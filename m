Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id D5D236B005D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 09:43:10 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDQ00074OVTFU40@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 19 Nov 2012 23:43:09 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MDQ009RJOVLMY70@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 19 Nov 2012 23:43:09 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: cma: skip watermarks check for already isolated blocks in
 split_free_page() fix
Date: Mon, 19 Nov 2012 15:42:49 +0100
Message-id: <1353336169-23868-1-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <50A7D524.2060809@gmail.com>
References: <50A7D524.2060809@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Francesco Lavra <francescolavra.fl@gmail.com>

Cleanup and simplify the code which uses page migrate type.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/page_alloc.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6b990cb..f05365f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1393,12 +1393,15 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 
 	zone = page_zone(page);
 	order = page_order(page);
+	mt = get_pageblock_migratetype(page);
 
-	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE) {
+	if (mt != MIGRATE_ISOLATE) {
 		/* Obey watermarks as if the page was being allocated */
 		watermark = low_wmark_pages(zone) + (1 << order);
 		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 			return 0;
+
+		__mod_zone_freepage_state(zone, -(1UL << order), mt);
 	}
 
 	/* Remove page from free list */
@@ -1406,10 +1409,6 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
-	mt = get_pageblock_migratetype(page);
-	if (unlikely(mt != MIGRATE_ISOLATE))
-		__mod_zone_freepage_state(zone, -(1UL << order), mt);
-
 	if (alloc_order != order)
 		expand(zone, page, alloc_order, order,
 			&zone->free_area[order], migratetype);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
