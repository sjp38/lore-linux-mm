Date: Mon, 20 Dec 2004 19:47:28 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org>
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Tue, 21 Dec 2004, Hugh Dickins wrote:

> On Tue, 21 Dec 2004, Nick Piggin wrote:
> > 
> > Anyway, I'll continue to try to get more architecture support,
> 
> Sorry for being dense: despite your earlier explanation,
> I've yet again lost track of why pud needs any flag day through
> the architectures - beyond the inclusion of some generic nopud.h,
> but different from the one you're rightly aiming for.

It really should not need one.

If you do it right (and "right" here means "wrong"), all architectures 
should continue to work, aside from the fact that they get some nasty 
pointer type warnings.

> Good as they are, imagine setting aside your nopmd.h mods as a cleanup
> for some other occasion.  Then wouldn't a generic nopud.h something like
> 
> #define pud_t				pgd_t
> #define pud_alloc(mm, pgd, address)	(pgd)
> #define pud_offset(pgd, start)		(pgd)
> #define pud_none(pud)			0
> #define pud_bad(pud)			0
> #define pud_ERROR(pud)
> #define pud_clear(pud)
> #define PUD_SIZE			PGDIR_SIZE
> #define PUD_MASK			PGDIR_MASK

That gets it 99% of the way, but the fact is, code that hasn't been
changed to actually _use_ pud_t etc will get a warning because it will
pass down a "pgd_t *" to the "pmd_present()" things, and that's wrong -
they should be converted to get "pud_t"s.

(Or, the other way around: if an architecture has _not_ updated its 
pmd_offset() etc friends, it will get horrible pointer type warnings from 
code that expects a pud_t).

But since such an architecture will actually only _have_ three levels of 
pages tables anyway, the warnings will be only warnings - the code 
generated should be correct anyway.

(It may be _possible_ to avoid the warnings by just making "pud_t" and
"pmd_t" be the same type for such architectures, and just allowing
_mixing_ of three-level and four-level accesses.  I have to say that I 
consider that pretty borderline programming practice though).

> But I don't see why the pagetable code in each arch subdirectory needs
> to have a pud level inserted all at once (whereas a flag day was needed
> for the pml4 patch, because mm->pgd got replaced by mm->pml4).

There is a "flag day", because even architectures that haven't been
updated to 4-level page tables will see the four-level page table accessor
functions in generic code. But see above: I think we can make the
"flagness"  be less critical, in the sense that it will generate warnings,
but the code will still work.

But yes, that really _requires_ that the new level is in the "middle", aka 
the pud_t approach of Nick's patches. And I may be missing something.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
