Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA1E6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:01:15 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so67644150igc.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:01:15 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id m5si3960463igx.2.2015.07.08.16.01.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 16:01:14 -0700 (PDT)
Received: by iecvh10 with SMTP id vh10so166011989iec.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:01:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50b7cd0f35f651481ce32414fab5210de5dc1714.1434102076.git.vdavydov@parallels.com>
References: <cover.1434102076.git.vdavydov@parallels.com>
	<50b7cd0f35f651481ce32414fab5210de5dc1714.1434102076.git.vdavydov@parallels.com>
Date: Wed, 8 Jul 2015 16:01:13 -0700
Message-ID: <CAJu=L5-fwHMEKmL1Sp7owXyBa0GCrGR=TdKZbh15CJA3WrcwqA@mail.gmail.com>
Subject: Re: [PATCH -mm v6 5/6] proc: add kpageidle file
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jun 12, 2015 at 2:52 AM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> Knowing the portion of memory that is not used by a certain application
> or memory cgroup (idle memory) can be useful for partitioning the system
> efficiently, e.g. by setting memory cgroup limits appropriately.
> Currently, the only means to estimate the amount of idle memory provided
> by the kernel is /proc/PID/{clear_refs,smaps}: the user can clear the
> access bit for all pages mapped to a particular process by writing 1 to
> clear_refs, wait for some time, and then count smaps:Referenced.
> However, this method has two serious shortcomings:
>
>  - it does not count unmapped file pages
>  - it affects the reclaimer logic
>
> To overcome these drawbacks, this patch introduces two new page flags,
> Idle and Young, and a new proc file, /proc/kpageidle. A page's Idle flag
> can only be set from userspace by setting bit in /proc/kpageidle at the
> offset corresponding to the page, and it is cleared whenever the page is
> accessed either through page tables (it is cleared in page_referenced()
> in this case) or using the read(2) system call (mark_page_accessed()).
> Thus by setting the Idle flag for pages of a particular workload, which
> can be found e.g. by reading /proc/PID/pagemap, waiting for some time to
> let the workload access its working set, and then reading the kpageidle
> file, one can estimate the amount of pages that are not used by the
> workload.
>
> The Young page flag is used to avoid interference with the memory
> reclaimer. A page's Young flag is set whenever the Access bit of a page
> table entry pointing to the page is cleared by writing to kpageidle. If
> page_referenced() is called on a Young page, it will add 1 to its return
> value, therefore concealing the fact that the Access bit was cleared.
>
> Note, since there is no room for extra page flags on 32 bit, this
> feature uses extended page flags when compiled on 32 bit.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Vladimir,
I've reviewed the other five patches on your series and they're
eminently reasonable, so I'll focus my comments here, inline below.
Comments apply to both this specific patch and more broadly to the
approach you present. If I think of more I will post again. Hope that
helps!

Andres

