Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0444C6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 23:37:26 -0500 (EST)
Received: by qyk14 with SMTP id 14so9443617qyk.11
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 20:37:25 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH 1/4] mm/page_alloc : rename rmqueue_bulk to rmqueue_single
Date: Mon, 11 Jan 2010 12:37:11 +0800
Message-Id: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

There is only one place calls rmqueue_bulk to allocate the single
pages. So rename it to rmqueue_single, and remove an argument
order.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/page_alloc.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e9f5cc..23df1ed 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -930,25 +930,24 @@ retry_reserve:
 }
 
 /* 
- * Obtain a specified number of elements from the buddy allocator, all under
+ * Obtain a specified number of single page from the buddy allocator, all under
  * a single hold of the lock, for efficiency.  Add them to the supplied list.
  * Returns the number of new pages which were placed at *list.
  */
-static int rmqueue_bulk(struct zone *zone, unsigned int order, 
-			unsigned long count, struct list_head *list,
-			int migratetype, int cold)
+static int rmqueue_single(struct zone *zone, unsigned long count,
+		       struct list_head *list, int migratetype, int cold)
 {
 	int i;
 	
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		struct page *page = __rmqueue(zone, 0, migratetype);
 		if (unlikely(page == NULL))
 			break;
 
 		/*
 		 * Split buddy pages returned by expand() are received here
-		 * in physical page order. The page is added to the callers and
+		 * in order zero. The page is added to the callers and
 		 * list and the list head then moves forward. From the callers
 		 * perspective, the linked list is ordered by page number in
 		 * some conditions. This is useful for IO devices that can
@@ -962,7 +961,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		set_page_private(page, migratetype);
 		list = &page->lru;
 	}
-	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
 	spin_unlock(&zone->lock);
 	return i;
 }
@@ -1192,9 +1191,8 @@ again:
 		list = &pcp->lists[migratetype];
 		local_irq_save(flags);
 		if (list_empty(list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
-					pcp->batch, list,
-					migratetype, cold);
+			pcp->count += rmqueue_single(zone, pcp->batch, list,
+							migratetype, cold);
 			if (unlikely(list_empty(list)))
 				goto failed;
 		}
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
