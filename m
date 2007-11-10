Date: Fri, 9 Nov 2007 18:39:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Vmstat: Small revisions to refresh_cpu_vm_stats()
Message-ID: <Pine.LNX.4.64.0711091837390.18567@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

1. Add comments explaining how the function can be called.

2. Avoid interrupt enable / disable through the use of xchg.

3. Collect global diffs in a local array and only spill
   them once into the global counters when the zone scan
   is finished. This means that we only touch each global
   counter once instead of each time we fold cpu counters
   into zone counters.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmstat.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2007-11-08 21:57:36.230699984 -0800
+++ linux-2.6/mm/vmstat.c	2007-11-08 21:58:09.397700022 -0800
@@ -287,6 +287,10 @@ EXPORT_SYMBOL(dec_zone_page_state);
 /*
  * Update the zone counters for one cpu.
  *
+ * The cpu specified must be either the current cpu or a processor that
+ * is not online. If it is the current cpu then the execution thread must
+ * be pinned to the current cpu.
+ *
  * Note that refresh_cpu_vm_stats strives to only access
  * node local memory. The per cpu pagesets on remote zones are placed
  * in the memory local to the processor using that pageset. So the
@@ -302,7 +306,7 @@ void refresh_cpu_vm_stats(int cpu)
 {
 	struct zone *zone;
 	int i;
-	unsigned long flags;
+	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
 
 	for_each_zone(zone) {
 		struct per_cpu_pageset *p;
@@ -314,15 +318,14 @@ void refresh_cpu_vm_stats(int cpu)
 
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 			if (p->vm_stat_diff[i]) {
-				local_irq_save(flags);
-				zone_page_state_add(p->vm_stat_diff[i],
-					zone, i);
-				p->vm_stat_diff[i] = 0;
+				int v = xchg(&p->vm_stat_diff[i], 0);
+
+				atomic_long_add(v, &zone->vm_stat[i]);
+				global_diff[i] += v;
 #ifdef CONFIG_NUMA
 				/* 3 seconds idle till flush */
 				p->expire = 3;
 #endif
-				local_irq_restore(flags);
 			}
 #ifdef CONFIG_NUMA
 		/*
@@ -354,6 +357,10 @@ void refresh_cpu_vm_stats(int cpu)
 			drain_zone_pages(zone, p->pcp + 1);
 #endif
 	}
+
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		if (global_diff[i])
+			atomic_long_add(global_diff[i], &vm_stat[i]);
 }
 
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
