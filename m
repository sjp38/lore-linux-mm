Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CFE3A900137
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 16:33:15 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p7BKX7Ql022551
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 13:33:07 -0700
Received: from qyk31 (qyk31.prod.google.com [10.241.83.159])
	by hpaq2.eem.corp.google.com with ESMTP id p7BKWVlc015914
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 13:33:06 -0700
Received: by qyk31 with SMTP id 31so1541740qyk.4
        for <linux-mm@kvack.org>; Thu, 11 Aug 2011 13:33:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
Date: Thu, 11 Aug 2011 13:33:05 -0700
Message-ID: <CALWz4izVoN2s6J9t1TVj+1pMmHVxfiWYvq=uqeTL4C5-YsBwOw@mail.gmail.com>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=001636b4315f39a8a304aa40b4ab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--001636b4315f39a8a304aa40b4ab
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.org>wrote:

> All lru list walkers have been converted to operate on per-memcg
> lists, the global per-zone lists are no longer required.
>
> This patch makes the per-memcg lists exclusive and removes the global
> lists from memcg-enabled kernels.
>
> The per-memcg lists now string up page descriptors directly, which
> unifies/simplifies the list isolation code of page reclaim as well as
> it saves a full double-linked list head for each page in the system.
>
> At the core of this change is the introduction of the lruvec
> structure, an array of all lru list heads.  It exists for each zone
> globally, and for each zone per memcg.  All lru list operations are
> now done in generic code against lruvecs, with the memcg lru list
> primitives only doing accounting and returning the proper lruvec for
> the currently scanned memcg on isolation, or for the respective page
> on putback.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h  |   53 ++++-----
>  include/linux/mm_inline.h   |   14 ++-
>  include/linux/mmzone.h      |   10 +-
>  include/linux/page_cgroup.h |   36 ------
>  mm/memcontrol.c             |  271
> ++++++++++++++++++-------------------------
>  mm/page_alloc.c             |    2 +-
>  mm/page_cgroup.c            |   38 +------
>  mm/swap.c                   |   20 ++--
>  mm/vmscan.c                 |   88 ++++++--------
>  9 files changed, 207 insertions(+), 325 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 56c1def..d3837f0 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -20,6 +20,7 @@
>  #ifndef _LINUX_MEMCONTROL_H
>  #define _LINUX_MEMCONTROL_H
>  #include <linux/cgroup.h>
> +#include <linux/mmzone.h>
>  struct mem_cgroup;
>  struct page_cgroup;
>  struct page;
> @@ -30,13 +31,6 @@ enum mem_cgroup_page_stat_item {
>        MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
>  };
>
> -extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> -                                       struct list_head *dst,
> -                                       unsigned long *scanned, int order,
> -                                       int mode, struct zone *z,
> -                                       struct mem_cgroup *mem_cont,
> -                                       int active, int file);
> -
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  /*
>  * All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -60,15 +54,14 @@ extern void mem_cgroup_cancel_charge_swapin(struct
> mem_cgroup *ptr);
>
>  extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct
> *mm,
>                                        gfp_t gfp_mask);
> -struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,
> -                                   enum lru_list);
> -extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
> -extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
> -extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
> -extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list
> lru);
> -extern void mem_cgroup_del_lru(struct page *page);
> -extern void mem_cgroup_move_lists(struct page *page,
> -                                 enum lru_list from, enum lru_list to);
> +
> +struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
> +struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
> +                                      enum lru_list);
> +void mem_cgroup_lru_del_list(struct page *, enum lru_list);
> +void mem_cgroup_lru_del(struct page *);
> +struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
> +                                        enum lru_list, enum lru_list);
>
>  /* For coalescing uncharge for reducing memcg' overhead*/
>  extern void mem_cgroup_uncharge_start(void);
> @@ -214,33 +207,33 @@ static inline int
> mem_cgroup_shmem_charge_fallback(struct page *page,
>        return 0;
>  }
>
> -static inline void mem_cgroup_add_lru_list(struct page *page, int lru)
> -{
> -}
> -
> -static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
> +static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
> +                                                   struct mem_cgroup *mem)
>  {
> -       return ;
> +       return &zone->lruvec;
>  }
>
> -static inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
> +static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
> +                                                    struct page *page,
> +                                                    enum lru_list lru)
>  {
> -       return ;
> +       return &zone->lruvec;
>  }
>
> -static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)
> +static inline void mem_cgroup_lru_del_list(struct page *page, enum
> lru_list lru)
>  {
> -       return ;
>  }
>
> -static inline void mem_cgroup_del_lru(struct page *page)
> +static inline void mem_cgroup_lru_del(struct page *page)
>  {
> -       return ;
>  }
>
> -static inline void
> -mem_cgroup_move_lists(struct page *page, enum lru_list from, enum lru_list
> to)
> +static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
> +                                                      struct page *page,
> +                                                      enum lru_list from,
> +                                                      enum lru_list to)
>  {
> +       return &zone->lruvec;
>  }
>
>  static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page
> *page)
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index 8f7d247..43d5d9f 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -25,23 +25,27 @@ static inline void
>  __add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list
> l,
>                       struct list_head *head)
>  {
> +       /* NOTE: Caller must ensure @head is on the right lruvec! */
> +       mem_cgroup_lru_add_list(zone, page, l);
>        list_add(&page->lru, head);
>        __mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
> -       mem_cgroup_add_lru_list(page, l);
>  }
>
>  static inline void
>  add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list
> l)
>  {
> -       __add_page_to_lru_list(zone, page, l, &zone->lru[l].list);
> +       struct lruvec *lruvec = mem_cgroup_lru_add_list(zone, page, l);
> +
> +       list_add(&page->lru, &lruvec->lists[l]);
> +       __mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
>  }
>
>  static inline void
>  del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list
> l)
>  {
> +       mem_cgroup_lru_del_list(page, l);
>        list_del(&page->lru);
>        __mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
> -       mem_cgroup_del_lru_list(page, l);
>  }
>
>  /**
> @@ -64,7 +68,6 @@ del_page_from_lru(struct zone *zone, struct page *page)
>  {
>        enum lru_list l;
>
> -       list_del(&page->lru);
>        if (PageUnevictable(page)) {
>                __ClearPageUnevictable(page);
>                l = LRU_UNEVICTABLE;
> @@ -75,8 +78,9 @@ del_page_from_lru(struct zone *zone, struct page *page)
>                        l += LRU_ACTIVE;
>                }
>        }
> +       mem_cgroup_lru_del_list(page, l);
> +       list_del(&page->lru);
>        __mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
> -       mem_cgroup_del_lru_list(page, l);
>  }
>
>  /**
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e56f835..c2ddce5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -158,6 +158,10 @@ static inline int is_unevictable_lru(enum lru_list l)
>        return (l == LRU_UNEVICTABLE);
>  }
>
> +struct lruvec {
> +       struct list_head lists[NR_LRU_LISTS];
> +};
> +
>  enum zone_watermarks {
>        WMARK_MIN,
>        WMARK_LOW,
> @@ -344,10 +348,8 @@ struct zone {
>        ZONE_PADDING(_pad1_)
>
>        /* Fields commonly accessed by the page reclaim scanner */
> -       spinlock_t              lru_lock;
> -       struct zone_lru {
> -               struct list_head list;
> -       } lru[NR_LRU_LISTS];
> +       spinlock_t              lru_lock;
> +       struct lruvec           lruvec;
>
>        struct zone_reclaim_stat reclaim_stat;
>
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 961ecc7..a42ddf9 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -31,7 +31,6 @@ enum {
>  struct page_cgroup {
>        unsigned long flags;
>        struct mem_cgroup *mem_cgroup;
> -       struct list_head lru;           /* per cgroup LRU list */
>  };
>
>  void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
> @@ -49,7 +48,6 @@ static inline void __init page_cgroup_init(void)
>  #endif
>
>  struct page_cgroup *lookup_page_cgroup(struct page *page);
> -struct page *lookup_cgroup_page(struct page_cgroup *pc);
>
>  #define TESTPCGFLAG(uname, lname)                      \
>  static inline int PageCgroup##uname(struct page_cgroup *pc)    \
> @@ -121,40 +119,6 @@ static inline void move_unlock_page_cgroup(struct
> page_cgroup *pc,
>        bit_spin_unlock(PCG_MOVE_LOCK, &pc->flags);
>        local_irq_restore(*flags);
>  }
> -
> -#ifdef CONFIG_SPARSEMEM
> -#define PCG_ARRAYID_WIDTH      SECTIONS_SHIFT
> -#else
> -#define PCG_ARRAYID_WIDTH      NODES_SHIFT
> -#endif
> -
> -#if (PCG_ARRAYID_WIDTH > BITS_PER_LONG - NR_PCG_FLAGS)
> -#error Not enough space left in pc->flags to store page_cgroup array IDs
> -#endif
> -
> -/* pc->flags: ARRAY-ID | FLAGS */
> -
> -#define PCG_ARRAYID_MASK       ((1UL << PCG_ARRAYID_WIDTH) - 1)
> -
> -#define PCG_ARRAYID_OFFSET     (BITS_PER_LONG - PCG_ARRAYID_WIDTH)
> -/*
> - * Zero the shift count for non-existent fields, to prevent compiler
> - * warnings and ensure references are optimized away.
> - */
> -#define PCG_ARRAYID_SHIFT      (PCG_ARRAYID_OFFSET * (PCG_ARRAYID_WIDTH !=
> 0))
> -
> -static inline void set_page_cgroup_array_id(struct page_cgroup *pc,
> -                                           unsigned long id)
> -{
> -       pc->flags &= ~(PCG_ARRAYID_MASK << PCG_ARRAYID_SHIFT);
> -       pc->flags |= (id & PCG_ARRAYID_MASK) << PCG_ARRAYID_SHIFT;
> -}
> -
> -static inline unsigned long page_cgroup_array_id(struct page_cgroup *pc)
> -{
> -       return (pc->flags >> PCG_ARRAYID_SHIFT) & PCG_ARRAYID_MASK;
> -}
> -
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d9d1a7e..4a365b7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -133,10 +133,7 @@ struct mem_cgroup_stat_cpu {
>  * per-zone information in memory controller.
>  */
>  struct mem_cgroup_per_zone {
> -       /*
> -        * spin_lock to protect the per cgroup LRU
> -        */
> -       struct list_head        lists[NR_LRU_LISTS];
> +       struct lruvec           lruvec;
>        unsigned long           count[NR_LRU_LISTS];
>
>        struct zone_reclaim_stat reclaim_stat;
> @@ -642,6 +639,26 @@ static inline bool mem_cgroup_is_root(struct
> mem_cgroup *mem)
>        return (mem == root_mem_cgroup);
>  }
>
> +/**
> + * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
> + * @zone: zone of the wanted lruvec
> + * @mem: memcg of the wanted lruvec
> + *
> + * Returns the lru list vector holding pages for the given @zone and
> + * @mem.  This can be the global zone lruvec, if the memory controller
> + * is disabled.
> + */
> +struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone, struct mem_cgroup
> *mem)
> +{
> +       struct mem_cgroup_per_zone *mz;
> +
> +       if (mem_cgroup_disabled())
> +               return &zone->lruvec;
> +
> +       mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
> +       return &mz->lruvec;
> +}
> +
>  /*
>  * Following LRU functions are allowed to be used without PCG_LOCK.
>  * Operations are called by routine of global LRU independently from memcg.
> @@ -656,21 +673,74 @@ static inline bool mem_cgroup_is_root(struct
> mem_cgroup *mem)
>  * When moving account, the page is not on LRU. It's isolated.
>  */
>
> -struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup
> *mem,
> -                                   enum lru_list lru)
> +/**
> + * mem_cgroup_lru_add_list - account for adding an lru page and return
> lruvec
> + * @zone: zone of the page
> + * @page: the page itself
> + * @lru: target lru list
> + *
> + * This function must be called when a page is to be added to an lru
> + * list.
> + *
> + * Returns the lruvec to hold @page, the callsite is responsible for
> + * physically linking the page to &lruvec->lists[@lru].
> + */
> +struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page
> *page,
> +                                      enum lru_list lru)
>  {
>        struct mem_cgroup_per_zone *mz;
>        struct page_cgroup *pc;
> +       struct mem_cgroup *mem;
>
> -       mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
> -       pc = list_entry(mz->lists[lru].prev, struct page_cgroup, lru);
> -       return lookup_cgroup_page(pc);
> +       if (mem_cgroup_disabled())
> +               return &zone->lruvec;
> +
> +       pc = lookup_page_cgroup(page);
> +       VM_BUG_ON(PageCgroupAcctLRU(pc));
> +       if (PageCgroupUsed(pc)) {
> +               /* Ensure pc->mem_cgroup is visible after reading PCG_USED.
> */
> +               smp_rmb();
> +               mem = pc->mem_cgroup;
> +       } else {
> +               /*
> +                * If the page is no longer charged, add it to the
> +                * root memcg's lru.  Either it will be freed soon, or
> +                * it will get charged again and the charger will
> +                * relink it to the right list.
> +                */
> +               mem = root_mem_cgroup;
> +       }
> +       mz = page_cgroup_zoneinfo(mem, page);
> +       /*
> +        * We do not account for uncharged pages: they are linked to
> +        * root_mem_cgroup but when the page is unlinked upon free,
> +        * accounting would be done against pc->mem_cgroup.
> +        */
> +       if (PageCgroupUsed(pc)) {
> +               /*
> +                * Huge page splitting is serialized through the lru
> +                * lock, so compound_order() is stable here.
> +                */
> +               MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
> +               SetPageCgroupAcctLRU(pc);
> +       }
> +       return &mz->lruvec;
>  }
>
> -void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
> +/**
> + * mem_cgroup_lru_del_list - account for removing an lru page
> + * @page: page to unlink
> + * @lru: lru list the page is sitting on
> + *
> + * This function must be called when a page is to be removed from an
> + * lru list.
> + *
> + * The callsite is responsible for physically unlinking &@page->lru.
> + */
> +void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
>  {
> -       struct page_cgroup *pc;
>        struct mem_cgroup_per_zone *mz;
> +       struct page_cgroup *pc;
>
>        if (mem_cgroup_disabled())
>                return;
> @@ -686,75 +756,35 @@ void mem_cgroup_del_lru_list(struct page *page, enum
> lru_list lru)
>        mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>        /* huge page split is done under lru_lock. so, we have no races. */
>        MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> -       VM_BUG_ON(list_empty(&pc->lru));
> -       list_del_init(&pc->lru);
>  }
>
> -void mem_cgroup_del_lru(struct page *page)
> +void mem_cgroup_lru_del(struct page *page)
>  {
> -       mem_cgroup_del_lru_list(page, page_lru(page));
> +       mem_cgroup_lru_del_list(page, page_lru(page));
>  }
>
> -/*
> - * Writeback is about to end against a page which has been marked for
> immediate
> - * reclaim.  If it still appears to be reclaimable, move it to the tail of
> the
> - * inactive list.
> +/**
> + * mem_cgroup_lru_move_lists - account for moving a page between lru lists
> + * @zone: zone of the page
> + * @page: page to move
> + * @from: current lru list
> + * @to: new lru list
> + *
> + * This function must be called when a page is moved between lru
> + * lists, or rotated on the same lru list.
> + *
> + * Returns the lruvec to hold @page in the future, the callsite is
> + * responsible for physically relinking the page to
> + * &lruvec->lists[@to].
>  */
> -void mem_cgroup_rotate_reclaimable_page(struct page *page)
> -{
> -       struct mem_cgroup_per_zone *mz;
> -       struct page_cgroup *pc;
> -       enum lru_list lru = page_lru(page);
> -
> -       if (mem_cgroup_disabled())
> -               return;
> -
> -       pc = lookup_page_cgroup(page);
> -       /* unused page is not rotated. */
> -       if (!PageCgroupUsed(pc))
> -               return;
> -       /* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> -       smp_rmb();
> -       mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> -       list_move_tail(&pc->lru, &mz->lists[lru]);
> -}
> -
> -void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
> +struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
> +                                        struct page *page,
> +                                        enum lru_list from,
> +                                        enum lru_list to)
>  {
> -       struct mem_cgroup_per_zone *mz;
> -       struct page_cgroup *pc;
> -
> -       if (mem_cgroup_disabled())
> -               return;
> -
> -       pc = lookup_page_cgroup(page);
> -       /* unused page is not rotated. */
> -       if (!PageCgroupUsed(pc))
> -               return;
> -       /* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> -       smp_rmb();
> -       mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> -       list_move(&pc->lru, &mz->lists[lru]);
> -}
> -
> -void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
> -{
> -       struct page_cgroup *pc;
> -       struct mem_cgroup_per_zone *mz;
> -
> -       if (mem_cgroup_disabled())
> -               return;
> -       pc = lookup_page_cgroup(page);
> -       VM_BUG_ON(PageCgroupAcctLRU(pc));
> -       if (!PageCgroupUsed(pc))
> -               return;
> -       /* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> -       smp_rmb();
> -       mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> -       /* huge page split is done under lru_lock. so, we have no races. */
> -       MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
> -       SetPageCgroupAcctLRU(pc);
> -       list_add(&pc->lru, &mz->lists[lru]);
> +       /* TODO: this could be optimized, especially if from == to */
> +       mem_cgroup_lru_del_list(page, from);
> +       return mem_cgroup_lru_add_list(zone, page, to);
>  }
>
>  /*
> @@ -786,7 +816,7 @@ static void mem_cgroup_lru_del_before_commit(struct
> page *page)
>         * is guarded by lock_page() because the page is SwapCache.
>         */
>        if (!PageCgroupUsed(pc))
> -               mem_cgroup_del_lru_list(page, page_lru(page));
> +               del_page_from_lru(zone, page);
>        spin_unlock_irqrestore(&zone->lru_lock, flags);
>  }
>
> @@ -800,22 +830,11 @@ static void mem_cgroup_lru_add_after_commit(struct
> page *page)
>        if (likely(!PageLRU(page)))
>                return;
>        spin_lock_irqsave(&zone->lru_lock, flags);
> -       /* link when the page is linked to LRU but page_cgroup isn't */
>        if (PageLRU(page) && !PageCgroupAcctLRU(pc))
> -               mem_cgroup_add_lru_list(page, page_lru(page));
> +               add_page_to_lru_list(zone, page, page_lru(page));
>        spin_unlock_irqrestore(&zone->lru_lock, flags);
>  }
>
> -
> -void mem_cgroup_move_lists(struct page *page,
> -                          enum lru_list from, enum lru_list to)
> -{
> -       if (mem_cgroup_disabled())
> -               return;
> -       mem_cgroup_del_lru_list(page, from);
> -       mem_cgroup_add_lru_list(page, to);
> -}
> -
>  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup
> *mem)
>  {
>        int ret;
> @@ -935,67 +954,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page
> *page)
>        return &mz->reclaim_stat;
>  }
>
> -unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> -                                       struct list_head *dst,
> -                                       unsigned long *scanned, int order,
> -                                       int mode, struct zone *z,
> -                                       struct mem_cgroup *mem_cont,
> -                                       int active, int file)
> -{
> -       unsigned long nr_taken = 0;
> -       struct page *page;
> -       unsigned long scan;
> -       LIST_HEAD(pc_list);
> -       struct list_head *src;
> -       struct page_cgroup *pc, *tmp;
> -       int nid = zone_to_nid(z);
> -       int zid = zone_idx(z);
> -       struct mem_cgroup_per_zone *mz;
> -       int lru = LRU_FILE * file + active;
> -       int ret;
> -
> -       BUG_ON(!mem_cont);
> -       mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
> -       src = &mz->lists[lru];
> -
> -       scan = 0;
> -       list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
> -               if (scan >= nr_to_scan)
> -                       break;
> -
> -               if (unlikely(!PageCgroupUsed(pc)))
> -                       continue;
> -
> -               page = lookup_cgroup_page(pc);
> -
> -               if (unlikely(!PageLRU(page)))
> -                       continue;
> -
> -               scan++;
> -               ret = __isolate_lru_page(page, mode, file);
> -               switch (ret) {
> -               case 0:
> -                       list_move(&page->lru, dst);
> -                       mem_cgroup_del_lru(page);
> -                       nr_taken += hpage_nr_pages(page);
> -                       break;
> -               case -EBUSY:
> -                       /* we don't affect global LRU but rotate in our LRU
> */
> -                       mem_cgroup_rotate_lru_list(page, page_lru(page));
> -                       break;
> -               default:
> -                       break;
> -               }
> -       }
> -
> -       *scanned = scan;
> -
> -       trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
> -                                     0, 0, 0, mode);
> -
> -       return nr_taken;
> -}
> -
>  #define mem_cgroup_from_res_counter(counter, member)   \
>        container_of(counter, struct mem_cgroup, member)
>
> @@ -3110,22 +3068,23 @@ static int mem_cgroup_resize_memsw_limit(struct
> mem_cgroup *memcg,
>  static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
>                                int node, int zid, enum lru_list lru)
>  {
> -       struct zone *zone;
>        struct mem_cgroup_per_zone *mz;
> -       struct page_cgroup *pc, *busy;
>        unsigned long flags, loop;
>        struct list_head *list;
> +       struct page *busy;
> +       struct zone *zone;
>        int ret = 0;
>
>        zone = &NODE_DATA(node)->node_zones[zid];
>        mz = mem_cgroup_zoneinfo(mem, node, zid);
> -       list = &mz->lists[lru];
> +       list = &mz->lruvec.lists[lru];
>
>        loop = MEM_CGROUP_ZSTAT(mz, lru);
>        /* give some margin against EBUSY etc...*/
>        loop += 256;
>        busy = NULL;
>        while (loop--) {
> +               struct page_cgroup *pc;
>                struct page *page;
>
>                ret = 0;
> @@ -3134,16 +3093,16 @@ static int mem_cgroup_force_empty_list(struct
> mem_cgroup *mem,
>                        spin_unlock_irqrestore(&zone->lru_lock, flags);
>                        break;
>                }
> -               pc = list_entry(list->prev, struct page_cgroup, lru);
> -               if (busy == pc) {
> -                       list_move(&pc->lru, list);
> +               page = list_entry(list->prev, struct page, lru);
> +               if (busy == page) {
> +                       list_move(&page->lru, list);
>                        busy = NULL;
>                        spin_unlock_irqrestore(&zone->lru_lock, flags);
>                        continue;
>                }
>                spin_unlock_irqrestore(&zone->lru_lock, flags);
>
> -               page = lookup_cgroup_page(pc);
> +               pc = lookup_page_cgroup(page);
>
>                ret = mem_cgroup_move_parent(page, pc, mem, GFP_KERNEL);
>                if (ret == -ENOMEM)
> @@ -3151,7 +3110,7 @@ static int mem_cgroup_force_empty_list(struct
> mem_cgroup *mem,
>
>                if (ret == -EBUSY || ret == -EINVAL) {
>                        /* found lock contention or "pc" is obsolete. */
> -                       busy = pc;
> +                       busy = page;
>                        cond_resched();
>                } else
>                        busy = NULL;
> @@ -4171,7 +4130,7 @@ static int alloc_mem_cgroup_per_zone_info(struct
> mem_cgroup *mem, int node)
>        for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>                mz = &pn->zoneinfo[zone];
>                for_each_lru(l)
> -                       INIT_LIST_HEAD(&mz->lists[l]);
> +                       INIT_LIST_HEAD(&mz->lruvec.lists[l]);
>        }
>        return 0;
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3f8bce2..9da238d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4289,7 +4289,7 @@ static void __paginginit free_area_init_core(struct
> pglist_data *pgdat,
>
>                zone_pcp_init(zone);
>                for_each_lru(l) {
> -                       INIT_LIST_HEAD(&zone->lru[l].list);
> +                       INIT_LIST_HEAD(&zone->lruvec.lists[l]);
>                        zone->reclaim_stat.nr_saved_scan[l] = 0;
>                }
>                zone->reclaim_stat.recent_rotated[0] = 0;
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 2daadc3..916c6f9 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -11,12 +11,10 @@
>  #include <linux/swapops.h>
>  #include <linux/kmemleak.h>
>
> -static void __meminit init_page_cgroup(struct page_cgroup *pc, unsigned
> long id)
> +static void __meminit init_page_cgroup(struct page_cgroup *pc)
>  {
>        pc->flags = 0;
> -       set_page_cgroup_array_id(pc, id);
>        pc->mem_cgroup = NULL;
> -       INIT_LIST_HEAD(&pc->lru);
>  }
>  static unsigned long total_usage;
>
> @@ -42,19 +40,6 @@ struct page_cgroup *lookup_page_cgroup(struct page
> *page)
>        return base + offset;
>  }
>
> -struct page *lookup_cgroup_page(struct page_cgroup *pc)
> -{
> -       unsigned long pfn;
> -       struct page *page;
> -       pg_data_t *pgdat;
> -
> -       pgdat = NODE_DATA(page_cgroup_array_id(pc));
> -       pfn = pc - pgdat->node_page_cgroup + pgdat->node_start_pfn;
> -       page = pfn_to_page(pfn);
> -       VM_BUG_ON(pc != lookup_page_cgroup(page));
> -       return page;
> -}
> -
>  static int __init alloc_node_page_cgroup(int nid)
>  {
>        struct page_cgroup *base, *pc;
> @@ -75,7 +60,7 @@ static int __init alloc_node_page_cgroup(int nid)
>                return -ENOMEM;
>        for (index = 0; index < nr_pages; index++) {
>                pc = base + index;
> -               init_page_cgroup(pc, nid);
> +               init_page_cgroup(pc);
>        }
>        NODE_DATA(nid)->node_page_cgroup = base;
>        total_usage += table_size;
> @@ -117,19 +102,6 @@ struct page_cgroup *lookup_page_cgroup(struct page
> *page)
>        return section->page_cgroup + pfn;
>  }
>
> -struct page *lookup_cgroup_page(struct page_cgroup *pc)
> -{
> -       struct mem_section *section;
> -       struct page *page;
> -       unsigned long nr;
> -
> -       nr = page_cgroup_array_id(pc);
> -       section = __nr_to_section(nr);
> -       page = pfn_to_page(pc - section->page_cgroup);
> -       VM_BUG_ON(pc != lookup_page_cgroup(page));
> -       return page;
> -}
> -
>  static void *__init_refok alloc_page_cgroup(size_t size, int nid)
>  {
>        void *addr = NULL;
> @@ -167,11 +139,9 @@ static int __init_refok
> init_section_page_cgroup(unsigned long pfn)
>        struct page_cgroup *base, *pc;
>        struct mem_section *section;
>        unsigned long table_size;
> -       unsigned long nr;
>        int nid, index;
>
> -       nr = pfn_to_section_nr(pfn);
> -       section = __nr_to_section(nr);
> +       section = __pfn_to_section(pfn);
>
>        if (section->page_cgroup)
>                return 0;
> @@ -194,7 +164,7 @@ static int __init_refok
> init_section_page_cgroup(unsigned long pfn)
>
>        for (index = 0; index < PAGES_PER_SECTION; index++) {
>                pc = base + index;
> -               init_page_cgroup(pc, nr);
> +               init_page_cgroup(pc);
>        }
>
>        section->page_cgroup = base - pfn;
> diff --git a/mm/swap.c b/mm/swap.c
> index 5602f1a..0a5a93b 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -209,12 +209,14 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
>  static void pagevec_move_tail_fn(struct page *page, void *arg)
>  {
>        int *pgmoved = arg;
> -       struct zone *zone = page_zone(page);
>
>        if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
>                enum lru_list lru = page_lru_base_type(page);
> -               list_move_tail(&page->lru, &zone->lru[lru].list);
> -               mem_cgroup_rotate_reclaimable_page(page);
> +               struct lruvec *lruvec;
> +
> +               lruvec = mem_cgroup_lru_move_lists(page_zone(page),
> +                                                  page, lru, lru);
> +               list_move_tail(&page->lru, &lruvec->lists[lru]);
>                (*pgmoved)++;
>        }
>  }
> @@ -420,12 +422,13 @@ static void lru_deactivate_fn(struct page *page, void
> *arg)
>                 */
>                SetPageReclaim(page);
>        } else {
> +               struct lruvec *lruvec;
>                /*
>                 * The page's writeback ends up during pagevec
>                 * We moves tha page into tail of inactive.
>                 */
> -               list_move_tail(&page->lru, &zone->lru[lru].list);
> -               mem_cgroup_rotate_reclaimable_page(page);
> +               lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
> +               list_move_tail(&page->lru, &lruvec->lists[lru]);
>                __count_vm_event(PGROTATED);
>        }
>
> @@ -597,7 +600,6 @@ void lru_add_page_tail(struct zone* zone,
>        int active;
>        enum lru_list lru;
>        const int file = 0;
> -       struct list_head *head;
>
>        VM_BUG_ON(!PageHead(page));
>        VM_BUG_ON(PageCompound(page_tail));
> @@ -617,10 +619,10 @@ void lru_add_page_tail(struct zone* zone,
>                }
>                update_page_reclaim_stat(zone, page_tail, file, active);
>                if (likely(PageLRU(page)))
> -                       head = page->lru.prev;
> +                       __add_page_to_lru_list(zone, page_tail, lru,
> +                                              page->lru.prev);
>                else
> -                       head = &zone->lru[lru].list;
> -               __add_page_to_lru_list(zone, page_tail, lru, head);
> +                       add_page_to_lru_list(zone, page_tail, lru);
>        } else {
>                SetPageUnevictable(page_tail);
>                add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 23fd2b1..87e1fcb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1080,15 +1080,14 @@ static unsigned long isolate_lru_pages(unsigned
> long nr_to_scan,
>
>                switch (__isolate_lru_page(page, mode, file)) {
>                case 0:
> +                       mem_cgroup_lru_del(page);
>                        list_move(&page->lru, dst);
> -                       mem_cgroup_del_lru(page);
>                        nr_taken += hpage_nr_pages(page);
>                        break;
>
>                case -EBUSY:
>                        /* else it is being freed elsewhere */
>                        list_move(&page->lru, src);
> -                       mem_cgroup_rotate_lru_list(page, page_lru(page));
>                        continue;
>
>                default:
> @@ -1138,8 +1137,8 @@ static unsigned long isolate_lru_pages(unsigned long
> nr_to_scan,
>                                break;
>
>                        if (__isolate_lru_page(cursor_page, mode, file) ==
> 0) {
> +                               mem_cgroup_lru_del(cursor_page);
>                                list_move(&cursor_page->lru, dst);
> -                               mem_cgroup_del_lru(cursor_page);
>                                nr_taken += hpage_nr_pages(page);
>                                nr_lumpy_taken++;
>                                if (PageDirty(cursor_page))
> @@ -1168,19 +1167,22 @@ static unsigned long isolate_lru_pages(unsigned
> long nr_to_scan,
>        return nr_taken;
>  }
>
> -static unsigned long isolate_pages_global(unsigned long nr,
> -                                       struct list_head *dst,
> -                                       unsigned long *scanned, int order,
> -                                       int mode, struct zone *z,
> -                                       int active, int file)
> +static unsigned long isolate_pages(unsigned long nr,
> +                                  struct list_head *dst,
> +                                  unsigned long *scanned, int order,
> +                                  int mode, struct zone *z,
> +                                  int active, int file,
> +                                  struct mem_cgroup *mem)
>  {
> +       struct lruvec *lruvec = mem_cgroup_zone_lruvec(z, mem);
>        int lru = LRU_BASE;
> +
>        if (active)
>                lru += LRU_ACTIVE;
>        if (file)
>                lru += LRU_FILE;
> -       return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned,
> order,
> -                                                               mode,
> file);
> +       return isolate_lru_pages(nr, &lruvec->lists[lru], dst,
> +                                scanned, order, mode, file);
>  }
>
>  /*
> @@ -1428,20 +1430,11 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
>        lru_add_drain();
>        spin_lock_irq(&zone->lru_lock);
>
> -       if (scanning_global_lru(sc)) {
> -               nr_taken = isolate_pages_global(nr_to_scan,
> -                       &page_list, &nr_scanned, sc->order,
> -                       sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
> -                                       ISOLATE_BOTH : ISOLATE_INACTIVE,
> -                       zone, 0, file);
> -       } else {
> -               nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
> -                       &page_list, &nr_scanned, sc->order,
> -                       sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
> +       nr_taken = isolate_pages(nr_to_scan,
> +                                &page_list, &nr_scanned, sc->order,
> +                                sc->reclaim_mode &
> RECLAIM_MODE_LUMPYRECLAIM ?
>                                        ISOLATE_BOTH : ISOLATE_INACTIVE,
> -                       zone, sc->mem_cgroup,
> -                       0, file);
> -       }
> +                                zone, 0, file, sc->mem_cgroup);
>
>        if (global_reclaim(sc)) {
>                zone->pages_scanned += nr_scanned;
> @@ -1514,13 +1507,15 @@ static void move_active_pages_to_lru(struct zone
> *zone,
>        pagevec_init(&pvec, 1);
>
>        while (!list_empty(list)) {
> +               struct lruvec *lruvec;
> +
>                page = lru_to_page(list);
>
>                VM_BUG_ON(PageLRU(page));
>                SetPageLRU(page);
>
> -               list_move(&page->lru, &zone->lru[lru].list);
> -               mem_cgroup_add_lru_list(page, lru);
> +               lruvec = mem_cgroup_lru_add_list(zone, page, lru);
> +               list_move(&page->lru, &lruvec->lists[lru]);
>                pgmoved += hpage_nr_pages(page);
>
>                if (!pagevec_add(&pvec, page) || list_empty(list)) {
> @@ -1551,17 +1546,10 @@ static void shrink_active_list(unsigned long
> nr_pages, struct zone *zone,
>
>        lru_add_drain();
>        spin_lock_irq(&zone->lru_lock);
> -       if (scanning_global_lru(sc)) {
> -               nr_taken = isolate_pages_global(nr_pages, &l_hold,
> -                                               &pgscanned, sc->order,
> -                                               ISOLATE_ACTIVE, zone,
> -                                               1, file);
> -       } else {
> -               nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
> -                                               &pgscanned, sc->order,
> -                                               ISOLATE_ACTIVE, zone,
> -                                               sc->mem_cgroup, 1, file);
> -       }
> +       nr_taken = isolate_pages(nr_pages, &l_hold,
> +                                &pgscanned, sc->order,
> +                                ISOLATE_ACTIVE, zone,
> +                                1, file, sc->mem_cgroup);
>
>        if (global_reclaim(sc))
>                zone->pages_scanned += pgscanned;
> @@ -3154,16 +3142,18 @@ int page_evictable(struct page *page, struct
> vm_area_struct *vma)
>  */
>  static void check_move_unevictable_page(struct page *page, struct zone
> *zone)
>  {
> -       VM_BUG_ON(PageActive(page));
> +       struct lruvec *lruvec;
>
> +       VM_BUG_ON(PageActive(page));
>  retry:
>        ClearPageUnevictable(page);
>        if (page_evictable(page, NULL)) {
>                enum lru_list l = page_lru_base_type(page);
>
> +               lruvec = mem_cgroup_lru_move_lists(zone, page,
> +                                                  LRU_UNEVICTABLE, l);
>                __dec_zone_state(zone, NR_UNEVICTABLE);
> -               list_move(&page->lru, &zone->lru[l].list);
> -               mem_cgroup_move_lists(page, LRU_UNEVICTABLE, l);
> +               list_move(&page->lru, &lruvec->lists[l]);
>                __inc_zone_state(zone, NR_INACTIVE_ANON + l);
>                __count_vm_event(UNEVICTABLE_PGRESCUED);
>        } else {
> @@ -3171,8 +3161,9 @@ retry:
>                 * rotate unevictable list
>                 */
>                SetPageUnevictable(page);
> -               list_move(&page->lru, &zone->lru[LRU_UNEVICTABLE].list);
> -               mem_cgroup_rotate_lru_list(page, LRU_UNEVICTABLE);
> +               lruvec = mem_cgroup_lru_move_lists(zone, page,
> LRU_UNEVICTABLE,
> +                                                  LRU_UNEVICTABLE);
> +               list_move(&page->lru, &lruvec->lists[LRU_UNEVICTABLE]);
>                if (page_evictable(page, NULL))
>                        goto retry;
>        }
> @@ -3233,14 +3224,6 @@ void scan_mapping_unevictable_pages(struct
> address_space *mapping)
>
>  }
>
> -static struct page *lru_tailpage(struct zone *zone, struct mem_cgroup
> *mem,
> -                                enum lru_list lru)
> -{
> -       if (mem)
> -               return mem_cgroup_lru_to_page(zone, mem, lru);
> -       return lru_to_page(&zone->lru[lru].list);
> -}
> -
>  /**
>  * scan_zone_unevictable_pages - check unevictable list for evictable pages
>  * @zone - zone of which to scan the unevictable list
> @@ -3259,8 +3242,13 @@ static void scan_zone_unevictable_pages(struct zone
> *zone)
>        first = mem = mem_cgroup_hierarchy_walk(NULL, mem);
>        do {
>                unsigned long nr_to_scan;
> +               struct list_head *list;
> +               struct lruvec *lruvec;
>
>                nr_to_scan = zone_nr_lru_pages(zone, mem, LRU_UNEVICTABLE);
> +               lruvec = mem_cgroup_zone_lruvec(zone, mem);
> +               list = &lruvec->lists[LRU_UNEVICTABLE];
> +
>                while (nr_to_scan > 0) {
>                        unsigned long batch_size;
>                        unsigned long scan;
> @@ -3272,7 +3260,7 @@ static void scan_zone_unevictable_pages(struct zone
> *zone)
>                        for (scan = 0; scan < batch_size; scan++) {
>                                struct page *page;
>
> -                               page = lru_tailpage(zone, mem,
> LRU_UNEVICTABLE);
> +                               page = lru_to_page(list);
>                                if (!trylock_page(page))
>                                        continue;
>                                if (likely(PageLRU(page) &&
> --
> 1.7.5.2
>
> Johannes, I wonder if we should include the following patch:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 674823e..1513deb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -832,7 +832,7 @@ static void
mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
         * Forget old LRU when this page_cgroup is *not* used. This Used bit
         * is guarded by lock_page() because the page is SwapCache.
         */
-       if (!PageCgroupUsed(pc))
+       if (PageLRU(page) && !PageCgroupUsed(pc))
                del_page_from_lru(zone, page);
        spin_unlock_irqrestore(&zone->lru_lock, flags);
 }

--Ying

--001636b4315f39a8a304aa40b4ab
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 31, 2011 at 11:25 PM, Johann=
es Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hanne=
s@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
All lru list walkers have been converted to operate on per-memcg<br>
lists, the global per-zone lists are no longer required.<br>
<br>
This patch makes the per-memcg lists exclusive and removes the global<br>
lists from memcg-enabled kernels.<br>
<br>
The per-memcg lists now string up page descriptors directly, which<br>
unifies/simplifies the list isolation code of page reclaim as well as<br>
it saves a full double-linked list head for each page in the system.<br>
<br>
At the core of this change is the introduction of the lruvec<br>
structure, an array of all lru list heads. =A0It exists for each zone<br>
globally, and for each zone per memcg. =A0All lru list operations are<br>
now done in generic code against lruvecs, with the memcg lru list<br>
primitives only doing accounting and returning the proper lruvec for<br>
the currently scanned memcg on isolation, or for the respective page<br>
on putback.<br>
<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">ha=
nnes@cmpxchg.org</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h =A0| =A0 53 ++++-----<br>
=A0include/linux/mm_inline.h =A0 | =A0 14 ++-<br>
=A0include/linux/mmzone.h =A0 =A0 =A0| =A0 10 +-<br>
=A0include/linux/page_cgroup.h | =A0 36 ------<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0271 ++++++++++++++++++-----=
--------------------<br>
=A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-<br>
=A0mm/page_cgroup.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 38 +------<br>
=A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 20 ++--<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 88 ++++++--------<br>
=A09 files changed, 207 insertions(+), 325 deletions(-)<br>
<br>
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<br>
index 56c1def..d3837f0 100644<br>
--- a/include/linux/memcontrol.h<br>
+++ b/include/linux/memcontrol.h<br>
@@ -20,6 +20,7 @@<br>
=A0#ifndef _LINUX_MEMCONTROL_H<br>
=A0#define _LINUX_MEMCONTROL_H<br>
=A0#include &lt;linux/cgroup.h&gt;<br>
+#include &lt;linux/mmzone.h&gt;<br>
=A0struct mem_cgroup;<br>
=A0struct page_cgroup;<br>
=A0struct page;<br>
@@ -30,13 +31,6 @@ enum mem_cgroup_page_stat_item {<br>
 =A0 =A0 =A0 =A0MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */<=
br>
=A0};<br>
<br>
-extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,<br=
>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct list_head *dst,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long *scanned, int order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int mode, struct zone *z,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct mem_cgroup *mem_cont,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int active, int file);<br>
-<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
=A0/*<br>
 =A0* All &quot;charge&quot; functions with gfp_mask should use GFP_KERNEL =
or<br>
@@ -60,15 +54,14 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_=
cgroup *ptr);<br>
<br>
=A0extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *=
mm,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask);<br>
-struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,<br=
>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum =
lru_list);<br>
-extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);=
<br>
-extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);=
<br>
-extern void mem_cgroup_rotate_reclaimable_page(struct page *page);<br>
-extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lr=
u);<br>
-extern void mem_cgroup_del_lru(struct page *page);<br>
-extern void mem_cgroup_move_lists(struct page *page,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lru_=
list from, enum lru_list to);<br>
+<br>
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);=
<br>
+struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0enum lru_list);<br>
+void mem_cgroup_lru_del_list(struct page *, enum lru_list);<br>
+void mem_cgroup_lru_del(struct page *);<br>
+struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0enum lru_list, enum lru_list);<br>
<br>
=A0/* For coalescing uncharge for reducing memcg&#39; overhead*/<br>
=A0extern void mem_cgroup_uncharge_start(void);<br>
@@ -214,33 +207,33 @@ static inline int mem_cgroup_shmem_charge_fallback(st=
ruct page *page,<br>
 =A0 =A0 =A0 =A0return 0;<br>
=A0}<br>
<br>
-static inline void mem_cgroup_add_lru_list(struct page *page, int lru)<br>
-{<br>
-}<br>
-<br>
-static inline void mem_cgroup_del_lru_list(struct page *page, int lru)<br>
+static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *mem)<br>
=A0{<br>
- =A0 =A0 =A0 return ;<br>
+ =A0 =A0 =A0 return &amp;zone-&gt;lruvec;<br>
=A0}<br>
<br>
-static inline void mem_cgroup_rotate_reclaimable_page(struct page *page)<b=
r>
+static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list lru)<br>
=A0{<br>
- =A0 =A0 =A0 return ;<br>
+ =A0 =A0 =A0 return &amp;zone-&gt;lruvec;<br>
=A0}<br>
<br>
-static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)<=
br>
+static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_lis=
t lru)<br>
=A0{<br>
- =A0 =A0 =A0 return ;<br>
=A0}<br>
<br>
-static inline void mem_cgroup_del_lru(struct page *page)<br>
+static inline void mem_cgroup_lru_del(struct page *page)<br>
=A0{<br>
- =A0 =A0 =A0 return ;<br>
=A0}<br>
<br>
-static inline void<br>
-mem_cgroup_move_lists(struct page *page, enum lru_list from, enum lru_list=
 to)<br>
