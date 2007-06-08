Date: Fri, 8 Jun 2007 22:59:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memory unplug v4 intro [4/6] page isolation
Message-Id: <20070608225903.ae3c1794.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070608132411.GA9390@skynet.ie>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
	<20070608144151.ac8408e0.kamezawa.hiroyu@jp.fujitsu.com>
	<20070608132411.GA9390@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007 14:24:11 +0100
mel@skynet.ie (Mel Gorman) wrote:

> > +/*
> > + * Chack a range of pages are isolated or not.
> > + * returns next pfn to be tested.
> > + * If pfn is not isoalted, returns 0.
> > + */
> > +
> 
> Spurious whitespace here. isolated is misspelt.
> 
ok.

> > +unsigned long test_and_next_isolated_page(unsigned long pfn)
> > +{
> 
> Can this be defined with test_isolated_pages() as page_order() is now
> defined in internal.h?
> 
I dropped per-page test in this version and added faster one.
Will we need per-page test ?

> > +	struct page *page;
> > +	if (!pfn_valid(pfn))
> > +		return 0;
> 
> The caller is already calling pfn_valid() so this should be unnecessary.
> 
hmm, ok.

> Also, you may be calling pfn_valid() more than required. 
maybe yes.

> If you know a PFN
> is within a MAX_ORDER block that contains at least one valid page, you only
> have to call pfn_valid_within() which is a no-op on almost every architecture
> but IA64.
ok, I'll look it.

> 
> > +	page = pfn_to_page(pfn);
> > +	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> > +		return 0;
> 
> You shouldn't need to check this for every single page.
> 
Hmm, I don't have to ?
BTW, shall I move this func to page_isolation.c ?

> > +	if (PageBuddy(page))
> > +		return pfn + (1 << page_order(page));
> > +	/* Means pages in pcp list */
> > +	if (page_count(page) == 0 && page_private(page) == MIGRATE_ISOLATE)
> > +		return pfn + 1;
> > +	return 0;
> > +}
> > +
> > +/*
> > + * set/clear page block's type to be ISOLATE.
> > + * page allocater never alloc memory from ISOLATE block.
> > + */
> > +
> > +
> 
> More spurious whitespace
> 
Ugh..sorry.

> > +int set_migratetype_isolate(struct page *page)
> > +{
> > +	struct zone *zone;
> > +	unsigned long flags;
> > +	int ret = -EBUSY;
> > +
> > +	zone = page_zone(page);
> > +	spin_lock_irqsave(&zone->lock, flags);
> > +	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
> > +		goto out;
> 
> hmmm, review this decision on a regular basis. If the block was reclaimable
> and Christoph's SLUB defragmentation patches work out, there will be more
> block types that can be isolated.
> 
*maybe* yes. we can change this check later.


> As these are externally available, they could do with kerneldoc comments
> explaining their purpose.
> 
> /**
>  * make_pagetype_isolated - Mark a range of pages to be isolated from the buddy allocator
>  * @start_pfn: The lower PFN of the range to be isolated
>  * @end_pfn: The upper PFN of the range to be isolated
>  *
>  * Mark a range of pages to be isolated from the buddy allocator. Any
>  * currently free page will no longer be available when this returns
>  * successfully. Any page freed in the future will similarly be isolated
>  * 
>  * Returns 0 on success and -EBUSY if any part of the range cannot be
>  * isolated
>  */
> 
> or something
ok, I'll do.

> 
> The names are not great either.
> 
> isolate_page_range() and putback_isolated_range() prehaps? I am not the
> best at naming things so prehaps others will have better suggestions.
> 
Hmm, I'll look for better name.

> > +	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
> > +	unsigned long undo_pfn;
> > +
> > +	start_pfn_aligned = rounddown(start_pfn, NR_PAGES_ISOLATION_BLOCK);
> > +	end_pfn_aligned = roundup(end_pfn, NR_PAGES_ISOLATION_BLOCK);
> > +
> 
> Check that the aligned PFNs do not go outside the zone range. This sort of
> check has come up a lot, it may be a candidate for it's own helper.
> 
Hmm, now, the caller checks it. but ok. I'll add check here.


> 
> > +#define PAGE_ISOLATION_ORDER	(MAX_ORDER - 1)
> > +#define NR_PAGES_ISOLATION_BLOCK	(1 << PAGE_ISOLATION_ORDER)
> > +
> 
> Consider using pageblock_order and pageblock_nr_pages from
> pageblock-flags.h
> 
yes, of course.

Thank you for review.

It seems the total constructure of patch is not so good. I'll rebuild it.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
