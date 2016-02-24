Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 82B856B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 19:12:09 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id a4so7230515wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:12:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g185si15324695wmg.13.2016.02.23.16.12.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 16:12:08 -0800 (PST)
Date: Tue, 23 Feb 2016 16:12:01 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 00/27] Move LRU page reclaim from zones to nodes v2
Message-ID: <20160224001201.GA2120@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <20160223200416.GA27563@cmpxchg.org>
 <20160223201932.GN2854@techsingularity.net>
 <20160223205915.GA10744@cmpxchg.org>
 <20160223215859.GO2854@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223215859.GO2854@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 09:58:59PM +0000, Mel Gorman wrote:
> On Tue, Feb 23, 2016 at 12:59:15PM -0800, Johannes Weiner wrote:
> > The problem is that kswapd will stay awake and continuously draw
> > subsequent allocations into a single zone, thus utilizing only a
> > fraction of available memory.
> 
> Not quite. Look at prepare_kswapd_sleep() in the full series and it has this
> 
> 
>         for (i = 0; i <= classzone_idx; i++) {
>                 struct zone *zone = pgdat->node_zones + i;
> 
>                 if (!populated_zone(zone))
>                         continue;
> 
>                 if (zone_balanced(zone, order, 0, classzone_idx))
>                         return true;
>         }
> 
> and balance_pgdat has this
> 
>                 /* Only reclaim if there are no eligible zones */
>                 for (i = classzone_idx; i >= 0; i--) {
>                         zone = pgdat->node_zones + i;
>                         if (!populated_zone(zone))
>                                 continue;
> 
>                         if (!zone_balanced(zone, order, 0, classzone_idx)) {
>                                 classzone_idx = i;
>                                 break;
>                         }
>                 }
> 
> kswapd only stays awake until *one* balanced zone is available. That is
> a key difference with the existing kswapd which balances all zones.

Thanks for clarifying, that is a good point. I applied the full series
now locally and the final code is indeed much easier to understand.

> > Sure, it doesn't matter in that benchmark, because the pages are used
> > only once. But if it had an actual cache workingset bigger than DMA32
> > but smaller than DMA32+Normal, it would be thrashing unnecessarily.
> > 
> > If kswapd were truly balancing the pages in a node equally, regardless
> > of zone placement, then in the long run we should see zone allocations
> > converge to a share that is in proportion to each zone's size. As far
> > as I can see, that is not quite happening yet.
> > 
> 
> Not quite either. The order kswapd reclaims is in related to the age of
> all pages in the node. Early in the lifetime of the system, that may be
> ZONE_NORMAL initially until the other zones are populated. Ultimately
> the balance of zones will be related to the age of the pages.

Thanks again. Yes, the picture is finally clicking into place for me.

> > > > If reclaim can't guarantee a balanced zone utilization then the
> > > > allocator has to keep doing it. :(
> > > 
> > > That's the key issue - the main reason balanced zone utilisation is
> > > necessary is because we reclaim on a per-zone basis and we must avoid
> > > page aging anomalies. If we balance such that one eligible zone is above
> > > the watermark then it's less of a concern.
> > 
> > Yes, but only if there can't be extended reclaim stretches that prefer
> > the pages of a single zone. Yet it looks like this is still possible.
> 
> And that is a problem if a workload is dominated by allocations
> requiring the lower zones. If that is the common case then it's a bust
> and fair zone allocation policy is still required. That removes one
> motivation from the series as it leaves some fatness in the page
> allocator paths.

With your above explanations, I'm now much more confident this series
is doing the right thing. Thanks.

The uncertainty over low-zone allocation floods is real, but what is
also unsettling is that, where the fair zone code used to shield us
from kswapd changes, we now open ourselves up to subtle aging bugs,
which are no longer detectable via the zone placement statistics. And
we have changed kswapd around quite extensively in the recent past.

A good metric for aging distortion might be able to mitigate both
these things. Something to keep an eye on when making changes to
kswapd, or when analyzing performance problems with a workload.

What I have in mind is per-classzone counters of reclaim work. If we
had exact numbers on how much zone-restricted reclaim is being done
relative to unrestricted scans, we could know how severely the aging
process is being distorted under any given workload. That would allow
us to validate these changes here, future kswapd and allocator
changes, and help us identify problematic workloads.

And maybe we can change the now useless pgalloc_ stats from counting
zone placement to counting allocation requests by classzone. We could
then again correlate the number of requests to the amount of work
done. A high amount of restricted reclaim on behalf of mostly Normal
allocation requests would detect the bug I described above, e.g. And
we could generally tell how expensive restricted allocations are in
the new node-LRUs.

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
