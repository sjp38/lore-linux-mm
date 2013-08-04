Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 43B3A6B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 19:47:01 -0400 (EDT)
Date: Mon, 5 Aug 2013 08:47:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Possible deadloop in direct reclaim?
Message-ID: <20130804234740.GG32486@bbox>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <20130801054338.GD19540@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE04E@SC-VEXCH4.marvell.com>
 <20130801073330.GG19540@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE0E3@SC-VEXCH4.marvell.com>
 <20130801084259.GA32486@bbox>
 <20130802015241.GB32486@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE43E@SC-VEXCH4.marvell.com>
 <20130802035333.GD32486@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE511@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B630BE511@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>

Hello,

On Fri, Aug 02, 2013 at 01:08:50AM -0700, Lisa Du wrote:
> >-----Original Message-----
> >From: Minchan Kim [mailto:minchan@kernel.org]
> >Sent: 2013a1'8ae??2ae?JPY 11:54
> >To: Lisa Du
> >Cc: linux-mm@kvack.org; KOSAKI Motohiro; Bob Liu
> >Subject: Re: Possible deadloop in direct reclaim?
> >
> >On Thu, Aug 01, 2013 at 08:17:56PM -0700, Lisa Du wrote:
> >> >-----Original Message-----
> >> >From: Minchan Kim [mailto:minchan@kernel.org]
> >> >Sent: 2013a1'8ae??2ae?JPY 10:26
> >> >To: Lisa Du
> >> >Cc: linux-mm@kvack.org; KOSAKI Motohiro
> >> >Subject: Re: Possible deadloop in direct reclaim?
> 
> 
> >> >I reviewed current mmotm because recently Mel changed kswapd a lot and
> >> >all_unreclaimable patch history today.
> >> >What I see is recent mmotm has a same problem, too if system have no swap
> >> >and no compaction. Of course, compaction is default yes option so we could
> >> >recommend to enable if system works well but it's up to user and we should
> >> >avoid direct reclaim hang although user disable compaction.
> >> >
> >> >When I see the patch history, real culprit is 929bea7c.
> >> >
> >> >"  zone->all_unreclaimable and zone->pages_scanned are neigher atomic
> >> >    variables nor protected by lock.  Therefore zones can become a state of
> >> >    zone->page_scanned=0 and zone->all_unreclaimable=1.  In this case, current
> >> >    all_unreclaimable() return false even though zone->all_unreclaimabe=1."
> >> >
> >> >I understand the problem but apparently, it makes Lisa's problem because
> >> >kswapd can give up balancing when high order allocation happens to prevent
> >> >excessive reclaim with assuming the process requested high order allocation
> >> >can do direct reclaim/compaction. But what if the process can't reclaim
> >> >by no swap but lots of anon pages and can't compact by !CONFIG_COMPACTION?
> >> >
> >>
> >> Also Bob found below thread, seems Kosaki also found same issue:
> >> mm, vmscan: fix do_try_to_free_pages() livelock
> >> https://lkml.org/lkml/2012/6/14/74
> >
> >I remember it and AFAIRC, I had a concern because description was
> >too vague without detailed example and I fixed Aaditya's problem with
> >another approach. That's why it wasn't merged at that time.
> >
> >Now, we have a real problem and analysis so I think KOSAKI's patch makes
> >perfect to me.
> >
> >Lisa, Could you resend KOSAKI's patch with more detailed description?
> 
> Hi, Minchan and Kosaki
> Would you please help check below patch I resend based on previous Kosaki's patch?
> I'm not sure if the description is clear enough, please let me know if you have any comments.
> Many thanks!
> From 2dfe137665a694dcc74ae9c8a27641b06190f344 Mon Sep 17 00:00:00 2001
> From: Lisa Du <cldu@marvell.com>
> Date: Fri, 2 Aug 2013 14:37:31 +0800
> Subject: [PATCH] mm: vmscan: fix do_try_to_free_pages() livelock
> 
> Currently, I found system can enter a state that there are lots
> of free pages in a zone but only order-0 and order-1 pages which
> means the zone is heavily fragmented, then high order allocation
> could make direct reclaim path's long stall(ex, 60 seconds)
> especially in no swap and no compaciton enviroment.
> 
> The reason is do_try_to_free_pages enter live lock:
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
> kill the process.
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

Remove Change-ID.
And please write down explicitly "It's based KOSAKI's work and I rewrite
the description"
In addtion, write down "The problem happend v3.4 but it seems the problem
still lives in current tree because ..."

Otherwise, looks good to me.
If you respin, please send a mail with new thread for akpm to be confused.

Thanks!

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
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Lisa Du <cldu@marvell.com>
> ---
>  include/linux/mm_inline.h |   20 ++++++++++++++++++++
>  include/linux/mmzone.h    |    1 -
>  include/linux/vmstat.h    |    1 -
>  mm/page-writeback.c       |    1 +
>  mm/page_alloc.c           |    5 ++---
>  mm/vmscan.c               |   43 +++++++++----------------------------------
>  mm/vmstat.c               |    3 ++-
>  7 files changed, 34 insertions(+), 40 deletions(-)
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
> index 34582d9..7501d1e 100644
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
> @@ -2301,8 +2296,6 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>  			continue;
>  		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  			continue;
> -		if (zone->all_unreclaimable)
> -			continue;
>  		if (zone_reclaimable(zone))
>  			return false;
>  	}
> @@ -2714,7 +2707,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
>  		 * DEF_PRIORITY. Effectively, it considers them balanced so
>  		 * they must be considered balanced here as well!
>  		 */
> -		if (zone->all_unreclaimable) {
> +		if (!zone_reclaimable(zone)) {
>  			balanced_pages += zone->managed_pages;
>  			continue;
>  		}
> @@ -2775,7 +2768,6 @@ static bool kswapd_shrink_zone(struct zone *zone,
>  			       unsigned long lru_pages,
>  			       unsigned long *nr_attempted)
>  {
> -	unsigned long nr_slab;
>  	int testorder = sc->order;
>  	unsigned long balance_gap;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
> @@ -2820,15 +2812,12 @@ static bool kswapd_shrink_zone(struct zone *zone,
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
> @@ -2837,7 +2826,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
>  	 * BDIs but as pressure is relieved, speculatively avoid congestion
>  	 * waits.
>  	 */
> -	if (!zone->all_unreclaimable &&
> +	if (zone_reclaimable(zone) &&
>  	    zone_balanced(zone, testorder, 0, classzone_idx)) {
>  		zone_clear_flag(zone, ZONE_CONGESTED);
>  		zone_clear_flag(zone, ZONE_TAIL_LRU_DIRTY);
> @@ -2903,7 +2892,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  			if (!populated_zone(zone))
>  				continue;
>  
> -			if (zone->all_unreclaimable &&
> +			if (!zone_reclaimable(zone) &&
>  			    sc.priority != DEF_PRIORITY)
>  				continue;
>  
> @@ -2982,7 +2971,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  			if (!populated_zone(zone))
>  				continue;
>  
> -			if (zone->all_unreclaimable &&
> +			if (!zone_reclaimable(zone) &&
>  			    sc.priority != DEF_PRIORITY)
>  				continue;
>  
> @@ -3267,20 +3256,6 @@ unsigned long global_reclaimable_pages(void)
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
> @@ -3578,7 +3553,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
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
> >
> >>
> >> >
> >> >
> >> >
> >> >--
> >> >Kind regards,
> >> >Minchan Kim
> >
> >--
> >Kind regards,
> >Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
