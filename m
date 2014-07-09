Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 411746B0038
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 20:06:41 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so8264705pad.9
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 17:06:40 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ey3si31978493pbb.194.2014.07.08.17.06.35
        for <linux-mm@kvack.org>;
        Tue, 08 Jul 2014 17:06:39 -0700 (PDT)
Date: Wed, 9 Jul 2014 09:06:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v11 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20140709000631.GB32385@bbox>
References: <1404799424-1120-1-git-send-email-minchan@kernel.org>
 <1404799424-1120-2-git-send-email-minchan@kernel.org>
 <20140708094114.GA3490@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140708094114.GA3490@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Tue, Jul 08, 2014 at 12:41:14PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jul 08, 2014 at 03:03:38PM +0900, Minchan Kim wrote:
> > Linux doesn't have an ability to free pages lazy while other OS
> > already have been supported that named by madvise(MADV_FREE).
> > 
> > The gain is clear that kernel can discard freed pages rather than
> > swapping out or OOM if memory pressure happens.
> > 
> > Without memory pressure, freed pages would be reused by userspace
> > without another additional overhead(ex, page fault + allocation
> > + zeroing).
> > 
> > How to work is following as.
> > 
> > When madvise syscall is called, VM clears dirty bit of ptes of
> > the range. If memory pressure happens, VM checks dirty bit of
> > page table and if it found still "clean", it means it's a
> > "lazyfree pages" so VM could discard the page instead of swapping out.
> > Once there was store operation for the page before VM peek a page
> > to reclaim, dirty bit is set so VM can swap out the page instead of
> > discarding.
> > 
> > Firstly, heavy users would be general allocators(ex, jemalloc,
> > tcmalloc and hope glibc supports it) and jemalloc/tcmalloc already
> > have supported the feature for other OS(ex, FreeBSD)
> > 
> > barrios@blaptop:~/benchmark/ebizzy$ lscpu
> > Architecture:          x86_64
> > CPU op-mode(s):        32-bit, 64-bit
> > Byte Order:            Little Endian
> > CPU(s):                4
> > On-line CPU(s) list:   0-3
> > Thread(s) per core:    2
> > Core(s) per socket:    2
> > Socket(s):             1
> > NUMA node(s):          1
> > Vendor ID:             GenuineIntel
> > CPU family:            6
> > Model:                 42
> > Stepping:              7
> > CPU MHz:               2801.000
> > BogoMIPS:              5581.64
> > Virtualization:        VT-x
> > L1d cache:             32K
> > L1i cache:             32K
> > L2 cache:              256K
> > L3 cache:              4096K
> > NUMA node0 CPU(s):     0-3
> > 
> > ebizzy benchmark(./ebizzy -S 10 -n 512)
> > 
> >  vanilla-jemalloc		MADV_free-jemalloc
> > 
> > 1 thread
> > records:  10              records:  10
> > avg:      7682.10         avg:      15306.10
> > std:      62.35(0.81%)    std:      347.99(2.27%)
> > max:      7770.00         max:      15622.00
> > min:      7598.00         min:      14772.00
> > 
> > 2 thread
> > records:  10              records:  10
> > avg:      12747.50        avg:      24171.00
> > std:      792.06(6.21%)   std:      895.18(3.70%)
> > max:      13337.00        max:      26023.00
> > min:      10535.00        min:      23152.00
> > 
> > 4 thread
> > records:  10              records:  10
> > avg:      16474.60        avg:      33717.90
> > std:      1496.45(9.08%)  std:      2008.97(5.96%)
> > max:      17877.00        max:      35958.00
> > min:      12224.00        min:      29565.00
> > 
> > 8 thread
> > records:  10              records:  10
> > avg:      16778.50        avg:      33308.10
> > std:      825.53(4.92%)   std:      1668.30(5.01%)
> > max:      17543.00        max:      36010.00
> > min:      14576.00        min:      29577.00
> > 
> > 16 thread
> > records:  10              records:  10
> > avg:      20614.40        avg:      35516.30
> > std:      602.95(2.92%)   std:      1283.65(3.61%)
> > max:      21753.00        max:      37178.00
> > min:      19605.00        min:      33217.00
> > 
> > 32 thread
> > records:  10              records:  10
> > avg:      22771.70        avg:      36018.50
> > std:      598.94(2.63%)   std:      1046.76(2.91%)
> > max:      24035.00        max:      37266.00
> > min:      22108.00        min:      34149.00
> > 
> > In summary, MADV_FREE is about 2 time faster than MADV_DONTNEED.
> > 
> > Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> > Cc: Linux API <linux-api@vger.kernel.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Jason Evans <je@fb.com>
> > Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/rmap.h                   |   9 ++-
> >  include/linux/vm_event_item.h          |   1 +
> >  include/uapi/asm-generic/mman-common.h |   1 +
> >  mm/madvise.c                           | 135 +++++++++++++++++++++++++++++++++
> >  mm/rmap.c                              |  42 +++++++++-
> >  mm/vmscan.c                            |  40 ++++++++--
> >  mm/vmstat.c                            |   1 +
> >  7 files changed, 217 insertions(+), 12 deletions(-)
> > 
> 
> ...
> 
> > @@ -251,6 +260,124 @@ static long madvise_willneed(struct vm_area_struct *vma,
> >  	return 0;
> >  }
> >  
> > +static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> > +				unsigned long end, struct mm_walk *walk)
> > +
> > +{
> > +	struct madvise_free_private *fp = walk->private;
> > +	struct mmu_gather *tlb = fp->tlb;
> > +	struct mm_struct *mm = tlb->mm;
> > +	struct vm_area_struct *vma = fp->vma;
> > +	spinlock_t *ptl;
> > +	pte_t *pte, ptent;
> > +	struct page *page;
> > +
> > +	split_huge_page_pmd(vma, addr, pmd);
> > +	if (pmd_trans_unstable(pmd))
> > +		return 0;
> > +
> > +	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> > +	arch_enter_lazy_mmu_mode();
> > +	for (; addr != end; pte++, addr += PAGE_SIZE) {
> > +		ptent = *pte;
> > +
> > +		if (pte_none(ptent))
> > +			continue;
> 
> The check is redundant: all pte_none() entries are also !pte_present().

True.

> 
> > +
> > +		if (!pte_present(ptent))
> > +			continue;
> > +
> > +		page = vm_normal_page(vma, addr, ptent);
> > +		if (page && PageSwapCache(page)) {
> > +			if (trylock_page(page)) {
> > +				if (try_to_free_swap(page))
> > +					ClearPageDirty(page);
> > +				unlock_page(page);
> > +			} else
> > +				continue;
> > +		}
> 
> Is it safe to touch non-vm_normal entries? I would suggest to put
>   if (!page)
> 	  continue;
> instead.

That's right!

> 
> > +		/*
> > +		 * Some of architecture(ex, PPC) don't update TLB
> > +		 * with set_pte_at and tlb_remove_tlb_entry so for
> > +		 * the portability, remap the pte with old|clean
> > +		 * after pte clearing.
> > +		 */
> > +		ptent = ptep_get_and_clear_full(mm, addr, pte,
> > +						tlb->fullmm);
> > +		ptent = pte_mkold(ptent);
> > +		ptent = pte_mkclean(ptent);
> > +		set_pte_at(mm, addr, pte, ptent);
> > +		tlb_remove_tlb_entry(tlb, pte, addr);
> > +	}
> > +	arch_leave_lazy_mmu_mode();
> > +	pte_unmap_unlock(pte - 1, ptl);
> > +	cond_resched();
> > +	return 0;
> > +}
> > +
> > +static void madvise_free_page_range(struct mmu_gather *tlb,
> > +			     struct vm_area_struct *vma,
> > +			     unsigned long addr, unsigned long end)
> > +{
> > +	struct madvise_free_private fp = {
> > +		.vma = vma,
> > +		.tlb = tlb,
> > +	};
> > +
> > +	struct mm_walk free_walk = {
> > +		.pmd_entry = madvise_free_pte_range,
> > +		.mm = vma->vm_mm,
> > +		.private = &fp,
> > +	};
> > +
> > +	BUG_ON(addr >= end);
> > +	tlb_start_vma(tlb, vma);
> > +	walk_page_range(addr, end, &free_walk);
> > +	tlb_end_vma(tlb, vma);
> > +}
> > +
> > +static int madvise_free_single_vma(struct vm_area_struct *vma,
> > +			unsigned long start_addr, unsigned long end_addr)
> > +{
> > +	unsigned long start, end;
> > +	struct mm_struct *mm = vma->vm_mm;
> > +	struct mmu_gather tlb;
> > +
> > +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> > +		return -EINVAL;
> 
> VM_MIXEDMAP? VM_IO? Should it be whitelist instead?

Don't they work with vma->vm_file?
so, below check will filter it out.

> 
> > +
> > +	/* MADV_FREE works for only anon vma at the moment */
> > +	if (vma->vm_file)
> > +		return -EINVAL;
> > +
> > +	start = max(vma->vm_start, start_addr);
> > +	if (start >= vma->vm_end)
> > +		return -EINVAL;
> > +	end = min(vma->vm_end, end_addr);
> > +	if (end <= vma->vm_start)
> > +		return -EINVAL;
> > +
> > +	lru_add_drain();
> > +	tlb_gather_mmu(&tlb, mm, start, end);
> > +	update_hiwater_rss(mm);
> > +
> > +	mmu_notifier_invalidate_range_start(mm, start, end);
> > +	madvise_free_page_range(&tlb, vma, start, end);
> > +	mmu_notifier_invalidate_range_end(mm, start, end);
> > +	tlb_finish_mmu(&tlb, start, end);
> > +
> > +	return 0;
> > +}
> > +
> > +static long madvise_free(struct vm_area_struct *vma,
> > +			     struct vm_area_struct **prev,
> > +			     unsigned long start, unsigned long end)
> > +{
> > +	*prev = vma;
> > +	return madvise_free_single_vma(vma, start, end);
> > +}
> > +
> >  /*
> >   * Application no longer needs these pages.  If the pages are dirty,
> >   * it's OK to just throw them away.  The app will be more careful about
> > @@ -381,6 +508,13 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
> >  		return madvise_remove(vma, prev, start, end);
> >  	case MADV_WILLNEED:
> >  		return madvise_willneed(vma, prev, start, end);
> > +	case MADV_FREE:
> > +		/*
> > +		 * XXX: In this implementation, MADV_FREE works like
> > +		 * MADV_DONTNEED on swapless system or full swap.
> > +		 */
> > +		if (get_nr_swap_pages() > 0)
> > +			return madvise_free(vma, prev, start, end);
> 
> /* passthough */
> 
> >  	case MADV_DONTNEED:
> >  		return madvise_dontneed(vma, prev, start, end);
> >  	default:
> 
> ...
> 
> > @@ -1186,6 +1210,19 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  		swp_entry_t entry = { .val = page_private(page) };
> >  		pte_t swp_pte;
> >  
> > +		if (flags & TTU_FREE) {
> > +			VM_BUG_ON_PAGE(PageSwapCache(page), page);
> > +			if (dirty || PageDirty(page)) {
> > +				set_pte_at(mm, address, pte, pteval);
> > +				ret = SWAP_FAIL;
> > +				goto out_unmap;
> 
> Hm. Again: do we really want stop here if caller asks for
> TTU_FREE|TTU_UNMAP or should proceed?

I'd like to stop.
If it is dirty in here, it means the page have been accessed during window
between page_check_references and try_to_unmap in shrink_page_list so
the page should be cycled one more time in LRU list without swapping.

But it's not a good idea to pass TTU_FREE|TTU_UNMAP together for redability
because people can think try_to_unmap will try both.
so I will modify it.

Thanks for the review!

> 
> > +			} else {
> > +				/* It's a freeable page by MADV_FREE */
> > +				dec_mm_counter(mm, MM_ANONPAGES);
> > +				goto discard;
> > +			}
> > +		}
> > +
> >  		if (PageSwapCache(page)) {
> >  			/*
> >  			 * Store the swap location in the pte.
> -- 
>  Kirill A. Shutemov
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
