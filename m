Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4156B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:59:22 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so218343789wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:59:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dz12si46937254wjb.180.2016.02.23.12.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 12:59:20 -0800 (PST)
Date: Tue, 23 Feb 2016 12:59:15 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 00/27] Move LRU page reclaim from zones to nodes v2
Message-ID: <20160223205915.GA10744@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <20160223200416.GA27563@cmpxchg.org>
 <20160223201932.GN2854@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223201932.GN2854@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 08:19:32PM +0000, Mel Gorman wrote:
> On Tue, Feb 23, 2016 at 12:04:16PM -0800, Johannes Weiner wrote:
> > On Tue, Feb 23, 2016 at 03:04:23PM +0000, Mel Gorman wrote:
> > > In many benchmarks, there is an obvious difference in the number of
> > > allocations from each zone as the fair zone allocation policy is removed
> > > towards the end of the series. For example, this is the allocation stats
> > > when running blogbench that showed no difference in headling performance
> > > 
> > >                           mmotm-20160209   nodelru-v2
> > > DMA allocs                           0           0
> > > DMA32 allocs                   7218763      608067
> > > Normal allocs                 12701806    18821286
> > > Movable allocs                       0           0
> > 
> > According to the mmotm numbers, your DMA32 zone is over a third of
> > available memory, yet in the nodelru-v2 kernel sees only 3% of the
> > allocations.
> 
> In this case yes but blogbench is not scaled to memory size and is not
> reclaim intensive. If you look, you'll see the total number of overall
> allocations is very similar. During that test, there is a small amount of
> kswapd scan activity (but not reclaim which is odd) at the start of the
> test for nodelru but that's about it.

Yes, if fairness enforcement is now done by reclaim, then workloads
without reclaim will show skewed placement as the Normal zone is again
filled up first before moving on to the next zone.

That is fine. But what about the balance in reclaiming workloads?

> > That's an insanely high level of aging inversion, where
> > the lifetime of a cache entry is again highly dependent on placement.
> > 
> 
> The aging is now indepdant of what zone the page was allocated from because
> it's node-based LRU reclaim. That may mean that the occupancy of individual
> zones is now different but it should only matter if there is a large number
> of address-limited requests.

The problem is that kswapd will stay awake and continuously draw
subsequent allocations into a single zone, thus utilizing only a
fraction of available memory. A DMA32-limited kswapd wakeups can
reclaim cache in DMA32 continuously if the allocator continously
places new cache pages in that zone. It looks like that is what
happened in the stutter benchmark.

Sure, it doesn't matter in that benchmark, because the pages are used
only once. But if it had an actual cache workingset bigger than DMA32
but smaller than DMA32+Normal, it would be thrashing unnecessarily.

If kswapd were truly balancing the pages in a node equally, regardless
of zone placement, then in the long run we should see zone allocations
converge to a share that is in proportion to each zone's size. As far
as I can see, that is not quite happening yet.

> > The fact that this doesn't make a performance difference in the
> > specific benchmarks you ran only proves just that: these specific
> > benchmarks don't care. IMO, benchmarking is not enough here. If this
> > is truly supposed to be unproblematic, then I think we need a reasoned
> > explanation. I can't imagine how it possibly could be, though.
> > 
> 
> The basic explanation is that reclaim is on a per-node basis and we
> no longer balance all zones, just one that is necessary to satisfy the
> original request that wokeup kswapd.
> 
> > If reclaim can't guarantee a balanced zone utilization then the
> > allocator has to keep doing it. :(
> 
> That's the key issue - the main reason balanced zone utilisation is
> necessary is because we reclaim on a per-zone basis and we must avoid
> page aging anomalies. If we balance such that one eligible zone is above
> the watermark then it's less of a concern.

Yes, but only if there can't be extended reclaim stretches that prefer
the pages of a single zone. Yet it looks like this is still possible.

I wonder if that were fixed by dropping patch 7/27? Potentially it
would need a bit more work than that. I.e. could we make kswapd
balance only for the highest classzone in the system, and thus make
address-limited allocations fend for themselves in direct reclaim?

This way, we would avoid that pathological interaction between kswapd
and the allocator, and kswapd would be guaranteed to balance fairly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