+static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list from,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list to)<br>
=A0{<br>
+ =A0 =A0 =A0 return &amp;zone-&gt;lruvec;<br>
=A0}<br>
<br>
=A0static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct pag=
e *page)<br>
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h<br>
index 8f7d247..43d5d9f 100644<br>
--- a/include/linux/mm_inline.h<br>
+++ b/include/linux/mm_inline.h<br>
@@ -25,23 +25,27 @@ static inline void<br>
=A0__add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_li=
st l,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *head)<br>
=A0{<br>
+ =A0 =A0 =A0 /* NOTE: Caller must ensure @head is on the right lruvec! */<=
br>
+ =A0 =A0 =A0 mem_cgroup_lru_add_list(zone, page, l);<br>
 =A0 =A0 =A0 =A0list_add(&amp;page-&gt;lru, head);<br>
 =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages=
(page));<br>
- =A0 =A0 =A0 mem_cgroup_add_lru_list(page, l);<br>
=A0}<br>
<br>
=A0static inline void<br>
=A0add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list=
 l)<br>
=A0{<br>
- =A0 =A0 =A0 __add_page_to_lru_list(zone, page, l, &amp;zone-&gt;lru[l].li=
st);<br>
+ =A0 =A0 =A0 struct lruvec *lruvec =3D mem_cgroup_lru_add_list(zone, page,=
 l);<br>
+<br>
+ =A0 =A0 =A0 list_add(&amp;page-&gt;lru, &amp;lruvec-&gt;lists[l]);<br>
+ =A0 =A0 =A0 __mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(p=
age));<br>
=A0}<br>
<br>
=A0static inline void<br>
=A0del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_li=
st l)<br>
=A0{<br>
+ =A0 =A0 =A0 mem_cgroup_lru_del_list(page, l);<br>
 =A0 =A0 =A0 =A0list_del(&amp;page-&gt;lru);<br>
 =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_page=
s(page));<br>
- =A0 =A0 =A0 mem_cgroup_del_lru_list(page, l);<br>
=A0}<br>
<br>
=A0/**<br>
@@ -64,7 +68,6 @@ del_page_from_lru(struct zone *zone, struct page *page)<b=
r>
=A0{<br>
 =A0 =A0 =A0 =A0enum lru_list l;<br>
<br>
- =A0 =A0 =A0 list_del(&amp;page-&gt;lru);<br>
 =A0 =A0 =A0 =A0if (PageUnevictable(page)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__ClearPageUnevictable(page);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0l =3D LRU_UNEVICTABLE;<br>
@@ -75,8 +78,9 @@ del_page_from_lru(struct zone *zone, struct page *page)<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0l +=3D LRU_ACTIVE;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 mem_cgroup_lru_del_list(page, l);<br>
+ =A0 =A0 =A0 list_del(&amp;page-&gt;lru);<br>
 =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_page=
s(page));<br>
- =A0 =A0 =A0 mem_cgroup_del_lru_list(page, l);<br>
=A0}<br>
<br>
=A0/**<br>
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h<br>
index e56f835..c2ddce5 100644<br>
--- a/include/linux/mmzone.h<br>
+++ b/include/linux/mmzone.h<br>
@@ -158,6 +158,10 @@ static inline int is_unevictable_lru(enum lru_list l)<=
br>
 =A0 =A0 =A0 =A0return (l =3D=3D LRU_UNEVICTABLE);<br>
=A0}<br>
<br>
+struct lruvec {<br>
+ =A0 =A0 =A0 struct list_head lists[NR_LRU_LISTS];<br>
+};<br>
+<br>
=A0enum zone_watermarks {<br>
 =A0 =A0 =A0 =A0WMARK_MIN,<br>
 =A0 =A0 =A0 =A0WMARK_LOW,<br>
@@ -344,10 +348,8 @@ struct zone {<br>
 =A0 =A0 =A0 =A0ZONE_PADDING(_pad1_)<br>
<br>
 =A0 =A0 =A0 =A0/* Fields commonly accessed by the page reclaim scanner */<=
