Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1486B0039
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 15:48:04 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so1398468pdj.35
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:48:04 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id zi2si9883578pbb.138.2014.07.14.12.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 12:48:03 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so3520505pdj.30
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:48:02 -0700 (PDT)
Date: Mon, 14 Jul 2014 12:46:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 3/3] mm: vmscan: clean up struct scan_control
In-Reply-To: <1405344049-19868-4-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1407141240200.17669@eggly.anvils>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org> <1405344049-19868-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Jul 2014, Johannes Weiner wrote:

> Reorder the members by input and output, then turn the individual
> integers for may_writepage, may_unmap, may_swap, compaction_ready,
> hibernation_mode into flags that fit into a single integer.
> 
> Stack delta: +72/-296 -224                   old     new   delta
> kswapd                                       104     176     +72
> try_to_free_pages                             80      56     -24
> try_to_free_mem_cgroup_pages                  80      56     -24
> shrink_all_memory                             88      64     -24
> reclaim_clean_pages_from_list                168     144     -24
> mem_cgroup_shrink_node_zone                  104      80     -24
> __zone_reclaim                               176     152     -24
> balance_pgdat                                152       -    -152
> 
>    text    data     bss     dec     hex filename
>   38151    5641      16   43808    ab20 mm/vmscan.o.old
>   38047    5641      16   43704    aab8 mm/vmscan.o
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 158 ++++++++++++++++++++++++++++++------------------------------
>  1 file changed, 78 insertions(+), 80 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c28b8981e56a..73d8e69ff3eb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -58,36 +58,28 @@
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/vmscan.h>
>  
> -struct scan_control {
> -	/* Incremented by the number of inactive pages that were scanned */
> -	unsigned long nr_scanned;
> -
> -	/* Number of pages freed so far during a call to shrink_zones() */
> -	unsigned long nr_reclaimed;
> -
> -	/* One of the zones is ready for compaction */
> -	int compaction_ready;
> +/* Scan control flags */
> +#define MAY_WRITEPAGE		0x1
> +#define MAY_UNMAP		0x2
> +#define MAY_SWAP		0x4
> +#define MAY_SKIP_CONGESTION	0x8
> +#define COMPACTION_READY	0x10
>  
> +struct scan_control {
>  	/* How many pages shrink_list() should reclaim */
>  	unsigned long nr_to_reclaim;
>  
> -	unsigned long hibernation_mode;
> -
>  	/* This context's GFP mask */
>  	gfp_t gfp_mask;
>  
> -	int may_writepage;
> -
> -	/* Can mapped pages be reclaimed? */
> -	int may_unmap;
> -
> -	/* Can pages be swapped as part of reclaim? */
> -	int may_swap;
> -
> +	/* Allocation order */
>  	int order;
>  
> -	/* Scan (total_size >> priority) pages at once */
> -	int priority;
> +	/*
> +	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
> +	 * are scanned.
> +	 */
> +	nodemask_t	*nodemask;
>  
>  	/*
>  	 * The memory cgroup that hit its limit and as a result is the
> @@ -95,11 +87,17 @@ struct scan_control {
>  	 */
>  	struct mem_cgroup *target_mem_cgroup;
>  
> -	/*
> -	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
> -	 * are scanned.
> -	 */
> -	nodemask_t	*nodemask;
> +	/* Scan (total_size >> priority) pages at once */
> +	int priority;
> +
> +	/* Scan control flags; see above */
> +	unsigned int flags;

This seems to result in a fair amount of unnecessary churn:
why not just put may_writepage etc into an unsigned int bitfield,
then you get the saving without changing all the rest of the code.

Hugh

> +
> +	/* Incremented by the number of inactive pages that were scanned */
> +	unsigned long nr_scanned;
> +
> +	/* Number of pages freed so far during a call to shrink_zones() */
> +	unsigned long nr_reclaimed;
>  };
>  
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> @@ -840,7 +838,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (unlikely(!page_evictable(page)))
>  			goto cull_mlocked;
>  
> -		if (!sc->may_unmap && page_mapped(page))
> +		if (!(sc->flags & MAY_UNMAP) && page_mapped(page))
>  			goto keep_locked;
>  
>  		/* Double the slab pressure for mapped and swapcache pages */
> @@ -1014,7 +1012,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  			if (!may_enter_fs)
>  				goto keep_locked;
> -			if (!sc->may_writepage)
> +			if (!(sc->flags & MAY_WRITEPAGE))
>  				goto keep_locked;
>  
>  			/* Page is dirty, try to write it out here */
> @@ -1146,7 +1144,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  	struct scan_control sc = {
>  		.gfp_mask = GFP_KERNEL,
>  		.priority = DEF_PRIORITY,
> -		.may_unmap = 1,
> +		.flags = MAY_UNMAP,
>  	};
>  	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
>  	struct page *page, *next;
> @@ -1489,9 +1487,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  
>  	lru_add_drain();
>  
> -	if (!sc->may_unmap)
> +	if (!(sc->flags & MAY_UNMAP))
>  		isolate_mode |= ISOLATE_UNMAPPED;
> -	if (!sc->may_writepage)
> +	if (!(sc->flags & MAY_WRITEPAGE))
>  		isolate_mode |= ISOLATE_CLEAN;
>  
>  	spin_lock_irq(&zone->lru_lock);
> @@ -1593,7 +1591,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	 * is congested. Allow kswapd to continue until it starts encountering
>  	 * unqueued dirty pages or cycling through the LRU too quickly.
>  	 */
> -	if (!sc->hibernation_mode && !current_is_kswapd() &&
> +	if (!(sc->flags & MAY_SKIP_CONGESTION) && !current_is_kswapd() &&
>  	    current_may_throttle())
>  		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
>  
> @@ -1683,9 +1681,9 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  
>  	lru_add_drain();
>  
> -	if (!sc->may_unmap)
> +	if (!(sc->flags & MAY_UNMAP))
>  		isolate_mode |= ISOLATE_UNMAPPED;
> -	if (!sc->may_writepage)
> +	if (!(sc->flags & MAY_WRITEPAGE))
>  		isolate_mode |= ISOLATE_CLEAN;
>  
>  	spin_lock_irq(&zone->lru_lock);
> @@ -1897,7 +1895,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
>  		force_scan = true;
>  
>  	/* If we have no swap space, do not bother scanning anon pages. */
> -	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
> +	if (!(sc->flags & MAY_SWAP) || (get_nr_swap_pages() <= 0)) {
>  		scan_balance = SCAN_FILE;
>  		goto out;
>  	}
> @@ -2406,7 +2404,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
>  			    zonelist_zone_idx(z) <= requested_highidx &&
>  			    compaction_ready(zone, sc->order)) {
> -				sc->compaction_ready = true;
> +				sc->flags |= COMPACTION_READY;
>  				continue;
>  			}
>  
> @@ -2496,7 +2494,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
>  			break;
>  
> -		if (sc->compaction_ready)
> +		if (sc->flags & COMPACTION_READY)
>  			break;
>  
>  		/*
> @@ -2504,7 +2502,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		 * writepage even in laptop mode.
>  		 */
>  		if (sc->priority < DEF_PRIORITY - 2)
> -			sc->may_writepage = 1;
> +			sc->flags |= MAY_WRITEPAGE;
>  
>  		/*
>  		 * Try to write back as many pages as we just scanned.  This
> @@ -2517,7 +2515,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		if (total_scanned > writeback_threshold) {
>  			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
>  						WB_REASON_TRY_TO_FREE_PAGES);
> -			sc->may_writepage = 1;
> +			sc->flags |= MAY_WRITEPAGE;
>  		}
>  	} while (--sc->priority >= 0);
>  
> @@ -2527,7 +2525,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		return sc->nr_reclaimed;
>  
>  	/* Aborted reclaim to try compaction? don't OOM, then */
> -	if (sc->compaction_ready)
> +	if (sc->flags & COMPACTION_READY)
>  		return 1;
>  
>  	/* Any of the zones still reclaimable?  Don't OOM. */
> @@ -2668,17 +2666,17 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  {
>  	unsigned long nr_reclaimed;
>  	struct scan_control sc = {
> -		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
> -		.may_writepage = !laptop_mode,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> -		.may_unmap = 1,
> -		.may_swap = 1,
> +		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
>  		.order = order,
> -		.priority = DEF_PRIORITY,
> -		.target_mem_cgroup = NULL,
>  		.nodemask = nodemask,
> +		.priority = DEF_PRIORITY,
> +		.flags = MAY_UNMAP | MAY_SWAP,
>  	};
>  
> +	if (!laptop_mode)
> +		sc.flags |= MAY_WRITEPAGE;
> +
>  	/*
>  	 * Do not enter reclaim if fatal signal was delivered while throttled.
>  	 * 1 is returned so that the page allocator does not OOM kill at this
> @@ -2688,7 +2686,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  		return 1;
>  
>  	trace_mm_vmscan_direct_reclaim_begin(order,
> -				sc.may_writepage,
> +				sc.flags & MAY_WRITEPAGE,
>  				gfp_mask);
>  
>  	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> @@ -2706,23 +2704,22 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
>  						unsigned long *nr_scanned)
>  {
>  	struct scan_control sc = {
> -		.nr_scanned = 0,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> -		.may_writepage = !laptop_mode,
> -		.may_unmap = 1,
> -		.may_swap = !noswap,
> -		.order = 0,
> -		.priority = 0,
> +		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> +		            (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
>  		.target_mem_cgroup = memcg,
> +		.flags = MAY_UNMAP,
>  	};
>  	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  	int swappiness = mem_cgroup_swappiness(memcg);
>  
> -	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> -			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> +	if (!laptop_mode)
> +		sc.flags |= MAY_WRITEPAGE;
> +	if (!noswap)
> +		sc.flags |= MAY_SWAP;
>  
>  	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
> -						      sc.may_writepage,
> +						      sc.flags & MAY_WRITEPAGE,
>  						      sc.gfp_mask);
>  
>  	/*
> @@ -2748,18 +2745,19 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  	unsigned long nr_reclaimed;
>  	int nid;
>  	struct scan_control sc = {
> -		.may_writepage = !laptop_mode,
> -		.may_unmap = 1,
> -		.may_swap = !noswap,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> -		.order = 0,
> -		.priority = DEF_PRIORITY,
> -		.target_mem_cgroup = memcg,
> -		.nodemask = NULL, /* we don't care the placement */
>  		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> -				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
> +		            (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
> +		.target_mem_cgroup = memcg,
> +		.priority = DEF_PRIORITY,
> +		.flags = MAY_UNMAP,
>  	};
>  
> +	if (!laptop_mode)
> +		sc.flags |= MAY_WRITEPAGE;
> +	if (!noswap)
> +		sc.flags |= MAY_SWAP;
> +
>  	/*
>  	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
>  	 * take care of from where we get pages. So the node where we start the
> @@ -2770,7 +2768,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  	zonelist = NODE_DATA(nid)->node_zonelists;
>  
>  	trace_mm_vmscan_memcg_reclaim_begin(0,
> -					    sc.may_writepage,
> +					    sc.flags & MAY_WRITEPAGE,
>  					    sc.gfp_mask);
>  
>  	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> @@ -3015,15 +3013,15 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  	unsigned long nr_soft_scanned;
>  	struct scan_control sc = {
>  		.gfp_mask = GFP_KERNEL,
> -		.priority = DEF_PRIORITY,
> -		.may_unmap = 1,
> -		.may_swap = 1,
> -		.may_writepage = !laptop_mode,
>  		.order = order,
> -		.target_mem_cgroup = NULL,
> +		.priority = DEF_PRIORITY,
> +		.flags = MAY_UNMAP | MAY_SWAP,
>  	};
>  	count_vm_event(PAGEOUTRUN);
>  
> +	if (!laptop_mode)
> +		sc.flags |= MAY_WRITEPAGE;
> +
>  	do {
>  		unsigned long lru_pages = 0;
>  		unsigned long nr_attempted = 0;
> @@ -3104,7 +3102,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  		 * even in laptop mode.
>  		 */
>  		if (sc.priority < DEF_PRIORITY - 2)
> -			sc.may_writepage = 1;
> +			sc.flags |= MAY_WRITEPAGE;
>  
>  		/*
>  		 * Now scan the zone in the dma->highmem direction, stopping
> @@ -3401,14 +3399,11 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  {
>  	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
> -		.gfp_mask = GFP_HIGHUSER_MOVABLE,
> -		.may_swap = 1,
> -		.may_unmap = 1,
> -		.may_writepage = 1,
>  		.nr_to_reclaim = nr_to_reclaim,
> -		.hibernation_mode = 1,
> -		.order = 0,
> +		.gfp_mask = GFP_HIGHUSER_MOVABLE,
>  		.priority = DEF_PRIORITY,
> +		.flags = MAY_WRITEPAGE | MAY_UNMAP | MAY_SWAP |
> +		         MAY_SKIP_CONGESTION,
>  	};
>  	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
>  	struct task_struct *p = current;
> @@ -3588,19 +3583,22 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	struct task_struct *p = current;
>  	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
> -		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> -		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> -		.may_swap = 1,
>  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
>  		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
>  		.order = order,
>  		.priority = ZONE_RECLAIM_PRIORITY,
> +		.flags = MAY_SWAP,
>  	};
>  	struct shrink_control shrink = {
>  		.gfp_mask = sc.gfp_mask,
>  	};
>  	unsigned long nr_slab_pages0, nr_slab_pages1;
>  
> +	if (zone_reclaim_mode & RECLAIM_WRITE)
> +		sc.flags |= MAY_WRITEPAGE;
> +	if (zone_reclaim_mode & RECLAIM_SWAP)
> +		sc.flags |= MAY_UNMAP;
> +
>  	cond_resched();
>  	/*
>  	 * We need to be able to allocate from the reserves for RECLAIM_SWAP
> -- 
> 2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
