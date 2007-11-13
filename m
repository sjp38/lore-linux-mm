Date: Mon, 12 Nov 2007 20:42:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Page allocator: Get rid of the list of cold pages
Message-ID: <Pine.LNX.4.64.0711122041320.30747@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

We have repeatedly discussed if the cold pages still have a point. There is
one way to join the two lists: Use a single list and put the cold pages at the
end and the hot pages at the beginning. That way a single list can serve for
both types of allocations.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mmzone.h |    2 -
 mm/page_alloc.c        |   55 +++++++++++++++++++++++--------------------------
 mm/vmstat.c            |   24 ++++++++-------------
 3 files changed, 36 insertions(+), 45 deletions(-)

Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2007-11-12 20:16:24.814260361 -0800
+++ linux-2.6/include/linux/mmzone.h	2007-11-12 20:17:35.267759790 -0800
@@ -113,7 +113,7 @@ struct per_cpu_pages {
 };
 
 struct per_cpu_pageset {
-	struct per_cpu_pages pcp[2];	/* 0: hot.  1: cold */
+	struct per_cpu_pages pcp;
 #ifdef CONFIG_NUMA
 	s8 expire;
 #endif
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2007-11-12 20:16:24.822260116 -0800
+++ linux-2.6/mm/vmstat.c	2007-11-12 20:29:18.912816791 -0800
@@ -332,7 +332,7 @@ void refresh_cpu_vm_stats(int cpu)
 		 * Check if there are pages remaining in this pageset
 		 * if not then there is nothing to expire.
 		 */
-		if (!p->expire || (!p->pcp[0].count && !p->pcp[1].count))
+		if (!p->expire || !p->pcp.count)
 			continue;
 
 		/*
@@ -347,11 +347,8 @@ void refresh_cpu_vm_stats(int cpu)
 		if (p->expire)
 			continue;
 
-		if (p->pcp[0].count)
-			drain_zone_pages(zone, p->pcp + 0);
-
-		if (p->pcp[1].count)
-			drain_zone_pages(zone, p->pcp + 1);
+		if (p->pcp.count)
+			drain_zone_pages(zone, &p->pcp);
 #endif
 	}
 }
@@ -685,20 +682,17 @@ static void zoneinfo_show_print(struct s
 		   "\n  pagesets");
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
-		int j;
 
 		pageset = CPU_PTR(zone->pageset, i);
-		for (j = 0; j < ARRAY_SIZE(pageset->pcp); j++) {
-			seq_printf(m,
-				   "\n    cpu: %i pcp: %i"
+		seq_printf(m,
+				   "\n    cpu: %i"
 				   "\n              count: %i"
 				   "\n              high:  %i"
 				   "\n              batch: %i",
-				   i, j,
-				   pageset->pcp[j].count,
-				   pageset->pcp[j].high,
-				   pageset->pcp[j].batch);
-			}
+				   i,
+				   pageset->pcp.count,
+				   pageset->pcp.high,
+				   pageset->pcp.batch);
 #ifdef CONFIG_SMP
 		seq_printf(m, "\n  vm stats threshold: %d",
 				pageset->stat_threshold);
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-11-12 20:16:24.830259956 -0800
+++ linux-2.6/mm/page_alloc.c	2007-11-12 20:26:44.766259839 -0800
@@ -885,24 +885,21 @@ static void __drain_pages(unsigned int c
 {
 	unsigned long flags;
 	struct zone *zone;
-	int i;
 
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset;
+		struct per_cpu_pages *pcp;
 
 		if (!populated_zone(zone))
 			continue;
 
 		pset = CPU_PTR(zone->pageset, cpu);
-		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
-			struct per_cpu_pages *pcp;
 
-			pcp = &pset->pcp[i];
-			local_irq_save(flags);
-			free_pages_bulk(zone, pcp->count, &pcp->list, 0);
-			pcp->count = 0;
-			local_irq_restore(flags);
-		}
+		pcp = &pset->pcp;
+		local_irq_save(flags);
+		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
+		pcp->count = 0;
+		local_irq_restore(flags);
 	}
 }
 
@@ -993,9 +990,12 @@ static void fastcall free_hot_cold_page(
 	kernel_map_pages(page, 1, 0);
 
 	local_irq_save(flags);
-	pcp = &THIS_CPU(zone->pageset)->pcp[cold];
+	pcp = &THIS_CPU(zone->pageset)->pcp;
 	__count_vm_event(PGFREE);
-	list_add(&page->lru, &pcp->list);
+	if (cold)
+		list_add_tail(&page->lru, &pcp->list);
+	else
+		list_add(&page->lru, &pcp->list);
 	set_page_private(page, get_pageblock_migratetype(page));
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
@@ -1051,7 +1051,7 @@ again:
 		struct per_cpu_pages *pcp;
 
 		local_irq_save(flags);
-		pcp = &THIS_CPU(zone->pageset)->pcp[cold];
+		pcp = &THIS_CPU(zone->pageset)->pcp;
 		if (!pcp->count) {
 			pcp->count = rmqueue_bulk(zone, 0,
 					pcp->batch, &pcp->list, migratetype);
@@ -1060,9 +1060,15 @@ again:
 		}
 
 		/* Find a page of the appropriate migrate type */
-		list_for_each_entry(page, &pcp->list, lru)
-			if (page_private(page) == migratetype)
-				break;
+		if (cold) {
+			list_for_each_entry_reverse(page, &pcp->list, lru)
+				if (page_private(page) == migratetype)
+					break;
+		} else {
+			list_for_each_entry(page, &pcp->list, lru)
+				if (page_private(page) == migratetype)
+					break;
+		}
 
 		/* Allocate more to the pcp list if necessary */
 		if (unlikely(&page->lru == &pcp->list)) {
@@ -1787,12 +1793,9 @@ void show_free_areas(void)
 
 			pageset = CPU_PTR(zone->pageset, cpu);
 
-			printk("CPU %4d: Hot: hi:%5d, btch:%4d usd:%4d   "
-			       "Cold: hi:%5d, btch:%4d usd:%4d\n",
-			       cpu, pageset->pcp[0].high,
-			       pageset->pcp[0].batch, pageset->pcp[0].count,
-			       pageset->pcp[1].high, pageset->pcp[1].batch,
-			       pageset->pcp[1].count);
+			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
+			       cpu, pageset->pcp.high,
+			       pageset->pcp.batch, pageset->pcp.count);
 		}
 	}
 
@@ -2590,17 +2593,11 @@ inline void setup_pageset(struct per_cpu
 
 	memset(p, 0, sizeof(*p));
 
-	pcp = &p->pcp[0];		/* hot */
+	pcp = &p->pcp;
 	pcp->count = 0;
 	pcp->high = 6 * batch;
 	pcp->batch = max(1UL, 1 * batch);
 	INIT_LIST_HEAD(&pcp->list);
-
-	pcp = &p->pcp[1];		/* cold*/
-	pcp->count = 0;
-	pcp->high = 2 * batch;
-	pcp->batch = max(1UL, batch/2);
-	INIT_LIST_HEAD(&pcp->list);
 }
 
 /*
@@ -2613,7 +2610,7 @@ static void setup_pagelist_highmark(stru
 {
 	struct per_cpu_pages *pcp;
 
-	pcp = &p->pcp[0]; /* hot list */
+	pcp = &p->pcp;
 	pcp->high = high;
 	pcp->batch = max(1UL, high/4);
 	if ((high/4) > (PAGE_SHIFT * 8))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
