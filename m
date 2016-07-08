Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88CA16B0005
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 22:41:19 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so65468173pat.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 19:41:19 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id pj9si1395641pac.4.2016.07.07.19.41.17
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 19:41:17 -0700 (PDT)
Date: Fri, 8 Jul 2016 11:44:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160708024447.GB2370@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160707012038.GB27987@js1304-P5Q-DELUXE>
 <20160707101701.GR11498@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160707101701.GR11498@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 07, 2016 at 11:17:01AM +0100, Mel Gorman wrote:
> On Thu, Jul 07, 2016 at 10:20:39AM +0900, Joonsoo Kim wrote:
> > > @@ -3249,9 +3249,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
> > >  
> > >  	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > >  
> > > +	/*
> > > +	 * If kswapd has not been woken recently, then kswapd goes fully
> > > +	 * to sleep. kcompactd may still need to wake if the original
> > > +	 * request was high-order.
> > > +	 */
> > > +	if (classzone_idx == -1) {
> > > +		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
> > > +		classzone_idx = MAX_NR_ZONES - 1;
> > > +		goto full_sleep;
> > > +	}
> > 
> > Passing -1 to kcompactd would cause the problem?
> > 
> 
> No, it ends up doing a wakeup and then going back to sleep which is not
> what is required. I'll fix it.
> 
> > > @@ -3390,12 +3386,24 @@ static int kswapd(void *p)
> > >  		 * We can speed up thawing tasks if we don't call balance_pgdat
> > >  		 * after returning from the refrigerator
> > >  		 */
> > > -		if (!ret) {
> > > -			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> > > +		if (ret)
> > > +			continue;
> > >  
> > > -			/* return value ignored until next patch */
> > > -			balance_pgdat(pgdat, order, classzone_idx);
> > > -		}
> > > +		/*
> > > +		 * Reclaim begins at the requested order but if a high-order
> > > +		 * reclaim fails then kswapd falls back to reclaiming for
> > > +		 * order-0. If that happens, kswapd will consider sleeping
> > > +		 * for the order it finished reclaiming at (reclaim_order)
> > > +		 * but kcompactd is woken to compact for the original
> > > +		 * request (alloc_order).
> > > +		 */
> > > +		trace_mm_vmscan_kswapd_wake(pgdat->node_id, alloc_order);
> > > +		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
> > > +		if (reclaim_order < alloc_order)
> > > +			goto kswapd_try_sleep;
> > 
> > This 'goto' would cause kswapd to sleep prematurely. We need to check
> > *new* pgdat->kswapd_order and classzone_idx even in this case.
> > 
> 
> It only matters if the next request coming is also high-order requests but
> one thing that needs to be avoided is kswapd staying awake periods of time
> constantly reclaiming for high-order pages. This is why the check means
> "If we reclaimed for high-order and failed, then consider sleeping now".
> If allocations still require it, they direct reclaim instead.

But, assume that next request is zone-constrained allocation. We need
to balance memory for it but kswapd would skip it.

> 
> "Fixing" this potentially causes reclaim storms from kswapd.
> 
> > > @@ -3418,10 +3426,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
> > >  	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
> > >  		return;
> > >  	pgdat = zone->zone_pgdat;
> > > -	if (pgdat->kswapd_max_order < order) {
> > > -		pgdat->kswapd_max_order = order;
> > > -		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
> > > -	}
> > > +	if (pgdat->kswapd_classzone_idx == -1)
> > > +		pgdat->kswapd_classzone_idx = classzone_idx;
> > > +	pgdat->kswapd_classzone_idx = max(pgdat->kswapd_classzone_idx, classzone_idx);
> > > +	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
> > 
> > Now, updating pgdat->skwapd_max_order and classzone_idx happens
> > unconditionally. Before your patch, it is only updated toward hard
> > constraint (e.g. higher order).
> > 
> 
> So? It's updating the request to suit the requirements of all pending
> allocation requests that woke kswapd.
> 
> > And, I'd like to know why max() is used for classzone_idx rather than
> > min()? I think that kswapd should balance the lowest zone requested.
> > 
> 
> If there are two allocation requests -- one zone-constraned and the other
> zone-unconstrained, it does not make sense to have kswapd skip the pages
> usable for the zone-unconstrained and waste a load of CPU. You could

I agree that, in this case, it's not good to skip the pages usable
for the zone-unconstrained request. But, what I am concerned is that
kswapd stop reclaim prematurely in the view of zone-constrained
requestor. Kswapd decide to stop reclaim if one of eligible zone is
balanced and this max() makes eligible zone higher than the one
zone-unconstrained requestor want.

Thanks.

> argue that using min would satisfy the zone-constrained allocation faster
> but that's at the cost of delaying the zone-unconstrained allocation and
> wasting CPU. Bear in mind that using max may mean some lowmem pages get
> freed anyway due to LRU order.
> 
> -- 
> Mel Gorman
> SUSE Labs
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
