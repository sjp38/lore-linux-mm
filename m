Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 132FB6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:39 -0400 (EDT)
Received: by laar3 with SMTP id r3so48490547laa.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ql9si5280610wjc.168.2015.06.08.06.56.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:36 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/25] mm, vmstat: Add infrastructure for per-node vmstats
Date: Mon,  8 Jun 2015 14:56:07 +0100
Message-Id: <1433771791-30567-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

VM statistic counters for reclaim decisions are zone-based. If the kernel
is to reclaim on a per-node basis then we need to track per-node statistics
but there is no infrastructure for that. This patch adds it in preparation
but is currently unused.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/base/node.c    |  72 ++++++++-------
 include/linux/mmzone.h |  12 +++
 include/linux/vmstat.h |  94 +++++++++++++++++--
 mm/page_alloc.c        |   9 +-
 mm/vmstat.c            | 240 ++++++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 364 insertions(+), 63 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 36fabe43cd44..0b6392789b66 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -74,16 +74,16 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
-		       nid, K(node_page_state(nid, NR_ACTIVE_ANON) +
-				node_page_state(nid, NR_ACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_ANON) +
-				node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_ACTIVE_ANON)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_ANON)),
-		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
-		       nid, K(node_page_state(nid, NR_MLOCK)));
+		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON) +
+				sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON) +
+				sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON)),
+		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON)),
+		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_UNEVICTABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
 	n += sprintf(buf + n,
@@ -115,28 +115,28 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d AnonHugePages:  %8lu kB\n"
 #endif
 			,
-		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
-		       nid, K(node_page_state(nid, NR_WRITEBACK)),
-		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
-		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
-		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
+		       nid, K(sum_zone_node_page_state(nid, NR_FILE_DIRTY)),
+		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK)),
+		       nid, K(sum_zone_node_page_state(nid, NR_FILE_PAGES)),
+		       nid, K(sum_zone_node_page_state(nid, NR_FILE_MAPPED)),
+		       nid, K(sum_zone_node_page_state(nid, NR_ANON_PAGES)),
 		       nid, K(i.sharedram),
-		       nid, node_page_state(nid, NR_KERNEL_STACK) *
+		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
-		       nid, K(node_page_state(nid, NR_PAGETABLE)),
-		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
-		       nid, K(node_page_state(nid, NR_BOUNCE)),
-		       nid, K(node_page_state(nid, NR_WRITEBACK_TEMP)),
-		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
-				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_PAGETABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_UNSTABLE_NFS)),
+		       nid, K(sum_zone_node_page_state(nid, NR_BOUNCE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK_TEMP)),
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE) +
+				sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE))
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE))
 			, nid,
-			K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
+			K(sum_zone_node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
 			HPAGE_PMD_NR));
 #else
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
 #endif
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
@@ -155,12 +155,12 @@ static ssize_t node_read_numastat(struct device *dev,
 		       "interleave_hit %lu\n"
 		       "local_node %lu\n"
 		       "other_node %lu\n",
-		       node_page_state(dev->id, NUMA_HIT),
-		       node_page_state(dev->id, NUMA_MISS),
-		       node_page_state(dev->id, NUMA_FOREIGN),
-		       node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
-		       node_page_state(dev->id, NUMA_LOCAL),
-		       node_page_state(dev->id, NUMA_OTHER));
+		       sum_zone_node_page_state(dev->id, NUMA_HIT),
+		       sum_zone_node_page_state(dev->id, NUMA_MISS),
+		       sum_zone_node_page_state(dev->id, NUMA_FOREIGN),
+		       sum_zone_node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
+		       sum_zone_node_page_state(dev->id, NUMA_LOCAL),
+		       sum_zone_node_page_state(dev->id, NUMA_OTHER));
 }
 static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
