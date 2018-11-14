Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F01E76B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 18:51:12 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d6-v6so14478026pfn.19
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:51:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z31-v6sor29418575plb.35.2018.11.14.15.51.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 15:51:11 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: use managed_zone() for more exact check in zone iteration
Date: Thu, 15 Nov 2018 07:50:40 +0800
Message-Id: <20181114235040.36180-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

For one zone, there are three digits to describe its space range:

    spanned_pages
    present_pages
    managed_pages

The detailed meaning is written in include/linux/mmzone.h. This patch
concerns about the last two.

    present_pages is physical pages existing within the zone
    managed_pages is present pages managed by the buddy system

>From the definition, managed_pages is a more strict condition than
present_pages.

There are two functions using zone's present_pages as a boundary:

    populated_zone()
    for_each_populated_zone()

By going through the kernel tree, most of their users are willing to
access pages managed by the buddy system, which means it is more exact
to check zone's managed_pages for a validation.

This patch replaces those checks on present_pages to managed_pages by:

    * change for_each_populated_zone() to for_each_managed_zone()
    * convert for_each_populated_zone() to for_each_zone() and check
      populated_zone() where is necessary
    * change populated_zone() to managed_zone() at proper places

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---

Michal, after last mail, I did one more thing to replace
populated_zone() with managed_zone() at proper places.

One thing I am not sure is those places in mm/compaction.c. I have
chaged them. If not, please let me know.

BTW, I did a boot up test with the patched kernel and looks smooth.
---
 arch/s390/mm/page-states.c |  2 +-
 include/linux/mmzone.h     |  8 +++-----
 kernel/power/snapshot.c    | 31 ++++++++++++++++++++-----------
 mm/compaction.c            |  8 ++++----
 mm/highmem.c               |  5 ++---
 mm/huge_memory.c           |  2 +-
 mm/khugepaged.c            |  2 +-
 mm/madvise.c               |  2 +-
 mm/migrate.c               |  2 +-
 mm/page-writeback.c        |  4 ++--
 mm/page_alloc.c            | 19 +++++++++----------
 mm/vmstat.c                | 14 +++++++-------
 12 files changed, 52 insertions(+), 47 deletions(-)

