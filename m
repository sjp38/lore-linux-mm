Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88EC36B0292
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 04:46:53 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so6501855pgy.1
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 01:46:53 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w26si5283768pfi.302.2017.08.15.01.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 01:46:51 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH 1/2] mm: Change the call sites of numa statistics items
Date: Tue, 15 Aug 2017 16:45:35 +0800
Message-Id: <1502786736-21585-2-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Kemi Wang <kemi.wang@intel.com>

In this patch,  NUMA statistics is separated from zone statistics
framework, all the call sites of NUMA stats are changed to use
numa-stats-specific functions, it does not have any functionality change
except that the value of NUMA stats is shown behind zone page stats, and
the threshold size of NUMA stats is shown behind pcp threshold when users
*read* the zone info.

E.g. cat /proc/zoneinfo
    ***Base***                           ***With this patch***
nr_free_pages 3976                         nr_free_pages 3976
nr_zone_inactive_anon 0                    nr_zone_inactive_anon 0
nr_zone_active_anon 0                      nr_zone_active_anon 0
nr_zone_inactive_file 0                    nr_zone_inactive_file 0
nr_zone_active_file 0                      nr_zone_active_file 0
nr_zone_unevictable 0                      nr_zone_unevictable 0
nr_zone_write_pending 0                    nr_zone_write_pending 0
nr_mlock     0                             nr_mlock     0
nr_page_table_pages 0                      nr_page_table_pages 0
nr_kernel_stack 0                          nr_kernel_stack 0
nr_bounce    0                             nr_bounce    0
nr_zspages   0                             nr_zspages   0
numa_hit 0                                *nr_free_cma  0*
numa_miss 0                                numa_hit     0
numa_foreign 0                             numa_miss    0
numa_interleave 0                          numa_foreign 0
numa_local   0                             numa_interleave 0
numa_other   0                             numa_local   0
*nr_free_cma 0*                            numa_other 0
    ...                                        ...
vm stats threshold: 10                     vm stats threshold: 10
    ...                                   *vm numa stats threshold: 10*
                                               ...

The next patch updates the numa stats counter size and threshold.

Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 drivers/base/node.c    |  22 ++++---
 include/linux/mmzone.h |  25 +++++---
 include/linux/vmstat.h |  29 +++++++++
 mm/page_alloc.c        |  10 +--
 mm/vmstat.c            | 167 +++++++++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 227 insertions(+), 26 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index d8dc830..12080c6 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -160,12 +160,12 @@ static ssize_t node_read_numastat(struct device *dev,
 		       "interleave_hit %lu\n"
 		       "local_node %lu\n"
 		       "other_node %lu\n",
-		       sum_zone_node_page_state(dev->id, NUMA_HIT),
-		       sum_zone_node_page_state(dev->id, NUMA_MISS),
-		       sum_zone_node_page_state(dev->id, NUMA_FOREIGN),
-		       sum_zone_node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
-		       sum_zone_node_page_state(dev->id, NUMA_LOCAL),
-		       sum_zone_node_page_state(dev->id, NUMA_OTHER));
+		       sum_zone_node_numa_state(dev->id, NUMA_HIT),
+		       sum_zone_node_numa_state(dev->id, NUMA_MISS),
+		       sum_zone_node_numa_state(dev->id, NUMA_FOREIGN),
+		       sum_zone_node_numa_state(dev->id, NUMA_INTERLEAVE_HIT),
+		       sum_zone_node_numa_state(dev->id, NUMA_LOCAL),
+		       sum_zone_node_numa_state(dev->id, NUMA_OTHER));
 }
 static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
