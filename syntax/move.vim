" Vim syntax file
" Language: Move
" Maintainer: Richard Melkonian <r.v.melkonian@gmail.com>
" Latest Version: 0.1.0

if exists("b:current_syntax")
  finish
endif

" Syntax definitions {{{1
" Basic keywords {{{2
syn keyword   moveConditional if else match
syn keyword   moveRepeat loop while
syn keyword   moveStructure struct enum nextgroup=moveNonPrimitiveType skipwhite skipempty
syn keyword   moveOperator    as

syn match     moveAssert      "\<assert\(\w\)*!" contained
syn keyword   moveKeyword     break continue module use native drop store copy phantom key has return let mut friend
syn keyword   moveKeyword     public nextgroup=movePubScope skipwhite skipempty
syn keyword   moveKeyword     fun nextgroup=moveFuncName skipwhite skipempty
syn keyword   moveKeyword     entry nextgroup=moveKeyword skipwhite skipempty
syn keyword   moveKeyword     module nextgroup=moveModPath skipwhite skipempty
syn keyword   moveKeyword     use nextgroup=moveModPath skipwhite skipempty

syn keyword   moveStorage     borrow_global borrow_global_mut move_to move_from
syn keyword   moveStorage const nextgroup=moveIdentifier skipwhite skipempty

syn keyword movePubScopeFriend friend contained
syn match movePubScopeDelim /[()]/ contained
syn match movePubScope /([^()]*)/ contained contains=movePubScopeFriend transparent

syn match moveNonPrimitiveType "\(\u\w*\)"
syn match     moveIdentifier  "\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*" display contained
syn match     moveFuncName    "\%(r#\)\=\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*" display contained

syn keyword   moveType        bool u8 u16 u32 u64 u128 u256 address vector
syn keyword   moveBoolean     true false

" If foo::bar changes to foo.bar, change this ("::" to "\.").
" If foo::bar changes to Foo::bar, change this (first "\w" to "\u").
syn match     moveModPath     "\w\(\w\)*::[^<]"he=e-3,me=e-3
syn match     moveModPathSep  "::"

" A bit heuristic-y but functions always start with a lowercase character...
syn match     moveFuncCall    "\l\(\w\)*("he=e-1,me=e-1
syn match     moveFuncCall    "\l\(\w\)*\ze<"he=e,me=e nextgroup=moveTypeParams " foo<T>();
" Same here: heuristically all type param (just like moveNonPrimitiveType)
" start with an uppercase character
syn match     moveTypeParams    "<*\l\(\w\)*>"he=e,me=e

" This is merely a convention; note also the use of [A-Z], restricting it to
" latin identifiers rather than the full Unicode uppercase. I have not used
" [:upper:] as it depends upon 'noignorecase'
"syn match     moveCapsIdent    display "[A-Z]\w\(\w\)*"

syn match     moveOperator     display "\%(+\|-\|/\|*\|=\|\^\|&\||\|!\|>\|<\|%\)=\?"
" This one isn't *quite* right, as we could have binary-& with a reference
syn match     moveSigil        display /&\s\+[&~@*][^)= \t\r\n]/he=e-1,me=e-1
syn match     moveSigil        display /[&~@*][^)= \t\r\n]/he=e-1,me=e-1
" This isn't actually correct; a closure with no arguments can be `|| { }`.
" Last, because the & in && isn't a sigil
syn match     moveOperator     display "&&\|||"

syn match     moveMacro       '\w\(\w\)*!' contains=moveAssert
syn match     moveMacro       '#\w\(\w\)*' contains=moveAssert

syn region    moveString      matchgroup=moveStringDelimiter start=+b"+ end=+"+ contains=moveCharacter,moveCharacterInvalid
syn region    moveHexString      matchgroup=moveStringDelimiter start=+h"+ end=+"+ contains=moveHexCharacter,moveHexCharacterInvalid

