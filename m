Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A273828E1
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 06:11:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so5869033wma.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 03:11:50 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id e90si2174138wmc.113.2016.07.08.03.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 03:11:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id E73C91C23B6
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 11:11:48 +0100 (IST)
Date: Fri, 8 Jul 2016 11:11:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160708101147.GD11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160707012038.GB27987@js1304-P5Q-DELUXE>
 <20160707101701.GR11498@techsingularity.net>
 <20160708024447.GB2370@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160708024447.GB2370@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 11:44:47AM +0900, Joonsoo Kim wrote:
> > > > @@ -3390,12 +3386,24 @@ static int kswapd(void *p)
> > > >  		 * We can speed up thawing tasks if we don't call balance_pgdat
> > > >  		 * after returning from the refrigerator
> > > >  		 */
> > > > -		if (!ret) {
> > > > -			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> > > > +		if (ret)
> > > > +			continue;
> > > >  
> > > > -			/* return value ignored until next patch */
> > > > -			balance_pgdat(pgdat, order, classzone_idx);
> > > > -		}
> > > > +		/*
> > > > +		 * Reclaim begins at the requested order but if a high-order
> > > > +		 * reclaim fails then kswapd falls back to reclaiming for
> > > > +		 * order-0. If that happens, kswapd will consider sleeping
> > > > +		 * for the order it finished reclaiming at (reclaim_order)
> > > > +		 * but kcompactd is woken to compact for the original
> > > > +		 * request (alloc_order).
> > > > +		 */
> > > > +		trace_mm_vmscan_kswapd_wake(pgdat->node_id, alloc_order);
> > > > +		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
> > > > +		if (reclaim_order < alloc_order)
> > > > +			goto kswapd_try_sleep;
> > > 
> > > This 'goto' would cause kswapd to sleep prematurely. We need to check
> > > *new* pgdat->kswapd_order and classzone_idx even in this case.
> > > 
> > 
> > It only matters if the next request coming is also high-order requests but
> > one thing that needs to be avoided is kswapd staying awake periods of time
> > constantly reclaiming for high-order pages. This is why the check means
> > "If we reclaimed for high-order and failed, then consider sleeping now".
> > If allocations still require it, they direct reclaim instead.
> 
> But, assume that next request is zone-constrained allocation. We need
> to balance memory for it but kswapd would skip it.
> 

Then it'll also be woken up again in the very near future as the
zone-constrained allocation. If the zone is at the min watermark, then
it'll have direct reclaimed but between min and low, it'll be a simple
wakeup.

The premature sleep, wakeup with new requests logic was a complete mess.
However, what I did do is remove the -1 handling of kswapd_classzone_idx
handling and the goto full-sleep. In the event of a premature wakeup,
it'll recheck for wakeups and if none has occured, it'll use the old
classzone information.

Note that it will *not* use the original allocation order if it's a
premature sleep. This is because it's known that high-order reclaim
failed in the near past and restarting it has a high risk of
overreclaiming.

> > > And, I'd like to know why max() is used for classzone_idx rather than
> > > min()? I think that kswapd should balance the lowest zone requested.
> > > 
> > 
> > If there are two allocation requests -- one zone-constraned and the other
> > zone-unconstrained, it does not make sense to have kswapd skip the pages
> > usable for the zone-unconstrained and waste a load of CPU. You could
> 
> I agree that, in this case, it's not good to skip the pages usable
> for the zone-unconstrained request. But, what I am concerned is that
> kswapd stop reclaim prematurely in the view of zone-constrained
> requestor.

It doesn't stop reclaiming for the lower zones. It's reclaiming the LRU
for the whole node that may or may not have lower zone pages at the end
of the LRU. If it does, then the allocation request will be satisfied.
If it does not, then kswapd will think the node is balanced and get
rewoken to do a zone-constrained reclaim pass.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
