Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAAE6B0035
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 11:40:42 -0400 (EDT)
Received: by mail-bk0-f54.google.com with SMTP id 6so195470bkj.13
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 08:40:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uk8si2625076bkb.37.2014.04.03.08.40.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 08:40:41 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/2] mm/page_alloc: prevent MIGRATE_RESERVE pages from being misplaced
Date: Thu,  3 Apr 2014 17:40:17 +0200
Message-Id: <1396539618-31362-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <533D8015.1000106@suse.cz>
References: <533D8015.1000106@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>

For the MIGRATE_RESERVE pages, it is important they do not get misplaced
on free_list of other migratetype, otherwise the whole MIGRATE_RESERVE
pageblock might be changed to other migratetype in try_to_steal_freepages().

Currently, it is however possible for this to happen when MIGRATE_RESERVE
page is allocated on pcplist through rmqueue_bulk() as a fallback for other
desired migratetype, and then later freed back through free_pcppages_bulk()
without being actually used. This happens because free_pcppages_bulk() uses
get_freepage_migratetype() to choose the free_list, and rmqueue_bulk() calls
set_freepage_migratetype() with the *desired* migratetype and not the page's
original MIGRATE_RESERVE migratetype.

This patch fixes the problem by moving the call to set_freepage_migratetype()
from rmqueue_bulk() down to __rmqueue_smallest() and __rmqueue_fallback() where
the actual page's migratetype (e.g. from which free_list the page is taken
from) is used. Note that this migratetype might be different from the
pageblock's migratetype due to freepage stealing decisions. This is OK, as page
stealing never uses MIGRATE_RESERVE as a fallback, and also takes care to leave
all MIGRATE_CMA pages on the correct freelist.

Therefore, as an additional benefit, the call to get_pageblock_migratetype()
from rmqueue_bulk() when CMA is enabled, can be removed completely. This relies
on the fact that MIGRATE_CMA pageblocks are created only during system init,
and the above. The related is_migrate_isolate() check is also unnecessary, as
memory isolation has other ways to move pages between freelists, and drain
pcp lists containing pages that should be isolated.
The buffered_rmqueue() can also benefit from calling get_freepage_migratetype()
instead of get_pageblock_migratetype().

A separate patch will add VM_BUG_ON checks for the invariant that for
MIGRATE_RESERVE and MIGRATE_CMA pageblocks, freepage_migratetype must equal to
pageblock_migratetype so that these pages always go to the correct free_list.

Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
Reported-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Suggested-by: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3bac76a..2dbaba1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -930,6 +930,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
+		set_freepage_migratetype(page, migratetype);
 		return page;
 	}
 
@@ -1056,7 +1057,9 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
 
 	/*
 	 * When borrowing from MIGRATE_CMA, we need to release the excess
-	 * buddy pages to CMA itself.
+	 * buddy pages to CMA itself. We also ensure the freepage_migratetype
+	 * is set to CMA so it is returned to the correct freelist in case
+	 * the page ends up being not actually allocated from the pcp lists.
 	 */
 	if (is_migrate_cma(fallback_type))
 		return fallback_type;
@@ -1124,6 +1127,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 
 			expand(zone, page, order, current_order, area,
 			       new_type);
+			/* The freepage_migratetype may differ from pageblock's
+			 * migratetype depending on the decisions in
+			 * try_to_steal_freepages. This is OK as long as it does
+			 * not differ for MIGRATE_CMA type.
+			 */
+			set_freepage_migratetype(page, new_type);
 
 			trace_mm_page_alloc_extfrag(page, order, current_order,
 				start_migratetype, migratetype, new_type);
@@ -1174,7 +1183,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			unsigned long count, struct list_head *list,
 			int migratetype, int cold)
 {
-	int mt = migratetype, i;
+	int i;
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
@@ -1195,14 +1204,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
-		if (IS_ENABLED(CONFIG_CMA)) {
-			mt = get_pageblock_migratetype(page);
-			if (!is_migrate_cma(mt) && !is_migrate_isolate(mt))
-				mt = migratetype;
-		}
-		set_freepage_migratetype(page, mt);
 		list = &page->lru;
-		if (is_migrate_cma(mt))
+		if (is_migrate_cma(get_freepage_migratetype(page)))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
 	}
@@ -1580,7 +1583,7 @@ again:
 		if (!page)
 			goto failed;
 		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_pageblock_migratetype(page));
+					  get_freepage_migratetype(page));
 	}
 
 	/*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
