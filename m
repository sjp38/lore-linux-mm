Date: Tue, 19 Jun 2007 17:36:11 +0100
Subject: Re: [PATCH 5/7] Introduce a means of compacting memory within a zone
Message-ID: <20070619163611.GD17109@skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie> <20070618093002.7790.68471.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0706181010030.4751@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706181010030.4751@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On (18/06/07 10:18), Christoph Lameter didst pronounce:
> On Mon, 18 Jun 2007, Mel Gorman wrote:
> 
> > +	/* Isolate free pages. This assumes the block is valid */
> > +	for (; blockpfn < end_pfn; blockpfn++) {
> > +		struct page *page;
> > +		int isolated, i;
> > +
> > +		if (!pfn_valid_within(blockpfn))
> > +			continue;
> > +
> > +		page = pfn_to_page(blockpfn);
> > +		if (!PageBuddy(page))
> > +			continue;
> 
> The name PageBuddy is getting to be misleading. Maybe rename this to
> PageFree or so?
> 

That would be suprisingly ambiguous. per-cpu pages are free pages but are not
PageBuddy pages. In this case, I really mean a PageBuddy page, not a free page.

> > +
> > +		/* Found a free page, break it into order-0 pages */
> > +		isolated = split_free_page(page);
> > +		total_isolated += isolated;
> > +		for (i = 0; i < isolated; i++) {
> > +			list_add(&page->lru, freelist);
> > +			page++;
> > +		}
> 
> Why do you need to break them all up? Easier to coalesce later?
> 

They are broken up because migration currently works on order-0 pages.
It is easier to break them up now for compaction_alloc() to give out one
at a time than trying to figure out how to split them up later.

> > +/* Returns 1 if the page is within a block suitable for migration to */
> > +static int pageblock_migratable(struct page *page)
> > +{
> > +	/* If the page is a large free page, then allow migration */
> > +	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> > +		return 1;
> 
> if (PageSlab(page) && page->slab->ops->kick) {
> 	migratable slab
> }
> 
> if (page table page) {
> 	migratable page table page?
> }
> 
> etc?
> 

Not quite. pageblock_migratable() is telling if this block is suitable for
taking free pages from so movable pages can be migrated there.  Right now
that means checking if there are enough free pages that the whole block
becomes MOVABLE or if the block is already being used for movable pages.

The block could become movable if the decision was made to kick out slab
pages that are located towards the end of the zone. If page tables
become movable, then they would need to be identified here but that is
not the case.

The pageblock_migratable() function is named so that this decision can
be easily revisited in one place.

> > +		/* Try isolate the page */
> > +		if (locked_isolate_lru_page(zone, page, migratelist) == 0)
> > +			isolated++;
> 
> Support for other ways of migrating a page?
> 

When other mechanisms exist, they would be added here. Right now,
isolate_lru_page() is the only one I am aware of.

> > +static int compact_zone(struct zone *zone, struct compact_control *cc)
> > +{
> > +	int ret = COMPACT_INCOMPLETE;
> > +
> > +	/* Setup to move all movable pages to the end of the zone */
> > +	cc->migrate_pfn = zone->zone_start_pfn;
> > +	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> > +	cc->free_pfn &= ~(pageblock_nr_pages-1);
> > +
> > +	for (; ret == COMPACT_INCOMPLETE; ret = compact_finished(zone, cc)) {
> > +		isolate_migratepages(zone, cc);
> > +
> > +		if (!cc->nr_migratepages)
> > +			continue;
> > +
> > +		/* Isolate free pages if necessary */
> > +		if (cc->nr_freepages < cc->nr_migratepages)
> > +			isolate_freepages(zone, cc);
> > +
> > +		/* Stop compacting if we cannot get enough free pages */
> > +		if (cc->nr_freepages < cc->nr_migratepages)
> > +			break;
> > +
> > +		migrate_pages(&cc->migratepages, compaction_alloc,
> > +							(unsigned long)cc);
> 
> You do not need to check the result of migration? Page migration is a best 
> effort that may fail.
> 

You're right. I used to check it for debugging purposes to make sure migration
was actually occuring. It is not unusual still for a fair number of pages
to fail to migrate. migration already uses a retry logic and I shouldn't
be replicating it.

More importantly, by leaving the pages on the migratelist, I potentially
retry the same migrations over and over again wasting time and effort not
to mention that I keep pages isolated for much longer than necessary and
that could cause stalling problems. I should be calling putback_lru_pages()
when migrate_pages() tells me it failed to migrate pages.

I'll revisit this one. Thanks

> Looks good otherwise.
> 
> Acked-by: Christoph Lameter <clameter@sgi.com>

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
