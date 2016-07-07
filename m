Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 306F46B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 06:17:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so14909366wmr.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 03:17:05 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id f63si2998830wma.112.2016.07.07.03.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 03:17:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 83F961C315E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 11:17:03 +0100 (IST)
Date: Thu, 7 Jul 2016 11:17:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160707101701.GR11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160707012038.GB27987@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707012038.GB27987@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 07, 2016 at 10:20:39AM +0900, Joonsoo Kim wrote:
> > @@ -3249,9 +3249,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
> >  
> >  	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> >  
> > +	/*
> > +	 * If kswapd has not been woken recently, then kswapd goes fully
> > +	 * to sleep. kcompactd may still need to wake if the original
> > +	 * request was high-order.
> > +	 */
> > +	if (classzone_idx == -1) {
> > +		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
> > +		classzone_idx = MAX_NR_ZONES - 1;
> > +		goto full_sleep;
> > +	}
> 
> Passing -1 to kcompactd would cause the problem?
> 

No, it ends up doing a wakeup and then going back to sleep which is not
what is required. I'll fix it.

> > @@ -3390,12 +3386,24 @@ static int kswapd(void *p)
> >  		 * We can speed up thawing tasks if we don't call balance_pgdat
> >  		 * after returning from the refrigerator
> >  		 */
> > -		if (!ret) {
> > -			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> > +		if (ret)
> > +			continue;
> >  
> > -			/* return value ignored until next patch */
> > -			balance_pgdat(pgdat, order, classzone_idx);
> > -		}
> > +		/*
> > +		 * Reclaim begins at the requested order but if a high-order
> > +		 * reclaim fails then kswapd falls back to reclaiming for
> > +		 * order-0. If that happens, kswapd will consider sleeping
> > +		 * for the order it finished reclaiming at (reclaim_order)
> > +		 * but kcompactd is woken to compact for the original
> > +		 * request (alloc_order).
> > +		 */
> > +		trace_mm_vmscan_kswapd_wake(pgdat->node_id, alloc_order);
> > +		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
> > +		if (reclaim_order < alloc_order)
> > +			goto kswapd_try_sleep;
> 
> This 'goto' would cause kswapd to sleep prematurely. We need to check
> *new* pgdat->kswapd_order and classzone_idx even in this case.
> 

It only matters if the next request coming is also high-order requests but
one thing that needs to be avoided is kswapd staying awake periods of time
constantly reclaiming for high-order pages. This is why the check means
"If we reclaimed for high-order and failed, then consider sleeping now".
If allocations still require it, they direct reclaim instead.

"Fixing" this potentially causes reclaim storms from kswapd.

> > @@ -3418,10 +3426,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
> >  	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
> >  		return;
> >  	pgdat = zone->zone_pgdat;
> > -	if (pgdat->kswapd_max_order < order) {
> > -		pgdat->kswapd_max_order = order;
> > -		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
> > -	}
> > +	if (pgdat->kswapd_classzone_idx == -1)
> > +		pgdat->kswapd_classzone_idx = classzone_idx;
> > +	pgdat->kswapd_classzone_idx = max(pgdat->kswapd_classzone_idx, classzone_idx);
> > +	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
> 
> Now, updating pgdat->skwapd_max_order and classzone_idx happens
> unconditionally. Before your patch, it is only updated toward hard
> constraint (e.g. higher order).
> 

So? It's updating the request to suit the requirements of all pending
allocation requests that woke kswapd.

> And, I'd like to know why max() is used for classzone_idx rather than
> min()? I think that kswapd should balance the lowest zone requested.
> 

If there are two allocation requests -- one zone-constraned and the other
zone-unconstrained, it does not make sense to have kswapd skip the pages
usable for the zone-unconstrained and waste a load of CPU. You could
argue that using min would satisfy the zone-constrained allocation faster
but that's at the cost of delaying the zone-unconstrained allocation and
wasting CPU. Bear in mind that using max may mean some lowmem pages get
freed anyway due to LRU order.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
