Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C771E6B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 05:02:44 -0400 (EDT)
Date: Mon, 30 Apr 2012 10:02:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4] mm: compaction: handle incorrect Unmovable type
 pageblocks
Message-ID: <20120430090239.GL9226@suse.de>
References: <201204271257.11501.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201204271257.11501.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Fri, Apr 27, 2012 at 12:57:11PM +0200, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH v4] mm: compaction: handle incorrect Unmovable type pageblocks
> 
> When Unmovable pages are freed from Unmovable type pageblock
> (and some Movable type pages are left in it) waiting until
> an allocation takes ownership of the block may take too long.
> The type of the pageblock remains unchanged so the pageblock
> cannot be used as a migration target during compaction.
> 
> Fix it by:
> 
> * Adding enum compact_mode (COMPACT_ASYNC_MOVABLE,
>   COMPACT_ASYNC_UNMOVABLE and COMPACT_SYNC) and then converting
>   sync field in struct compact_control to use it.
> 
> * Scanning the Unmovable pageblocks (during COMPACT_ASYNC_UNMOVABLE
>   and COMPACT_SYNC compactions) and building a count based on
>   finding PageBuddy pages, page_count(page) == 0 or PageLRU pages.
>   If all pages within the Unmovable pageblock are in one of those
>   three sets change the whole pageblock type to Movable.
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

This is looking much better to me. However, I would really like to see
COMPACT_ASYNC_UNMOVABLE being used by the page allocator instead of depending
on kswapd to do the work. Right now as it uses COMPACT_ASYNC_MOVABLE only,
I think it uses COMPACT_SYNC too easily (making latency worse).

Specifically

1. Leave try_to_compact_pages() taking a sync parameter. It is up to
   compaction how to treat sync==false
2. When sync==false, start with ASYNC_MOVABLE. Track how many pageblocks
   were scanned during compaction and how many of them were
   MIGRATE_UNMOVABLE. If compaction ran fully (COMPACT_COMPLETE) it implies
   that there is not a suitable page for allocation. In this case then
   check how if there were enough MIGRATE_UNMOVABLE pageblocks to try a
   second pass in ASYNC_FULL. By keeping all the logic in compaction.c
   it prevents too much knowledge of compaction sneaking into
   page_alloc.c
3. When scanning ASYNC_FULL, *only* scan the MIGRATE_UNMOVABLE blocks as
   migration targets because the first pass would have scanned within
   MIGRATE_MOVABLE. This will reduce the cost of the second pass.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
