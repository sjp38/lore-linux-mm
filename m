Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 9C3DE6B0264
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 10:29:50 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MAC005KNG9KLH30@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Sep 2012 23:29:49 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MAC00M85G9E5EA0@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 14 Sep 2012 23:29:49 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v4 1/4] mm: fix tracing in free_pcppages_bulk()
Date: Fri, 14 Sep 2012 16:29:31 +0200
Message-id: <1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com>
In-reply-to: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

page->private gets re-used in __free_one_page() to store page order
(so trace_mm_page_pcpu_drain() may print order instead of migratetype)
thus migratetype value must be cached locally.

Fixes regression introduced in a701623 ("mm: fix migratetype bug
which slowed swapping").

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/page_alloc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 93a3433..e9da55c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -668,12 +668,15 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free = to_free;
 
 		do {
+			int mt;
+
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
+			mt = page_private(page);
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
-			__free_one_page(page, zone, 0, page_private(page));
-			trace_mm_page_pcpu_drain(page, 0, page_private(page));
+			__free_one_page(page, zone, 0, mt);
+			trace_mm_page_pcpu_drain(page, 0, mt);
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
-- 
1.7.11.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