" Match attributes with either arbitrary syntax or special highlighting for
" derives. We still highlight strings and comments inside of the attribute.
syn region    moveAttribute   start="#!\?\[" end="\]" contains=@moveAttributeContents,moveAttributeParenthesizedParens,moveAttributeParenthesizedCurly,moveAttributeParenthesizedBrackets
syn region    moveAttributeParenthesizedParens matchgroup=moveAttribute start="\w\%(\w\)*("rs=e end=")"re=s transparent contained contains=moveAttributeBalancedParens,@moveAttributeContents
syn region    moveAttributeParenthesizedCurly matchgroup=moveAttribute start="\w\%(\w\)*{"rs=e end="}"re=s transparent contained contains=moveAttributeBalancedCurly,@moveAttributeContents
syn region    moveAttributeParenthesizedBrackets matchgroup=moveAttribute start="\w\%(\w\)*\["rs=e end="\]"re=s transparent contained contains=moveAttributeBalancedBrackets,@moveAttributeContents
syn region    moveAttributeBalancedParens matchgroup=moveAttribute start="("rs=e end=")"re=s transparent contained contains=moveAttributeBalancedParens,@moveAttributeContents
syn region    moveAttributeBalancedCurly matchgroup=moveAttribute start="{"rs=e end="}"re=s transparent contained contains=moveAttributeBalancedCurly,@moveAttributeContents
syn region    moveAttributeBalancedBrackets matchgroup=moveAttribute start="\["rs=e end="\]"re=s transparent contained contains=moveAttributeBalancedBrackets,@moveAttributeContents
syn cluster   moveAttributeContents contains=moveString,moveCommentLine,moveCommentBlock,moveCommentLineDocError,moveCommentBlockDocError

" Number literals
syn match     moveDecNumber   display "\<[0-9][0-9_]*\%([u]\%(256\|8\|16\|32\|64\|128\)\)\="
syn match     moveHexNumber   display "\<0x[a-fA-F0-9_]\+\%([u]\%(256\|8\|16\|32\|64\|128\)\)\="

" For the benefit of delimitMate
syn region moveGenericRegion display start=/<\%('\|[^[:cntrl:][:space:][:punct:]]\)\@=')\S\@=/ end=/>/ contains=moveGenericLifetimeCandidate
syn region moveGenericLifetimeCandidate display start=/\%(<\|,\s*\)\@<='/ end=/[[:cntrl:][:space:][:punct:]]\@=\|$/ contains=moveSigil

syn match   moveCharacterInvalid   display contained '\([^\x00-\x7f]\)'
syn match   moveHexCharacterInvalid   display contained '\([^a-fA-F0-9]\)'
" The groups negated here add up to 0-255 but nothing else (they do not seem to go beyond ASCII).
syn match   moveHexCharacter   display contained '\([0-9a-fA-F]\)' contains=moveHexCharacterInvalid
syn match   moveCharacter   display contained '\([\x00-x7f]\)' contains=moveCharacterInvalid

" --------- HERE

syn region moveCommentLine                                                  start="//"                      end="$"   contains=moveTodo,@Spell
syn region moveCommentLineDoc                                               start="//\%(//\@!\|!\)"         end="$"   contains=moveTodo,@Spell
syn region moveCommentLineDocError                                          start="//\%(//\@!\|!\)"         end="$"   contains=moveTodo,@Spell contained
syn region moveCommentBlock             matchgroup=moveCommentBlock         start="/\*\%(!\|\*[*/]\@!\)\@!" end="\*/" contains=moveTodo,moveCommentBlockNest,@Spell
syn region moveCommentBlockDoc          matchgroup=moveCommentBlockDoc      start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=moveTodo,moveCommentBlockDocNest,moveCommentBlockDocMoveCode,@Spell
syn region moveCommentBlockDocError     matchgroup=moveCommentBlockDocError start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=moveTodo,moveCommentBlockDocNestError,@Spell contained
syn region moveCommentBlockNest         matchgroup=moveCommentBlock         start="/\*"                     end="\*/" contains=moveTodo,moveCommentBlockNest,@Spell contained transparent
syn region moveCommentBlockDocNest      matchgroup=moveCommentBlockDoc      start="/\*"                     end="\*/" contains=moveTodo,moveCommentBlockDocNest,@Spell contained transparent
syn region moveCommentBlockDocNestError matchgroup=moveCommentBlockDocError start="/\*"                     end="\*/" contains=moveTodo,moveCommentBlockDocNestError,@Spell contained transparent

" FIXME: this is a really ugly and not fully correct implementation. Most
" importantly, a case like ``/* */*`` should have the final ``*`` not being in
" a comment, but in practice at present it leaves comments open two levels
" deep. But as long as you stay away from that particular case, I *believe*
" the highlighting is correct. Due to the way Vim's syntax engine works
" (greedy for start matches, unlike Move's tokeniser which is searching for
" the earliest-starting match, start or end), I believe this cannot be solved.
" Oh you who would fix it, don't bother with things like duplicating the Block
" rules and putting ``\*\@<!`` at the start of them; it makes it worse, as
" then you must deal with cases like ``/*/**/*/``. And don't try making it
" worse with ``\%(/\@<!\*\)\@<!``, either...

syn keyword moveTodo contained TODO FIXME XXX NB NOTE SAFETY

" Folding rules {{{2
" Trivial folding rules to begin with.
" FIXME: use the AST to make really good folding
syn region moveFoldBraces start="{" end="}" transparent fold