@@ -181,9 +181,17 @@ static ssize_t node_read_vmstat(struct device *dev,
 		n += sprintf(buf+n, "%s %lu\n", vmstat_text[i],
 			     sum_zone_node_page_state(nid, i));
 
-	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+#ifdef CONFIG_NUMA
+	for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++)
 		n += sprintf(buf+n, "%s %lu\n",
 			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
+			     sum_zone_node_numa_state(nid, i));
+#endif
+
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		n += sprintf(buf+n, "%s %lu\n",
+			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
+			     NR_VM_ZONE_NUMA_STAT_ITEMS],
 			     node_page_state(pgdat, i));
 
 	return n;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc14b8b..0b11ba7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -114,6 +114,20 @@ struct zone_padding {
 #define ZONE_PADDING(name)
 #endif
 
+#ifdef CONFIG_NUMA
+enum zone_numa_stat_item {
+	NUMA_HIT,		/* allocated in intended node */
+	NUMA_MISS,		/* allocated in non intended node */
+	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
+	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
+	NUMA_LOCAL,		/* allocation from local node */
+	NUMA_OTHER,		/* allocation from other node */
+	NR_VM_ZONE_NUMA_STAT_ITEMS
+};
+#else
+#define NR_VM_ZONE_NUMA_STAT_ITEMS 0
+#endif
+
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
@@ -132,14 +146,6 @@ enum zone_stat_item {
 #if IS_ENABLED(CONFIG_ZSMALLOC)
 	NR_ZSPAGES,		/* allocated in zsmalloc */
 #endif
-#ifdef CONFIG_NUMA
-	NUMA_HIT,		/* allocated in intended node */
-	NUMA_MISS,		/* allocated in non intended node */
-	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
-	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
-	NUMA_LOCAL,		/* allocation from local node */
-	NUMA_OTHER,		/* allocation from other node */
-#endif
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
@@ -276,6 +282,8 @@ struct per_cpu_pageset {
 	struct per_cpu_pages pcp;
 #ifdef CONFIG_NUMA
 	s8 expire;
+	s8 numa_stat_threshold;
+	s8 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
 #endif
 #ifdef CONFIG_SMP
 	s8 stat_threshold;
@@ -496,6 +504,7 @@ struct zone {
 	ZONE_PADDING(_pad3_)
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
+	atomic_long_t		vm_numa_stat[NR_VM_ZONE_NUMA_STAT_ITEMS];
 } ____cacheline_internodealigned_in_smp;
 
 enum pgdat_flags {
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index b3d85f3..1e19379 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -107,8 +107,33 @@ static inline void vm_events_fold_cpu(int cpu)
  * Zone and node-based page accounting with per cpu differentials.
  */
 extern atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS];
+extern atomic_long_t vm_zone_numa_stat[NR_VM_ZONE_NUMA_STAT_ITEMS];
 extern atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS];
 
+#ifdef CONFIG_NUMA
+static inline void zone_numa_state_add(long x, struct zone *zone,
+				 enum zone_numa_stat_item item)
+{
+	atomic_long_add(x, &zone->vm_numa_stat[item]);
+	atomic_long_add(x, &vm_zone_numa_stat[item]);
+}
+
+static inline unsigned long global_numa_state(enum zone_numa_stat_item item)
+{
+	long x = atomic_long_read(&vm_zone_numa_stat[item]);
+
+	return x;
+}
+
+static inline unsigned long zone_numa_state(struct zone *zone,
+					enum zone_numa_stat_item item)
+{
+	long x = atomic_long_read(&zone->vm_numa_stat[item]);
+
+	return x;
+}
+#endif /* CONFIG_NUMA */
+
 static inline void zone_page_state_add(long x, struct zone *zone,
 				 enum zone_stat_item item)
 {
@@ -194,8 +219,12 @@ static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
 
 
 #ifdef CONFIG_NUMA
+extern void __inc_zone_numa_state(struct zone *,
+						enum zone_numa_stat_item);
 extern unsigned long sum_zone_node_page_state(int node,
 						enum zone_stat_item item);
+extern unsigned long sum_zone_node_numa_state(int node,
+						enum zone_numa_stat_item item);
 extern unsigned long node_page_state(struct pglist_data *pgdat,
 						enum node_stat_item item);
 #else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d30e91..7222c47 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2720,18 +2720,18 @@ int __isolate_free_page(struct page *page, unsigned int order)
 static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 {
 #ifdef CONFIG_NUMA
-	enum zone_stat_item local_stat = NUMA_LOCAL;
+	enum zone_numa_stat_item local_stat = NUMA_LOCAL;
 
 	if (z->node != numa_node_id())
 		local_stat = NUMA_OTHER;
 
 	if (z->node == preferred_zone->node)
-		__inc_zone_state(z, NUMA_HIT);
+		__inc_zone_numa_state(z, NUMA_HIT);
 	else {
-		__inc_zone_state(z, NUMA_MISS);
-		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
+		__inc_zone_numa_state(z, NUMA_MISS);
+		__inc_zone_numa_state(preferred_zone, NUMA_FOREIGN);
 	}
-	__inc_zone_state(z, local_stat);
+	__inc_zone_numa_state(z, local_stat);
 #endif
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9a4441b..5a7fa30 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -87,8 +87,10 @@ void vm_events_fold_cpu(int cpu)
  * vm_stat contains the global counters
  */
 atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
+atomic_long_t vm_zone_numa_stat[NR_VM_ZONE_NUMA_STAT_ITEMS] __cacheline_aligned_in_smp;
 atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS] __cacheline_aligned_in_smp;
 EXPORT_SYMBOL(vm_zone_stat);
+EXPORT_SYMBOL(vm_zone_numa_stat);
 EXPORT_SYMBOL(vm_node_stat);
 
 #ifdef CONFIG_SMP
@@ -192,7 +194,10 @@ void refresh_zone_stat_thresholds(void)
 
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
-
+#ifdef CONFIG_NUMA
+			per_cpu_ptr(zone->pageset, cpu)->numa_stat_threshold
+							= threshold;
+#endif
 			/* Base nodestat threshold on the largest populated zone. */
 			pgdat_threshold = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold;
 			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
@@ -226,9 +231,14 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 			continue;
 
 		threshold = (*calculate_pressure)(zone);
-		for_each_online_cpu(cpu)
+		for_each_online_cpu(cpu) {
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
+#ifdef CONFIG_NUMA
+			per_cpu_ptr(zone->pageset, cpu)->numa_stat_threshold
+							= threshold;
+#endif
+		}
 	}
 }
 
@@ -604,6 +614,32 @@ EXPORT_SYMBOL(dec_node_page_state);
  * Fold a differential into the global counters.
  * Returns the number of counters updated.
  */
+#ifdef CONFIG_NUMA
+static int fold_diff(int *zone_diff, int *numa_diff, int *node_diff)
+{
+	int i;
+	int changes = 0;
+
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		if (zone_diff[i]) {
+			atomic_long_add(zone_diff[i], &vm_zone_stat[i]);
+			changes++;
+	}
+
+	for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++)
+		if (numa_diff[i]) {
+			atomic_long_add(numa_diff[i], &vm_zone_numa_stat[i]);
+			changes++;
+	}
+
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		if (node_diff[i]) {
+			atomic_long_add(node_diff[i], &vm_node_stat[i]);
+			changes++;
+	}
+	return changes;
+}
+#else
 static int fold_diff(int *zone_diff, int *node_diff)
 {
 	int i;
@@ -622,6 +658,7 @@ static int fold_diff(int *zone_diff, int *node_diff)
 	}
 	return changes;
 }
