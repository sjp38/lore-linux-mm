Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 57C0A6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 01:04:00 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so583871pbc.18
        for <linux-mm@kvack.org>; Wed, 14 May 2014 22:04:00 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id hb8si2060855pbc.239.2014.05.14.22.03.58
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 22:03:59 -0700 (PDT)
Date: Thu, 15 May 2014 14:06:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140515050627.GB27599@bbox>
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

Hello Heesub,

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

Actually, I discussed with Joonsoo to solve such corner case in future if
someone report it but you did it now. Thanks!

LRU churning is a general problem, not CMA specific although CMA would make
worse more agressively so I'd like to handle it another topic(ie, patchset)

The reason we did rotate them back to LRU head was just to avoid scanning
repeat overhead of one reclaim cycle so one of idea I can think of is that
we can put a reclaim cursor into LRU tail right before reclaim cycle and
start scanning from the cursor and update the cursor position on every
scanning cycle. Of course, we should rotate filtered out pages back to
LRU's tail, not head but with cursor, we can skip pointless pages which was
already scanned by this reclaim cycle.

The cursor should be removed when the reclaim cycle would be done so if next
reclaim happens, cursor will start from the beginning so it could make
unecessary scanning again until reaching the proper victim page so CPU usage
would be higher but it's better than evicting working set.

Another idea?

> reasons, but it must be easy for yourself. I am wondering if it
> could help also in your case.
> 
> Thanks,
> Heesub
> 
> >
> >>
> >>And we couldn't do it in zone_watermark_ok with set/reset ALLOC_CMA?
> >>If possible, it would be better becauser it's generic function to check
> >>free pages and cause trigger reclaim/compaction logic.
> >
> >I guess, your *it* means ratio computation. Right?
> >I don't like putting it on zone_watermark_ok(). Although it need to
> >refer to free cma pages value which are also referred in zone_watermark_ok(),
> >this computation is for determining ratio, not for triggering
> >reclaim/compaction. And this zone_watermark_ok() is on more hot-path, so
> >putting this logic into zone_watermark_ok() looks not better to me.
> >
> >I will think better place to do it.
> >
> >Thanks.
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
