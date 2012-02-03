Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9BB666B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 08:53:24 -0500 (EST)
Date: Fri, 3 Feb 2012 13:53:20 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/15] mm: mmzone: MIGRATE_CMA migration type added
Message-ID: <20120203135320.GF5796@csn.ul.ie>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-9-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1328271538-14502-9-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

On Fri, Feb 03, 2012 at 01:18:51PM +0100, Marek Szyprowski wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
> 
> The MIGRATE_CMA migration type has two main characteristics:
> (i) only movable pages can be allocated from MIGRATE_CMA
> pageblocks and (ii) page allocator will never change migration
> type of MIGRATE_CMA pageblocks.
> 
> This guarantees (to some degree) that page in a MIGRATE_CMA page
> block can always be migrated somewhere else (unless there's no
> memory left in the system).
> 
> It is designed to be used for allocating big chunks (eg. 10MiB)
> of physically contiguous memory.  Once driver requests
> contiguous memory, pages from MIGRATE_CMA pageblocks may be
> migrated away to create a contiguous block.
> 
> To minimise number of migrations, MIGRATE_CMA migration type
> is the last type tried when page allocator falls back to other
> migration types then requested.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> Tested-by: Rob Clark <rob.clark@linaro.org>
> Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
> Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>

Minor comments that can be handled as a follow-up but otherwise

Acked-by: Mel Gorman <mel@csn.ul.ie>

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 238fcec..993c375 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -750,6 +750,26 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
>  	__free_pages(page, order);
>  }
>  
> +#ifdef CONFIG_CMA
> +/*
> + * Free whole pageblock and set it's migration type to MIGRATE_CMA.
> + */
> +void __init init_cma_reserved_pageblock(struct page *page)
> +{
> +	unsigned i = pageblock_nr_pages;
> +	struct page *p = page;
> +
> +	do {
> +		__ClearPageReserved(p);
> +		set_page_count(p, 0);
> +	} while (++p, --i);
> +
> +	set_page_refcounted(page);
> +	set_pageblock_migratetype(page, MIGRATE_CMA);
> +	__free_pages(page, pageblock_order);
> +	totalram_pages += pageblock_nr_pages;
> +}
> +#endif
>  

This chunk is not used with the patch. Usually a hunk like this would
be part of the patch that used it.  Functionally it looks ok but
I see that the function that calls it is *not* __init. That should
trigger a section warning. Do a make CONFIG_DEBUG_SECTION_MISMATCH=y
and clean it up if necessary.

