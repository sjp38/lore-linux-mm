Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id D92886B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 02:08:38 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id x12so4870683wgg.26
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 23:08:38 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id a9si22485909wjy.88.2014.09.15.23.08.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 23:08:36 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id k48so5058564wev.27
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 23:08:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1409556048-5045-2-git-send-email-minchan@kernel.org>
References: <1409556048-5045-1-git-send-email-minchan@kernel.org> <1409556048-5045-2-git-send-email-minchan@kernel.org>
From: SeongJae Park <sj38.park@gmail.com>
Date: Tue, 16 Sep 2014 15:08:06 +0900
Message-ID: <CAEjAshqHry=Fj0YSZmG-F6-M160JC-BqE+QhssWON+kknNNmNQ@mail.gmail.com>
Subject: Re: [PATCH v16 1/7] mm: support madvise(MADV_FREE)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Minchan,

On Mon, Sep 1, 2014 at 4:20 PM, Minchan Kim <minchan@kernel.org> wrote:
> Linux doesn't have an ability to free pages lazy while other OS
> already have been supported that named by madvise(MADV_FREE).
>
> The gain is clear that kernel can discard freed pages rather than
> swapping out or OOM if memory pressure happens.
>
> Without memory pressure, freed pages would be reused by userspace
> without another additional overhead(ex, page fault + allocation
> + zeroing).
>
> How to work is following as.
>
> When madvise syscall is called, VM clears dirty bit of ptes of
> the range. If memory pressure happens, VM checks dirty bit of
> page table and if it found still "clean", it means it's a
> "lazyfree pages" so VM could discard the page instead of swapping out.
> Once there was store operation for the page before VM peek a page
> to reclaim, dirty bit is set so VM can swap out the page instead of
> discarding.
>
> Firstly, heavy users would be general allocators(ex, jemalloc,
> tcmalloc and hope glibc supports it) and jemalloc/tcmalloc already
> have supported the feature for other OS(ex, FreeBSD)
>
> barrios@blaptop:~/benchmark/ebizzy$ lscpu
> Architecture:          x86_64
> CPU op-mode(s):        32-bit, 64-bit
> Byte Order:            Little Endian
> CPU(s):                4
> On-line CPU(s) list:   0-3
> Thread(s) per core:    2
> Core(s) per socket:    2
> Socket(s):             1
> NUMA node(s):          1
> Vendor ID:             GenuineIntel
> CPU family:            6
> Model:                 42
> Stepping:              7
> CPU MHz:               2801.000
> BogoMIPS:              5581.64
> Virtualization:        VT-x
> L1d cache:             32K
> L1i cache:             32K
> L2 cache:              256K
> L3 cache:              4096K
> NUMA node0 CPU(s):     0-3
>
> ebizzy benchmark(./ebizzy -S 10 -n 512)
>
>  vanilla-jemalloc               MADV_free-jemalloc
>
> 1 thread
> records:  10              records:  10
> avg:      7682.10         avg:      15306.10
> std:      62.35(0.81%)    std:      347.99(2.27%)
> max:      7770.00         max:      15622.00
> min:      7598.00         min:      14772.00
>
> 2 thread
> records:  10              records:  10
> avg:      12747.50        avg:      24171.00
> std:      792.06(6.21%)   std:      895.18(3.70%)
> max:      13337.00        max:      26023.00
> min:      10535.00        min:      23152.00
>
> 4 thread
> records:  10              records:  10
> avg:      16474.60        avg:      33717.90
> std:      1496.45(9.08%)  std:      2008.97(5.96%)
> max:      17877.00        max:      35958.00
> min:      12224.00        min:      29565.00
>
> 8 thread
> records:  10              records:  10
> avg:      16778.50        avg:      33308.10
> std:      825.53(4.92%)   std:      1668.30(5.01%)
> max:      17543.00        max:      36010.00
> min:      14576.00        min:      29577.00
>
> 16 thread
> records:  10              records:  10
> avg:      20614.40        avg:      35516.30
> std:      602.95(2.92%)   std:      1283.65(3.61%)
> max:      21753.00        max:      37178.00
> min:      19605.00        min:      33217.00
>
> 32 thread
> records:  10              records:  10
> avg:      22771.70        avg:      36018.50
> std:      598.94(2.63%)   std:      1046.76(2.91%)
> max:      24035.00        max:      37266.00
> min:      22108.00        min:      34149.00
>
> In summary, MADV_FREE is about 2 time faster than MADV_DONTNEED.
>
> Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> Cc: Linux API <linux-api@vger.kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Jason Evans <je@fb.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/rmap.h                   |   9 ++-
>  include/linux/vm_event_item.h          |   1 +
>  include/uapi/asm-generic/mman-common.h |   1 +
>  mm/madvise.c                           | 140 +++++++++++++++++++++++++++++++++
>  mm/rmap.c                              |  42 +++++++++-
>  mm/vmscan.c                            |  40 ++++++++--
>  mm/vmstat.c                            |   1 +
>  7 files changed, 222 insertions(+), 12 deletions(-)
>
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index c0c2bce6b0b7..14ec4ece14a5 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -75,6 +75,7 @@ enum ttu_flags {
>         TTU_UNMAP = 1,                  /* unmap mode */
>         TTU_MIGRATION = 2,              /* migration mode */
>         TTU_MUNLOCK = 4,                /* munlock mode */
> +       TTU_FREE = 8,                   /* free mode */
>
>         TTU_IGNORE_MLOCK = (1 << 8),    /* ignore mlock */
>         TTU_IGNORE_ACCESS = (1 << 9),   /* don't age */
> @@ -181,7 +182,8 @@ static inline void page_dup_rmap(struct page *page)
>   * Called from mm/vmscan.c to handle paging out
>   */
>  int page_referenced(struct page *, int is_locked,
> -                       struct mem_cgroup *memcg, unsigned long *vm_flags);
> +                       struct mem_cgroup *memcg, unsigned long *vm_flags,
> +                       int *is_dirty);

