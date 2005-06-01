Date: Wed, 1 Jun 2005 14:47:48 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Remove huge pageset structure by disabling pagesets during
 early boot
Message-ID: <Pine.LNX.4.62.0506011445110.10550@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-ia64@vger.kernel.org
Cc: akpm@osdl.org
List-ID: <linux-mm.kvack.org>

- Remove the potentially huge per_cpu_pageset from __initdata that I 
  introduced with the pageset localization patches. The array
  can reach 48M on some large NUMA machines.
- Allow the page_allocator to operate without pagesets (will be enabled
  when each processor is brought up during boot).
- Do not abort if pageset memory cannot be allocated for a certain zone
  on bootup. Continue without per_cpu_pageset for the zone.
- Do allocation and deallocation of pagesets also on non NUMA machines
  since SMP machines may also support Hotplug.
- Avoid duplication of pageset initialization code.

No pageset structures also means no NUMA statistics during early boot since
both use the same struct.

Patch against 2.6.12-rc5-mm2

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.12-rc5/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc5.orig/mm/page_alloc.c	2005-06-01 14:43:39.000000000 -0700
+++ linux-2.6.12-rc5/mm/page_alloc.c	2005-06-01 14:43:39.000000000 -0700
@@ -70,11 +70,6 @@ EXPORT_SYMBOL(totalram_pages);
 struct zone *zone_table[1 << ZONETABLE_SHIFT];
 EXPORT_SYMBOL(zone_table);
 
-#ifdef CONFIG_NUMA
-static struct per_cpu_pageset
-	pageset_table[MAX_NR_ZONES*MAX_NUMNODES*NR_CPUS] __initdata;
-#endif
-
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
 int min_free_kbytes = 1024;
 
@@ -532,6 +527,8 @@ void drain_remote_pages(void)
 			continue;
 
 		pset = zone->pageset[smp_processor_id()];
+		if (!pset)
+			continue;
 		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
 			struct per_cpu_pages *pcp;
 
