Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 725026B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 12:35:31 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id uo5so2911966pbc.32
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 09:35:31 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id io5si5586213pbc.234.2014.03.06.09.35.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 06 Mar 2014 09:35:30 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N20004E7ZJ1ZFB0@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 07 Mar 2014 02:35:25 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v3] mm/page_alloc: fix freeing of MIGRATE_RESERVE migratetype
 pages
Date: Thu, 06 Mar 2014 18:35:12 +0100
Message-id: <3269714.29dGMiCR2L@amdc1032>
MIME-version: 1.0
Content-transfer-encoding: 7Bit
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Pages allocated from MIGRATE_RESERVE migratetype pageblocks
are not freed back to MIGRATE_RESERVE migratetype free
lists in free_pcppages_bulk()->__free_one_page() if we got
to free_pcppages_bulk() through drain_[zone_]pages().
The freeing through free_hot_cold_page() is okay because
freepage migratetype is set to pageblock migratetype before
calling free_pcppages_bulk().  If pages of MIGRATE_RESERVE
migratetype end up on the free lists of other migratetype
whole Reserved pageblock may be later changed to the other
migratetype in __rmqueue_fallback() and it will be never
changed back to be a Reserved pageblock.  Fix the issue by
moving freepage migratetype setting from rmqueue_bulk() to
__rmqueue[_fallback]() and preserving freepage migratetype
as an original pageblock migratetype for MIGRATE_RESERVE
migratetype pages.

The problem was introduced in v2.6.31 by commit ed0ae21
("page allocator: do not call get_pageblock_migratetype()
more than necessary").

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
---
v2:
- updated patch description, there is no __zone_pcp_update()
  in newer kernels
v3:
- set freepage migratetype in __rmqueue[_fallback]()
  instead of rmqueue_bulk() (per Mel's request)

 mm/page_alloc.c |   27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2014-03-06 18:10:21.884422983 +0100
+++ b/mm/page_alloc.c	2014-03-06 18:10:27.016422895 +0100
@@ -1094,7 +1094,7 @@ __rmqueue_fallback(struct zone *zone, in
 	struct free_area *area;
 	int current_order;
 	struct page *page;
-	int migratetype, new_type, i;
+	int migratetype, new_type, mt = start_migratetype, i;
 
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
@@ -1125,6 +1125,14 @@ __rmqueue_fallback(struct zone *zone, in
 			expand(zone, page, order, current_order, area,
 			       new_type);
 
+			if (IS_ENABLED(CONFIG_CMA)) {
+				mt = get_pageblock_migratetype(page);
+				if (!is_migrate_cma(mt) &&
+				    !is_migrate_isolate(mt))
+					mt = start_migratetype;
+			}
+			set_freepage_migratetype(page, mt);
+
 			trace_mm_page_alloc_extfrag(page, order, current_order,
 				start_migratetype, migratetype, new_type);
 
@@ -1147,7 +1155,9 @@ static struct page *__rmqueue(struct zon
 retry_reserve:
 	page = __rmqueue_smallest(zone, order, migratetype);
 
-	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
+	if (likely(page)) {
+		set_freepage_migratetype(page, migratetype);
+	} else if (migratetype != MIGRATE_RESERVE) {
 		page = __rmqueue_fallback(zone, order, migratetype);
 
 		/*
@@ -1174,7 +1184,7 @@ static int rmqueue_bulk(struct zone *zon
 			unsigned long count, struct list_head *list,
 			int migratetype, int cold)
 {
-	int mt = migratetype, i;
+	int i;
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
@@ -1195,16 +1205,15 @@ static int rmqueue_bulk(struct zone *zon
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
+		list = &page->lru;
 		if (IS_ENABLED(CONFIG_CMA)) {
-			mt = get_pageblock_migratetype(page);
+			int mt = get_pageblock_migratetype(page);
 			if (!is_migrate_cma(mt) && !is_migrate_isolate(mt))
 				mt = migratetype;
+			if (is_migrate_cma(mt))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+						      -(1 << order));
 		}
-		set_freepage_migratetype(page, mt);
-		list = &page->lru;
-		if (is_migrate_cma(mt))
-			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
-					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
