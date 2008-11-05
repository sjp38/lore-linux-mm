From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 7/7] cpu alloc: page allocator conversion
Date: Wed, 05 Nov 2008 17:16:41 -0600
Message-ID: <20081105231650.526116017@quilx.com>
References: <20081105231634.133252042@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline; filename=cpu_alloc_page_allocator_conversion
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-Id: linux-mm.kvack.org

Use the new cpu_alloc functionality to avoid per cpu arrays in struct zone.
This drastically reduces the size of struct zone for systems with a large
amounts of processors and allows placement of critical variables of struct
zone in one cacheline even on very large systems.

Another effect is that the pagesets of one processor are placed near one
another. If multiple pagesets from different zones fit into one cacheline
then additional cacheline fetches can be avoided on the hot paths when
allocating memory from multiple zones.

Surprisingly this clears up much of the painful NUMA bringup. Bootstrap
becomes simpler if we use the same scheme for UP, SMP, NUMA. #ifdefs are
reduced and we can drop the zone_pcp macro.

Hotplug handling is also simplified since cpu alloc can bring up and
shut down cpu areas for a specific cpu as a whole. So there is no need to
allocate or free individual pagesets.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/mm.h     |    4 -
 include/linux/mmzone.h |   12 ---
 mm/page_alloc.c        |  162 +++++++++++++++++++------------------------------
 mm/vmstat.c            |   15 ++--
 4 files changed, 74 insertions(+), 119 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2008-11-04 14:39:18.000000000 -0600
+++ linux-2.6/include/linux/mm.h	2008-11-04 14:39:20.000000000 -0600
@@ -1042,11 +1042,7 @@
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern int after_bootmem;
 
-#ifdef CONFIG_NUMA
 extern void setup_per_cpu_pageset(void);
-#else
-static inline void setup_per_cpu_pageset(void) {}
-#endif
 
 /* prio_tree.c */
 void vma_prio_tree_add(struct vm_area_struct *, struct vm_area_struct *old);
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2008-11-04 14:39:18.000000000 -0600
+++ linux-2.6/include/linux/mmzone.h	2008-11-04 14:39:20.000000000 -0600
@@ -182,13 +182,7 @@
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
 
@@ -283,10 +277,8 @@
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
--- linux-2.6.orig/mm/page_alloc.c	2008-11-04 14:39:18.000000000 -0600
+++ linux-2.6/mm/page_alloc.c	2008-11-04 15:32:17.000000000 -0600
@@ -903,7 +903,7 @@
 		if (!populated_zone(zone))
 			continue;
 
-		pset = zone_pcp(zone, cpu);
+		pset = CPU_PTR(zone->pageset, cpu);
 
 		pcp = &pset->pcp;
 		local_irq_save(flags);
@@ -986,7 +986,7 @@
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
-	pcp = &zone_pcp(zone, get_cpu())->pcp;
+	pcp = &THIS_CPU(zone->pageset)->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 	if (cold)
@@ -1000,7 +1000,6 @@
 		pcp->count -= pcp->batch;
 	}
 	local_irq_restore(flags);
-	put_cpu();
 }
 
 void free_hot_page(struct page *page)
@@ -1042,15 +1041,13 @@
 	unsigned long flags;
 	struct page *page;
 	int cold = !!(gfp_flags & __GFP_COLD);
-	int cpu;
 	int migratetype = allocflags_to_migratetype(gfp_flags);
 
 again:
-	cpu  = get_cpu();
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 
-		pcp = &zone_pcp(zone, cpu)->pcp;
+		pcp = &THIS_CPU(zone->pageset)->pcp;
 		local_irq_save(flags);
 		if (!pcp->count) {
 			pcp->count = rmqueue_bulk(zone, 0,
@@ -1090,7 +1087,6 @@
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone);
 	local_irq_restore(flags);
-	put_cpu();
 
 	VM_BUG_ON(bad_range(zone, page));
 	if (prep_new_page(page, order, gfp_flags))
@@ -1099,7 +1095,6 @@
 
 failed:
 	local_irq_restore(flags);
-	put_cpu();
 	return NULL;
 }
 
