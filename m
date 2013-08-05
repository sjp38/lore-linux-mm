Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 151506B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 03:41:49 -0400 (EDT)
Date: Mon, 5 Aug 2013 09:41:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [resend] [PATCH] mm: vmscan: fix do_try_to_free_pages() livelock
Message-ID: <20130805074146.GD10146@dhcp22.suse.cz>
References: <89813612683626448B837EE5A0B6A7CB3B630BE80B@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B630BE80B@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>

It would help to CC all people mentioned in Cc: ;)

On Sun 04-08-13 19:26:38, Lisa Du wrote:
> From: Lisa Du <cldu@marvell.com>
> Date: Mon, 5 Aug 2013 09:26:57 +0800
> Subject: [PATCH] mm: vmscan: fix do_try_to_free_pages() livelock
> 
> This patch is based on KOSAKI's work and I add a little more
> description, please refer https://lkml.org/lkml/2012/6/14/74.
> 
> Currently, I found system can enter a state that there are lots
> of free pages in a zone but only order-0 and order-1 pages which
> means the zone is heavily fragmented, then high order allocation
> could make direct reclaim path's long stall(ex, 60 seconds)
> especially in no swap and no compaciton enviroment. This problem
> happened on v3.4, but it seems issue still lives in current tree,
> the reason is do_try_to_free_pages enter live lock:
> 
> kswapd will go to sleep if the zones have been fully scanned
> and are still not balanced. As kswapd thinks there's little point
> trying all over again to avoid infinite loop. Instead it changes
> order from high-order to 0-order because kswapd think order-0 is the
> most important. Look at 73ce02e9 in detail. If watermarks are ok,
> kswapd will go back to sleep and may leave zone->all_unreclaimable = 0.
> It assume high-order users can still perform direct reclaim if they wish.
> 
> Direct reclaim continue to reclaim for a high order which is not a
> COSTLY_ORDER without oom-killer until kswapd turn on zone->all_unreclaimble.
> This is because to avoid too early oom-kill. So it means direct_reclaim
> depends on kswapd to break this loop.
> 
> In worst case, direct-reclaim may continue to page reclaim forever
> when kswapd sleeps forever until someone like watchdog detect and finally
> kill the process. As described in:
> http://thread.gmane.org/gmane.linux.kernel.mm/103737
> 
> We can't turn on zone->all_unreclaimable from direct reclaim path
> because direct reclaim path don't take any lock and this way is racy.
> Thus this patch removes zone->all_unreclaimable field completely and
> recalculates zone reclaimable state every time.
> 
> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
> directly and kswapd continue to use zone->all_unreclaimable. Because, it
> is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
> zone->all_unreclaimable as a name) describes the detail.
> 
> Change-Id: If3b44e33e400c1db0e42a5e2fc9ebc7a265f2aae
> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Cc: Ying Han <yinghan@google.com>
> Cc: Nick Piggin <npiggin@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Bob Liu <lliubbo@gmail.com>
> Cc: Neil Zhang <zhangwm@marvell.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Lisa Du <cldu@marvell.com>

all_unreclaimable was just a bad idea from the very beginning

