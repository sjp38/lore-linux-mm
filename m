Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF416B0277
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:02:24 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id s9so12441886pfe.20
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 22:02:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o5si25144435plh.477.2017.11.27.22.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 22:02:22 -0800 (PST)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
Date: Tue, 28 Nov 2017 14:00:23 +0800
Message-Id: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Kemi Wang <kemi.wang@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

The existed implementation of NUMA counters is per logical CPU along with
zone->vm_numa_stat[] separated by zone, plus a global numa counter array
vm_numa_stat[]. However, unlike the other vmstat counters, numa stats don't
effect system's decision and are only read from /proc and /sys, it is a
slow path operation and likely tolerate higher overhead. Additionally,
usually nodes only have a single zone, except for node 0. And there isn't
really any use where you need these hits counts separated by zone.

Therefore, we can migrate the implementation of numa stats from per-zone to
per-node, and get rid of these global numa counters. It's good enough to
keep everything in a per cpu ptr of type u64, and sum them up when need, as
suggested by Andi Kleen. That's helpful for code cleanup and enhancement
(e.g. save more than 130+ lines code).

With this patch, we can see 1.8%(335->329) drop of CPU cycles for single
page allocation and deallocation concurrently with 112 threads tested on a
2-sockets skylake platform using Jesper's page_bench03 benchmark.

Benchmark provided by Jesper D Brouer(increase loop times to 10000000):
https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
bench

Also, it does not cause obvious latency increase when read /proc and /sys
on a 2-sockets skylake platform. Latency shown by time command:
                           base             head
/proc/vmstat            sys 0m0.001s     sys 0m0.001s

/sys/devices/system/    sys 0m0.001s     sys 0m0.000s
node/node*/numastat

We would not worry it much as it is a slow path and will not be read
frequently.

Suggested-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 drivers/base/node.c    |  14 ++---
 include/linux/mmzone.h |   2 -
 include/linux/vmstat.h |  61 +++++++++---------
 mm/page_alloc.c        |   7 +++
 mm/vmstat.c            | 167 ++++---------------------------------------------
 5 files changed, 56 insertions(+), 195 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index ee090ab..0be5fbd 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -169,12 +169,12 @@ static ssize_t node_read_numastat(struct device *dev,
 		       "interleave_hit %lu\n"
 		       "local_node %lu\n"
 		       "other_node %lu\n",
-		       sum_zone_numa_state(dev->id, NUMA_HIT),
-		       sum_zone_numa_state(dev->id, NUMA_MISS),
-		       sum_zone_numa_state(dev->id, NUMA_FOREIGN),
-		       sum_zone_numa_state(dev->id, NUMA_INTERLEAVE_HIT),
-		       sum_zone_numa_state(dev->id, NUMA_LOCAL),
-		       sum_zone_numa_state(dev->id, NUMA_OTHER));
+		       node_numa_state_snapshot(dev->id, NUMA_HIT),
+		       node_numa_state_snapshot(dev->id, NUMA_MISS),
+		       node_numa_state_snapshot(dev->id, NUMA_FOREIGN),
+		       node_numa_state_snapshot(dev->id, NUMA_INTERLEAVE_HIT),
+		       node_numa_state_snapshot(dev->id, NUMA_LOCAL),
+		       node_numa_state_snapshot(dev->id, NUMA_OTHER));
 }
 static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
@@ -194,7 +194,7 @@ static ssize_t node_read_vmstat(struct device *dev,
 	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
 		n += sprintf(buf+n, "%s %lu\n",
 			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-			     sum_zone_numa_state(nid, i));
+			     node_numa_state_snapshot(nid, i));
 #endif
 
 	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 67f2e3c..b2d264f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -283,7 +283,6 @@ struct per_cpu_pageset {
 	struct per_cpu_pages pcp;
 #ifdef CONFIG_NUMA
 	s8 expire;
-	u16 vm_numa_stat_diff[NR_VM_NUMA_STAT_ITEMS];
 #endif
 #ifdef CONFIG_SMP
 	s8 stat_threshold;
@@ -504,7 +503,6 @@ struct zone {
 	ZONE_PADDING(_pad3_)
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
-	atomic_long_t		vm_numa_stat[NR_VM_NUMA_STAT_ITEMS];
 } ____cacheline_internodealigned_in_smp;
 
 enum pgdat_flags {
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 1779c98..7383d66 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -118,36 +118,8 @@ static inline void vm_events_fold_cpu(int cpu)
  * Zone and node-based page accounting with per cpu differentials.
  */
 extern atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS];
-extern atomic_long_t vm_numa_stat[NR_VM_NUMA_STAT_ITEMS];
 extern atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS];
