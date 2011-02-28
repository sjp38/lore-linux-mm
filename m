Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88E058D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 07:29:52 -0500 (EST)
Date: Mon, 28 Feb 2011 12:28:04 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
Message-ID: <20110228122803.GC492@flint.arm.linux.org.uk>
References: <20110217162327.434629380@chello.nl> <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins> <1298657083.2428.2483.camel@twins> <20110225215123.GA10026@flint.arm.linux.org.uk> <1298893487.2428.10537.camel@twins> <20110228115907.GB492@flint.arm.linux.org.uk> <1298895612.2428.10621.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298895612.2428.10621.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, Feb 28, 2011 at 01:20:12PM +0100, Peter Zijlstra wrote:
> On Mon, 2011-02-28 at 11:59 +0000, Russell King wrote:
> > On Mon, Feb 28, 2011 at 12:44:47PM +0100, Peter Zijlstra wrote:
> > > Right, so the normal case is:
> > > 
> > >   unmap_region()
> > >     tlb_gather_mmu()
> > 
> > The fullmm argument is important here as it specifies the mode.
> 
> well, unmap_region always has that 0, I've mentioned the fullmm mode
> separately below, its in many way the easiest case to deal with.
> 
> >       tlb_gather_mmu(, 0)
> > 
> > >     unmap_vmas()
> > >       for (; vma; vma = vma->vm_next)
> > >         unmao_page_range()
> > >           tlb_start_vma() -> flush cache range
> > >           zap_*_range()
> > >             ptep_get_and_clear_full() -> batch/track external tlbs
> > >             tlb_remove_tlb_entry() -> batch/track external tlbs
> > >             tlb_remove_page() -> track range/batch page
> > >           tlb_end_vma() -> flush tlb range
> > 
> >        tlb_finish_mmu() -> nothing
> > 
> > > 
> > >  [ for architectures that have hardware page table walkers
> > >    concurrent faults can still load the page tables ]
> > > 
> > >     free_pgtables()
> > 
> >         tlb_gather_mmu(, 1)
> > 
> > >       while (vma)
> > >         unlink_*_vma()
> > >         free_*_range()
> > >           *_free_tlb()
> > >     tlb_finish_mmu()
> > 
> >       tlb_finish_mmu() -> flush tlb mm
> > 
> > > 
> > >   free vmas
> > 
> > So this is all fine.  Note that we *don't* use the range stuff here.
> > 
> > > Now, if we want to track ranges _and_ have hardware page table walkers
> > > (ARM seems to be one such), we must flush TLBs at tlb_end_vma() because
> > > flush_tlb_range() requires a vma pointer (ARM and TILE actually use more
> > > than ->vm_mm), and on tlb_finish_mmu() issue a full mm wide invalidate
> > > because the hardware walker could have re-populated the cache after
> > > clearing the PTEs but before freeing the page tables.
> > 
> > No.  The hardware walker won't re-populate the TLB after the page table
> 
> Never said it would repopulate the TLB, just said it could repopulate
> your cache thing and that it might still walk the page tables.
> 
> > entries have been cleared - where would it get this information from if
> > not from the page tables?
> > 
> > > What ARM does is it retains the last vma pointer and tracks
> > > pte_free_tlb() range and uses that in tlb_finish_mmu(), which is a tad
> > > hacky.
> > 
> > It may be hacky but then the TLB shootdown interface is hacky too.  We
> > don't keep the vma around to re-use after tlb_end_vma() - if you think
> > that then you misunderstand what's going on.  The vma pointer is kept
> > around as a cheap way of allowing tlb_finish_mmu() to distinguish
> > between the unmap_region() mode and the shift_arg_pages() mode.
> 
> Well, you most certainly use it in the unmap_region() case above.
> tlb_end_vma() will do a flush_tlb_range(), but then your
> __pte_free_tlb() will also track range and the tlb_finish_mmu() will
> then again issue a flush_tlb_range() using the last vma pointer.

Can you point out where pte_free_tlb() is used with unmap_region()?

> unmap_region()'s last tlb_start_vma(), with __pte_free_tlb() tracking
> range will then get tlb_finish_mmu() to issue a second
> flush_tlb_range().

I don't think it will because afaics pte_free_tlb() is never called in
the unmap_region() case.

> > No.  That's stupid.  Consider the case where you have to loop one page
> > at a time over the range (we do on ARM.)  If we ended up with your
> > suggestion above, that means we could potentially have to loop 4K at a
> > time over 3GB of address space.  That's idiotic when we have an
> > instruction which can flush the entire TLB for a particular thread.
> 
> *blink* so you've implemented flush_tlb_range() as an iteration of
> single page invalidates?

Yes, because flush_tlb_range() is used at most over one VMA, which
typically will not be in the GB range, but a few MB at most.

> Anyway, I don't see how that's related to the I-TLB thing?

It's all related because I don't think you understand what's going on
here properly yet, and as such are getting rather mixed up and confused
about when flush_tlb_range() is called.  As such, the whole
does-it-take-vma-or-mm argument is irrelevant, and therefore so is
the I-TLB stuff.

I put to you that pte_free_tlb() is not called in unmap_vmas(), and
as such the double-tlb-invalidate you talk about can't happen.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