br>
- =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lru_lock;<br>
- =A0 =A0 =A0 struct zone_lru {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head list;<br>
- =A0 =A0 =A0 } lru[NR_LRU_LISTS];<br>
+ =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lru_lock;<br>
+ =A0 =A0 =A0 struct lruvec =A0 =A0 =A0 =A0 =A0 lruvec;<br>
<br>
 =A0 =A0 =A0 =A0struct zone_reclaim_stat reclaim_stat;<br>
<br>
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h<br>
index 961ecc7..a42ddf9 100644<br>
--- a/include/linux/page_cgroup.h<br>
+++ b/include/linux/page_cgroup.h<br>
@@ -31,7 +31,6 @@ enum {<br>
=A0struct page_cgroup {<br>
 =A0 =A0 =A0 =A0unsigned long flags;<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem_cgroup;<br>
- =A0 =A0 =A0 struct list_head lru; =A0 =A0 =A0 =A0 =A0 /* per cgroup LRU l=
ist */<br>
=A0};<br>
<br>
=A0void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);<br>
@@ -49,7 +48,6 @@ static inline void __init page_cgroup_init(void)<br>
=A0#endif<br>
<br>
=A0struct page_cgroup *lookup_page_cgroup(struct page *page);<br>
-struct page *lookup_cgroup_page(struct page_cgroup *pc);<br>
<br>
=A0#define TESTPCGFLAG(uname, lname) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0\<br>
=A0static inline int PageCgroup##uname(struct page_cgroup *pc) =A0 =A0\<br>
@@ -121,40 +119,6 @@ static inline void move_unlock_page_cgroup(struct page=
_cgroup *pc,<br>
 =A0 =A0 =A0 =A0bit_spin_unlock(PCG_MOVE_LOCK, &amp;pc-&gt;flags);<br>
 =A0 =A0 =A0 =A0local_irq_restore(*flags);<br>
=A0}<br>
-<br>
-#ifdef CONFIG_SPARSEMEM<br>
-#define PCG_ARRAYID_WIDTH =A0 =A0 =A0SECTIONS_SHIFT<br>
-#else<br>
-#define PCG_ARRAYID_WIDTH =A0 =A0 =A0NODES_SHIFT<br>
-#endif<br>
-<br>
-#if (PCG_ARRAYID_WIDTH &gt; BITS_PER_LONG - NR_PCG_FLAGS)<br>
-#error Not enough space left in pc-&gt;flags to store page_cgroup array ID=
s<br>
-#endif<br>
-<br>
-/* pc-&gt;flags: ARRAY-ID | FLAGS */<br>
-<br>
-#define PCG_ARRAYID_MASK =A0 =A0 =A0 ((1UL &lt;&lt; PCG_ARRAYID_WIDTH) - 1=
)<br>
-<br>
-#define PCG_ARRAYID_OFFSET =A0 =A0 (BITS_PER_LONG - PCG_ARRAYID_WIDTH)<br>
-/*<br>
- * Zero the shift count for non-existent fields, to prevent compiler<br>
- * warnings and ensure references are optimized away.<br>
- */<br>
-#define PCG_ARRAYID_SHIFT =A0 =A0 =A0(PCG_ARRAYID_OFFSET * (PCG_ARRAYID_WI=
DTH !=3D 0))<br>
-<br>
-static inline void set_page_cgroup_array_id(struct page_cgroup *pc,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 unsigned long id)<br>
-{<br>
- =A0 =A0 =A0 pc-&gt;flags &amp;=3D ~(PCG_ARRAYID_MASK &lt;&lt; PCG_ARRAYID=
_SHIFT);<br>
- =A0 =A0 =A0 pc-&gt;flags |=3D (id &amp; PCG_ARRAYID_MASK) &lt;&lt; PCG_AR=
RAYID_SHIFT;<br>
-}<br>
-<br>
-static inline unsigned long page_cgroup_array_id(struct page_cgroup *pc)<b=
r>
-{<br>
- =A0 =A0 =A0 return (pc-&gt;flags &gt;&gt; PCG_ARRAYID_SHIFT) &amp; PCG_AR=
RAYID_MASK;<br>
-}<br>
-<br>
=A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */<br>
=A0struct page_cgroup;<br>
<br>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
index d9d1a7e..4a365b7 100644<br>
--- a/mm/memcontrol.c<br>
+++ b/mm/memcontrol.c<br>
@@ -133,10 +133,7 @@ struct mem_cgroup_stat_cpu {<br>
 =A0* per-zone information in memory controller.<br>
 =A0*/<br>
=A0struct mem_cgroup_per_zone {<br>
- =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0* spin_lock to protect the per cgroup LRU<br>
- =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0lists[NR_LRU_LISTS];<br>
+ =A0 =A0 =A0 struct lruvec =A0 =A0 =A0 =A0 =A0 lruvec;<br>
 =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 count[NR_LRU_LISTS];<br>
<br>
 =A0 =A0 =A0 =A0struct zone_reclaim_stat reclaim_stat;<br>
@@ -642,6 +639,26 @@ static inline bool mem_cgroup_is_root(struct mem_cgrou=
p *mem)<br>
 =A0 =A0 =A0 =A0return (mem =3D=3D root_mem_cgroup);<br>
=A0}<br>
<br>
+/**<br>
+ * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg<b=
r>
+ * @zone: zone of the wanted lruvec<br>
+ * @mem: memcg of the wanted lruvec<br>
+ *<br>
+ * Returns the lru list vector holding pages for the given @zone and<br>
+ * @mem. =A0This can be the global zone lruvec, if the memory controller<b=
r>
+ * is disabled.<br>
+ */<br>
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone, struct mem_cgroup=
 *mem)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
