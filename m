Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id BECA36B013D
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:17 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/22] mm: page allocator: Allocate and free pages from magazine in batches
Date: Wed,  8 May 2013 17:02:55 +0100
Message-Id: <1368028987-8369-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When the magazine is empty or full the zone lock is taken and a single
page is operated on. This makes the zone lock hotter than it needs to be
so batch allocations and frees from the zone. A larger number of pages
are taken when refilling the magazine to reduce the contention on the
zone->lock for IRQ-disabled callers. It's more likely that a workload will
notice contention on allocations than contentions on free although of
course this is workload dependant

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 172 +++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 127 insertions(+), 45 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9ed05a5..9426174 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -601,8 +601,6 @@ static inline void __free_one_page(struct page *page,
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
 out:
 	zone->free_area[order].nr_free++;
-	if (unlikely(!is_migrate_isolate(migratetype)))
-		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 }
 
 static inline int free_pages_check(struct page *page)
@@ -634,6 +632,8 @@ static void free_one_page(struct zone *zone, struct page *page,
 	__count_vm_events(PGFREE, 1 << order);
 
 	__free_one_page(page, zone, order, migratetype);
+	if (unlikely(!is_migrate_isolate(migratetype)))
+		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
@@ -1093,6 +1093,87 @@ void mark_free_pages(struct zone *zone)
 #endif /* CONFIG_PM */
 
 #define MAGAZINE_LIMIT (1024)
+#define MAGAZINE_ALLOC_BATCH (384)
+#define MAGAZINE_FREE_BATCH (64)
+
+static
+struct page *__rmqueue_magazine(struct zone *zone, int migratetype)
+{
+	struct page *page;
+	struct free_area *area = &(zone->noirq_magazine);
+
+	if (list_empty(&area->free_list[migratetype]))
+		return NULL;
+
+	/* Page is available in the magazine, allocate it */
+	page = list_entry(area->free_list[migratetype].next, struct page, lru);
+	list_del(&page->lru);
+	area->nr_free--;
+	set_page_private(page, 0);
+
+	return page;
+}
+
+static void magazine_drain(struct zone *zone, int migratetype)
+{
+	struct free_area *area = &(zone->noirq_magazine);
+	struct list_head *list;
+	struct page *page;
+	unsigned int batch_free = 0;
+	unsigned int to_free = MAGAZINE_FREE_BATCH;
+	unsigned int nr_freed_cma = 0;
+	unsigned long flags;
+	LIST_HEAD(free_list);
+
+	if (area->nr_free < MAGAZINE_LIMIT) {
+		spin_unlock(&zone->magazine_lock);
+		return;
+	}
+
+	/* Free batch number of pages */
+	while (to_free) {
+		/*
+		 * Removes pages from lists in a round-robin fashion. A
+		 * batch_free count is maintained that is incremented when an
+		 * empty list is encountered.  This is so more pages are freed
+		 * off fuller lists instead of spinning excessively around empty
+		 * lists
+		 */
+		do {
+			batch_free++;
+			if (++migratetype == MIGRATE_PCPTYPES)
+				migratetype = 0;
+			list = &area->free_list[migratetype];;
+		} while (list_empty(list));
+
+		/* This is the only non-empty list. Free them all. */
+		if (batch_free == MIGRATE_PCPTYPES)
+			batch_free = to_free;
+
+		do {
+			page = list_entry(list->prev, struct page, lru);
+			area->nr_free--;
+			set_page_private(page, 0);
+			list_move(&page->lru, &free_list);
+			if (is_migrate_isolate_page(zone, page))
+				nr_freed_cma++;
+		} while (--to_free && --batch_free && !list_empty(list));
+	}
+
+	/* Free the list of pages to the buddy allocator */
+	spin_unlock(&zone->magazine_lock);
+	spin_lock_irqsave(&zone->lock, flags);
+	while (!list_empty(&free_list)) {
+		page = list_entry(free_list.prev, struct page, lru);
+		list_del(&page->lru);
+		__free_one_page(page, zone, 0, get_freepage_migratetype(page));
+	}
+	__mod_zone_page_state(zone, NR_FREE_PAGES,
+				MAGAZINE_FREE_BATCH - nr_freed_cma);
+	if (nr_freed_cma)
+		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_freed_cma);
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
 
 /*
  * Free a 0-order page
@@ -1111,8 +1192,10 @@ void free_hot_cold_page(struct page *page, bool cold)
 	set_freepage_migratetype(page, migratetype);
 
 	/* magazine_lock is not safe against IRQs */
-	if (in_interrupt() || irqs_disabled())
-		goto free_one;
+	if (in_interrupt() || irqs_disabled()) {
+		free_one_page(zone, page, 0, migratetype);
+		return;
+	}
 
 	/* Put the free page on the magazine list */
 	spin_lock(&zone->magazine_lock);
@@ -1121,32 +1204,10 @@ void free_hot_cold_page(struct page *page, bool cold)
 		list_add(&page->lru, &area->free_list[migratetype]);
 	else
 		list_add_tail(&page->lru, &area->free_list[migratetype]);
-	page = NULL;
-
-	/* If the magazine is full, remove a cold page for the buddy list */
-	if (area->nr_free > MAGAZINE_LIMIT) {
-		struct list_head *list = &area->free_list[migratetype];
-		int starttype = migratetype;
+	area->nr_free++;
 
-		while (list_empty(list)) {
-			if (++migratetype == MIGRATE_PCPTYPES)
-				migratetype = 0;
-			list = &area->free_list[migratetype];;
-		
-			WARN_ON_ONCE(starttype == migratetype);
-		}
-			
-		page = list_entry(list->prev, struct page, lru);
-		list_del(&page->lru);
-	} else {
-		area->nr_free++;
-	}
-	spin_unlock(&zone->magazine_lock);
-
-free_one:
-	/* Free a page back to the buddy lists if necessary */
-	if (page)
-		free_one_page(zone, page, 0, migratetype);
+	/* Drain the magazine if necessary, releases the magazine lock */
+	magazine_drain(zone, migratetype);
 }
 
 /*
@@ -1261,25 +1322,46 @@ static
 struct page *rmqueue_magazine(struct zone *zone, int migratetype)
 {
 	struct page *page = NULL;
-	struct free_area *area;
 
-	/* Check if it is worth acquiring the lock */
-	if (!zone->noirq_magazine.nr_free)
-		return NULL;
-		
-	spin_lock(&zone->magazine_lock);
-	area = &(zone->noirq_magazine);
-	if (list_empty(&area->free_list[migratetype]))
-		goto out;
+	/* Only acquire the lock if there is a reasonable chance of success */
+	if (zone->noirq_magazine.nr_free) {
+		spin_lock(&zone->magazine_lock);
+		page = __rmqueue_magazine(zone, migratetype);
+		spin_unlock(&zone->magazine_lock);
+	}
 
