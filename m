Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7E7F66B009C
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 15:17:39 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B771C82C2D8
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 16:06:40 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cwIkCj0ISN2u for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 16:06:40 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E860282C6DE
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 16:06:28 -0400 (EDT)
Message-Id: <20091001174121.841905850@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:45 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 12/19] Move early initialization of pagesets out of zone_wait_table_init()
Content-Disposition: inline; filename=this_cpu_move_initialization
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Explicitly initialize the pagesets after the per cpu areas have been
initialized. This is necessary in order to be able to use per cpu
operations in later patches.

Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 arch/ia64/kernel/setup.c       |    1 +
 arch/powerpc/kernel/setup_64.c |    1 +
 arch/sparc/kernel/smp_64.c     |    1 +
 arch/x86/kernel/setup_percpu.c |    2 ++
 include/linux/mm.h             |    1 +
 mm/page_alloc.c                |   40 +++++++++++++++++++++++++++++-----------
 mm/percpu.c                    |    2 ++
 7 files changed, 37 insertions(+), 11 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2009-10-01 08:54:19.000000000 -0500
+++ linux-2.6/mm/page_alloc.c	2009-10-01 09:36:19.000000000 -0500
@@ -3270,23 +3270,42 @@ void zone_pcp_update(struct zone *zone)
 	stop_machine(__zone_pcp_update, zone, NULL);
 }
 
-static __meminit void zone_pcp_init(struct zone *zone)
+/*
+ * Early setup of pagesets.
+ *
+ * In the NUMA case the pageset setup simply results in all zones pcp
+ * pointer being directed at a per cpu pageset with zero batchsize.
+ *
+ * This means that every free and every allocation occurs directly from
+ * the buddy allocator tables.
+ *
+ * The pageset never queues pages during early boot and is therefore usable
+ * for every type of zone.
+ */
+__meminit void setup_pagesets(void)
 {
 	int cpu;
-	unsigned long batch = zone_batchsize(zone);
+	struct zone *zone;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_zone(zone) {
 #ifdef CONFIG_NUMA
-		/* Early boot. Slab allocator not functional yet */
-		zone_pcp(zone, cpu) = &boot_pageset[cpu];
-		setup_pageset(&boot_pageset[cpu],0);
+		unsigned long batch = 0;
+
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			/* Early boot. Slab allocator not functional yet */
+			zone_pcp(zone, cpu) = &boot_pageset[cpu];
+		}
 #else
-		setup_pageset(zone_pcp(zone,cpu), batch);
+		unsigned long batch = zone_batchsize(zone);
 #endif
+
+		for_each_possible_cpu(cpu)
+			setup_pageset(zone_pcp(zone, cpu), batch);
+
+		if (zone->present_pages)
+			printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
+				zone->name, zone->present_pages, batch);
 	}
-	if (zone->present_pages)
-		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
-			zone->name, zone->present_pages, batch);
 }
 
 __meminit int init_currently_empty_zone(struct zone *zone,
@@ -3841,7 +3860,6 @@ static void __paginginit free_area_init_
 
 		zone->prev_priority = DEF_PRIORITY;
 
-		zone_pcp_init(zone);
 		for_each_lru(l) {
 			INIT_LIST_HEAD(&zone->lru[l].list);
 			zone->reclaim_stat.nr_saved_scan[l] = 0;
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2009-10-01 08:54:19.000000000 -0500
+++ linux-2.6/include/linux/mm.h	2009-10-01 09:36:19.000000000 -0500
@@ -1060,6 +1060,7 @@ extern void show_mem(void);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern int after_bootmem;
+extern void setup_pagesets(void);
 
 #ifdef CONFIG_NUMA
 extern void setup_per_cpu_pageset(void);
Index: linux-2.6/arch/ia64/kernel/setup.c
===================================================================
--- linux-2.6.orig/arch/ia64/kernel/setup.c	2009-10-01 08:54:19.000000000 -0500
+++ linux-2.6/arch/ia64/kernel/setup.c	2009-10-01 09:35:39.000000000 -0500
@@ -864,6 +864,7 @@ void __init
 setup_per_cpu_areas (void)
 {
 	/* start_kernel() requires this... */
+	setup_pagesets();
 }
 #endif
 
Index: linux-2.6/arch/powerpc/kernel/setup_64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kernel/setup_64.c	2009-10-01 08:54:19.000000000 -0500
+++ linux-2.6/arch/powerpc/kernel/setup_64.c	2009-10-01 09:35:39.000000000 -0500
@@ -578,6 +578,7 @@ static void ppc64_do_msg(unsigned int sr
 		snprintf(buf, 128, "%s", msg);
 		ppc_md.progress(buf, 0);
 	}
+	setup_pagesets();
 }
 
 /* Print a boot progress message. */
Index: linux-2.6/arch/sparc/kernel/smp_64.c
===================================================================
--- linux-2.6.orig/arch/sparc/kernel/smp_64.c	2009-10-01 08:54:19.000000000 -0500
+++ linux-2.6/arch/sparc/kernel/smp_64.c	2009-10-01 09:35:39.000000000 -0500
@@ -1486,4 +1486,5 @@ void __init setup_per_cpu_areas(void)
 	of_fill_in_cpu_data();
 	if (tlb_type == hypervisor)
 		mdesc_fill_in_cpu_data(cpu_all_mask);
+	setup_pagesets();
 }
Index: linux-2.6/arch/x86/kernel/setup_percpu.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/setup_percpu.c	2009-10-01 08:54:19.000000000 -0500
+++ linux-2.6/arch/x86/kernel/setup_percpu.c	2009-10-01 09:35:39.000000000 -0500
@@ -269,4 +269,6 @@ void __init setup_per_cpu_areas(void)
 
 	/* Setup cpu initialized, callin, callout masks */
 	setup_cpu_local_masks();
+
+	setup_pagesets();
 }
Index: linux-2.6/mm/percpu.c
===================================================================
--- linux-2.6.orig/mm/percpu.c	2009-10-01 08:54:19.000000000 -0500
+++ linux-2.6/mm/percpu.c	2009-10-01 09:35:39.000000000 -0500
@@ -2062,5 +2062,7 @@ void __init setup_per_cpu_areas(void)
 	delta = (unsigned long)pcpu_base_addr - (unsigned long)__per_cpu_start;
 	for_each_possible_cpu(cpu)
 		__per_cpu_offset[cpu] = delta + pcpu_unit_offsets[cpu];
+
+	setup_pagesets();
 }
 #endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
