Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D0F136B00A7
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 21:14:56 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9S1ErvT003146
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 Oct 2010 10:14:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F37C345DE4F
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 10:14:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D865B45DD71
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 10:14:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B2B501DB8012
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 10:14:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5271AE38002
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 10:14:52 +0900 (JST)
Date: Thu, 28 Oct 2010 10:09:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
Message-Id: <20101028100920.5d4ce413.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1288169256-7174-2-git-send-email-mel@csn.ul.ie>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
	<1288169256-7174-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Oct 2010 09:47:35 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Commit [aa45484: calculate a better estimate of NR_FREE_PAGES when
> memory is low] noted that watermarks were based on the vmstat
> NR_FREE_PAGES. To avoid synchronization overhead, these counters are
> maintained on a per-cpu basis and drained both periodically and when a
> threshold is above a threshold. On large CPU systems, the difference
> between the estimate and real value of NR_FREE_PAGES can be very high.
> The system can get into a case where pages are allocated far below the
> min watermark potentially causing livelock issues. The commit solved the
> problem by taking a better reading of NR_FREE_PAGES when memory was low.
> 
> Unfortunately, as reported by Shaohua Li this accurate reading can consume
> a large amount of CPU time on systems with many sockets due to cache
> line bouncing. This patch takes a different approach. For large machines
> where counter drift might be unsafe and while kswapd is awake, the per-cpu
> thresholds for the target pgdat are reduced to limit the level of drift
> to what should be a safe level. This incurs a performance penalty in heavy
> memory pressure by a factor that depends on the workload and the machine but
> the machine should function correctly without accidentally exhausting all
> memory on a node. There is an additional cost when kswapd wakes and sleeps
> but the event is not expected to be frequent - in Shaohua's test case,
> there was one recorded sleep and wake event at least.
> 
> To ensure that kswapd wakes up, a safe version of zone_watermark_ok()
> is introduced that takes a more accurate reading of NR_FREE_PAGES when
> called from wakeup_kswapd, when deciding whether it is really safe to go
> back to sleep in sleeping_prematurely() and when deciding if a zone is
> really balanced or not in balance_pgdat(). We are still using an expensive
> function but limiting how often it is called.
> 
> When the test case is reproduced, the time spent in the watermark functions
> is reduced. The following report is on the percentage of time spent
> cumulatively spent in the functions zone_nr_free_pages(), zone_watermark_ok(),
> __zone_watermark_ok(), zone_watermark_ok_safe(), zone_page_state_snapshot(),
> zone_page_state().
> 
> vanilla                      11.6615%
> disable-threshold            0.2584%
> 
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/mmzone.h |   10 +++-------
>  include/linux/vmstat.h |    5 +++++
>  mm/mmzone.c            |   21 ---------------------
>  mm/page_alloc.c        |   35 +++++++++++++++++++++++++++--------
>  mm/vmscan.c            |   23 +++++++++++++----------
>  mm/vmstat.c            |   46 +++++++++++++++++++++++++++++++++++++++++++++-
>  6 files changed, 93 insertions(+), 47 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 3984c4e..8d789d7 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -448,12 +448,6 @@ static inline int zone_is_oom_locked(const struct zone *zone)
>  	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
>  }
>  
> -#ifdef CONFIG_SMP
> -unsigned long zone_nr_free_pages(struct zone *zone);
> -#else
> -#define zone_nr_free_pages(zone) zone_page_state(zone, NR_FREE_PAGES)
> -#endif /* CONFIG_SMP */
> -
>  /*
>   * The "priority" of VM scanning is how much of the queues we will scan in one
>   * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
> @@ -651,7 +645,9 @@ typedef struct pglist_data {
>  extern struct mutex zonelists_mutex;
>  void build_all_zonelists(void *data);
>  void wakeup_kswapd(struct zone *zone, int order);
> -int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +		int classzone_idx, int alloc_flags);
> +bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>  		int classzone_idx, int alloc_flags);
>  enum memmap_context {
>  	MEMMAP_EARLY,
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index eaaea37..e4cc21c 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -254,6 +254,8 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
>  extern void __dec_zone_state(struct zone *, enum zone_stat_item);
>  
>  void refresh_cpu_vm_stats(int);
> +void reduce_pgdat_percpu_threshold(pg_data_t *pgdat);
> +void restore_pgdat_percpu_threshold(pg_data_t *pgdat);
>  #else /* CONFIG_SMP */
>  
>  /*
> @@ -298,6 +300,9 @@ static inline void __dec_zone_page_state(struct page *page,
>  #define dec_zone_page_state __dec_zone_page_state
>  #define mod_zone_page_state __mod_zone_page_state
>  
> +static inline void reduce_pgdat_percpu_threshold(pg_data_t *pgdat) { }
> +static inline void restore_pgdat_percpu_threshold(pg_data_t *pgdat) { }
> +
>  static inline void refresh_cpu_vm_stats(int cpu) { }
>  #endif
>  
> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index e35bfb8..f5b7d17 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -87,24 +87,3 @@ int memmap_valid_within(unsigned long pfn,
>  	return 1;
>  }
>  #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
> -
> -#ifdef CONFIG_SMP
> -/* Called when a more accurate view of NR_FREE_PAGES is needed */
> -unsigned long zone_nr_free_pages(struct zone *zone)
> -{
> -	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
> -
> -	/*
> -	 * While kswapd is awake, it is considered the zone is under some
> -	 * memory pressure. Under pressure, there is a risk that
> -	 * per-cpu-counter-drift will allow the min watermark to be breached
> -	 * potentially causing a live-lock. While kswapd is awake and
> -	 * free pages are low, get a better estimate for free pages
> -	 */
> -	if (nr_free_pages < zone->percpu_drift_mark &&
> -			!waitqueue_active(&zone->zone_pgdat->kswapd_wait))
> -		return zone_page_state_snapshot(zone, NR_FREE_PAGES);
> -
> -	return nr_free_pages;
> -}
> -#endif /* CONFIG_SMP */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f12ad18..0286150 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1454,24 +1454,24 @@ static inline int should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>  #endif /* CONFIG_FAIL_PAGE_ALLOC */
>  
>  /*
> - * Return 1 if free pages are above 'mark'. This takes into account the order
> + * Return true if free pages are above 'mark'. This takes into account the order
>   * of the allocation.
>   */
> -int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> -		      int classzone_idx, int alloc_flags)
> +static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +		      int classzone_idx, int alloc_flags, long free_pages)
>  {
>  	/* free_pages my go negative - that's OK */
>  	long min = mark;
> -	long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
>  	int o;
>  
> +	free_pages -= (1 << order) + 1;
>  	if (alloc_flags & ALLOC_HIGH)
>  		min -= min / 2;
>  	if (alloc_flags & ALLOC_HARDER)
>  		min -= min / 4;
>  
>  	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
> -		return 0;
> +		return false;
>  	for (o = 0; o < order; o++) {
>  		/* At the next order, this order's pages become unavailable */
>  		free_pages -= z->free_area[o].nr_free << o;
> @@ -1480,9 +1480,28 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  		min >>= 1;
>  
>  		if (free_pages <= min)
> -			return 0;
> +			return false;
>  	}
> -	return 1;
> +	return true;
> +}
> +
> +bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +		      int classzone_idx, int alloc_flags)
> +{
> +	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> +					zone_page_state(z, NR_FREE_PAGES));
> +}
> +
> +bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
> +		      int classzone_idx, int alloc_flags)
> +{
> +	long free_pages = zone_page_state(z, NR_FREE_PAGES);
> +
> +	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
> +		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
> +
> +	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> +								free_pages);
>  }
>  
>  #ifdef CONFIG_NUMA
> @@ -2436,7 +2455,7 @@ void show_free_areas(void)
>  			" all_unreclaimable? %s"
>  			"\n",
>  			zone->name,
> -			K(zone_nr_free_pages(zone)),
> +			K(zone_page_state(zone, NR_FREE_PAGES)),
>  			K(min_wmark_pages(zone)),
>  			K(low_wmark_pages(zone)),
>  			K(high_wmark_pages(zone)),
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c5dfabf..3e71cb1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2082,7 +2082,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  		if (zone->all_unreclaimable)
>  			continue;
>  
> -		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
> +		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
>  								0, 0))
>  			return 1;
>  	}
> @@ -2169,7 +2169,7 @@ loop_again:
>  				shrink_active_list(SWAP_CLUSTER_MAX, zone,
>  							&sc, priority, 0);
>  
> -			if (!zone_watermark_ok(zone, order,
> +			if (!zone_watermark_ok_safe(zone, order,
>  					high_wmark_pages(zone), 0, 0)) {
>  				end_zone = i;
>  				break;
> @@ -2215,7 +2215,7 @@ loop_again:
>  			 * We put equal pressure on every zone, unless one
>  			 * zone has way too many pages free already.
>  			 */
> -			if (!zone_watermark_ok(zone, order,
> +			if (!zone_watermark_ok_safe(zone, order,
>  					8*high_wmark_pages(zone), end_zone, 0))
>  				shrink_zone(priority, zone, &sc);
>  			reclaim_state->reclaimed_slab = 0;
> @@ -2236,7 +2236,7 @@ loop_again:
>  			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
>  				sc.may_writepage = 1;
>  
> -			if (!zone_watermark_ok(zone, order,
> +			if (!zone_watermark_ok_safe(zone, order,
>  					high_wmark_pages(zone), end_zone, 0)) {
>  				all_zones_ok = 0;
>  				/*
> @@ -2244,7 +2244,7 @@ loop_again:
>  				 * means that we have a GFP_ATOMIC allocation
>  				 * failure risk. Hurry up!
>  				 */
> -				if (!zone_watermark_ok(zone, order,
> +				if (!zone_watermark_ok_safe(zone, order,
>  					    min_wmark_pages(zone), end_zone, 0))
>  					has_under_min_watermark_zone = 1;
>  			}
> @@ -2378,7 +2378,9 @@ static int kswapd(void *p)
>  				 */
>  				if (!sleeping_prematurely(pgdat, order, remaining)) {
>  					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> +					restore_pgdat_percpu_threshold(pgdat);
>  					schedule();
> +					reduce_pgdat_percpu_threshold(pgdat);
>  				} else {
>  					if (remaining)
>  						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> @@ -2417,16 +2419,17 @@ void wakeup_kswapd(struct zone *zone, int order)
>  	if (!populated_zone(zone))
>  		return;
>  
> -	pgdat = zone->zone_pgdat;
> -	if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
> +	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  		return;
> +	pgdat = zone->zone_pgdat;
>  	if (pgdat->kswapd_max_order < order)
>  		pgdat->kswapd_max_order = order;
> -	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
> -	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> -		return;
>  	if (!waitqueue_active(&pgdat->kswapd_wait))
>  		return;
> +	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
> +		return;
> +
> +	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
>  	wake_up_interruptible(&pgdat->kswapd_wait);
>  }
>  
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 355a9e6..cafcc2d 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -81,6 +81,12 @@ EXPORT_SYMBOL(vm_stat);
>  
>  #ifdef CONFIG_SMP
>  
> +static int calculate_pressure_threshold(struct zone *zone)
> +{
> +	return max(1, (int)((high_wmark_pages(zone) - low_wmark_pages(zone) /
> +				num_online_cpus())));
> +}
> +

Could you add background theory of this calculation as a comment to
show the difference with calculate_threshold() ?

And don't we need to have "max=125" thresh here ?


>  static int calculate_threshold(struct zone *zone)
>  {
>  	int threshold;
> @@ -159,6 +165,44 @@ static void refresh_zone_stat_thresholds(void)
>  	}
>  }
>  
> +void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
> +{
> +	struct zone *zone;
> +	int cpu;
> +	int threshold;
> +	int i;
> +

get_online_cpus();

> +	for (i = 0; i < pgdat->nr_zones; i++) {
> +		zone = &pgdat->node_zones[i];
> +		if (!zone->percpu_drift_mark)
> +			continue;
> +
> +		threshold = calculate_pressure_threshold(zone);
> +		for_each_online_cpu(cpu)
> +			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> +							= threshold;
> +	}

put_online_cpus();

> +}
> +
> +void restore_pgdat_percpu_threshold(pg_data_t *pgdat)
> +{
> +	struct zone *zone;
> +	int cpu;
> +	int threshold;
> +	int i;
> +

get_online_cpus();

> +	for (i = 0; i < pgdat->nr_zones; i++) {
> +		zone = &pgdat->node_zones[i];
> +		if (!zone->percpu_drift_mark)
> +			continue;
> +
> +		threshold = calculate_threshold(zone);
> +		for_each_online_cpu(cpu)
> +			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> +							= threshold;
> +	}

put_online_cpus();


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
