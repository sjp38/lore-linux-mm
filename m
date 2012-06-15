Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 225AC6B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 03:32:43 -0400 (EDT)
Message-ID: <4FDAE521.7020104@kernel.org>
Date: Fri, 15 Jun 2012 16:32:49 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v11 1/2] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
References: <201206141800.31038.b.zolnierkie@samsung.com>
In-Reply-To: <201206141800.31038.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Dave Jones <davej@redhat.com>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On 06/15/2012 01:00 AM, Bartlomiej Zolnierkiewicz wrote:

> 
> Hi,
> 
> Most important changes from v10:
> 
> * port patch over
>   https://lkml.org/lkml/2012/6/13/568
>   https://lkml.org/lkml/2012/6/13/570
>   patches from Minchan Kim
> 
> * split new /proc/vmstat entry addition to separate patch (#2/2)
> 
> Best regards,
> --
> Bartlomiej Zolnierkiewicz
> Samsung Poland R&D Center
> 
> 
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH v11] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks
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
> * Adding nr_pageblocks_skipped field to struct compact_control
>   and tracking how many destination pageblocks were of
>   MIGRATE_UNMOVABLE type.  If COMPACT_ASYNC_MOVABLE mode compaction
>   ran fully in try_to_compact_pages() (COMPACT_COMPLETE) it implies
>   that there is not a suitable page for allocation.  In this case
>   then check how if there were enough MIGRATE_UNMOVABLE pageblocks
>   to try a second pass in COMPACT_ASYNC_UNMOVABLE mode.
> 
> * Scanning the MIGRATE_UNMOVABLE pageblocks (during COMPACT_SYNC
>   and COMPACT_ASYNC_UNMOVABLE compaction modes) and building
>   a count based on finding PageBuddy pages, page_count(page) == 0
>   or PageLRU pages.  If all pages within the MIGRATE_UNMOVABLE
>   pageblock are in one of those three sets change the whole
>   pageblock type to MIGRATE_MOVABLE.
> 
> My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> - allocate 95000 pages for kernel's usage
> - free every second page (47500 pages) of memory just allocated
> - allocate and use 60000 pages from user space
> - free remaining 60000 pages of kernel memory
> (now we have fragmented memory occupied mostly by user space pages)
> - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> 
> The results:
> - with compaction disabled I get 10 successful allocations
> - with compaction enabled - 11 successful allocations
> - with this patch I'm able to get 25 successful allocations
> 
> NOTE: If we can make kswapd aware of order-0 request during
> compaction, we can enhance kswapd with changing mode to
> COMPACT_ASYNC_FULL (COMPACT_ASYNC_MOVABLE + COMPACT_ASYNC_UNMOVABLE).
> Please see the following thread:
> 
> 	http://marc.info/?l=linux-mm&m=133552069417068&w=2
> 
> [minchan@kernel.org: minor cleanups]
> Cc: Hugh Dickins <hughd@google.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: Cong Wang <amwang@redhat.com>
> Cc: Markus Trippelsdorf <markus@trippelsdorf.de>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Reviewed-by: Minchan Kim <minchan@kernel.org>

Thanks, Bartlomiej!
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