@@ -1854,7 +1849,7 @@
 		for_each_online_cpu(cpu) {
 			struct per_cpu_pageset *pageset;
 
-			pageset = zone_pcp(zone, cpu);
+			pageset = CPU_PTR(zone->pageset, cpu);
 
 			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
 			       cpu, pageset->pcp.high,
@@ -2714,82 +2709,33 @@
 		pcp->batch = PAGE_SHIFT * 8;
 }
 
-
-#ifdef CONFIG_NUMA
-/*
- * Boot pageset table. One per cpu which is going to be used for all
- * zones and all nodes. The parameters will be set in such a way
- * that an item put on a list will immediately be handed over to
- * the buddy list. This is safe since pageset manipulation is done
- * with interrupts disabled.
- *
- * Some NUMA counter updates may also be caught by the boot pagesets.
- *
- * The boot_pagesets must be kept even after bootup is complete for
- * unused processors and/or zones. They do play a role for bootstrapping
- * hotplugged processors.
- *
- * zoneinfo_show() and maybe other functions do
- * not check if the processor is online before following the pageset pointer.
- * Other parts of the kernel may not check if the zone is available.
- */
-static struct per_cpu_pageset boot_pageset[NR_CPUS];
-
 /*
- * Dynamically allocate memory for the
- * per cpu pageset array in struct zone.
+ * Configure pageset array in struct zone.
  */
-static int __cpuinit process_zones(int cpu)
+static void __cpuinit process_zones(int cpu)
 {
-	struct zone *zone, *dzone;
+	struct zone *zone;
 	int node = cpu_to_node(cpu);
 
 	node_set_state(node, N_CPU);	/* this node has a cpu */
 
 	for_each_zone(zone) {
+		struct per_cpu_pageset *pcp =
+				CPU_PTR(zone->pageset, cpu);
 
 		if (!populated_zone(zone))
 			continue;
 
-		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
-					 GFP_KERNEL, node);
-		if (!zone_pcp(zone, cpu))
-			goto bad;
-
-		setup_pageset(zone_pcp(zone, cpu), zone_batchsize(zone));
+		setup_pageset(pcp, zone_batchsize(zone));
 
 		if (percpu_pagelist_fraction)
-			setup_pagelist_highmark(zone_pcp(zone, cpu),
-			 	(zone->present_pages / percpu_pagelist_fraction));
-	}
+			setup_pagelist_highmark(pcp, zone->present_pages /
+						percpu_pagelist_fraction);
 
-	return 0;
-bad:
-	for_each_zone(dzone) {
-		if (!populated_zone(dzone))
-			continue;
-		if (dzone == zone)
-			break;
-		kfree(zone_pcp(dzone, cpu));
-		zone_pcp(dzone, cpu) = NULL;
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
-		zone_pcp(zone, cpu) = NULL;
 	}
 }
 
+#ifdef CONFIG_SMP
 static int __cpuinit pageset_cpuup_callback(struct notifier_block *nfb,
 		unsigned long action,
 		void *hcpu)
@@ -2800,14 +2746,7 @@
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
+		process_zones(cpu);
 		break;
 	default:
 		break;
@@ -2817,21 +2756,15 @@
 
 static struct notifier_block __cpuinitdata pageset_notifier =
 	{ &pageset_cpuup_callback, NULL, 0 };
+#endif
 
 void __init setup_per_cpu_pageset(void)
 {
-	int err;
-
-	/* Initialize per_cpu_pageset for cpu 0.
-	 * A cpuup callback will do this for every cpu
-	 * as it comes online
-	 */
-	err = process_zones(smp_processor_id());
-	BUG_ON(err);
+	process_zones(smp_processor_id());
+#ifdef CONFIG_SMP
 	register_cpu_notifier(&pageset_notifier);
-}
-
 #endif
+}
 
 static noinline __init_refok
 int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
@@ -2876,23 +2809,35 @@
 	return 0;
 }
 
