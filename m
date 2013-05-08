Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 569946B014F
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:24 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 19/22] mm: page allocator: Watch for magazine and zone lock contention
Date: Wed,  8 May 2013 17:03:04 +0100
Message-Id: <1368028987-8369-20-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When refilling or draining magazines it is possible that the locks are
contended. This patch will refill/drain a minimum number of pages and
attempt to refill/drain a maximum number. Between the min and max
ranges it will check contention and release the lock if it is contended.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 38 ++++++++++++++++++++++++++++++--------
 1 file changed, 30 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63952f6..727c8d3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1071,8 +1071,10 @@ void mark_free_pages(struct zone *zone)
 #endif /* CONFIG_PM */
 
 #define MAGAZINE_LIMIT (1024)
-#define MAGAZINE_ALLOC_BATCH (384)
-#define MAGAZINE_FREE_BATCH (64)
+#define MAGAZINE_MIN_ALLOC_BATCH (16)
+#define MAGAZINE_MIN_FREE_BATCH (16)
+#define MAGAZINE_MAX_ALLOC_BATCH (384)
+#define MAGAZINE_MAX_FREE_BATCH (64)
 
 static inline struct free_magazine *lock_magazine(struct zone *zone)
 {
@@ -1138,6 +1140,11 @@ static inline void unlock_magazine(struct free_magazine *mag)
 	spin_unlock(&mag->lock);
 }
 
+static inline bool magazine_contended(struct free_magazine *mag)
+{
+	return spin_is_contended(&mag->lock);
+}
+
 static
 struct page *__rmqueue_magazine(struct free_magazine *mag,
 				int migratetype)
@@ -1163,8 +1170,8 @@ static void magazine_drain(struct zone *zone, struct free_magazine *mag,
 	struct list_head *list;
 	struct page *page;
 	unsigned int batch_free = 0;
-	unsigned int to_free = MAGAZINE_FREE_BATCH;
-	unsigned int nr_freed_cma = 0;
+	unsigned int to_free = MAGAZINE_MAX_FREE_BATCH;
+	unsigned int nr_freed_cma = 0, nr_freed = 0;
 	unsigned long flags;
 	struct free_area_magazine *area = &mag->area;
 	LIST_HEAD(free_list);
@@ -1190,9 +1197,13 @@ static void magazine_drain(struct zone *zone, struct free_magazine *mag,
 			list = &area->free_list[migratetype];;
 		} while (list_empty(list));
 
-		/* This is the only non-empty list. Free them all. */
+		/*
+		 * This is the only non-empty list. Free up the the min-free
+		 * batch so that the spinlock contention is still checked
+		 */
 		if (batch_free == MIGRATE_PCPTYPES)
-			batch_free = to_free;
+			batch_free = min_t(unsigned int,
+					   MAGAZINE_MIN_FREE_BATCH, to_free);
 
 		do {
 			page = list_entry(list->prev, struct page, lru);
@@ -1201,7 +1212,13 @@ static void magazine_drain(struct zone *zone, struct free_magazine *mag,
 			list_move(&page->lru, &free_list);
 			if (is_migrate_isolate_page(zone, page))
 				nr_freed_cma++;
+			nr_freed++;
 		} while (--to_free && --batch_free && !list_empty(list));
+
+		/* Watch for parallel contention */
+		if (nr_freed > MAGAZINE_MIN_FREE_BATCH &&
+		    magazine_contended(mag))
+			break;
 	}
 
 	/* Free the list of pages to the buddy allocator */
@@ -1213,7 +1230,7 @@ static void magazine_drain(struct zone *zone, struct free_magazine *mag,
 		__free_one_page(page, zone, 0, get_freepage_migratetype(page));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES,
-				MAGAZINE_FREE_BATCH - nr_freed_cma);
+				nr_freed - nr_freed_cma);
 	if (nr_freed_cma)
 		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_freed_cma);
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -1388,12 +1405,17 @@ retry:
 		unsigned int nr_alloced = 0;
 
 		spin_lock_irqsave(&zone->lock, flags);
-		for (i = 0; i < MAGAZINE_ALLOC_BATCH; i++) {
+		for (i = 0; i < MAGAZINE_MAX_ALLOC_BATCH; i++) {
 			page = __rmqueue(zone, 0, migratetype);
 			if (!page)
 				break;
 			list_add(&page->lru, &alloc_list);
 			nr_alloced++;
+
+			/* Watch for parallel contention */
+			if (nr_alloced > MAGAZINE_MIN_ALLOC_BATCH &&
+			    spin_is_contended(&zone->lock))
+				break;
 		}
 		if (!is_migrate_cma(mt))
 			__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_alloced);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
