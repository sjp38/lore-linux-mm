Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B4B3A6B004D
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 23:58:50 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2EA5C82C7EF
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 00:06:46 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Qu3V9-gC9Z5c for <linux-mm@kvack.org>;
	Fri,  2 Oct 2009 00:06:36 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 805A982C7D4
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 00:06:32 -0400 (EDT)
Message-Id: <20091001174122.031855401@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:46 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 13/19] this_cpu_ops: page allocator conversion
Content-Disposition: inline; filename=this_cpu_page_allocator
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Use the per cpu allocator functionality to avoid per cpu arrays in struct zone.

This drastically reduces the size of struct zone for systems with large
amounts of processors and allows placement of critical variables of struct
zone in one cacheline even on very large systems.

Another effect is that the pagesets of one processor are placed near one
another. If multiple pagesets from different zones fit into one cacheline
then additional cacheline fetches can be avoided on the hot paths when
allocating memory from multiple zones.

Bootstrap becomes simpler if we use the same scheme for UP, SMP, NUMA. #ifdefs
are reduced and we can drop the zone_pcp macro.

Hotplug handling is also simplified since cpu alloc can bring up and
shut down cpu areas for a specific cpu as a whole. So there is no need to
allocate or free individual pagesets.

Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/mm.h     |    4 -
 include/linux/mmzone.h |   12 ---
 mm/page_alloc.c        |  156 ++++++++++++++-----------------------------------
 mm/vmstat.c            |   14 ++--
 4 files changed, 55 insertions(+), 131 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2009-09-29 09:30:37.000000000 -0500
+++ linux-2.6/include/linux/mm.h	2009-09-29 09:30:39.000000000 -0500
@@ -1062,11 +1062,7 @@ extern void si_meminfo_node(struct sysin
 extern int after_bootmem;
 extern void setup_pagesets(void);
 
-#ifdef CONFIG_NUMA
 extern void setup_per_cpu_pageset(void);
-#else
-static inline void setup_per_cpu_pageset(void) {}
-#endif
 
 extern void zone_pcp_update(struct zone *zone);
 
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2009-09-29 09:30:25.000000000 -0500
+++ linux-2.6/include/linux/mmzone.h	2009-09-29 09:30:39.000000000 -0500
@@ -184,13 +184,7 @@ struct per_cpu_pageset {
 	s8 stat_threshold;
 	s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
 #endif
-} ____cacheline_aligned_in_smp;
-
-#ifdef CONFIG_NUMA
-#define zone_pcp(__z, __cpu) ((__z)->pageset[(__cpu)])
-#else
-#define zone_pcp(__z, __cpu) (&(__z)->pageset[(__cpu)])
-#endif
+};
 
 #endif /* !__GENERATING_BOUNDS.H */
 
