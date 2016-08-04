Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CDE56B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 16:59:21 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i27so435751373qte.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 13:59:21 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id 194si1735585ybc.282.2016.08.04.13.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 13:59:19 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id r9so20820859ywg.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 13:59:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-4-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net> <1467970510-21195-4-git-send-email-mgorman@techsingularity.net>
From: James Hogan <james.hogan@imgtec.com>
Date: Thu, 4 Aug 2016 21:59:17 +0100
Message-ID: <CAAG0J9_k3edxDzqpEjt2BqqZXMW4PVj7BNUBAk6TWtw3Zh_oMg@mail.gmail.com>
Subject: Re: [PATCH 03/34] mm, vmscan: move LRU lists to node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, metag <linux-metag@vger.kernel.org>

On 8 July 2016 at 10:34, Mel Gorman <mgorman@techsingularity.net> wrote:
> This moves the LRU lists from the zone to the node and related data
> such as counters, tracing, congestion tracking and writeback tracking.
> Unfortunately, due to reclaim and compaction retry logic, it is necessary
> to account for the number of LRU pages on both zone and node logic.
> Most reclaim logic is based on the node counters but the retry logic uses
> the zone counters which do not distinguish inactive and active sizes.
> It would be possible to leave the LRU counters on a per-zone basis but
> it's a heavier calculation across multiple cache lines that is much more
> frequent than the retry checks.
>
> Other than the LRU counters, this is mostly a mechanical patch but note
> that it introduces a number of anomalies.  For example, the scans are
> per-zone but using per-node counters.  We also mark a node as congested
> when a zone is congested.  This causes weird problems that are fixed later
> but is easier to review.
>
> In the event that there is excessive overhead on 32-bit systems due to
> the nodes being on LRU then there are two potential solutions
>
> 1. Long-term isolation of highmem pages when reclaim is lowmem
>
>    When pages are skipped, they are immediately added back onto the LRU
>    list. If lowmem reclaim persisted for long periods of time, the same
>    highmem pages get continually scanned. The idea would be that lowmem
>    keeps those pages on a separate list until a reclaim for highmem pages
>    arrives that splices the highmem pages back onto the LRU. It potentially
>    could be implemented similar to the UNEVICTABLE list.
>
>    That would reduce the skip rate with the potential corner case is that
>    highmem pages have to be scanned and reclaimed to free lowmem slab pages.
>
> 2. Linear scan lowmem pages if the initial LRU shrink fails
>
>    This will break LRU ordering but may be preferable and faster during
>    memory pressure than skipping LRU pages.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

This breaks boot on metag architecture:
Oops: err 0007 (Data access general read/write fault) addr 00233008 [#1]

It appears to be in node_page_state_snapshot() (via
pgdat_reclaimable()), and have come via mm_init. Here's the relevant
bit of the backtrace:

    node_page_state_snapshot@0x4009c884(enum node_stat_item item =
???, struct pglist_data * pgdat = ???) + 0x48
    pgdat_reclaimable(struct pglist_data * pgdat = 0x402517a0)
    show_free_areas(unsigned int filter = 0) + 0x2cc
    show_mem(unsigned int filter = 0) + 0x18
    mm_init@0x4025c3d4()
    start_kernel() + 0x204

__per_cpu_offset[0] == 0x233000 (close to bad addr),
pgdat->per_cpu_nodestats = NULL. and setup_per_cpu_pageset()
definitely hasn't been called yet (mm_init is called before
setup_per_cpu_pageset()).