-static __meminit void zone_pcp_init(struct zone *zone)
+static inline void alloc_pageset(struct zone *zone)
 {
-	int cpu;
 	unsigned long batch = zone_batchsize(zone);
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
-#ifdef CONFIG_NUMA
-		/* Early boot. Slab allocator not functional yet */
-		zone_pcp(zone, cpu) = &boot_pageset[cpu];
-		setup_pageset(&boot_pageset[cpu],0);
-#else
-		setup_pageset(zone_pcp(zone,cpu), batch);
-#endif
-	}
+	zone->pageset = CPU_ALLOC(struct per_cpu_pageset, GFP_KERNEL);
+	setup_pageset(THIS_CPU(zone->pageset), batch);
+}
+/*
+ * Allocate and initialize pcp structures
+ */
+static __meminit void zone_pcp_init(struct zone *zone)
+{
+	if (slab_is_available())
+		alloc_pageset(zone);
 	if (zone->present_pages)
-		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
-			zone->name, zone->present_pages, batch);
+		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%u\n",
+			zone->name, zone->present_pages,
+			zone_batchsize(zone));
+}
+
+/*
+ * Allocate pcp structures that we were unable to allocate during early boot.
+ */
+void __init allocate_pagesets(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone)
+		alloc_pageset(zone);
 }
 
 __meminit int init_currently_empty_zone(struct zone *zone,
@@ -3438,6 +3383,8 @@
 		unsigned long size, realsize, memmap_pages;
 		enum lru_list l;
 
+		printk("+++ Free area init core for zone %p\n", zone);
+
 		size = zone_spanned_pages_in_node(nid, j, zones_size);
 		realsize = size - zone_absent_pages_in_node(nid, j,
 								zholes_size);
@@ -4438,11 +4385,13 @@
 	ret = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
 	if (!write || (ret == -EINVAL))
 		return ret;
-	for_each_zone(zone) {
-		for_each_online_cpu(cpu) {
+	for_each_online_cpu(cpu) {
+		for_each_zone(zone) {
 			unsigned long  high;
+
 			high = zone->present_pages / percpu_pagelist_fraction;
-			setup_pagelist_highmark(zone_pcp(zone, cpu), high);
+			setup_pagelist_highmark(CPU_PTR(zone->pageset, cpu),
+									high);
 		}
 	}
 	return 0;
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2008-11-04 14:39:18.000000000 -0600
+++ linux-2.6/mm/vmstat.c	2008-11-04 14:39:20.000000000 -0600
@@ -143,7 +143,8 @@
 		threshold = calculate_threshold(zone);
 
 		for_each_online_cpu(cpu)
-			zone_pcp(zone, cpu)->stat_threshold = threshold;
+			CPU_PTR(zone->pageset, cpu)->stat_threshold
+							= threshold;
 	}
 }
 
@@ -153,7 +154,8 @@
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
 {
-	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	struct per_cpu_pageset *pcp = THIS_CPU(zone->pageset);
+
 	s8 *p = pcp->vm_stat_diff + item;
 	long x;
 
@@ -206,7 +208,7 @@
  */
 void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	struct per_cpu_pageset *pcp = THIS_CPU(zone->pageset);
 	s8 *p = pcp->vm_stat_diff + item;
 
 	(*p)++;
@@ -227,7 +229,7 @@
 
 void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	struct per_cpu_pageset *pcp = THIS_CPU(zone->pageset);
 	s8 *p = pcp->vm_stat_diff + item;
 
 	(*p)--;
@@ -307,7 +309,7 @@
 		if (!populated_zone(zone))
 			continue;
 
-		p = zone_pcp(zone, cpu);
+		p = CPU_PTR(zone->pageset, cpu);
 
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 			if (p->vm_stat_diff[i]) {
@@ -759,7 +761,7 @@
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
 
-		pageset = zone_pcp(zone, i);
+		pageset = CPU_PTR(zone->pageset, i);
 		seq_printf(m,
 			   "\n    cpu: %i"
 			   "\n              count: %i"
Index: linux-2.6/mm/cpu_alloc.c
===================================================================
--- linux-2.6.orig/mm/cpu_alloc.c	2008-11-04 15:26:36.000000000 -0600
+++ linux-2.6/mm/cpu_alloc.c	2008-11-04 15:26:45.000000000 -0600
@@ -189,6 +189,8 @@
 
 void __init cpu_alloc_init(void)
 {
+	extern void allocate_pagesets(void);
+
 #ifdef CONFIG_SMP
 	base_percpu_in_units = (__per_cpu_end - __per_cpu_start
 					+ UNIT_SIZE - 1) / UNIT_SIZE;
@@ -199,5 +201,7 @@
 #ifndef CONFIG_SMP
 	cpu_alloc_start = alloc_bootmem(nr_units * UNIT_SIZE);
 #endif
+	/* Allocate pagesets whose allocation was deferred */
+	allocate_pagesets();
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
