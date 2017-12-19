Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 089C36B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 01:41:36 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x1so6866264plb.2
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 22:41:36 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k91si10570919pld.115.2017.12.18.22.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 22:41:34 -0800 (PST)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH v2 1/5] mm: migrate NUMA stats from per-zone to per-node
Date: Tue, 19 Dec 2017 14:39:22 +0800
Message-Id: <1513665566-4465-2-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Kemi Wang <kemi.wang@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

There is not really any use to get NUMA stats separated by zone, and
current per-zone NUMA stats is only consumed in /proc/zoneinfo. For code
cleanup purpose, we move NUMA stats from per-zone to per-node and reuse the
existed per-cpu infrastructure.

Suggested-by: Andi Kleen <ak@linux.intel.com>
Suggested-by: Michal Hocko <mhocko@kernel.com>
Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 drivers/base/node.c    |  23 +++----
 include/linux/mmzone.h |  27 ++++----
 include/linux/vmstat.h |  31 ---------
 mm/mempolicy.c         |   2 +-
 mm/page_alloc.c        |  16 +++--
 mm/vmstat.c            | 177 +++++--------------------------------------------
 6 files changed, 46 insertions(+), 230 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index ee090ab..a045ea1 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -169,13 +169,14 @@ static ssize_t node_read_numastat(struct device *dev,
 		       "interleave_hit %lu\n"
 		       "local_node %lu\n"
 		       "other_node %lu\n",
-		       sum_zone_numa_state(dev->id, NUMA_HIT),
-		       sum_zone_numa_state(dev->id, NUMA_MISS),
-		       sum_zone_numa_state(dev->id, NUMA_FOREIGN),
-		       sum_zone_numa_state(dev->id, NUMA_INTERLEAVE_HIT),
-		       sum_zone_numa_state(dev->id, NUMA_LOCAL),
-		       sum_zone_numa_state(dev->id, NUMA_OTHER));
+		       node_page_state(NODE_DATA(dev->id), NUMA_HIT),
+		       node_page_state(NODE_DATA(dev->id), NUMA_MISS),
+		       node_page_state(NODE_DATA(dev->id), NUMA_FOREIGN),
+		       node_page_state(NODE_DATA(dev->id), NUMA_INTERLEAVE_HIT),
+		       node_page_state(NODE_DATA(dev->id), NUMA_LOCAL),
+		       node_page_state(NODE_DATA(dev->id), NUMA_OTHER));
 }
