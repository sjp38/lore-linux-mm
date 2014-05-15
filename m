Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE616B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 22:08:43 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so392978pad.18
        for <linux-mm@kvack.org>; Wed, 14 May 2014 19:08:43 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pt4si3698829pac.241.2014.05.14.19.08.41
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 19:08:42 -0700 (PDT)
Date: Thu, 15 May 2014 11:10:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/3] Aggressively allocate the pages on cma reserved
 memory
Message-ID: <20140515021055.GC10116@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <536CCC78.6050806@samsung.com>
 <20140513022603.GF23803@js1304-P5Q-DELUXE>
 <8738gcae4h.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8738gcae4h.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, 'Tomasz Stanislawski' <t.stanislaws@samsung.com>

On Wed, May 14, 2014 at 03:14:30PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > On Fri, May 09, 2014 at 02:39:20PM +0200, Marek Szyprowski wrote:
> >> Hello,
> >> 
> >> On 2014-05-08 02:32, Joonsoo Kim wrote:
> >> >This series tries to improve CMA.
> >> >
> >> >CMA is introduced to provide physically contiguous pages at runtime
> >> >without reserving memory area. But, current implementation works like as
> >> >reserving memory approach, because allocation on cma reserved region only
> >> >occurs as fallback of migrate_movable allocation. We can allocate from it
> >> >when there is no movable page. In that situation, kswapd would be invoked
> >> >easily since unmovable and reclaimable allocation consider
> >> >(free pages - free CMA pages) as free memory on the system and free memory
> >> >may be lower than high watermark in that case. If kswapd start to reclaim
> >> >memory, then fallback allocation doesn't occur much.
> >> >
> >> >In my experiment, I found that if system memory has 1024 MB memory and
> >> >has 512 MB reserved memory for CMA, kswapd is mostly invoked around
> >> >the 512MB free memory boundary. And invoked kswapd tries to make free
> >> >memory until (free pages - free CMA pages) is higher than high watermark,
> >> >so free memory on meminfo is moving around 512MB boundary consistently.
> >> >
> >> >To fix this problem, we should allocate the pages on cma reserved memory
> >> >more aggressively and intelligenetly. Patch 2 implements the solution.
> >> >Patch 1 is the simple optimization which remove useless re-trial and patch 3
> >> >is for removing useless alloc flag, so these are not important.
> >> >See patch 2 for more detailed description.
> >> >
> >> >This patchset is based on v3.15-rc4.
> >> 
> >> Thanks for posting those patches. It basically reminds me the
> >> following discussion:
> >> http://thread.gmane.org/gmane.linux.kernel/1391989/focus=1399524
> >> 
> >> Your approach is basically the same. I hope that your patches can be
> >> improved
> >> in such a way that they will be accepted by mm maintainers. I only
> >> wonder if the
> >> third patch is really necessary. Without it kswapd wakeup might be
> >> still avoided
> >> in some cases.
> >
> > Hello,
> >
> > Oh... I didn't know that patch and discussion, because I have no interest
> > on CMA at that time. Your approach looks similar to #1
> > approach of mine and could have same problem of #1 approach which I mentioned
> > in patch 2/3. Please refer that patch description. :)
> 
> IIUC that patch also interleave right ?
> 
> +#ifdef CONFIG_CMA
> +	unsigned long nr_free = zone_page_state(zone, NR_FREE_PAGES);
> +	unsigned long nr_cma_free = zone_page_state(zone, NR_FREE_CMA_PAGES);
> +
> +	if (migratetype == MIGRATE_MOVABLE && nr_cma_free &&
> +	    nr_free - nr_cma_free < 2 * low_wmark_pages(zone))
> +		migratetype = MIGRATE_CMA;
> +#endif /* CONFIG_CMA */

Hello,

This is not interleave in my point of view. This logic will allocate
free movable pages until hitting 2 * low_wmark, and then allocate free
cma pages. Interleave that I mean is something like round-robin policy
with no constraint like above.

> 
> That doesn't always prefer CMA region. It would be nice to
> understand why grouping in pageblock_nr_pages is beneficial. Also in
> your patch you decrement nr_try_cma for every 'order' allocation. Why ?

pageblock_nr_pages is just magic value with no rationale. :)
But we need grouping, because without it, we can't get physically
contiguous pages. When we allocate the pages for page cache, readahead
logic will try to allocate 32 pages. If we don't use grouping, disk
I/O for these pages can't be handled by one I/O request on some devices.
I'm not familiar to I/O device, please let me correct.

And, yes, I will consider 'order' allocation when inc/dec nr_try_cma.

> 
> +	if (zone->nr_try_cma) {
> +		/* Okay. Now, we can try to allocate the page from cma region */
> +		zone->nr_try_cma--;
> +		page = __rmqueue_smallest(zone, order, MIGRATE_CMA);
> +
> +		/* CMA pages can vanish through CMA allocation */
> +		if (unlikely(!page && order == 0))
> +			zone->nr_try_cma = 0;
> +
> +		return page;
> +	}
> 
> 
> If we fail above MIGRATE_CMA alloc should we return failure ? Why
> not try MOVABLE allocation on failure (ie fallthrough the code path) ?

This patch use fallthrough logic. If we fail on __rmqueue_cma(), it will
go __rmqueue() as usual.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