@@ -168,12 +168,18 @@ static ssize_t node_read_vmstat(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
 	int nid = dev->id;
+	struct pglist_data *pgdat = NODE_DATA(nid);
 	int i;
 	int n = 0;
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		n += sprintf(buf+n, "%s %lu\n", vmstat_text[i],
-			     node_page_state(nid, i));
+			     sum_zone_node_page_state(nid, i));
+
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		n += sprintf(buf+n, "%s %lu\n",
+			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
+			     node_page_state(pgdat, i));
 
 	return n;
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2782df47101e..c52a3e3f178c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -159,6 +159,10 @@ enum zone_stat_item {
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
+enum node_stat_item {
+	NR_VM_NODE_STAT_ITEMS
+};
+
 /*
  * We do arithmetic on the LRU lists in various places in the code,
  * so it is important to keep the active lists LRU_ACTIVE higher in
@@ -269,6 +273,11 @@ struct per_cpu_pageset {
 #endif
 };
 
+struct per_cpu_nodestat {
+	s8 stat_threshold;
+	s8 vm_node_stat_diff[NR_VM_NODE_STAT_ITEMS];
+};
+
 #endif /* !__GENERATING_BOUNDS.H */
 
 enum zone_type {
@@ -762,6 +771,9 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+
+	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
+	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 82e7db7f7100..99564636ddfc 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -106,20 +106,38 @@ static inline void vm_events_fold_cpu(int cpu)
 		zone_idx(zone), delta)
 
 /*
- * Zone based page accounting with per cpu differentials.
+ * Zone and node-based page accounting with per cpu differentials.
  */
-extern atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS];
+extern atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS];
+extern atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS];
 
 static inline void zone_page_state_add(long x, struct zone *zone,
 				 enum zone_stat_item item)
 {
 	atomic_long_add(x, &zone->vm_stat[item]);
-	atomic_long_add(x, &vm_stat[item]);
+	atomic_long_add(x, &vm_zone_stat[item]);
+}
+
+static inline void node_page_state_add(long x, struct pglist_data *pgdat,
+				 enum node_stat_item item)
+{
+	atomic_long_add(x, &pgdat->vm_stat[item]);
+	atomic_long_add(x, &vm_node_stat[item]);
 }
 
 static inline unsigned long global_page_state(enum zone_stat_item item)
 {
-	long x = atomic_long_read(&vm_stat[item]);
+	long x = atomic_long_read(&vm_zone_stat[item]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
+static inline unsigned long global_node_page_state(enum node_stat_item item)
+{
+	long x = atomic_long_read(&vm_node_stat[item]);
 #ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
@@ -138,6 +156,17 @@ static inline unsigned long zone_page_state(struct zone *zone,
 	return x;
 }
 
+static inline unsigned long node_page_state(struct pglist_data *pgdat,
+					enum node_stat_item item)
+{
+	long x = atomic_long_read(&pgdat->vm_stat[item]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
 /*
  * More accurate version that also considers the currently pending
  * deltas. For that we need to loop over all cpus to find the current
@@ -166,7 +195,7 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
  * is called frequently in a NUMA machine, so try to be as
  * frugal as possible.
  */
-static inline unsigned long node_page_state(int node,
+static inline unsigned long sum_zone_node_page_state(int node,
 				 enum zone_stat_item item)
 {
 	struct zone *zones = NODE_DATA(node)->node_zones;
@@ -189,27 +218,39 @@ extern void zone_statistics(struct zone *, struct zone *, gfp_t gfp);
 
 #else
 
-#define node_page_state(node, item) global_page_state(item)
 #define zone_statistics(_zl, _z, gfp) do { } while (0)
 
 #endif /* CONFIG_NUMA */
 
 #define add_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, __d)
 #define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
+#define add_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, __d)
+#define sub_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, -(__d))
 
 #ifdef CONFIG_SMP
 void __mod_zone_page_state(struct zone *, enum zone_stat_item item, int);
 void __inc_zone_page_state(struct page *, enum zone_stat_item);
 void __dec_zone_page_state(struct page *, enum zone_stat_item);
 
+void __mod_node_page_state(struct pglist_data *, enum node_stat_item item, int);
+void __inc_node_page_state(struct page *, enum node_stat_item);
+void __dec_node_page_state(struct page *, enum node_stat_item);
+
 void mod_zone_page_state(struct zone *, enum zone_stat_item, int);
 void inc_zone_page_state(struct page *, enum zone_stat_item);
 void dec_zone_page_state(struct page *, enum zone_stat_item);
 
+void mod_node_page_state(struct pglist_data *, enum node_stat_item, int);
+void inc_node_page_state(struct page *, enum node_stat_item);
+void dec_node_page_state(struct page *, enum node_stat_item);
+
 extern void inc_zone_state(struct zone *, enum zone_stat_item);
+extern void inc_node_state(struct pglist_data *, enum node_stat_item);
 extern void __inc_zone_state(struct zone *, enum zone_stat_item);
+extern void __inc_node_state(struct pglist_data *, enum node_stat_item);
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
+extern void __dec_node_state(struct pglist_data *, enum node_stat_item);
 
 void cpu_vm_stats_fold(int cpu);
 void refresh_zone_stat_thresholds(void);
@@ -232,16 +273,34 @@ static inline void __mod_zone_page_state(struct zone *zone,
 	zone_page_state_add(delta, zone, item);
 }
 
+static inline void __mod_node_page_state(struct pglist_data *pgdat,
+			enum node_stat_item item, int delta)
+{
+	node_page_state_add(delta, pgdat, item);
+}
+
 static inline void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
 	atomic_long_inc(&zone->vm_stat[item]);
-	atomic_long_inc(&vm_stat[item]);
+	atomic_long_inc(&vm_zone_stat[item]);
+}
+
+static inline void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	atomic_long_inc(&pgdat->vm_stat[item]);
+	atomic_long_inc(&vm_node_stat[item]);
 }
 
 static inline void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
 	atomic_long_dec(&zone->vm_stat[item]);
-	atomic_long_dec(&vm_stat[item]);
+	atomic_long_dec(&vm_zone_stat[item]);
+}
+
+static inline void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	atomic_long_dec(&pgdat->vm_stat[item]);
+	atomic_long_dec(&vm_node_stat[item]);
 }
 
 static inline void __inc_zone_page_state(struct page *page,
@@ -250,12 +309,26 @@ static inline void __inc_zone_page_state(struct page *page,
 	__inc_zone_state(page_zone(page), item);
 }
 
+static inline void __inc_node_page_state(struct page *page,
+			enum node_stat_item item)
+{
+	__inc_node_state(page_zone(page)->zone_pgdat, item);
+}
+
+
 static inline void __dec_zone_page_state(struct page *page,
 			enum zone_stat_item item)
 {
 	__dec_zone_state(page_zone(page), item);
 }
 
+static inline void __dec_node_page_state(struct page *page,
+			enum node_stat_item item)
+{
+	__dec_node_state(page_zone(page)->zone_pgdat, item);
+}
+
+
 /*
  * We only use atomic operations to update counters. So there is no need to
  * disable interrupts.
@@ -264,7 +337,12 @@ static inline void __dec_zone_page_state(struct page *page,
 #define dec_zone_page_state __dec_zone_page_state
 #define mod_zone_page_state __mod_zone_page_state
 
+#define inc_node_page_state __inc_node_page_state
+#define dec_node_page_state __dec_node_page_state
+#define mod_node_page_state __mod_node_page_state
+
 #define inc_zone_state __inc_zone_state
+#define inc_node_state __inc_node_state
 #define dec_zone_state __dec_zone_state
 
 #define set_pgdat_percpu_threshold(pgdat, callback) { }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40e29429e7b0..b58c27b13061 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3134,8 +3134,8 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
 		managed_pages += pgdat->node_zones[zone_type].managed_pages;
 	val->totalram = managed_pages;
-	val->sharedram = node_page_state(nid, NR_SHMEM);
-	val->freeram = node_page_state(nid, NR_FREE_PAGES);
+	val->sharedram = sum_zone_node_page_state(nid, NR_SHMEM);
+	val->freeram = sum_zone_node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
 	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
 	val->freehigh = zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
@@ -4335,6 +4335,11 @@ static void __meminit setup_zone_pageset(struct zone *zone)
 	zone->pageset = alloc_percpu(struct per_cpu_pageset);
 	for_each_possible_cpu(cpu)
 		zone_pageset_init(zone, cpu);
+
+	if (!zone->zone_pgdat->per_cpu_nodestats) {
+		zone->zone_pgdat->per_cpu_nodestats =
+			alloc_percpu(struct per_cpu_nodestat);
+	}
 }
 
 /*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4f5cd974e11a..effafdb80975 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -86,8 +86,10 @@ void vm_events_fold_cpu(int cpu)
  *
  * vm_stat contains the global counters
  */
-atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
-EXPORT_SYMBOL(vm_stat);
+atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
+atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS] __cacheline_aligned_in_smp;
+EXPORT_SYMBOL(vm_zone_stat);
+EXPORT_SYMBOL(vm_node_stat);
 
 #ifdef CONFIG_SMP
 
@@ -176,9 +178,13 @@ void refresh_zone_stat_thresholds(void)
 
 		threshold = calculate_normal_threshold(zone);
 
-		for_each_online_cpu(cpu)
+		for_each_online_cpu(cpu) {
+			struct pglist_data *pgdat = zone->zone_pgdat;
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
+			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
+							= threshold;
+		}
 
 		/*
 		 * Only set percpu_drift_mark if there is a danger that
@@ -238,6 +244,26 @@ void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 }
 EXPORT_SYMBOL(__mod_zone_page_state);
 
+void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+				int delta)
+{
+	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	long x;
+	long t;
+
+	x = delta + __this_cpu_read(*p);
+
+	t = __this_cpu_read(pcp->stat_threshold);
+
+	if (unlikely(x > t || x < -t)) {
+		node_page_state_add(x, pgdat, item);
+		x = 0;
+	}
+	__this_cpu_write(*p, x);
+}
+EXPORT_SYMBOL(__mod_node_page_state);
+
 /*
  * Optimized increment and decrement functions.
  *
@@ -277,12 +303,34 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 	}
 }
 
+void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	s8 v, t;
+
+	v = __this_cpu_inc_return(*p);
+	t = __this_cpu_read(pcp->stat_threshold);
+	if (unlikely(v > t)) {
+		s8 overstep = t >> 1;
+
+		node_page_state_add(v + overstep, pgdat, item);
+		__this_cpu_write(*p, -overstep);
+	}
+}
+
 void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	__inc_zone_state(page_zone(page), item);
 }
 EXPORT_SYMBOL(__inc_zone_page_state);
 
+void __inc_node_page_state(struct page *page, enum node_stat_item item)
+{
+	__inc_node_state(page_zone(page)->zone_pgdat, item);
+}
+EXPORT_SYMBOL(__inc_node_page_state);
+
 void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
@@ -299,12 +347,34 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 	}
 }
 
+void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	s8 v, t;
+
+	v = __this_cpu_dec_return(*p);
+	t = __this_cpu_read(pcp->stat_threshold);
+	if (unlikely(v < - t)) {
+		s8 overstep = t >> 1;
+
+		node_page_state_add(v - overstep, pgdat, item);
+		__this_cpu_write(*p, overstep);
+	}
+}
+
 void __dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	__dec_zone_state(page_zone(page), item);
 }
 EXPORT_SYMBOL(__dec_zone_page_state);
 
+void __dec_node_page_state(struct page *page, enum node_stat_item item)
+{
+	__dec_node_state(page_zone(page)->zone_pgdat, item);
+}
+EXPORT_SYMBOL(__dec_node_page_state);
+
 #ifdef CONFIG_HAVE_CMPXCHG_LOCAL
 /*
  * If we have cmpxchg_local support then we do not need to incur the overhead
@@ -318,7 +388,7 @@ EXPORT_SYMBOL(__dec_zone_page_state);
  *     1       Overstepping half of threshold
  *     -1      Overstepping minus half of threshold
 */
-static inline void mod_state(struct zone *zone,
+static inline void mod_zone_state(struct zone *zone,
        enum zone_stat_item item, int delta, int overstep_mode)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
@@ -359,26 +429,88 @@ static inline void mod_state(struct zone *zone,
 void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 					int delta)
 {
-	mod_state(zone, item, delta, 0);
+	mod_zone_state(zone, item, delta, 0);
 }
 EXPORT_SYMBOL(mod_zone_page_state);
 
 void inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	mod_state(zone, item, 1, 1);
+	mod_zone_state(zone, item, 1, 1);
 }
 
 void inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
-	mod_state(page_zone(page), item, 1, 1);
+	mod_zone_state(page_zone(page), item, 1, 1);
 }
 EXPORT_SYMBOL(inc_zone_page_state);
 
 void dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
-	mod_state(page_zone(page), item, -1, -1);
+	mod_zone_state(page_zone(page), item, -1, -1);
 }
 EXPORT_SYMBOL(dec_zone_page_state);
+
+static inline void mod_node_state(struct pglist_data *pgdat,
+       enum node_stat_item item, int delta, int overstep_mode)
+{
+	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	long o, n, t, z;
+
+	do {
+		z = 0;  /* overflow to zone counters */
+
+		/*
+		 * The fetching of the stat_threshold is racy. We may apply
+		 * a counter threshold to the wrong the cpu if we get
+		 * rescheduled while executing here. However, the next
+		 * counter update will apply the threshold again and
+		 * therefore bring the counter under the threshold again.
+		 *
+		 * Most of the time the thresholds are the same anyways
+		 * for all cpus in a zone.
+		 */
+		t = this_cpu_read(pcp->stat_threshold);
+
+		o = this_cpu_read(*p);
+		n = delta + o;
+
+		if (n > t || n < -t) {
+			int os = overstep_mode * (t >> 1) ;
+
+			/* Overflow must be added to zone counters */
+			z = n + os;
+			n = -os;
+		}
+	} while (this_cpu_cmpxchg(*p, o, n) != o);
+
+	if (z)
+		node_page_state_add(z, pgdat, item);
+}
+
+void mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+					int delta)
+{
+	mod_node_state(pgdat, item, delta, 0);
+}
+EXPORT_SYMBOL(mod_node_page_state);
+
+void inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	mod_node_state(pgdat, item, 1, 1);
+}
+
+void inc_node_page_state(struct page *page, enum node_stat_item item)
+{
+	mod_node_state(page_zone(page)->zone_pgdat, item, 1, 1);
+}
+EXPORT_SYMBOL(inc_node_page_state);
+
+void dec_node_page_state(struct page *page, enum node_stat_item item)
+{
+	mod_node_state(page_zone(page)->zone_pgdat, item, -1, -1);
+}
+EXPORT_SYMBOL(dec_node_page_state);
 #else
 /*
  * Use interrupt disable to serialize counter updates
@@ -394,15 +526,6 @@ void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 }
 EXPORT_SYMBOL(mod_zone_page_state);
 
-void inc_zone_state(struct zone *zone, enum zone_stat_item item)
-{
-	unsigned long flags;
-
-	local_irq_save(flags);
-	__inc_zone_state(zone, item);
-	local_irq_restore(flags);
-}
-
 void inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	unsigned long flags;
@@ -424,8 +547,50 @@ void dec_zone_page_state(struct page *page, enum zone_stat_item item)
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(dec_zone_page_state);
-#endif
 
+void inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__inc_node_state(pgdat, item);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(inc_node_state);
+
+void mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+					int delta)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__mod_node_page_state(node, item, delta);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(mod_node_page_state);
+
+void inc_node_page_state(struct page *page, enum node_stat_item item)
+{
+	unsigned long flags;
+	struct pglist_data *pgdat;
+
+	pgdat = page_zone(page)->zone_pgdat;
+	local_irq_save(flags);
+	__inc_zone_state(pgdat, item);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(inc_node_page_state);
+
+void dec_node_page_state(struct page *page, enum node_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__dec_node_page_state(page, item);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(dec_node_page_state);
+#endif
 
 /*
  * Fold a differential into the global counters.
@@ -438,7 +603,7 @@ static int fold_diff(int *diff)
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		if (diff[i]) {
-			atomic_long_add(diff[i], &vm_stat[i]);
+			atomic_long_add(diff[i], &vm_zone_stat[i]);
 			changes++;
 	}
 	return changes;
@@ -462,6 +627,7 @@ static int fold_diff(int *diff)
  */
 static int refresh_cpu_vm_stats(void)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int i;
 	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
