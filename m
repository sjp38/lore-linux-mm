Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8947C90012A
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 07:45:42 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/8] mm: MIGRATE_CMA migration type added
Date: Tue, 5 Jul 2011 13:44:31 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <1309851710-3828-5-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1309851710-3828-5-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201107051344.31298.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Tuesday 05 July 2011, Marek Szyprowski wrote:
> From: Michal Nazarewicz <m.nazarewicz@samsung.com>
> 
> The MIGRATE_CMA migration type has two main characteristics:
> (i) only movable pages can be allocated from MIGRATE_CMA
> pageblocks and (ii) page allocator will never change migration
> type of MIGRATE_CMA pageblocks.
> 
> This guarantees that page in a MIGRATE_CMA page block can
> always be migrated somewhere else (unless there's no memory left
> in the system).
> 
> It is designed to be used with Contiguous Memory Allocator
> (CMA) for allocating big chunks (eg. 10MiB) of physically
> contiguous memory. Once driver requests contiguous memory,
> CMA will migrate pages from MIGRATE_CMA pageblocks.
> 
> To minimise number of migrations, MIGRATE_CMA migration type
> is the last type tried when page allocator falls back to other
> migration types then requested.
> 
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> [m.szyprowski: cleaned up Kconfig, renamed some functions]
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>, but I noticed a few things:

> cma migrate fixup

This text doesn't belong here.

> +enum {
> +	MIGRATE_UNMOVABLE,
> +	MIGRATE_RECLAIMABLE,
> +	MIGRATE_MOVABLE,
> +	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
> +	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
> +#ifdef CONFIG_CMA_MIGRATE_TYPE
> +	/*
> +	 * MIGRATE_CMA migration type is designed to mimic the way
> +	 * ZONE_MOVABLE works.  Only movable pages can be allocated
> +	 * from MIGRATE_CMA pageblocks and page allocator never
> +	 * implicitly change migration type of MIGRATE_CMA pageblock.
> +	 *
> +	 * The way to use it is to change migratetype of a range of
> +	 * pageblocks to MIGRATE_CMA which can be done by
> +	 * __free_pageblock_cma() function.  What is important though
> +	 * is that a range of pageblocks must be aligned to
> +	 * MAX_ORDER_NR_PAGES should biggest page be bigger then
> +	 * a single pageblock.
> +	 */
> +	MIGRATE_CMA,
> +#endif
> +	MIGRATE_ISOLATE,	/* can't allocate from here */
> +	MIGRATE_TYPES
> +};

It's not clear to me why you need this #ifdef. Does it hurt if the
migration type is defined but not used?

> @@ -198,6 +198,12 @@ config MIGRATION
>  	  pages as migration can relocate pages to satisfy a huge page
>  	  allocation instead of reclaiming.
>  
> +config CMA_MIGRATE_TYPE
> +	bool
> +	help
> +	  This enables the use the MIGRATE_CMA migrate type, which lets lets CMA
> +	  work on almost arbitrary memory range and not only inside ZONE_MOVABLE.
> +
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT

This is currently only selected on ARM with your patch set. 

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 6cc604b..9e5cc59 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -119,6 +119,16 @@ static bool suitable_migration_target(struct page *page)
>  	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
>  		return false;
>  
> +	/* Keep MIGRATE_CMA alone as well. */
> +	/*
> +	 * XXX Revisit.  We currently cannot let compaction touch CMA
> +	 * pages since compaction insists on changing their migration
> +	 * type to MIGRATE_MOVABLE (see split_free_page() called from
> +	 * isolate_freepages_block() above).
> +	 */
> +	if (is_migrate_cma(migratetype))
> +		return false;
> +
>  	/* If the page is a large free page, then allow migration */
>  	if (PageBuddy(page) && page_order(page) >= pageblock_order)
>  		return true;

Do you plan to fix address this before merging the patch set, or is
it harmless enough to get in this way?

>  /*
>   * The order of subdivision here is critical for the IO subsystem.
> @@ -827,11 +852,15 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>   * This array describes the order lists are fallen back to when
>   * the free lists for the desirable migrate type are depleted
>   */
> -static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
> +static int fallbacks[MIGRATE_TYPES][4] = {
>  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
>  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
> +#ifdef CONFIG_CMA_MIGRATE_TYPE
> +	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_CMA    , MIGRATE_RESERVE },
> +#else
>  	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
> -	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
> +#endif
> +	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
>  };
>  
>  /*
> @@ -1044,7 +1086,12 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			list_add(&page->lru, list);
>  		else
>  			list_add_tail(&page->lru, list);
> -		set_page_private(page, migratetype);
> +#ifdef CONFIG_CMA_MIGRATE_TYPE
> +		if (is_pageblock_cma(page))
> +			set_page_private(page, MIGRATE_CMA);
> +		else
> +#endif
> +			set_page_private(page, migratetype);
>  		list = &page->lru;
>  	}

I guess if you can get rid of the first #ifdef I mentioned above, these two can be
removed as well, without causing any run-time overhead.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