+<br>
+ =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &amp;zone-&gt;lruvec;<br>
+<br>
+ =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(z=
one));<br>
+ =A0 =A0 =A0 return &amp;mz-&gt;lruvec;<br>
+}<br>
+<br>
=A0/*<br>
 =A0* Following LRU functions are allowed to be used without PCG_LOCK.<br>
 =A0* Operations are called by routine of global LRU independently from mem=
cg.<br>
@@ -656,21 +673,74 @@ static inline bool mem_cgroup_is_root(struct mem_cgro=
up *mem)<br>
 =A0* When moving account, the page is not on LRU. It&#39;s isolated.<br>
 =A0*/<br>
<br>
-struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup *=
mem,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum =
lru_list lru)<br>
+/**<br>
+ * mem_cgroup_lru_add_list - account for adding an lru page and return lru=
vec<br>
+ * @zone: zone of the page<br>
+ * @page: the page itself<br>
+ * @lru: target lru list<br>
+ *<br>
+ * This function must be called when a page is to be added to an lru<br>
+ * list.<br>
+ *<br>
+ * Returns the lruvec to hold @page, the callsite is responsible for<br>
+ * physically linking the page to &amp;lruvec-&gt;lists[@lru].<br>
+ */<br>
+struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *pag=
e,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0enum lru_list lru)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;<br>
 =A0 =A0 =A0 =A0struct page_cgroup *pc;<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem;<br>
