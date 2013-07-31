Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 36DEC6B0037
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:32:11 -0400 (EDT)
Message-ID: <0000014035c9719b-5fe4aee8-6924-4bff-92d9-a8775f23b1ee-000000@email.amazonses.com>
Date: Wed, 31 Jul 2013 17:32:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 1/3] vmstat: Create separate function to fold per cpu diffs into glocal counters.
References: <20130731173202.150701040@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org

It is better to have a separate folding function because refresh_cpu_vm_stats()
also does other things like expire pages in the page allocator caches.

If we have a separate function then refresh_cpu_vm_stats() is only
called from the local cpu which allows additional optimizations.

The folding function is only called when a cpu is being downed and
therefore no other processor will be accessing the counters. Also
simplifies synchronization.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/vmstat.h
===================================================================
--- linux.orig/include/linux/vmstat.h	2013-07-26 10:36:41.547909803 -0500
+++ linux/include/linux/vmstat.h	2013-07-26 10:36:41.543909722 -0500
@@ -198,7 +198,7 @@ extern void __inc_zone_state(struct zone
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
-void refresh_cpu_vm_stats(int);
+void cpu_vm_stats_fold(int);
 void refresh_zone_stat_thresholds(void);
 
 void drain_zonestat(struct zone *zone, struct per_cpu_pageset *);
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2013-07-26 10:36:41.547909803 -0500
+++ linux/mm/page_alloc.c	2013-07-26 10:36:41.547909803 -0500
@@ -5361,7 +5361,7 @@ static int page_alloc_cpu_notify(struct
 		 * This is only okay since the processor is dead and cannot
 		 * race with what we are doing.
 		 */
-		refresh_cpu_vm_stats(cpu);
+		cpu_vm_stats_fold(cpu);
 	}
 	return NOTIFY_OK;
 }
Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2013-07-26 10:36:41.547909803 -0500
+++ linux/mm/vmstat.c	2013-07-26 10:36:58.328247861 -0500
@@ -415,11 +415,7 @@ EXPORT_SYMBOL(dec_zone_page_state);
 #endif
 
 /*
- * Update the zone counters for one cpu.
- *
- * The cpu specified must be either the current cpu or a processor that
- * is not online. If it is the current cpu then the execution thread must
- * be pinned to the current cpu.
+ * Update the zone counters for the current cpu.
  *
  * Note that refresh_cpu_vm_stats strives to only access
  * node local memory. The per cpu pagesets on remote zones are placed
@@ -432,7 +428,7 @@ EXPORT_SYMBOL(dec_zone_page_state);
  * with the global counters. These could cause remote node cache line
  * bouncing and will have to be only done when necessary.
  */
-void refresh_cpu_vm_stats(int cpu)
+static void refresh_cpu_vm_stats(int cpu)
 {
 	struct zone *zone;
 	int i;
@@ -489,6 +485,38 @@ void refresh_cpu_vm_stats(int cpu)
 	}
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		if (global_diff[i])
+			atomic_long_add(global_diff[i], &vm_stat[i]);
+}
+
+/*
+ * Fold the data for an offline cpu into the global array.
+ * There cannot be any access by the offline cpu and therefore
+ * synchronization is simplified.
+ */
+void cpu_vm_stats_fold(int cpu)
+{
+	struct zone *zone;
+	int i;
+	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+
+	for_each_populated_zone(zone) {
+		struct per_cpu_pageset *p;
+
+		p = per_cpu_ptr(zone->pageset, cpu);
+
+		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+			if (p->vm_stat_diff[i]) {
+				int v;
+
+				v = p->vm_stat_diff[i];
+				p->vm_stat_diff[i] = 0;
+				atomic_long_add(v, &zone->vm_stat[i]);
+				global_diff[i] += v;
+			}
+	}
+
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		if (global_diff[i])
 			atomic_long_add(global_diff[i], &vm_stat[i]);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
