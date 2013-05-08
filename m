Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DE0026B014B
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:22 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/22] mm: page allocator: Move magazine access behind accessors
Date: Wed,  8 May 2013 17:03:02 +0100
Message-Id: <1368028987-8369-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

In preparation for splitting the magazines, move them behind accessors.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  4 ++--
 mm/page_alloc.c        | 57 +++++++++++++++++++++++++++++++++-----------------
 mm/vmstat.c            |  5 +----
 3 files changed, 41 insertions(+), 25 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ca04853..4eb5151 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -370,8 +370,8 @@ struct zone {
 	 * Keep some order-0 pages on a separate free list
 	 * protected by an irq-unsafe lock
 	 */
-	spinlock_t			magazine_lock;
-	struct free_area_magazine	noirq_magazine;
+	spinlock_t			_magazine_lock;
+	struct free_area_magazine	_noirq_magazine;
 
 #ifndef CONFIG_SPARSEMEM
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6760e00..36ffff0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1074,11 +1074,33 @@ void mark_free_pages(struct zone *zone)
 #define MAGAZINE_ALLOC_BATCH (384)
 #define MAGAZINE_FREE_BATCH (64)
 
+static inline struct free_area_magazine *find_lock_magazine(struct zone *zone)
+{
+	struct free_area_magazine *area = &zone->_noirq_magazine;
+	spin_lock(&zone->_magazine_lock);
+	return area;
+}
+
+static inline struct free_area_magazine *find_lock_filled_magazine(struct zone *zone)
+{
+	struct free_area_magazine *area = &zone->_noirq_magazine;
+	if (!area->nr_free)
+		return NULL;
+	spin_lock(&zone->_magazine_lock);
+	return area;
+}
+
+static inline void unlock_magazine(struct free_area_magazine *area)
+{
+	struct zone *zone = container_of(area, struct zone, _noirq_magazine);
+	spin_unlock(&zone->_magazine_lock);
+}
+
 static
-struct page *__rmqueue_magazine(struct zone *zone, int migratetype)
+struct page *__rmqueue_magazine(struct free_area_magazine *area,
+				int migratetype)
 {
 	struct page *page;
-	struct free_area_magazine *area = &(zone->noirq_magazine);
 
 	if (list_empty(&area->free_list[migratetype]))
 		return NULL;
@@ -1092,9 +1114,9 @@ struct page *__rmqueue_magazine(struct zone *zone, int migratetype)
 	return page;
 }
 
-static void magazine_drain(struct zone *zone, int migratetype)
+static void magazine_drain(struct zone *zone, struct free_area_magazine *area,
+			   int migratetype)
 {
-	struct free_area_magazine *area = &(zone->noirq_magazine);
 	struct list_head *list;
 	struct page *page;
 	unsigned int batch_free = 0;
@@ -1104,7 +1126,7 @@ static void magazine_drain(struct zone *zone, int migratetype)
 	LIST_HEAD(free_list);
 
 	if (area->nr_free < MAGAZINE_LIMIT) {
-		spin_unlock(&zone->magazine_lock);
+		unlock_magazine(area);
 		return;
 	}
 
@@ -1139,7 +1161,7 @@ static void magazine_drain(struct zone *zone, int migratetype)
 	}
 
 	/* Free the list of pages to the buddy allocator */
-	spin_unlock(&zone->magazine_lock);
+	unlock_magazine(area);
 	spin_lock_irqsave(&zone->lock, flags);
 	while (!list_empty(&free_list)) {
 		page = list_entry(free_list.prev, struct page, lru);
@@ -1188,13 +1210,12 @@ void free_base_page(struct page *page)
 	}
 
 	/* Put the free page on the magazine list */
-	spin_lock(&zone->magazine_lock);
-	area = &(zone->noirq_magazine);
+	area = find_lock_magazine(zone);
 	list_add(&page->lru, &area->free_list[migratetype]);
 	area->nr_free++;
 
 	/* Drain the magazine if necessary, releases the magazine lock */
-	magazine_drain(zone, migratetype);
+	magazine_drain(zone, area, migratetype);
 }
 
 /* Free a list of 0-order pages */
@@ -1307,20 +1328,18 @@ static
 struct page *rmqueue_magazine(struct zone *zone, int migratetype)
 {
 	struct page *page = NULL;
+	struct free_area_magazine *area = find_lock_filled_magazine(zone);
 
-	/* Only acquire the lock if there is a reasonable chance of success */
-	if (zone->noirq_magazine.nr_free) {
-		spin_lock(&zone->magazine_lock);
 retry:
-		page = __rmqueue_magazine(zone, migratetype);
-		spin_unlock(&zone->magazine_lock);
+	if (area) {
+		page = __rmqueue_magazine(area, migratetype);
+		unlock_magazine(area);
 	}
 
 	/* Try refilling the magazine on allocaion failure */
 	if (!page) {
 		LIST_HEAD(alloc_list);
 		unsigned long flags;
-		struct free_area_magazine *area = &(zone->noirq_magazine);
 		unsigned int i;
 		unsigned int nr_alloced = 0;
 
@@ -1340,7 +1359,7 @@ retry:
 		if (!nr_alloced)
 			return NULL;
 
-		spin_lock(&zone->magazine_lock);
+		area = find_lock_magazine(zone);
 		list_splice(&alloc_list, &area->free_list[migratetype]);
 		area->nr_free += nr_alloced;
 		goto retry;
@@ -3782,8 +3801,8 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
-		INIT_LIST_HEAD(&zone->noirq_magazine.free_list[t]);
-		zone->noirq_magazine.nr_free = 0;
+		INIT_LIST_HEAD(&zone->_noirq_magazine.free_list[t]);
+		zone->_noirq_magazine.nr_free = 0;
 	}
 }
 
@@ -4333,7 +4352,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
 		spin_lock_init(&zone->lru_lock);
-		spin_lock_init(&zone->magazine_lock);
+		spin_lock_init(&zone->_magazine_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7274ca5..3db0d52 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1003,15 +1003,12 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   ")"
 		   "\n  noirq magazine");
 	seq_printf(m,
-		"\n    cpu: %i"
 		"\n              count: %lu",
-		i,
-		zone->noirq_magazine.nr_free);
+		zone->_noirq_magazine.nr_free);
 
 #ifdef CONFIG_SMP
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
-
  		pageset = per_cpu_ptr(zone->pageset, i);
 		seq_printf(m, "\n  pagesets\n  vm stats threshold: %d",
  				pageset->stat_threshold);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