<br>
- =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(z=
one));<br>
- =A0 =A0 =A0 pc =3D list_entry(mz-&gt;lists[lru].prev, struct page_cgroup,=
 lru);<br>
- =A0 =A0 =A0 return lookup_cgroup_page(pc);<br>
+ =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &amp;zone-&gt;lruvec;<br>
+<br>
+ =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
+ =A0 =A0 =A0 VM_BUG_ON(PageCgroupAcctLRU(pc));<br>
+ =A0 =A0 =A0 if (PageCgroupUsed(pc)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Ensure pc-&gt;mem_cgroup is visible after =
reading PCG_USED. */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_rmb();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D pc-&gt;mem_cgroup;<br>
+ =A0 =A0 =A0 } else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the page is no longer charged, add it=
 to the<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* root memcg&#39;s lru. =A0Either it will =
be freed soon, or<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it will get charged again and the charge=
r will<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* relink it to the right list.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D root_mem_cgroup;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(mem, page);<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* We do not account for uncharged pages: they are linked t=
o<br>
+ =A0 =A0 =A0 =A0* root_mem_cgroup but when the page is unlinked upon free,=
<br>
+ =A0 =A0 =A0 =A0* accounting would be done against pc-&gt;mem_cgroup.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 if (PageCgroupUsed(pc)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Huge page splitting is serialized throug=
h the lru<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* lock, so compound_order() is stable here=
.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) +=3D 1 &lt;&lt; com=
pound_order(page);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageCgroupAcctLRU(pc);<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 return &amp;mz-&gt;lruvec;<br>
=A0}<br>
<br>
-void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)<br>
+/**<br>
+ * mem_cgroup_lru_del_list - account for removing an lru page<br>
+ * @page: page to unlink<br>
+ * @lru: lru list the page is sitting on<br>
+ *<br>
+ * This function must be called when a page is to be removed from an<br>
+ * lru list.<br>
+ *<br>
+ * The callsite is responsible for physically unlinking &amp;@page-&gt;lru=
.<br>
+ */<br>
+void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)<br>
=A0{<br>
- =A0 =A0 =A0 struct page_cgroup *pc;<br>
 =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;<br>
+ =A0 =A0 =A0 struct page_cgroup *pc;<br>
<br>
 =A0 =A0 =A0 =A0if (mem_cgroup_disabled())<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
@@ -686,75 +756,35 @@ void mem_cgroup_del_lru_list(struct page *page, enum =
lru_list lru)<br>
 =A0 =A0 =A0 =A0mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
 =A0 =A0 =A0 =A0/* huge page split is done under lru_lock. so, we have no r=
aces. */<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 &lt;&lt; compound_order(pa=
ge);<br>
- =A0 =A0 =A0 VM_BUG_ON(list_empty(&amp;pc-&gt;lru));<br>
- =A0 =A0 =A0 list_del_init(&amp;pc-&gt;lru);<br>
=A0}<br>
<br>
-void mem_cgroup_del_lru(struct page *page)<br>
+void mem_cgroup_lru_del(struct page *page)<br>
=A0{<br>
- =A0 =A0 =A0 mem_cgroup_del_lru_list(page, page_lru(page));<br>
+ =A0 =A0 =A0 mem_cgroup_lru_del_list(page, page_lru(page));<br>
=A0}<br>
<br>
-/*<br>
- * Writeback is about to end against a page which has been marked for imme=
diate<br>
- * reclaim. =A0If it still appears to be reclaimable, move it to the tail =
of the<br>
- * inactive list.<br>
+/**<br>
+ * mem_cgroup_lru_move_lists - account for moving a page between lru lists=
<br>
+ * @zone: zone of the page<br>
+ * @page: page to move<br>
+ * @from: current lru list<br>
+ * @to: new lru list<br>
+ *<br>
+ * This function must be called when a page is moved between lru<br>
+ * lists, or rotated on the same lru list.<br>
+ *<br>
+ * Returns the lruvec to hold @page in the future, the callsite is<br>
+ * responsible for physically relinking the page to<br>
+ * &amp;lruvec-&gt;lists[@to].<br>
 =A0*/<br>
