Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 5FA566B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:11:09 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so6835325pdi.41
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 12:11:08 -0700 (PDT)
Date: Thu, 15 Aug 2013 04:11:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130814191101.GB2753@gmail.com>
References: <520B0B75.4030708@huawei.com>
 <20130814085711.GK2296@suse.de>
 <20130814155205.GA2706@gmail.com>
 <20130814161642.GM2296@suse.de>
 <20130814163921.GC2706@gmail.com>
 <20130814180012.GO2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814180012.GO2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 14, 2013 at 07:00:12PM +0100, Mel Gorman wrote:
> On Thu, Aug 15, 2013 at 01:39:21AM +0900, Minchan Kim wrote:
> > On Wed, Aug 14, 2013 at 05:16:42PM +0100, Mel Gorman wrote:
> > > On Thu, Aug 15, 2013 at 12:52:29AM +0900, Minchan Kim wrote:
> > > > Hi Mel,
> > > > 
> > > > On Wed, Aug 14, 2013 at 09:57:11AM +0100, Mel Gorman wrote:
> > > > > On Wed, Aug 14, 2013 at 12:45:41PM +0800, Xishi Qiu wrote:
> > > > > > A large free page buddy block will continue many times, so if the page 
> > > > > > is free, skip the whole page buddy block instead of one page.
> > > > > > 
> > > > > > Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> > > > > 
> > > > > page_order cannot be used unless zone->lock is held which is not held in
> > > > > this path. Acquiring the lock would prevent parallel allocations from the
> > > > 
> > > > Argh, I missed that. And it seems you already pointed it out long time ago
> > > > someone try to do same things if I remember correctly. :(
> > > 
> > > It feels familiar but I do not remember why.
> > > 
> > > > But let's think about it more.
> > > > 
> > > > It's always not right because CMA and memory-hotplug already isolated
> > > > free pages in the range to MIGRATE_ISOLATE right before starting migration
> > > > so we could use page_order safely in those contexts even if we don't hold
> > > > zone->lock.
> > > >  
> > > 
> > > Both of those are teh corner cases. Neither operation happen frequently
> > > in comparison to something like THP allocations for example. I think an
> > > optimisation along those lines is marginal at best.
> > 
> > In embedded side, we don't use THP yet but uses CMA and memory-hotplug so
> > your claim isn't the case for the embedded world.
> 
> I thought CMA was only used when certain devices require large
> contiguous ranges of memory. The expectation was that such allocations
> are relatively rare and the cost savings from this patch would not be

It's not true. It depends on user activity.
For exmaple, if user opens the app like camera frequenlty, CMA allocation can
happen frequently if we implement image buffer for camera as CMA.

> measurable. Considering how heavy the memory hotplug operation is I also
> severely doubt that not being able to skip over PageBuddy pages in
> compaction is noticable.
> 
> > > >  		/* Skip if free */
> > > > -		if (PageBuddy(page))
> > > > +		if (PageBuddy(page)) {
> > > > +			/*
> > > > +			 * page_order is racy without zone->lock but worst case
> > > > +			 * by the racing is just skipping pageblock_nr_pages.
> > > > +			 * but even the race is really unlikely by double
> > > > +			 * check of PageBuddy.
> > > > +			 */
> > > > +			unsigned long order = page_order(page);
> > > > +			if (PageBuddy(page))
> > > > +				low_pfn += (1 << order) - 1;
> > > >  			continue;
> > > > +		}
> > > >  
> > > 
> > > Even if the page is still page buddy, there is no guarantee that it's
> > > the same page order as the first read. It could have be currently
> > > merging with adjacent buddies for example. There is also a really
> > > small race that a page was freed, allocated with some number stuffed
> > > into page->private and freed again before the second PageBuddy check.
> > > It's a bit of a hand grenade. How much of a performance benefit is there
> > 
> > 1. Just worst case is skipping pageblock_nr_pages
> 
> No, the worst case is that page_order returns a number that is
> completely garbage and low_pfn goes off the end of the zone

Sigh, I missed low_pfn is return value so you're right but we can simple
fix it with min(low_pfn, end_pfn).

> 
> > 2. Race is really small
> > 3. Higher order page allocation customer always have graceful fallback.
> > 
> > If you really have a concern about that, we can add following.
> > 
> > -		if (PageBuddy(page))
> > +		if (PageBuddy(page)) {
> > +#ifdef CONFIG_MEMORY_ISOLATION
> > +			/*
> > +			 * memory-hotplug and CMA already move free pages to
> > +			 * MIGRATE_ISOLATE so we can use page_order safely
> > +			 * without zone->lock.
> > +			 */
> > +			if (PageBuddy(page))
> > +				low_pfn += (1 << page_order(page)) - 1;
> > +#endif
> >  			continue;
> > +		}
> 
> How does that help anything? MEMORY_ISOLATION is set in distribution
> configs and there is no guarantee at all and the same race exists. If it
> was going to be anything it would be something like this untested hack

Argh, I sent wrong versoin patch. Here is 4:06 am so maybe I need sleeping. :(

> 
> /*
>  * It is not safe to call page_order(page) for a PageBuddy page without
>  * holding the zone lock as the order can change or the page allocated.
>  * Check PageBuddy after reading page_order to minimise the race. As
>  * the value could still be stale, make sure that we do not accidentally
>  * skip past the end of the largest page the buddy allocator handles.
>  */
> if (PageBuddy(page)) {
> 	int nr_pages = (1 << page_order(page)) - 1;
> 	if (PageBuddy(page)) {
> 		nr_pages = min(nr_pages, MAX_ORDER_NR_PAGES - 1);
> 		low_pfn += nr_pages;
> 		continue;
> 	}
> }

My version is following as

	if (PageBuddy(page)) {
#ifdef CONFIG_MEMOR_ISOLATION
		unsigned long order = page_order(page);
		if (PageBuddy(page)) {
			low_pfn += (1 << order) - 1;
			low_pfn = min(low_pfn, end_pfn);
		}	
#endif
		continue;
	}


> 
> It's still race-prone meaning that it really should be backed by some
> performance data justifying it.

Okay.

Thanks for the input, Mel!
> 
> -- 
> Mel Gorman
> SUSE Labs
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