>  /*
>   * The order of subdivision here is critical for the IO subsystem.
> @@ -875,10 +895,15 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>   * This array describes the order lists are fallen back to when
>   * the free lists for the desirable migrate type are depleted
>   */
> -static int fallbacks[MIGRATE_TYPES][3] = {
> -	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
> -	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
> -	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
> +static int fallbacks[MIGRATE_TYPES][4] = {
> +	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
> +	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
> +#ifdef CONFIG_CMA
> +	[MIGRATE_MOVABLE]     = { MIGRATE_CMA,         MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
> +	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
> +#else
> +	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
> +#endif
>  	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
>  	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
>  };
> @@ -995,11 +1020,18 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  			 * pages to the preferred allocation list. If falling
>  			 * back for a reclaimable kernel allocation, be more
>  			 * aggressive about taking ownership of free pages
> +			 *
> +			 * On the other hand, never change migration
> +			 * type of MIGRATE_CMA pageblocks nor move CMA
> +			 * pages on different free lists. We don't
> +			 * want unmovable pages to be allocated from
> +			 * MIGRATE_CMA areas.
>  			 */
> -			if (unlikely(current_order >= (pageblock_order >> 1)) ||
> -					start_migratetype == MIGRATE_RECLAIMABLE ||
> -					page_group_by_mobility_disabled) {
> -				unsigned long pages;
> +			if (!is_migrate_cma(migratetype) &&
> +			    (unlikely(current_order >= pageblock_order / 2) ||
> +			     start_migratetype == MIGRATE_RECLAIMABLE ||
> +			     page_group_by_mobility_disabled)) {
> +				int pages;
>  				pages = move_freepages_block(zone, page,
>  								start_migratetype);
>  
> @@ -1017,11 +1049,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  			rmv_page_order(page);
>  
>  			/* Take ownership for orders >= pageblock_order */
> -			if (current_order >= pageblock_order)
> +			if (current_order >= pageblock_order &&
> +			    !is_migrate_cma(migratetype))
>  				change_pageblock_range(page, current_order,
>  							start_migratetype);
>  
> -			expand(zone, page, order, current_order, area, migratetype);
> +			expand(zone, page, order, current_order, area,
> +			       is_migrate_cma(migratetype)
> +			     ? migratetype : start_migratetype);
>  
>  			trace_mm_page_alloc_extfrag(page, order, current_order,
>  				start_migratetype, migratetype);
> @@ -1072,7 +1107,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			unsigned long count, struct list_head *list,
>  			int migratetype, int cold)
>  {
> -	int i;
> +	int mt = migratetype, i;
>  
>  	spin_lock(&zone->lock);
>  	for (i = 0; i < count; ++i) {
> @@ -1093,7 +1128,12 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			list_add(&page->lru, list);
>  		else
>  			list_add_tail(&page->lru, list);
> -		set_page_private(page, migratetype);
> +#ifdef CONFIG_CMA
> +		mt = get_pageblock_migratetype(page);
> +		if (!is_migrate_cma(mt) && mt != MIGRATE_ISOLATE)
> +			mt = migratetype;
> +#endif
> +		set_page_private(page, mt);

Ok, so while I'm not happy with the CONFIG_CMA bit here, so be it for
now. There are a few things I would like to see with it though in the
future

1. Add a comment explaning why it is necessary only for CONFIG_CMA.
   Put all the ugliness in the changelog if you like, it's already
   been written up in a mail so you can cut and paste the changelog

2. If there exists a second hunk that has this sort of ugliness,
   consider doing something like

#ifdef CONFIG_CMA
#define CMA_BUILD 1
#else
#define CMA_BUILD 0
#endif

if (CONFIG_CMA) {
	int mt = get_pageblock_migratetype(page);
	if (!is_migrate_cma(mt) && mt != MIGRATE_ISOLATE)
		mt = migratetype;
}

That can be slightly tidier and easier to follow while still getting
optimised out for !CONFIG_CMA

3. Consider trying to get rid of the CONFIG_CMA part entirely. Do this
   by having a readmostly static variable that is *only* set
   while MIGRATE_ISOLATE pageblocks exist. If they exist, then
   unconditionally do this paranoid check documenting that both memory
   hotplug and CMA benefit from it. The advantage is that you get
   the careful checking that you want but incur the cost in the page
   allocator *only* when you are actively trying to allocate with CMA.

e.g.

static int nr_migrate_isolate __read_mostly;

int set_migratetype_isolate(struct page *page)
{
	....
	nr_migrate_isolate++;
	....
}

void unset_migratetype_isolate(struct page *page)
{
	...
	nr_migrate_isolate--;
	...
}

Be careful to get the accounting of nr_migrate_isolate right during
memory hot-remove if unset_migratetype_isolate is not called because
the memory is offlined.In rmqueue_bulk() then do

	/*
	 * During memory hot-remove and during CMA allocation, be
	 * careful that pages that were added to the per-cpu
	 * lists before the pageblock was marked MIGRATE_ISOLATE and
	 * not moved properly are accounted for properly
	 */
	if (nr_migrate_isolate) {
		int mt = get_pageblock_migratetype(page);
		if (!is_migrate_cma(mt) && mt != MIGRATE_ISOLATE)
			mt = migratetype;
	}

Make sense?
		
-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