if !exists("b:current_syntax_embed")
    let b:current_syntax_embed = 1
    syntax include @MoveCodeInComment <sfile>:p:h/move.vim
    unlet b:current_syntax_embed

    " Currently regions marked as ```<some-other-syntax> will not get
    " highlighted at all. In the future, we can do as vim-markdown does and
    " highlight with the other syntax. But for now, let's make sure we find
    " the closing block marker, because the rules below won't catch it.
    syn region moveCommentLinesDocNonMoveCode matchgroup=moveCommentDocCodeFence start='^\z(\s*//[!/]\s*```\).\+$' end='^\z1$' keepend contains=moveCommentLineDoc

    " We borrow the rules from move’s src/libmovedoc/html/markdown.rs, so that
    " we only highlight as Move what it would perceive as Move (almost; it’s
    " possible to trick it if you try hard, and indented code blocks aren’t
    " supported because Markdown is a menace to parse and only mad dogs and
    " Englishmen would try to handle that case correctly in this syntax file).
    syn region moveCommentLinesDocMoveCode matchgroup=moveCommentDocCodeFence start='^\z(\s*//[!/]\s*```\)[^A-Za-z0-9_-]*\%(\%(should_panic\|no_run\|ignore\|allow_fail\|move\|test_harness\|compile_fail\|E\d\{4}\|edition201[58]\)\%([^A-Za-z0-9_-]\+\|$\)\)*$' end='^\z1$' keepend contains=@MoveCodeInComment,moveCommentLineDocLeader
    syn region moveCommentBlockDocMoveCode matchgroup=moveCommentDocCodeFence start='^\z(\%(\s*\*\)\?\s*```\)[^A-Za-z0-9_-]*\%(\%(should_panic\|no_run\|ignore\|allow_fail\|move\|test_harness\|compile_fail\|E\d\{4}\|edition201[58]\)\%([^A-Za-z0-9_-]\+\|$\)\)*$' end='^\z1$' keepend contains=@MoveCodeInComment,moveCommentBlockDocStar
    " Strictly, this may or may not be correct; this code, for example, would
    " mishighlight:
    "
    "     /**
    "     ```move
    "     println!("{}", 1
    "     * 1);
    "     ```
    "     */
    "
    " … but I don’t care. Balance of probability, and all that.
    syn match moveCommentBlockDocStar /^\s*\*\s\?/ contained
    syn match moveCommentLineDocLeader "^\s*//\%(//\@!\|!\)" contained
endif

" Default highlighting {{{1
hi def link moveDecNumber       moveNumber
hi def link moveHexNumber       moveNumber
hi def link moveNonPrimitiveType moveType

hi def link moveSigil         StorageClass
hi def link moveString        String
hi def link moveHexString        String
hi def link moveStringDelimiter String
hi def link moveCharacterInvalid Error
hi def link moveCharacter     Character
hi def link moveHexCharacterInvalid Error
hi def link moveHexCharacter     Character
hi def link moveNumber        Number
hi def link moveBoolean       Boolean
hi def link moveConstant      Constant
hi def link moveOperator      Operator
hi def link moveKeyword       Keyword
hi def link moveStructure     Keyword " More precise is Structure
hi def link movePubScopeDelim Delimiter
hi def link movePubScopeFriend moveKeyword
hi def link moveRepeat        Conditional
hi def link moveConditional   Conditional
hi def link moveIdentifier    Identifier
hi def link moveCapsIdent     moveIdentifier
hi def link moveModPath       Include
hi def link moveModPathSep    Delimiter
hi def link moveFuncName      Function
hi def link moveFuncCall      Function
hi def link moveCommentLine   Comment
hi def link moveCommentLineDoc SpecialComment
hi def link moveCommentLineDocLeader moveCommentLineDoc
hi def link moveCommentLineDocError Error
hi def link moveCommentBlock  moveCommentLine
hi def link moveCommentBlockDoc moveCommentLineDoc
hi def link moveCommentBlockDocStar moveCommentBlockDoc
hi def link moveCommentBlockDocError Error
hi def link moveCommentDocCodeFence moveCommentLineDoc
hi def link moveAssert        PreCondit
hi def link moveMacro         Macro
hi def link moveType          Type
hi def link moveTypeParams         Type
hi def link moveTodo          Todo
hi def link moveAttribute     PreProc
hi def link moveStorage       StorageClass

" Other Suggestions:
" hi moveAttribute ctermfg=cyan
" hi moveAssert ctermfg=yellow
" hi moveMacro ctermfg=magenta

syn sync minlines=200
syn sync maxlines=500

let b:current_syntax = "move"

" vim: set et sw=4 sts=4 ts=8:

