Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id ACB646B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 20:05:40 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so1789710pbc.23
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 17:05:40 -0700 (PDT)
Date: Thu, 26 Sep 2013 20:04:57 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1380240297-ia3atfjx-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130926154224.D2CFFE0090@blue.fi.intel.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130919171727.GC6802@sgi.com>
 <20130920123137.BE2F7E0090@blue.fi.intel.com>
 <20130924164443.GB2940@sgi.com>
 <20130926105052.0205AE0090@blue.fi.intel.com>
 <20130926154224.D2CFFE0090@blue.fi.intel.com>
Subject: Re: [PATCHv2 0/9] split page table lock for PMD tables
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 26, 2013 at 06:42:24PM +0300, Kirill A. Shutemov wrote:
> Kirill A. Shutemov wrote:
> > Alex Thorlton wrote:
> > > > THP off:
> > > > --------
> > ...
> > > >       36.540185552 seconds time elapsed                                          ( +- 18.36% )
> > > 
> > > I'm assuming this was THP off, no patchset, correct?
> > 
> > Yes. But THP off patched is *very* close to this, so I didn't post it separately.
> > 
> > > Here are my results from this test on 3.12-rc1:
> > ...
> > >     1138.759708820 seconds time elapsed                                          ( +-  0.47% )
> > > 
> > > And the same test on 3.12-rc1 with your patchset:
> > > 
> > >  Performance counter stats for './runt -t -c 512 -b 512m' (5 runs):
> > ...
> > >     1115.214191126 seconds time elapsed                                          ( +-  0.18% )
> > > 
> > > Looks like we're getting a mild performance increase here, but we still
> > > have a problem.
> > 
> > Let me guess: you have HUGETLBFS enabled in your config, right? ;)
> > 
> > HUGETLBFS hasn't converted to new locking and we disable split pmd lock if
> > HUGETLBFS is enabled.
> > 
> > I'm going to convert HUGETLBFS too, but it might take some time.
> 
> Okay, here is a bit reworked patch from Naoya Horiguchi.
> It might need more cleanup.
> 
> Please, test and review.
> 
> From 47e400fc308e0054c2cadf7df48f632555c83572 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 26 Sep 2013 17:51:33 +0300
> Subject: [PATCH] mm/hugetlb: convert hugetlbfs to use split pmd lock
> 
> Hugetlb supports multiple page sizes. We use split lock only for PMD
> level, but not for PUD.

I like this simple approach, because I don't think the benefit of doing
split ptl for PUD is large enough comparing with the cost of adding spinlock
initialization on every pud. Maybe we might as well consider this when
pud hugepage will be widely used.

> I've run workload from Alex Thorlton[1], slightly modified to use
> mmap(MAP_HUGETLB) for memory allocation.
> 
> hugetlbfs, v3.12-rc2:
> ---------------------
> 
>  Performance counter stats for './thp_memscale_hugetlbfs -c 80 -b 512M' (5 runs):
> 
>     2588052.787264 task-clock                #   54.400 CPUs utilized            ( +-  3.69% )
>            246,831 context-switches          #    0.095 K/sec                    ( +-  4.15% )
>                138 cpu-migrations            #    0.000 K/sec                    ( +-  5.30% )
>             21,027 page-faults               #    0.008 K/sec                    ( +-  0.01% )
>  6,166,666,307,263 cycles                    #    2.383 GHz                      ( +-  3.68% ) [83.33%]
>  6,086,008,929,407 stalled-cycles-frontend   #   98.69% frontend cycles idle     ( +-  3.77% ) [83.33%]
>  5,087,874,435,481 stalled-cycles-backend    #   82.51% backend  cycles idle     ( +-  4.41% ) [66.67%]
>    133,782,831,249 instructions              #    0.02  insns per cycle
>                                              #   45.49  stalled cycles per insn  ( +-  4.30% ) [83.34%]
>     34,026,870,541 branches                  #   13.148 M/sec                    ( +-  4.24% ) [83.34%]
>         68,670,942 branch-misses             #    0.20% of all branches          ( +-  3.26% ) [83.33%]
> 
>       47.574936948 seconds time elapsed                                          ( +-  2.09% )
> 
> hugetlbfs, patched:
> -------------------
> 
>  Performance counter stats for './thp_memscale_hugetlbfs -c 80 -b 512M' (5 runs):
> 
>      395353.076837 task-clock                #   20.329 CPUs utilized            ( +-  8.16% )
>             55,730 context-switches          #    0.141 K/sec                    ( +-  5.31% )
>                138 cpu-migrations            #    0.000 K/sec                    ( +-  4.24% )
>             21,027 page-faults               #    0.053 K/sec                    ( +-  0.00% )
>    930,219,717,244 cycles                    #    2.353 GHz                      ( +-  8.21% ) [83.32%]
>    914,295,694,103 stalled-cycles-frontend   #   98.29% frontend cycles idle     ( +-  8.35% ) [83.33%]
>    704,137,950,187 stalled-cycles-backend    #   75.70% backend  cycles idle     ( +-  9.16% ) [66.69%]
>     30,541,538,385 instructions              #    0.03  insns per cycle
>                                              #   29.94  stalled cycles per insn  ( +-  3.98% ) [83.35%]
>      8,415,376,631 branches                  #   21.286 M/sec                    ( +-  3.61% ) [83.36%]
>         32,645,478 branch-misses             #    0.39% of all branches          ( +-  3.41% ) [83.32%]
> 
>       19.447481153 seconds time elapsed                                          ( +-  2.00% )
> 
> Split lock helps, but hugetlbs is still significantly slower the THP
> (8.4 seconds).