+#endif /* CONFIG_NUMA */
 
 /*
  * Update the zone counters for the current cpu.
@@ -645,6 +682,9 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 	struct zone *zone;
 	int i;
 	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+#ifdef CONFIG_NUMA
+	int global_numa_diff[NR_VM_ZONE_NUMA_STAT_ITEMS] = {0, };
+#endif
 	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 	int changes = 0;
 
@@ -666,6 +706,18 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 			}
 		}
 #ifdef CONFIG_NUMA
+		for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++) {
+			int v;
+
+			v = this_cpu_xchg(p->vm_numa_stat_diff[i], 0);
+			if (v) {
+
+				atomic_long_add(v, &zone->vm_numa_stat[i]);
+				global_numa_diff[i] += v;
+				__this_cpu_write(p->expire, 3);
+			}
+		}
+
 		if (do_pagesets) {
 			cond_resched();
 			/*
@@ -712,7 +764,11 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 		}
 	}
 
+#ifdef CONFIG_NUMA
+	changes += fold_diff(global_zone_diff, global_numa_diff, global_node_diff);
+#else
 	changes += fold_diff(global_zone_diff, global_node_diff);
+#endif
 	return changes;
 }
 
@@ -727,6 +783,9 @@ void cpu_vm_stats_fold(int cpu)
 	struct zone *zone;
 	int i;
 	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+#ifdef CONFIG_NUMA
+	int global_numa_diff[NR_VM_ZONE_NUMA_STAT_ITEMS] = {0, };
+#endif
 	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 
 	for_each_populated_zone(zone) {
@@ -743,6 +802,18 @@ void cpu_vm_stats_fold(int cpu)
 				atomic_long_add(v, &zone->vm_stat[i]);
 				global_zone_diff[i] += v;
 			}
+
+#ifdef CONFIG_NUMA
+		for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++)
+			if (p->vm_numa_stat_diff[i]) {
+				int v;
+
+				v = p->vm_numa_stat_diff[i];
+				p->vm_numa_stat_diff[i] = 0;
+				atomic_long_add(v, &zone->vm_numa_stat[i]);
+				global_numa_diff[i] += v;
+			}
+#endif
 	}
 
 	for_each_online_pgdat(pgdat) {
@@ -761,7 +832,11 @@ void cpu_vm_stats_fold(int cpu)
 			}
 	}
 
+#ifdef CONFIG_NUMA
+	fold_diff(global_zone_diff, global_numa_diff, global_node_diff);
+#else
 	fold_diff(global_zone_diff, global_node_diff);
+#endif
 }
 
 /*
@@ -779,10 +854,37 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 			atomic_long_add(v, &zone->vm_stat[i]);
 			atomic_long_add(v, &vm_zone_stat[i]);
 		}
+
+#ifdef CONFIG_NUMA
+	for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++)
+		if (pset->vm_numa_stat_diff[i]) {
+			int v = pset->vm_numa_stat_diff[i];
+			pset->vm_numa_stat_diff[i] = 0;
+			atomic_long_add(v, &zone->vm_numa_stat[i]);
+			atomic_long_add(v, &vm_zone_numa_stat[i]);
+		}
+#endif
 }
 #endif
 
 #ifdef CONFIG_NUMA
+void __inc_zone_numa_state(struct zone *zone,
+				 enum zone_numa_stat_item item)
+{
+	struct per_cpu_pageset __percpu *pcp = zone->pageset;
+	s8 __percpu *p = pcp->vm_numa_stat_diff + item;
+	s8 v, t;
+
+	v = __this_cpu_inc_return(*p);
+	t = __this_cpu_read(pcp->numa_stat_threshold);
+	if (unlikely(v > t)) {
+		s8 overstep = t >> 1;
+
+		zone_numa_state_add(v + overstep, zone, item);
+		__this_cpu_write(*p, -overstep);
+	}
+}
+
 /*
  * Determine the per node value of a stat item. This function
  * is called frequently in a NUMA machine, so try to be as
@@ -801,6 +903,22 @@ unsigned long sum_zone_node_page_state(int node,
 	return count;
 }
 
+/* Determine the per node value of a numa stat item. To avoid deviation,
+ * the per-cpu stat number in vm_numa_stat_diff[] is also included.
+ */
+unsigned long sum_zone_node_numa_state(int node,
+				 enum zone_numa_stat_item item)
+{
+	struct zone *zones = NODE_DATA(node)->node_zones;
+	int i;
+	unsigned long count = 0;
+
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		count += zone_numa_state(zones + i, item);
+
+	return count;
+}
+
 /*
  * Determine the per node value of a stat item.
  */