-void mem_cgroup_rotate_reclaimable_page(struct page *page)<br>
-{<br>
- =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
- =A0 =A0 =A0 struct page_cgroup *pc;<br>
- =A0 =A0 =A0 enum lru_list lru =3D page_lru(page);<br>
-<br>
- =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
-<br>
- =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
- =A0 =A0 =A0 /* unused page is not rotated. */<br>
- =A0 =A0 =A0 if (!PageCgroupUsed(pc))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
- =A0 =A0 =A0 /* Ensure pc-&gt;mem_cgroup is visible after reading PCG_USED=
. */<br>
- =A0 =A0 =A0 smp_rmb();<br>
- =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
- =A0 =A0 =A0 list_move_tail(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
-}<br>
-<br>
-void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)<br>
+struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct page *page,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0enum lru_list from,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0enum lru_list to)<br>
=A0{<br>
- =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
- =A0 =A0 =A0 struct page_cgroup *pc;<br>
-<br>
- =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
-<br>
- =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
- =A0 =A0 =A0 /* unused page is not rotated. */<br>
- =A0 =A0 =A0 if (!PageCgroupUsed(pc))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
- =A0 =A0 =A0 /* Ensure pc-&gt;mem_cgroup is visible after reading PCG_USED=
. */<br>
- =A0 =A0 =A0 smp_rmb();<br>
- =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
- =A0 =A0 =A0 list_move(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
-}<br>
-<br>
-void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)<br>
-{<br>
- =A0 =A0 =A0 struct page_cgroup *pc;<br>
- =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
-<br>
- =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
- =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
- =A0 =A0 =A0 VM_BUG_ON(PageCgroupAcctLRU(pc));<br>
- =A0 =A0 =A0 if (!PageCgroupUsed(pc))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
- =A0 =A0 =A0 /* Ensure pc-&gt;mem_cgroup is visible after reading PCG_USED=
. */<br>
- =A0 =A0 =A0 smp_rmb();<br>
- =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
- =A0 =A0 =A0 /* huge page split is done under lru_lock. so, we have no rac=
es. */<br>
- =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) +=3D 1 &lt;&lt; compound_order(page=
);<br>
- =A0 =A0 =A0 SetPageCgroupAcctLRU(pc);<br>
- =A0 =A0 =A0 list_add(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
+ =A0 =A0 =A0 /* TODO: this could be optimized, especially if from =3D=3D t=
o */<br>
+ =A0 =A0 =A0 mem_cgroup_lru_del_list(page, from);<br>
+ =A0 =A0 =A0 return mem_cgroup_lru_add_list(zone, page, to);<br>
=A0}<br>
<br>
=A0/*<br>
@@ -786,7 +816,7 @@ static void mem_cgroup_lru_del_before_commit(struct pag=
e *page)<br>
 =A0 =A0 =A0 =A0 * is guarded by lock_page() because the page is SwapCache.=
<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru_list(page, page_lru(page))=
;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_from_lru(zone, page);<br>
 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&amp;zone-&gt;lru_lock, flags);<br>
=A0}<br>
<br>
@@ -800,22 +830,11 @@ static void mem_cgroup_lru_add_after_commit(struct pa=
ge *page)<br>
 =A0 =A0 =A0 =A0if (likely(!PageLRU(page)))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
 =A0 =A0 =A0 =A0spin_lock_irqsave(&amp;zone-&gt;lru_lock, flags);<br>
- =A0 =A0 =A0 /* link when the page is linked to LRU but page_cgroup isn&#3=
9;t */<br>
 =A0 =A0 =A0 =A0if (PageLRU(page) &amp;&amp; !PageCgroupAcctLRU(pc))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_add_lru_list(page, page_lru(page))=
;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_page_to_lru_list(zone, page, page_lru(pag=
e));<br>
 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&amp;zone-&gt;lru_lock, flags);<br>
=A0}<br>
<br>
-<br>
-void mem_cgroup_move_lists(struct page *page,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list from, en=
um lru_list to)<br>
-{<br>
- =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
- =A0 =A0 =A0 mem_cgroup_del_lru_list(page, from);<br>
- =A0 =A0 =A0 mem_cgroup_add_lru_list(page, to);<br>
-}<br>
-<br>
=A0int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup=
 *mem)<br>
=A0{<br>
 =A0 =A0 =A0 =A0int ret;<br>
@@ -935,67 +954,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *pag=
e)<br>
 =A0 =A0 =A0 =A0return &amp;mz-&gt;reclaim_stat;<br>
=A0}<br>
<br>
-unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct list_head *dst,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long *scanned, int order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int mode, struct zone *z,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct mem_cgroup *mem_cont,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int active, int file)<br>
-{<br>
- =A0 =A0 =A0 unsigned long nr_taken =3D 0;<br>
- =A0 =A0 =A0 struct page *page;<br>
- =A0 =A0 =A0 unsigned long scan;<br>
- =A0 =A0 =A0 LIST_HEAD(pc_list);<br>
- =A0 =A0 =A0 struct list_head *src;<br>
- =A0 =A0 =A0 struct page_cgroup *pc, *tmp;<br>
- =A0 =A0 =A0 int nid =3D zone_to_nid(z);<br>
- =A0 =A0 =A0 int zid =3D zone_idx(z);<br>
- =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
- =A0 =A0 =A0 int lru =3D LRU_FILE * file + active;<br>
- =A0 =A0 =A0 int ret;<br>
-<br>
- =A0 =A0 =A0 BUG_ON(!mem_cont);<br>
- =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem_cont, nid, zid);<br>
- =A0 =A0 =A0 src =3D &amp;mz-&gt;lists[lru];<br>
-<br>
- =A0 =A0 =A0 scan =3D 0;<br>
- =A0 =A0 =A0 list_for_each_entry_safe_reverse(pc, tmp, src, lru) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scan &gt;=3D nr_to_scan)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!PageCgroupUsed(pc)))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lookup_cgroup_page(pc);<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!PageLRU(page)))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan++;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __isolate_lru_page(page, mode, file);=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (ret) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 0:<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, =
dst);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru(page);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken +=3D hpage_nr_pages(=
page);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 case -EBUSY:<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we don&#39;t affect global=
 LRU but rotate in our LRU */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_lru_list(pa=
ge, page_lru(page));<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
- =A0 =A0 =A0 }<br>
-<br>
- =A0 =A0 =A0 *scanned =3D scan;<br>
-<br>
- =A0 =A0 =A0 trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,<=
br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0=
, 0, 0, mode);<br>
-<br>
- =A0 =A0 =A0 return nr_taken;<br>
-}<br>
-<br>
=A0#define mem_cgroup_from_res_counter(counter, member) =A0 \<br>
 =A0 =A0 =A0 =A0container_of(counter, struct mem_cgroup, member)<br>
