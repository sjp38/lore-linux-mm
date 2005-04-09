Message-ID: <4257D78F.7020609@yahoo.com.au>
Date: Sat, 09 Apr 2005 23:24:31 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch 3/4] pcp: NULL pagesets
References: <4257D74C.3010703@yahoo.com.au> <4257D779.30801@yahoo.com.au>
In-Reply-To: <4257D779.30801@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------040701090302030005000106"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040701090302030005000106
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

3/4

--------------040701090302030005000106
Content-Type: text/plain;
 name="pcp-null-pagesets.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pcp-null-pagesets.patch"

Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2005-04-09 22:44:48.000000000 +1000
+++ linux-2.6/include/linux/mmzone.h	2005-04-09 22:45:07.000000000 +1000
@@ -128,6 +128,9 @@ struct zone {
 	struct per_cpu_zone_stats stats[NR_CPUS];
 #endif
 
+	/* global pageset for CPUs without private pagesets for this zone */
+	struct per_cpu_pageset	pageset;
+
 	/*
 	 * free areas of different sizes
 	 */
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2005-04-09 22:45:06.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2005-04-09 22:45:07.000000000 +1000
@@ -84,7 +84,6 @@ struct zone_pagesets {
 
 /*
  * List of pointers to per_cpu_pagesets for each zone.
- * XXX: put this comment in a future patch that actually enables NULLs here
  * It is used as a per-CPU set. A value of NULL in any pointer indicates
  * this CPU doesn't have a pageset for this zone, and should use the public
  * pageset.
@@ -363,13 +362,14 @@ static inline void free_pages_check(cons
  */
 static int
 free_pages_bulk(struct zone *zone, int count,
-		struct list_head *list, unsigned int order)
+		struct list_head *list, unsigned int order, const int locked)
 {
-	unsigned long flags;
+	unsigned long flags = 0; /* shut up gcc */
 	struct page *page = NULL;
 	int ret = 0;
 
-	spin_lock_irqsave(&zone->lock, flags);
+	if (likely(!locked))
+		spin_lock_irqsave(&zone->lock, flags);
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 	while (!list_empty(list) && count--) {
@@ -379,7 +379,8 @@ free_pages_bulk(struct zone *zone, int c
 		__free_pages_bulk(page, zone, order);
 		ret++;
 	}
-	spin_unlock_irqrestore(&zone->lock, flags);
+	if (likely(!locked))
+		spin_unlock_irqrestore(&zone->lock, flags);
 	return ret;
 }
 
@@ -402,7 +403,7 @@ void __free_pages_ok(struct page *page, 
 		free_pages_check(__FUNCTION__, page + i);
 	list_add(&page->lru, &list);
 	kernel_map_pages(page, 1<<order, 0);
-	free_pages_bulk(page_zone(page), 1, &list, order);
+	free_pages_bulk(page_zone(page), 1, &list, order, 0);
 }
 
 
@@ -512,14 +513,15 @@ static struct page *__rmqueue(struct zon
  * Returns the number of new pages which were placed at *list.
  */
 static int rmqueue_bulk(struct zone *zone, unsigned int order, 
-			unsigned long count, struct list_head *list)
+		unsigned long count, struct list_head *list, const int locked)
 {
-	unsigned long flags;
+	unsigned long flags = 0; /* shut up gcc */
 	int i;
 	int allocated = 0;
 	struct page *page;
 	
-	spin_lock_irqsave(&zone->lock, flags);
+	if (likely(!locked))
+		spin_lock_irqsave(&zone->lock, flags);
 	for (i = 0; i < count; ++i) {
 		page = __rmqueue(zone, order);
 		if (page == NULL)
@@ -527,7 +529,8 @@ static int rmqueue_bulk(struct zone *zon
 		allocated++;
 		list_add_tail(&page->lru, list);
 	}
-	spin_unlock_irqrestore(&zone->lock, flags);
+	if (likely(!locked))
+		spin_unlock_irqrestore(&zone->lock, flags);
 	return allocated;
 }
 
@@ -541,13 +544,15 @@ static void __drain_pages(unsigned int c
 	/* XXX: this can be a for i = 0 .. TOTAL_ZONES loop */
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset = zone_pageset(zp, zone);
+		if (unlikely(!pset))
+			continue;
 
 		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
 			struct per_cpu_pages *pcp;
 
 			pcp = &pset->pcp[i];
 			pcp->count -= free_pages_bulk(zone, pcp->count,
-						&pcp->list, 0);
+						&pcp->list, 0, 0);
 		}
 	}
 }
