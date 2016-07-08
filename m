Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0ED6B0005
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:35:33 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x83so5221146wma.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:35:33 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id j17si2088701wmd.23.2016.07.08.02.35.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 02:35:31 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 7BEB799428
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 09:35:31 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 01/34] mm, vmstat: add infrastructure for per-node vmstats
Date: Fri,  8 Jul 2016 10:34:37 +0100
Message-Id: <1467970510-21195-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

VM statistic counters for reclaim decisions are zone-based.  If the kernel
is to reclaim on a per-node basis then we need to track per-node
statistics but there is no infrastructure for that.  The most notable
change is that the old node_page_state is renamed to
sum_zone_node_page_state.  The new node_page_state takes a pglist_data and
uses per-node stats but none exist yet.  There is some renaming such as
vm_stat to vm_zone_stat and the addition of vm_node_stat and the renaming
of mod_state to mod_zone_state.  Otherwise, this is mostly a mechanical
patch with no functional change.  There is a lot of similarity between the
node and zone helpers which is unfortunate but there was no obvious way of
reusing the code and maintaining type safety.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 drivers/base/node.c    |  76 +++++++------
 include/linux/mm.h     |   5 +
 include/linux/mmzone.h |  13 +++
 include/linux/vmstat.h |  92 +++++++++++++--
 mm/page_alloc.c        |  10 +-
 mm/vmstat.c            | 295 +++++++++++++++++++++++++++++++++++++++++++++----
 mm/workingset.c        |   9 +-
 7 files changed, 424 insertions(+), 76 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index ed0ef0f69489..92d8e090c5b3 100644
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
@@ -117,31 +117,31 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
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
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(node_page_state(nid, NR_ANON_THPS) *
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
+		       nid, K(sum_zone_node_page_state(nid, NR_ANON_THPS) *
 				       HPAGE_PMD_NR),
-		       nid, K(node_page_state(nid, NR_SHMEM_THPS) *
+		       nid, K(sum_zone_node_page_state(nid, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
-		       nid, K(node_page_state(nid, NR_SHMEM_PMDMAPPED) *
+		       nid, K(sum_zone_node_page_state(nid, NR_SHMEM_PMDMAPPED) *
 				       HPAGE_PMD_NR));
 #else
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
+		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
 #endif
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
@@ -160,12 +160,12 @@ static ssize_t node_read_numastat(struct device *dev,
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
 
@@ -173,12 +173,18 @@ static ssize_t node_read_vmstat(struct device *dev,
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b21e5f30378e..dd79aa2800a3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -933,6 +933,11 @@ static inline struct zone *page_zone(const struct page *page)
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
 }
 
+static inline pg_data_t *page_pgdat(const struct page *page)
+{
+	return NODE_DATA(page_to_nid(page));
+}
+
 #ifdef SECTION_IN_PAGE_FLAGS
 static inline void set_page_section(struct page *page, unsigned long section)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 19425e988bdc..078ecb81e209 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -160,6 +160,10 @@ enum zone_stat_item {
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
+enum node_stat_item {
+	NR_VM_NODE_STAT_ITEMS
+};
+
 /*
  * We do arithmetic on the LRU lists in various places in the code,
  * so it is important to keep the active lists LRU_ACTIVE higher in
@@ -267,6 +271,11 @@ struct per_cpu_pageset {
 #endif
 };
 
+struct per_cpu_nodestat {
+	s8 stat_threshold;
+	s8 vm_node_stat_diff[NR_VM_NODE_STAT_ITEMS];
+};
+
 #endif /* !__GENERATING_BOUNDS.H */
 
 enum zone_type {
@@ -695,6 +704,10 @@ typedef struct pglist_data {
 	struct list_head split_queue;
 	unsigned long split_queue_len;
 #endif
+
+	/* Per-node vmstats */
+	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
+	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index d2da8e053210..d1744aa3ab9c 100644
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
@@ -161,31 +179,44 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
 }
 
 #ifdef CONFIG_NUMA
-
-extern unsigned long node_page_state(int node, enum zone_stat_item item);
-
+extern unsigned long sum_zone_node_page_state(int node,
+						enum zone_stat_item item);
+extern unsigned long node_page_state(struct pglist_data *pgdat,
+						enum node_stat_item item);
 #else
-
-#define node_page_state(node, item) global_page_state(item)
-
+#define sum_zone_node_page_state(node, item) global_page_state(item)
+#define node_page_state(node, item) global_node_page_state(item)
 #endif /* CONFIG_NUMA */
 
 #define add_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, __d)
 #define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
+#define add_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, __d)
+#define sub_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, -(__d))
 
 #ifdef CONFIG_SMP
 void __mod_zone_page_state(struct zone *, enum zone_stat_item item, long);
 void __inc_zone_page_state(struct page *, enum zone_stat_item);
 void __dec_zone_page_state(struct page *, enum zone_stat_item);
 
+void __mod_node_page_state(struct pglist_data *, enum node_stat_item item, long);
+void __inc_node_page_state(struct page *, enum node_stat_item);
+void __dec_node_page_state(struct page *, enum node_stat_item);
+
 void mod_zone_page_state(struct zone *, enum zone_stat_item, long);
 void inc_zone_page_state(struct page *, enum zone_stat_item);
 void dec_zone_page_state(struct page *, enum zone_stat_item);
 
+void mod_node_page_state(struct pglist_data *, enum node_stat_item, long);
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
 
 void quiet_vmstat(void);
 void cpu_vm_stats_fold(int cpu);
@@ -213,16 +244,34 @@ static inline void __mod_zone_page_state(struct zone *zone,
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
@@ -231,12 +280,26 @@ static inline void __inc_zone_page_state(struct page *page,
 	__inc_zone_state(page_zone(page), item);
 }
 
+static inline void __inc_node_page_state(struct page *page,
+			enum node_stat_item item)
+{
+	__inc_node_state(page_pgdat(page), item);
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
+	__dec_node_state(page_pgdat(page), item);
+}
+
+
 /*
  * We only use atomic operations to update counters. So there is no need to
  * disable interrupts.
@@ -245,7 +308,12 @@ static inline void __dec_zone_page_state(struct page *page,
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
index 403c5dcd24da..34e46c02a406 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4247,8 +4247,8 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
 		managed_pages += pgdat->node_zones[zone_type].managed_pages;
 	val->totalram = managed_pages;
-	val->sharedram = node_page_state(nid, NR_SHMEM);
-	val->freeram = node_page_state(nid, NR_FREE_PAGES);
+	val->sharedram = sum_zone_node_page_state(nid, NR_SHMEM);
+	val->freeram = sum_zone_node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
 		struct zone *zone = &pgdat->node_zones[zone_type];
@@ -5373,6 +5373,11 @@ static void __meminit setup_zone_pageset(struct zone *zone)
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
@@ -6078,6 +6083,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	reset_deferred_meminit(pgdat);
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
+	pgdat->per_cpu_nodestats = NULL;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
 	pr_info("Initmem setup node %d [mem %#018Lx-%#018Lx]\n", nid,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7997f52935c9..3345d396a99b 100644
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
 
@@ -167,19 +169,36 @@ int calculate_normal_threshold(struct zone *zone)
  */
 void refresh_zone_stat_thresholds(void)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int cpu;
 	int threshold;
 
+	/* Zero current pgdat thresholds */
+	for_each_online_pgdat(pgdat) {
+		for_each_online_cpu(cpu) {
+			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold = 0;
+		}
+	}
+
 	for_each_populated_zone(zone) {
+		struct pglist_data *pgdat = zone->zone_pgdat;
 		unsigned long max_drift, tolerate_drift;
 
 		threshold = calculate_normal_threshold(zone);
 
-		for_each_online_cpu(cpu)
+		for_each_online_cpu(cpu) {
+			int pgdat_threshold;
+
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
 
+			/* Base nodestat threshold on the largest populated zone. */
+			pgdat_threshold = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold;
+			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
+				= max(threshold, pgdat_threshold);
+		}
+
 		/*
 		 * Only set percpu_drift_mark if there is a danger that
 		 * NR_FREE_PAGES reports the low watermark is ok when in fact
@@ -238,6 +257,26 @@ void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 }
 EXPORT_SYMBOL(__mod_zone_page_state);
 
+void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+				long delta)
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
@@ -277,12 +316,34 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
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
+	__inc_node_state(page_pgdat(page), item);
+}
+EXPORT_SYMBOL(__inc_node_page_state);
+
 void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
@@ -299,12 +360,34 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
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
+	__dec_node_state(page_pgdat(page), item);
+}
+EXPORT_SYMBOL(__dec_node_page_state);
+
 #ifdef CONFIG_HAVE_CMPXCHG_LOCAL
 /*
  * If we have cmpxchg_local support then we do not need to incur the overhead
@@ -318,8 +401,8 @@ EXPORT_SYMBOL(__dec_zone_page_state);
  *     1       Overstepping half of threshold
  *     -1      Overstepping minus half of threshold
 */
-static inline void mod_state(struct zone *zone, enum zone_stat_item item,
-			     long delta, int overstep_mode)
+static inline void mod_zone_state(struct zone *zone,
+       enum zone_stat_item item, long delta, int overstep_mode)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
 	s8 __percpu *p = pcp->vm_stat_diff + item;
@@ -359,26 +442,88 @@ static inline void mod_state(struct zone *zone, enum zone_stat_item item,
 void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 			 long delta)
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
+		z = 0;  /* overflow to node counters */
+
+		/*
+		 * The fetching of the stat_threshold is racy. We may apply
+		 * a counter threshold to the wrong the cpu if we get
+		 * rescheduled while executing here. However, the next
+		 * counter update will apply the threshold again and
+		 * therefore bring the counter under the threshold again.
+		 *
+		 * Most of the time the thresholds are the same anyways
+		 * for all cpus in a node.
+		 */
+		t = this_cpu_read(pcp->stat_threshold);
+
+		o = this_cpu_read(*p);
+		n = delta + o;
+
+		if (n > t || n < -t) {
+			int os = overstep_mode * (t >> 1) ;
+
+			/* Overflow must be added to node counters */
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
+					long delta)
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
+	mod_node_state(page_pgdat(page), item, 1, 1);
+}
+EXPORT_SYMBOL(inc_node_page_state);
+
+void dec_node_page_state(struct page *page, enum node_stat_item item)
+{
+	mod_node_state(page_pgdat(page), item, -1, -1);
+}
+EXPORT_SYMBOL(dec_node_page_state);
 #else
 /*
  * Use interrupt disable to serialize counter updates
@@ -424,21 +569,69 @@ void dec_zone_page_state(struct page *page, enum zone_stat_item item)
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
+					long delta)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__mod_node_page_state(pgdat, item, delta);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(mod_node_page_state);
+
+void inc_node_page_state(struct page *page, enum node_stat_item item)
+{
+	unsigned long flags;
+	struct pglist_data *pgdat;
+
+	pgdat = page_pgdat(page);
+	local_irq_save(flags);
+	__inc_node_state(pgdat, item);
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
  * Returns the number of counters updated.
  */
-static int fold_diff(int *diff)
+static int fold_diff(int *zone_diff, int *node_diff)
 {
 	int i;
 	int changes = 0;
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		if (diff[i]) {
-			atomic_long_add(diff[i], &vm_stat[i]);
+		if (zone_diff[i]) {
+			atomic_long_add(zone_diff[i], &vm_zone_stat[i]);
+			changes++;
+	}
+
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		if (node_diff[i]) {
+			atomic_long_add(node_diff[i], &vm_node_stat[i]);
 			changes++;
 	}
 	return changes;
@@ -462,9 +655,11 @@ static int fold_diff(int *diff)
  */
 static int refresh_cpu_vm_stats(bool do_pagesets)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int i;
-	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 	int changes = 0;
 
 	for_each_populated_zone(zone) {
@@ -477,7 +672,7 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 			if (v) {
 
 				atomic_long_add(v, &zone->vm_stat[i]);
-				global_diff[i] += v;
+				global_zone_diff[i] += v;
 #ifdef CONFIG_NUMA
 				/* 3 seconds idle till flush */
 				__this_cpu_write(p->expire, 3);
@@ -516,7 +711,22 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 		}
 #endif
 	}
-	changes += fold_diff(global_diff);
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
+				global_node_diff[i] += v;
+			}
+		}
+	}
+
+	changes += fold_diff(global_zone_diff, global_node_diff);
 	return changes;
 }
 
@@ -527,9 +737,11 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
  */
 void cpu_vm_stats_fold(int cpu)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int i;
-	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 
 	for_each_populated_zone(zone) {
 		struct per_cpu_pageset *p;
@@ -543,11 +755,27 @@ void cpu_vm_stats_fold(int cpu)
 				v = p->vm_stat_diff[i];
 				p->vm_stat_diff[i] = 0;
 				atomic_long_add(v, &zone->vm_stat[i]);
-				global_diff[i] += v;
+				global_zone_diff[i] += v;
 			}
 	}
 
-	fold_diff(global_diff);
+	for_each_online_pgdat(pgdat) {
+		struct per_cpu_nodestat *p;
+
+		p = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu);
+
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			if (p->vm_node_stat_diff[i]) {
+				int v;
+
+				v = p->vm_node_stat_diff[i];
+				p->vm_node_stat_diff[i] = 0;
+				atomic_long_add(v, &pgdat->vm_stat[i]);
+				global_node_diff[i] += v;
+			}
+	}
+
+	fold_diff(global_zone_diff, global_node_diff);
 }
 
 /*
@@ -563,16 +791,19 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 			int v = pset->vm_stat_diff[i];
 			pset->vm_stat_diff[i] = 0;
 			atomic_long_add(v, &zone->vm_stat[i]);
-			atomic_long_add(v, &vm_stat[i]);
+			atomic_long_add(v, &vm_zone_stat[i]);
 		}
 }
 #endif
 
 #ifdef CONFIG_NUMA
 /*
- * Determine the per node value of a stat item.
+ * Determine the per node value of a stat item. This function
+ * is called frequently in a NUMA machine, so try to be as
+ * frugal as possible.
  */
-unsigned long node_page_state(int node, enum zone_stat_item item)
+unsigned long sum_zone_node_page_state(int node,
+				 enum zone_stat_item item)
 {
 	struct zone *zones = NODE_DATA(node)->node_zones;
 	int i;
@@ -584,6 +815,19 @@ unsigned long node_page_state(int node, enum zone_stat_item item)
 	return count;
 }
 
+/*
+ * Determine the per node value of a stat item.
+ */
+unsigned long node_page_state(struct pglist_data *pgdat,
+				enum node_stat_item item)
+{
+	long x = atomic_long_read(&pgdat->vm_stat[item]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
 #endif
 
 #ifdef CONFIG_COMPACTION
@@ -1287,6 +1531,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
 	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
+			  NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
@@ -1301,6 +1546,10 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		v[i] = global_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		v[i] = global_node_page_state(i);
+	v += NR_VM_NODE_STAT_ITEMS;
+
 	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
 			    v + NR_DIRTY_THRESHOLD);
 	v += NR_VM_WRITEBACK_STAT_ITEMS;
@@ -1390,7 +1639,7 @@ int vmstat_refresh(struct ctl_table *table, int write,
 	if (err)
 		return err;
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
-		val = atomic_long_read(&vm_stat[i]);
+		val = atomic_long_read(&vm_zone_stat[i]);
 		if (val < 0) {
 			switch (i) {
 			case NR_ALLOC_BATCH:
diff --git a/mm/workingset.c b/mm/workingset.c
index 8252de4566e9..ba972ac2dfdd 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -351,12 +351,13 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
 	local_irq_enable();
 
-	if (memcg_kmem_enabled())
+	if (memcg_kmem_enabled()) {
 		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
 						     LRU_ALL_FILE);
-	else
-		pages = node_page_state(sc->nid, NR_ACTIVE_FILE) +
-			node_page_state(sc->nid, NR_INACTIVE_FILE);
+	} else {
+		pages = sum_zone_node_page_state(sc->nid, NR_ACTIVE_FILE) +
+			sum_zone_node_page_state(sc->nid, NR_INACTIVE_FILE);
+	}
 
 	/*
 	 * Active cache pages are limited to 50% of memory, and shadow
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
