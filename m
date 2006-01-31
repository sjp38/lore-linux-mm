From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060131023020.7915.39262.sendpatchset@debian>
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060131023000.7915.71955.sendpatchset@debian>
Subject: [PATCH 4/8] Extract zone specific routines as functions
Date: Tue, 31 Jan 2006 11:30:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch extract per-zone parts from __drain_pages() and
__setup_per_zone_pages_min() as functions.  The extracted functions
will be used by pzone functions.

Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>

---
 page_alloc.c |  111 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 60 insertions(+), 51 deletions(-)

diff -urNp a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	2006-01-27 15:34:05.000000000 +0900
+++ b/mm/page_alloc.c	2006-01-27 15:29:03.000000000 +0900
@@ -588,28 +599,32 @@ void drain_remote_pages(void)
 }
 #endif
 
-#if defined(CONFIG_PM) || defined(CONFIG_HOTPLUG_CPU)
-static void __drain_pages(unsigned int cpu)
+#if defined(CONFIG_PM) || defined(CONFIG_HOTPLUG_CPU)
+static void __drain_zone_pages(struct zone *zone, int cpu)
 {
-	struct zone *zone;
+	struct per_cpu_pageset *pset;
 	int i;
 
-	read_lock_nr_zones();
-	for_each_zone(zone) {
-		struct per_cpu_pageset *pset;
-
-		pset = zone_pcp(zone, cpu);
-		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
-			struct per_cpu_pages *pcp;
+	pset = zone_pcp(zone, cpu);
+	for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
+		struct per_cpu_pages *pcp;
 
-			pcp = &pset->pcp[i];
-			pcp->count -= free_pages_bulk(zone, pcp->count,
-						&pcp->list, 0);
-		}
+		pcp = &pset->pcp[i];
+		pcp->count -= free_pages_bulk(zone, pcp->count,
+					&pcp->list, 0);
 	}
+}
+
+static void __drain_pages(unsigned int cpu)
+{
+	struct zone *zone;
+
+	read_lock_nr_zones();
+	for_each_zone(zone)
+		__drain_zone_pages(zone, cpu);
 	read_unlock_nr_zones();
 }
-#endif /* CONFIG_PM || CONFIG_HOTPLUG_CPU */
+#endif /* CONFIG_PM || CONFIG_HOTPLUG_CPU */
 
 #ifdef CONFIG_PM
 
@@ -2429,6 +2445,45 @@ static void setup_per_zone_lowmem_reserv
 	}
 }
 
+static void setup_zone_pages_min(struct zone *zone, unsigned long lowmem_pages)
+{
+	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned long flags;
+	unsigned long tmp;
+
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	tmp = (pages_min * zone->present_pages) / lowmem_pages;
+	if (is_highmem(zone)) {
+		/*
+		 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
+		 * need highmem pages, so cap pages_min to a small
+		 * value here.
+		 *
+		 * The (pages_high-pages_low) and (pages_low-pages_min)
+		 * deltas controls asynch page reclaim, and so should
+		 * not be capped for highmem.
+		 */
+		int min_pages;
+
+		min_pages = zone->present_pages / 1024;
+		if (min_pages < SWAP_CLUSTER_MAX)
+			min_pages = SWAP_CLUSTER_MAX;
+		if (min_pages > 128)
+			min_pages = 128;
+		zone->pages_min = min_pages;
+	} else {
+		/*
+		 * If it's a lowmem zone, reserve a number of pages
+		 * proportionate to the zone's size.
+		 */
+		zone->pages_min = tmp;
+	}
+
+	zone->pages_low   = zone->pages_min + tmp / 4;
+	zone->pages_high  = zone->pages_min + tmp / 2;
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+}
+
 /*
  * setup_per_zone_pages_min - called when min_free_kbytes changes.  Ensures 
  *	that the pages_{min,low,high} values for each zone are set correctly 
@@ -2436,10 +2491,8 @@ static void setup_per_zone_lowmem_reserv
  */
 void setup_per_zone_pages_min(void)
 {
-	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
-	unsigned long flags;
 
 	read_lock_nr_zones();
 	/* Calculate total number of !ZONE_HIGHMEM pages */
@@ -2448,40 +2501,8 @@ void setup_per_zone_pages_min(void)
 			lowmem_pages += zone->present_pages;
 	}
 
-	for_each_zone(zone) {
-		unsigned long tmp;
-		spin_lock_irqsave(&zone->lru_lock, flags);
-		tmp = (pages_min * zone->present_pages) / lowmem_pages;
-		if (is_highmem(zone)) {
-			/*
-			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
-			 * need highmem pages, so cap pages_min to a small
-			 * value here.
-			 *
-			 * The (pages_high-pages_low) and (pages_low-pages_min)
-			 * deltas controls asynch page reclaim, and so should
-			 * not be capped for highmem.
-			 */
-			int min_pages;
-
-			min_pages = zone->present_pages / 1024;
-			if (min_pages < SWAP_CLUSTER_MAX)
-				min_pages = SWAP_CLUSTER_MAX;
-			if (min_pages > 128)
-				min_pages = 128;
-			zone->pages_min = min_pages;
-		} else {
-			/*
-			 * If it's a lowmem zone, reserve a number of pages
-			 * proportionate to the zone's size.
-			 */
-			zone->pages_min = tmp;
-		}
-
-		zone->pages_low   = zone->pages_min + tmp / 4;
-		zone->pages_high  = zone->pages_min + tmp / 2;
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
-	}
+	for_each_zone(zone)
+		setup_zone_pages_min(zone, lowmem_pages);
 	read_unlock_nr_zones();
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