-	/* Page is available in the magazine, allocate it */
-	page = list_entry(area->free_list[migratetype].next, struct page, lru);
-	list_del(&page->lru);
-	area->nr_free--;
-	set_page_private(page, 0);
+	/* Try refilling the magazine on allocaion failure */
+	if (!page) {
+		LIST_HEAD(alloc_list);
+		unsigned long flags;
+		struct free_area *area = &(zone->noirq_magazine);
+		unsigned int i;
+		unsigned int nr_alloced = 0;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		for (i = 0; i < MAGAZINE_ALLOC_BATCH; i++) {
+			page = __rmqueue(zone, 0, migratetype);
+			if (!page)
+				break;
+			list_add_tail(&page->lru, &alloc_list);
+			nr_alloced++;
+		}
+		if (!is_migrate_cma(mt))
+			__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_alloced);
+		else
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, -nr_alloced);
+		spin_unlock_irqrestore(&zone->lock, flags);
+
+		spin_lock(&zone->magazine_lock);
+		while (!list_empty(&alloc_list)) {
+			page = list_entry(alloc_list.next, struct page, lru);
+			list_move_tail(&page->lru, &area->free_list[migratetype]);
+			area->nr_free++;
+		}
+		page = __rmqueue_magazine(zone, migratetype);
+		spin_unlock(&zone->magazine_lock);
+	}
 
-out:
-	spin_unlock(&zone->magazine_lock);
 	return page;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
