Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A39A8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:43:01 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u195-v6so5991421ith.2
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:43:01 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 124-v6si11714385itu.102.2018.09.10.17.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 17:42:59 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 2/8] mm: make zone_reclaim_stat updates thread-safe
Date: Mon, 10 Sep 2018 20:42:34 -0400
Message-Id: <20180911004240.4758-3-daniel.m.jordan@oracle.com>
In-Reply-To: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com

lru_lock needs to be held to update the zone_reclaim_stat statistics.
Similar to the previous patch, this requirement again arises fairly
naturally because callers are holding lru_lock already.

In preparation for allowing concurrent adds and removes from the LRU,
however, make concurrent updates to these statistics safe without
lru_lock.  The lock continues to be held until later in the series, when
it is replaced with a rwlock that also disables preemption, maintaining
the assumption in the comment above __update_page_reclaim_stat, which is
introduced here.

Use a combination of per-cpu counters and atomics.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/mmzone.h | 50 ++++++++++++++++++++++++++++++++++++++++++
 init/main.c            |  1 +
 mm/memcontrol.c        | 20 ++++++++---------
 mm/memory_hotplug.c    |  1 +
 mm/mmzone.c            | 14 ++++++++++++
 mm/swap.c              | 14 ++++++++----
 mm/vmscan.c            | 42 ++++++++++++++++++++---------------
 7 files changed, 110 insertions(+), 32 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2dc52a..6d4c23a3069d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -229,6 +229,12 @@ struct zone_reclaim_stat {
 	 *
 	 * The anon LRU stats live in [0], file LRU stats in [1]
 	 */
+	atomic_long_t		recent_rotated[2];
+	atomic_long_t		recent_scanned[2];
+};
+
+/* These spill into the counters in struct zone_reclaim_stat beyond a cutoff. */
+struct zone_reclaim_stat_cpu {
 	unsigned long		recent_rotated[2];
 	unsigned long		recent_scanned[2];
 };
@@ -236,6 +242,7 @@ struct zone_reclaim_stat {
 struct lruvec {
 	struct list_head		lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat	reclaim_stat;
+	struct zone_reclaim_stat_cpu __percpu *reclaim_stat_cpu;
 	/* Evictions & activations on the inactive file list */
 	atomic_long_t			inactive_age;
 	/* Refaults at the time of last reclaim cycle */
@@ -245,6 +252,47 @@ struct lruvec {
 #endif
 };
 
+#define	RECLAIM_STAT_BATCH	32U	/* From SWAP_CLUSTER_MAX */
+
+/*
+ * Callers of the below three functions that update reclaim stats must hold
+ * lru_lock and have preemption disabled.  Use percpu counters that spill into
+ * atomics to allow concurrent updates when multiple readers hold lru_lock.
+ */
+
+static inline void __update_page_reclaim_stat(unsigned long count,
+					      unsigned long *percpu_stat,
+					      atomic_long_t *stat)
+{
+	unsigned long val = *percpu_stat + count;
+
+	if (unlikely(val > RECLAIM_STAT_BATCH)) {
+		atomic_long_add(val, stat);
+		val = 0;
+	}
+	*percpu_stat = val;
+}
+
+static inline void update_reclaim_stat_scanned(struct lruvec *lruvec, int file,
+					       unsigned long count)
+{
+	struct zone_reclaim_stat_cpu __percpu *percpu_stat =
+					 this_cpu_ptr(lruvec->reclaim_stat_cpu);
+
+	__update_page_reclaim_stat(count, &percpu_stat->recent_scanned[file],
+				   &lruvec->reclaim_stat.recent_scanned[file]);
+}
+
+static inline void update_reclaim_stat_rotated(struct lruvec *lruvec, int file,
+					       unsigned long count)
+{
+	struct zone_reclaim_stat_cpu __percpu *percpu_stat =
+					 this_cpu_ptr(lruvec->reclaim_stat_cpu);
+
+	__update_page_reclaim_stat(count, &percpu_stat->recent_rotated[file],
+				   &lruvec->reclaim_stat.recent_rotated[file]);
+}
+
 /* Mask used at gathering information at once (see memcontrol.c) */
 #define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
@@ -795,6 +843,8 @@ extern void init_currently_empty_zone(struct zone *zone, unsigned long start_pfn
 				     unsigned long size);
 
 extern void lruvec_init(struct lruvec *lruvec);
+extern void lruvec_init_late(struct lruvec *lruvec);
+extern void lruvecs_init_late(void);
 
 static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
 {
diff --git a/init/main.c b/init/main.c
index 3b4ada11ed52..80ad02fe99de 100644
--- a/init/main.c
+++ b/init/main.c
@@ -526,6 +526,7 @@ static void __init mm_init(void)
 	init_espfix_bsp();
 	/* Should be run after espfix64 is set up. */
 	pti_init();
+	lruvecs_init_late();
 }
 
 asmlinkage __visible void __init start_kernel(void)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5463ad160e10..f7f9682482cd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3152,22 +3152,22 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		pg_data_t *pgdat;
 		struct mem_cgroup_per_node *mz;
 		struct zone_reclaim_stat *rstat;
-		unsigned long recent_rotated[2] = {0, 0};
-		unsigned long recent_scanned[2] = {0, 0};
+		unsigned long rota[2] = {0, 0};
+		unsigned long scan[2] = {0, 0};
 
 		for_each_online_pgdat(pgdat) {
 			mz = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
 			rstat = &mz->lruvec.reclaim_stat;
 
-			recent_rotated[0] += rstat->recent_rotated[0];
-			recent_rotated[1] += rstat->recent_rotated[1];
-			recent_scanned[0] += rstat->recent_scanned[0];
-			recent_scanned[1] += rstat->recent_scanned[1];
+			rota[0] += atomic_long_read(&rstat->recent_rotated[0]);
+			rota[1] += atomic_long_read(&rstat->recent_rotated[1]);
+			scan[0] += atomic_long_read(&rstat->recent_scanned[0]);
+			scan[1] += atomic_long_read(&rstat->recent_scanned[1]);
 		}
-		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[0]);
-		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[1]);
-		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[0]);
-		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[1]);
+		seq_printf(m, "recent_rotated_anon %lu\n", rota[0]);
+		seq_printf(m, "recent_rotated_file %lu\n", rota[1]);
+		seq_printf(m, "recent_scanned_anon %lu\n", scan[0]);
+		seq_printf(m, "recent_scanned_file %lu\n", scan[1]);
 	}
 #endif
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 25982467800b..d3ebb11c3f9f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1009,6 +1009,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	/* init node's zones as empty zones, we don't have any present pages.*/
 	free_area_init_node(nid, zones_size, start_pfn, zholes_size);
 	pgdat->per_cpu_nodestats = alloc_percpu(struct per_cpu_nodestat);
