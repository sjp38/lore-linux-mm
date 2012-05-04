Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 0F2F86B00ED
	for <linux-mm@kvack.org>; Fri,  4 May 2012 11:19:07 -0400 (EDT)
Date: Fri, 4 May 2012 16:19:01 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v6] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
Message-ID: <20120504151901.GN11435@suse.de>
References: <201205041603.25237.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201205041603.25237.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Fri, May 04, 2012 at 04:03:25PM +0200, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH v6] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks
> 
> When MIGRATE_UNMOVABLE pages are freed from MIGRATE_UNMOVABLE
> type pageblock (and some MIGRATE_MOVABLE pages are left in it)
> waiting until an allocation takes ownership of the block may
> take too long.  The type of the pageblock remains unchanged
> so the pageblock cannot be used as a migration target during
> compaction.
> 
> Fix it by:
> 
> * Adding enum compact_mode (COMPACT_ASYNC_[MOVABLE,UNMOVABLE],
>   and COMPACT_SYNC) and then converting sync field in struct
>   compact_control to use it.
> 
> * Adding nr_pageblocks_scanned and nr_pageblocks_skipped fields
>   to struct compact_control and tracking how many destination
>   pageblocks were scanned during compaction and how many of them
>   were of MIGRATE_UNMOVABLE type.  If COMPACT_ASYNC_MOVABLE mode
>   compaction ran fully in try_to_compact_pages() (COMPACT_COMPLETE)
>   it implies that there is not a suitable page for allocation.
>   In this case then check how if there were enough MIGRATE_UNMOVABLE
>   pageblocks to try a second pass in COMPACT_ASYNC_UNMOVABLE mode.
> 
> * Scanning the MIGRATE_UNMOVABLE pageblocks (during COMPACT_SYNC
>   and COMPACT_ASYNC_UNMOVABLE compaction modes) and building
>   a count based on finding PageBuddy pages, page_count(page) == 0
>   or PageLRU pages.  If all pages within the MIGRATE_UNMOVABLE
>   pageblock are in one of those three sets change the whole
>   pageblock type to MIGRATE_MOVABLE.
> 
> 
> My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> - allocate 120000 pages for kernel's usage
> - free every second page (60000 pages) of memory just allocated
> - allocate and use 60000 pages from user space
> - free remaining 60000 pages of kernel memory
> (now we have fragmented memory occupied mostly by user space pages)
> - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> 
> The results:
> - with compaction disabled I get 11 successful allocations
> - with compaction enabled - 14 successful allocations
> - with this patch I'm able to get all 100 successful allocations
> 
> 
> NOTE: If we can make kswapd aware of order-0 request during
> compaction, we can enhance kswapd with changing mode to
> COMPACT_ASYNC_FULL (COMPACT_ASYNC_MOVABLE + COMPACT_ASYNC_UNMOVABLE).
> Please see the following thread:
> 
> 	http://marc.info/?l=linux-mm&m=133552069417068&w=2
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
>
> <SNIP>
>
> @@ -750,6 +816,8 @@
>  	struct zoneref *z;
>  	struct zone *zone;
>  	int rc = COMPACT_SKIPPED;
> +	unsigned long nr_pageblocks_scanned = 0, nr_pageblocks_skipped = 0;
> +	enum compact_mode mode = sync ? COMPACT_SYNC : COMPACT_ASYNC_MOVABLE;
>  
>  	/*
>  	 * Check whether it is worth even starting compaction. The order check is
> @@ -765,13 +833,22 @@
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
>  								nodemask) {
>  		int status;
> -
> -		status = compact_zone_order(zone, order, gfp_mask, sync);
> +retry:
> +		status = compact_zone_order(zone, order, gfp_mask, mode,
> +				&nr_pageblocks_scanned, &nr_pageblocks_skipped);
>  		rc = max(status, rc);
>  
>  		/* If a normal allocation would succeed, stop compacting */
>  		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
>  			break;
> +
> +		if (rc == COMPACT_COMPLETE && mode == COMPACT_ASYNC_MOVABLE) {
> +			if (nr_pageblocks_scanned && nr_pageblocks_skipped) {
> +				mode = COMPACT_ASYNC_UNMOVABLE;
> +				goto retry;
> +			}
> +		} else
> +			mode = sync ? COMPACT_SYNC : COMPACT_ASYNC_MOVABLE;

Minor nit but if you moved this line above the retry: then the else
block would be necessary. It would not be necessary to initialise mode
at the start of the function either.

Otherwise I didn't spot anything.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