-
-#ifdef CONFIG_NUMA
-static inline void zone_numa_state_add(long x, struct zone *zone,
-				 enum numa_stat_item item)
-{
-	atomic_long_add(x, &zone->vm_numa_stat[item]);
-	atomic_long_add(x, &vm_numa_stat[item]);
-}
-
-static inline unsigned long global_numa_state(enum numa_stat_item item)
-{
-	long x = atomic_long_read(&vm_numa_stat[item]);
-
-	return x;
-}
-
-static inline unsigned long zone_numa_state_snapshot(struct zone *zone,
-					enum numa_stat_item item)
-{
-	long x = atomic_long_read(&zone->vm_numa_stat[item]);
-	int cpu;
-
-	for_each_online_cpu(cpu)
-		x += per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item];
-
-	return x;
-}
-#endif /* CONFIG_NUMA */
+extern u64 __percpu *vm_numa_stat;
 
 static inline void zone_page_state_add(long x, struct zone *zone,
 				 enum zone_stat_item item)
@@ -234,10 +206,39 @@ static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
 
 
 #ifdef CONFIG_NUMA
+static inline unsigned long zone_numa_state_snapshot(struct zone *zone,
+					enum numa_stat_item item)
+{
+	return 0;
+}
+
+static inline unsigned long node_numa_state_snapshot(int node,
+					enum numa_stat_item item)
+{
+	unsigned long x = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		x += per_cpu_ptr(vm_numa_stat, cpu)[(node *
+				NR_VM_NUMA_STAT_ITEMS) + item];
+
+	return x;
+}
+
+static inline unsigned long global_numa_state(enum numa_stat_item item)
+{
+	int node;
+	unsigned long x = 0;
+
+	for_each_online_node(node)
+		x += node_numa_state_snapshot(node, item);
+
+	return x;
+}
+
 extern void __inc_numa_state(struct zone *zone, enum numa_stat_item item);
 extern unsigned long sum_zone_node_page_state(int node,
 					      enum zone_stat_item item);
-extern unsigned long sum_zone_numa_state(int node, enum numa_stat_item item);
 extern unsigned long node_page_state(struct pglist_data *pgdat,
 						enum node_stat_item item);
 #else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d4096f4..142e1ba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5564,6 +5564,7 @@ void __init setup_per_cpu_pageset(void)
 {
 	struct pglist_data *pgdat;
 	struct zone *zone;
+	size_t size, align;
 
 	for_each_populated_zone(zone)
 		setup_zone_pageset(zone);
@@ -5571,6 +5572,12 @@ void __init setup_per_cpu_pageset(void)
 	for_each_online_pgdat(pgdat)
 		pgdat->per_cpu_nodestats =
 			alloc_percpu(struct per_cpu_nodestat);
+
+#ifdef CONFIG_NUMA
+	size = sizeof(u64) * num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS;
+	align = __alignof__(u64[num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS]);
+	vm_numa_stat = (u64 __percpu *)__alloc_percpu(size, align);
+#endif
 }
 
 static __meminit void zone_pcp_init(struct zone *zone)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2db6..bbabd96 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -30,48 +30,20 @@
 
 #include "internal.h"
 
-#define NUMA_STATS_THRESHOLD (U16_MAX - 2)
-
 #ifdef CONFIG_NUMA
 int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
 
-/* zero numa counters within a zone */
-static void zero_zone_numa_counters(struct zone *zone)
+static void invalid_numa_statistics(void)
 {
-	int item, cpu;
+	int i, cpu;
 
-	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++) {
-		atomic_long_set(&zone->vm_numa_stat[item], 0);
-		for_each_online_cpu(cpu)
-			per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item]
-						= 0;
+	for_each_possible_cpu(cpu) {
+		for (i = 0; i < num_possible_nodes() *
+				NR_VM_NUMA_STAT_ITEMS; i++)
+			per_cpu_ptr(vm_numa_stat, cpu)[i] = 0;
 	}
 }
 