Name of the last parameter is `is_dirty` here and `is_pte_dirty` in
definition. Wouldn't it be better to use same name?

I think this is just a really trivial question but, couldn't ignored.

Thanks,
SeongJae Park

>
>  #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
>
> @@ -260,9 +262,12 @@ int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
>
>  static inline int page_referenced(struct page *page, int is_locked,
>                                   struct mem_cgroup *memcg,
> -                                 unsigned long *vm_flags)
> +                                 unsigned long *vm_flags,
> +                                 int *is_pte_dirty)
>  {
>         *vm_flags = 0;
> +       if (is_pte_dirty)
> +               *is_pte_dirty = 0;
>         return 0;
>  }
>
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index ced92345c963..e2d3fb1e9814 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -25,6 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>                 FOR_ALL_ZONES(PGALLOC),
>                 PGFREE, PGACTIVATE, PGDEACTIVATE,
>                 PGFAULT, PGMAJFAULT,
> +               PGLAZYFREED,
>                 FOR_ALL_ZONES(PGREFILL),
>                 FOR_ALL_ZONES(PGSTEAL_KSWAPD),
>                 FOR_ALL_ZONES(PGSTEAL_DIRECT),
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index ddc3b36f1046..7a94102b7a02 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -34,6 +34,7 @@
>  #define MADV_SEQUENTIAL        2               /* expect sequential page references */
>  #define MADV_WILLNEED  3               /* will need these pages */
>  #define MADV_DONTNEED  4               /* don't need these pages */
> +#define MADV_FREE      5               /* free pages only if memory pressure */
>
>  /* common parameters: try to keep these consistent across architectures */
>  #define MADV_REMOVE    9               /* remove these pages & resources */
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 0938b30da4ab..a21584235bb6 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -19,6 +19,14 @@
>  #include <linux/blkdev.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
> +#include <linux/mmu_notifier.h>
> +
> +#include <asm/tlb.h>
> +
> +struct madvise_free_private {
> +       struct vm_area_struct *vma;
> +       struct mmu_gather *tlb;
> +};
>
>  /*
>   * Any behaviour which results in changes to the vma->vm_flags needs to
> @@ -31,6 +39,7 @@ static int madvise_need_mmap_write(int behavior)
>         case MADV_REMOVE:
>         case MADV_WILLNEED:
>         case MADV_DONTNEED:
> +       case MADV_FREE:
>                 return 0;
>         default:
>                 /* be safe, default to 1. list exceptions explicitly */
> @@ -251,6 +260,128 @@ static long madvise_willneed(struct vm_area_struct *vma,
>         return 0;
>  }
>
> +static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> +                               unsigned long end, struct mm_walk *walk)
> +
> +{
> +       struct madvise_free_private *fp = walk->private;
> +       struct mmu_gather *tlb = fp->tlb;
> +       struct mm_struct *mm = tlb->mm;
> +       struct vm_area_struct *vma = fp->vma;
> +       spinlock_t *ptl;
> +       pte_t *pte, ptent;
> +       struct page *page;
> +
> +       split_huge_page_pmd(vma, addr, pmd);
> +       if (pmd_trans_unstable(pmd))
> +               return 0;
> +
> +       pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +       arch_enter_lazy_mmu_mode();
> +       for (; addr != end; pte++, addr += PAGE_SIZE) {
> +               ptent = *pte;
> +
> +               if (!pte_present(ptent))
> +                       continue;
> +
> +               page = vm_normal_page(vma, addr, ptent);
> +               if (!page)
> +                       continue;
> +
> +               if (PageSwapCache(page)) {
> +                       if (!trylock_page(page))
> +                               continue;
> +
> +                       if (!try_to_free_swap(page)) {
> +                               unlock_page(page);
> +                               continue;
> +                       }
> +
> +                       ClearPageDirty(page);
> +                       unlock_page(page);
> +               }
> +
> +               /*
> +                * Some of architecture(ex, PPC) don't update TLB
> +                * with set_pte_at and tlb_remove_tlb_entry so for
> +                * the portability, remap the pte with old|clean
> +                * after pte clearing.
> +                */
> +               ptent = ptep_get_and_clear_full(mm, addr, pte,
> +                                               tlb->fullmm);
> +               ptent = pte_mkold(ptent);
> +               ptent = pte_mkclean(ptent);
> +               set_pte_at(mm, addr, pte, ptent);
> +               tlb_remove_tlb_entry(tlb, pte, addr);
> +       }
> +       arch_leave_lazy_mmu_mode();
> +       pte_unmap_unlock(pte - 1, ptl);
> +       cond_resched();
> +       return 0;
> +}
> +
> +static void madvise_free_page_range(struct mmu_gather *tlb,
> +                            struct vm_area_struct *vma,
> +                            unsigned long addr, unsigned long end)
> +{
> +       struct madvise_free_private fp = {
> +               .vma = vma,
> +               .tlb = tlb,
> +       };
> +
> +       struct mm_walk free_walk = {
> +               .pmd_entry = madvise_free_pte_range,
> +               .mm = vma->vm_mm,
> +               .private = &fp,
> +       };
> +
> +       BUG_ON(addr >= end);
> +       tlb_start_vma(tlb, vma);
> +       walk_page_range(addr, end, &free_walk);
> +       tlb_end_vma(tlb, vma);
> +}
> +
> +static int madvise_free_single_vma(struct vm_area_struct *vma,
> +                       unsigned long start_addr, unsigned long end_addr)
> +{
> +       unsigned long start, end;
> +       struct mm_struct *mm = vma->vm_mm;
> +       struct mmu_gather tlb;
> +
> +       if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> +               return -EINVAL;
> +
> +       /* MADV_FREE works for only anon vma at the moment */
> +       if (vma->vm_file)
> +               return -EINVAL;
> +
> +       start = max(vma->vm_start, start_addr);
> +       if (start >= vma->vm_end)
> +               return -EINVAL;
> +       end = min(vma->vm_end, end_addr);
> +       if (end <= vma->vm_start)
> +               return -EINVAL;
> +
> +       lru_add_drain();
> +       tlb_gather_mmu(&tlb, mm, start, end);
> +       update_hiwater_rss(mm);
> +
> +       mmu_notifier_invalidate_range_start(mm, start, end);
> +       madvise_free_page_range(&tlb, vma, start, end);
> +       mmu_notifier_invalidate_range_end(mm, start, end);
> +       tlb_finish_mmu(&tlb, start, end);
> +
> +       return 0;
> +}
> +
> +static long madvise_free(struct vm_area_struct *vma,
> +                            struct vm_area_struct **prev,
> +                            unsigned long start, unsigned long end)
> +{
> +       *prev = vma;
> +       return madvise_free_single_vma(vma, start, end);
> +}
> +
>  /*
>   * Application no longer needs these pages.  If the pages are dirty,
>   * it's OK to just throw them away.  The app will be more careful about
> @@ -381,6 +512,14 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
>                 return madvise_remove(vma, prev, start, end);
>         case MADV_WILLNEED:
>                 return madvise_willneed(vma, prev, start, end);
> +       case MADV_FREE:
> +               /*
> +                * XXX: In this implementation, MADV_FREE works like
> +                * MADV_DONTNEED on swapless system or full swap.
> +                */
> +               if (get_nr_swap_pages() > 0)
> +                       return madvise_free(vma, prev, start, end);
> +               /* passthrough */
>         case MADV_DONTNEED:
>                 return madvise_dontneed(vma, prev, start, end);
>         default:
> @@ -400,6 +539,7 @@ madvise_behavior_valid(int behavior)
>         case MADV_REMOVE:
>         case MADV_WILLNEED:
>         case MADV_DONTNEED:
> +       case MADV_FREE:
>  #ifdef CONFIG_KSM
>         case MADV_MERGEABLE:
>         case MADV_UNMERGEABLE:
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 5fbd0fe8f933..93149c82a5a4 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -663,6 +663,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
>  }
>
>  struct page_referenced_arg {
> +       int dirtied;
>         int mapcount;
>         int referenced;
>         unsigned long vm_flags;
> @@ -677,6 +678,7 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>         struct mm_struct *mm = vma->vm_mm;
>         spinlock_t *ptl;
>         int referenced = 0;
> +       int dirty = 0;
>         struct page_referenced_arg *pra = arg;
>
>         if (unlikely(PageTransHuge(page))) {
> @@ -700,6 +702,11 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>                 /* go ahead even if the pmd is pmd_trans_splitting() */
>                 if (pmdp_clear_flush_young_notify(vma, address, pmd))
>                         referenced++;
> +
> +               /*
> +                * In this implmentation, MADV_FREE doesn't support THP free
> +                */
> +               dirty++;
>                 spin_unlock(ptl);
>         } else {
>                 pte_t *pte;
> @@ -729,6 +736,10 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>                         if (likely(!(vma->vm_flags & VM_SEQ_READ)))
>                                 referenced++;
>                 }
> +
> +               if (pte_dirty(*pte))
> +                       dirty++;
> +
>                 pte_unmap_unlock(pte, ptl);
>         }
>
> @@ -737,6 +748,9 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>                 pra->vm_flags |= vma->vm_flags;
>         }
>
> +       if (dirty)
> +               pra->dirtied++;
> +
>         pra->mapcount--;
>         if (!pra->mapcount)
>                 return SWAP_SUCCESS; /* To break the loop */
> @@ -761,6 +775,7 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
>   * @is_locked: caller holds lock on the page
>   * @memcg: target memory cgroup
>   * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
> + * @is_pte_dirty: ptes which have marked dirty bit - used for lazyfree page
>   *
>   * Quick test_and_clear_referenced for all mappings to a page,
>   * returns the number of ptes which referenced the page.
> @@ -768,7 +783,8 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
>  int page_referenced(struct page *page,
>                     int is_locked,
>                     struct mem_cgroup *memcg,
> -                   unsigned long *vm_flags)
> +                   unsigned long *vm_flags,
> +                   int *is_pte_dirty)
>  {
>         int ret;
>         int we_locked = 0;
> @@ -783,6 +799,9 @@ int page_referenced(struct page *page,
>         };
>
>         *vm_flags = 0;
> +       if (is_pte_dirty)
> +               *is_pte_dirty = 0;
> +
>         if (!page_mapped(page))
>                 return 0;
>
> @@ -810,6 +829,9 @@ int page_referenced(struct page *page,
>         if (we_locked)
>                 unlock_page(page);
>
> +       if (is_pte_dirty)
> +               *is_pte_dirty = pra.dirtied;
> +
>         return pra.referenced;
>  }
>
> @@ -1128,6 +1150,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>         spinlock_t *ptl;
>         int ret = SWAP_AGAIN;
>         enum ttu_flags flags = (enum ttu_flags)arg;
> +       int dirty = 0;
>
>         pte = page_check_address(page, mm, address, &ptl, 0);
>         if (!pte)
> @@ -1157,7 +1180,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>         pteval = ptep_clear_flush(vma, address, pte);
>
>         /* Move the dirty bit to the physical page now the pte is gone. */
> -       if (pte_dirty(pteval))
> +       dirty = pte_dirty(pteval);
> +       if (dirty)
>                 set_page_dirty(page);
>
>         /* Update high watermark before we lower rss */
> @@ -1186,6 +1210,19 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>                 swp_entry_t entry = { .val = page_private(page) };
>                 pte_t swp_pte;
>
> +               if (flags & TTU_FREE) {
> +                       VM_BUG_ON_PAGE(PageSwapCache(page), page);
> +                       if (!dirty && !PageDirty(page)) {
> +                               /* It's a freeable page by MADV_FREE */
> +                               dec_mm_counter(mm, MM_ANONPAGES);
> +                               goto discard;
> +                       } else {
> +                               set_pte_at(mm, address, pte, pteval);
> +                               ret = SWAP_FAIL;
> +                               goto out_unmap;
> +                       }
> +               }
> +
>                 if (PageSwapCache(page)) {
>                         /*
>                          * Store the swap location in the pte.
> @@ -1227,6 +1264,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>         } else
>                 dec_mm_counter(mm, MM_FILEPAGES);
>
> +discard:
>         page_remove_rmap(page);
>         page_cache_release(page);
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6484195c6859..e3e026c6c7b1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -713,13 +713,17 @@ enum page_references {
>  };
>
>  static enum page_references page_check_references(struct page *page,
> -                                                 struct scan_control *sc)
> +                                                 struct scan_control *sc,
> +                                                 bool *freeable)
>  {
>         int referenced_ptes, referenced_page;
>         unsigned long vm_flags;
> +       int pte_dirty;
> +
> +       VM_BUG_ON_PAGE(!PageLocked(page), page);
>
>         referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
> -                                         &vm_flags);
> +                                         &vm_flags, &pte_dirty);
>         referenced_page = TestClearPageReferenced(page);
>
>         /*
> @@ -760,6 +764,10 @@ static enum page_references page_check_references(struct page *page,
>                 return PAGEREF_KEEP;
>         }
>
> +       if (PageAnon(page) && !pte_dirty && !PageSwapCache(page) &&
> +                       !PageDirty(page))
> +               *freeable = true;
> +
>         /* Reclaim if clean, defer dirty pages to writeback */
>         if (referenced_page && !PageSwapBacked(page))
>                 return PAGEREF_RECLAIM_CLEAN;
> @@ -828,6 +836,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                 int may_enter_fs;
>                 enum page_references references = PAGEREF_RECLAIM_CLEAN;
>                 bool dirty, writeback;
> +               bool freeable = false;
>
>                 cond_resched();
>
> @@ -950,7 +959,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                 }
>
>                 if (!force_reclaim)
> -                       references = page_check_references(page, sc);
> +                       references = page_check_references(page, sc,
> +                                                       &freeable);
>
>                 switch (references) {
>                 case PAGEREF_ACTIVATE:
> @@ -966,7 +976,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                  * Anonymous process memory has backing store?
>                  * Try to allocate it some swap space here.
>                  */
> -               if (PageAnon(page) && !PageSwapCache(page)) {
> +               if (PageAnon(page) && !PageSwapCache(page) && !freeable) {
>                         if (!(sc->gfp_mask & __GFP_IO))
>                                 goto keep_locked;
>                         if (!add_to_swap(page, page_list))
> @@ -981,8 +991,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                  * The page is mapped into the page tables of one or more
>                  * processes. Try to unmap it here.
>                  */
> -               if (page_mapped(page) && mapping) {
> -                       switch (try_to_unmap(page, ttu_flags)) {
> +               if (page_mapped(page) && (mapping || freeable)) {
> +                       switch (try_to_unmap(page,
> +                               freeable ? TTU_FREE : ttu_flags)) {
>                         case SWAP_FAIL:
>                                 goto activate_locked;
>                         case SWAP_AGAIN:
> @@ -990,7 +1001,20 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                         case SWAP_MLOCK:
>                                 goto cull_mlocked;
>                         case SWAP_SUCCESS:
> -                               ; /* try to free the page below */
> +                               /* try to free the page below */
> +                               if (!freeable)
> +                                       break;
> +                               /*
> +                                * Freeable anon page doesn't have mapping
> +                                * due to skipping of swapcache so we free
> +                                * page in here rather than __remove_mapping.
> +                                */
> +                               VM_BUG_ON_PAGE(PageSwapCache(page), page);
> +                               if (!page_freeze_refs(page, 1))
> +                                       goto keep_locked;
> +                               __clear_page_locked(page);
> +                               count_vm_event(PGLAZYFREED);
> +                               goto free_it;
>                         }
>                 }
>
> @@ -1730,7 +1754,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>                 }
>
>                 if (page_referenced(page, 0, sc->target_mem_cgroup,
> -                                   &vm_flags)) {
> +                                   &vm_flags, NULL)) {
>                         nr_rotated += hpage_nr_pages(page);
>                         /*
>                          * Identify referenced, file-backed active pages and
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 87273cddeca0..0b8fc1ac591a 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -817,6 +817,7 @@ const char * const vmstat_text[] = {
>
>         "pgfault",
>         "pgmajfault",
> +       "pglazyfreed",
>
>         TEXTS_FOR_ZONES("pgrefill")
>         TEXTS_FOR_ZONES("pgsteal_kswapd")
> --
> 2.0.0
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
