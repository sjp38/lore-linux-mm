Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AB4EA6B014D
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:23 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 18/22] mm: page allocator: Split magazine lock in two to reduce contention
Date: Wed,  8 May 2013 17:03:03 +0100
Message-Id: <1368028987-8369-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is the simpliest example of how the lock can be split arbitrarily
on a boundary. Ideally it would be based on SMT characteristics but lets
just split it in two to start with and prefer a magazine based on the
processor ID.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  12 ++++--
 mm/page_alloc.c        | 114 +++++++++++++++++++++++++++++++++++--------------
 mm/vmstat.c            |   8 ++--
 3 files changed, 95 insertions(+), 39 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4eb5151..c0a8958 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -90,6 +90,11 @@ struct free_area_magazine {
 	unsigned long		nr_free;
 };
 
+struct free_magazine {
+	spinlock_t			lock;
+	struct free_area_magazine	area;
+};
+
 struct pglist_data;
 
 /*
@@ -305,6 +310,8 @@ enum zone_type {
 
 #ifndef __GENERATING_BOUNDS_H
 
+#define NR_MAGAZINES 2
+
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 
@@ -368,10 +375,9 @@ struct zone {
 
 	/*
 	 * Keep some order-0 pages on a separate free list
-	 * protected by an irq-unsafe lock
+	 * protected by an irq-unsafe lock.
 	 */
-	spinlock_t			_magazine_lock;
-	struct free_area_magazine	_noirq_magazine;
+	struct free_magazine	noirq_magazine[NR_MAGAZINES];
 
 #ifndef CONFIG_SPARSEMEM
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 36ffff0..63952f6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1074,33 +1074,76 @@ void mark_free_pages(struct zone *zone)
 #define MAGAZINE_ALLOC_BATCH (384)
 #define MAGAZINE_FREE_BATCH (64)
 
-static inline struct free_area_magazine *find_lock_magazine(struct zone *zone)
+static inline struct free_magazine *lock_magazine(struct zone *zone)
 {
-	struct free_area_magazine *area = &zone->_noirq_magazine;
-	spin_lock(&zone->_magazine_lock);
-	return area;
+	int i = (raw_smp_processor_id() >> 1) & (NR_MAGAZINES-1);
+	spin_lock(&zone->noirq_magazine[i].lock);
+	return &zone->noirq_magazine[i];
 }
 
-static inline struct free_area_magazine *find_lock_filled_magazine(struct zone *zone)
+static inline struct free_magazine *find_lock_magazine(struct zone *zone)
 {
-	struct free_area_magazine *area = &zone->_noirq_magazine;
-	if (!area->nr_free)
+	int i = (raw_smp_processor_id() >> 1) & (NR_MAGAZINES-1);
+	int start = i;
+
+	do {
+		if (spin_trylock(&zone->noirq_magazine[i].lock))
+			goto out;
+		i = (i + 1) & (NR_MAGAZINES-1);
+	} while (i != start);
+
+	spin_lock(&zone->noirq_magazine[i].lock);
+out:
+	return &zone->noirq_magazine[i];
+}
+
+static struct free_magazine *find_lock_filled_magazine(struct zone *zone)
+{
+	int i = (raw_smp_processor_id() >> 1) & (NR_MAGAZINES-1);
+	int start = i;
+	bool all_empty = true;
+
+	/* Pass 1. Find an unlocked magazine with free pages */
+	do {
+		if (zone->noirq_magazine[i].area.nr_free) {
+			all_empty = false;
+			if (spin_trylock(&zone->noirq_magazine[i].lock))
+				goto out;
+		}
+		i = (i + 1) & (NR_MAGAZINES-1);
+	} while (i != start);
+
+	/* If all area empty then a second pass is pointness */
+	if (all_empty)
 		return NULL;
-	spin_lock(&zone->_magazine_lock);
-	return area;
+
+	/* Pass 2. Find a magazine with pages and wait on it */
+	do {
+		if (zone->noirq_magazine[i].area.nr_free) {
+			spin_lock(&zone->noirq_magazine[i].lock);
+			goto out;
+		}
+		i = (i + 1) & (NR_MAGAZINES-1);
+	} while (i != start);
+
+	/* Lock holder emptied the last magazine or raced */
+	return NULL;
+
+out:
+	return &zone->noirq_magazine[i];
 }
 
-static inline void unlock_magazine(struct free_area_magazine *area)
+static inline void unlock_magazine(struct free_magazine *mag)
 {
-	struct zone *zone = container_of(area, struct zone, _noirq_magazine);
-	spin_unlock(&zone->_magazine_lock);
+	spin_unlock(&mag->lock);
 }
 
 static