+
 static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
 static ssize_t node_read_vmstat(struct device *dev,
@@ -190,17 +191,9 @@ static ssize_t node_read_vmstat(struct device *dev,
 		n += sprintf(buf+n, "%s %lu\n", vmstat_text[i],
 			     sum_zone_node_page_state(nid, i));
 
-#ifdef CONFIG_NUMA
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-		n += sprintf(buf+n, "%s %lu\n",
-			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-			     sum_zone_numa_state(nid, i));
-#endif
-
 	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
 		n += sprintf(buf+n, "%s %lu\n",
-			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
-			     NR_VM_NUMA_STAT_ITEMS],
+			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
 			     node_page_state(pgdat, i));
 
 	return n;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 67f2e3c..c06d880 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -115,20 +115,6 @@ struct zone_padding {
 #define ZONE_PADDING(name)
 #endif
 
-#ifdef CONFIG_NUMA
-enum numa_stat_item {
-	NUMA_HIT,		/* allocated in intended node */
-	NUMA_MISS,		/* allocated in non intended node */
-	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
-	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
-	NUMA_LOCAL,		/* allocation from local node */
-	NUMA_OTHER,		/* allocation from other node */
-	NR_VM_NUMA_STAT_ITEMS
-};
-#else
-#define NR_VM_NUMA_STAT_ITEMS 0
-#endif
-
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
@@ -151,7 +137,18 @@ enum zone_stat_item {
 	NR_VM_ZONE_STAT_ITEMS };
 
 enum node_stat_item {
-	NR_LRU_BASE,
+#ifdef CONFIG_NUMA
+	NUMA_HIT,		/* allocated in intended node */
+	NUMA_MISS,		/* allocated in non intended node */
+	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
+	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
+	NUMA_LOCAL,		/* allocation from local node */
+	NUMA_OTHER,		/* allocation from other node */
+	NR_VM_NUMA_STAT_ITEMS,
+#else
+#define	NR_VM_NUMA_STAT_ITEMS 0
+#endif
+	NR_LRU_BASE = NR_VM_NUMA_STAT_ITEMS,
 	NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
 	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 1779c98..80bf290 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -118,37 +118,8 @@ static inline void vm_events_fold_cpu(int cpu)
  * Zone and node-based page accounting with per cpu differentials.
  */
 extern atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS];
-extern atomic_long_t vm_numa_stat[NR_VM_NUMA_STAT_ITEMS];
 extern atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS];
 
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
-
 static inline void zone_page_state_add(long x, struct zone *zone,
 				 enum zone_stat_item item)
 {
@@ -234,10 +205,8 @@ static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
 
 
 #ifdef CONFIG_NUMA
-extern void __inc_numa_state(struct zone *zone, enum numa_stat_item item);
 extern unsigned long sum_zone_node_page_state(int node,
 					      enum zone_stat_item item);
-extern unsigned long sum_zone_numa_state(int node, enum numa_stat_item item);
 extern unsigned long node_page_state(struct pglist_data *pgdat,
 						enum node_stat_item item);
 #else
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4ce44d3..b2293e3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1920,7 +1920,7 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 		return page;
 	if (page && page_to_nid(page) == nid) {
 		preempt_disable();
-		__inc_numa_state(page_zone(page), NUMA_INTERLEAVE_HIT);
+		inc_node_state(page_pgdat(page), NUMA_INTERLEAVE_HIT);
 		preempt_enable();
 	}
 	return page;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7e5e775..81e8d8f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2793,22 +2793,24 @@ int __isolate_free_page(struct page *page, unsigned int order)
 static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 {
 #ifdef CONFIG_NUMA
-	enum numa_stat_item local_stat = NUMA_LOCAL;
+	int preferred_nid = preferred_zone->node;
+	int nid = z->node;
+	enum node_stat_item local_stat = NUMA_LOCAL;
 
 	/* skip numa counters update if numa stats is disabled */
 	if (!static_branch_likely(&vm_numa_stat_key))
 		return;
 
-	if (z->node != numa_node_id())
+	if (nid != numa_node_id())
 		local_stat = NUMA_OTHER;
 
-	if (z->node == preferred_zone->node)
-		__inc_numa_state(z, NUMA_HIT);
+	if (nid == preferred_nid)
+		inc_node_state(NODE_DATA(nid), NUMA_HIT);
 	else {
-		__inc_numa_state(z, NUMA_MISS);
-		__inc_numa_state(preferred_zone, NUMA_FOREIGN);
+		inc_node_state(NODE_DATA(nid), NUMA_MISS);
+		inc_node_state(NODE_DATA(preferred_nid), NUMA_FOREIGN);
 	}
-	__inc_numa_state(z, local_stat);
+	inc_node_state(NODE_DATA(nid), local_stat);
 #endif
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2db6..1dd12ae 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -30,46 +30,44 @@
 
 #include "internal.h"
 
-#define NUMA_STATS_THRESHOLD (U16_MAX - 2)
-
 #ifdef CONFIG_NUMA
 int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
 
-/* zero numa counters within a zone */
-static void zero_zone_numa_counters(struct zone *zone)
+/* zero numa stats within a node */
+static void zero_node_numa_stats(int node)
 {
 	int item, cpu;
 
 	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++) {
-		atomic_long_set(&zone->vm_numa_stat[item], 0);
+		atomic_long_set(&(NODE_DATA(node)->vm_stat[item]), 0);
 		for_each_online_cpu(cpu)
-			per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item]
-						= 0;
+			per_cpu_ptr(NODE_DATA(node)->per_cpu_nodestats,
+					cpu)->vm_node_stat_diff[item] = 0;
 	}
 }
 
-/* zero numa counters of all the populated zones */
-static void zero_zones_numa_counters(void)
+/* zero numa stats of all the online nodes */
+static void zero_nodes_numa_stats(void)
 {
-	struct zone *zone;
+	int node;
 
-	for_each_populated_zone(zone)
-		zero_zone_numa_counters(zone);
+	for_each_online_node(node)
+		zero_node_numa_stats(node);
 }
 
-/* zero global numa counters */
-static void zero_global_numa_counters(void)
+/* zero global numa stats */
+static void zero_global_numa_stats(void)
 {
 	int item;
 
 	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++)
-		atomic_long_set(&vm_numa_stat[item], 0);
+		atomic_long_set(&vm_node_stat[item], 0);
 }
 
 static void invalid_numa_statistics(void)
 {
-	zero_zones_numa_counters();
-	zero_global_numa_counters();
+	zero_nodes_numa_stats();
+	zero_global_numa_stats();
 }
 
 static DEFINE_MUTEX(vm_numa_stat_lock);
