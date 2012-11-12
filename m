Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id D41EA6B004D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 04:00:19 -0500 (EST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDD005K3A9NORT0@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Nov 2012 18:00:18 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MDD000SMABXAW00@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 12 Nov 2012 18:00:18 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: cma: allocate pages from CMA if NR_FREE_PAGES approaches
 low water mark
Date: Mon, 12 Nov 2012 09:59:42 +0100
Message-id: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

It has been observed that system tends to keep a lot of CMA free pages
even in very high memory pressure use cases. The CMA fallback for movable
pages is used very rarely, only when system is completely pruned from
MOVABLE pages, what usually means that the out-of-memory even will be
triggered very soon. To avoid such situation and make better use of CMA
pages, a heuristics is introduced which turns on CMA fallback for movable
pages when the real number of free pages (excluding CMA free pages)
approaches low water mark.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 mm/page_alloc.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fcb9719..90b51f3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1076,6 +1076,15 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 {
 	struct page *page;
 
+#ifdef CONFIG_CMA
+	unsigned long nr_free = zone_page_state(zone, NR_FREE_PAGES);
+	unsigned long nr_cma_free = zone_page_state(zone, NR_FREE_CMA_PAGES);
+
+	if (migratetype == MIGRATE_MOVABLE && nr_cma_free &&
+	    nr_free - nr_cma_free < 2 * low_wmark_pages(zone))
+		migratetype = MIGRATE_CMA;
+#endif /* CONFIG_CMA */
+
 retry_reserve:
 	page = __rmqueue_smallest(zone, order, migratetype);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
