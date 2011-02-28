Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 929568D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 06:45:24 -0500 (EST)
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110225215123.GA10026@flint.arm.linux.org.uk>
References: <20110217162327.434629380@chello.nl>
	 <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins>
	 <1298657083.2428.2483.camel@twins>
	 <20110225215123.GA10026@flint.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Feb 2011 12:44:47 +0100
Message-ID: <1298893487.2428.10537.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>

On Fri, 2011-02-25 at 21:51 +0000, Russell King wrote:
> On Fri, Feb 25, 2011 at 07:04:43PM +0100, Peter Zijlstra wrote:
> > I'm not quite sure why you chose to add range tracking on
> > pte_free_tlb(), the only affected code path seems to be unmap_region()
> > where you'll use a flush_tlb_range(), but its buggy, the pte_free_tlb()
> > range is much larger than 1 page, and if you do it there you also need
> > it for all the other p??_free_tlb() functions.
>=20
> My reasoning is to do with the way the LPAE stuff works.  For the
> explaination below, I'm going to assume a 2 level page table system
> for simplicity.
>=20
> The first thing to realise is that if we have L2 entries, then we'll
> have unmapped them first using the usual tlb shootdown interfaces.
>=20
> However, when we're freeing the page tables themselves, we should
> already have removed the L2 entries, so all we have are the L1 entries.
> In most 'normal' processors, these aren't cached in any way.
>=20
> Howver, with LPAE, these are cached.  I'm told that any TLB flush for an
> address which is covered by the L1 entry will cause that cached entry to
> be invalidated.
>=20
> So really this is about getting rid of cached L1 entries, and not the
> usual TLB lookaside entries that you'd come to expect.


Right, so the normal case is:

  unmap_region()
    tlb_gather_mmu()
    unmap_vmas()
      for (; vma; vma =3D vma->vm_next)
        unmao_page_range()
          tlb_start_vma() -> flush cache range
          zap_*_range()
            ptep_get_and_clear_full() -> batch/track external tlbs
            tlb_remove_tlb_entry() -> batch/track external tlbs
            tlb_remove_page() -> track range/batch page
          tlb_end_vma() -> flush tlb range

 [ for architectures that have hardware page table walkers
   concurrent faults can still load the page tables ]

    free_pgtables()
      while (vma)
        unlink_*_vma()
        free_*_range()
          *_free_tlb()
    tlb_finish_mmu()

  free vmas


Now, if we want to track ranges _and_ have hardware page table walkers
(ARM seems to be one such), we must flush TLBs at tlb_end_vma() because
flush_tlb_range() requires a vma pointer (ARM and TILE actually use more
than ->vm_mm), and on tlb_finish_mmu() issue a full mm wide invalidate
because the hardware walker could have re-populated the cache after
clearing the PTEs but before freeing the page tables.

What ARM does is it retains the last vma pointer and tracks
pte_free_tlb() range and uses that in tlb_finish_mmu(), which is a tad
hacky.

Mostly because of shift_arg_pages(), where we have:

  shift_arg_pages()
    tlb_gather_mmu()
    free_*_range()
    tlb_finish_mmu()

For which ARM now punts and does a full tlb invalidate (no vma pointer).
But also because it drags along that vma pointer, which might not at all
match the range its actually going to invalidate (and hence its vm_flags
might not accurately reflect things -- at worst more expensive than
needed).

The reason I wanted flush_tlb_range() to take an mm_struct and not the
current vm_area_struct is because we can avoid doing the
flush_tlb_range() from tlb_end_vma() and delay the thing until
tlb_finish_mmu() without having to resort to such games as above. We
could simply track the full range over all VMAs and free'd page-tables
and do one range invalidate.

ARM uses vm_flags & VM_EXEC to see if it also needs to invalidate
I-TLBs, and TILE uses VM_EXEC and VM_HUGETLB.

For the I-TLBs we could easily use
ptep_get_and_clear_full()/tlb_remove_tlb_entry() and see if any of the
cleared pte's had its executable bit set (both ARM and TILE seem to have
such a PTE bit).

I'm not sure what we can do about TILE's VM_HUGETLB usage though, if it
needs explicit flushes for huge ptes it might just have to issue
multiple tlb invalidates and do them from tlb_start_vma()/tlb_end_vma().

So my current proposal for generic mmu_gather (not fully coded yet) is
to provide a number of CONFIG_goo switches:

  CONFIG_HAVE_RCU_TABLE_FREE - for architectures that do not walk the
linux page tables in hardware (Sparc64, PowerPC, etc), and others where
TLB flushing isn't delayed by disabling IRQs (Xen, s390).

  CONFIG_HAVE_MMU_GATHER_RANGE - will track start,end ranges from
tlb_remove_tlb_entry() and p*_free_tlb() and issue
flush_tlb_range(mm,start,end) instead of mm-wide invalidates.

  CONFIG_HAVE_MMU_GATHER_ITLB - will use
ptep_get_and_clear_full()/tlb_remove_tlb_entry() to test pte_exec() and
issue flush_itlb_range(mm,start,end).

Then there is the optimization s390 wants, which is to do a full mm tlb
flush for fullmm (exit_mmap()) at tlb_gather_mmu() and never again after
that, since there is guaranteed no concurrency to poke at anything.
AFAICT that should work on all architectures so we can do that
unconditionally.

So the biggest problem with implementing the above is TILE, where we
need to figure out wth to do with its hugetlb stuff.

The second biggest problem is with ARM and TILE, where we'd need to
implement flush_itlb_range(). I've already got a patch for all other
architectures to convert flush_tlb_range() to mm_struct.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
