Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 0C1476B0151
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:24 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 20/22] mm: page allocator: Hold magazine lock for a batch of pages
Date: Wed,  8 May 2013 17:03:05 +0100
Message-Id: <1368028987-8369-21-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

free_base_page_list() frees a list of pages. This patch will batch
the magazine lock for the list of pages if possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 61 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 727c8d3..cf31191 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1236,15 +1236,13 @@ static void magazine_drain(struct zone *zone, struct free_magazine *mag,
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
-/* Free a 0-order page */
-void free_base_page(struct page *page)
+/* Prepare a page for freeing and return its migratetype */
+static inline int free_base_page_prep(struct page *page)
 {
-	struct zone *zone = page_zone(page);
-	struct free_magazine *mag;
 	int migratetype;
 
 	if (!free_pages_prepare(page, 0))
-		return;
+		return -1;
 
 	migratetype = get_pageblock_migratetype(page);
 
@@ -1256,24 +1254,46 @@ void free_base_page(struct page *page)
 	 * excessively into the page allocator
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
-		if (unlikely(is_migrate_isolate(migratetype))) {
-			free_one_page(zone, page, 0, migratetype);
-			return;
-		}
-		migratetype = MIGRATE_MOVABLE;
+		if (likely(!is_migrate_isolate(migratetype)))
+			migratetype = MIGRATE_MOVABLE;
 	}
+
+	set_freepage_migratetype(page, migratetype);
+
+	return migratetype;
+}
+
+/* Put the free page on the magazine list with magazine lock held */
+static inline void __free_base_page(struct zone *zone,
+				struct free_area_magazine *area,
+				struct page *page, int migratetype)
+{
+	list_add(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Free a 0-order page */
+void free_base_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	struct free_magazine *mag;
+	int migratetype;
+
+	migratetype = free_base_page_prep(page);
+	if (migratetype == -1)
+		return;
 	set_freepage_migratetype(page, migratetype);
 
 	/* magazine_lock is not safe against IRQs */
-	if (in_interrupt() || irqs_disabled()) {
+	if (migratetype >= MIGRATE_PCPTYPES || in_interrupt() ||
+					       irqs_disabled()) {
 		free_one_page(zone, page, 0, migratetype);
 		return;
 	}
 
 	/* Put the free page on the magazine list */
 	mag = lock_magazine(zone);
-	list_add(&page->lru, &mag->area.free_list[migratetype]);
-	mag->area.nr_free++;
+	__free_base_page(zone, &mag->area, page, migratetype);
 
 	/* Drain the magazine if necessary, releases the magazine lock */
 	magazine_drain(zone, mag, migratetype);
@@ -1283,11 +1303,38 @@ void free_base_page(struct page *page)
 void free_base_page_list(struct list_head *list)
 {
 	struct page *page, *next;
+	struct zone *locked_zone = NULL;
+	struct free_magazine *mag = NULL;
+	bool use_magazine = (!in_interrupt() && !irqs_disabled());
+	int migratetype = MIGRATE_UNMOVABLE;
 
+	/* Similar to free_hot_cold_page except magazine lock is batched */
 	list_for_each_entry_safe(page, next, list, lru) {
+		struct zone *zone = page_zone(page);
+		int migratetype;
+
 		trace_mm_page_free_batched(page);
-		free_base_page(page);
+		migratetype = free_base_page_prep(page);
+		if (migratetype == -1)
+			continue;
+
+		if (!use_magazine || migratetype >= MIGRATE_PCPTYPES) {
+			free_one_page(zone, page, 0, migratetype);
+			continue;
+		}
+
+		if (zone != locked_zone) {
+			/* Drain unlocks magazine lock */
+			if (locked_zone)
+				magazine_drain(locked_zone, mag, migratetype);
+			mag = lock_magazine(zone);
+			locked_zone = zone;
+		}
+		__free_base_page(zone, &mag->area, page, migratetype);
 	}
+
+	if (locked_zone)
+		magazine_drain(locked_zone, mag, migratetype);
 }
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
