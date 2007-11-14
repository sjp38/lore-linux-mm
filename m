Date: Wed, 14 Nov 2007 11:52:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Page allocator: Get rid of the list of cold pages
Message-ID: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, apw@shadowen.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

The discussion of the RFC for this and Mel's measurements indicate that 
there may not be too much of a point left to having separate lists for 
hot and cold pages (see http://marc.info/?t=119492914200001&r=1&w=2). I 
think it is worth taking into mm for further testing. This version is 
against 2.6.24-rc2-mm1.


Page allocator: Get rid of the list of cold pages

We have repeatedly discussed if the cold pages still have a point. There is
one way to join the two lists: Use a single list and put the cold pages at the
end and the hot pages at the beginning. That way a single list can serve for
both types of allocations.

[This version against 2.6.24-rc2-mm1]

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mmzone.h |    2 -
 mm/page_alloc.c        |   54 +++++++++++++++++++++++--------------------------
 mm/vmstat.c            |   30 ++++++++++-----------------
 3 files changed, 39 insertions(+), 47 deletions(-)

Index: linux-2.6.24-rc2-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.24-rc2-mm1.orig/include/linux/mmzone.h	2007-11-06 13:57:46.000000000 -0800
+++ linux-2.6.24-rc2-mm1/include/linux/mmzone.h	2007-11-14 11:23:37.597012369 -0800
@@ -113,7 +113,7 @@ struct per_cpu_pages {
 };
 
 struct per_cpu_pageset {
-	struct per_cpu_pages pcp[2];	/* 0: hot.  1: cold */
+	struct per_cpu_pages pcp;
 #ifdef CONFIG_NUMA
 	s8 expire;
 #endif
Index: linux-2.6.24-rc2-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/mm/vmstat.c	2007-11-14 11:10:22.264011944 -0800
+++ linux-2.6.24-rc2-mm1/mm/vmstat.c	2007-11-14 11:31:03.702407648 -0800
@@ -330,7 +330,7 @@ void refresh_cpu_vm_stats(int cpu)
 		 * Check if there are pages remaining in this pageset
 		 * if not then there is nothing to expire.
 		 */
-		if (!p->expire || (!p->pcp[0].count && !p->pcp[1].count))
+		if (!p->expire || !p->pcp.count)
 			continue;
 
 		/*
@@ -345,11 +345,8 @@ void refresh_cpu_vm_stats(int cpu)
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
@@ -774,20 +771,17 @@ static void zoneinfo_show_print(struct s
 		   "\n  pagesets");
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
-		int j;
 
 		pageset = zone_pcp(zone, i);
-		for (j = 0; j < ARRAY_SIZE(pageset->pcp); j++) {
-			seq_printf(m,
-				   "\n    cpu: %i pcp: %i"
-				   "\n              count: %i"
-				   "\n              high:  %i"
-				   "\n              batch: %i",
-				   i, j,
-				   pageset->pcp[j].count,
-				   pageset->pcp[j].high,
-				   pageset->pcp[j].batch);
-			}
+		seq_printf(m,
+			   "\n    cpu: %i"
+			   "\n              count: %i"
+			   "\n              high:  %i"
+			   "\n              batch: %i",
+			   i,
+			   pageset->pcp.count,
+			   pageset->pcp.high,
+			   pageset->pcp.batch);
 #ifdef CONFIG_SMP
 		seq_printf(m, "\n  vm stats threshold: %d",
 				pageset->stat_threshold);
Index: linux-2.6.24-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/mm/page_alloc.c	2007-11-14 11:10:22.220011821 -0800
+++ linux-2.6.24-rc2-mm1/mm/page_alloc.c	2007-11-14 11:28:27.857511982 -0800
@@ -914,20 +914,18 @@ static void drain_pages(unsigned int cpu
 
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset;
+		struct per_cpu_pages *pcp;
 
 		if (!populated_zone(zone))
 			continue;
 
 		pset = zone_pcp(zone, cpu);
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
 
@@ -1003,10 +1001,13 @@ static void fastcall free_hot_cold_page(
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
-	pcp = &zone_pcp(zone, get_cpu())->pcp[cold];
+	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
-	list_add(&page->lru, &pcp->list);
+	if (cold)
+		list_add_tail(&page->lru, &pcp->list);
+	else
+		list_add(&page->lru, &pcp->list);
 	set_page_private(page, get_pageblock_migratetype(page));
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
@@ -1064,7 +1065,7 @@ again:
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 
-		pcp = &zone_pcp(zone, cpu)->pcp[cold];
+		pcp = &zone_pcp(zone, cpu)->pcp;
 		local_irq_save(flags);
 		if (!pcp->count) {
 			pcp->count = rmqueue_bulk(zone, 0,
@@ -1074,9 +1075,15 @@ again:
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
@@ -1863,12 +1870,9 @@ void show_free_areas(void)
 
 			pageset = zone_pcp(zone, cpu);
 
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
 
@@ -2670,17 +2674,11 @@ inline void setup_pageset(struct per_cpu
 
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
@@ -2693,7 +2691,7 @@ static void setup_pagelist_highmark(stru
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