<br>
@@ -3110,22 +3068,23 @@ static int mem_cgroup_resize_memsw_limit(struct mem=
_cgroup *memcg,<br>
=A0static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int node, i=
nt zid, enum lru_list lru)<br>
=A0{<br>
- =A0 =A0 =A0 struct zone *zone;<br>
 =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;<br>
- =A0 =A0 =A0 struct page_cgroup *pc, *busy;<br>
 =A0 =A0 =A0 =A0unsigned long flags, loop;<br>
 =A0 =A0 =A0 =A0struct list_head *list;<br>
+ =A0 =A0 =A0 struct page *busy;<br>
+ =A0 =A0 =A0 struct zone *zone;<br>
 =A0 =A0 =A0 =A0int ret =3D 0;<br>
<br>
 =A0 =A0 =A0 =A0zone =3D &amp;NODE_DATA(node)-&gt;node_zones[zid];<br>
 =A0 =A0 =A0 =A0mz =3D mem_cgroup_zoneinfo(mem, node, zid);<br>
- =A0 =A0 =A0 list =3D &amp;mz-&gt;lists[lru];<br>
+ =A0 =A0 =A0 list =3D &amp;mz-&gt;lruvec.lists[lru];<br>
<br>
 =A0 =A0 =A0 =A0loop =3D MEM_CGROUP_ZSTAT(mz, lru);<br>
 =A0 =A0 =A0 =A0/* give some margin against EBUSY etc...*/<br>
 =A0 =A0 =A0 =A0loop +=3D 256;<br>
 =A0 =A0 =A0 =A0busy =3D NULL;<br>
 =A0 =A0 =A0 =A0while (loop--) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page_cgroup *pc;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D 0;<br>
@@ -3134,16 +3093,16 @@ static int mem_cgroup_force_empty_list(struct mem_c=
group *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&amp=
;zone-&gt;lru_lock, flags);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc =3D list_entry(list-&gt;prev, struct page_=
cgroup, lru);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (busy =3D=3D pc) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;pc-&gt;lru, li=
st);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D list_entry(list-&gt;prev, struct pag=
e, lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (busy =3D=3D page) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, =
list);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0busy =3D NULL;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&amp=
;zone-&gt;lru_lock, flags);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&amp;zone-&gt;lru_lo=
ck, flags);<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lookup_cgroup_page(pc);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_move_parent(page, pc, me=
m, GFP_KERNEL);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret =3D=3D -ENOMEM)<br>
@@ -3151,7 +3110,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgr=
oup *mem,<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret =3D=3D -EBUSY || ret =3D=3D -EINVAL=
) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* found lock contention or=
 &quot;pc&quot; is obsolete. */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 busy =3D pc;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 busy =3D page;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cond_resched();<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0busy =3D NULL;<br>
@@ -4171,7 +4130,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_=
cgroup *mem, int node)<br>
 =A0 =A0 =A0 =A0for (zone =3D 0; zone &lt; MAX_NR_ZONES; zone++) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz =3D &amp;pn-&gt;zoneinfo[zone];<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_lru(l)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&amp;mz-&gt;li=
sts[l]);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&amp;mz-&gt;lr=
uvec.lists[l]);<br>
 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0return 0;<br>
=A0}<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index 3f8bce2..9da238d 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -4289,7 +4289,7 @@ static void __paginginit free_area_init_core(struct p=
glist_data *pgdat,<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone_pcp_init(zone);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_lru(l) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&amp;zone-&gt;=
lru[l].list);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&amp;zone-&gt;=
lruvec.lists[l]);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone-&gt;reclaim_stat.nr_sa=
ved_scan[l] =3D 0;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone-&gt;reclaim_stat.recent_rotated[0] =3D=
 0;<br>
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c<br>
index 2daadc3..916c6f9 100644<br>
--- a/mm/page_cgroup.c<br>
+++ b/mm/page_cgroup.c<br>
@@ -11,12 +11,10 @@<br>
=A0#include &lt;linux/swapops.h&gt;<br>
=A0#include &lt;linux/kmemleak.h&gt;<br>
<br>
-static void __meminit init_page_cgroup(struct page_cgroup *pc, unsigned lo=
ng id)<br>
+static void __meminit init_page_cgroup(struct page_cgroup *pc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0pc-&gt;flags =3D 0;<br>
- =A0 =A0 =A0 set_page_cgroup_array_id(pc, id);<br>
 =A0 =A0 =A0 =A0pc-&gt;mem_cgroup =3D NULL;<br>
- =A0 =A0 =A0 INIT_LIST_HEAD(&amp;pc-&gt;lru);<br>
=A0}<br>
=A0static unsigned long total_usage;<br>
<br>
@@ -42,19 +40,6 @@ struct page_cgroup *lookup_page_cgroup(struct page *page=
)<br>
 =A0 =A0 =A0 =A0return base + offset;<br>
=A0}<br>
<br>
-struct page *lookup_cgroup_page(struct page_cgroup *pc)<br>
-{<br>
- =A0 =A0 =A0 unsigned long pfn;<br>
- =A0 =A0 =A0 struct page *page;<br>
- =A0 =A0 =A0 pg_data_t *pgdat;<br>
-<br>
- =A0 =A0 =A0 pgdat =3D NODE_DATA(page_cgroup_array_id(pc));<br>
- =A0 =A0 =A0 pfn =3D pc - pgdat-&gt;node_page_cgroup + pgdat-&gt;node_star=
t_pfn;<br>
- =A0 =A0 =A0 page =3D pfn_to_page(pfn);<br>
- =A0 =A0 =A0 VM_BUG_ON(pc !=3D lookup_page_cgroup(page));<br>
- =A0 =A0 =A0 return page;<br>
-}<br>
-<br>
=A0static int __init alloc_node_page_cgroup(int nid)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct page_cgroup *base, *pc;<br>
@@ -75,7 +60,7 @@ static int __init alloc_node_page_cgroup(int nid)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;<br>
 =A0 =A0 =A0 =A0for (index =3D 0; index &lt; nr_pages; index++) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D base + index;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_page_cgroup(pc, nid);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_page_cgroup(pc);<br>
 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0NODE_DATA(nid)-&gt;node_page_cgroup =3D base;<br>
 =A0 =A0 =A0 =A0total_usage +=3D table_size;<br>
@@ -117,19 +102,6 @@ struct page_cgroup *lookup_page_cgroup(struct page *pa=
ge)<br>
 =A0 =A0 =A0 =A0return section-&gt;page_cgroup + pfn;<br>
=A0}<br>
<br>
-struct page *lookup_cgroup_page(struct page_cgroup *pc)<br>
-{<br>
- =A0 =A0 =A0 struct mem_section *section;<br>
- =A0 =A0 =A0 struct page *page;<br>
- =A0 =A0 =A0 unsigned long nr;<br>
-<br>
- =A0 =A0 =A0 nr =3D page_cgroup_array_id(pc);<br>
- =A0 =A0 =A0 section =3D __nr_to_section(nr);<br>
- =A0 =A0 =A0 page =3D pfn_to_page(pc - section-&gt;page_cgroup);<br>
- =A0 =A0 =A0 VM_BUG_ON(pc !=3D lookup_page_cgroup(page));<br>
- =A0 =A0 =A0 return page;<br>
-}<br>
-<br>
=A0static void *__init_refok alloc_page_cgroup(size_t size, int nid)<br>
=A0{<br>
 =A0 =A0 =A0 =A0void *addr =3D NULL;<br>
@@ -167,11 +139,9 @@ static int __init_refok init_section_page_cgroup(unsig=
ned long pfn)<br>
 =A0 =A0 =A0 =A0struct page_cgroup *base, *pc;<br>
 =A0 =A0 =A0 =A0struct mem_section *section;<br>
 =A0 =A0 =A0 =A0unsigned long table_size;<br>
- =A0 =A0 =A0 unsigned long nr;<br>
 =A0 =A0 =A0 =A0int nid, index;<br>
<br>
- =A0 =A0 =A0 nr =3D pfn_to_section_nr(pfn);<br>
- =A0 =A0 =A0 section =3D __nr_to_section(nr);<br>
+ =A0 =A0 =A0 section =3D __pfn_to_section(pfn);<br>
<br>
 =A0 =A0 =A0 =A0if (section-&gt;page_cgroup)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;<br>
@@ -194,7 +164,7 @@ static int __init_refok init_section_page_cgroup(unsign=
ed long pfn)<br>
<br>
 =A0 =A0 =A0 =A0for (index =3D 0; index &lt; PAGES_PER_SECTION; index++) {<=
br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D base + index;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_page_cgroup(pc, nr);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_page_cgroup(pc);<br>
 =A0 =A0 =A0 =A0}<br>
<br>
 =A0 =A0 =A0 =A0section-&gt;page_cgroup =3D base - pfn;<br>
diff --git a/mm/swap.c b/mm/swap.c<br>
index 5602f1a..0a5a93b 100644<br>
--- a/mm/swap.c<br>
+++ b/mm/swap.c<br>
@@ -209,12 +209,14 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,=
<br>
=A0static void pagevec_move_tail_fn(struct page *page, void *arg)<br>
=A0{<br>
 =A0 =A0 =A0 =A0int *pgmoved =3D arg;<br>
- =A0 =A0 =A0 struct zone *zone =3D page_zone(page);<br>
<br>
 =A0 =A0 =A0 =A0if (PageLRU(page) &amp;&amp; !PageActive(page) &amp;&amp; !=
PageUnevictable(page)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list lru =3D page_lru_base_type(pa=
ge);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&amp;page-&gt;lru, &amp;zone-&=
gt;lru[lru].list);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_reclaimable_page(page);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_move_lists(page_zon=
e(page),<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0page, lru, lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&amp;page-&gt;lru, &amp;lruvec=
-&gt;lists[lru]);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*pgmoved)++;<br>
 =A0 =A0 =A0 =A0}<br>
=A0}<br>
@@ -420,12 +422,13 @@ static void lru_deactivate_fn(struct page *page, void=
 *arg)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageReclaim(page);<br>
 =A0 =A0 =A0 =A0} else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * The page&#39;s writeback ends up during =
pagevec<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We moves tha page into tail of inactive.=
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&amp;page-&gt;lru, &amp;zone-&=
gt;lru[lru].list);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_reclaimable_page(page);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_move_lists(zone, pa=
ge, lru, lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&amp;page-&gt;lru, &amp;lruvec=
-&gt;lists[lru]);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_event(PGROTATED);<br>
 =A0 =A0 =A0 =A0}<br>
