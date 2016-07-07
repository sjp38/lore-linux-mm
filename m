Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1CA6B0253
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 21:17:44 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u201so6335056oie.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 18:17:44 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 194si832774iou.63.2016.07.06.18.17.42
        for <linux-mm@kvack.org>;
        Wed, 06 Jul 2016 18:17:43 -0700 (PDT)
Date: Thu, 7 Jul 2016 10:20:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160707012038.GB27987@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 01, 2016 at 09:01:16PM +0100, Mel Gorman wrote:
> kswapd goes through some complex steps trying to figure out if it should
> stay awake based on the classzone_idx and the requested order.  It is
> unnecessarily complex and passes in an invalid classzone_idx to
> balance_pgdat().  What matters most of all is whether a larger order has
> been requsted and whether kswapd successfully reclaimed at the previous
> order.  This patch irons out the logic to check just that and the end
> result is less headache inducing.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/mmzone.h |   5 ++-
>  mm/memory_hotplug.c    |   5 ++-
>  mm/page_alloc.c        |   2 +-
>  mm/vmscan.c            | 102 ++++++++++++++++++++++++++-----------------------
>  4 files changed, 62 insertions(+), 52 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 258c20758e80..eb74e63df5cf 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -667,8 +667,9 @@ typedef struct pglist_data {
>  	wait_queue_head_t pfmemalloc_wait;
>  	struct task_struct *kswapd;	/* Protected by
>  					   mem_hotplug_begin/end() */
> -	int kswapd_max_order;
> -	enum zone_type classzone_idx;
> +	int kswapd_order;
> +	enum zone_type kswapd_classzone_idx;
> +
>  #ifdef CONFIG_COMPACTION
>  	int kcompactd_max_order;
>  	enum zone_type kcompactd_classzone_idx;
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c5278360ca66..065140ecd081 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1209,9 +1209,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  
>  		arch_refresh_nodedata(nid, pgdat);
>  	} else {
> -		/* Reset the nr_zones and classzone_idx to 0 before reuse */
> +		/* Reset the nr_zones, order and classzone_idx before reuse */
>  		pgdat->nr_zones = 0;
> -		pgdat->classzone_idx = 0;
> +		pgdat->kswapd_order = 0;
> +		pgdat->kswapd_classzone_idx = 0;
>  	}
>  
>  	/* we can use NODE_DATA(nid) from here */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 59e4463e5dce..f58548139bf2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6084,7 +6084,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  	unsigned long end_pfn = 0;
>  
>  	/* pg_data_t should be reset to zero when it's allocated */
> -	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
> +	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
>  
>  	reset_deferred_meminit(pgdat);
>  	pgdat->node_id = nid;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a52167eabc96..b524d3b72527 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2762,7 +2762,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>  
>  	/* kswapd must be awake if processes are being throttled */
>  	if (!wmark_ok && waitqueue_active(&pgdat->kswapd_wait)) {
> -		pgdat->classzone_idx = min(pgdat->classzone_idx,
> +		pgdat->kswapd_classzone_idx = min(pgdat->kswapd_classzone_idx,
>  						(enum zone_type)ZONE_NORMAL);
>  		wake_up_interruptible(&pgdat->kswapd_wait);
>  	}
> @@ -3238,8 +3238,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  	return sc.order;
>  }
>  
> -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
> -				int classzone_idx, int balanced_classzone_idx)
> +static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
> +				int classzone_idx)
>  {
>  	long remaining = 0;
>  	DEFINE_WAIT(wait);
> @@ -3249,9 +3249,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
>  
>  	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  
> +	/*
> +	 * If kswapd has not been woken recently, then kswapd goes fully
> +	 * to sleep. kcompactd may still need to wake if the original
> +	 * request was high-order.
> +	 */
> +	if (classzone_idx == -1) {
> +		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
> +		classzone_idx = MAX_NR_ZONES - 1;
> +		goto full_sleep;
> +	}

Passing -1 to kcompactd would cause the problem?

> +
>  	/* Try to sleep for a short interval */
> -	if (prepare_kswapd_sleep(pgdat, order, remaining,
> -						balanced_classzone_idx)) {
> +	if (prepare_kswapd_sleep(pgdat, reclaim_order, remaining, classzone_idx)) {
>  		/*
>  		 * Compaction records what page blocks it recently failed to
>  		 * isolate pages from and skips them in the future scanning.
> @@ -3264,19 +3274,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
>  		 * We have freed the memory, now we should compact it to make
>  		 * allocation of the requested order possible.
>  		 */
> -		wakeup_kcompactd(pgdat, order, classzone_idx);
> +		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
>  
>  		remaining = schedule_timeout(HZ/10);
>  		finish_wait(&pgdat->kswapd_wait, &wait);
>  		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  	}
>  
> +full_sleep:
>  	/*
>  	 * After a short sleep, check if it was a premature sleep. If not, then
>  	 * go fully to sleep until explicitly woken up.
>  	 */
> -	if (prepare_kswapd_sleep(pgdat, order, remaining,
> -						balanced_classzone_idx)) {
> +	if (prepare_kswapd_sleep(pgdat, reclaim_order, remaining, classzone_idx)) {
>  		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
>  
>  		/*
> @@ -3317,9 +3327,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
>   */
>  static int kswapd(void *p)
>  {
> -	unsigned long order, new_order;
> -	int classzone_idx, new_classzone_idx;
> -	int balanced_classzone_idx;
> +	unsigned int alloc_order, reclaim_order, classzone_idx;
>  	pg_data_t *pgdat = (pg_data_t*)p;
>  	struct task_struct *tsk = current;
>  
> @@ -3349,38 +3357,26 @@ static int kswapd(void *p)
>  	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
>  	set_freezable();
>  
> -	order = new_order = 0;
> -	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
> -	balanced_classzone_idx = classzone_idx;
> +	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
> +	pgdat->kswapd_classzone_idx = classzone_idx = -1;
>  	for ( ; ; ) {
>  		bool ret;
>  
> +kswapd_try_sleep:
> +		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
> +					classzone_idx);
> +
>  		/*
> -		 * While we were reclaiming, there might have been another
> -		 * wakeup, so check the values.
> +		 * Read the new order and classzone_idx which may be -1 if
> +		 * kswapd_try_to_sleep() woke up after a short timeout instead
> +		 * of being woken by the page allocator.
>  		 */
> -		new_order = pgdat->kswapd_max_order;
> -		new_classzone_idx = pgdat->classzone_idx;
> -		pgdat->kswapd_max_order =  0;
> -		pgdat->classzone_idx = pgdat->nr_zones - 1;
> -
> -		if (order < new_order || classzone_idx > new_classzone_idx) {
> -			/*
> -			 * Don't sleep if someone wants a larger 'order'
> -			 * allocation or has tigher zone constraints
> -			 */
> -			order = new_order;
> -			classzone_idx = new_classzone_idx;
> -		} else {
> -			kswapd_try_to_sleep(pgdat, order, classzone_idx,
> -						balanced_classzone_idx);
> -			order = pgdat->kswapd_max_order;
> -			classzone_idx = pgdat->classzone_idx;
> -			new_order = order;
> -			new_classzone_idx = classzone_idx;
> -			pgdat->kswapd_max_order = 0;
> -			pgdat->classzone_idx = pgdat->nr_zones - 1;
> -		}
> +		alloc_order = reclaim_order = pgdat->kswapd_order;
> +		classzone_idx = pgdat->kswapd_classzone_idx;
> +		if (classzone_idx == -1)
> +			classzone_idx = MAX_NR_ZONES - 1;
> +		pgdat->kswapd_order = 0;
> +		pgdat->kswapd_classzone_idx = -1;
>  
>  		ret = try_to_freeze();
>  		if (kthread_should_stop())
> @@ -3390,12 +3386,24 @@ static int kswapd(void *p)
>  		 * We can speed up thawing tasks if we don't call balance_pgdat
>  		 * after returning from the refrigerator
>  		 */
> -		if (!ret) {
> -			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> +		if (ret)
> +			continue;
>  
> -			/* return value ignored until next patch */
> -			balance_pgdat(pgdat, order, classzone_idx);
> -		}
> +		/*
> +		 * Reclaim begins at the requested order but if a high-order
> +		 * reclaim fails then kswapd falls back to reclaiming for
> +		 * order-0. If that happens, kswapd will consider sleeping
> +		 * for the order it finished reclaiming at (reclaim_order)
> +		 * but kcompactd is woken to compact for the original
> +		 * request (alloc_order).
> +		 */
> +		trace_mm_vmscan_kswapd_wake(pgdat->node_id, alloc_order);
> +		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
> +		if (reclaim_order < alloc_order)
> +			goto kswapd_try_sleep;

This 'goto' would cause kswapd to sleep prematurely. We need to check
*new* pgdat->kswapd_order and classzone_idx even in this case.

> +
> +		alloc_order = reclaim_order = pgdat->kswapd_order;
> +		classzone_idx = pgdat->kswapd_classzone_idx;
>  	}
>  
>  	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
> @@ -3418,10 +3426,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
>  		return;
>  	pgdat = zone->zone_pgdat;
> -	if (pgdat->kswapd_max_order < order) {
> -		pgdat->kswapd_max_order = order;
> -		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
> -	}
> +	if (pgdat->kswapd_classzone_idx == -1)
> +		pgdat->kswapd_classzone_idx = classzone_idx;
> +	pgdat->kswapd_classzone_idx = max(pgdat->kswapd_classzone_idx, classzone_idx);
> +	pgdat->kswapd_order = max(pgdat->kswapd_order, order);

Now, updating pgdat->skwapd_max_order and classzone_idx happens
unconditionally. Before your patch, it is only updated toward hard
constraint (e.g. higher order).

And, I'd like to know why max() is used for classzone_idx rather than
min()? I think that kswapd should balance the lowest zone requested.

Thanks.

>  	if (!waitqueue_active(&pgdat->kswapd_wait))
>  		return;
>  	if (zone_balanced(zone, order, 0))
> -- 
> 2.6.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