@@ -160,10 +158,8 @@ void vm_events_fold_cpu(int cpu)
  * vm_stat contains the global counters
  */
 atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
-atomic_long_t vm_numa_stat[NR_VM_NUMA_STAT_ITEMS] __cacheline_aligned_in_smp;
 atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS] __cacheline_aligned_in_smp;
 EXPORT_SYMBOL(vm_zone_stat);
-EXPORT_SYMBOL(vm_numa_stat);
 EXPORT_SYMBOL(vm_node_stat);
 
 #ifdef CONFIG_SMP
@@ -679,32 +675,6 @@ EXPORT_SYMBOL(dec_node_page_state);
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
@@ -723,7 +693,6 @@ static int fold_diff(int *zone_diff, int *node_diff)
 	}
 	return changes;
 }
-#endif /* CONFIG_NUMA */
 
 /*
  * Update the zone counters for the current cpu.
@@ -747,9 +716,6 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 	struct zone *zone;
 	int i;
 	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
-#ifdef CONFIG_NUMA
-	int global_numa_diff[NR_VM_NUMA_STAT_ITEMS] = { 0, };
-#endif
 	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 	int changes = 0;
 
@@ -771,18 +737,6 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
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
@@ -829,12 +783,7 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
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
 
@@ -849,9 +798,6 @@ void cpu_vm_stats_fold(int cpu)
 	struct zone *zone;
 	int i;
 	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
-#ifdef CONFIG_NUMA
-	int global_numa_diff[NR_VM_NUMA_STAT_ITEMS] = { 0, };
-#endif
 	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 
 	for_each_populated_zone(zone) {
@@ -868,18 +814,6 @@ void cpu_vm_stats_fold(int cpu)
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
@@ -898,11 +832,7 @@ void cpu_vm_stats_fold(int cpu)
 			}
 	}
 
-#ifdef CONFIG_NUMA
-	fold_diff(global_zone_diff, global_numa_diff, global_node_diff);
-#else
 	fold_diff(global_zone_diff, global_node_diff);
-#endif
 }
 
 /*
@@ -920,36 +850,10 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
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
 
 #ifdef CONFIG_NUMA
-void __inc_numa_state(struct zone *zone,
-				 enum numa_stat_item item)
-{
-	struct per_cpu_pageset __percpu *pcp = zone->pageset;
-	u16 __percpu *p = pcp->vm_numa_stat_diff + item;
-	u16 v;
-
-	v = __this_cpu_inc_return(*p);
-
-	if (unlikely(v > NUMA_STATS_THRESHOLD)) {
-		zone_numa_state_add(v, zone, item);
-		__this_cpu_write(*p, 0);
-	}
-}
-
 /*
  * Determine the per node value of a stat item. This function
  * is called frequently in a NUMA machine, so try to be as
@@ -969,23 +873,6 @@ unsigned long sum_zone_node_page_state(int node,
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
@@ -1569,8 +1456,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, "\n  per-node stats");
 		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
 			seq_printf(m, "\n      %-12s %lu",
-				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
-				NR_VM_NUMA_STAT_ITEMS],
+				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
 				node_page_state(pgdat, i));
 		}
 	}
@@ -1607,13 +1493,6 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, "\n      %-12s %lu", vmstat_text[i],
 				zone_page_state(zone, i));
 
-#ifdef CONFIG_NUMA
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-		seq_printf(m, "\n      %-12s %lu",
-				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-				zone_numa_state_snapshot(zone, i));
-#endif
-
 	seq_printf(m, "\n  pagesets");
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
@@ -1688,7 +1567,6 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
 	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
-			  NR_VM_NUMA_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
 
@@ -1704,12 +1582,6 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		v[i] = global_zone_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
-#ifdef CONFIG_NUMA
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-		v[i] = global_numa_state(i);
-	v += NR_VM_NUMA_STAT_ITEMS;
-#endif
-
 	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
 		v[i] = global_node_page_state(i);
 	v += NR_VM_NODE_STAT_ITEMS;
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
