Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 713F16B0254
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:19:35 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b205so8144445wmb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:19:35 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id d19si33480709wjs.146.2016.02.23.12.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 12:19:34 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id EEABE1C178F
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 20:19:33 +0000 (GMT)
Date: Tue, 23 Feb 2016 20:19:32 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH 00/27] Move LRU page reclaim from zones to nodes v2
Message-ID: <20160223201932.GN2854@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <20160223200416.GA27563@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160223200416.GA27563@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 12:04:16PM -0800, Johannes Weiner wrote:
> On Tue, Feb 23, 2016 at 03:04:23PM +0000, Mel Gorman wrote:
> > In many benchmarks, there is an obvious difference in the number of
> > allocations from each zone as the fair zone allocation policy is removed
> > towards the end of the series. For example, this is the allocation stats
> > when running blogbench that showed no difference in headling performance
> > 
> >                           mmotm-20160209   nodelru-v2
> > DMA allocs                           0           0
> > DMA32 allocs                   7218763      608067
> > Normal allocs                 12701806    18821286
> > Movable allocs                       0           0
> 
> According to the mmotm numbers, your DMA32 zone is over a third of
> available memory, yet in the nodelru-v2 kernel sees only 3% of the
> allocations.

In this case yes but blogbench is not scaled to memory size and is not
reclaim intensive. If you look, you'll see the total number of overall
allocations is very similar. During that test, there is a small amount of
kswapd scan activity (but not reclaim which is odd) at the start of the
test for nodelru but that's about it.

> That's an insanely high level of aging inversion, where
> the lifetime of a cache entry is again highly dependent on placement.
> 

The aging is now indepdant of what zone the page was allocated from because
it's node-based LRU reclaim. That may mean that the occupancy of individual
zones is now different but it should only matter if there is a large number
of address-limited requests.

> The fact that this doesn't make a performance difference in the
> specific benchmarks you ran only proves just that: these specific
> benchmarks don't care. IMO, benchmarking is not enough here. If this
> is truly supposed to be unproblematic, then I think we need a reasoned
> explanation. I can't imagine how it possibly could be, though.
> 

The basic explanation is that reclaim is on a per-node basis and we
no longer balance all zones, just one that is necessary to satisfy the
original request that wokeup kswapd.

> If reclaim can't guarantee a balanced zone utilization then the
> allocator has to keep doing it. :(

That's the key issue - the main reason balanced zone utilisation is
necessary is because we reclaim on a per-zone basis and we must avoid
page aging anomalies. If we balance such that one eligible zone is above
the watermark then it's less of a concern.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
