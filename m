Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D75686B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:42:49 -0400 (EDT)
Message-ID: <0000014035d33307-8a6a3ab4-7d63-40d4-8610-0b1f701a5d05-000000@email.amazonses.com>
Date: Wed, 31 Jul 2013 17:42:48 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 3/3] vmstat: Use this_cpu to avoid irqon/off sequence in refresh_cpu_vm_stats
References: <20130731173202.150701040@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org

Disabling interrupts repeatedly can be avoided in the inner loop if we
use a this_cpu operation.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2013-07-30 13:41:04.567462579 -0500
+++ linux/mm/vmstat.c	2013-07-30 13:49:17.379563161 -0500
@@ -437,33 +437,29 @@ static inline void fold_diff(int *diff)
  * with the global counters. These could cause remote node cache line
  * bouncing and will have to be only done when necessary.
  */
-static void refresh_cpu_vm_stats(int cpu)
+static void refresh_cpu_vm_stats(void)
 {
 	struct zone *zone;
 	int i;
 	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
 
 	for_each_populated_zone(zone) {
-		struct per_cpu_pageset *p;
+		struct per_cpu_pageset __percpu *p = zone->pageset;
 
-		p = per_cpu_ptr(zone->pageset, cpu);
+		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
+			int v;
 
-		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-			if (p->vm_stat_diff[i]) {
-				unsigned long flags;
-				int v;
+			v = this_cpu_xchg(p->vm_stat_diff[i], 0);
+			if (v) {
 
-				local_irq_save(flags);
-				v = p->vm_stat_diff[i];
-				p->vm_stat_diff[i] = 0;
-				local_irq_restore(flags);
 				atomic_long_add(v, &zone->vm_stat[i]);
 				global_diff[i] += v;
 #ifdef CONFIG_NUMA
 				/* 3 seconds idle till flush */
-				p->expire = 3;
+				__this_cpu_write(p->expire, 3);
 #endif
 			}
+		}
 		cond_resched();
 #ifdef CONFIG_NUMA
 		/*
@@ -473,23 +469,24 @@ static void refresh_cpu_vm_stats(int cpu
 		 * Check if there are pages remaining in this pageset
 		 * if not then there is nothing to expire.
 		 */
-		if (!p->expire || !p->pcp.count)
+		if (!__this_cpu_read(p->expire) ||
+			       !__this_cpu_read(p->pcp.count))
 			continue;
 
 		/*
 		 * We never drain zones local to this processor.
 		 */
 		if (zone_to_nid(zone) == numa_node_id()) {
-			p->expire = 0;
+			__this_cpu_write(p->expire, 0);
 			continue;
 		}
 
-		p->expire--;
-		if (p->expire)
+
+		if (__this_cpu_dec_return(p->expire))
 			continue;
 
-		if (p->pcp.count)
-			drain_zone_pages(zone, &p->pcp);
+		if (__this_cpu_read(p->pcp.count))
+			drain_zone_pages(zone, __this_cpu_ptr(&p->pcp));
 #endif
 	}
 	fold_diff(global_diff);
@@ -1209,7 +1206,7 @@ int sysctl_stat_interval __read_mostly =
 
 static void vmstat_update(struct work_struct *w)
 {
-	refresh_cpu_vm_stats(smp_processor_id());
+	refresh_cpu_vm_stats();
 	schedule_delayed_work(&__get_cpu_var(vmstat_work),
 		round_jiffies_relative(sysctl_stat_interval));
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