@@ -306,10 +300,8 @@ struct zone {
 	 */
 	unsigned long		min_unmapped_pages;
 	unsigned long		min_slab_pages;
-	struct per_cpu_pageset	*pageset[NR_CPUS];
-#else
-	struct per_cpu_pageset	pageset[NR_CPUS];
 #endif
+	struct per_cpu_pageset	*pageset;
 	/*
 	 * free areas of different sizes
 	 */
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2009-09-29 09:30:37.000000000 -0500
+++ linux-2.6/mm/page_alloc.c	2009-09-29 09:30:50.000000000 -0500
@@ -1011,7 +1011,7 @@ static void drain_pages(unsigned int cpu
 		struct per_cpu_pageset *pset;
 		struct per_cpu_pages *pcp;
 
-		pset = zone_pcp(zone, cpu);
+		pset = per_cpu_ptr(zone->pageset, cpu);
 
 		pcp = &pset->pcp;
 		local_irq_save(flags);
@@ -1098,7 +1098,7 @@ static void free_hot_cold_page(struct pa
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
-	pcp = &zone_pcp(zone, get_cpu())->pcp;
+	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	migratetype = get_pageblock_migratetype(page);
 	set_page_private(page, migratetype);
 	local_irq_save(flags);
@@ -1133,7 +1133,6 @@ static void free_hot_cold_page(struct pa
 
 out:
 	local_irq_restore(flags);
-	put_cpu();
 }
 
 void free_hot_page(struct page *page)
@@ -1183,15 +1182,13 @@ struct page *buffered_rmqueue(struct zon
 	unsigned long flags;
 	struct page *page;
 	int cold = !!(gfp_flags & __GFP_COLD);
-	int cpu;
 
 again:
-	cpu  = get_cpu();
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 		struct list_head *list;
 
-		pcp = &zone_pcp(zone, cpu)->pcp;
+		pcp = &this_cpu_ptr(zone->pageset)->pcp;
 		list = &pcp->lists[migratetype];
 		local_irq_save(flags);
 		if (list_empty(list)) {
@@ -1234,7 +1231,6 @@ again:
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone);
 	local_irq_restore(flags);
-	put_cpu();
 
 	VM_BUG_ON(bad_range(zone, page));
 	if (prep_new_page(page, order, gfp_flags))
@@ -1243,7 +1239,6 @@ again:
 
 failed:
 	local_irq_restore(flags);
-	put_cpu();
 	return NULL;
 }
 
@@ -2172,7 +2167,7 @@ void show_free_areas(void)
 		for_each_online_cpu(cpu) {
 			struct per_cpu_pageset *pageset;
 
-			pageset = zone_pcp(zone, cpu);
+			pageset = per_cpu_ptr(zone->pageset, cpu);
 
 			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
 			       cpu, pageset->pcp.high,
@@ -3087,7 +3082,6 @@ static void setup_pagelist_highmark(stru
 }
 
 
-#ifdef CONFIG_NUMA
 /*
  * Boot pageset table. One per cpu which is going to be used for all
  * zones and all nodes. The parameters will be set in such a way
@@ -3095,112 +3089,67 @@ static void setup_pagelist_highmark(stru
  * the buddy list. This is safe since pageset manipulation is done
  * with interrupts disabled.
  *
- * Some NUMA counter updates may also be caught by the boot pagesets.
- *
- * The boot_pagesets must be kept even after bootup is complete for
- * unused processors and/or zones. They do play a role for bootstrapping
- * hotplugged processors.
+ * Some counter updates may also be caught by the boot pagesets.
  *
  * zoneinfo_show() and maybe other functions do
  * not check if the processor is online before following the pageset pointer.
  * Other parts of the kernel may not check if the zone is available.
  */
-static struct per_cpu_pageset boot_pageset[NR_CPUS];
-
-/*
- * Dynamically allocate memory for the
- * per cpu pageset array in struct zone.
- */
-static int __cpuinit process_zones(int cpu)
-{
-	struct zone *zone, *dzone;
-	int node = cpu_to_node(cpu);
-
-	node_set_state(node, N_CPU);	/* this node has a cpu */
-
-	for_each_populated_zone(zone) {
-		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
-					 GFP_KERNEL, node);
-		if (!zone_pcp(zone, cpu))
-			goto bad;
-
-		setup_pageset(zone_pcp(zone, cpu), zone_batchsize(zone));
-
-		if (percpu_pagelist_fraction)
-			setup_pagelist_highmark(zone_pcp(zone, cpu),
-			 	(zone->present_pages / percpu_pagelist_fraction));
-	}
-
-	return 0;
-bad:
-	for_each_zone(dzone) {
-		if (!populated_zone(dzone))
-			continue;
-		if (dzone == zone)
-			break;
-		kfree(zone_pcp(dzone, cpu));
-		zone_pcp(dzone, cpu) = &boot_pageset[cpu];
-	}
-	return -ENOMEM;
-}
-
-static inline void free_zone_pagesets(int cpu)
-{
-	struct zone *zone;
-
-	for_each_zone(zone) {
-		struct per_cpu_pageset *pset = zone_pcp(zone, cpu);
-
-		/* Free per_cpu_pageset if it is slab allocated */
-		if (pset != &boot_pageset[cpu])
-			kfree(pset);
-		zone_pcp(zone, cpu) = &boot_pageset[cpu];
-	}
-}
+static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
 
 static int __cpuinit pageset_cpuup_callback(struct notifier_block *nfb,
 		unsigned long action,
 		void *hcpu)
 {
 	int cpu = (long)hcpu;
-	int ret = NOTIFY_OK;
 
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		if (process_zones(cpu))
-			ret = NOTIFY_BAD;
-		break;
-	case CPU_UP_CANCELED:
-	case CPU_UP_CANCELED_FROZEN:
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		free_zone_pagesets(cpu);
+		node_set_state(cpu_to_node(cpu), N_CPU);
 		break;
 	default:
 		break;
 	}
-	return ret;
+	return NOTIFY_OK;
 }
 
 static struct notifier_block __cpuinitdata pageset_notifier =
 	{ &pageset_cpuup_callback, NULL, 0 };
 
+/*
+ * Allocate per cpu pagesets and initialize them.
+ * Before this call only boot pagesets were available.
+ * Boot pagesets will no longer be used after this call is complete.
+ */
 void __init setup_per_cpu_pageset(void)
 {
-	int err;
+	struct zone *zone;
+	int cpu;
+
+	for_each_populated_zone(zone) {
+		zone->pageset = alloc_percpu(struct per_cpu_pageset);
 
-	/* Initialize per_cpu_pageset for cpu 0.
-	 * A cpuup callback will do this for every cpu
-	 * as it comes online
+		for_each_possible_cpu(cpu) {
+			struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
+
+			setup_pageset(pcp, zone_batchsize(zone));
+
+			if (percpu_pagelist_fraction)
+				setup_pagelist_highmark(pcp,
+					(zone->present_pages /
+						percpu_pagelist_fraction));
+		}
+	}
+
+	/*
+	 * The boot cpu is always the first active.
+	 * The boot node has a processor
 	 */
-	err = process_zones(smp_processor_id());
-	BUG_ON(err);
+	node_set_state(cpu_to_node(smp_processor_id()), N_CPU);
 	register_cpu_notifier(&pageset_notifier);
 }
 
-#endif
-
 static noinline __init_refok
 int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 {
@@ -3254,7 +3203,7 @@ static int __zone_pcp_update(void *data)
 		struct per_cpu_pageset *pset;
 		struct per_cpu_pages *pcp;
 
-		pset = zone_pcp(zone, cpu);
+		pset = per_cpu_ptr(zone->pageset, cpu);
 		pcp = &pset->pcp;
 
 		local_irq_save(flags);
@@ -3272,15 +3221,7 @@ void zone_pcp_update(struct zone *zone)
 
 /*
  * Early setup of pagesets.
- *
- * In the NUMA case the pageset setup simply results in all zones pcp
- * pointer being directed at a per cpu pageset with zero batchsize.
- *
- * This means that every free and every allocation occurs directly from
- * the buddy allocator tables.
- *
- * The pageset never queues pages during early boot and is therefore usable
- * for every type of zone.
+ * At this point various allocators are not operational yet.
  */
 __meminit void setup_pagesets(void)
 {
@@ -3288,23 +3229,15 @@ __meminit void setup_pagesets(void)
 	struct zone *zone;
 
 	for_each_zone(zone) {
-#ifdef CONFIG_NUMA
-		unsigned long batch = 0;
-
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			/* Early boot. Slab allocator not functional yet */
-			zone_pcp(zone, cpu) = &boot_pageset[cpu];
-		}
-#else
-		unsigned long batch = zone_batchsize(zone);
-#endif
+		zone->pageset = &per_cpu_var(boot_pageset);
 
+		/*
+		 * Special pagesets with zero elements so that frees
+		 * and allocations are not buffered at all.
+		 */
 		for_each_possible_cpu(cpu)
-			setup_pageset(zone_pcp(zone, cpu), batch);
+			setup_pageset(per_cpu_ptr(zone->pageset, cpu), 0);
 
-		if (zone->present_pages)
-			printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
-				zone->name, zone->present_pages, batch);
 	}
 }
 
@@ -4818,10 +4751,11 @@ int percpu_pagelist_fraction_sysctl_hand
 	if (!write || (ret == -EINVAL))
 		return ret;
 	for_each_populated_zone(zone) {
-		for_each_online_cpu(cpu) {
+		for_each_possible_cpu(cpu) {
 			unsigned long  high;
 			high = zone->present_pages / percpu_pagelist_fraction;
-			setup_pagelist_highmark(zone_pcp(zone, cpu), high);
+			setup_pagelist_highmark(
+				per_cpu_ptr(zone->pageset, cpu), high);
 		}
 	}
 	return 0;
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2009-09-29 09:30:25.000000000 -0500
+++ linux-2.6/mm/vmstat.c	2009-09-29 09:30:43.000000000 -0500
@@ -139,7 +139,8 @@ static void refresh_zone_stat_thresholds
 		threshold = calculate_threshold(zone);
 
 		for_each_online_cpu(cpu)
-			zone_pcp(zone, cpu)->stat_threshold = threshold;
+			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
+							= threshold;
 	}
 }
 
@@ -149,7 +150,8 @@ static void refresh_zone_stat_thresholds
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
 {
-	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
+
 	s8 *p = pcp->vm_stat_diff + item;
 	long x;
 
@@ -202,7 +204,7 @@ EXPORT_SYMBOL(mod_zone_page_state);
  */
 void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
 	s8 *p = pcp->vm_stat_diff + item;
 
 	(*p)++;
@@ -223,7 +225,7 @@ EXPORT_SYMBOL(__inc_zone_page_state);
 
 void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
 	s8 *p = pcp->vm_stat_diff + item;
 
 	(*p)--;
@@ -300,7 +302,7 @@ void refresh_cpu_vm_stats(int cpu)
 	for_each_populated_zone(zone) {
 		struct per_cpu_pageset *p;
 
-		p = zone_pcp(zone, cpu);
+		p = per_cpu_ptr(zone->pageset, cpu);
 
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 			if (p->vm_stat_diff[i]) {
@@ -738,7 +740,7 @@ static void zoneinfo_show_print(struct s
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
 
-		pageset = zone_pcp(zone, i);
+		pageset = per_cpu_ptr(zone->pageset, i);
 		seq_printf(m,
 			   "\n    cpu: %i"
 			   "\n              count: %i"

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