Any ideas what the correct solution is (and why presumably others
haven't seen the same issue on other architectures?).

Thanks
James

> ---
>  arch/tile/mm/pgtable.c                    |   8 +-
>  drivers/base/node.c                       |  19 +--
>  drivers/staging/android/lowmemorykiller.c |   8 +-
>  include/linux/backing-dev.h               |   2 +-
>  include/linux/memcontrol.h                |  18 +--
>  include/linux/mm_inline.h                 |  21 ++-
>  include/linux/mmzone.h                    |  68 +++++----
>  include/linux/swap.h                      |   1 +
>  include/linux/vm_event_item.h             |  10 +-
>  include/linux/vmstat.h                    |  17 +++
>  include/trace/events/vmscan.h             |  12 +-
>  kernel/power/snapshot.c                   |  10 +-
>  mm/backing-dev.c                          |  15 +-
>  mm/compaction.c                           |  18 +--
>  mm/huge_memory.c                          |   2 +-
>  mm/internal.h                             |   2 +-
>  mm/khugepaged.c                           |   4 +-
>  mm/memcontrol.c                           |  17 +--
>  mm/memory-failure.c                       |   4 +-
>  mm/memory_hotplug.c                       |   2 +-
>  mm/mempolicy.c                            |   2 +-
>  mm/migrate.c                              |  21 +--
>  mm/mlock.c                                |   2 +-
>  mm/page-writeback.c                       |   8 +-
>  mm/page_alloc.c                           |  68 +++++----
>  mm/swap.c                                 |  50 +++----
>  mm/vmscan.c                               | 226 +++++++++++++++++-------------
>  mm/vmstat.c                               |  47 ++++---
>  mm/workingset.c                           |   4 +-
>  29 files changed, 386 insertions(+), 300 deletions(-)
>
> diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
> index c4d5bf841a7f..9e389213580d 100644
> --- a/arch/tile/mm/pgtable.c
> +++ b/arch/tile/mm/pgtable.c
> @@ -45,10 +45,10 @@ void show_mem(unsigned int filter)
>         struct zone *zone;
>
>         pr_err("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
> -              (global_page_state(NR_ACTIVE_ANON) +
> -               global_page_state(NR_ACTIVE_FILE)),
> -              (global_page_state(NR_INACTIVE_ANON) +
> -               global_page_state(NR_INACTIVE_FILE)),
> +              (global_node_page_state(NR_ACTIVE_ANON) +
> +               global_node_page_state(NR_ACTIVE_FILE)),
> +              (global_node_page_state(NR_INACTIVE_ANON) +
> +               global_node_page_state(NR_INACTIVE_FILE)),
>                global_page_state(NR_FILE_DIRTY),
>                global_page_state(NR_WRITEBACK),
>                global_page_state(NR_UNSTABLE_NFS),
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 92d8e090c5b3..b7f01a4a642d 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -56,6 +56,7 @@ static ssize_t node_read_meminfo(struct device *dev,
>  {
>         int n;
>         int nid = dev->id;
> +       struct pglist_data *pgdat = NODE_DATA(nid);
>         struct sysinfo i;
>
>         si_meminfo_node(&i, nid);
> @@ -74,15 +75,15 @@ static ssize_t node_read_meminfo(struct device *dev,
>                        nid, K(i.totalram),
>                        nid, K(i.freeram),
>                        nid, K(i.totalram - i.freeram),
> -                      nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON) +
> -                               sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
> -                      nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON) +
> -                               sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
> -                      nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON)),
> -                      nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON)),
> -                      nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
> -                      nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
> -                      nid, K(sum_zone_node_page_state(nid, NR_UNEVICTABLE)),
> +                      nid, K(node_page_state(pgdat, NR_ACTIVE_ANON) +
> +                               node_page_state(pgdat, NR_ACTIVE_FILE)),
> +                      nid, K(node_page_state(pgdat, NR_INACTIVE_ANON) +
> +                               node_page_state(pgdat, NR_INACTIVE_FILE)),
> +                      nid, K(node_page_state(pgdat, NR_ACTIVE_ANON)),
> +                      nid, K(node_page_state(pgdat, NR_INACTIVE_ANON)),
> +                      nid, K(node_page_state(pgdat, NR_ACTIVE_FILE)),
> +                      nid, K(node_page_state(pgdat, NR_INACTIVE_FILE)),
> +                      nid, K(node_page_state(pgdat, NR_UNEVICTABLE)),
>                        nid, K(sum_zone_node_page_state(nid, NR_MLOCK)));
>
>  #ifdef CONFIG_HIGHMEM
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> index 24d2745e9437..93dbcc38eb0f 100644
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -72,10 +72,10 @@ static unsigned long lowmem_deathpending_timeout;
>  static unsigned long lowmem_count(struct shrinker *s,
>                                   struct shrink_control *sc)
>  {
> -       return global_page_state(NR_ACTIVE_ANON) +
> -               global_page_state(NR_ACTIVE_FILE) +
> -               global_page_state(NR_INACTIVE_ANON) +
> -               global_page_state(NR_INACTIVE_FILE);
> +       return global_node_page_state(NR_ACTIVE_ANON) +
> +               global_node_page_state(NR_ACTIVE_FILE) +
> +               global_node_page_state(NR_INACTIVE_ANON) +
> +               global_node_page_state(NR_INACTIVE_FILE);
>  }
>
>  static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index c82794f20110..491a91717788 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -197,7 +197,7 @@ static inline int wb_congested(struct bdi_writeback *wb, int cong_bits)
>  }
>
>  long congestion_wait(int sync, long timeout);
> -long wait_iff_congested(struct zone *zone, int sync, long timeout);
> +long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout);
>  int pdflush_proc_obsolete(struct ctl_table *table, int write,
>                 void __user *buffer, size_t *lenp, loff_t *ppos);
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 104efa6874db..68f1121c8fe7 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -340,7 +340,7 @@ static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>         struct lruvec *lruvec;
>
>         if (mem_cgroup_disabled()) {
> -               lruvec = &zone->lruvec;
> +               lruvec = zone_lruvec(zone);
>                 goto out;
>         }
>
> @@ -349,15 +349,15 @@ static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>  out:
>         /*
>          * Since a node can be onlined after the mem_cgroup was created,
> -        * we have to be prepared to initialize lruvec->zone here;
> +        * we have to be prepared to initialize lruvec->pgdat here;
>          * and if offlined then reonlined, we need to reinitialize it.
>          */
> -       if (unlikely(lruvec->zone != zone))
> -               lruvec->zone = zone;
> +       if (unlikely(lruvec->pgdat != zone->zone_pgdat))
> +               lruvec->pgdat = zone->zone_pgdat;
>         return lruvec;
>  }
>
> -struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
> +struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
>
>  bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
>  struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> @@ -438,7 +438,7 @@ static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
>  int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
>
>  void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
> -               int nr_pages);
> +               enum zone_type zid, int nr_pages);
>
>  unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
>                                            int nid, unsigned int lru_mask);
> @@ -613,13 +613,13 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
>  static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>                                                     struct mem_cgroup *memcg)
>  {
> -       return &zone->lruvec;
> +       return zone_lruvec(zone);
>  }
>
>  static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
> -                                                   struct zone *zone)
> +                                                   struct pglist_data *pgdat)
>  {
> -       return &zone->lruvec;
> +       return &pgdat->lruvec;
>  }
>
>  static inline bool mm_match_cgroup(struct mm_struct *mm,
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index 5bd29ba4f174..9aadcc781857 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -23,25 +23,32 @@ static inline int page_is_file_cache(struct page *page)
>  }
>
>  static __always_inline void __update_lru_size(struct lruvec *lruvec,
> -                               enum lru_list lru, int nr_pages)
> +                               enum lru_list lru, enum zone_type zid,
> +                               int nr_pages)
>  {
> -       __mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
> +       struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> +
> +       __mod_node_page_state(pgdat, NR_LRU_BASE + lru, nr_pages);
> +       __mod_zone_page_state(&pgdat->node_zones[zid],
> +               NR_ZONE_LRU_BASE + !!is_file_lru(lru),
> +               nr_pages);
>  }
>
>  static __always_inline void update_lru_size(struct lruvec *lruvec,
> -                               enum lru_list lru, int nr_pages)
> +                               enum lru_list lru, enum zone_type zid,
> +                               int nr_pages)
>  {
>  #ifdef CONFIG_MEMCG
> -       mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
> +       mem_cgroup_update_lru_size(lruvec, lru, zid, nr_pages);
>  #else
> -       __update_lru_size(lruvec, lru, nr_pages);
> +       __update_lru_size(lruvec, lru, zid, nr_pages);
>  #endif
>  }
>
>  static __always_inline void add_page_to_lru_list(struct page *page,
>                                 struct lruvec *lruvec, enum lru_list lru)
>  {
> -       update_lru_size(lruvec, lru, hpage_nr_pages(page));
> +       update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
>         list_add(&page->lru, &lruvec->lists[lru]);
>  }
>
> @@ -49,7 +56,7 @@ static __always_inline void del_page_from_lru_list(struct page *page,
>                                 struct lruvec *lruvec, enum lru_list lru)
>  {
>         list_del(&page->lru);
> -       update_lru_size(lruvec, lru, -hpage_nr_pages(page));
> +       update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
>  }
>
>  /**
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index cfa870107abe..d4f5cac0a8c3 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -111,12 +111,9 @@ enum zone_stat_item {
>         /* First 128 byte cacheline (assuming 64 bit words) */
>         NR_FREE_PAGES,
>         NR_ALLOC_BATCH,
> -       NR_LRU_BASE,
> -       NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
> -       NR_ACTIVE_ANON,         /*  "     "     "   "       "         */
> -       NR_INACTIVE_FILE,       /*  "     "     "   "       "         */
> -       NR_ACTIVE_FILE,         /*  "     "     "   "       "         */
> -       NR_UNEVICTABLE,         /*  "     "     "   "       "         */
> +       NR_ZONE_LRU_BASE, /* Used only for compaction and reclaim retry */
> +       NR_ZONE_LRU_ANON = NR_ZONE_LRU_BASE,
> +       NR_ZONE_LRU_FILE,
>         NR_MLOCK,               /* mlock()ed pages found and moved off LRU */
>         NR_ANON_PAGES,  /* Mapped anonymous pages */
>         NR_FILE_MAPPED, /* pagecache pages mapped into pagetables.
> @@ -134,12 +131,9 @@ enum zone_stat_item {
>         NR_VMSCAN_WRITE,
>         NR_VMSCAN_IMMEDIATE,    /* Prioritise for reclaim when writeback ends */
>         NR_WRITEBACK_TEMP,      /* Writeback using temporary buffers */
> -       NR_ISOLATED_ANON,       /* Temporary isolated pages from anon lru */
> -       NR_ISOLATED_FILE,       /* Temporary isolated pages from file lru */
>         NR_SHMEM,               /* shmem pages (included tmpfs/GEM pages) */
>         NR_DIRTIED,             /* page dirtyings since bootup */
>         NR_WRITTEN,             /* page writings since bootup */
> -       NR_PAGES_SCANNED,       /* pages scanned since last reclaim */
>  #if IS_ENABLED(CONFIG_ZSMALLOC)
>         NR_ZSPAGES,             /* allocated in zsmalloc */
>  #endif
> @@ -161,6 +155,15 @@ enum zone_stat_item {
>         NR_VM_ZONE_STAT_ITEMS };
>
>  enum node_stat_item {
> +       NR_LRU_BASE,
> +       NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
> +       NR_ACTIVE_ANON,         /*  "     "     "   "       "         */
> +       NR_INACTIVE_FILE,       /*  "     "     "   "       "         */
> +       NR_ACTIVE_FILE,         /*  "     "     "   "       "         */
> +       NR_UNEVICTABLE,         /*  "     "     "   "       "         */
> +       NR_ISOLATED_ANON,       /* Temporary isolated pages from anon lru */
> +       NR_ISOLATED_FILE,       /* Temporary isolated pages from file lru */
> +       NR_PAGES_SCANNED,       /* pages scanned since last reclaim */
>         NR_VM_NODE_STAT_ITEMS
>  };
>
> @@ -219,7 +222,7 @@ struct lruvec {
>         /* Evictions & activations on the inactive file list */
>         atomic_long_t                   inactive_age;
>  #ifdef CONFIG_MEMCG
> -       struct zone                     *zone;
> +       struct pglist_data *pgdat;
>  #endif
>  };
>
> @@ -357,13 +360,6 @@ struct zone {
>  #ifdef CONFIG_NUMA
>         int node;
>  #endif
> -
> -       /*
> -        * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
> -        * this zone's LRU.  Maintained by the pageout code.
> -        */
> -       unsigned int inactive_ratio;
> -
>         struct pglist_data      *zone_pgdat;
>         struct per_cpu_pageset __percpu *pageset;
>
> @@ -495,9 +491,6 @@ struct zone {
>
>         /* Write-intensive fields used by page reclaim */
>
> -       /* Fields commonly accessed by the page reclaim scanner */
> -       struct lruvec           lruvec;
> -
>         /*
>          * When free pages are below this point, additional steps are taken
>          * when reading the number of free pages to avoid per-cpu counter
> @@ -537,17 +530,20 @@ struct zone {
>
>  enum zone_flags {
>         ZONE_RECLAIM_LOCKED,            /* prevents concurrent reclaim */
> -       ZONE_CONGESTED,                 /* zone has many dirty pages backed by
> +       ZONE_FAIR_DEPLETED,             /* fair zone policy batch depleted */
> +};
> +
> +enum pgdat_flags {
> +       PGDAT_CONGESTED,                /* pgdat has many dirty pages backed by
>                                          * a congested BDI
>                                          */
> -       ZONE_DIRTY,                     /* reclaim scanning has recently found
> +       PGDAT_DIRTY,                    /* reclaim scanning has recently found
>                                          * many dirty file pages at the tail
>                                          * of the LRU.
>                                          */
> -       ZONE_WRITEBACK,                 /* reclaim scanning has recently found
> +       PGDAT_WRITEBACK,                /* reclaim scanning has recently found
>                                          * many pages under writeback
>                                          */
> -       ZONE_FAIR_DEPLETED,             /* fair zone policy batch depleted */
>  };
>
>  static inline unsigned long zone_end_pfn(const struct zone *zone)
> @@ -707,6 +703,19 @@ typedef struct pglist_data {
>         unsigned long split_queue_len;
>  #endif
>
> +       /* Fields commonly accessed by the page reclaim scanner */
> +       struct lruvec           lruvec;
> +
> +       /*
> +        * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
> +        * this node's LRU.  Maintained by the pageout code.
> +        */
> +       unsigned int inactive_ratio;
> +
> +       unsigned long           flags;
> +
> +       ZONE_PADDING(_pad2_)
> +
>         /* Per-node vmstats */
>         struct per_cpu_nodestat __percpu *per_cpu_nodestats;
>         atomic_long_t           vm_stat[NR_VM_NODE_STAT_ITEMS];
> @@ -728,6 +737,11 @@ static inline spinlock_t *zone_lru_lock(struct zone *zone)
>         return &zone->zone_pgdat->lru_lock;
>  }
>
> +static inline struct lruvec *zone_lruvec(struct zone *zone)
> +{
> +       return &zone->zone_pgdat->lruvec;
> +}
> +
>  static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
>  {
>         return pgdat->node_start_pfn + pgdat->node_spanned_pages;
> @@ -779,12 +793,12 @@ extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
>
>  extern void lruvec_init(struct lruvec *lruvec);
>
> -static inline struct zone *lruvec_zone(struct lruvec *lruvec)
> +static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
>  {
>  #ifdef CONFIG_MEMCG
> -       return lruvec->zone;
> +       return lruvec->pgdat;
>  #else
> -       return container_of(lruvec, struct zone, lruvec);
> +       return container_of(lruvec, struct pglist_data, lruvec);
>  #endif
>  }
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 0af2bb2028fd..c82f916008b7 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -317,6 +317,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
>
>  /* linux/mm/vmscan.c */
>  extern unsigned long zone_reclaimable_pages(struct zone *zone);
> +extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
>  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>                                         gfp_t gfp_mask, nodemask_t *mask);
>  extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 42604173f122..1798ff542517 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -26,11 +26,11 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>                 PGFREE, PGACTIVATE, PGDEACTIVATE,
>                 PGFAULT, PGMAJFAULT,
>                 PGLAZYFREED,
> -               FOR_ALL_ZONES(PGREFILL),
> -               FOR_ALL_ZONES(PGSTEAL_KSWAPD),
> -               FOR_ALL_ZONES(PGSTEAL_DIRECT),
> -               FOR_ALL_ZONES(PGSCAN_KSWAPD),
> -               FOR_ALL_ZONES(PGSCAN_DIRECT),
> +               PGREFILL,
> +               PGSTEAL_KSWAPD,
> +               PGSTEAL_DIRECT,
> +               PGSCAN_KSWAPD,
> +               PGSCAN_DIRECT,
>                 PGSCAN_DIRECT_THROTTLE,
>  #ifdef CONFIG_NUMA
>                 PGSCAN_ZONE_RECLAIM_FAILED,
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index d1744aa3ab9c..fee321c98550 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -178,6 +178,23 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
>         return x;
>  }
>
> +static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
> +                                       enum node_stat_item item)
> +{
> +       long x = atomic_long_read(&pgdat->vm_stat[item]);
> +
> +#ifdef CONFIG_SMP
> +       int cpu;
> +       for_each_online_cpu(cpu)
> +               x += per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->vm_node_stat_diff[item];
> +
> +       if (x < 0)
> +               x = 0;
> +#endif
> +       return x;
> +}
> +
> +
>  #ifdef CONFIG_NUMA
>  extern unsigned long sum_zone_node_page_state(int node,
>                                                 enum zone_stat_item item);
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 0101ef37f1ee..897f1aa1ee5f 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -352,15 +352,14 @@ TRACE_EVENT(mm_vmscan_writepage,
>
>  TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
>
> -       TP_PROTO(struct zone *zone,
> +       TP_PROTO(int nid,
>                 unsigned long nr_scanned, unsigned long nr_reclaimed,
>                 int priority, int file),
>
> -       TP_ARGS(zone, nr_scanned, nr_reclaimed, priority, file),
> +       TP_ARGS(nid, nr_scanned, nr_reclaimed, priority, file),
>
>         TP_STRUCT__entry(
>                 __field(int, nid)
> -               __field(int, zid)
>                 __field(unsigned long, nr_scanned)
>                 __field(unsigned long, nr_reclaimed)
>                 __field(int, priority)
> @@ -368,16 +367,15 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
>         ),
>
>         TP_fast_assign(
> -               __entry->nid = zone_to_nid(zone);
> -               __entry->zid = zone_idx(zone);
> +               __entry->nid = nid;
>                 __entry->nr_scanned = nr_scanned;
>                 __entry->nr_reclaimed = nr_reclaimed;
>                 __entry->priority = priority;
>                 __entry->reclaim_flags = trace_shrink_flags(file);
>         ),
>
> -       TP_printk("nid=%d zid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
> -               __entry->nid, __entry->zid,
> +       TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
> +               __entry->nid,
>                 __entry->nr_scanned, __entry->nr_reclaimed,
>                 __entry->priority,
>                 show_reclaim_flags(__entry->reclaim_flags))
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index 3a970604308f..24a06bc23f85 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1525,11 +1525,11 @@ static unsigned long minimum_image_size(unsigned long saveable)
>         unsigned long size;
>
>         size = global_page_state(NR_SLAB_RECLAIMABLE)
> -               + global_page_state(NR_ACTIVE_ANON)
> -               + global_page_state(NR_INACTIVE_ANON)
> -               + global_page_state(NR_ACTIVE_FILE)
> -               + global_page_state(NR_INACTIVE_FILE)
> -               - global_page_state(NR_FILE_MAPPED);
> +               + global_node_page_state(NR_ACTIVE_ANON)
> +               + global_node_page_state(NR_INACTIVE_ANON)
> +               + global_node_page_state(NR_ACTIVE_FILE)
> +               + global_node_page_state(NR_INACTIVE_FILE)
> +               - global_node_page_state(NR_FILE_MAPPED);
>
>         return saveable <= size ? 0 : saveable - size;
>  }
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index f53b23ab7ed7..a8c3af46bd3d 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -982,24 +982,24 @@ long congestion_wait(int sync, long timeout)
>  EXPORT_SYMBOL(congestion_wait);
>
>  /**
> - * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a zone to complete writes
> - * @zone: A zone to check if it is heavily congested
> + * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a pgdat to complete writes
> + * @pgdat: A pgdat to check if it is heavily congested
>   * @sync: SYNC or ASYNC IO
>   * @timeout: timeout in jiffies
>   *
>   * In the event of a congested backing_dev (any backing_dev) and the given
> - * @zone has experienced recent congestion, this waits for up to @timeout
> + * @pgdat has experienced recent congestion, this waits for up to @timeout
>   * jiffies for either a BDI to exit congestion of the given @sync queue
>   * or a write to complete.
>   *
> - * In the absence of zone congestion, cond_resched() is called to yield
> + * In the absence of pgdat congestion, cond_resched() is called to yield
>   * the processor if necessary but otherwise does not sleep.
>   *
>   * The return value is 0 if the sleep is for the full timeout. Otherwise,
>   * it is the number of jiffies that were still remaining when the function
>   * returned. return_value == timeout implies the function did not sleep.
>   */
> -long wait_iff_congested(struct zone *zone, int sync, long timeout)
> +long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout)
>  {
>         long ret;
>         unsigned long start = jiffies;
> @@ -1008,12 +1008,13 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
>
>         /*
>          * If there is no congestion, or heavy congestion is not being
> -        * encountered in the current zone, yield if necessary instead
> +        * encountered in the current pgdat, yield if necessary instead
>          * of sleeping on the congestion queue
>          */
>         if (atomic_read(&nr_wb_congested[sync]) == 0 ||
> -           !test_bit(ZONE_CONGESTED, &zone->flags)) {
> +           !test_bit(PGDAT_CONGESTED, &pgdat->flags)) {
>                 cond_resched();
> +
>                 /* In case we scheduled, work out time remaining */
>                 ret = timeout - (jiffies - start);
>                 if (ret < 0)
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7607efb7bee2..a0bd85712516 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -646,8 +646,8 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
>         list_for_each_entry(page, &cc->migratepages, lru)
>                 count[!!page_is_file_cache(page)]++;
>
> -       mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
> -       mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
> +       mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON, count[0]);
> +       mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, count[1]);
>  }
>
>  /* Similar to reclaim, but different enough that they don't share logic */
> @@ -655,12 +655,12 @@ static bool too_many_isolated(struct zone *zone)
>  {
>         unsigned long active, inactive, isolated;
>
> -       inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
> -                                       zone_page_state(zone, NR_INACTIVE_ANON);
> -       active = zone_page_state(zone, NR_ACTIVE_FILE) +
> -                                       zone_page_state(zone, NR_ACTIVE_ANON);
> -       isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
> -                                       zone_page_state(zone, NR_ISOLATED_ANON);
> +       inactive = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
> +                       node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
> +       active = node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE) +
> +                       node_page_state(zone->zone_pgdat, NR_ACTIVE_ANON);
> +       isolated = node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE) +
> +                       node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON);
>
>         return isolated > (inactive + active) / 2;
>  }
> @@ -856,7 +856,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>                         }
>                 }
>
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>
>                 /* Try isolate the page */
>                 if (__isolate_lru_page(page, isolate_mode) != 0)
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 2f997328ae64..5d5b2207cfd2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1830,7 +1830,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>         pgoff_t end = -1;
>         int i;
>
> -       lruvec = mem_cgroup_page_lruvec(head, zone);
> +       lruvec = mem_cgroup_page_lruvec(head, zone->zone_pgdat);
>
>         /* complete memcg works before add pages to LRU */
>         mem_cgroup_split_huge_fixup(head);
> diff --git a/mm/internal.h b/mm/internal.h
> index 9b6a6c43ac39..2f80d0343c56 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -78,7 +78,7 @@ extern unsigned long highest_memmap_pfn;
>   */
>  extern int isolate_lru_page(struct page *page);
>  extern void putback_lru_page(struct page *page);
> -extern bool zone_reclaimable(struct zone *zone);
> +extern bool pgdat_reclaimable(struct pglist_data *pgdat);
>
>  /*
>   * in mm/rmap.c:
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 93d5f87c00d5..d7a49f665f04 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -480,7 +480,7 @@ void __khugepaged_exit(struct mm_struct *mm)
>  static void release_pte_page(struct page *page)
>  {
>         /* 0 stands for page_is_file_cache(page) == false */
> -       dec_zone_page_state(page, NR_ISOLATED_ANON + 0);
> +       dec_node_page_state(page, NR_ISOLATED_ANON + 0);
>         unlock_page(page);
>         putback_lru_page(page);
>  }
> @@ -576,7 +576,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>                         goto out;
>                 }
>                 /* 0 stands for page_is_file_cache(page) == false */
> -               inc_zone_page_state(page, NR_ISOLATED_ANON + 0);
> +               inc_node_page_state(page, NR_ISOLATED_ANON + 0);
>                 VM_BUG_ON_PAGE(!PageLocked(page), page);
>                 VM_BUG_ON_PAGE(PageLRU(page), page);
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9b70f9ca8ddf..50c86ad121bc 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -943,14 +943,14 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
>   * and putback protocol: the LRU lock must be held, and the page must
>   * either be PageLRU() or the caller must have isolated/allocated it.
>   */
> -struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
> +struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgdat)
>  {
>         struct mem_cgroup_per_zone *mz;
>         struct mem_cgroup *memcg;
>         struct lruvec *lruvec;
>
>         if (mem_cgroup_disabled()) {
> -               lruvec = &zone->lruvec;
> +               lruvec = &pgdat->lruvec;
>                 goto out;
>         }
>
> @@ -970,8 +970,8 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>          * we have to be prepared to initialize lruvec->zone here;
>          * and if offlined then reonlined, we need to reinitialize it.
>          */
> -       if (unlikely(lruvec->zone != zone))
> -               lruvec->zone = zone;
> +       if (unlikely(lruvec->pgdat != pgdat))
> +               lruvec->pgdat = pgdat;
>         return lruvec;
>  }
>
> @@ -979,6 +979,7 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>   * mem_cgroup_update_lru_size - account for adding or removing an lru page
>   * @lruvec: mem_cgroup per zone lru vector
>   * @lru: index of lru list the page is sitting on
> + * @zid: Zone ID of the zone pages have been added to
>   * @nr_pages: positive when adding or negative when removing
>   *
>   * This function must be called under lru_lock, just before a page is added
> @@ -986,14 +987,14 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>   * so as to allow it to check that lru_size 0 is consistent with list_empty).
>   */
>  void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
> -                               int nr_pages)
> +                               enum zone_type zid, int nr_pages)
>  {
>         struct mem_cgroup_per_zone *mz;
>         unsigned long *lru_size;
>         long size;
>         bool empty;
>
> -       __update_lru_size(lruvec, lru, nr_pages);
> +       __update_lru_size(lruvec, lru, zid, nr_pages);
>
>         if (mem_cgroup_disabled())
>                 return;
> @@ -2069,7 +2070,7 @@ static void lock_page_lru(struct page *page, int *isolated)
>         if (PageLRU(page)) {
>                 struct lruvec *lruvec;
>
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>                 ClearPageLRU(page);
>                 del_page_from_lru_list(page, lruvec, page_lru(page));
>                 *isolated = 1;
> @@ -2084,7 +2085,7 @@ static void unlock_page_lru(struct page *page, int isolated)
>         if (isolated) {
>                 struct lruvec *lruvec;
>
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>                 VM_BUG_ON_PAGE(PageLRU(page), page);
>                 SetPageLRU(page);
>                 add_page_to_lru_list(page, lruvec, page_lru(page));
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 2fcca6b0e005..11de752ccaf5 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1663,7 +1663,7 @@ static int __soft_offline_page(struct page *page, int flags)
>         put_hwpoison_page(page);
>         if (!ret) {
>                 LIST_HEAD(pagelist);
> -               inc_zone_page_state(page, NR_ISOLATED_ANON +
> +               inc_node_page_state(page, NR_ISOLATED_ANON +
>                                         page_is_file_cache(page));
>                 list_add(&page->lru, &pagelist);
>                 ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
> @@ -1671,7 +1671,7 @@ static int __soft_offline_page(struct page *page, int flags)
>                 if (ret) {
>                         if (!list_empty(&pagelist)) {
>                                 list_del(&page->lru);
> -                               dec_zone_page_state(page, NR_ISOLATED_ANON +
> +                               dec_node_page_state(page, NR_ISOLATED_ANON +
>                                                 page_is_file_cache(page));
>                                 putback_lru_page(page);
>                         }
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 82d0b98d27f8..c5278360ca66 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1586,7 +1586,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>                         put_page(page);
>                         list_add_tail(&page->lru, &source);
>                         move_pages--;
> -                       inc_zone_page_state(page, NR_ISOLATED_ANON +
> +                       inc_node_page_state(page, NR_ISOLATED_ANON +
>                                             page_is_file_cache(page));
>
>                 } else {
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 53e40d3f3933..d8c4e38fb5f4 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -962,7 +962,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>         if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
>                 if (!isolate_lru_page(page)) {
>                         list_add_tail(&page->lru, pagelist);
> -                       inc_zone_page_state(page, NR_ISOLATED_ANON +
> +                       inc_node_page_state(page, NR_ISOLATED_ANON +
>                                             page_is_file_cache(page));
>                 }
>         }
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 2232f6923cc7..3033dae33a0a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -168,7 +168,7 @@ void putback_movable_pages(struct list_head *l)
>                         continue;
>                 }
>                 list_del(&page->lru);
> -               dec_zone_page_state(page, NR_ISOLATED_ANON +
> +               dec_node_page_state(page, NR_ISOLATED_ANON +
>                                 page_is_file_cache(page));
>                 /*
>                  * We isolated non-lru movable page so here we can use
> @@ -1119,7 +1119,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>                  * restored.
>                  */
>                 list_del(&page->lru);
> -               dec_zone_page_state(page, NR_ISOLATED_ANON +
> +               dec_node_page_state(page, NR_ISOLATED_ANON +
>                                 page_is_file_cache(page));
>         }
>
> @@ -1460,7 +1460,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>                 err = isolate_lru_page(page);
>                 if (!err) {
>                         list_add_tail(&page->lru, &pagelist);
> -                       inc_zone_page_state(page, NR_ISOLATED_ANON +
> +                       inc_node_page_state(page, NR_ISOLATED_ANON +
>                                             page_is_file_cache(page));
>                 }
>  put_and_set:
> @@ -1726,15 +1726,16 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
>                                    unsigned long nr_migrate_pages)
>  {
>         int z;
> +
> +       if (!pgdat_reclaimable(pgdat))
> +               return false;
> +
>         for (z = pgdat->nr_zones - 1; z >= 0; z--) {
>                 struct zone *zone = pgdat->node_zones + z;
>
>                 if (!populated_zone(zone))
>                         continue;
>
> -               if (!zone_reclaimable(zone))
> -                       continue;
> -
>                 /* Avoid waking kswapd by allocating pages_to_migrate pages. */
>                 if (!zone_watermark_ok(zone, 0,
>                                        high_wmark_pages(zone) +
> @@ -1828,7 +1829,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>         }
>
>         page_lru = page_is_file_cache(page);
> -       mod_zone_page_state(page_zone(page), NR_ISOLATED_ANON + page_lru,
> +       mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON + page_lru,
>                                 hpage_nr_pages(page));
>
>         /*
> @@ -1886,7 +1887,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
>         if (nr_remaining) {
>                 if (!list_empty(&migratepages)) {
>                         list_del(&page->lru);
> -                       dec_zone_page_state(page, NR_ISOLATED_ANON +
> +                       dec_node_page_state(page, NR_ISOLATED_ANON +
>                                         page_is_file_cache(page));
>                         putback_lru_page(page);
>                 }
> @@ -1979,7 +1980,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>                 /* Retake the callers reference and putback on LRU */
>                 get_page(page);
>                 putback_lru_page(page);
> -               mod_zone_page_state(page_zone(page),
> +               mod_node_page_state(page_pgdat(page),
>                          NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
>
>                 goto out_unlock;
> @@ -2030,7 +2031,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>         count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
>         count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
>
> -       mod_zone_page_state(page_zone(page),
> +       mod_node_page_state(page_pgdat(page),
>                         NR_ISOLATED_ANON + page_lru,
>                         -HPAGE_PMD_NR);
>         return isolated;
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 997f63082ff5..14645be06e30 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -103,7 +103,7 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
>         if (PageLRU(page)) {
>                 struct lruvec *lruvec;
>
> -               lruvec = mem_cgroup_page_lruvec(page, page_zone(page));
> +               lruvec = mem_cgroup_page_lruvec(page, page_pgdat(page));
>                 if (getpage)
>                         get_page(page);
>                 ClearPageLRU(page);
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index d578d2a56b19..0ada2b2954b0 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -285,8 +285,8 @@ static unsigned long zone_dirtyable_memory(struct zone *zone)
>          */
>         nr_pages -= min(nr_pages, zone->totalreserve_pages);
>
> -       nr_pages += zone_page_state(zone, NR_INACTIVE_FILE);
> -       nr_pages += zone_page_state(zone, NR_ACTIVE_FILE);
> +       nr_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
> +       nr_pages += node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
>
>         return nr_pages;
>  }
> @@ -348,8 +348,8 @@ static unsigned long global_dirtyable_memory(void)
>          */
>         x -= min(x, totalreserve_pages);
>
> -       x += global_page_state(NR_INACTIVE_FILE);
> -       x += global_page_state(NR_ACTIVE_FILE);
> +       x += global_node_page_state(NR_INACTIVE_FILE);
> +       x += global_node_page_state(NR_ACTIVE_FILE);
>
>         if (!vm_highmem_is_dirtyable)
>                 x -= highmem_dirtyable_memory(x);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48b5414009ac..b84b85ae54ff 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1090,9 +1090,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>
>         spin_lock(&zone->lock);
>         isolated_pageblocks = has_isolate_pageblock(zone);
> -       nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> +       nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
>         if (nr_scanned)
> -               __mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
> +               __mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
>
>         while (count) {
>                 struct page *page;
> @@ -1147,9 +1147,9 @@ static void free_one_page(struct zone *zone,
>  {
>         unsigned long nr_scanned;
>         spin_lock(&zone->lock);
> -       nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> +       nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
>         if (nr_scanned)
> -               __mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
> +               __mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
>
>         if (unlikely(has_isolate_pageblock(zone) ||
>                 is_migrate_isolate(migratetype))) {
> @@ -4331,6 +4331,7 @@ void show_free_areas(unsigned int filter)
>         unsigned long free_pcp = 0;
>         int cpu;
>         struct zone *zone;
> +       pg_data_t *pgdat;
>
>         for_each_populated_zone(zone) {
>                 if (skip_free_areas_node(filter, zone_to_nid(zone)))
> @@ -4349,13 +4350,13 @@ void show_free_areas(unsigned int filter)
>                 " anon_thp: %lu shmem_thp: %lu shmem_pmdmapped: %lu\n"
>  #endif
>                 " free:%lu free_pcp:%lu free_cma:%lu\n",
> -               global_page_state(NR_ACTIVE_ANON),
> -               global_page_state(NR_INACTIVE_ANON),
> -               global_page_state(NR_ISOLATED_ANON),
> -               global_page_state(NR_ACTIVE_FILE),
> -               global_page_state(NR_INACTIVE_FILE),
> -               global_page_state(NR_ISOLATED_FILE),
> -               global_page_state(NR_UNEVICTABLE),
> +               global_node_page_state(NR_ACTIVE_ANON),
> +               global_node_page_state(NR_INACTIVE_ANON),
> +               global_node_page_state(NR_ISOLATED_ANON),
> +               global_node_page_state(NR_ACTIVE_FILE),
> +               global_node_page_state(NR_INACTIVE_FILE),
> +               global_node_page_state(NR_ISOLATED_FILE),
> +               global_node_page_state(NR_UNEVICTABLE),
>                 global_page_state(NR_FILE_DIRTY),
>                 global_page_state(NR_WRITEBACK),
>                 global_page_state(NR_UNSTABLE_NFS),
> @@ -4374,6 +4375,28 @@ void show_free_areas(unsigned int filter)
>                 free_pcp,
>                 global_page_state(NR_FREE_CMA_PAGES));
>
> +       for_each_online_pgdat(pgdat) {
> +               printk("Node %d"
> +                       " active_anon:%lukB"
> +                       " inactive_anon:%lukB"
> +                       " active_file:%lukB"
> +                       " inactive_file:%lukB"
> +                       " unevictable:%lukB"
> +                       " isolated(anon):%lukB"
> +                       " isolated(file):%lukB"
> +                       " all_unreclaimable? %s"
> +                       "\n",
> +                       pgdat->node_id,
> +                       K(node_page_state(pgdat, NR_ACTIVE_ANON)),
> +                       K(node_page_state(pgdat, NR_INACTIVE_ANON)),
> +                       K(node_page_state(pgdat, NR_ACTIVE_FILE)),
> +                       K(node_page_state(pgdat, NR_INACTIVE_FILE)),
> +                       K(node_page_state(pgdat, NR_UNEVICTABLE)),
> +                       K(node_page_state(pgdat, NR_ISOLATED_ANON)),
> +                       K(node_page_state(pgdat, NR_ISOLATED_FILE)),
> +                       !pgdat_reclaimable(pgdat) ? "yes" : "no");
> +       }
> +
>         for_each_populated_zone(zone) {
>                 int i;
>
> @@ -4390,13 +4413,6 @@ void show_free_areas(unsigned int filter)
>                         " min:%lukB"
>                         " low:%lukB"
>                         " high:%lukB"
> -                       " active_anon:%lukB"
> -                       " inactive_anon:%lukB"
> -                       " active_file:%lukB"
> -                       " inactive_file:%lukB"
> -                       " unevictable:%lukB"
> -                       " isolated(anon):%lukB"
> -                       " isolated(file):%lukB"
>                         " present:%lukB"
>                         " managed:%lukB"
>                         " mlocked:%lukB"
> @@ -4419,21 +4435,13 @@ void show_free_areas(unsigned int filter)
>                         " local_pcp:%ukB"
>                         " free_cma:%lukB"
>                         " writeback_tmp:%lukB"
> -                       " pages_scanned:%lu"
> -                       " all_unreclaimable? %s"
> +                       " node_pages_scanned:%lu"
>                         "\n",
>                         zone->name,
>                         K(zone_page_state(zone, NR_FREE_PAGES)),
>                         K(min_wmark_pages(zone)),
>                         K(low_wmark_pages(zone)),
>                         K(high_wmark_pages(zone)),
> -                       K(zone_page_state(zone, NR_ACTIVE_ANON)),
> -                       K(zone_page_state(zone, NR_INACTIVE_ANON)),
> -                       K(zone_page_state(zone, NR_ACTIVE_FILE)),
> -                       K(zone_page_state(zone, NR_INACTIVE_FILE)),
> -                       K(zone_page_state(zone, NR_UNEVICTABLE)),
> -                       K(zone_page_state(zone, NR_ISOLATED_ANON)),
> -                       K(zone_page_state(zone, NR_ISOLATED_FILE)),
>                         K(zone->present_pages),
>                         K(zone->managed_pages),
>                         K(zone_page_state(zone, NR_MLOCK)),
> @@ -4458,9 +4466,7 @@ void show_free_areas(unsigned int filter)
>                         K(this_cpu_read(zone->pageset->pcp.count)),
>                         K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
>                         K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
> -                       K(zone_page_state(zone, NR_PAGES_SCANNED)),
> -                       (!zone_reclaimable(zone) ? "yes" : "no")
> -                       );
> +                       K(node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED)));
>                 printk("lowmem_reserve[]:");
>                 for (i = 0; i < MAX_NR_ZONES; i++)
>                         printk(" %ld", zone->lowmem_reserve[i]);
> @@ -6010,7 +6016,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>                 /* For bootup, initialized properly in watermark setup */
>                 mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
>
> -               lruvec_init(&zone->lruvec);
> +               lruvec_init(zone_lruvec(zone));
>                 if (!size)
>                         continue;
>
> diff --git a/mm/swap.c b/mm/swap.c
> index bf37e5cfae81..77af473635fe 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -63,7 +63,7 @@ static void __page_cache_release(struct page *page)
>                 unsigned long flags;
>
>                 spin_lock_irqsave(zone_lru_lock(zone), flags);
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>                 VM_BUG_ON_PAGE(!PageLRU(page), page);
>                 __ClearPageLRU(page);
>                 del_page_from_lru_list(page, lruvec, page_off_lru(page));
> @@ -194,7 +194,7 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
>                         spin_lock_irqsave(zone_lru_lock(zone), flags);
>                 }
>
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>                 (*move_fn)(page, lruvec, arg);
>         }
>         if (zone)
> @@ -319,7 +319,7 @@ void activate_page(struct page *page)
>
>         page = compound_head(page);
>         spin_lock_irq(zone_lru_lock(zone));
> -       __activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
> +       __activate_page(page, mem_cgroup_page_lruvec(page, zone->zone_pgdat), NULL);
>         spin_unlock_irq(zone_lru_lock(zone));
>  }
>  #endif
> @@ -445,16 +445,16 @@ void lru_cache_add(struct page *page)
>   */
>  void add_page_to_unevictable_list(struct page *page)
>  {
> -       struct zone *zone = page_zone(page);
> +       struct pglist_data *pgdat = page_pgdat(page);
>         struct lruvec *lruvec;
>
> -       spin_lock_irq(zone_lru_lock(zone));
> -       lruvec = mem_cgroup_page_lruvec(page, zone);
> +       spin_lock_irq(&pgdat->lru_lock);
> +       lruvec = mem_cgroup_page_lruvec(page, pgdat);
>         ClearPageActive(page);
>         SetPageUnevictable(page);
>         SetPageLRU(page);
>         add_page_to_lru_list(page, lruvec, LRU_UNEVICTABLE);
> -       spin_unlock_irq(zone_lru_lock(zone));
> +       spin_unlock_irq(&pgdat->lru_lock);
>  }
>
>  /**
> @@ -730,7 +730,7 @@ void release_pages(struct page **pages, int nr, bool cold)
>  {
>         int i;
>         LIST_HEAD(pages_to_free);
> -       struct zone *zone = NULL;
> +       struct pglist_data *locked_pgdat = NULL;
>         struct lruvec *lruvec;
>         unsigned long uninitialized_var(flags);
>         unsigned int uninitialized_var(lock_batch);
> @@ -741,11 +741,11 @@ void release_pages(struct page **pages, int nr, bool cold)
>                 /*
>                  * Make sure the IRQ-safe lock-holding time does not get
>                  * excessive with a continuous string of pages from the
> -                * same zone. The lock is held only if zone != NULL.
> +                * same pgdat. The lock is held only if pgdat != NULL.
>                  */
> -               if (zone && ++lock_batch == SWAP_CLUSTER_MAX) {
> -                       spin_unlock_irqrestore(zone_lru_lock(zone), flags);
> -                       zone = NULL;
> +               if (locked_pgdat && ++lock_batch == SWAP_CLUSTER_MAX) {
> +                       spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
> +                       locked_pgdat = NULL;
>                 }
>
>                 if (is_huge_zero_page(page)) {
> @@ -758,27 +758,27 @@ void release_pages(struct page **pages, int nr, bool cold)
>                         continue;
>
>                 if (PageCompound(page)) {
> -                       if (zone) {
> -                               spin_unlock_irqrestore(zone_lru_lock(zone), flags);
> -                               zone = NULL;
> +                       if (locked_pgdat) {
> +                               spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
> +                               locked_pgdat = NULL;
>                         }
>                         __put_compound_page(page);
>                         continue;
>                 }
>
>                 if (PageLRU(page)) {
> -                       struct zone *pagezone = page_zone(page);
> +                       struct pglist_data *pgdat = page_pgdat(page);
>
> -                       if (pagezone != zone) {
> -                               if (zone)
> -                                       spin_unlock_irqrestore(zone_lru_lock(zone),
> +                       if (pgdat != locked_pgdat) {
> +                               if (locked_pgdat)
> +                                       spin_unlock_irqrestore(&locked_pgdat->lru_lock,
>                                                                         flags);
>                                 lock_batch = 0;
> -                               zone = pagezone;
> -                               spin_lock_irqsave(zone_lru_lock(zone), flags);
> +                               locked_pgdat = pgdat;
> +                               spin_lock_irqsave(&locked_pgdat->lru_lock, flags);
>                         }
>
> -                       lruvec = mem_cgroup_page_lruvec(page, zone);
> +                       lruvec = mem_cgroup_page_lruvec(page, locked_pgdat);
>                         VM_BUG_ON_PAGE(!PageLRU(page), page);
>                         __ClearPageLRU(page);
>                         del_page_from_lru_list(page, lruvec, page_off_lru(page));
> @@ -789,8 +789,8 @@ void release_pages(struct page **pages, int nr, bool cold)
>
>                 list_add(&page->lru, &pages_to_free);
>         }
> -       if (zone)
> -               spin_unlock_irqrestore(zone_lru_lock(zone), flags);
> +       if (locked_pgdat)
> +               spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
>
>         mem_cgroup_uncharge_list(&pages_to_free);
>         free_hot_cold_page_list(&pages_to_free, cold);
> @@ -826,7 +826,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
>         VM_BUG_ON_PAGE(PageCompound(page_tail), page);
>         VM_BUG_ON_PAGE(PageLRU(page_tail), page);
>         VM_BUG_ON(NR_CPUS != 1 &&
> -                 !spin_is_locked(zone_lru_lock(lruvec_zone(lruvec))));
> +                 !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
>
>         if (!list)
>                 SetPageLRU(page_tail);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e7ffcd259cc4..86a523a761c9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -191,26 +191,42 @@ static bool sane_reclaim(struct scan_control *sc)
>  }
>  #endif
>
> +/*
> + * This misses isolated pages which are not accounted for to save counters.
> + * As the data only determines if reclaim or compaction continues, it is
> + * not expected that isolated pages will be a dominating factor.
> + */
>  unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
>         unsigned long nr;
>
> -       nr = zone_page_state_snapshot(zone, NR_ACTIVE_FILE) +
> -            zone_page_state_snapshot(zone, NR_INACTIVE_FILE) +
> -            zone_page_state_snapshot(zone, NR_ISOLATED_FILE);
> +       nr = zone_page_state_snapshot(zone, NR_ZONE_LRU_FILE);
> +       if (get_nr_swap_pages() > 0)
> +               nr += zone_page_state_snapshot(zone, NR_ZONE_LRU_ANON);
> +
> +       return nr;
> +}
> +
> +unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
> +{
> +       unsigned long nr;
> +
> +       nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
> +            node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
> +            node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
>
>         if (get_nr_swap_pages() > 0)
> -               nr += zone_page_state_snapshot(zone, NR_ACTIVE_ANON) +
> -                     zone_page_state_snapshot(zone, NR_INACTIVE_ANON) +
> -                     zone_page_state_snapshot(zone, NR_ISOLATED_ANON);
> +               nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
> +                     node_page_state_snapshot(pgdat, NR_INACTIVE_ANON) +
> +                     node_page_state_snapshot(pgdat, NR_ISOLATED_ANON);
>
>         return nr;
>  }
>
> -bool zone_reclaimable(struct zone *zone)
> +bool pgdat_reclaimable(struct pglist_data *pgdat)
>  {
> -       return zone_page_state_snapshot(zone, NR_PAGES_SCANNED) <
> -               zone_reclaimable_pages(zone) * 6;
> +       return node_page_state_snapshot(pgdat, NR_PAGES_SCANNED) <
> +               pgdat_reclaimable_pages(pgdat) * 6;
>  }
>
>  unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
> @@ -218,7 +234,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
>         if (!mem_cgroup_disabled())
>                 return mem_cgroup_get_lru_size(lruvec, lru);
>
> -       return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
> +       return node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
>  }
>
>  /*
> @@ -877,7 +893,7 @@ static void page_check_dirty_writeback(struct page *page,
>   * shrink_page_list() returns the number of reclaimed pages
>   */
>  static unsigned long shrink_page_list(struct list_head *page_list,
> -                                     struct zone *zone,
> +                                     struct pglist_data *pgdat,
>                                       struct scan_control *sc,
>                                       enum ttu_flags ttu_flags,
>                                       unsigned long *ret_nr_dirty,
> @@ -917,7 +933,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                         goto keep;
>
>                 VM_BUG_ON_PAGE(PageActive(page), page);
> -               VM_BUG_ON_PAGE(page_zone(page) != zone, page);
>
>                 sc->nr_scanned++;
>
> @@ -996,7 +1011,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                         /* Case 1 above */
>                         if (current_is_kswapd() &&
>                             PageReclaim(page) &&
> -                           test_bit(ZONE_WRITEBACK, &zone->flags)) {
> +                           test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
>                                 nr_immediate++;
>                                 goto keep_locked;
>
> @@ -1092,7 +1107,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                          */
>                         if (page_is_file_cache(page) &&
>                                         (!current_is_kswapd() ||
> -                                        !test_bit(ZONE_DIRTY, &zone->flags))) {
> +                                        !test_bit(PGDAT_DIRTY, &pgdat->flags))) {
>                                 /*
>                                  * Immediately reclaim when written back.
>                                  * Similar in principal to deactivate_page()
> @@ -1266,11 +1281,11 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>                 }
>         }
>
> -       ret = shrink_page_list(&clean_pages, zone, &sc,
> +       ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
>                         TTU_UNMAP|TTU_IGNORE_ACCESS,
>                         &dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
>         list_splice(&clean_pages, page_list);
> -       mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
> +       mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
>         return ret;
>  }
>
> @@ -1375,7 +1390,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  {
>         struct list_head *src = &lruvec->lists[lru];
>         unsigned long nr_taken = 0;
> -       unsigned long scan;
> +       unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
> +       unsigned long scan, nr_pages;
>
>         for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
>                                         !list_empty(src); scan++) {
> @@ -1388,7 +1404,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>
>                 switch (__isolate_lru_page(page, mode)) {
>                 case 0:
> -                       nr_taken += hpage_nr_pages(page);
> +                       nr_pages = hpage_nr_pages(page);
> +                       nr_taken += nr_pages;
> +                       nr_zone_taken[page_zonenum(page)] += nr_pages;
>                         list_move(&page->lru, dst);
>                         break;
>
> @@ -1405,6 +1423,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>         *nr_scanned = scan;
>         trace_mm_vmscan_lru_isolate(sc->order, nr_to_scan, scan,
>                                     nr_taken, mode, is_file_lru(lru));
> +       for (scan = 0; scan < MAX_NR_ZONES; scan++) {
> +               nr_pages = nr_zone_taken[scan];
> +               if (!nr_pages)
> +                       continue;
> +
> +               update_lru_size(lruvec, lru, scan, -nr_pages);
> +       }
>         return nr_taken;
>  }
>
> @@ -1445,7 +1470,7 @@ int isolate_lru_page(struct page *page)
>                 struct lruvec *lruvec;
>
>                 spin_lock_irq(zone_lru_lock(zone));
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>                 if (PageLRU(page)) {
>                         int lru = page_lru(page);
>                         get_page(page);
> @@ -1465,7 +1490,7 @@ int isolate_lru_page(struct page *page)
>   * the LRU list will go small and be scanned faster than necessary, leading to
>   * unnecessary swapping, thrashing and OOM.
>   */
> -static int too_many_isolated(struct zone *zone, int file,
> +static int too_many_isolated(struct pglist_data *pgdat, int file,
>                 struct scan_control *sc)
>  {
>         unsigned long inactive, isolated;
> @@ -1477,11 +1502,11 @@ static int too_many_isolated(struct zone *zone, int file,
>                 return 0;
>
>         if (file) {
> -               inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> -               isolated = zone_page_state(zone, NR_ISOLATED_FILE);
> +               inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
> +               isolated = node_page_state(pgdat, NR_ISOLATED_FILE);
>         } else {
> -               inactive = zone_page_state(zone, NR_INACTIVE_ANON);
> -               isolated = zone_page_state(zone, NR_ISOLATED_ANON);
> +               inactive = node_page_state(pgdat, NR_INACTIVE_ANON);
> +               isolated = node_page_state(pgdat, NR_ISOLATED_ANON);
>         }
>
>         /*
> @@ -1499,7 +1524,7 @@ static noinline_for_stack void
>  putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>  {
>         struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> -       struct zone *zone = lruvec_zone(lruvec);
> +       struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>         LIST_HEAD(pages_to_free);
>
>         /*
> @@ -1512,13 +1537,13 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>                 VM_BUG_ON_PAGE(PageLRU(page), page);
>                 list_del(&page->lru);
>                 if (unlikely(!page_evictable(page))) {
> -                       spin_unlock_irq(zone_lru_lock(zone));
> +                       spin_unlock_irq(&pgdat->lru_lock);
>                         putback_lru_page(page);
> -                       spin_lock_irq(zone_lru_lock(zone));
> +                       spin_lock_irq(&pgdat->lru_lock);
>                         continue;
>                 }
>
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, pgdat);
>
>                 SetPageLRU(page);
>                 lru = page_lru(page);
> @@ -1535,10 +1560,10 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>                         del_page_from_lru_list(page, lruvec, lru);
>
>                         if (unlikely(PageCompound(page))) {
> -                               spin_unlock_irq(zone_lru_lock(zone));
> +                               spin_unlock_irq(&pgdat->lru_lock);
>                                 mem_cgroup_uncharge(page);
>                                 (*get_compound_page_dtor(page))(page);
> -                               spin_lock_irq(zone_lru_lock(zone));
> +                               spin_lock_irq(&pgdat->lru_lock);
>                         } else
>                                 list_add(&page->lru, &pages_to_free);
>                 }
> @@ -1582,10 +1607,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>         unsigned long nr_immediate = 0;
>         isolate_mode_t isolate_mode = 0;
>         int file = is_file_lru(lru);
> -       struct zone *zone = lruvec_zone(lruvec);
> +       struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>         struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>
> -       while (unlikely(too_many_isolated(zone, file, sc))) {
> +       while (unlikely(too_many_isolated(pgdat, file, sc))) {
>                 congestion_wait(BLK_RW_ASYNC, HZ/10);
>
>                 /* We are about to die and free our memory. Return now. */
> @@ -1600,48 +1625,45 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>         if (!sc->may_writepage)
>                 isolate_mode |= ISOLATE_CLEAN;
>
> -       spin_lock_irq(zone_lru_lock(zone));
> +       spin_lock_irq(&pgdat->lru_lock);
>
>         nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
>                                      &nr_scanned, sc, isolate_mode, lru);
>
> -       update_lru_size(lruvec, lru, -nr_taken);
> -       __mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
> +       __mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>         reclaim_stat->recent_scanned[file] += nr_taken;
>
>         if (global_reclaim(sc)) {
> -               __mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
> +               __mod_node_page_state(pgdat, NR_PAGES_SCANNED, nr_scanned);
>                 if (current_is_kswapd())
> -                       __count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scanned);
> +                       __count_vm_events(PGSCAN_KSWAPD, nr_scanned);
>                 else
> -                       __count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
> +                       __count_vm_events(PGSCAN_DIRECT, nr_scanned);
>         }
> -       spin_unlock_irq(zone_lru_lock(zone));
> +       spin_unlock_irq(&pgdat->lru_lock);
>
>         if (nr_taken == 0)
>                 return 0;
>
> -       nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
> +       nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, TTU_UNMAP,
>                                 &nr_dirty, &nr_unqueued_dirty, &nr_congested,
>                                 &nr_writeback, &nr_immediate,
>                                 false);
>
> -       spin_lock_irq(zone_lru_lock(zone));
> +       spin_lock_irq(&pgdat->lru_lock);
>
>         if (global_reclaim(sc)) {
>                 if (current_is_kswapd())
> -                       __count_zone_vm_events(PGSTEAL_KSWAPD, zone,
> -                                              nr_reclaimed);
> +                       __count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
>                 else
> -                       __count_zone_vm_events(PGSTEAL_DIRECT, zone,
> -                                              nr_reclaimed);
> +                       __count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
>         }
>
>         putback_inactive_pages(lruvec, &page_list);
>
> -       __mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
> +       __mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
>
> -       spin_unlock_irq(zone_lru_lock(zone));
> +       spin_unlock_irq(&pgdat->lru_lock);
>
>         mem_cgroup_uncharge_list(&page_list);
>         free_hot_cold_page_list(&page_list, true);
> @@ -1661,7 +1683,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>          * are encountered in the nr_immediate check below.
>          */
>         if (nr_writeback && nr_writeback == nr_taken)
> -               set_bit(ZONE_WRITEBACK, &zone->flags);
> +               set_bit(PGDAT_WRITEBACK, &pgdat->flags);
>
>         /*
>          * Legacy memcg will stall in page writeback so avoid forcibly
> @@ -1673,16 +1695,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>                  * backed by a congested BDI and wait_iff_congested will stall.
>                  */
>                 if (nr_dirty && nr_dirty == nr_congested)
> -                       set_bit(ZONE_CONGESTED, &zone->flags);
> +                       set_bit(PGDAT_CONGESTED, &pgdat->flags);
>
>                 /*
>                  * If dirty pages are scanned that are not queued for IO, it
>                  * implies that flushers are not keeping up. In this case, flag
> -                * the zone ZONE_DIRTY and kswapd will start writing pages from
> +                * the pgdat PGDAT_DIRTY and kswapd will start writing pages from
>                  * reclaim context.
>                  */
>                 if (nr_unqueued_dirty == nr_taken)
> -                       set_bit(ZONE_DIRTY, &zone->flags);
> +                       set_bit(PGDAT_DIRTY, &pgdat->flags);
>
>                 /*
>                  * If kswapd scans pages marked marked for immediate
> @@ -1701,9 +1723,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>          */
>         if (!sc->hibernation_mode && !current_is_kswapd() &&
>             current_may_throttle())
> -               wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +               wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
>
> -       trace_mm_vmscan_lru_shrink_inactive(zone, nr_scanned, nr_reclaimed,
> +       trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
> +                       nr_scanned, nr_reclaimed,
>                         sc->priority, file);
>         return nr_reclaimed;
>  }
> @@ -1731,20 +1754,20 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>                                      struct list_head *pages_to_free,
>                                      enum lru_list lru)
>  {
> -       struct zone *zone = lruvec_zone(lruvec);
> +       struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>         unsigned long pgmoved = 0;
>         struct page *page;
>         int nr_pages;
>
>         while (!list_empty(list)) {
>                 page = lru_to_page(list);
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, pgdat);
>
>                 VM_BUG_ON_PAGE(PageLRU(page), page);
>                 SetPageLRU(page);
>
>                 nr_pages = hpage_nr_pages(page);
> -               update_lru_size(lruvec, lru, nr_pages);
> +               update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
>                 list_move(&page->lru, &lruvec->lists[lru]);
>                 pgmoved += nr_pages;
>
> @@ -1754,10 +1777,10 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>                         del_page_from_lru_list(page, lruvec, lru);
>
>                         if (unlikely(PageCompound(page))) {
> -                               spin_unlock_irq(zone_lru_lock(zone));
> +                               spin_unlock_irq(&pgdat->lru_lock);
>                                 mem_cgroup_uncharge(page);
>                                 (*get_compound_page_dtor(page))(page);
> -                               spin_lock_irq(zone_lru_lock(zone));
> +                               spin_lock_irq(&pgdat->lru_lock);
>                         } else
>                                 list_add(&page->lru, pages_to_free);
>                 }
> @@ -1783,7 +1806,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>         unsigned long nr_rotated = 0;
>         isolate_mode_t isolate_mode = 0;
>         int file = is_file_lru(lru);
> -       struct zone *zone = lruvec_zone(lruvec);
> +       struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>
>         lru_add_drain();
>
> @@ -1792,20 +1815,19 @@ static void shrink_active_list(unsigned long nr_to_scan,
>         if (!sc->may_writepage)
>                 isolate_mode |= ISOLATE_CLEAN;
>
> -       spin_lock_irq(zone_lru_lock(zone));
> +       spin_lock_irq(&pgdat->lru_lock);
>
>         nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
>                                      &nr_scanned, sc, isolate_mode, lru);
>
> -       update_lru_size(lruvec, lru, -nr_taken);
> -       __mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
> +       __mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>         reclaim_stat->recent_scanned[file] += nr_taken;
>
>         if (global_reclaim(sc))
> -               __mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
> -       __count_zone_vm_events(PGREFILL, zone, nr_scanned);
> +               __mod_node_page_state(pgdat, NR_PAGES_SCANNED, nr_scanned);
> +       __count_vm_events(PGREFILL, nr_scanned);
>
> -       spin_unlock_irq(zone_lru_lock(zone));
> +       spin_unlock_irq(&pgdat->lru_lock);
>
>         while (!list_empty(&l_hold)) {
>                 cond_resched();
> @@ -1850,7 +1872,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>         /*
>          * Move pages back to the lru list.
>          */
> -       spin_lock_irq(zone_lru_lock(zone));
> +       spin_lock_irq(&pgdat->lru_lock);
>         /*
>          * Count referenced pages from currently used mappings as rotated,
>          * even though only some of them are actually re-activated.  This
> @@ -1861,8 +1883,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
>
>         move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
>         move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> -       __mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
> -       spin_unlock_irq(zone_lru_lock(zone));
> +       __mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
> +       spin_unlock_irq(&pgdat->lru_lock);
>
>         mem_cgroup_uncharge_list(&l_hold);
>         free_hot_cold_page_list(&l_hold, true);
> @@ -1956,7 +1978,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>         struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>         u64 fraction[2];
>         u64 denominator = 0;    /* gcc */
> -       struct zone *zone = lruvec_zone(lruvec);
> +       struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>         unsigned long anon_prio, file_prio;
>         enum scan_balance scan_balance;
>         unsigned long anon, file;
> @@ -1977,7 +1999,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>          * well.
>          */
>         if (current_is_kswapd()) {
> -               if (!zone_reclaimable(zone))
> +               if (!pgdat_reclaimable(pgdat))
>                         force_scan = true;
>                 if (!mem_cgroup_online(memcg))
>                         force_scan = true;
> @@ -2023,14 +2045,24 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>          * anon pages.  Try to detect this based on file LRU size.
>          */
>         if (global_reclaim(sc)) {
> -               unsigned long zonefile;
> -               unsigned long zonefree;
> +               unsigned long pgdatfile;
> +               unsigned long pgdatfree;
> +               int z;
> +               unsigned long total_high_wmark = 0;
>
> -               zonefree = zone_page_state(zone, NR_FREE_PAGES);
> -               zonefile = zone_page_state(zone, NR_ACTIVE_FILE) +
> -                          zone_page_state(zone, NR_INACTIVE_FILE);
> +               pgdatfree = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
> +               pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
> +                          node_page_state(pgdat, NR_INACTIVE_FILE);
> +
> +               for (z = 0; z < MAX_NR_ZONES; z++) {
> +                       struct zone *zone = &pgdat->node_zones[z];
> +                       if (!populated_zone(zone))
> +                               continue;
> +
> +                       total_high_wmark += high_wmark_pages(zone);
> +               }
>
> -               if (unlikely(zonefile + zonefree <= high_wmark_pages(zone))) {
> +               if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
>                         scan_balance = SCAN_ANON;
>                         goto out;
>                 }
> @@ -2077,7 +2109,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>         file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE) +
>                 lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
>
> -       spin_lock_irq(zone_lru_lock(zone));
> +       spin_lock_irq(&pgdat->lru_lock);
>         if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
>                 reclaim_stat->recent_scanned[0] /= 2;
>                 reclaim_stat->recent_rotated[0] /= 2;
> @@ -2098,7 +2130,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>
>         fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
>         fp /= reclaim_stat->recent_rotated[1] + 1;
> -       spin_unlock_irq(zone_lru_lock(zone));
> +       spin_unlock_irq(&pgdat->lru_lock);
>
>         fraction[0] = ap;
>         fraction[1] = fp;
> @@ -2352,9 +2384,9 @@ static inline bool should_continue_reclaim(struct zone *zone,
>          * inactive lists are large enough, continue reclaiming
>          */
>         pages_for_compaction = (2UL << sc->order);
> -       inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
> +       inactive_lru_pages = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
>         if (get_nr_swap_pages() > 0)
> -               inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
> +               inactive_lru_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
>         if (sc->nr_reclaimed < pages_for_compaction &&
>                         inactive_lru_pages > pages_for_compaction)
>                 return true;
> @@ -2554,7 +2586,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>                                 continue;
>
>                         if (sc->priority != DEF_PRIORITY &&
> -                           !zone_reclaimable(zone))
> +                           !pgdat_reclaimable(zone->zone_pgdat))
>                                 continue;       /* Let kswapd poll it */
>
>                         /*
> @@ -2692,7 +2724,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>         for (i = 0; i <= ZONE_NORMAL; i++) {
>                 zone = &pgdat->node_zones[i];
>                 if (!populated_zone(zone) ||
> -                   zone_reclaimable_pages(zone) == 0)
> +                   pgdat_reclaimable_pages(pgdat) == 0)
>                         continue;
>
>                 pfmemalloc_reserve += min_wmark_pages(zone);
> @@ -3000,7 +3032,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
>                  * DEF_PRIORITY. Effectively, it considers them balanced so
>                  * they must be considered balanced here as well!
>                  */
> -               if (!zone_reclaimable(zone)) {
> +               if (!pgdat_reclaimable(zone->zone_pgdat)) {
>                         balanced_pages += zone->managed_pages;
>                         continue;
>                 }
> @@ -3063,6 +3095,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
>  {
>         unsigned long balance_gap;
>         bool lowmem_pressure;
> +       struct pglist_data *pgdat = zone->zone_pgdat;
>
>         /* Reclaim above the high watermark. */
>         sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
> @@ -3087,7 +3120,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
>
>         shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
>
> -       clear_bit(ZONE_WRITEBACK, &zone->flags);
> +       /* TODO: ANOMALY */
> +       clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
>
>         /*
>          * If a zone reaches its high watermark, consider it to be no longer
> @@ -3095,10 +3129,10 @@ static bool kswapd_shrink_zone(struct zone *zone,
>          * BDIs but as pressure is relieved, speculatively avoid congestion
>          * waits.
>          */
> -       if (zone_reclaimable(zone) &&
> +       if (pgdat_reclaimable(zone->zone_pgdat) &&
>             zone_balanced(zone, sc->order, false, 0, classzone_idx)) {
> -               clear_bit(ZONE_CONGESTED, &zone->flags);
> -               clear_bit(ZONE_DIRTY, &zone->flags);
> +               clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> +               clear_bit(PGDAT_DIRTY, &pgdat->flags);
>         }
>
>         return sc->nr_scanned >= sc->nr_to_reclaim;
> @@ -3157,7 +3191,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>                                 continue;
>
>                         if (sc.priority != DEF_PRIORITY &&
> -                           !zone_reclaimable(zone))
> +                           !pgdat_reclaimable(zone->zone_pgdat))
>                                 continue;
>
>                         /*
> @@ -3184,9 +3218,11 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>                                 /*
>                                  * If balanced, clear the dirty and congested
>                                  * flags
> +                                *
> +                                * TODO: ANOMALY
>                                  */
> -                               clear_bit(ZONE_CONGESTED, &zone->flags);
> -                               clear_bit(ZONE_DIRTY, &zone->flags);
> +                               clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
> +                               clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
>                         }
>                 }
>
> @@ -3216,7 +3252,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>                                 continue;
>
>                         if (sc.priority != DEF_PRIORITY &&
> -                           !zone_reclaimable(zone))
> +                           !pgdat_reclaimable(zone->zone_pgdat))
>                                 continue;
>
>                         sc.nr_scanned = 0;
> @@ -3612,8 +3648,8 @@ int sysctl_min_slab_ratio = 5;
>  static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
>  {
>         unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
> -       unsigned long file_lru = zone_page_state(zone, NR_INACTIVE_FILE) +
> -               zone_page_state(zone, NR_ACTIVE_FILE);
> +       unsigned long file_lru = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
> +               node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
>
>         /*
>          * It's possible for there to be more file mapped pages than
> @@ -3716,7 +3752,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>             zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
>                 return ZONE_RECLAIM_FULL;
>
> -       if (!zone_reclaimable(zone))
> +       if (!pgdat_reclaimable(zone->zone_pgdat))
>                 return ZONE_RECLAIM_FULL;
>
>         /*
> @@ -3795,7 +3831,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
>                         zone = pagezone;
>                         spin_lock_irq(zone_lru_lock(zone));
>                 }
> -               lruvec = mem_cgroup_page_lruvec(page, zone);
> +               lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>
>                 if (!PageLRU(page) || !PageUnevictable(page))
>                         continue;
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 3345d396a99b..de0c17076270 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -936,11 +936,8 @@ const char * const vmstat_text[] = {
>         /* enum zone_stat_item countes */
>         "nr_free_pages",
>         "nr_alloc_batch",
> -       "nr_inactive_anon",
> -       "nr_active_anon",
> -       "nr_inactive_file",
> -       "nr_active_file",
> -       "nr_unevictable",
> +       "nr_zone_anon_lru",
> +       "nr_zone_file_lru",
>         "nr_mlock",
>         "nr_anon_pages",
>         "nr_mapped",
> @@ -956,12 +953,9 @@ const char * const vmstat_text[] = {
>         "nr_vmscan_write",
>         "nr_vmscan_immediate_reclaim",
>         "nr_writeback_temp",
> -       "nr_isolated_anon",
> -       "nr_isolated_file",
>         "nr_shmem",
>         "nr_dirtied",
>         "nr_written",
> -       "nr_pages_scanned",
>  #if IS_ENABLED(CONFIG_ZSMALLOC)
>         "nr_zspages",
>  #endif
> @@ -981,6 +975,16 @@ const char * const vmstat_text[] = {
>         "nr_shmem_pmdmapped",
>         "nr_free_cma",
>
> +       /* Node-based counters */
> +       "nr_inactive_anon",
> +       "nr_active_anon",
> +       "nr_inactive_file",
> +       "nr_active_file",
> +       "nr_unevictable",
> +       "nr_isolated_anon",
> +       "nr_isolated_file",
> +       "nr_pages_scanned",
> +
>         /* enum writeback_stat_item counters */
>         "nr_dirty_threshold",
>         "nr_dirty_background_threshold",
> @@ -1002,11 +1006,11 @@ const char * const vmstat_text[] = {
>         "pgmajfault",
>         "pglazyfreed",
>
> -       TEXTS_FOR_ZONES("pgrefill")
> -       TEXTS_FOR_ZONES("pgsteal_kswapd")
> -       TEXTS_FOR_ZONES("pgsteal_direct")
> -       TEXTS_FOR_ZONES("pgscan_kswapd")
> -       TEXTS_FOR_ZONES("pgscan_direct")
> +       "pgrefill",
> +       "pgsteal_kswapd",
> +       "pgsteal_direct",
> +       "pgscan_kswapd",
> +       "pgscan_direct",
>         "pgscan_direct_throttle",
>
>  #ifdef CONFIG_NUMA
> @@ -1434,7 +1438,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>                    "\n        min      %lu"
>                    "\n        low      %lu"
>                    "\n        high     %lu"
> -                  "\n        scanned  %lu"
> +                  "\n   node_scanned  %lu"
>                    "\n        spanned  %lu"
>                    "\n        present  %lu"
>                    "\n        managed  %lu",
> @@ -1442,13 +1446,13 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>                    min_wmark_pages(zone),
>                    low_wmark_pages(zone),
>                    high_wmark_pages(zone),
> -                  zone_page_state(zone, NR_PAGES_SCANNED),
> +                  node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED),
>                    zone->spanned_pages,
>                    zone->present_pages,
>                    zone->managed_pages);
>
>         for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
> -               seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
> +               seq_printf(m, "\n      %-12s %lu", vmstat_text[i],
>                                 zone_page_state(zone, i));
>
>         seq_printf(m,
> @@ -1478,12 +1482,12 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  #endif
>         }
>         seq_printf(m,
> -                  "\n  all_unreclaimable: %u"
> -                  "\n  start_pfn:         %lu"
> -                  "\n  inactive_ratio:    %u",
> -                  !zone_reclaimable(zone),
> +                  "\n  node_unreclaimable:  %u"
> +                  "\n  start_pfn:           %lu"
> +                  "\n  node_inactive_ratio: %u",
> +                  !pgdat_reclaimable(zone->zone_pgdat),
>                    zone->zone_start_pfn,
> -                  zone->inactive_ratio);
> +                  zone->zone_pgdat->inactive_ratio);
>         seq_putc(m, '\n');
>  }
>
> @@ -1574,7 +1578,6 @@ static int vmstat_show(struct seq_file *m, void *arg)
>  {
>         unsigned long *l = arg;
>         unsigned long off = l - (unsigned long *)m->private;
> -
>         seq_printf(m, "%s %lu\n", vmstat_text[off], *l);
>         return 0;
>  }
> diff --git a/mm/workingset.c b/mm/workingset.c
> index ba972ac2dfdd..ebe14445809a 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -355,8 +355,8 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
>                 pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
>                                                      LRU_ALL_FILE);
>         } else {
> -               pages = sum_zone_node_page_state(sc->nid, NR_ACTIVE_FILE) +
> -                       sum_zone_node_page_state(sc->nid, NR_INACTIVE_FILE);
> +               pages = node_page_state(NODE_DATA(sc->nid), NR_ACTIVE_FILE) +
> +                       node_page_state(NODE_DATA(sc->nid), NR_INACTIVE_FILE);
>         }
>
>         /*
> --
> 2.6.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