@@ -514,6 +680,21 @@ static int refresh_cpu_vm_stats(void)
 		}
 #endif
 	}
+
+	for_each_online_pgdat(pgdat) {
+		struct per_cpu_nodestat __percpu *p = pgdat->per_cpu_nodestats;
+
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+			int v;
+
+			v = this_cpu_xchg(p->vm_node_stat_diff[i], 0);
+			if (v) {
+				atomic_long_add(v, &pgdat->vm_stat[i]);
+				changes += v;
+			}
+		}
+	}
+
 	changes += fold_diff(global_diff);
 	return changes;
 }
@@ -525,6 +706,7 @@ static int refresh_cpu_vm_stats(void)
  */
 void cpu_vm_stats_fold(int cpu)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int i;
 	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
@@ -545,6 +727,19 @@ void cpu_vm_stats_fold(int cpu)
 			}
 	}
 
+	for_each_online_pgdat(pgdat) {
+		struct per_cpu_nodestat __percpu *p = pgdat->per_cpu_nodestats;
+
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			if (p->vm_node_stat_diff[i]) {
+				int v;
+
+				v = p->vm_node_stat_diff[i];
+				p->vm_node_stat_diff[i] = 0;
+				atomic_long_add(v, &pgdat->vm_stat[i]);
+			}
+	}
+
 	fold_diff(global_diff);
 }
 
@@ -561,7 +756,7 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 			int v = pset->vm_stat_diff[i];
 			pset->vm_stat_diff[i] = 0;
 			atomic_long_add(v, &zone->vm_stat[i]);
-			atomic_long_add(v, &vm_stat[i]);
+			atomic_long_add(v, &vm_zone_stat[i]);
 		}
 }
 #endif
@@ -1287,6 +1482,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
 	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
+			  NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
@@ -1301,6 +1497,10 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		v[i] = global_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		v[i] = global_node_page_state(i);
+	v += NR_VM_NODE_STAT_ITEMS;
+
 	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
 			    v + NR_DIRTY_THRESHOLD);
 	v += NR_VM_WRITEBACK_STAT_ITEMS;
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
