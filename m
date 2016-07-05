Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3E36B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 21:20:57 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u81so275267158oia.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:20:57 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g26si1059234ioj.174.2016.07.04.18.20.55
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 18:20:56 -0700 (PDT)
Date: Tue, 5 Jul 2016 10:19:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 03/31] mm, vmscan: move LRU lists to node
Message-ID: <20160705011957.GB28164@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1467403299-25786-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 01, 2016 at 09:01:11PM +0100, Mel Gorman wrote:
> This moves the LRU lists from the zone to the node and related data such
> as counters, tracing, congestion tracking and writeback tracking.
> Unfortunately, due to reclaim and compaction retry logic, it is necessary
> to account for the number of LRU pages on both zone and node logic.  Most
> reclaim logic is based on the node counters but the retry logic uses the
> zone counters which do not distinguish inactive and inactive sizes.  It

                                                      active

> would be possible to leave the LRU counters on a per-zone basis but it's a
> heavier calculation across multiple cache lines that is much more frequent
> than the retry checks.
> 
> Other than the LRU counters, this is mostly a mechanical patch but note
> that it introduces a number of anomalies.  For example, the scans are
> per-zone but using per-node counters.  We also mark a node as congested
> when a zone is congested.  This causes weird problems that are fixed later
> but is easier to review.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  arch/tile/mm/pgtable.c                    |   8 +-
>  drivers/base/node.c                       |  19 +--
>  drivers/staging/android/lowmemorykiller.c |   8 +-
>  include/linux/backing-dev.h               |   2 +-
>  include/linux/memcontrol.h                |  16 +--
>  include/linux/mm_inline.h                 |  21 ++-
>  include/linux/mmzone.h                    |  69 +++++----
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
>  mm/page_alloc.c                           |  70 ++++-----
>  mm/swap.c                                 |  50 +++----
>  mm/vmscan.c                               | 226 +++++++++++++++++-------------
>  mm/vmstat.c                               |  47 ++++---
>  mm/workingset.c                           |   4 +-
>  29 files changed, 387 insertions(+), 300 deletions(-)
> 
> diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
> index c4d5bf841a7f..9e389213580d 100644
> --- a/arch/tile/mm/pgtable.c
> +++ b/arch/tile/mm/pgtable.c
> @@ -45,10 +45,10 @@ void show_mem(unsigned int filter)
>  	struct zone *zone;
>  
>  	pr_err("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
> -	       (global_page_state(NR_ACTIVE_ANON) +
> -		global_page_state(NR_ACTIVE_FILE)),
> -	       (global_page_state(NR_INACTIVE_ANON) +
> -		global_page_state(NR_INACTIVE_FILE)),
> +	       (global_node_page_state(NR_ACTIVE_ANON) +
> +		global_node_page_state(NR_ACTIVE_FILE)),
> +	       (global_node_page_state(NR_INACTIVE_ANON) +
> +		global_node_page_state(NR_INACTIVE_FILE)),
>  	       global_page_state(NR_FILE_DIRTY),
>  	       global_page_state(NR_WRITEBACK),
>  	       global_page_state(NR_UNSTABLE_NFS),
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 92d8e090c5b3..b7f01a4a642d 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -56,6 +56,7 @@ static ssize_t node_read_meminfo(struct device *dev,
>  {
>  	int n;
>  	int nid = dev->id;
> +	struct pglist_data *pgdat = NODE_DATA(nid);
>  	struct sysinfo i;
>  
>  	si_meminfo_node(&i, nid);
> @@ -74,15 +75,15 @@ static ssize_t node_read_meminfo(struct device *dev,
>  		       nid, K(i.totalram),
>  		       nid, K(i.freeram),
>  		       nid, K(i.totalram - i.freeram),
> -		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON) +
> -				sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
> -		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON) +
> -				sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
> -		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON)),
> -		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON)),
> -		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
> -		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
> -		       nid, K(sum_zone_node_page_state(nid, NR_UNEVICTABLE)),
> +		       nid, K(node_page_state(pgdat, NR_ACTIVE_ANON) +
> +				node_page_state(pgdat, NR_ACTIVE_FILE)),
> +		       nid, K(node_page_state(pgdat, NR_INACTIVE_ANON) +
> +				node_page_state(pgdat, NR_INACTIVE_FILE)),
> +		       nid, K(node_page_state(pgdat, NR_ACTIVE_ANON)),
> +		       nid, K(node_page_state(pgdat, NR_INACTIVE_ANON)),
> +		       nid, K(node_page_state(pgdat, NR_ACTIVE_FILE)),
> +		       nid, K(node_page_state(pgdat, NR_INACTIVE_FILE)),
> +		       nid, K(node_page_state(pgdat, NR_UNEVICTABLE)),
>  		       nid, K(sum_zone_node_page_state(nid, NR_MLOCK)));
>  
>  #ifdef CONFIG_HIGHMEM
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> index 24d2745e9437..93dbcc38eb0f 100644
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -72,10 +72,10 @@ static unsigned long lowmem_deathpending_timeout;
>  static unsigned long lowmem_count(struct shrinker *s,
>  				  struct shrink_control *sc)
>  {
> -	return global_page_state(NR_ACTIVE_ANON) +
> -		global_page_state(NR_ACTIVE_FILE) +
> -		global_page_state(NR_INACTIVE_ANON) +
> -		global_page_state(NR_INACTIVE_FILE);
> +	return global_node_page_state(NR_ACTIVE_ANON) +
> +		global_node_page_state(NR_ACTIVE_FILE) +
> +		global_node_page_state(NR_INACTIVE_ANON) +
> +		global_node_page_state(NR_INACTIVE_FILE);
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
>  		void __user *buffer, size_t *lenp, loff_t *ppos);
>  
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 104efa6874db..1927dcb6921e 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -340,7 +340,7 @@ static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>  	struct lruvec *lruvec;
>  
>  	if (mem_cgroup_disabled()) {
> -		lruvec = &zone->lruvec;
> +		lruvec = zone_lruvec(zone);
>  		goto out;
>  	}
>  
> @@ -352,12 +352,12 @@ static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>  	 * we have to be prepared to initialize lruvec->zone here;

                                                lruvec->pgdat