diff --git a/arch/s390/mm/page-states.c b/arch/s390/mm/page-states.c
index dc3cede7f2ec..015430bf0c63 100644
--- a/arch/s390/mm/page-states.c
+++ b/arch/s390/mm/page-states.c
@@ -265,7 +265,7 @@ void arch_set_page_states(int make_stable)
 		return;
 	if (make_stable)
 		drain_local_pages(NULL);
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		spin_lock_irqsave(&zone->lock, flags);
 		for_each_migratetype_order(order, t) {
 			list_for_each(l, &zone->free_area[order].free_list[t]) {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 847705a6d0ec..2174baba0546 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -937,11 +937,9 @@ extern struct zone *next_zone(struct zone *zone);
 	     zone;					\
 	     zone = next_zone(zone))
 
-#define for_each_populated_zone(zone)		        \
-	for (zone = (first_online_pgdat())->node_zones; \
-	     zone;					\
-	     zone = next_zone(zone))			\
-		if (!populated_zone(zone))		\
+#define for_each_managed_zone(zone)		        \
+	for_each_zone(zone)				\
+		if (!managed_zone(zone))		\
 			; /* do nothing */		\
 		else
 
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index b0308a2c6000..aa99efa73d89 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -592,10 +592,13 @@ static int create_mem_extents(struct list_head *list, gfp_t gfp_mask)
 
 	INIT_LIST_HEAD(list);
 
-	for_each_populated_zone(zone) {
+	for_each_zone(zone) {
 		unsigned long zone_start, zone_end;
 		struct mem_extent *ext, *cur, *aux;
 
+		if (!populated_zone(zone))
+			continue;
+
 		zone_start = zone->zone_start_pfn;
 		zone_end = zone_end_pfn(zone);
 
@@ -1193,8 +1196,8 @@ static unsigned int count_free_highmem_pages(void)
 	struct zone *zone;
 	unsigned int cnt = 0;
 
-	for_each_populated_zone(zone)
-		if (is_highmem(zone))
+	for_each_zone(zone)
+		if (populated_zone(zone) && is_highmem(zone))
 			cnt += zone_page_state(zone, NR_FREE_PAGES);
 
 	return cnt;
@@ -1239,10 +1242,10 @@ static unsigned int count_highmem_pages(void)
 	struct zone *zone;
 	unsigned int n = 0;
 
-	for_each_populated_zone(zone) {
+	for_each_zone(zone) {
 		unsigned long pfn, max_zone_pfn;
 
-		if (!is_highmem(zone))
+		if (!populated_zone(zone) || !is_highmem(zone))
 			continue;
 
 		mark_free_pages(zone);
@@ -1305,8 +1308,8 @@ static unsigned int count_data_pages(void)
 	unsigned long pfn, max_zone_pfn;
 	unsigned int n = 0;
 
-	for_each_populated_zone(zone) {
-		if (is_highmem(zone))
+	for_each_zone(zone) {
+		if (!populated_zone(zone) || is_highmem(zone))
 			continue;
 
 		mark_free_pages(zone);
@@ -1399,9 +1402,12 @@ static void copy_data_pages(struct memory_bitmap *copy_bm,
 	struct zone *zone;
 	unsigned long pfn;
 
-	for_each_populated_zone(zone) {
+	for_each_zone(zone) {
 		unsigned long max_zone_pfn;
 
+		if (!populated_zone(zone))
+			continue;
+
 		mark_free_pages(zone);
 		max_zone_pfn = zone_end_pfn(zone);
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
@@ -1717,7 +1723,10 @@ int hibernate_preallocate_memory(void)
 	saveable += save_highmem;
 	highmem = save_highmem;
 	size = 0;
-	for_each_populated_zone(zone) {
+	for_each_zone(zone) {
+		if (!populated_zone(zone))
+			continue;
+
 		size += snapshot_additional_pages(zone);
 		if (is_highmem(zone))
 			highmem += zone_page_state(zone, NR_FREE_PAGES);
@@ -1863,8 +1872,8 @@ static int enough_free_mem(unsigned int nr_pages, unsigned int nr_highmem)
 	struct zone *zone;
 	unsigned int free = alloc_normal;
 
-	for_each_populated_zone(zone)
-		if (!is_highmem(zone))
+	for_each_zone(zone)
+		if (populated_zone(zone) && !is_highmem(zone))
 			free += zone_page_state(zone, NR_FREE_PAGES);
 
 	nr_pages += count_pages_for_highmem(nr_highmem);
diff --git a/mm/compaction.c b/mm/compaction.c
index 7c607479de4a..8867c011dd45 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -276,7 +276,7 @@ void reset_isolation_suitable(pg_data_t *pgdat)
 
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 		struct zone *zone = &pgdat->node_zones[zoneid];
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		/* Only flush if a full compaction finished recently */
@@ -1832,7 +1832,7 @@ static void compact_node(int nid)
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 
 		zone = &pgdat->node_zones[zoneid];
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		cc.nr_freepages = 0;
@@ -1927,7 +1927,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
 		zone = &pgdat->node_zones[zoneid];
 
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
@@ -1963,7 +1963,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		int status;
 
 		zone = &pgdat->node_zones[zoneid];
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		if (compaction_deferred(zone, cc.order))
diff --git a/mm/highmem.c b/mm/highmem.c
index 59db3223a5d6..1edc0539d25a 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -111,15 +111,14 @@ EXPORT_SYMBOL(totalhigh_pages);
 
 EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
 
-unsigned int nr_free_highpages (void)
+unsigned int nr_free_highpages(void)
 {
 	struct zone *zone;
 	unsigned int pages = 0;
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone)
 		if (is_highmem(zone))
 			pages += zone_page_state(zone, NR_FREE_PAGES);
-	}
 
 	return pages;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4e4ef8fa479d..d0f97b29c96f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2829,7 +2829,7 @@ static int split_huge_pages_set(void *data, u64 val)
 	if (val != 1)
 		return -EINVAL;
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		max_zone_pfn = zone_end_pfn(zone);
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++) {
 			if (!pfn_valid(pfn))
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index c13625c1ad5e..4c3ec240d4d9 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1845,7 +1845,7 @@ static void set_recommended_min_free_kbytes(void)
 	int nr_zones = 0;
 	unsigned long recommended_min;
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		/*
 		 * We don't need to worry about fragmentation of
 		 * ZONE_MOVABLE since it only has movable pages.
diff --git a/mm/madvise.c b/mm/madvise.c
index 6cb1ca93e290..3a8eced61107 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -677,7 +677,7 @@ static int madvise_inject_error(int behavior,
 	}
 
 	/* Ensure that all poisoned pages are removed from per-cpu lists */
-	for_each_populated_zone(zone)
+	for_each_managed_zone(zone)
 		drain_all_pages(zone);
 
 	return 0;
diff --git a/mm/migrate.c b/mm/migrate.c
index f7e4bfdc13b7..5c4846dd0ae3 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1819,7 +1819,7 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
 	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
 		struct zone *zone = pgdat->node_zones + z;
 
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		/* Avoid waking kswapd by allocating pages_to_migrate pages. */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3f690bae6b78..076f51e86149 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -281,7 +281,7 @@ static unsigned long node_dirtyable_memory(struct pglist_data *pgdat)
 	for (z = 0; z < MAX_NR_ZONES; z++) {
 		struct zone *zone = pgdat->node_zones + z;
 
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		nr_pages += zone_page_state(zone, NR_FREE_PAGES);
@@ -316,7 +316,7 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 				continue;
 
 			z = &NODE_DATA(node)->node_zones[i];
-			if (!populated_zone(z))
+			if (!managed_zone(z))
 				continue;
 
 			nr_pages = zone_page_state(z, NR_FREE_PAGES);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c20d3c76bd59..458bd81cf75c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1747,7 +1747,7 @@ void __init page_alloc_init_late(void)
 	memblock_discard();
 #endif
 
-	for_each_populated_zone(zone)
+	for_each_managed_zone(zone)
 		set_zone_contiguous(zone);
 }
 
@@ -2569,9 +2569,8 @@ static void drain_pages(unsigned int cpu)
 {
 	struct zone *zone;
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone)
 		drain_pages_zone(cpu, zone);
-	}
 }
 
 /*
@@ -2655,7 +2654,7 @@ void drain_all_pages(struct zone *zone)
 			if (pcp->pcp.count)
 				has_pcps = true;
 		} else {
-			for_each_populated_zone(z) {
+			for_each_managed_zone(z) {
 				pcp = per_cpu_ptr(z->pageset, cpu);
 				if (pcp->pcp.count) {
 					has_pcps = true;
@@ -4857,7 +4856,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 	struct zone *zone;
 	pg_data_t *pgdat;
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		if (show_mem_node_skip(filter, zone_to_nid(zone), nodemask))
 			continue;
 
@@ -4940,7 +4939,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 				"yes" : "no");
 	}
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		int i;
 
 		if (show_mem_node_skip(filter, zone_to_nid(zone), nodemask))
@@ -4999,7 +4998,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		printk(KERN_CONT "\n");
 	}
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		unsigned int order;
 		unsigned long nr[MAX_ORDER], flags, total = 0;
 		unsigned char types[MAX_ORDER];
@@ -5787,7 +5786,7 @@ void __init setup_per_cpu_pageset(void)
 	struct pglist_data *pgdat;
 	struct zone *zone;
 
-	for_each_populated_zone(zone)
+	for_each_managed_zone(zone)
 		setup_zone_pageset(zone);
 
 	for_each_online_pgdat(pgdat)
@@ -6905,7 +6904,7 @@ static void check_for_memory(pg_data_t *pgdat, int nid)
 
 	for (zone_type = 0; zone_type <= ZONE_MOVABLE - 1; zone_type++) {
 		struct zone *zone = &pgdat->node_zones[zone_type];
-		if (populated_zone(zone)) {
+		if (managed_zone(zone)) {
 			if (IS_ENABLED(CONFIG_HIGHMEM))
 				node_set_state(nid, N_HIGH_MEMORY);
 			if (zone_type <= ZONE_NORMAL)
@@ -7581,7 +7580,7 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
 	if (percpu_pagelist_fraction == old_percpu_pagelist_fraction)
 		goto out;
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		unsigned int cpu;
 
 		for_each_possible_cpu(cpu)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6038ce593ce3..06cd9e9ecba1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -53,7 +53,7 @@ static void zero_zones_numa_counters(void)
 {
 	struct zone *zone;
 
-	for_each_populated_zone(zone)
+	for_each_managed_zone(zone)
 		zero_zone_numa_counters(zone);
 }
 
@@ -256,7 +256,7 @@ void refresh_zone_stat_thresholds(void)
 		}
 	}
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		struct pglist_data *pgdat = zone->zone_pgdat;
 		unsigned long max_drift, tolerate_drift;
 
@@ -753,7 +753,7 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 	int changes = 0;
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		struct per_cpu_pageset __percpu *p = zone->pageset;
 
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
@@ -854,7 +854,7 @@ void cpu_vm_stats_fold(int cpu)
 #endif
 	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		struct per_cpu_pageset *p;
 
 		p = per_cpu_ptr(zone->pageset, cpu);
@@ -1578,8 +1578,8 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, ", %ld", zone->lowmem_reserve[i]);
 	seq_putc(m, ')');
 
-	/* If unpopulated, no other information is useful */
-	if (!populated_zone(zone)) {
+	/* If unmanaged, no other information is useful */
+	if (!managed_zone(zone)) {
 		seq_putc(m, '\n');
 		return;
 	}
@@ -1817,7 +1817,7 @@ static bool need_update(int cpu)
 {
 	struct zone *zone;
 
-	for_each_populated_zone(zone) {
+	for_each_managed_zone(zone) {
 		struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
 
 		BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
-- 
2.15.1
