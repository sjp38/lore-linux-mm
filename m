Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id F159C6B0152
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:59 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 22/22] mm: page allocator: Drain magazines for direct compact failures
Date: Wed,  8 May 2013 17:03:07 +0100
Message-Id: <1368028987-8369-23-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

THP allocations may fail due to pages pinned in magazines so drain them
in the event of a direct compact failure. Similarly drain the magazines
during memory hot-remove, memory failure and page isolation as before.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h |  2 ++
 mm/memory-failure.c |  1 +
 mm/memory_hotplug.c |  2 ++
 mm/page_alloc.c     | 63 +++++++++++++++++++++++++++++++++++++++++++++--------
 mm/page_isolation.c |  1 +
 5 files changed, 60 insertions(+), 9 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 53844b4..fafa28b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -375,6 +375,8 @@ extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
 #define free_page(addr) free_pages((addr), 0)
 
 void page_alloc_init(void);
+void drain_zone_magazine(struct zone *zone);
+void drain_all_magazines(void);
 
 /*
  * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 3175ffd..cd201a3 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -237,6 +237,7 @@ void shake_page(struct page *p, int access)
 		lru_add_drain_all();
 		if (PageLRU(p))
 			return;
+		drain_zone_magazine(page_zone(p));
 		if (PageLRU(p) || is_free_buddy_page(p))
 			return;
 	}
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 63f473c..b35c6ee 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1526,6 +1526,7 @@ repeat:
 	if (drain) {
 		lru_add_drain_all();
 		cond_resched();
+		drain_all_magazines();
 	}
 
 	pfn = scan_lru_pages(start_pfn, end_pfn);
@@ -1546,6 +1547,7 @@ repeat:
 	/* drain all zone's lru pagevec, this is asynchronous... */
 	lru_add_drain_all();
 	yield();
+	drain_all_magazines();
 	/* check again */
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
 	if (offlined_pages < 0) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 374adf8..0f0bc18 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1164,23 +1164,17 @@ struct page *__rmqueue_magazine(struct free_magazine *mag,
 	return page;
 }
 
-static void magazine_drain(struct zone *zone, struct free_magazine *mag,
-			   int migratetype)
+static void __magazine_drain(struct zone *zone, struct free_magazine *mag,
+			   int migratetype, int min_to_free, int to_free)
 {
 	struct list_head *list;
 	struct page *page;
 	unsigned int batch_free = 0;
-	unsigned int to_free = MAGAZINE_MAX_FREE_BATCH;
 	unsigned int nr_freed_cma = 0, nr_freed = 0;
 	unsigned long flags;
 	struct free_area_magazine *area = &mag->area;
 	LIST_HEAD(free_list);
 
-	if (area->nr_free < MAGAZINE_LIMIT) {
-		unlock_magazine(mag);
-		return;
-	}
-
 	/* Free batch number of pages */
 	while (to_free) {
 		/*
@@ -1216,7 +1210,7 @@ static void magazine_drain(struct zone *zone, struct free_magazine *mag,
 		} while (--to_free && --batch_free && !list_empty(list));
 
 		/* Watch for parallel contention */
-		if (nr_freed > MAGAZINE_MIN_FREE_BATCH &&
+		if (nr_freed > min_to_free &&
 		    magazine_contended(mag))
 			break;
 	}
@@ -1236,6 +1230,53 @@ static void magazine_drain(struct zone *zone, struct free_magazine *mag,
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+static void magazine_drain(struct zone *zone, struct free_magazine *mag,
+			   int migratetype)
+{
+	if (mag->area.nr_free < MAGAZINE_LIMIT) {
+		unlock_magazine(mag);
+		return;
+	}
+
+	__magazine_drain(zone, mag, migratetype, MAGAZINE_MIN_FREE_BATCH,
+			MAGAZINE_MAX_FREE_BATCH);
+}
+
+void drain_zone_magazine(struct zone *zone)
+{
+	int i;
+
+	for (i = 0; i < NR_MAGAZINES; i++) {
+		struct free_magazine *mag = &zone->noirq_magazine[i];
+
+		spin_lock(&zone->noirq_magazine[i].lock);
+		__magazine_drain(zone, mag, MIGRATE_UNMOVABLE,
+				mag->area.nr_free,
+				mag->area.nr_free);
+		spin_unlock(&zone->noirq_magazine[i].lock);
+	}
+}
+
+static void drain_zonelist_magazine(struct zonelist *zonelist,
+			enum zone_type high_zoneidx, nodemask_t *nodemask)
+{
+	struct zoneref *z;
+	struct zone *zone;
+
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+						high_zoneidx, nodemask) {
+		drain_zone_magazine(zone);
+	}
+}
+
+void drain_all_magazines(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone)
+		drain_zone_magazine(zone);
+}
+
 /* Prepare a page for freeing and return its migratetype */
 static inline int free_base_page_prep(struct page *page)
 {
@@ -2170,6 +2211,9 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	if (*did_some_progress != COMPACT_SKIPPED) {
 		struct page *page;
 
+		/* Page migration frees to the magazine but we want merging */
+		drain_zonelist_magazine(zonelist, high_zoneidx, nodemask);
+
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
@@ -5766,6 +5810,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 */
 
 	lru_add_drain_all();
+	drain_all_magazines();
 
 	order = 0;
 	outer_start = start;
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index af79199..1279d9d 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -62,6 +62,7 @@ out:
 		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
 
 		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
+		drain_zone_magazine(zone);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
