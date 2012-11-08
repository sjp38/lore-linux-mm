Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id E5C816B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 01:59:34 -0500 (EST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MD50040HQ33HQO0@mailout1.samsung.com> for
 linux-mm@kvack.org; Thu, 08 Nov 2012 15:59:33 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MD500BFIQ30NSE1@mmp2.samsung.com> for linux-mm@kvack.org;
 Thu, 08 Nov 2012 15:59:33 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: skip watermarks check for already isolated blocks in
 split_free_page()
Date: Thu, 08 Nov 2012 07:59:04 +0100
Message-id: <1352357944-14830-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Since commit 2139cbe627b8 ("cma: fix counting of isolated pages") free
pages in isolated pageblocks are not accounted to NR_FREE_PAGES counters,
so watermarks check is not required if one operates on a free page in
isolated pageblock.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/page_alloc.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fd154fe..43ab09f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1394,10 +1394,12 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 	zone = page_zone(page);
 	order = page_order(page);
 
-	/* Obey watermarks as if the page was being allocated */
-	watermark = low_wmark_pages(zone) + (1 << order);
-	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
-		return 0;
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE) {
+		/* Obey watermarks as if the page was being allocated */
+		watermark = low_wmark_pages(zone) + (1 << order);
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+			return 0;
+	}
 
 	/* Remove page from free list */
 	list_del(&page->lru);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
