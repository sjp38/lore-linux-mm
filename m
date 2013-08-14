Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B70DE6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 12:16:47 -0400 (EDT)
Date: Wed, 14 Aug 2013 17:16:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130814161642.GM2296@suse.de>
References: <520B0B75.4030708@huawei.com>
 <20130814085711.GK2296@suse.de>
 <20130814155205.GA2706@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130814155205.GA2706@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 15, 2013 at 12:52:29AM +0900, Minchan Kim wrote:
> Hi Mel,
> 
> On Wed, Aug 14, 2013 at 09:57:11AM +0100, Mel Gorman wrote:
> > On Wed, Aug 14, 2013 at 12:45:41PM +0800, Xishi Qiu wrote:
> > > A large free page buddy block will continue many times, so if the page 
> > > is free, skip the whole page buddy block instead of one page.
> > > 
> > > Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> > 
> > page_order cannot be used unless zone->lock is held which is not held in
> > this path. Acquiring the lock would prevent parallel allocations from the
> 
> Argh, I missed that. And it seems you already pointed it out long time ago
> someone try to do same things if I remember correctly. :(

It feels familiar but I do not remember why.

> But let's think about it more.
> 
> It's always not right because CMA and memory-hotplug already isolated
> free pages in the range to MIGRATE_ISOLATE right before starting migration
> so we could use page_order safely in those contexts even if we don't hold
> zone->lock.
>  

Both of those are teh corner cases. Neither operation happen frequently
in comparison to something like THP allocations for example. I think an
optimisation along those lines is marginal at best.

> In addition, it's likely to have many free pages in case of CMA because CMA
> makes MIGRATE_CMA fallback of MIGRATE_MOVABLE to minimize number of migrations.
> Even CMA area was full, it could have many free pages once driver who is
> CMA area's owner releases the CMA area. So, the bigger CMA space is,
> the bigger patch's benefit is. And it could help memory-hotplug, too.
> 
> Only problem is normal compaction. The worst case is just skipping
> pageblock_nr_pages, for instace, 4M(of course, it depends on configuration).
> but we can make the race window very small by dobule checking PageBuddy.
> Still, it could make the race theoretically but I think it's really really
> unlikely and still enhance compaction overhead withtout holding the lock.
> Even if the race happens, normal compaction's customers(ex, THP) doesn't
> have critical result and just fallback. So I think it isn't not bad tradeoff.
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 05ccb4c..2341d52 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -520,8 +520,18 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			goto next_pageblock;
>  
>  		/* Skip if free */
> -		if (PageBuddy(page))
> +		if (PageBuddy(page)) {
> +			/*
> +			 * page_order is racy without zone->lock but worst case
> +			 * by the racing is just skipping pageblock_nr_pages.
> +			 * but even the race is really unlikely by double
> +			 * check of PageBuddy.
> +			 */
> +			unsigned long order = page_order(page);
> +			if (PageBuddy(page))
> +				low_pfn += (1 << order) - 1;
>  			continue;
> +		}
>  

Even if the page is still page buddy, there is no guarantee that it's
the same page order as the first read. It could have be currently
merging with adjacent buddies for example. There is also a really
small race that a page was freed, allocated with some number stuffed
into page->private and freed again before the second PageBuddy check.
It's a bit of a hand grenade. How much of a performance benefit is there
from this patch?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
