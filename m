Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 376A68D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 17:05:43 -0500 (EST)
Message-ID: <4D6D6DB4.5020603@tilera.com>
Date: Tue, 1 Mar 2011 17:05:40 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
References: <20110217162327.434629380@chello.nl>	 <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins>	 <1298657083.2428.2483.camel@twins>	 <20110225215123.GA10026@flint.arm.linux.org.uk> <1298893487.2428.10537.camel@twins>
In-Reply-To: <1298893487.2428.10537.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Russell King <rmk@arm.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>

On 2/28/2011 6:44 AM, Peter Zijlstra wrote:
> [...]
> Now, if we want to track ranges _and_ have hardware page table walkers
> (ARM seems to be one such), we must flush TLBs at tlb_end_vma() because
> flush_tlb_range() requires a vma pointer (ARM and TILE actually use more
> than ->vm_mm), and on tlb_finish_mmu() issue a full mm wide invalidate
> because the hardware walker could have re-populated the cache after
> clearing the PTEs but before freeing the page tables.
>
> What ARM does is it retains the last vma pointer and tracks
> pte_free_tlb() range and uses that in tlb_finish_mmu(), which is a tad
> hacky.
>
> Mostly because of shift_arg_pages(), where we have:
>
>   shift_arg_pages()
>     tlb_gather_mmu()
>     free_*_range()
>     tlb_finish_mmu()
>
> For which ARM now punts and does a full tlb invalidate (no vma pointer).
> But also because it drags along that vma pointer, which might not at all
> match the range its actually going to invalidate (and hence its vm_flags
> might not accurately reflect things -- at worst more expensive than
> needed).
>
> The reason I wanted flush_tlb_range() to take an mm_struct and not the
> current vm_area_struct is because we can avoid doing the
> flush_tlb_range() from tlb_end_vma() and delay the thing until
> tlb_finish_mmu() without having to resort to such games as above. We
> could simply track the full range over all VMAs and free'd page-tables
> and do one range invalidate.
>
> ARM uses vm_flags & VM_EXEC to see if it also needs to invalidate
> I-TLBs, and TILE uses VM_EXEC and VM_HUGETLB.
>
> For the I-TLBs we could easily use
> ptep_get_and_clear_full()/tlb_remove_tlb_entry() and see if any of the
> cleared pte's had its executable bit set (both ARM and TILE seem to have
> such a PTE bit).

For Tile, the concern is that we want to make sure to invalidate the
i-cache.  The I-TLB is handled by the regular TLB flush just fine, like the
other architectures.  So our concern is that once we have cleared the page
table entries and invalidated the TLBs, we still have to deal with i-cache
lines in any core that may have run code from that page.  The risk is that
the kernel might free, reallocate, and then run code from one of those
pages, all before the stale i-cache lines happened to be evicted.

The current Tile code flushes the icache explicitly at two different times:

1. Whenever we flush the TLB, since this is one time when we know who might
currently be using the page (via cpu_vm_mask) and we can flush all of them
easily, piggybacking on the infrastructure we use to flush remote TLBs.

2. Whenever we context switch, to handle the case where cpu 1 is running
process A, then switches to B, but another cpu still running process A
unmaps an executable page that was in cpu 1's icache.  This way when cpu 1
switches back to A, it doesn't have to worry about any unmaps that occurred
while it was switched out.


> I'm not sure what we can do about TILE's VM_HUGETLB usage though, if it
> needs explicit flushes for huge ptes it might just have to issue
> multiple tlb invalidates and do them from tlb_start_vma()/tlb_end_vma().

I'm not too concerned about this.  We can make the flush code check both
page sizes at a small cost in efficiency, relative to the overall cost of
global TLB invalidation.

>   CONFIG_HAVE_MMU_GATHER_ITLB - will use
> ptep_get_and_clear_full()/tlb_remove_tlb_entry() to test pte_exec() and
> issue flush_itlb_range(mm,start,end).

So it sounds like the proposal for tile would be to piggy-back on
flush_itlb_range() and use it to flush the i-cache?  It does seem like
there must be other Linux architectures with incoherent icache out there,
and some existing solution we could just repurpose.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
