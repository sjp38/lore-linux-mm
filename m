Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A5DEF6B0037
	for <linux-mm@kvack.org>; Mon, 19 May 2014 19:19:30 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so6440395pad.41
        for <linux-mm@kvack.org>; Mon, 19 May 2014 16:19:30 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id gp6si21428605pac.215.2014.05.19.16.19.28
        for <linux-mm@kvack.org>;
        Mon, 19 May 2014 16:19:29 -0700 (PDT)
Date: Tue, 20 May 2014 08:22:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140519232215.GB21636@bbox>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20140513030057.GC32092@bbox>
 <20140515015301.GA10116@js1304-P5Q-DELUXE>
 <53742A4B.4090901@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53742A4B.4090901@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, May 15, 2014 at 11:45:31AM +0900, Heesub Shin wrote:
> Hello,
> 
> On 05/15/2014 10:53 AM, Joonsoo Kim wrote:
> >On Tue, May 13, 2014 at 12:00:57PM +0900, Minchan Kim wrote:
> >>Hey Joonsoo,
> >>
> >>On Thu, May 08, 2014 at 09:32:23AM +0900, Joonsoo Kim wrote:
> >>>CMA is introduced to provide physically contiguous pages at runtime.
> >>>For this purpose, it reserves memory at boot time. Although it reserve
> >>>memory, this reserved memory can be used for movable memory allocation
> >>>request. This usecase is beneficial to the system that needs this CMA
> >>>reserved memory infrequently and it is one of main purpose of
> >>>introducing CMA.
> >>>
> >>>But, there is a problem in current implementation. The problem is that
> >>>it works like as just reserved memory approach. The pages on cma reserved
> >>>memory are hardly used for movable memory allocation. This is caused by
> >>>combination of allocation and reclaim policy.
> >>>
> >>>The pages on cma reserved memory are allocated if there is no movable
> >>>memory, that is, as fallback allocation. So the time this fallback
> >>>allocation is started is under heavy memory pressure. Although it is under
> >>>memory pressure, movable allocation easily succeed, since there would be
> >>>many pages on cma reserved memory. But this is not the case for unmovable
> >>>and reclaimable allocation, because they can't use the pages on cma
> >>>reserved memory. These allocations regard system's free memory as
> >>>(free pages - free cma pages) on watermark checking, that is, free
> >>>unmovable pages + free reclaimable pages + free movable pages. Because
> >>>we already exhausted movable pages, only free pages we have are unmovable
> >>>and reclaimable types and this would be really small amount. So watermark
> >>>checking would be failed. It will wake up kswapd to make enough free
> >>>memory for unmovable and reclaimable allocation and kswapd will do.
> >>>So before we fully utilize pages on cma reserved memory, kswapd start to
> >>>reclaim memory and try to make free memory over the high watermark. This
> >>>watermark checking by kswapd doesn't take care free cma pages so many
> >>>movable pages would be reclaimed. After then, we have a lot of movable
> >>>pages again, so fallback allocation doesn't happen again. To conclude,
> >>>amount of free memory on meminfo which includes free CMA pages is moving
> >>>around 512 MB if I reserve 512 MB memory for CMA.
> >>>
> >>>I found this problem on following experiment.
> >>>
> >>>4 CPUs, 1024 MB, VIRTUAL MACHINE
> >>>make -j24
> >>>
> >>>CMA reserve:		0 MB		512 MB
> >>>Elapsed-time:		234.8		361.8
> >>>Average-MemFree:	283880 KB	530851 KB
> >>>
> >>>To solve this problem, I can think following 2 possible solutions.
> >>>1. allocate the pages on cma reserved memory first, and if they are
> >>>    exhausted, allocate movable pages.
> >>>2. interleaved allocation: try to allocate specific amounts of memory
> >>>    from cma reserved memory and then allocate from free movable memory.
> >>
> >>I love this idea but when I see the code, I don't like that.
> >>In allocation path, just try to allocate pages by round-robin so it's role
> >>of allocator. If one of migratetype is full, just pass mission to reclaimer
> >>with hint(ie, Hey reclaimer, it's non-movable allocation fail
> >>so there is pointless if you reclaim MIGRATE_CMA pages) so that
> >>reclaimer can filter it out during page scanning.
> >>We already have an tool to achieve it(ie, isolate_mode_t).
> >
> >Hello,
> >
> >I agree with leaving fast allocation path as simple as possible.
> >I will remove runtime computation for determining ratio in
> >__rmqueue_cma() and, instead, will use pre-computed value calculated
> >on the other path.
> >
> >I am not sure that whether your second suggestion(Hey relaimer part)
> >is good or not. In my quick thought, that could be helpful in the
> >situation that many free cma pages remained. But, it would be not helpful
> >when there are neither free movable and cma pages. In generally, most
> >workloads mainly uses movable pages for page cache or anonymous mapping.
> >Although reclaim is triggered by non-movable allocation failure, reclaimed
> >pages are used mostly by movable allocation. We can handle these allocation
> >request even if we reclaim the pages just in lru order. If we rotate
> >the lru list for finding movable pages, it could cause more useful
> >pages to be evicted.
> >
> >This is just my quick thought, so please let me correct if I am wrong.
> 
> We have an out of tree implementation that is completely the same
> with the approach Minchan said and it works, but it has definitely
> some side-effects as you pointed, distorting the LRU and evicting
> hot pages. I do not attach code fragments in this thread for some
> reasons, but it must be easy for yourself. I am wondering if it
> could help also in your case.
> 
> Thanks,
> Heesub

Heesub, To be sure, did you try round-robin allocate like Joonsoo's
approach and happend such LRU churning problem?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