> ---
>  Documentation/vm/pagemap.txt |  12 ++-
>  fs/proc/page.c               | 178 +++++++++++++++++++++++++++++++++++++++++++
>  fs/proc/task_mmu.c           |   4 +-
>  include/linux/mm.h           |  88 +++++++++++++++++++++
>  include/linux/page-flags.h   |   9 +++
>  include/linux/page_ext.h     |   4 +
>  mm/Kconfig                   |  12 +++
>  mm/debug.c                   |   4 +
>  mm/page_ext.c                |   3 +
>  mm/rmap.c                    |   8 ++
>  mm/swap.c                    |   2 +
>  11 files changed, 322 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index a9b7afc8fbc6..c9266340852c 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
>  userspace programs to examine the page tables and related information by
>  reading files in /proc.
>
> -There are four components to pagemap:
> +There are five components to pagemap:
>
>   * /proc/pid/pagemap.  This file lets a userspace process find out which
>     physical frame each virtual page is mapped to.  It contains one 64-bit
> @@ -69,6 +69,16 @@ There are four components to pagemap:
>     memory cgroup each page is charged to, indexed by PFN. Only available when
>     CONFIG_MEMCG is set.
>
> + * /proc/kpageidle.  This file implements a bitmap where each bit corresponds
> +   to a page, indexed by PFN. When the bit is set, the corresponding page is
> +   idle. A page is considered idle if it has not been accessed since it was
> +   marked idle. To mark a page idle one should set the bit corresponding to the
> +   page by writing to the file. A value written to the file is OR-ed with the
> +   current bitmap value. Only user memory pages can be marked idle, for other
> +   page types input is silently ignored. Writing to this file beyond max PFN
> +   results in the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is
> +   set.
> +
>  Short descriptions to the page flags:
>
>   0. LOCKED
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 70d23245dd43..1e342270b9c0 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -16,6 +16,7 @@
>
>  #define KPMSIZE sizeof(u64)
>  #define KPMMASK (KPMSIZE - 1)
> +#define KPMBITS (KPMSIZE * BITS_PER_BYTE)
>
>  /* /proc/kpagecount - an array exposing page counts
>   *
> @@ -275,6 +276,179 @@ static const struct file_operations proc_kpagecgroup_operations = {
>  };
>  #endif /* CONFIG_MEMCG */
>
> +#ifdef CONFIG_IDLE_PAGE_TRACKING
> +/*
> + * Idle page tracking only considers user memory pages, for other types of
> + * pages the idle flag is always unset and an attempt to set it is silently
> + * ignored.
> + *
> + * We treat a page as a user memory page if it is on an LRU list, because it is
> + * always safe to pass such a page to page_referenced(), which is essential for
> + * idle page tracking. With such an indicator of user pages we can skip
> + * isolated pages, but since there are not usually many of them, it will hardly
> + * affect the overall result.
> + *
> + * This function tries to get a user memory page by pfn as described above.
> + */
> +static struct page *kpageidle_get_page(unsigned long pfn)
> +{
> +       struct page *page;
> +       struct zone *zone;
> +
> +       if (!pfn_valid(pfn))
> +               return NULL;
> +
> +       page = pfn_to_page(pfn);
> +       if (!page || !PageLRU(page))

Isolation can race in while you're processing the page, after these
checks. This is ok, but worth a small comment.

> +               return NULL;
> +       if (!get_page_unless_zero(page))
> +               return NULL;
> +
> +       zone = page_zone(page);
> +       spin_lock_irq(&zone->lru_lock);
> +       if (unlikely(!PageLRU(page))) {
> +               put_page(page);
> +               page = NULL;
> +       }
> +       spin_unlock_irq(&zone->lru_lock);
> +       return page;
> +}
> +
> +/*
> + * This function calls page_referenced() to clear the referenced bit for all
> + * mappings to a page. Since the latter also clears the page idle flag if the
> + * page was referenced, it can be used to update the idle flag of a page.
> + */
> +static void kpageidle_clear_pte_refs(struct page *page)
> +{
> +       unsigned long dummy;
> +
> +       if (page_referenced(page, 0, NULL, &dummy, NULL))

Because of pte/pmd_clear_flush_young* called in the guts of
page_referenced_one, an N byte write or read to /proc/kpageidle will
cause N * 64 TLB flushes.

Additionally, because of the _notify connection to mmu notifiers, this
will also cause N * 64 EPT TLB flushes (in the KVM Intel case, similar
for other notifier flavors, you get the point).

The solution is relatively straightforward: augment
page_referenced_one with a mode marker or boolean that determines
whether tlb flushing is required.

For an access pattern tracker such as the one you propose, flushing is
not strictly necessary: the next context switch will take care. Too
bad if you missed a few accesses because the pte/pmd was loaded in the
TLB. Not so easy for MMU notifiers, because each secondary MMU has its
own semantics. You could arguably throw the towel in there, or try to
provide a framework (i.e. propagate the flushing flag) and let each
implementation fill the gaps.

> +               /*
> +                * We cleared the referenced bit in a mapping to this page. To
> +                * avoid interference with the reclaimer, mark it young so that
> +                * the next call to page_referenced() will also return > 0 (see
> +                * page_referenced_one())
> +                */
> +               set_page_young(page);
> +}
> +
> +static ssize_t kpageidle_read(struct file *file, char __user *buf,
> +                             size_t count, loff_t *ppos)
> +{
> +       u64 __user *out = (u64 __user *)buf;
> +       struct page *page;
> +       unsigned long pfn, end_pfn;
> +       ssize_t ret = 0;
> +       u64 idle_bitmap = 0;
> +       int bit;
> +
> +       if (*ppos & KPMMASK || count & KPMMASK)
> +               return -EINVAL;
> +
> +       pfn = *ppos * BITS_PER_BYTE;
> +       if (pfn >= max_pfn)
> +               return 0;
> +
> +       end_pfn = pfn + count * BITS_PER_BYTE;
> +       if (end_pfn > max_pfn)
> +               end_pfn = ALIGN(max_pfn, KPMBITS);
> +
> +       for (; pfn < end_pfn; pfn++) {
> +               bit = pfn % KPMBITS;
> +               page = kpageidle_get_page(pfn);
> +               if (page) {
> +                       if (page_is_idle(page)) {
> +                               /*
> +                                * The page might have been referenced via a
> +                                * pte, in which case it is not idle. Clear
> +                                * refs and recheck.
> +                                */
> +                               kpageidle_clear_pte_refs(page);
> +                               if (page_is_idle(page))
> +                                       idle_bitmap |= 1ULL << bit;
> +                       }
> +                       put_page(page);
> +               }
> +               if (bit == KPMBITS - 1) {
> +                       if (put_user(idle_bitmap, out)) {
> +                               ret = -EFAULT;
> +                               break;
> +                       }
> +                       idle_bitmap = 0;
> +                       out++;
> +               }
> +       }
> +
> +       *ppos += (char __user *)out - buf;
> +       if (!ret)
> +               ret = (char __user *)out - buf;
> +       return ret;
> +}
> +
> +static ssize_t kpageidle_write(struct file *file, const char __user *buf,

Your reasoning for a host wide /proc/kpageidle is well argued, but I'm
still hesitant.

mincore() shows how to (relatively simply) resolve unmapped file pages
to their backing page cache destination. You could recycle that code
and then you'd have per process idle/idling interfaces. With the
advantage of a clear TLB flush demarcation.

> +                              size_t count, loff_t *ppos)
> +{
> +       const u64 __user *in = (const u64 __user *)buf;
> +       struct page *page;
> +       unsigned long pfn, end_pfn;
> +       ssize_t ret = 0;
> +       u64 idle_bitmap = 0;
> +       int bit;
> +
> +       if (*ppos & KPMMASK || count & KPMMASK)
> +               return -EINVAL;
> +
> +       pfn = *ppos * BITS_PER_BYTE;
> +       if (pfn >= max_pfn)
> +               return -ENXIO;
> +
> +       end_pfn = pfn + count * BITS_PER_BYTE;
> +       if (end_pfn > max_pfn)
> +               end_pfn = ALIGN(max_pfn, KPMBITS);
> +
> +       for (; pfn < end_pfn; pfn++) {

Relatively straight forward to teleport forward 512 (or more
correctly: 1 << compound_order(page)) pages for THP pages, once done
with a THP head, and avoid 511 fruitless trips down rmap.c for each
tail.

> +               bit = pfn % KPMBITS;
> +               if (bit == 0) {
> +                       if (get_user(idle_bitmap, in)) {
> +                               ret = -EFAULT;
> +                               break;
> +                       }
> +                       in++;
> +               }
> +               if (idle_bitmap >> bit & 1) {
> +                       page = kpageidle_get_page(pfn);
> +                       if (page) {
> +                               kpageidle_clear_pte_refs(page);
> +                               set_page_idle(page);

In the common case this will make a page both young and idle. This is
fine. We will come back to it below.

> +                               put_page(page);
> +                       }
> +               }
> +       }
> +
> +       *ppos += (const char __user *)in - buf;
> +       if (!ret)
> +               ret = (const char __user *)in - buf;
> +       return ret;
> +}
> +
> +static const struct file_operations proc_kpageidle_operations = {
> +       .llseek = mem_lseek,
> +       .read = kpageidle_read,
> +       .write = kpageidle_write,
> +};
> +
> +#ifndef CONFIG_64BIT
> +static bool need_page_idle(void)
> +{
> +       return true;
> +}
> +struct page_ext_operations page_idle_ops = {
> +       .need = need_page_idle,
> +};
> +#endif
> +#endif /* CONFIG_IDLE_PAGE_TRACKING */
> +
>  static int __init proc_page_init(void)
>  {
>         proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
> @@ -282,6 +456,10 @@ static int __init proc_page_init(void)
>  #ifdef CONFIG_MEMCG
>         proc_create("kpagecgroup", S_IRUSR, NULL, &proc_kpagecgroup_operations);
>  #endif
> +#ifdef CONFIG_IDLE_PAGE_TRACKING
> +       proc_create("kpageidle", S_IRUSR | S_IWUSR, NULL,
> +                   &proc_kpageidle_operations);
> +#endif
>         return 0;
>  }
>  fs_initcall(proc_page_init);
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 58be92e11939..fcec9ccb8f7e 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -458,7 +458,7 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>
>         mss->resident += size;
>         /* Accumulate the size in pages that have been accessed. */
> -       if (young || PageReferenced(page))
> +       if (young || page_is_young(page) || PageReferenced(page))
>                 mss->referenced += size;
>         mapcount = page_mapcount(page);
>         if (mapcount >= 2) {
> @@ -810,6 +810,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>
>                 /* Clear accessed and referenced bits. */
>                 pmdp_test_and_clear_young(vma, addr, pmd);
> +               clear_page_young(page);
>                 ClearPageReferenced(page);
>  out:
>                 spin_unlock(ptl);
> @@ -837,6 +838,7 @@ out:
>
>                 /* Clear accessed and referenced bits. */
>                 ptep_test_and_clear_young(vma, addr, pte);
> +               clear_page_young(page);
>                 ClearPageReferenced(page);
>         }
>         pte_unmap_unlock(pte - 1, ptl);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7f471789781a..4545ac6e27eb 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2205,5 +2205,93 @@ void __init setup_nr_node_ids(void);
>  static inline void setup_nr_node_ids(void) {}
>  #endif
>
> +#ifdef CONFIG_IDLE_PAGE_TRACKING
> +#ifdef CONFIG_64BIT
> +static inline bool page_is_young(struct page *page)
> +{
> +       return PageYoung(page);
> +}
> +
> +static inline void set_page_young(struct page *page)
> +{
> +       SetPageYoung(page);
> +}
> +
> +static inline void clear_page_young(struct page *page)
> +{
> +       ClearPageYoung(page);
> +}