-/* zero numa counters of all the populated zones */
-static void zero_zones_numa_counters(void)
-{
-	struct zone *zone;
-
-	for_each_populated_zone(zone)
-		zero_zone_numa_counters(zone);
-}
-
-/* zero global numa counters */
-static void zero_global_numa_counters(void)
-{
-	int item;
-
-	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++)
-		atomic_long_set(&vm_numa_stat[item], 0);
-}
-
-static void invalid_numa_statistics(void)
-{
-	zero_zones_numa_counters();
-	zero_global_numa_counters();
-}
-
 static DEFINE_MUTEX(vm_numa_stat_lock);
 
 int sysctl_vm_numa_stat_handler(struct ctl_table *table, int write,
@@ -160,12 +132,12 @@ void vm_events_fold_cpu(int cpu)
  * vm_stat contains the global counters
  */
 atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
-atomic_long_t vm_numa_stat[NR_VM_NUMA_STAT_ITEMS] __cacheline_aligned_in_smp;
 atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS] __cacheline_aligned_in_smp;
 EXPORT_SYMBOL(vm_zone_stat);
-EXPORT_SYMBOL(vm_numa_stat);
 EXPORT_SYMBOL(vm_node_stat);
 
+u64 __percpu *vm_numa_stat;
+EXPORT_SYMBOL(vm_numa_stat);
 #ifdef CONFIG_SMP
 
 int calculate_pressure_threshold(struct zone *zone)
@@ -679,32 +651,6 @@ EXPORT_SYMBOL(dec_node_page_state);
  * Fold a differential into the global counters.
  * Returns the number of counters updated.
  */
-#ifdef CONFIG_NUMA
-static int fold_diff(int *zone_diff, int *numa_diff, int *node_diff)
-{
-	int i;
-	int changes = 0;
-
-	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		if (zone_diff[i]) {
-			atomic_long_add(zone_diff[i], &vm_zone_stat[i]);
-			changes++;
-	}
-
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-		if (numa_diff[i]) {
-			atomic_long_add(numa_diff[i], &vm_numa_stat[i]);
-			changes++;
-	}
-
-	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
-		if (node_diff[i]) {
-			atomic_long_add(node_diff[i], &vm_node_stat[i]);
-			changes++;
-	}
-	return changes;
-}
-#else
 static int fold_diff(int *zone_diff, int *node_diff)
 {
 	int i;
@@ -723,7 +669,6 @@ static int fold_diff(int *zone_diff, int *node_diff)
 	}
 	return changes;
 }
