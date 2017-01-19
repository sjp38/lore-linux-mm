Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1FD6B02A0
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 07:52:46 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gt1so8210876wjc.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 04:52:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d22si4365059wrb.2.2017.01.19.04.52.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 04:52:44 -0800 (PST)
Subject: Re: [RFC PATCH 3/5] mm: introduce exponential moving average to
 unusable free index
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1484291673-2239-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fbd7ad3f-3ed3-983a-b3d1-b2e72f79cd6a@suse.cz>
Date: Thu, 19 Jan 2017 13:52:38 +0100
MIME-Version: 1.0
In-Reply-To: <1484291673-2239-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/13/2017 08:14 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> We have a statistic about memory fragmentation but it would be fluctuated
> a lot within very short term so it's hard to accurately measure
> system's fragmentation state while workload is actively running. Without
> stable statistic, it's not possible to determine if the system is
> fragmented or not.
> 
> Meanwhile, recently, there were a lot of reports about fragmentation
> problem and we tried some changes. However, since there is no way
> to measure fragmentation ratio stably, we cannot make sure how these
> changes help the fragmentation.
> 
> There are some methods to measure fragmentation but I think that they
> have some problems.
> 
> 1. buddyinfo: it fluctuated a lot within very short term
> 2. tracepoint: it shows how steal happens between buddylists of different
> migratetype. It means fragmentation indirectly but would not be accurate.
> 3. pageowner: it shows the number of mixed pageblocks but it is not
> suitable for production system since it requires some additional memory.
> 
> Therefore, this patch try to calculate exponential moving average to
> unusable free index. Since it is a moving average, it is quite stable
> even if fragmentation state of memory fluctuate a lot.

I suspect that the fluctuation of the underlying unusable free index
isn't so much because the number of high-order free blocks would
fluctuate, but because of allocation vs reclaim changing the total
number of free blocks, which is used in the equation. Reclaim uses LRU
which I expect to have low correlation with pfn, so the freed pages tend
towards order-0. And the allocation side tries not to split large pages
so it also consumes mostly order-0.

So I would expect just plain free_blocks_order from contig_page_info to
be a good metric without need for averaging, at least for costly orders
and when we have enough free memory - if we are below e.g. the high
(order-0) watermark, then we should let kswapd do its job first anyway
before considering proactive compaction.

> I made this patch 3 month ago and implementation detail looks not
> good to me now. Maybe, it's better to rule out update code in allocation
> path and make it timer based. Anyway, this patch is just for RFC.

Yeah, any hooks in allocation/free hotpaths are going to meet strong
resistance :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
