Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A43956B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 22:21:57 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so3953266pab.0
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 19:21:57 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id p1si2135763pdi.7.2014.07.17.19.21.55
        for <linux-mm@kvack.org>;
        Thu, 17 Jul 2014 19:21:56 -0700 (PDT)
Date: Fri, 18 Jul 2014 11:22:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v12 1/8] mm: support madvise(MADV_FREE)
Message-ID: <20140718022232.GA3162@bbox>
References: <1404886949-17695-1-git-send-email-minchan@kernel.org>
 <1404886949-17695-2-git-send-email-minchan@kernel.org>
 <20140717112832.GA10127@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140717112832.GA10127@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Thu, Jul 17, 2014 at 02:28:32PM +0300, Kirill A. Shutemov wrote:
> On Wed, Jul 09, 2014 at 03:22:22PM +0900, Minchan Kim wrote:
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
> > Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/rmap.h                   |   9 ++-
> >  include/linux/vm_event_item.h          |   1 +
> >  include/uapi/asm-generic/mman-common.h |   1 +
> >  mm/madvise.c                           | 136 +++++++++++++++++++++++++++++++++
> >  mm/rmap.c                              |  42 +++++++++-
> >  mm/vmscan.c                            |  40 ++++++++--
> >  mm/vmstat.c                            |   1 +
> >  7 files changed, 218 insertions(+), 12 deletions(-)
> > 
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index be574506e6a9..0ba377b97a38 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -75,6 +75,7 @@ enum ttu_flags {
> >  	TTU_UNMAP = 1,			/* unmap mode */
> >  	TTU_MIGRATION = 2,		/* migration mode */
> >  	TTU_MUNLOCK = 4,		/* munlock mode */
> > +	TTU_FREE = 8,			/* free mode */
> >  
> >  	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
> >  	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
> > @@ -181,7 +182,8 @@ static inline void page_dup_rmap(struct page *page)
> >   * Called from mm/vmscan.c to handle paging out
> >   */
> >  int page_referenced(struct page *, int is_locked,
> > -			struct mem_cgroup *memcg, unsigned long *vm_flags);
> > +			struct mem_cgroup *memcg, unsigned long *vm_flags,
> > +			int *is_dirty);
> >  
> >  #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
> >  
> > @@ -260,9 +262,12 @@ int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
> >  
> >  static inline int page_referenced(struct page *page, int is_locked,
> >  				  struct mem_cgroup *memcg,
> > -				  unsigned long *vm_flags)
> > +				  unsigned long *vm_flags,
> > +				  int *is_pte_dirty)
> >  {
> >  	*vm_flags = 0;
> > +	if (is_pte_dirty)
> > +		*is_pte_dirty = 0;
> >  	return 0;
> >  }
> >  
> > diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> > index ced92345c963..e2d3fb1e9814 100644
> > --- a/include/linux/vm_event_item.h
> > +++ b/include/linux/vm_event_item.h
> > @@ -25,6 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >  		FOR_ALL_ZONES(PGALLOC),
> >  		PGFREE, PGACTIVATE, PGDEACTIVATE,
> >  		PGFAULT, PGMAJFAULT,
> > +		PGLAZYFREED,
> >  		FOR_ALL_ZONES(PGREFILL),
> >  		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
> >  		FOR_ALL_ZONES(PGSTEAL_DIRECT),
> > diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> > index ddc3b36f1046..7a94102b7a02 100644
> > --- a/include/uapi/asm-generic/mman-common.h
> > +++ b/include/uapi/asm-generic/mman-common.h
> > @@ -34,6 +34,7 @@
> >  #define MADV_SEQUENTIAL	2		/* expect sequential page references */
> >  #define MADV_WILLNEED	3		/* will need these pages */
> >  #define MADV_DONTNEED	4		/* don't need these pages */
> > +#define MADV_FREE	5		/* free pages only if memory pressure */
> >  
> >  /* common parameters: try to keep these consistent across architectures */
> >  #define MADV_REMOVE	9		/* remove these pages & resources */
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 0938b30da4ab..55b42e5e32a3 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -19,6 +19,14 @@
> >  #include <linux/blkdev.h>
> >  #include <linux/swap.h>
> >  #include <linux/swapops.h>
> > +#include <linux/mmu_notifier.h>
> > +
> > +#include <asm/tlb.h>
> > +
> > +struct madvise_free_private {
> > +	struct vm_area_struct *vma;
> > +	struct mmu_gather *tlb;
> > +};
> >  
> >  /*
> >   * Any behaviour which results in changes to the vma->vm_flags needs to
> > @@ -31,6 +39,7 @@ static int madvise_need_mmap_write(int behavior)
> >  	case MADV_REMOVE:
> >  	case MADV_WILLNEED:
> >  	case MADV_DONTNEED:
> > +	case MADV_FREE:
> >  		return 0;
> >  	default:
> >  		/* be safe, default to 1. list exceptions explicitly */
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
> > +		if (!pte_present(ptent))
> > +			continue;
> > +
> > +		page = vm_normal_page(vma, addr, ptent);
> > +		if (!page)
> > +			continue;
> > +
> > +		if (PageSwapCache(page)) {
> > +			if (trylock_page(page)) {
> > +				if (try_to_free_swap(page))
> > +					ClearPageDirty(page);
> > +				unlock_page(page);
> 
> 'continue' for !try_to_free_swap(page) case?

Good catch.

> 
> > +			} else
> > +				continue;
> > +		}
> > +
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
> 
> THP uses VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE to filter out
> 'special' VMAs. Looks reasonable here too.
> 
> Otherwise:
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks, Kirill!

> 
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