@@ -934,6 +1052,9 @@ const char * const vmstat_text[] = {
 #if IS_ENABLED(CONFIG_ZSMALLOC)
 	"nr_zspages",
 #endif
+	"nr_free_cma",
+
+	/* enum zone_numa_stat_item counters */
 #ifdef CONFIG_NUMA
 	"numa_hit",
 	"numa_miss",
@@ -942,7 +1063,6 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
-	"nr_free_cma",
 
 	/* Node-based counters */
 	"nr_inactive_anon",
@@ -1097,7 +1217,6 @@ const char * const vmstat_text[] = {
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
 
-
 #if (defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)) || \
      defined(CONFIG_PROC_FS)
 static void *frag_start(struct seq_file *m, loff_t *pos)
@@ -1375,7 +1494,8 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, "\n  per-node stats");
 		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
 			seq_printf(m, "\n      %-12s %lu",
-				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
+				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
+				NR_VM_ZONE_NUMA_STAT_ITEMS],
 				node_page_state(pgdat, i));
 		}
 	}
@@ -1412,6 +1532,13 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, "\n      %-12s %lu", vmstat_text[i],
 				zone_page_state(zone, i));
 
+#ifdef CONFIG_NUMA
+	for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++)
+		seq_printf(m, "\n      %-12s %lu",
+				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
+				zone_numa_state(zone, i));
+#endif
+
 	seq_printf(m, "\n  pagesets");
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
@@ -1430,6 +1557,11 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, "\n  vm stats threshold: %d",
 				pageset->stat_threshold);
 #endif