+	lruvec_init_late(node_lruvec(pgdat));
 
 	/*
 	 * The node we allocated has no zone fallback lists. For avoiding
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 4686fdc23bb9..090cd4f7effb 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -9,6 +9,7 @@
 #include <linux/stddef.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
+#include <linux/percpu.h>
 
 struct pglist_data *first_online_pgdat(void)
 {
@@ -96,6 +97,19 @@ void lruvec_init(struct lruvec *lruvec)
 		INIT_LIST_HEAD(&lruvec->lists[lru]);
 }
 
+void lruvec_init_late(struct lruvec *lruvec)
+{
+	lruvec->reclaim_stat_cpu = alloc_percpu(struct zone_reclaim_stat_cpu);
+}
+
+void lruvecs_init_late(void)
+{
+	pg_data_t *pgdat;
+
+	for_each_online_pgdat(pgdat)
+		lruvec_init_late(node_lruvec(pgdat));
+}
+
 #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_CPUPID_NOT_IN_PAGE_FLAGS)
 int page_cpupid_xchg_last(struct page *page, int cpupid)
 {
diff --git a/mm/swap.c b/mm/swap.c
index 3dd518832096..219c234d632f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -34,6 +34,7 @@
 #include <linux/uio.h>
 #include <linux/hugetlb.h>
 #include <linux/page_idle.h>
+#include <linux/mmzone.h>
 
 #include "internal.h"
 
@@ -260,14 +261,19 @@ void rotate_reclaimable_page(struct page *page)
 	}
 }
 
+/*
+ * Updates page reclaim statistics using per-cpu counters that spill into
+ * atomics above a threshold.
+ *
+ * Assumes that the caller has disabled preemption.  IRQs may be enabled
+ * because this function is not called from irq context.
+ */
 static void update_page_reclaim_stat(struct lruvec *lruvec,
 				     int file, int rotated)
 {
-	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-
-	reclaim_stat->recent_scanned[file]++;
+	update_reclaim_stat_scanned(lruvec, file, 1);
 	if (rotated)
-		reclaim_stat->recent_rotated[file]++;
+		update_reclaim_stat_rotated(lruvec, file, 1);
 }
 
 static void __activate_page(struct page *page, struct lruvec *lruvec,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9270a4370d54..730b6d0c6c61 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1655,7 +1655,6 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 static noinline_for_stack void
 putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 {
-	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	LIST_HEAD(pages_to_free);
 
@@ -1684,7 +1683,7 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
 			int numpages = hpage_nr_pages(page);
-			reclaim_stat->recent_rotated[file] += numpages;
+			update_reclaim_stat_rotated(lruvec, file, numpages);
 		}
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
@@ -1736,7 +1735,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
-	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	bool stalled = false;
 
 	while (unlikely(too_many_isolated(pgdat, file, sc))) {
@@ -1763,7 +1761,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 				     &nr_scanned, sc, isolate_mode, lru);
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
-	reclaim_stat->recent_scanned[file] += nr_taken;
+	update_reclaim_stat_scanned(lruvec, file, nr_taken);
 
 	if (current_is_kswapd()) {
 		if (global_reclaim(sc))
@@ -1914,7 +1912,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
 	struct page *page;
-	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	unsigned nr_deactivate, nr_activate;
 	unsigned nr_rotated = 0;
 	isolate_mode_t isolate_mode = 0;
@@ -1932,7 +1929,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 				     &nr_scanned, sc, isolate_mode, lru);
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
-	reclaim_stat->recent_scanned[file] += nr_taken;
+	update_reclaim_stat_scanned(lruvec, file, nr_taken);
 
 	__count_vm_events(PGREFILL, nr_scanned);
 	count_memcg_events(lruvec_memcg(lruvec), PGREFILL, nr_scanned);
@@ -1989,7 +1986,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 * helps balance scan pressure between file and anonymous pages in
 	 * get_scan_count.
 	 */
-	reclaim_stat->recent_rotated[file] += nr_rotated;
+	update_reclaim_stat_rotated(lruvec, file, nr_rotated);
 
 	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
@@ -2116,7 +2113,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			   unsigned long *lru_pages)
 {
 	int swappiness = mem_cgroup_swappiness(memcg);
-	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	struct zone_reclaim_stat *rstat = &lruvec->reclaim_stat;
 	u64 fraction[2];
 	u64 denominator = 0;	/* gcc */
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
@@ -2125,6 +2122,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	unsigned long anon, file;
 	unsigned long ap, fp;
 	enum lru_list lru;
+	long recent_scanned[2], recent_rotated[2];
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
@@ -2238,14 +2236,22 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES);
 
 	spin_lock_irq(&pgdat->lru_lock);
