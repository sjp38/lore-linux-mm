Date: Tue, 21 Dec 2004 02:55:25 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <1103590078.5121.15.camel@npiggin-nld.site>
Message-ID: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 2004, Nick Piggin wrote:
> 
> Anyway, I'll continue to try to get more architecture support,

Sorry for being dense: despite your earlier explanation,
I've yet again lost track of why pud needs any flag day through
the architectures - beyond the inclusion of some generic nopud.h,
but different from the one you're rightly aiming for.

Good as they are, imagine setting aside your nopmd.h mods as a cleanup
for some other occasion.  Then wouldn't a generic nopud.h something like

#define pud_t				pgd_t
#define pud_alloc(mm, pgd, address)	(pgd)
#define pud_offset(pgd, start)		(pgd)
#define pud_none(pud)			0
#define pud_bad(pud)			0
#define pud_ERROR(pud)
#define pud_clear(pud)
#define PUD_SIZE			PGDIR_SIZE
#define PUD_MASK			PGDIR_MASK

get your kernel with common patch 6/10 compiling and working correctly
on all architectures?  with just a one-line mod to each architecture
to include it?

Your answer seems to be no, so I guess there's a place in the code
you can point to, which shows up the nonsense of this suggestion:
please humiliate me!

Certainly x86_64 then needs to use other definitions to get its 4levels
working.  And it'd be highly advisable to convert i386 and some other
common architectures (as you have already done) to use more typesafe
declarations in which a pud_t is distinct from a pgd_t, so that people
building mods to the common pagetable code cannot mix levels by mistake.

But I don't see why the pagetable code in each arch subdirectory needs
to have a pud level inserted all at once (whereas a flag day was needed
for the pml4 patch, because mm->pgd got replaced by mm->pml4).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