Below I will comment more on the value of test_and_clear_page_young. I
think you should strive to support that, and it's trivial in the
common case of 64 bits (and requires some syntactic sugar and relaxed
guarantees for the page_ext case. Fine)

> +
> +static inline bool page_is_idle(struct page *page)
> +{
> +       return PageIdle(page);
> +}
> +
> +static inline void set_page_idle(struct page *page)
> +{
> +       SetPageIdle(page);
> +}
> +
> +static inline void clear_page_idle(struct page *page)
> +{
> +       ClearPageIdle(page);
> +}
> +#else /* !CONFIG_64BIT */
> +/*
> + * If there is not enough space to store Idle and Young bits in page flags, use
> + * page ext flags instead.
> + */
> +extern struct page_ext_operations page_idle_ops;
> +
> +static inline bool page_is_young(struct page *page)
> +{
> +       return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline void set_page_young(struct page *page)
> +{
> +       set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline void clear_page_young(struct page *page)
> +{
> +       clear_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline bool page_is_idle(struct page *page)
> +{
> +       return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline void set_page_idle(struct page *page)
> +{
> +       set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline void clear_page_idle(struct page *page)
> +{
> +       clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +}
> +#endif /* CONFIG_64BIT */
> +#else /* !CONFIG_IDLE_PAGE_TRACKING */
> +static inline bool page_is_young(struct page *page)
> +{
> +       return false;
> +}
> +
> +static inline void clear_page_young(struct page *page)
> +{
> +}
> +
> +static inline bool page_is_idle(struct page *page)
> +{
> +       return false;
> +}
> +
> +static inline void clear_page_idle(struct page *page)
> +{
> +}
> +#endif /* CONFIG_IDLE_PAGE_TRACKING */
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 91b7f9b2b774..14c5d774ad70 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -109,6 +109,10 @@ enum pageflags {
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>         PG_compound_lock,
>  #endif
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
> +       PG_young,
> +       PG_idle,
> +#endif
>         __NR_PAGEFLAGS,
>
>         /* Filesystems */
> @@ -363,6 +367,11 @@ PAGEFLAG_FALSE(HWPoison)
>  #define __PG_HWPOISON 0
>  #endif
>
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
> +PAGEFLAG(Young, young, PF_ANY)
> +PAGEFLAG(Idle, idle, PF_ANY)
> +#endif
> +
>  /*
>   * On an anonymous page mapped into a user virtual memory area,
>   * page->mapping points to its anon_vma, not to a struct address_space;
> diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
> index c42981cd99aa..17f118a82854 100644
> --- a/include/linux/page_ext.h
> +++ b/include/linux/page_ext.h
> @@ -26,6 +26,10 @@ enum page_ext_flags {
>         PAGE_EXT_DEBUG_POISON,          /* Page is poisoned */
>         PAGE_EXT_DEBUG_GUARD,
>         PAGE_EXT_OWNER,
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
> +       PAGE_EXT_YOUNG,
> +       PAGE_EXT_IDLE,
> +#endif
>  };
>
>  /*
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e79de2bd12cd..db817e2c2ec8 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -654,3 +654,15 @@ config DEFERRED_STRUCT_PAGE_INIT
>           when kswapd starts. This has a potential performance impact on
>           processes running early in the lifetime of the systemm until kswapd
>           finishes the initialisation.
> +
> +config IDLE_PAGE_TRACKING
> +       bool "Enable idle page tracking"
> +       select PROC_PAGE_MONITOR
> +       select PAGE_EXTENSION if !64BIT
> +       help
> +         This feature allows to estimate the amount of user pages that have
> +         not been touched during a given period of time. This information can
> +         be useful to tune memory cgroup limits and/or for job placement
> +         within a compute cluster.
> +
> +         See Documentation/vm/pagemap.txt for more details.
> diff --git a/mm/debug.c b/mm/debug.c
> index 76089ddf99ea..6c1b3ea61bfd 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -48,6 +48,10 @@ static const struct trace_print_flags pageflag_names[] = {
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>         {1UL << PG_compound_lock,       "compound_lock" },
>  #endif
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
> +       {1UL << PG_young,               "young"         },
> +       {1UL << PG_idle,                "idle"          },
> +#endif
>  };
>
>  static void dump_flags(unsigned long flags,
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index d86fd2f5353f..e4b3af054bf2 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -59,6 +59,9 @@ static struct page_ext_operations *page_ext_ops[] = {
>  #ifdef CONFIG_PAGE_OWNER
>         &page_owner_ops,
>  #endif
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
> +       &page_idle_ops,
> +#endif
>  };
>
>  static unsigned long total_usage;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 49b244b1f18c..8db3a6fc0c91 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -798,6 +798,14 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>                 pte_unmap_unlock(pte, ptl);

This is not in your patch, but further up in page_referenced_one there
is the pmd case.

So what happens on THP split? That was a leading question: you should
propagate the young and idle flags to the split-up tail pages.

>         }
>
> +       if (referenced && page_is_idle(page))
> +               clear_page_idle(page);

Is it so expensive to just call clear without the test .. ?

> +
> +       if (page_is_young(page)) {
> +               clear_page_young(page);

referenced += test_and_clear_page_young(page) .. ?

> +               referenced++;
> +       }
> +

Invert the order. A page can be both young and idle -- we noted that
closer to the top of the patch.

So young bumps referenced up, and then the final referenced value is
used to clear idle.

>         if (referenced) {

At this point, if you follow my suggestion of augmenting
page_referenced_one with a mode indicator (for TLB flushing), you can
set page young here. There is the added benefit of holding the
mmap_mutex lock or vma_lock, which prevents reclaim, try_to_unmap,
migration, from exploiting a small window where page young is not set
but should.

>                 pra->referenced++;
>                 pra->vm_flags |= vma->vm_flags;
> diff --git a/mm/swap.c b/mm/swap.c
> index ab7c338eda87..db43c9b4891d 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -623,6 +623,8 @@ void mark_page_accessed(struct page *page)
>         } else if (!PageReferenced(page)) {
>                 SetPageReferenced(page);
>         }
> +       if (page_is_idle(page))
> +               clear_page_idle(page);
>  }
>  EXPORT_SYMBOL(mark_page_accessed);
>
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