-	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
-		reclaim_stat->recent_scanned[0] /= 2;
-		reclaim_stat->recent_rotated[0] /= 2;
+	recent_scanned[0] = atomic_long_read(&rstat->recent_scanned[0]);
+	recent_rotated[0] = atomic_long_read(&rstat->recent_rotated[0]);
+	if (unlikely(recent_scanned[0] > anon / 4)) {
+		recent_scanned[0] /= 2;
+		recent_rotated[0] /= 2;
+		atomic_long_set(&rstat->recent_scanned[0], recent_scanned[0]);
+		atomic_long_set(&rstat->recent_rotated[0], recent_rotated[0]);
 	}
 
-	if (unlikely(reclaim_stat->recent_scanned[1] > file / 4)) {
-		reclaim_stat->recent_scanned[1] /= 2;
-		reclaim_stat->recent_rotated[1] /= 2;
+	recent_scanned[1] = atomic_long_read(&rstat->recent_scanned[1]);
+	recent_rotated[1] = atomic_long_read(&rstat->recent_rotated[1]);
+	if (unlikely(recent_scanned[1] > file / 4)) {
+		recent_scanned[1] /= 2;
+		recent_rotated[1] /= 2;
+		atomic_long_set(&rstat->recent_scanned[1], recent_scanned[1]);
+		atomic_long_set(&rstat->recent_rotated[1], recent_rotated[1]);
 	}
 
 	/*
@@ -2253,11 +2259,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * proportional to the fraction of recently scanned pages on
 	 * each list that were recently referenced and in active use.
 	 */
-	ap = anon_prio * (reclaim_stat->recent_scanned[0] + 1);
-	ap /= reclaim_stat->recent_rotated[0] + 1;
+	ap = anon_prio * (recent_scanned[0] + 1);
+	ap /= recent_rotated[0] + 1;
 
-	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
-	fp /= reclaim_stat->recent_rotated[1] + 1;
+	fp = file_prio * (recent_scanned[1] + 1);
+	fp /= recent_rotated[1] + 1;
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	fraction[0] = ap;
-- 
2.18.0