Same as the last time
Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  include/linux/mm_inline.h |   20 ++++++++++++++++++++
>  include/linux/mmzone.h    |    1 -
>  include/linux/vmstat.h    |    1 -
>  mm/page-writeback.c       |    1 +
>  mm/page_alloc.c           |    5 ++---
>  mm/vmscan.c               |   43 ++++++++++---------------------------------
>  mm/vmstat.c               |    3 ++-
>  7 files changed, 35 insertions(+), 39 deletions(-)
> 
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index 1397ccf..e212fae 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -2,6 +2,7 @@
>  #define LINUX_MM_INLINE_H
>  
>  #include <linux/huge_mm.h>
> +#include <linux/swap.h>
>  
>  /**
>   * page_is_file_cache - should the page be on a file LRU or anon LRU?
> @@ -99,4 +100,23 @@ static __always_inline enum lru_list page_lru(struct page *page)
>  	return lru;
>  }
>  
> +static inline unsigned long zone_reclaimable_pages(struct zone *zone)
> +{
> +	int nr;
> +
> +	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> +	     zone_page_state(zone, NR_INACTIVE_FILE);
> +
> +	if (get_nr_swap_pages() > 0)
> +		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> +		      zone_page_state(zone, NR_INACTIVE_ANON);
> +
> +	return nr;
> +}
> +
> +static inline bool zone_reclaimable(struct zone *zone)
> +{
> +	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
> +}
> +
>  #endif
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index af4a3b7..e835974 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -352,7 +352,6 @@ struct zone {
>  	 * free areas of different sizes
>  	 */
>  	spinlock_t		lock;
> -	int                     all_unreclaimable; /* All pages pinned */
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>  	/* Set to true when the PG_migrate_skip bits should be cleared */
>  	bool			compact_blockskip_flush;
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index c586679..6fff004 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -143,7 +143,6 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
>  }
>  
>  extern unsigned long global_reclaimable_pages(void);
> -extern unsigned long zone_reclaimable_pages(struct zone *zone);
>  
>  #ifdef CONFIG_NUMA
>  /*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 3f0c895..62bfd92 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -36,6 +36,7 @@
>  #include <linux/pagevec.h>
>  #include <linux/timer.h>
>  #include <linux/sched/rt.h>
> +#include <linux/mm_inline.h>
>  #include <trace/events/writeback.h>
>  
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b100255..19a18c0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -60,6 +60,7 @@
>  #include <linux/page-debug-flags.h>
>  #include <linux/hugetlb.h>
>  #include <linux/sched/rt.h>
> +#include <linux/mm_inline.h>
>  
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -647,7 +648,6 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  	int to_free = count;
>  
>  	spin_lock(&zone->lock);
> -	zone->all_unreclaimable = 0;
>  	zone->pages_scanned = 0;
>  
>  	while (to_free) {
> @@ -696,7 +696,6 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
>  				int migratetype)
>  {
>  	spin_lock(&zone->lock);
> -	zone->all_unreclaimable = 0;
>  	zone->pages_scanned = 0;
>  
>  	__free_one_page(page, zone, order, migratetype);
> @@ -3095,7 +3094,7 @@ void show_free_areas(unsigned int filter)
>  			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
>  			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
>  			zone->pages_scanned,
> -			(zone->all_unreclaimable ? "yes" : "no")
> +			(!zone_reclaimable(zone) ? "yes" : "no")
>  			);
>  		printk("lowmem_reserve[]:");
>  		for (i = 0; i < MAX_NR_ZONES; i++)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2cff0d4..7501d1e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1789,7 +1789,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  	 * latencies, so it's better to scan a minimum amount there as
>  	 * well.
>  	 */
> -	if (current_is_kswapd() && zone->all_unreclaimable)
> +	if (current_is_kswapd() && !zone_reclaimable(zone))
>  		force_scan = true;
>  	if (!global_reclaim(sc))
>  		force_scan = true;
> @@ -2244,8 +2244,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  		if (global_reclaim(sc)) {
>  			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  				continue;
> -			if (zone->all_unreclaimable &&
> -					sc->priority != DEF_PRIORITY)
> +			if (!zone_reclaimable(zone) &&
> +			    sc->priority != DEF_PRIORITY)
>  				continue;	/* Let kswapd poll it */
>  			if (IS_ENABLED(CONFIG_COMPACTION)) {
>  				/*
> @@ -2283,11 +2283,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	return aborted_reclaim;
>  }
>  
> -static bool zone_reclaimable(struct zone *zone)
> -{
> -	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
> -}
> -
>  /* All zones in zonelist are unreclaimable? */
>  static bool all_unreclaimable(struct zonelist *zonelist,
>  		struct scan_control *sc)
> @@ -2301,7 +2296,7 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>  			continue;
>  		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  			continue;
> -		if (!zone->all_unreclaimable)
> +		if (zone_reclaimable(zone))
>  			return false;
>  	}
>  
> @@ -2712,7 +2707,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
>  		 * DEF_PRIORITY. Effectively, it considers them balanced so
>  		 * they must be considered balanced here as well!
>  		 */
> -		if (zone->all_unreclaimable) {
> +		if (!zone_reclaimable(zone)) {
>  			balanced_pages += zone->managed_pages;
>  			continue;
>  		}
> @@ -2773,7 +2768,6 @@ static bool kswapd_shrink_zone(struct zone *zone,
>  			       unsigned long lru_pages,
>  			       unsigned long *nr_attempted)
>  {
> -	unsigned long nr_slab;
>  	int testorder = sc->order;
>  	unsigned long balance_gap;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
> @@ -2818,15 +2812,12 @@ static bool kswapd_shrink_zone(struct zone *zone,
>  	shrink_zone(zone, sc);
>  
>  	reclaim_state->reclaimed_slab = 0;
> -	nr_slab = shrink_slab(&shrink, sc->nr_scanned, lru_pages);
> +	shrink_slab(&shrink, sc->nr_scanned, lru_pages);
>  	sc->nr_reclaimed += reclaim_state->reclaimed_slab;
>  
>  	/* Account for the number of pages attempted to reclaim */
>  	*nr_attempted += sc->nr_to_reclaim;
>  
> -	if (nr_slab == 0 && !zone_reclaimable(zone))
> -		zone->all_unreclaimable = 1;
> -
>  	zone_clear_flag(zone, ZONE_WRITEBACK);
>  
>  	/*
> @@ -2835,7 +2826,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
>  	 * BDIs but as pressure is relieved, speculatively avoid congestion
>  	 * waits.
>  	 */
> -	if (!zone->all_unreclaimable &&
> +	if (zone_reclaimable(zone) &&
>  	    zone_balanced(zone, testorder, 0, classzone_idx)) {
>  		zone_clear_flag(zone, ZONE_CONGESTED);
>  		zone_clear_flag(zone, ZONE_TAIL_LRU_DIRTY);
> @@ -2901,7 +2892,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  			if (!populated_zone(zone))
>  				continue;
>  
> -			if (zone->all_unreclaimable &&
> +			if (!zone_reclaimable(zone) &&
>  			    sc.priority != DEF_PRIORITY)
>  				continue;
>  
> @@ -2980,7 +2971,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  			if (!populated_zone(zone))
>  				continue;
>  
> -			if (zone->all_unreclaimable &&
> +			if (!zone_reclaimable(zone) &&
>  			    sc.priority != DEF_PRIORITY)
>  				continue;
>  
> @@ -3265,20 +3256,6 @@ unsigned long global_reclaimable_pages(void)
>  	return nr;
>  }
>  
> -unsigned long zone_reclaimable_pages(struct zone *zone)
> -{
> -	int nr;
> -
> -	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> -	     zone_page_state(zone, NR_INACTIVE_FILE);
> -
> -	if (get_nr_swap_pages() > 0)
> -		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> -		      zone_page_state(zone, NR_INACTIVE_ANON);
> -
> -	return nr;
> -}
> -
>  #ifdef CONFIG_HIBERNATION
>  /*
>   * Try to free `nr_to_reclaim' of memory, system-wide, and return the number of
> @@ -3576,7 +3553,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
>  		return ZONE_RECLAIM_FULL;
>  
> -	if (zone->all_unreclaimable)
> +	if (!zone_reclaimable(zone))
>  		return ZONE_RECLAIM_FULL;
>  
>  	/*
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 20c2ef4..c48f75b 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -19,6 +19,7 @@
>  #include <linux/math64.h>
>  #include <linux/writeback.h>
>  #include <linux/compaction.h>
> +#include <linux/mm_inline.h>
>  
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
> @@ -1052,7 +1053,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  		   "\n  all_unreclaimable: %u"
>  		   "\n  start_pfn:         %lu"
>  		   "\n  inactive_ratio:    %u",
> -		   zone->all_unreclaimable,
> +		   !zone_reclaimable(zone),
>  		   zone->zone_start_pfn,
>  		   zone->inactive_ratio);
>  	seq_putc(m, '\n');
> -- 
> 1.7.0.4
> 
> 
> Thanks!
> 
> Best Regards
> Lisa Du
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