-struct page *__rmqueue_magazine(struct free_area_magazine *area,
+struct page *__rmqueue_magazine(struct free_magazine *mag,
 				int migratetype)
 {
 	struct page *page;
+	struct free_area_magazine *area = &mag->area;
 
 	if (list_empty(&area->free_list[migratetype]))
 		return NULL;
@@ -1114,7 +1157,7 @@ struct page *__rmqueue_magazine(struct free_area_magazine *area,
 	return page;
 }
 
-static void magazine_drain(struct zone *zone, struct free_area_magazine *area,
+static void magazine_drain(struct zone *zone, struct free_magazine *mag,
 			   int migratetype)
 {
 	struct list_head *list;
@@ -1123,10 +1166,11 @@ static void magazine_drain(struct zone *zone, struct free_area_magazine *area,
 	unsigned int to_free = MAGAZINE_FREE_BATCH;
 	unsigned int nr_freed_cma = 0;
 	unsigned long flags;
+	struct free_area_magazine *area = &mag->area;
 	LIST_HEAD(free_list);
 
 	if (area->nr_free < MAGAZINE_LIMIT) {
-		unlock_magazine(area);
+		unlock_magazine(mag);
 		return;
 	}
 
@@ -1161,7 +1205,7 @@ static void magazine_drain(struct zone *zone, struct free_area_magazine *area,
 	}
 
 	/* Free the list of pages to the buddy allocator */
-	unlock_magazine(area);
+	unlock_magazine(mag);
 	spin_lock_irqsave(&zone->lock, flags);
 	while (!list_empty(&free_list)) {
 		page = list_entry(free_list.prev, struct page, lru);
@@ -1179,8 +1223,8 @@ static void magazine_drain(struct zone *zone, struct free_area_magazine *area,
 void free_base_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	struct free_magazine *mag;
 	int migratetype;
-	struct free_area_magazine *area;
 
 	if (!free_pages_prepare(page, 0))
 		return;
@@ -1210,12 +1254,12 @@ void free_base_page(struct page *page)
 	}
 
 	/* Put the free page on the magazine list */
-	area = find_lock_magazine(zone);
-	list_add(&page->lru, &area->free_list[migratetype]);
-	area->nr_free++;
+	mag = lock_magazine(zone);
+	list_add(&page->lru, &mag->area.free_list[migratetype]);
+	mag->area.nr_free++;
 
 	/* Drain the magazine if necessary, releases the magazine lock */
-	magazine_drain(zone, area, migratetype);
+	magazine_drain(zone, mag, migratetype);
 }
 
 /* Free a list of 0-order pages */
@@ -1328,12 +1372,12 @@ static
 struct page *rmqueue_magazine(struct zone *zone, int migratetype)
 {
 	struct page *page = NULL;
-	struct free_area_magazine *area = find_lock_filled_magazine(zone);
+	struct free_magazine *mag = find_lock_filled_magazine(zone);
 
 retry:
-	if (area) {
-		page = __rmqueue_magazine(area, migratetype);
-		unlock_magazine(area);
+	if (mag) {
+		page = __rmqueue_magazine(mag, migratetype);
+		unlock_magazine(mag);
 	}
 
 	/* Try refilling the magazine on allocaion failure */
@@ -1359,9 +1403,9 @@ retry:
 		if (!nr_alloced)
 			return NULL;
 
-		area = find_lock_magazine(zone);
-		list_splice(&alloc_list, &area->free_list[migratetype]);
-		area->nr_free += nr_alloced;
+		mag = find_lock_magazine(zone);
+		list_splice(&alloc_list, &mag->area.free_list[migratetype]);
+		mag->area.nr_free += nr_alloced;
 		goto retry;
 	}
 
@@ -3797,12 +3841,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 static void __meminit zone_init_free_lists(struct zone *zone)
 {
-	unsigned int order, t;
+	unsigned int order, t, i;
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
-		INIT_LIST_HEAD(&zone->_noirq_magazine.free_list[t]);
-		zone->_noirq_magazine.nr_free = 0;
+		for (i = 0; i < NR_MAGAZINES && t < MIGRATE_PCPTYPES; i++) {
+			INIT_LIST_HEAD(&zone->noirq_magazine[i].area.free_list[t]);
+			zone->noirq_magazine[i].area.nr_free = 0;
+		}
 	}
 }
 
@@ -4284,7 +4330,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	enum zone_type j;
 	int nid = pgdat->node_id;
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
-	int ret;
+	int ret, i;
 
 	pgdat_resize_init(pgdat);
 #ifdef CONFIG_NUMA_BALANCING
@@ -4352,7 +4398,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
 		spin_lock_init(&zone->lru_lock);
-		spin_lock_init(&zone->_magazine_lock);
+		
+		for (i = 0; i < NR_MAGAZINES; i++)
+			spin_lock_init(&zone->noirq_magazine[i].lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 3db0d52..1374f92 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1002,9 +1002,11 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	seq_printf(m,
 		   ")"
 		   "\n  noirq magazine");
-	seq_printf(m,
-		"\n              count: %lu",
-		zone->_noirq_magazine.nr_free);
+	for (i = 0; i < NR_MAGAZINES; i++) {
+		seq_printf(m,
+			"\n              count: %lu",
+			zone->noirq_magazine[i].area.nr_free);
+	}
 
 #ifdef CONFIG_SMP
 	for_each_online_cpu(i) {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