@@ -627,9 +632,11 @@ static void FASTCALL(free_hot_cold_page(
 static void fastcall free_hot_cold_page(struct page *page, int cold)
 {
 	struct zone_pagesets *zp;
-	struct zone *zone = page_zone(page);
+	struct per_cpu_pageset *pset;
 	struct per_cpu_pages *pcp;
+	struct zone *zone = page_zone(page);
 	unsigned long flags;
+	int locked = 0;
 
 	arch_free_page(page, 0);
 
@@ -641,12 +648,23 @@ static void fastcall free_hot_cold_page(
 
 	preempt_disable();
 	zp = this_zone_pagesets();
-	pcp = &zone_pageset(zp, zone)->pcp[cold];
-	local_irq_save(flags);
+	pset = zone_pageset(zp, zone);
+	if (unlikely(!pset)) {
+		locked = 1;
+		pset = &zone->pageset;
+		spin_lock_irqsave(&zone->lock, flags);
+	} else
+		local_irq_save(flags);
+	
+	pcp = &pset->pcp[cold];
 	if (pcp->count >= pcp->high)
-		pcp->count -= free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
+		pcp->count -= free_pages_bulk(zone, pcp->batch, &pcp->list,
+						0, locked);
 	list_add(&page->lru, &pcp->list);
 	pcp->count++;
+
+	if (unlikely(locked))
+		spin_unlock(&zone->lock);
 	local_irq_restore(flags);
 	preempt_enable();
 }
@@ -683,22 +701,33 @@ buffered_rmqueue(struct zone *zone, int 
 	int cold = !!(gfp_flags & __GFP_COLD);
 
 	if (order == 0) {
+		int locked = 0;
 		struct zone_pagesets *zp;
+		struct per_cpu_pageset *pset;
 		struct per_cpu_pages *pcp;
 
 		preempt_disable();
 		zp = this_zone_pagesets();
-		pcp = &zone_pageset(zp, zone)->pcp[cold];
+		pset = zone_pageset(zp, zone);
+		if (unlikely(!pset)) {
+			locked = 1;
+			pset = &zone->pageset;
+			spin_lock_irqsave(&zone->lock, flags);
+		} else
+			local_irq_save(flags);
+
+		pcp = &pset->pcp[cold];
 
-		local_irq_save(flags);
 		if (pcp->count <= pcp->low)
 			pcp->count += rmqueue_bulk(zone, 0,
-						pcp->batch, &pcp->list);
+					pcp->batch, &pcp->list, locked);
 		if (pcp->count) {
 			page = list_entry(pcp->list.next, struct page, lru);
 			list_del(&page->lru);
 			pcp->count--;
 		}
+		if (unlikely(locked))
+			spin_unlock(&zone->lock);
 		local_irq_restore(flags);
 		preempt_enable();
 	}
@@ -1266,6 +1295,8 @@ void show_free_areas(void)
 
 			zp = cpu_zone_pagesets(cpu);
 			pageset = zone_pageset(zp, zone);
+			if (!pageset)
+				continue;
 
 			for (temperature = 0; temperature < 2; temperature++)
 				printk("cpu %d %s: low %d, high %d, batch %d\n",
@@ -1545,6 +1576,25 @@ void __init build_all_zonelists(void)
 	cpuset_init_current_mems_allowed();
 }
 
+static void __init init_percpu_pageset(struct per_cpu_pageset *pset, int batch)
+{
+	struct per_cpu_pages *pcp;
+
+	pcp = &pset->pcp[0];	/* hot */
+	pcp->count = 0;
+	pcp->low = 2 * batch;
+	pcp->high = 6 * batch;
+	pcp->batch = 1 * batch;
+	INIT_LIST_HEAD(&pcp->list);
+
+	pcp = &pset->pcp[1];	/* cold */
+	pcp->count = 0;
+	pcp->low = 0;
+	pcp->high = 2 * batch;
+	pcp->batch = 1 * batch;
+	INIT_LIST_HEAD(&pcp->list);
+}
+
 void __init build_percpu_pagelists(void)
 {
 	pg_data_t *pgdat;
@@ -1573,28 +1623,16 @@ void __init build_percpu_pagelists(void)
 			if (batch < 1)
 				batch = 1;
 
+			init_percpu_pageset(&zone->pageset, batch);
 			for (cpu = 0; cpu < NR_CPUS; cpu++) {
 				struct zone_pagesets *zp;
 				struct per_cpu_pageset *pageset;
-				struct per_cpu_pages *pcp;
 			
 				zp = cpu_zone_pagesets(cpu);
 				pageset = alloc_bootmem_node(pgdat, sizeof(*pageset));
+				init_percpu_pageset(pageset, batch);
 				zp->p[NODEZONE(nid, j)] = pageset;
 
-				pcp = &pageset->pcp[0];	/* hot */
-				pcp->count = 0;
-				pcp->low = 2 * batch;
-				pcp->high = 6 * batch;
-				pcp->batch = 1 * batch;
-				INIT_LIST_HEAD(&pcp->list);
-
-				pcp = &pageset->pcp[1];	/* cold */
-				pcp->count = 0;
-				pcp->low = 0;
-				pcp->high = 2 * batch;
-				pcp->batch = 1 * batch;
-				INIT_LIST_HEAD(&pcp->list);
 			}
 			printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
 					zone_names[j], zone->present_pages, batch);

--------------040701090302030005000106--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
