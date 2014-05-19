Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC026B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 00:47:34 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so5248456pad.11
        for <linux-mm@kvack.org>; Sun, 18 May 2014 21:47:34 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id be6si17963103pac.1.2014.05.18.21.47.32
        for <linux-mm@kvack.org>;
        Sun, 18 May 2014 21:47:33 -0700 (PDT)
Date: Mon, 19 May 2014 13:50:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140519045001.GA23916@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20140513030057.GC32092@bbox>
 <20140515015301.GA10116@js1304-P5Q-DELUXE>
 <20140515024353.GA27599@bbox>
 <20140519021121.GA19615@js1304-P5Q-DELUXE>
 <20140519025305.GA13248@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140519025305.GA13248@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>

On Mon, May 19, 2014 at 11:53:05AM +0900, Minchan Kim wrote:
> On Mon, May 19, 2014 at 11:11:21AM +0900, Joonsoo Kim wrote:
> > On Thu, May 15, 2014 at 11:43:53AM +0900, Minchan Kim wrote:
> > > On Thu, May 15, 2014 at 10:53:01AM +0900, Joonsoo Kim wrote:
> > > > On Tue, May 13, 2014 at 12:00:57PM +0900, Minchan Kim wrote:
> > > > > Hey Joonsoo,
> > > > > 
> > > > > On Thu, May 08, 2014 at 09:32:23AM +0900, Joonsoo Kim wrote:
> > > > > > CMA is introduced to provide physically contiguous pages at runtime.
> > > > > > For this purpose, it reserves memory at boot time. Although it reserve
> > > > > > memory, this reserved memory can be used for movable memory allocation
> > > > > > request. This usecase is beneficial to the system that needs this CMA
> > > > > > reserved memory infrequently and it is one of main purpose of
> > > > > > introducing CMA.
> > > > > > 
> > > > > > But, there is a problem in current implementation. The problem is that
> > > > > > it works like as just reserved memory approach. The pages on cma reserved
> > > > > > memory are hardly used for movable memory allocation. This is caused by
> > > > > > combination of allocation and reclaim policy.
> > > > > > 
> > > > > > The pages on cma reserved memory are allocated if there is no movable
> > > > > > memory, that is, as fallback allocation. So the time this fallback
> > > > > > allocation is started is under heavy memory pressure. Although it is under
> > > > > > memory pressure, movable allocation easily succeed, since there would be
> > > > > > many pages on cma reserved memory. But this is not the case for unmovable
> > > > > > and reclaimable allocation, because they can't use the pages on cma
> > > > > > reserved memory. These allocations regard system's free memory as
> > > > > > (free pages - free cma pages) on watermark checking, that is, free
> > > > > > unmovable pages + free reclaimable pages + free movable pages. Because
> > > > > > we already exhausted movable pages, only free pages we have are unmovable
> > > > > > and reclaimable types and this would be really small amount. So watermark
> > > > > > checking would be failed. It will wake up kswapd to make enough free
> > > > > > memory for unmovable and reclaimable allocation and kswapd will do.
> > > > > > So before we fully utilize pages on cma reserved memory, kswapd start to
> > > > > > reclaim memory and try to make free memory over the high watermark. This
> > > > > > watermark checking by kswapd doesn't take care free cma pages so many
> > > > > > movable pages would be reclaimed. After then, we have a lot of movable
> > > > > > pages again, so fallback allocation doesn't happen again. To conclude,
> > > > > > amount of free memory on meminfo which includes free CMA pages is moving
> > > > > > around 512 MB if I reserve 512 MB memory for CMA.
> > > > > > 
> > > > > > I found this problem on following experiment.
> > > > > > 
> > > > > > 4 CPUs, 1024 MB, VIRTUAL MACHINE
> > > > > > make -j24
> > > > > > 
> > > > > > CMA reserve:		0 MB		512 MB
> > > > > > Elapsed-time:		234.8		361.8
> > > > > > Average-MemFree:	283880 KB	530851 KB
> > > > > > 
> > > > > > To solve this problem, I can think following 2 possible solutions.
> > > > > > 1. allocate the pages on cma reserved memory first, and if they are
> > > > > >    exhausted, allocate movable pages.
> > > > > > 2. interleaved allocation: try to allocate specific amounts of memory
> > > > > >    from cma reserved memory and then allocate from free movable memory.
> > > > > 
> > > > > I love this idea but when I see the code, I don't like that.
> > > > > In allocation path, just try to allocate pages by round-robin so it's role
> > > > > of allocator. If one of migratetype is full, just pass mission to reclaimer
> > > > > with hint(ie, Hey reclaimer, it's non-movable allocation fail
> > > > > so there is pointless if you reclaim MIGRATE_CMA pages) so that
> > > > > reclaimer can filter it out during page scanning.
> > > > > We already have an tool to achieve it(ie, isolate_mode_t).
> > > > 
> > > > Hello,
> > > > 
> > > > I agree with leaving fast allocation path as simple as possible.
> > > > I will remove runtime computation for determining ratio in
> > > > __rmqueue_cma() and, instead, will use pre-computed value calculated
> > > > on the other path.
> > > 
> > > Sounds good.
> > > 
> > > > 
> > > > I am not sure that whether your second suggestion(Hey relaimer part)
> > > > is good or not. In my quick thought, that could be helpful in the
> > > > situation that many free cma pages remained. But, it would be not helpful
> > > > when there are neither free movable and cma pages. In generally, most
> > > > workloads mainly uses movable pages for page cache or anonymous mapping.
> > > > Although reclaim is triggered by non-movable allocation failure, reclaimed
> > > > pages are used mostly by movable allocation. We can handle these allocation
> > > > request even if we reclaim the pages just in lru order. If we rotate
> > > > the lru list for finding movable pages, it could cause more useful
> > > > pages to be evicted.
> > > > 
> > > > This is just my quick thought, so please let me correct if I am wrong.
> > > 
> > > Why should reclaimer reclaim unnecessary pages?
> > > So, your answer is that it would be better because upcoming newly allocated
> > > pages would be allocated easily without interrupt. But it could reclaim
> > > too much pages until watermark for unmovable allocation is okay.
> > > Even, sometime, you might see OOM.
> > > 
> > > Moreover, how could you handle current trobule?
> > > For example, there is atomic allocation and the only thing to save the world
> > > is kswapd because it's one of kswapd role but kswapd is spending many time to
> > > reclaim CMA pages, which is pointless so the allocation would be easily failed.
> > 
> > Hello,
> > 
> > I guess that it isn't the problem. In lru, movable pages and cma pages
> > would be interleaved. So it doesn't takes too long time to get the
> > page for non-movable allocation.
> 
> Please, don't assume there are ideal LRU ordering.
> Newly allocated page by fairness allocation is located by head of LRU
> while old pages are approaching the tail so there is huge time gab.
> During the time, old pages could be dropped/promoting so one of side
> could be filled with one type rather than interleaving both types pages
> you expected.

I assumed general case, not ideal case.
Your example can be possible, but would be corner case.

> 
> Additionally, if you uses syncable backed device like ramdisk/zram
> or something, pageout can be synchronized with page I/O.
> In this case, reclaim time wouldn't be trivial than async I/O.
> For exmaple, zram-swap case, it needs page copy + comperssion and
> the speed depends on your CPU speed.

This is a general problem what zram-swap have,
although reclaiming cma pages worse the situation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
