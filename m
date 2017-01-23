Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60D596B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 00:21:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 201so189255519pfw.5
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 21:21:27 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a3si13011490pld.64.2017.01.22.21.21.25
        for <linux-mm@kvack.org>;
        Sun, 22 Jan 2017 21:21:26 -0800 (PST)
Date: Mon, 23 Jan 2017 14:27:46 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 3/5] mm: introduce exponential moving average to
 unusable free index
Message-ID: <20170123052746.GD24581@js1304-P5Q-DELUXE>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1484291673-2239-4-git-send-email-iamjoonsoo.kim@lge.com>
 <fbd7ad3f-3ed3-983a-b3d1-b2e72f79cd6a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fbd7ad3f-3ed3-983a-b3d1-b2e72f79cd6a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Jan 19, 2017 at 01:52:38PM +0100, Vlastimil Babka wrote:
> On 01/13/2017 08:14 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > We have a statistic about memory fragmentation but it would be fluctuated
> > a lot within very short term so it's hard to accurately measure
> > system's fragmentation state while workload is actively running. Without
> > stable statistic, it's not possible to determine if the system is
> > fragmented or not.
> > 
> > Meanwhile, recently, there were a lot of reports about fragmentation
> > problem and we tried some changes. However, since there is no way
> > to measure fragmentation ratio stably, we cannot make sure how these
> > changes help the fragmentation.
> > 
> > There are some methods to measure fragmentation but I think that they
> > have some problems.
> > 
> > 1. buddyinfo: it fluctuated a lot within very short term
> > 2. tracepoint: it shows how steal happens between buddylists of different
> > migratetype. It means fragmentation indirectly but would not be accurate.
> > 3. pageowner: it shows the number of mixed pageblocks but it is not
> > suitable for production system since it requires some additional memory.
> > 
> > Therefore, this patch try to calculate exponential moving average to
> > unusable free index. Since it is a moving average, it is quite stable
> > even if fragmentation state of memory fluctuate a lot.
> 
> I suspect that the fluctuation of the underlying unusable free index
> isn't so much because the number of high-order free blocks would
> fluctuate, but because of allocation vs reclaim changing the total
> number of free blocks, which is used in the equation. Reclaim uses LRU
> which I expect to have low correlation with pfn, so the freed pages tend
> towards order-0. And the allocation side tries not to split large pages
> so it also consumes mostly order-0.

I introduced this metric because I observed fluctuation of unusable
free index. :)

> 
> So I would expect just plain free_blocks_order from contig_page_info to
> be a good metric without need for averaging, at least for costly orders
> and when we have enough free memory - if we are below e.g. the high
> (order-0) watermark, then we should let kswapd do its job first anyway
> before considering proactive compaction.

Maybe, plain free_blocks_order would be stable for the order 7 or more
but it's better to have the metric that works well for all orders.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