<br>
@@ -597,7 +600,6 @@ void lru_add_page_tail(struct zone* zone,<br>
 =A0 =A0 =A0 =A0int active;<br>
 =A0 =A0 =A0 =A0enum lru_list lru;<br>
 =A0 =A0 =A0 =A0const int file =3D 0;<br>
- =A0 =A0 =A0 struct list_head *head;<br>
<br>
 =A0 =A0 =A0 =A0VM_BUG_ON(!PageHead(page));<br>
 =A0 =A0 =A0 =A0VM_BUG_ON(PageCompound(page_tail));<br>
@@ -617,10 +619,10 @@ void lru_add_page_tail(struct zone* zone,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0update_page_reclaim_stat(zone, page_tail, f=
ile, active);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (likely(PageLRU(page)))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D page-&gt;lru.prev;<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __add_page_to_lru_list(zone, =
page_tail, lru,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0page-&gt;lru.prev);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D &amp;zone-&gt;lru[lr=
u].list;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 __add_page_to_lru_list(zone, page_tail, lru, =
head);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_page_to_lru_list(zone, pa=
ge_tail, lru);<br>
 =A0 =A0 =A0 =A0} else {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageUnevictable(page_tail);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_page_to_lru_list(zone, page_tail, LRU_U=
NEVICTABLE);<br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
index 23fd2b1..87e1fcb 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -1080,15 +1080,14 @@ static unsigned long isolate_lru_pages(unsigned lon=
g nr_to_scan,<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (__isolate_lru_page(page, mode, file=
)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 0:<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_lru_del(page);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&amp;page-&gt;lru=
, dst);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru(page);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken +=3D hpage_nr_page=
s(page);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case -EBUSY:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* else it is being freed e=
lsewhere */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&amp;page-&gt;lru=
, src);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_lru_list(pa=
ge, page_lru(page));<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:<br>
@@ -1138,8 +1137,8 @@ static unsigned long isolate_lru_pages(unsigned long =
nr_to_scan,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (__isolate_lru_page(curs=
or_page, mode, file) =3D=3D 0) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_lr=
u_del(cursor_page);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&=
amp;cursor_page-&gt;lru, dst);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_de=
l_lru(cursor_page);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken +=
=3D hpage_nr_pages(page);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_lumpy_ta=
ken++;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PageDir=
ty(cursor_page))<br>
@@ -1168,19 +1167,22 @@ static unsigned long isolate_lru_pages(unsigned lon=
g nr_to_scan,<br>
 =A0 =A0 =A0 =A0return nr_taken;<br>
=A0}<br>
<br>
-static unsigned long isolate_pages_global(unsigned long nr,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct list_head *dst,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long *scanned, int order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int mode, struct zone *z,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int active, int file)<br>
+static unsigned long isolate_pages(unsigned long nr,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 list_head *dst,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsign=
ed long *scanned, int order,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int mo=
de, struct zone *z,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int ac=
tive, int file,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 mem_cgroup *mem)<br>
=A0{<br>
+ =A0 =A0 =A0 struct lruvec *lruvec =3D mem_cgroup_zone_lruvec(z, mem);<br>
 =A0 =A0 =A0 =A0int lru =3D LRU_BASE;<br>
+<br>
 =A0 =A0 =A0 =A0if (active)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru +=3D LRU_ACTIVE;<br>
 =A0 =A0 =A0 =A0if (file)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru +=3D LRU_FILE;<br>
- =A0 =A0 =A0 return isolate_lru_pages(nr, &amp;z-&gt;lru[lru].list, dst, s=
canned, order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mode, file);<br>
+ =A0 =A0 =A0 return isolate_lru_pages(nr, &amp;lruvec-&gt;lists[lru], dst,=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scanned, o=
rder, mode, file);<br>
=A0}<br>
<br>
=A0/*<br>
@@ -1428,20 +1430,11 @@ shrink_inactive_list(unsigned long nr_to_scan, stru=
ct zone *zone,<br>
 =A0 =A0 =A0 =A0lru_add_drain();<br>
 =A0 =A0 =A0 =A0spin_lock_irq(&amp;zone-&gt;lru_lock);<br>
<br>
- =A0 =A0 =A0 if (scanning_global_lru(sc)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D isolate_pages_global(nr_to_scan,=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;page_list, &amp;nr_scann=
ed, sc-&gt;order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;reclaim_mode &amp; REC=
LAIM_MODE_LUMPYRECLAIM ?<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 ISOLATE_BOTH : ISOLATE_INACTIVE,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, 0, file);<br>
- =A0 =A0 =A0 } else {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D mem_cgroup_isolate_pages(nr_to_s=
can,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;page_list, &amp;nr_scann=
ed, sc-&gt;order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;reclaim_mode &amp; REC=
LAIM_MODE_LUMPYRECLAIM ?<br>
+ =A0 =A0 =A0 nr_taken =3D isolate_pages(nr_to_scan,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&amp;page_=
list, &amp;nr_scanned, sc-&gt;order,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc-&gt;rec=
laim_mode &amp; RECLAIM_MODE_LUMPYRECLAIM ?<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0ISOLATE_BOTH : ISOLATE_INACTIVE,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, sc-&gt;mem_cgroup,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, file);<br>
- =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, 0, f=
ile, sc-&gt;mem_cgroup);<br>
<br>
 =A0 =A0 =A0 =A0if (global_reclaim(sc)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone-&gt;pages_scanned +=3D nr_scanned;<br>
@@ -1514,13 +1507,15 @@ static void move_active_pages_to_lru(struct zone *z=
one,<br>
 =A0 =A0 =A0 =A0pagevec_init(&amp;pvec, 1);<br>
<br>
 =A0 =A0 =A0 =A0while (!list_empty(list)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec;<br>
+<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D lru_to_page(list);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0VM_BUG_ON(PageLRU(page));<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageLRU(page);<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, &amp;zone-&gt;lr=
u[lru].list);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_add_lru_list(page, lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_add_list(zone, page=
, lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, &amp;lruvec-&gt;=
lists[lru]);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgmoved +=3D hpage_nr_pages(page);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!pagevec_add(&amp;pvec, page) || list_e=
mpty(list)) {<br>
@@ -1551,17 +1546,10 @@ static void shrink_active_list(unsigned long nr_pag=
es, struct zone *zone,<br>
<br>
 =A0 =A0 =A0 =A0lru_add_drain();<br>
 =A0 =A0 =A0 =A0spin_lock_irq(&amp;zone-&gt;lru_lock);<br>
- =A0 =A0 =A0 if (scanning_global_lru(sc)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D isolate_pages_global(nr_pages, &=
amp;l_hold,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 &amp;pgscanned, sc-&gt;order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 ISOLATE_ACTIVE, zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1, file);<br>
- =A0 =A0 =A0 } else {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D mem_cgroup_isolate_pages(nr_page=
s, &amp;l_hold,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 &amp;pgscanned, sc-&gt;order,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 ISOLATE_ACTIVE, zone,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 sc-&gt;mem_cgroup, 1, file);<br>
- =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 nr_taken =3D isolate_pages(nr_pages, &amp;l_hold,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&amp;pgsca=
nned, sc-&gt;order,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ISOLATE_AC=
TIVE, zone,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01, file, s=
c-&gt;mem_cgroup);<br>
<br>
 =A0 =A0 =A0 =A0if (global_reclaim(sc))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone-&gt;pages_scanned +=3D pgscanned;<br>
@@ -3154,16 +3142,18 @@ int page_evictable(struct page *page, struct vm_are=
a_struct *vma)<br>
 =A0*/<br>
=A0static void check_move_unevictable_page(struct page *page, struct zone *=
zone)<br>
=A0{<br>
- =A0 =A0 =A0 VM_BUG_ON(PageActive(page));<br>
+ =A0 =A0 =A0 struct lruvec *lruvec;<br>
<br>
+ =A0 =A0 =A0 VM_BUG_ON(PageActive(page));<br>
=A0retry:<br>
 =A0 =A0 =A0 =A0ClearPageUnevictable(page);<br>
 =A0 =A0 =A0 =A0if (page_evictable(page, NULL)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list l =3D page_lru_base_type(page=
);<br>
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_move_lists(zone, pa=
ge,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0LRU_UNEVICTABLE, l);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__dec_zone_state(zone, NR_UNEVICTABLE);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, &amp;zone-&gt;lr=
u[l].list);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_move_lists(page, LRU_UNEVICTABLE, =
l);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, &amp;lruvec-&gt;=
lists[l]);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__inc_zone_state(zone, NR_INACTIVE_ANON + l=
);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_event(UNEVICTABLE_PGRESCUED);<br=
>
 =A0 =A0 =A0 =A0} else {<br>
@@ -3171,8 +3161,9 @@ retry:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * rotate unevictable list<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageUnevictable(page);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, &amp;zone-&gt;lr=
u[LRU_UNEVICTABLE].list);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_lru_list(page, LRU_UNEVICTA=
BLE);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_move_lists(zone, pa=
ge, LRU_UNEVICTABLE,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0LRU_UNEVICTABLE);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, &amp;lruvec-&gt;=
lists[LRU_UNEVICTABLE]);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (page_evictable(page, NULL))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto retry;<br>
 =A0 =A0 =A0 =A0}<br>
@@ -3233,14 +3224,6 @@ void scan_mapping_unevictable_pages(struct address_s=
pace *mapping)<br>
<br>
=A0}<br>
<br>
-static struct page *lru_tailpage(struct zone *zone, struct mem_cgroup *mem=
,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_l=
ist lru)<br>
-{<br>
- =A0 =A0 =A0 if (mem)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return mem_cgroup_lru_to_page(zone, mem, lru)=
;<br>
- =A0 =A0 =A0 return lru_to_page(&amp;zone-&gt;lru[lru].list);<br>
-}<br>
-<br>
=A0/**<br>
 =A0* scan_zone_unevictable_pages - check unevictable list for evictable pa=
ges<br>
 =A0* @zone - zone of which to scan the unevictable list<br>
@@ -3259,8 +3242,13 @@ static void scan_zone_unevictable_pages(struct zone =
*zone)<br>
 =A0 =A0 =A0 =A0first =3D mem =3D mem_cgroup_hierarchy_walk(NULL, mem);<br>
 =A0 =A0 =A0 =A0do {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_to_scan;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *list;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_to_scan =3D zone_nr_lru_pages(zone, mem,=
 LRU_UNEVICTABLE);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_zone_lruvec(zone, mem);=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list =3D &amp;lruvec-&gt;lists[LRU_UNEVICTABL=
E];<br>
+<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (nr_to_scan &gt; 0) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long batch_size;<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long scan;<br>
@@ -3272,7 +3260,7 @@ static void scan_zone_unevictable_pages(struct zone *=
zone)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (scan =3D 0; scan &lt; =
batch_size; scan++) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page=
 *page;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lru_=
tailpage(zone, mem, LRU_UNEVICTABLE);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lru_=
to_page(list);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!tryloc=
k_page(page))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0continue;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (likely(=
PageLRU(page) &amp;&amp;<br>
<font color=3D"#888888">--<br>
1.7.5.2<br>
<br></font></blockquote><div>Johannes,=A0I wonder if we should include the =
following patch:</div><div><br></div><div><div>diff --git a/mm/memcontrol.c=
 b/mm/memcontrol.c</div><div>index 674823e..1513deb 100644</div><div>--- a/=
mm/memcontrol.c</div>
<div>+++ b/mm/memcontrol.c</div><div>@@ -832,7 +832,7 @@ static void mem_cg=
roup_lru_del_before_commit_swapcache(struct page *page)</div><div>=A0 =A0 =
=A0 =A0 =A0* Forget old LRU when this page_cgroup is *not* used. This Used =
bit</div>
<div>=A0 =A0 =A0 =A0 =A0* is guarded by lock_page() because the page is Swa=
pCache.</div><div>=A0 =A0 =A0 =A0 =A0*/</div><div>- =A0 =A0 =A0 if (!PageCg=
roupUsed(pc))</div><div>+ =A0 =A0 =A0 if (PageLRU(page) &amp;&amp; !PageCgr=
oupUsed(pc))</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_from_lru(zo=
ne, page);</div>
<div>=A0 =A0 =A0 =A0 spin_unlock_irqrestore(&amp;zone-&gt;lru_lock, flags);=
</div><div>=A0}</div></div><div><br></div><div>--Ying</div><div><br></div><=
/div><br>

--001636b4315f39a8a304aa40b4ab--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