-#endif /* CONFIG_NUMA */
 
 /*
  * Update the zone counters for the current cpu.
@@ -747,9 +692,6 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 	struct zone *zone;
 	int i;
 	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
-#ifdef CONFIG_NUMA
-	int global_numa_diff[NR_VM_NUMA_STAT_ITEMS] = { 0, };
-#endif
 	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 	int changes = 0;
 
@@ -771,18 +713,6 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 			}
 		}
 #ifdef CONFIG_NUMA
-		for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++) {
-			int v;
-
-			v = this_cpu_xchg(p->vm_numa_stat_diff[i], 0);
-			if (v) {
-
-				atomic_long_add(v, &zone->vm_numa_stat[i]);
-				global_numa_diff[i] += v;
-				__this_cpu_write(p->expire, 3);
-			}
-		}
-
 		if (do_pagesets) {
 			cond_resched();
 			/*
@@ -829,12 +759,7 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 		}
 	}
 
-#ifdef CONFIG_NUMA
-	changes += fold_diff(global_zone_diff, global_numa_diff,
-			     global_node_diff);
-#else
 	changes += fold_diff(global_zone_diff, global_node_diff);
-#endif
 	return changes;
 }
 
@@ -849,9 +774,6 @@ void cpu_vm_stats_fold(int cpu)
 	struct zone *zone;
 	int i;
 	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
-#ifdef CONFIG_NUMA
-	int global_numa_diff[NR_VM_NUMA_STAT_ITEMS] = { 0, };
-#endif
 	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 
 	for_each_populated_zone(zone) {
@@ -868,18 +790,6 @@ void cpu_vm_stats_fold(int cpu)
 				atomic_long_add(v, &zone->vm_stat[i]);
 				global_zone_diff[i] += v;
 			}
-
-#ifdef CONFIG_NUMA
-		for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-			if (p->vm_numa_stat_diff[i]) {
-				int v;
-
-				v = p->vm_numa_stat_diff[i];
-				p->vm_numa_stat_diff[i] = 0;
-				atomic_long_add(v, &zone->vm_numa_stat[i]);
-				global_numa_diff[i] += v;
-			}
-#endif
 	}
 
 	for_each_online_pgdat(pgdat) {
@@ -898,11 +808,7 @@ void cpu_vm_stats_fold(int cpu)
 			}
 	}
 
-#ifdef CONFIG_NUMA
-	fold_diff(global_zone_diff, global_numa_diff, global_node_diff);
-#else
 	fold_diff(global_zone_diff, global_node_diff);
-#endif
 }
 
 /*
@@ -920,17 +826,6 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 			atomic_long_add(v, &zone->vm_stat[i]);
 			atomic_long_add(v, &vm_zone_stat[i]);
 		}
-
-#ifdef CONFIG_NUMA
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-		if (pset->vm_numa_stat_diff[i]) {
-			int v = pset->vm_numa_stat_diff[i];
-
-			pset->vm_numa_stat_diff[i] = 0;
-			atomic_long_add(v, &zone->vm_numa_stat[i]);
-			atomic_long_add(v, &vm_numa_stat[i]);
-		}
-#endif
 }
 #endif
 
@@ -938,16 +833,10 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 void __inc_numa_state(struct zone *zone,
 				 enum numa_stat_item item)
 {
-	struct per_cpu_pageset __percpu *pcp = zone->pageset;
-	u16 __percpu *p = pcp->vm_numa_stat_diff + item;
-	u16 v;
+	int offset = zone->node * NR_VM_NUMA_STAT_ITEMS + item;
+	u64 __percpu *p = vm_numa_stat + offset;
 
-	v = __this_cpu_inc_return(*p);
-
-	if (unlikely(v > NUMA_STATS_THRESHOLD)) {
-		zone_numa_state_add(v, zone, item);
-		__this_cpu_write(*p, 0);
-	}
+	__this_cpu_inc(*p);
 }
 
 /*
@@ -969,23 +858,6 @@ unsigned long sum_zone_node_page_state(int node,
 }
 
 /*
- * Determine the per node value of a numa stat item. To avoid deviation,
- * the per cpu stat number in vm_numa_stat_diff[] is also included.
- */
-unsigned long sum_zone_numa_state(int node,
-				 enum numa_stat_item item)
-{
-	struct zone *zones = NODE_DATA(node)->node_zones;
-	int i;
-	unsigned long count = 0;
-
-	for (i = 0; i < MAX_NR_ZONES; i++)
-		count += zone_numa_state_snapshot(zones + i, item);
-
-	return count;
-}
-
-/*
  * Determine the per node value of a stat item.
  */
 unsigned long node_page_state(struct pglist_data *pgdat,
@@ -1811,16 +1683,6 @@ int vmstat_refresh(struct ctl_table *table, int write,
 			err = -EINVAL;
 		}
 	}
-#ifdef CONFIG_NUMA
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++) {
-		val = atomic_long_read(&vm_numa_stat[i]);
-		if (val < 0) {
-			pr_warn("%s: %s %ld\n",
-				__func__, vmstat_text[i + NR_VM_ZONE_STAT_ITEMS], val);
-			err = -EINVAL;
-		}
-	}
-#endif
 	if (err)
 		return err;
 	if (write)
@@ -1862,9 +1724,6 @@ static bool need_update(int cpu)
 		struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
 
 		BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
-#ifdef CONFIG_NUMA
-		BUILD_BUG_ON(sizeof(p->vm_numa_stat_diff[0]) != 2);
-#endif
 
 		/*
 		 * The fast way of checking if there are any vmstat diffs.
@@ -1872,10 +1731,6 @@ static bool need_update(int cpu)
 		 */
 		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
 			return true;
-#ifdef CONFIG_NUMA
-		if (memchr_inv(p->vm_numa_stat_diff, 0, NR_VM_NUMA_STAT_ITEMS))
-			return true;
-#endif
 	}
 	return false;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