The difference is interesting, but it can be the different problem
from our current problem. Even in vanilla kernel, hugetlbfs looks slower.

> [1] ftp://shell.sgi.com/collect/memscale/thp_memscale.tar.gz
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/proc/meminfo.c        |   2 +-
>  include/linux/hugetlb.h  |  19 +++++++++
>  include/linux/mm_types.h |   4 +-
>  include/linux/swapops.h  |   9 ++--
>  mm/hugetlb.c             | 108 ++++++++++++++++++++++++++++-------------------
>  mm/mempolicy.c           |   5 ++-
>  mm/migrate.c             |   7 +--
>  mm/rmap.c                |   2 +-
>  8 files changed, 100 insertions(+), 56 deletions(-)
> 
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 59d85d6088..6d061f5359 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -1,8 +1,8 @@
>  #include <linux/fs.h>
> -#include <linux/hugetlb.h>
>  #include <linux/init.h>
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
> +#include <linux/hugetlb.h>
>  #include <linux/mman.h>
>  #include <linux/mmzone.h>
>  #include <linux/proc_fs.h>
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 0393270466..4a4a73b1ec 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -401,6 +401,7 @@ struct hstate {};
>  #define hstate_sizelog(s) NULL
>  #define hstate_vma(v) NULL
>  #define hstate_inode(i) NULL
> +#define page_hstate(page) NULL
>  #define huge_page_size(h) PAGE_SIZE
>  #define huge_page_mask(h) PAGE_MASK
>  #define vma_kernel_pagesize(v) PAGE_SIZE
> @@ -423,4 +424,22 @@ static inline pgoff_t basepage_index(struct page *page)
>  #define hugepage_migration_support(h)	0
>  #endif	/* CONFIG_HUGETLB_PAGE */
>  
> +static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
> +               struct mm_struct *mm, pte_t *pte)
> +{
> +       if (huge_page_size(h) == PMD_SIZE)
> +               return pmd_lockptr(mm, (pmd_t *) pte);
> +       VM_BUG_ON(huge_page_size(h) == PAGE_SIZE);
> +       return &mm->page_table_lock;
> +}
> +
> +static inline spinlock_t *huge_pte_lock(struct hstate *h,
> +               struct mm_struct *mm, pte_t *pte)
> +{
> +       spinlock_t *ptl;
> +       ptl = huge_pte_lockptr(h, mm, pte);
> +       spin_lock(ptl);
> +       return ptl;
> +}
> +
>  #endif /* _LINUX_HUGETLB_H */
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 8c2a3c3e28..90cc93b2cc 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -24,10 +24,8 @@
>  struct address_space;
>  
>  #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
> -/* hugetlb hasn't converted to split locking yet */
>  #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
> -		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK) && \
> -		!IS_ENABLED(CONFIG_HUGETLB_PAGE))
> +		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
>  
>  /*
>   * Each physical page in the system has a struct page associated with
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 8d4fa82bfb..ad9f4b2964 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -102,6 +102,8 @@ static inline void *swp_to_radix_entry(swp_entry_t entry)
>  	return (void *)(value | RADIX_TREE_EXCEPTIONAL_ENTRY);
>  }
>  
> +struct hstate;
> +
>  #ifdef CONFIG_MIGRATION
>  static inline swp_entry_t make_migration_entry(struct page *page, int write)
>  {

We can avoid this workaround by passing vma to migration_entry_wait_huge(),
and getting hstate inside that function.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