>  	 * and if offlined then reonlined, we need to reinitialize it.
>  	 */
> -	if (unlikely(lruvec->zone != zone))
> -		lruvec->zone = zone;
> +	if (unlikely(lruvec->pgdat != zone->zone_pgdat))
> +		lruvec->pgdat = zone->zone_pgdat;


>  	return lruvec;
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
> -		int nr_pages);
> +		enum zone_type zid, int nr_pages);
>  
>  unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
>  					   int nid, unsigned int lru_mask);
> @@ -613,13 +613,13 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
>  static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>  						    struct mem_cgroup *memcg)
>  {
> -	return &zone->lruvec;
> +	return zone_lruvec(zone);
>  }
>  
>  static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
> -						    struct zone *zone)
> +						    struct pglist_data *pgdat)
>  {
> -	return &zone->lruvec;
> +	return &pgdat->lruvec;
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
> -				enum lru_list lru, int nr_pages)
> +				enum lru_list lru, enum zone_type zid,
> +				int nr_pages)
>  {
> -	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
> +	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> +
> +	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, nr_pages);
> +	__mod_zone_page_state(&pgdat->node_zones[zid],
> +		NR_ZONE_LRU_BASE + !!is_file_lru(lru),
> +		nr_pages);
>  }
>  
>  static __always_inline void update_lru_size(struct lruvec *lruvec,
> -				enum lru_list lru, int nr_pages)
> +				enum lru_list lru, enum zone_type zid,
> +				int nr_pages)
>  {
>  #ifdef CONFIG_MEMCG
> -	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
> +	mem_cgroup_update_lru_size(lruvec, lru, zid, nr_pages);
>  #else
> -	__update_lru_size(lruvec, lru, nr_pages);
> +	__update_lru_size(lruvec, lru, zid, nr_pages);
>  #endif
>  }
>  
>  static __always_inline void add_page_to_lru_list(struct page *page,
>  				struct lruvec *lruvec, enum lru_list lru)
>  {
> -	update_lru_size(lruvec, lru, hpage_nr_pages(page));
> +	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
>  	list_add(&page->lru, &lruvec->lists[lru]);
>  }
>  
> @@ -49,7 +56,7 @@ static __always_inline void del_page_from_lru_list(struct page *page,
>  				struct lruvec *lruvec, enum lru_list lru)
>  {
>  	list_del(&page->lru);
> -	update_lru_size(lruvec, lru, -hpage_nr_pages(page));
> +	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
>  }
>  
>  /**
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2d5087e3c034..258c20758e80 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -111,12 +111,9 @@ enum zone_stat_item {
>  	/* First 128 byte cacheline (assuming 64 bit words) */
>  	NR_FREE_PAGES,
>  	NR_ALLOC_BATCH,
> -	NR_LRU_BASE,
> -	NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
> -	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
> -	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
> -	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
> -	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
> +	NR_ZONE_LRU_BASE, /* Used only for compaction and reclaim retry */
> +	NR_ZONE_LRU_ANON = NR_ZONE_LRU_BASE,
> +	NR_ZONE_LRU_FILE,
>  	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
>  	NR_ANON_PAGES,	/* Mapped anonymous pages */
>  	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
> @@ -134,12 +131,9 @@ enum zone_stat_item {
>  	NR_VMSCAN_WRITE,
>  	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
>  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> -	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
> -	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
>  	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
>  	NR_DIRTIED,		/* page dirtyings since bootup */
>  	NR_WRITTEN,		/* page writings since bootup */
> -	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
>  #if IS_ENABLED(CONFIG_ZSMALLOC)
>  	NR_ZSPAGES,		/* allocated in zsmalloc */
>  #endif
> @@ -161,6 +155,15 @@ enum zone_stat_item {
>  	NR_VM_ZONE_STAT_ITEMS };
>  
>  enum node_stat_item {
> +	NR_LRU_BASE,
> +	NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
> +	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
> +	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
> +	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
> +	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
> +	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
> +	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> +	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
>  	NR_VM_NODE_STAT_ITEMS
>  };
>  
> @@ -219,7 +222,7 @@ struct lruvec {
>  	/* Evictions & activations on the inactive file list */
>  	atomic_long_t			inactive_age;
>  #ifdef CONFIG_MEMCG
> -	struct zone			*zone;
> +	struct pglist_data *pgdat;
>  #endif
>  };
>  
> @@ -357,13 +360,6 @@ struct zone {
>  #ifdef CONFIG_NUMA
>  	int node;
>  #endif
> -
> -	/*
> -	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
> -	 * this zone's LRU.  Maintained by the pageout code.
> -	 */
> -	unsigned int inactive_ratio;
> -
>  	struct pglist_data	*zone_pgdat;
>  	struct per_cpu_pageset __percpu *pageset;
>  
> @@ -495,9 +491,6 @@ struct zone {
>  
>  	/* Write-intensive fields used by page reclaim */

trivial:
We moved lru_lock and lruvec to pgdat so I'm not sure we need ZONE_PADDING,
still.

>  
> -	/* Fields commonly accessed by the page reclaim scanner */
> -	struct lruvec		lruvec;
> -
>  	/*
>  	 * When free pages are below this point, additional steps are taken
>  	 * when reading the number of free pages to avoid per-cpu counter
> @@ -537,17 +530,20 @@ struct zone {
>  
>  enum zone_flags {
>  	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
> -	ZONE_CONGESTED,			/* zone has many dirty pages backed by
> +	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
> +};
> +

> +enum pgdat_flags {
> +	PGDAT_CONGESTED,		/* zone has many dirty pages backed by

                                           node or pgdat, whatever.

>  					 * a congested BDI
>  					 */
> -	ZONE_DIRTY,			/* reclaim scanning has recently found
> +	PGDAT_DIRTY,			/* reclaim scanning has recently found
>  					 * many dirty file pages at the tail
>  					 * of the LRU.
>  					 */
> -	ZONE_WRITEBACK,			/* reclaim scanning has recently found
> +	PGDAT_WRITEBACK,		/* reclaim scanning has recently found
>  					 * many pages under writeback
>  					 */
> -	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
>  };
>  
>  static inline unsigned long zone_end_pfn(const struct zone *zone)
> @@ -701,12 +697,26 @@ typedef struct pglist_data {
>  	unsigned long first_deferred_pfn;
>  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>  
> +

Unnecessary change.

>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	spinlock_t split_queue_lock;
>  	struct list_head split_queue;
>  	unsigned long split_queue_len;
>  #endif
>  
> +	/* Fields commonly accessed by the page reclaim scanner */
> +	struct lruvec		lruvec;
> +
> +	/*
> +	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
> +	 * this node's LRU.  Maintained by the pageout code.
> +	 */
> +	unsigned int inactive_ratio;
> +
> +	unsigned long		flags;
> +
> +	ZONE_PADDING(_pad2_)
> +
>  	/* Per-node vmstats */
>  	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
>  	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
> @@ -728,6 +738,11 @@ static inline spinlock_t *zone_lru_lock(struct zone *zone)
>  	return &zone->zone_pgdat->lru_lock;
>  }
>  
> +static inline struct lruvec *zone_lruvec(struct zone *zone)
> +{
> +	return &zone->zone_pgdat->lruvec;
> +}
> +
>  static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
>  {
>  	return pgdat->node_start_pfn + pgdat->node_spanned_pages;
> @@ -779,12 +794,12 @@ extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
>  
>  extern void lruvec_init(struct lruvec *lruvec);
>  
> -static inline struct zone *lruvec_zone(struct lruvec *lruvec)
> +static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
>  {
>  #ifdef CONFIG_MEMCG
> -	return lruvec->zone;
> +	return lruvec->pgdat;
>  #else
> -	return container_of(lruvec, struct zone, lruvec);
> +	return container_of(lruvec, struct pglist_data, lruvec);
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
>  					gfp_t gfp_mask, nodemask_t *mask);
>  extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 42604173f122..1798ff542517 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -26,11 +26,11 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		PGFREE, PGACTIVATE, PGDEACTIVATE,
>  		PGFAULT, PGMAJFAULT,
>  		PGLAZYFREED,
> -		FOR_ALL_ZONES(PGREFILL),
> -		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
> -		FOR_ALL_ZONES(PGSTEAL_DIRECT),
> -		FOR_ALL_ZONES(PGSCAN_KSWAPD),
> -		FOR_ALL_ZONES(PGSCAN_DIRECT),
> +		PGREFILL,
> +		PGSTEAL_KSWAPD,
> +		PGSTEAL_DIRECT,
> +		PGSCAN_KSWAPD,
> +		PGSCAN_DIRECT,
>  		PGSCAN_DIRECT_THROTTLE,
>  #ifdef CONFIG_NUMA
>  		PGSCAN_ZONE_RECLAIM_FAILED,
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index d1744aa3ab9c..ced0c3e9da88 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -178,6 +178,23 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
>  	return x;
>  }
>  
> +static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
> +					enum zone_stat_item item)

                                        enum node_stat_item

> +{
> +	long x = atomic_long_read(&pgdat->vm_stat[item]);
> +
> +#ifdef CONFIG_SMP
> +	int cpu;
> +	for_each_online_cpu(cpu)
> +		x += per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->vm_node_stat_diff[item];
> +
> +	if (x < 0)
> +		x = 0;
> +#endif
> +	return x;
> +}
> +
> +
>  #ifdef CONFIG_NUMA
>  extern unsigned long sum_zone_node_page_state(int node,
>  						enum zone_stat_item item);

<snip>

> @@ -1147,9 +1147,9 @@ static void free_one_page(struct zone *zone,
>  {
>  	unsigned long nr_scanned;
>  	spin_lock(&zone->lock);
> -	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> +	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
>  	if (nr_scanned)
> -		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
> +		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
>  
>  	if (unlikely(has_isolate_pageblock(zone) ||
>  		is_migrate_isolate(migratetype))) {
> @@ -3526,7 +3526,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  
>  		available = reclaimable = zone_reclaimable_pages(zone);
>  		available -= DIV_ROUND_UP(no_progress_loops * available,
> -					  MAX_RECLAIM_RETRIES);
> +					MAX_RECLAIM_RETRIES);

Unnecessary change.

>  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>  
>  		/*
> @@ -4331,6 +4331,7 @@ void show_free_areas(unsigned int filter)

<snip.

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

When I read below commit, one of the reason it was introduced is whether we
should continue to reclaim page or not.
At that time, several people wanted it by my guessing [suggested|acked]-by
so I think we should notice it to them.

Michal?

[9f6c399ddc36, consider isolated pages in zone_reclaimable_pages],

> + */
>  unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
>  	unsigned long nr;
>  
> -	nr = zone_page_state_snapshot(zone, NR_ACTIVE_FILE) +
> -	     zone_page_state_snapshot(zone, NR_INACTIVE_FILE) +
> -	     zone_page_state_snapshot(zone, NR_ISOLATED_FILE);
> +	nr = zone_page_state_snapshot(zone, NR_ZONE_LRU_FILE);
> +	if (get_nr_swap_pages() > 0)
> +		nr += zone_page_state_snapshot(zone, NR_ZONE_LRU_ANON);
> +
> +	return nr;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
