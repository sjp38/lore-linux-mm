Date: Mon, 18 Jun 2007 10:18:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/7] Introduce a means of compacting memory within a zone
In-Reply-To: <20070618093002.7790.68471.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0706181010030.4751@schroedinger.engr.sgi.com>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
 <20070618093002.7790.68471.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007, Mel Gorman wrote:

> +	/* Isolate free pages. This assumes the block is valid */
> +	for (; blockpfn < end_pfn; blockpfn++) {
> +		struct page *page;
> +		int isolated, i;
> +
> +		if (!pfn_valid_within(blockpfn))
> +			continue;
> +
> +		page = pfn_to_page(blockpfn);
> +		if (!PageBuddy(page))
> +			continue;

The name PageBuddy is getting to be misleading. Maybe rename this to
PageFree or so?

> +
> +		/* Found a free page, break it into order-0 pages */
> +		isolated = split_free_page(page);
> +		total_isolated += isolated;
> +		for (i = 0; i < isolated; i++) {
> +			list_add(&page->lru, freelist);
> +			page++;
> +		}

Why do you need to break them all up? Easier to coalesce later?

> +/* Returns 1 if the page is within a block suitable for migration to */
> +static int pageblock_migratable(struct page *page)
> +{
> +	/* If the page is a large free page, then allow migration */
> +	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> +		return 1;

if (PageSlab(page) && page->slab->ops->kick) {
	migratable slab
}

if (page table page) {
	migratable page table page?
}

etc?

> +		/* Try isolate the page */
> +		if (locked_isolate_lru_page(zone, page, migratelist) == 0)
> +			isolated++;

Support for other ways of migrating a page?

> +static int compact_zone(struct zone *zone, struct compact_control *cc)
> +{
> +	int ret = COMPACT_INCOMPLETE;
> +
> +	/* Setup to move all movable pages to the end of the zone */
> +	cc->migrate_pfn = zone->zone_start_pfn;
> +	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> +	cc->free_pfn &= ~(pageblock_nr_pages-1);
> +
> +	for (; ret == COMPACT_INCOMPLETE; ret = compact_finished(zone, cc)) {
> +		isolate_migratepages(zone, cc);
> +
> +		if (!cc->nr_migratepages)
> +			continue;
> +
> +		/* Isolate free pages if necessary */
> +		if (cc->nr_freepages < cc->nr_migratepages)
> +			isolate_freepages(zone, cc);
> +
> +		/* Stop compacting if we cannot get enough free pages */
> +		if (cc->nr_freepages < cc->nr_migratepages)
> +			break;
> +
> +		migrate_pages(&cc->migratepages, compaction_alloc,
> +							(unsigned long)cc);

You do not need to check the result of migration? Page migration is a best 
effort that may fail.

Looks good otherwise.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
