Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8F2546B00E6
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 23:36:47 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D3aiCI004639
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Oct 2010 12:36:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72F1445DE51
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:36:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5210E45DE4F
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:36:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C6BF1DB803A
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:36:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E326F1DB8038
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:36:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: zone state overhead
In-Reply-To: <20101012162526.GG30667@csn.ul.ie>
References: <20101012010514.GA20065@sli10-conroe.sh.intel.com> <20101012162526.GG30667@csn.ul.ie>
Message-Id: <20101013121913.ADB4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Oct 2010 12:36:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Hello, 

> ==== CUT HERE ====
> mm: page allocator: Adjust the per-cpu counter threshold when memory is low
> 
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
> Unfortately, as reported by Shaohua Li this accurate reading can consume
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

Interesting. I've reveiwed this one.


> 
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/mmzone.h |    6 ------
>  include/linux/vmstat.h |    2 ++
>  mm/mmzone.c            |   21 ---------------------
>  mm/page_alloc.c        |    4 ++--
>  mm/vmscan.c            |    2 ++
>  mm/vmstat.c            |   42 +++++++++++++++++++++++++++++++++++++++++-
>  6 files changed, 47 insertions(+), 30 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 3984c4e..343fd5c 100644
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
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index eaaea37..c67d333 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -254,6 +254,8 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
>  extern void __dec_zone_state(struct zone *, enum zone_stat_item);
>  
>  void refresh_cpu_vm_stats(int);
> +void disable_pgdat_percpu_threshold(pg_data_t *pgdat);
> +void enable_pgdat_percpu_threshold(pg_data_t *pgdat);
>  #else /* CONFIG_SMP */
>  
>  /*
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

Now, we can remove zone_page_state_snapshot() too.


> -
> -	return nr_free_pages;
> -}
> -#endif /* CONFIG_SMP */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a8cfa9c..a9b4542 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1462,7 +1462,7 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  {
>  	/* free_pages my go negative - that's OK */
>  	long min = mark;
> -	long free_pages = zone_nr_free_pages(z) - (1 << order) + 1;
> +	long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
>  	int o;
>  
>  	if (alloc_flags & ALLOC_HIGH)
> @@ -2436,7 +2436,7 @@ void show_free_areas(void)
>  			" all_unreclaimable? %s"
>  			"\n",
>  			zone->name,
> -			K(zone_nr_free_pages(zone)),
> +			K(zone_page_state(zone, NR_FREE_PAGES)),
>  			K(min_wmark_pages(zone)),
>  			K(low_wmark_pages(zone)),
>  			K(high_wmark_pages(zone)),
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c5dfabf..47ba29e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2378,7 +2378,9 @@ static int kswapd(void *p)
>  				 */
>  				if (!sleeping_prematurely(pgdat, order, remaining)) {
>  					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> +					enable_pgdat_percpu_threshold(pgdat);
>  					schedule();
> +					disable_pgdat_percpu_threshold(pgdat);

If we have 4096 cpus, max drift = 125x4096x4096 ~= 2GB. It is higher than zone watermark.
Then, such sysmtem can makes memory exshost before kswap call disable_pgdat_percpu_threshold().

Hmmm....
This seems fundamental problem. current our zone watermark and per-cpu stat threshold have completely
unbalanced definition.

zone watermak:             very few (few mega bytes)
                                       propotional sqrt(mem)
                                       no propotional nr-cpus

per-cpu stat threshold:  relatively large (desktop: few mega bytes, server ~50MB, SGI 2GB ;-)
                                       propotional log(mem)
                                       propotional log(nr-cpus)

It mean, much cpus break watermark assumption.....



>  				} else {
>  					if (remaining)
>  						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 355a9e6..19bd4a1 100644
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
>  static int calculate_threshold(struct zone *zone)
>  {
>  	int threshold;
> @@ -159,6 +165,40 @@ static void refresh_zone_stat_thresholds(void)
>  	}
>  }
>  
> +void disable_pgdat_percpu_threshold(pg_data_t *pgdat)
> +{
> +	struct zone *zone;
> +	int cpu;
> +	int threshold;
> +
> +	for_each_populated_zone(zone) {
> +		if (!zone->percpu_drift_mark || zone->zone_pgdat != pgdat)
> +			continue;

We don't use for_each_populated_zone() and "zone->zone_pgdat != pgdat" combination
in almost place.

        for (i = 0; i < pgdat->nr_zones; i++) {

is enough?

> +
> +		threshold = calculate_pressure_threshold(zone);
> +		for_each_online_cpu(cpu)
> +			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> +							= threshold;
>
> +	}
> +}
> +
> +void enable_pgdat_percpu_threshold(pg_data_t *pgdat)
> +{
> +	struct zone *zone;
> +	int cpu;
> +	int threshold;
> +
> +	for_each_populated_zone(zone) {
> +		if (!zone->percpu_drift_mark || zone->zone_pgdat != pgdat)
> +			continue;
> +
> +		threshold = calculate_threshold(zone);
> +		for_each_online_cpu(cpu)
> +			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> +							= threshold;
> +	}
> +}

disable_pgdat_percpu_threshold() and enable_pgdat_percpu_threshold() are
almostly same. can you merge them?


> +
>  /*
>   * For use when we know that interrupts are disabled.
>   */
> @@ -826,7 +866,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  		   "\n        scanned  %lu"
>  		   "\n        spanned  %lu"
>  		   "\n        present  %lu",
> -		   zone_nr_free_pages(zone),
> +		   zone_page_state(zone, NR_FREE_PAGES),
>  		   min_wmark_pages(zone),
>  		   low_wmark_pages(zone),
>  		   high_wmark_pages(zone),
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