+
+#ifdef CONFIG_NUMA
+		seq_printf(m, "\n  vm numa stats threshold: %d",
+				pageset->numa_stat_threshold);
+#endif
 	}
 	seq_printf(m,
 		   "\n  node_unreclaimable:  %u"
@@ -1488,6 +1620,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
 	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
+			  NR_VM_ZONE_NUMA_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
 
@@ -1503,6 +1636,12 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		v[i] = global_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
+#ifdef CONFIG_NUMA
+	for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++)
+		v[i] = global_numa_state(i);
+	v += NR_VM_ZONE_NUMA_STAT_ITEMS;
+#endif
+
 	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
 		v[i] = global_node_page_state(i);
 	v += NR_VM_NODE_STAT_ITEMS;
@@ -1604,6 +1743,16 @@ int vmstat_refresh(struct ctl_table *table, int write,
 			err = -EINVAL;
 		}
 	}
+#ifdef CONFIG_NUMA
+	for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++) {
+		val = atomic_long_read(&vm_zone_numa_stat[i]);
+		if (val < 0) {
+			pr_warn("%s: %s %ld\n",
+				__func__, vmstat_text[i + NR_VM_ZONE_STAT_ITEMS], val);
+			err = -EINVAL;
+		}
+	}
+#endif
 	if (err)
 		return err;
 	if (write)
@@ -1645,13 +1794,19 @@ static bool need_update(int cpu)
 		struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
 
 		BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
+#ifdef CONFIG_NUMA
+		BUILD_BUG_ON(sizeof(p->vm_numa_stat_diff[0]) != 1);
+#endif
 		/*
 		 * The fast way of checking if there are any vmstat diffs.
 		 * This works because the diffs are byte sized items.
 		 */
 		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
 			return true;
-
+#ifdef CONFIG_NUMA
+		if (memchr_inv(p->vm_numa_stat_diff, 0, NR_VM_ZONE_NUMA_STAT_ITEMS))
+			return true;
+#endif
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