@@ -555,6 +552,10 @@ static void __drain_pages(unsigned int c
 		struct per_cpu_pageset *pset;
 
 		pset = zone_pcp(zone, cpu);
+
+		if (!pset)
+			continue;
+
 		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
 			struct per_cpu_pages *pcp;
 
@@ -618,16 +619,22 @@ static void zone_statistics(struct zonel
 	local_irq_save(flags);
 	cpu = smp_processor_id();
 	p = zone_pcp(z,cpu);
-	if (pg == orig) {
-		p->numa_hit++;
-	} else {
-		p->numa_miss++;
-		zone_pcp(zonelist->zones[0], cpu)->numa_foreign++;
+	if (p) {
+		if (pg == orig) {
+			p->numa_hit++;
+		} else {
+			struct per_cpu_pageset *pset;
+
+			p->numa_miss++;
+			pset = zone_pcp(zonelist->zones[0], cpu);
+			if (pset)
+				pset->numa_foreign++;
+		}
+		if (pg == NODE_DATA(numa_node_id()))
+			p->local_node++;
+		else
+			p->other_node++;
 	}
-	if (pg == NODE_DATA(numa_node_id()))
-		p->local_node++;
-	else
-		p->other_node++;
 	local_irq_restore(flags);
 #endif
 }
@@ -639,6 +646,7 @@ static void FASTCALL(free_hot_cold_page(
 static void fastcall free_hot_cold_page(struct page *page, int cold)
 {
 	struct zone *zone = page_zone(page);
+	struct per_cpu_pageset *pset;
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
@@ -649,13 +657,19 @@ static void fastcall free_hot_cold_page(
 	if (PageAnon(page))
 		page->mapping = NULL;
 	free_pages_check(__FUNCTION__, page);
-	pcp = &zone_pcp(zone, get_cpu())->pcp[cold];
-	local_irq_save(flags);
-	if (pcp->count >= pcp->high)
-		pcp->count -= free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
-	list_add(&page->lru, &pcp->list);
-	pcp->count++;
-	local_irq_restore(flags);
+	pset = zone_pcp(zone, get_cpu());
+	if (pset) {
+		pcp = &pset->pcp[cold];
+		local_irq_save(flags);
+		if (pcp->count >= pcp->high)
+			pcp->count -= free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
+		list_add(&page->lru, &pcp->list);
+		pcp->count++;
+		local_irq_restore(flags);
+	} else {
+		INIT_LIST_HEAD(&page->lru);
+		free_pages_bulk(zone, 1, &page->lru, 0);
+	}
 	put_cpu();
 }
 
@@ -692,18 +706,22 @@ buffered_rmqueue(struct zone *zone, int 
 
 	if (order == 0) {
 		struct per_cpu_pages *pcp;
+		struct per_cpu_pageset *pset;
 
-		pcp = &zone_pcp(zone, get_cpu())->pcp[cold];
-		local_irq_save(flags);
-		if (pcp->count <= pcp->low)
-			pcp->count += rmqueue_bulk(zone, 0,
-						pcp->batch, &pcp->list);
-		if (pcp->count) {
-			page = list_entry(pcp->list.next, struct page, lru);
-			list_del(&page->lru);
-			pcp->count--;
+		pset = zone_pcp(zone, get_cpu());
+		if (pset) {
+			pcp = &pset->pcp[cold];
+			local_irq_save(flags);
+			if (pcp->count <= pcp->low)
+				pcp->count += rmqueue_bulk(zone, 0,
+							pcp->batch, &pcp->list);
+			if (pcp->count) {
+				page = list_entry(pcp->list.next, struct page, lru);
+				list_del(&page->lru);
+				pcp->count--;
+			}
+			local_irq_restore(flags);
 		}
-		local_irq_restore(flags);
 		put_cpu();
 	}
 
@@ -1414,6 +1432,9 @@ void show_free_areas(void)
 
 			pageset = zone_pcp(zone, cpu);
 
+			if (!pageset)
+				continue;
+
 			for (temperature = 0; temperature < 2; temperature++)
 				printk("cpu %d %s: low %d, high %d, batch %d used:%d\n",
 					cpu,
@@ -1849,68 +1870,45 @@ static int __devinit zone_batchsize(stru
 	return batch;
 }
 
-#ifdef CONFIG_NUMA
 /*
  * Dynamicaly allocate memory for the
  * per cpu pageset array in struct zone.
  */
 static int __devinit process_zones(int cpu)
 {
-	struct zone *zone, *dzone;
-	int i;
+	struct zone *zone;
 
 	for_each_zone(zone) {
 		struct per_cpu_pageset *npageset = NULL;
+		struct per_cpu_pages *pcp;
+		unsigned long batch;
 
 		npageset = kmalloc_node(sizeof(struct per_cpu_pageset),
 					 GFP_KERNEL, cpu_to_node(cpu));
 		if (!npageset) {
-			zone->pageset[cpu] = NULL;
-			goto bad;
+			printk(KERN_INFO "Unable to allocate pageset for processor %d\n",cpu);
+			continue;
 		}
 
-		if (zone->pageset[cpu]) {
-			memcpy(npageset, zone->pageset[cpu],
-					sizeof(struct per_cpu_pageset));
-
-			/* Relocate lists */
-			for (i = 0; i < 2; i++) {
-				INIT_LIST_HEAD(&npageset->pcp[i].list);
-				list_splice(&zone->pageset[cpu]->pcp[i].list,
-					&npageset->pcp[i].list);
-			}
- 		} else {
-			struct per_cpu_pages *pcp;
-			unsigned long batch;
-
-			batch = zone_batchsize(zone);
+		batch = zone_batchsize(zone);
 
-			pcp = &npageset->pcp[0];		/* hot */
-			pcp->count = 0;
-			pcp->low = 2 * batch;
-			pcp->high = 6 * batch;
-			pcp->batch = 1 * batch;
-			INIT_LIST_HEAD(&pcp->list);
-
-			pcp = &npageset->pcp[1];		/* cold*/
-			pcp->count = 0;
-			pcp->low = 0;
-			pcp->high = 2 * batch;
-			pcp->batch = 1 * batch;
-			INIT_LIST_HEAD(&pcp->list);
-		}
+		pcp = &npageset->pcp[0];		/* hot */
+		pcp->count = 0;
+		pcp->low = 2 * batch;
+		pcp->high = 6 * batch;
+		pcp->batch = 1 * batch;
+		INIT_LIST_HEAD(&pcp->list);
+
+		pcp = &npageset->pcp[1];		/* cold*/
+		pcp->count = 0;
+		pcp->low = 0;
+		pcp->high = 2 * batch;
+		pcp->batch = 1 * batch;
+		INIT_LIST_HEAD(&pcp->list);
 		zone->pageset[cpu] = npageset;
 	}
 
 	return 0;
-bad:
-	for_each_zone(dzone) {
-		if (dzone == zone)
-			break;
-		kfree(dzone->pageset[cpu]);
-		dzone->pageset[cpu] = NULL;
-	}
-	return -ENOMEM;
 }
 
 static int __devinit pageset_cpuup_callback(struct notifier_block *nfb,
@@ -1950,19 +1948,9 @@ struct notifier_block pageset_notifier =
 
 void __init setup_per_cpu_pageset()
 {
-	int err;
-
-	/* Initialize per_cpu_pageset for cpu 0.
-	 * A cpuup callback will do this for every cpu
-	 * as it comes online
-	 */
-	err = process_zones(smp_processor_id());
-	BUG_ON(err);
 	register_cpu_notifier(&pageset_notifier);
 }
 
-#endif
-
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -1974,7 +1962,7 @@ static void __init free_area_init_core(s
 {
 	unsigned long i, j;
 	const unsigned long zone_required_alignment = 1UL << (MAX_ORDER-1);
-	int cpu, nid = pgdat->node_id;
+	int nid = pgdat->node_id;
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 
 	pgdat->nr_zones = 0;
@@ -1984,7 +1972,6 @@ static void __init free_area_init_core(s
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize;
-		unsigned long batch;
 
 		realsize = size = zones_size[j];
 		if (zholes_size)
@@ -2004,36 +1991,14 @@ static void __init free_area_init_core(s
 
 		zone->temp_priority = zone->prev_priority = DEF_PRIORITY;
 
-		batch = zone_batchsize(zone);
-
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			struct per_cpu_pages *pcp;
-#ifdef CONFIG_NUMA
-			struct per_cpu_pageset *pgset;
-			pgset = &pageset_table[nid*MAX_NR_ZONES*NR_CPUS +
-					(j * NR_CPUS) + cpu];
-
-			zone->pageset[cpu] = pgset;
-#else
-			struct per_cpu_pageset *pgset = zone_pcp(zone, cpu);
-#endif
+		/*
+		 * The pagesets may be activated later in boot when the
+		 * slab allocator is fully operational.
+		 */
+		memset(&zone->pageset, 0, sizeof(struct per_cpu_pageset));
 
-			pcp = &pgset->pcp[0];			/* hot */
-			pcp->count = 0;
-			pcp->low = 2 * batch;
-			pcp->high = 6 * batch;
-			pcp->batch = 1 * batch;
-			INIT_LIST_HEAD(&pcp->list);
-
-			pcp = &pgset->pcp[1];			/* cold */
-			pcp->count = 0;
-			pcp->low = 0;
-			pcp->high = 2 * batch;
-			pcp->batch = 1 * batch;
-			INIT_LIST_HEAD(&pcp->list);
-		}
-		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
-				zone_names[j], realsize, batch);
+		printk(KERN_DEBUG "  %s zone: %lu pages\n",
+				zone_names[j], realsize);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
 		zone->nr_scan_active = 0;
@@ -2241,6 +2206,9 @@ static int zoneinfo_show(struct seq_file
 			int j;
 
 			pageset = zone_pcp(zone, i);
+			if (!pageset)
+				continue;
+
 			for (j = 0; j < ARRAY_SIZE(pageset->pcp); j++) {
 				if (pageset->pcp[j].count)
 					break;
Index: linux-2.6.12-rc5/mm/mempolicy.c
===================================================================
--- linux-2.6.12-rc5.orig/mm/mempolicy.c	2005-06-01 13:23:33.000000000 -0700
+++ linux-2.6.12-rc5/mm/mempolicy.c	2005-06-01 14:43:39.000000000 -0700
@@ -739,7 +739,12 @@ static struct page *alloc_page_interleav
 	else
 		page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zl->zones[0]) {
-		zone_pcp(zl->zones[0],get_cpu())->interleave_hit++;
+		struct per_cpu_pageset *pset;
+
+		pset = zone_pcp(zl->zones[0],get_cpu());
+		if (pset) {
+			pset->interleave_hit++;
+		}
 		put_cpu();
 	}
 	return page;
Index: linux-2.6.12-rc5/drivers/base/node.c
===================================================================
--- linux-2.6.12-rc5.orig/drivers/base/node.c	2005-06-01 13:23:33.000000000 -0700
+++ linux-2.6.12-rc5/drivers/base/node.c	2005-06-01 14:43:39.000000000 -0700
@@ -88,12 +88,14 @@ static ssize_t node_read_numastat(struct
 		struct zone *z = &pg->node_zones[i];
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
 			struct per_cpu_pageset *ps = zone_pcp(z,cpu);
-			numa_hit += ps->numa_hit;
-			numa_miss += ps->numa_miss;
-			numa_foreign += ps->numa_foreign;
-			interleave_hit += ps->interleave_hit;
-			local_node += ps->local_node;
-			other_node += ps->other_node;
+			if (ps) {
+				numa_hit += ps->numa_hit;
+				numa_miss += ps->numa_miss;
+				numa_foreign += ps->numa_foreign;
+				interleave_hit += ps->interleave_hit;
+				local_node += ps->local_node;
+				other_node += ps->other_node;
+			}
 		}
 	}
 	return sprintf(buf,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
