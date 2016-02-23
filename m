Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D3A5E6B0258
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:45:29 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so222884857wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:45:29 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id s1si21290244wjf.66.2016.02.23.05.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:45:18 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id C11511C1881
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:45:17 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/27] mm, vmscan: Move LRU lists to node
Date: Tue, 23 Feb 2016 13:44:54 +0000
Message-Id: <1456235116-32385-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
References: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This moves the LRU lists from the zone to the node and all related data
such as counters, tracing, congestion tracking and writeback tracking.
This is mostly a mechanical patch but note that it introduces a number
of anomalies. For example, the scans are per-zone but using per-node
counters. We also mark a node as congested when a zone is congested. This
causes weird problems that are fixed later but is easier to review.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 arch/tile/mm/pgtable.c                    |   8 +-
 drivers/base/node.c                       |  19 +--
 drivers/staging/android/lowmemorykiller.c |   8 +-
 include/linux/backing-dev.h               |   2 +-
 include/linux/memcontrol.h                |   8 +-
 include/linux/mm_inline.h                 |   4 +-
 include/linux/mmzone.h                    |  66 ++++++----
 include/linux/swap.h                      |   2 +-
 include/linux/vm_event_item.h             |  10 +-
 include/linux/vmstat.h                    |  18 +++
 include/trace/events/vmscan.h             |  12 +-
 kernel/power/snapshot.c                   |  10 +-
 mm/backing-dev.c                          |  15 ++-
 mm/compaction.c                           |  18 +--
 mm/huge_memory.c                          |   6 +-
 mm/internal.h                             |   2 +-
 mm/memcontrol.c                           |  18 +--
 mm/memory-failure.c                       |   4 +-
 mm/memory_hotplug.c                       |   2 +-
 mm/mempolicy.c                            |   2 +-
 mm/migrate.c                              |  21 +--
 mm/mlock.c                                |   2 +-
 mm/page-writeback.c                       |   8 +-
 mm/page_alloc.c                           |  99 ++++++++------
 mm/swap.c                                 |  56 ++++----
 mm/vmscan.c                               | 210 ++++++++++++++++--------------
 mm/vmstat.c                               |  45 +++----
 27 files changed, 368 insertions(+), 307 deletions(-)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 7bf2491a9c1f..3ed0a666d44a 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -45,10 +45,10 @@ void show_mem(unsigned int filter)
 	struct zone *zone;
 
 	pr_err("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
-	       (global_page_state(NR_ACTIVE_ANON) +
-		global_page_state(NR_ACTIVE_FILE)),
-	       (global_page_state(NR_INACTIVE_ANON) +
-		global_page_state(NR_INACTIVE_FILE)),
+	       (global_node_page_state(NR_ACTIVE_ANON) +
+		global_node_page_state(NR_ACTIVE_FILE)),
+	       (global_node_page_state(NR_INACTIVE_ANON) +
+		global_node_page_state(NR_INACTIVE_FILE)),
 	       global_page_state(NR_FILE_DIRTY),
 	       global_page_state(NR_WRITEBACK),
 	       global_page_state(NR_UNSTABLE_NFS),
diff --git a/drivers/base/node.c b/drivers/base/node.c
index efb81da250a8..4260c7f3ee1b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -56,6 +56,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 {
 	int n;
 	int nid = dev->id;
+	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct sysinfo i;
 
 	si_meminfo_node(&i, nid);
@@ -74,15 +75,15 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
-		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON) +
-				sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON) +
-				sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_ANON)),
-		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_ANON)),
-		       nid, K(sum_zone_node_page_state(nid, NR_ACTIVE_FILE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_UNEVICTABLE)),
+		       nid, K(node_page_state(pgdat, NR_ACTIVE_ANON) +
+				node_page_state(pgdat, NR_ACTIVE_FILE)),
+		       nid, K(node_page_state(pgdat, NR_INACTIVE_ANON) +
+				node_page_state(pgdat, NR_INACTIVE_FILE)),
+		       nid, K(node_page_state(pgdat, NR_ACTIVE_ANON)),
+		       nid, K(node_page_state(pgdat, NR_INACTIVE_ANON)),
+		       nid, K(node_page_state(pgdat, NR_ACTIVE_FILE)),
+		       nid, K(node_page_state(pgdat, NR_INACTIVE_FILE)),
+		       nid, K(node_page_state(pgdat, NR_UNEVICTABLE)),
 		       nid, K(sum_zone_node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 4b8a56cda6ca..7d677791d13a 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -70,10 +70,10 @@ static unsigned long lowmem_deathpending_timeout;
 static unsigned long lowmem_count(struct shrinker *s,
 				  struct shrink_control *sc)
 {
-	return global_page_state(NR_ACTIVE_ANON) +
-		global_page_state(NR_ACTIVE_FILE) +
-		global_page_state(NR_INACTIVE_ANON) +
-		global_page_state(NR_INACTIVE_FILE);
+	return global_node_page_state(NR_ACTIVE_ANON) +
+		global_node_page_state(NR_ACTIVE_FILE) +
+		global_node_page_state(NR_INACTIVE_ANON) +
+		global_node_page_state(NR_INACTIVE_FILE);
 }
 
 static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index c82794f20110..491a91717788 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -197,7 +197,7 @@ static inline int wb_congested(struct bdi_writeback *wb, int cong_bits)
 }
 
 long congestion_wait(int sync, long timeout);
-long wait_iff_congested(struct zone *zone, int sync, long timeout);
+long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout);
 int pdflush_proc_obsolete(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp, loff_t *ppos);
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1191d79aa495..f5626a5c88c2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -307,7 +307,7 @@ void mem_cgroup_uncharge_list(struct list_head *page_list);
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
-struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
+struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
@@ -595,13 +595,13 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
 static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 						    struct mem_cgroup *memcg)
 {
-	return &zone->lruvec;
+	return zone_lruvec(zone);
 }
 
 static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
-						    struct zone *zone)
+						    struct pglist_data *pgdat)
 {
-	return &zone->lruvec;
+	return &pgdat->lruvec;
 }
 
 static inline bool mm_match_cgroup(struct mm_struct *mm,
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 712e8c37a200..5817ae41ba30 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -28,7 +28,7 @@ static __always_inline void add_page_to_lru_list(struct page *page,
 	int nr_pages = hpage_nr_pages(page);
 	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
 	list_add(&page->lru, &lruvec->lists[lru]);
-	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
+	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_LRU_BASE + lru, nr_pages);
 }
 
 static __always_inline void del_page_from_lru_list(struct page *page,
@@ -37,7 +37,7 @@ static __always_inline void del_page_from_lru_list(struct page *page,
 	int nr_pages = hpage_nr_pages(page);
 	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
 	list_del(&page->lru);
-	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, -nr_pages);
+	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_LRU_BASE + lru, -nr_pages);
 }
 
 /**
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 86539225067e..93151a9a4f56 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -118,12 +118,6 @@ enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
 	NR_ALLOC_BATCH,
-	NR_LRU_BASE,
-	NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
-	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
-	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
-	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
-	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
@@ -141,12 +135,9 @@ enum zone_stat_item {
 	NR_VMSCAN_WRITE,
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
-	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
-	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
-	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
@@ -163,6 +154,15 @@ enum zone_stat_item {
 	NR_VM_ZONE_STAT_ITEMS };
 
 enum node_stat_item {
+	NR_LRU_BASE,
+	NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
+	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
+	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
+	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
+	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
+	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
+	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
+	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
 	NR_VM_NODE_STAT_ITEMS
 };
 
@@ -221,7 +221,7 @@ struct lruvec {
 	/* Evictions & activations on the inactive file list */
 	atomic_long_t			inactive_age;
 #ifdef CONFIG_MEMCG
-	struct zone			*zone;
+	struct pglist_data *pgdat;
 #endif
 };
 
@@ -359,13 +359,6 @@ struct zone {
 #ifdef CONFIG_NUMA
 	int node;
 #endif
-
-	/*
-	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
-	 * this zone's LRU.  Maintained by the pageout code.
-	 */
-	unsigned int inactive_ratio;
-
 	struct pglist_data	*zone_pgdat;
 	struct per_cpu_pageset __percpu *pageset;
 
@@ -497,9 +490,6 @@ struct zone {
 
 	/* Write-intensive fields used by page reclaim */
 
-	/* Fields commonly accessed by the page reclaim scanner */
-	struct lruvec		lruvec;
-
 	/*
 	 * When free pages are below this point, additional steps are taken
 	 * when reading the number of free pages to avoid per-cpu counter
@@ -540,17 +530,20 @@ struct zone {
 enum zone_flags {
 	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
-	ZONE_CONGESTED,			/* zone has many dirty pages backed by
+	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
+};
+
+enum pgdat_flags {
+	PGDAT_CONGESTED,		/* zone has many dirty pages backed by
 					 * a congested BDI
 					 */
-	ZONE_DIRTY,			/* reclaim scanning has recently found
+	PGDAT_DIRTY,			/* reclaim scanning has recently found
 					 * many dirty file pages at the tail
 					 * of the LRU.
 					 */
-	ZONE_WRITEBACK,			/* reclaim scanning has recently found
+	PGDAT_WRITEBACK,		/* reclaim scanning has recently found
 					 * many pages under writeback
 					 */
-	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 };
 
 static inline unsigned long zone_end_pfn(const struct zone *zone)
@@ -704,12 +697,26 @@ typedef struct pglist_data {
 	unsigned long first_deferred_pfn;
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	spinlock_t split_queue_lock;
 	struct list_head split_queue;
 	unsigned long split_queue_len;
 #endif
 
+	/* Fields commonly accessed by the page reclaim scanner */
+	struct lruvec		lruvec;
+
+	/*
+	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
+	 * this node's LRU.  Maintained by the pageout code.
+	 */
+	unsigned int inactive_ratio;
+
+	unsigned long		flags;
+
+	ZONE_PADDING(_pad2_)
+
 	/* Per-node vmstats */
 	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
 	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
@@ -731,6 +738,11 @@ static inline spinlock_t *zone_lru_lock(struct zone *zone)
 	return &zone->zone_pgdat->lru_lock;
 }
 
+static inline struct lruvec *zone_lruvec(struct zone *zone)
+{
+	return &zone->zone_pgdat->lruvec;
+}
+
 static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
 {
 	return pgdat->node_start_pfn + pgdat->node_spanned_pages;
@@ -778,12 +790,12 @@ extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
 
 extern void lruvec_init(struct lruvec *lruvec);
 
-static inline struct zone *lruvec_zone(struct lruvec *lruvec)
+static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
 {
 #ifdef CONFIG_MEMCG
-	return lruvec->zone;
+	return lruvec->pgdat;
 #else
-	return container_of(lruvec, struct zone, lruvec);
+	return container_of(lruvec, struct pglist_data, lruvec);
 #endif
 }
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b14a2bb33514..a776f6506522 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -316,7 +316,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 						struct vm_area_struct *vma);
 
 /* linux/mm/vmscan.c */
-extern unsigned long zone_reclaimable_pages(struct zone *zone);
+extern unsigned long pgdat_reclaimable_pages(pg_data_t *pgdat);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index ec084321fe09..8dcb5a813163 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -26,11 +26,11 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
 		PGLAZYFREED,
-		FOR_ALL_ZONES(PGREFILL),
-		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
-		FOR_ALL_ZONES(PGSTEAL_DIRECT),
-		FOR_ALL_ZONES(PGSCAN_KSWAPD),
-		FOR_ALL_ZONES(PGSCAN_DIRECT),
+		PGREFILL,
+		PGSTEAL_KSWAPD,
+		PGSTEAL_DIRECT,
+		PGSCAN_KSWAPD,
+		PGSCAN_DIRECT,
 		PGSCAN_DIRECT_THROTTLE,
 #ifdef CONFIG_NUMA
 		PGSCAN_ZONE_RECLAIM_FAILED,
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index d9f8889263b6..8a43f7b80c20 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -178,6 +178,23 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
 	return x;
 }
 
+static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
+					enum zone_stat_item item)
+{
+	long x = atomic_long_read(&pgdat->vm_stat[item]);
+
+#ifdef CONFIG_SMP
+	int cpu;
+	for_each_online_cpu(cpu)
+		x += per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->vm_node_stat_diff[item];
+
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
+
 #ifdef CONFIG_NUMA
 extern unsigned long sum_zone_node_page_state(int node,
 						enum zone_stat_item item);
@@ -187,6 +204,7 @@ extern void zone_statistics(struct zone *, struct zone *, gfp_t gfp);
 
 #else
 
+#define sum_zone_node_page_state(node, item) global_node_page_state(item)
 #define node_page_state(node, item) global_node_page_state(item)
 #define zone_statistics(_zl, _z, gfp) do { } while (0)
 
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 0101ef37f1ee..897f1aa1ee5f 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -352,15 +352,14 @@ TRACE_EVENT(mm_vmscan_writepage,
 
 TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 
-	TP_PROTO(struct zone *zone,
+	TP_PROTO(int nid,
 		unsigned long nr_scanned, unsigned long nr_reclaimed,
 		int priority, int file),
 
-	TP_ARGS(zone, nr_scanned, nr_reclaimed, priority, file),
+	TP_ARGS(nid, nr_scanned, nr_reclaimed, priority, file),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
-		__field(int, zid)
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_reclaimed)
 		__field(int, priority)
@@ -368,16 +367,15 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 	),
 
 	TP_fast_assign(
-		__entry->nid = zone_to_nid(zone);
-		__entry->zid = zone_idx(zone);
+		__entry->nid = nid;
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_reclaimed = nr_reclaimed;
 		__entry->priority = priority;
 		__entry->reclaim_flags = trace_shrink_flags(file);
 	),
 
-	TP_printk("nid=%d zid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
-		__entry->nid, __entry->zid,
+	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
+		__entry->nid,
 		__entry->nr_scanned, __entry->nr_reclaimed,
 		__entry->priority,
 		show_reclaim_flags(__entry->reclaim_flags))
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 3a970604308f..24a06bc23f85 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1525,11 +1525,11 @@ static unsigned long minimum_image_size(unsigned long saveable)
 	unsigned long size;
 
 	size = global_page_state(NR_SLAB_RECLAIMABLE)
-		+ global_page_state(NR_ACTIVE_ANON)
-		+ global_page_state(NR_INACTIVE_ANON)
-		+ global_page_state(NR_ACTIVE_FILE)
-		+ global_page_state(NR_INACTIVE_FILE)
-		- global_page_state(NR_FILE_MAPPED);
+		+ global_node_page_state(NR_ACTIVE_ANON)
+		+ global_node_page_state(NR_INACTIVE_ANON)
+		+ global_node_page_state(NR_ACTIVE_FILE)
+		+ global_node_page_state(NR_INACTIVE_FILE)
+		- global_node_page_state(NR_FILE_MAPPED);
 
 	return saveable <= size ? 0 : saveable - size;
 }
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 5683592f79d5..b59d4ebdf54a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -982,24 +982,24 @@ long congestion_wait(int sync, long timeout)
 EXPORT_SYMBOL(congestion_wait);
 
 /**
- * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a zone to complete writes
- * @zone: A zone to check if it is heavily congested
+ * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a pgdat to complete writes
+ * @pgdat: A pgdat to check if it is heavily congested
  * @sync: SYNC or ASYNC IO
  * @timeout: timeout in jiffies
  *
  * In the event of a congested backing_dev (any backing_dev) and the given
- * @zone has experienced recent congestion, this waits for up to @timeout
+ * @pgdat has experienced recent congestion, this waits for up to @timeout
  * jiffies for either a BDI to exit congestion of the given @sync queue
  * or a write to complete.
  *
- * In the absence of zone congestion, cond_resched() is called to yield
+ * In the absence of pgdat congestion, cond_resched() is called to yield
  * the processor if necessary but otherwise does not sleep.
  *
  * The return value is 0 if the sleep is for the full timeout. Otherwise,
  * it is the number of jiffies that were still remaining when the function
  * returned. return_value == timeout implies the function did not sleep.
  */
-long wait_iff_congested(struct zone *zone, int sync, long timeout)
+long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout)
 {
 	long ret;
 	unsigned long start = jiffies;
@@ -1008,12 +1008,13 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 
 	/*
 	 * If there is no congestion, or heavy congestion is not being
-	 * encountered in the current zone, yield if necessary instead
+	 * encountered in the current pgdat, yield if necessary instead
 	 * of sleeping on the congestion queue
 	 */
 	if (atomic_read(&nr_wb_congested[sync]) == 0 ||
-	    !test_bit(ZONE_CONGESTED, &zone->flags)) {
+	    !test_bit(PGDAT_CONGESTED, &pgdat->flags)) {
 		cond_resched();
+
 		/* In case we scheduled, work out time remaining */
 		ret = timeout - (jiffies - start);
 		if (ret < 0)
diff --git a/mm/compaction.c b/mm/compaction.c
index c85bd016754f..2ae7c7ea664e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -591,8 +591,8 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 	list_for_each_entry(page, &cc->migratepages, lru)
 		count[!!page_is_file_cache(page)]++;
 
-	mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
-	mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
+	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON, count[0]);
+	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, count[1]);
 }
 
 /* Similar to reclaim, but different enough that they don't share logic */
@@ -600,12 +600,12 @@ static bool too_many_isolated(struct zone *zone)
 {
 	unsigned long active, inactive, isolated;
 
-	inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
-					zone_page_state(zone, NR_INACTIVE_ANON);
-	active = zone_page_state(zone, NR_ACTIVE_FILE) +
-					zone_page_state(zone, NR_ACTIVE_ANON);
-	isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
-					zone_page_state(zone, NR_ISOLATED_ANON);
+	inactive = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
+			node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
+	active = node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE) +
+			node_page_state(zone->zone_pgdat, NR_ACTIVE_ANON);
+	isolated = node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE) +
+			node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON);
 
 	return isolated > (inactive + active) / 2;
 }
@@ -767,7 +767,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			}
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, isolate_mode) != 0)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 59ca13bb13f9..709797510e10 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1995,7 +1995,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 static void release_pte_page(struct page *page)
 {
 	/* 0 stands for page_is_file_cache(page) == false */
-	dec_zone_page_state(page, NR_ISOLATED_ANON + 0);
+	dec_node_page_state(page, NR_ISOLATED_ANON + 0);
 	unlock_page(page);
 	putback_lru_page(page);
 }
@@ -2090,7 +2090,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			goto out;
 		}
 		/* 0 stands for page_is_file_cache(page) == false */
-		inc_zone_page_state(page, NR_ISOLATED_ANON + 0);
+		inc_node_page_state(page, NR_ISOLATED_ANON + 0);
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
@@ -3357,7 +3357,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(zone_lru_lock(zone));
-	lruvec = mem_cgroup_page_lruvec(head, zone);
+	lruvec = mem_cgroup_page_lruvec(head, zone->zone_pgdat);
 
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
diff --git a/mm/internal.h b/mm/internal.h
index f9153e580d81..08c996d7b8fc 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -84,7 +84,7 @@ extern unsigned long highest_memmap_pfn;
  */
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
-extern bool zone_reclaimable(struct zone *zone);
+extern bool pgdat_reclaimable(struct pglist_data *pgdat);
 
 /*
  * in mm/rmap.c:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c1acf0edd3b4..e9e35424c57e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -958,7 +958,7 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled()) {
-		lruvec = &zone->lruvec;
+		lruvec = zone_lruvec(zone);
 		goto out;
 	}
 
@@ -970,8 +970,8 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 	 * we have to be prepared to initialize lruvec->zone here;
 	 * and if offlined then reonlined, we need to reinitialize it.
 	 */
-	if (unlikely(lruvec->zone != zone))
-		lruvec->zone = zone;
+	if (unlikely(lruvec->pgdat != zone->zone_pgdat))
+		lruvec->pgdat = zone->zone_pgdat;
 	return lruvec;
 }
 
@@ -984,14 +984,14 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
  * and putback protocol: the LRU lock must be held, and the page must
  * either be PageLRU() or the caller must have isolated/allocated it.
  */
-struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
+struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgdat)
 {
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup *memcg;
 	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled()) {
-		lruvec = &zone->lruvec;
+		lruvec = &pgdat->lruvec;
 		goto out;
 	}
 
@@ -1011,8 +1011,8 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
 	 * we have to be prepared to initialize lruvec->zone here;
 	 * and if offlined then reonlined, we need to reinitialize it.
 	 */
-	if (unlikely(lruvec->zone != zone))
-		lruvec->zone = zone;
+	if (unlikely(lruvec->pgdat != pgdat))
+		lruvec->pgdat = pgdat;
 	return lruvec;
 }
 
@@ -2092,7 +2092,7 @@ static void lock_page_lru(struct page *page, int *isolated)
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		*isolated = 1;
@@ -2107,7 +2107,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 	if (isolated) {
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 67c30eb993f0..204709f9ae0f 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1657,7 +1657,7 @@ static int __soft_offline_page(struct page *page, int flags)
 	put_hwpoison_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
-		inc_zone_page_state(page, NR_ISOLATED_ANON +
+		inc_node_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
@@ -1665,7 +1665,7 @@ static int __soft_offline_page(struct page *page, int flags)
 		if (ret) {
 			if (!list_empty(&pagelist)) {
 				list_del(&page->lru);
-				dec_zone_page_state(page, NR_ISOLATED_ANON +
+				dec_node_page_state(page, NR_ISOLATED_ANON +
 						page_is_file_cache(page));
 				putback_lru_page(page);
 			}
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 92402f8d17e8..b33fe895a35c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1524,7 +1524,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			put_page(page);
 			list_add_tail(&page->lru, &source);
 			move_pages--;
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
+			inc_node_page_state(page, NR_ISOLATED_ANON +
 					    page_is_file_cache(page));
 
 		} else {
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8c5fd08c253c..4871e4d66c44 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -963,7 +963,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
 		if (!isolate_lru_page(page)) {
 			list_add_tail(&page->lru, pagelist);
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
+			inc_node_page_state(page, NR_ISOLATED_ANON +
 					    page_is_file_cache(page));
 		}
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index 90cbf7c65cac..aea3e350f4fc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -92,7 +92,7 @@ void putback_movable_pages(struct list_head *l)
 			continue;
 		}
 		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
+		dec_node_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		if (unlikely(isolated_balloon_page(page)))
 			balloon_page_putback(page);
@@ -969,7 +969,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		 * restored.
 		 */
 		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
+		dec_node_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		/* Soft-offlined page shouldn't go through lru cache list */
 		if (reason == MR_MEMORY_FAILURE) {
@@ -1291,7 +1291,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		err = isolate_lru_page(page);
 		if (!err) {
 			list_add_tail(&page->lru, &pagelist);
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
+			inc_node_page_state(page, NR_ISOLATED_ANON +
 					    page_is_file_cache(page));
 		}
 put_and_set:
@@ -1557,15 +1557,16 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
 				   unsigned long nr_migrate_pages)
 {
 	int z;
+
+	if (!pgdat_reclaimable(pgdat))
+		return false;
+
 	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
 		struct zone *zone = pgdat->node_zones + z;
 
 		if (!populated_zone(zone))
 			continue;
 
-		if (!zone_reclaimable(zone))
-			continue;
-
 		/* Avoid waking kswapd by allocating pages_to_migrate pages. */
 		if (!zone_watermark_ok(zone, 0,
 				       high_wmark_pages(zone) +
@@ -1659,7 +1660,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 	}
 
 	page_lru = page_is_file_cache(page);
-	mod_zone_page_state(page_zone(page), NR_ISOLATED_ANON + page_lru,
+	mod_node_page_state(page_zone(page)->zone_pgdat, NR_ISOLATED_ANON + page_lru,
 				hpage_nr_pages(page));
 
 	/*
@@ -1717,7 +1718,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	if (nr_remaining) {
 		if (!list_empty(&migratepages)) {
 			list_del(&page->lru);
-			dec_zone_page_state(page, NR_ISOLATED_ANON +
+			dec_node_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
 			putback_lru_page(page);
 		}
@@ -1807,7 +1808,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		/* Retake the callers reference and putback on LRU */
 		get_page(page);
 		putback_lru_page(page);
-		mod_zone_page_state(page_zone(page),
+		mod_node_page_state(page_zone(page)->zone_pgdat,
 			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
 
 		goto out_unlock;
@@ -1860,7 +1861,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-	mod_zone_page_state(page_zone(page),
+	mod_node_page_state(page_zone(page)->zone_pgdat,
 			NR_ISOLATED_ANON + page_lru,
 			-HPAGE_PMD_NR);
 	return isolated;
diff --git a/mm/mlock.c b/mm/mlock.c
index ce7dabd53e7e..40156665ccf0 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -103,7 +103,7 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, page_zone(page));
+		lruvec = mem_cgroup_page_lruvec(page, page_zone(page)->zone_pgdat);
 		if (getpage)
 			get_page(page);
 		ClearPageLRU(page);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 11ff8f758631..b0960ec94bc9 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -285,8 +285,8 @@ static unsigned long zone_dirtyable_memory(struct zone *zone)
 	 */
 	nr_pages -= min(nr_pages, zone->totalreserve_pages);
 
-	nr_pages += zone_page_state(zone, NR_INACTIVE_FILE);
-	nr_pages += zone_page_state(zone, NR_ACTIVE_FILE);
+	nr_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
+	nr_pages += node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
 
 	return nr_pages;
 }
@@ -344,8 +344,8 @@ static unsigned long global_dirtyable_memory(void)
 	 */
 	x -= min(x, totalreserve_pages);
 
-	x += global_page_state(NR_INACTIVE_FILE);
-	x += global_page_state(NR_ACTIVE_FILE);
+	x += global_node_page_state(NR_INACTIVE_FILE);
+	x += global_node_page_state(NR_ACTIVE_FILE);
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 288015b5ee24..b03c7b5872bf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -801,9 +801,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	unsigned long nr_scanned;
 
 	spin_lock(&zone->lock);
-	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
+	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
 	if (nr_scanned)
-		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
+		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
 
 	while (to_free) {
 		struct page *page;
@@ -855,9 +855,9 @@ static void free_one_page(struct zone *zone,
 {
 	unsigned long nr_scanned;
 	spin_lock(&zone->lock);
-	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
+	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
 	if (nr_scanned)
-		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
+		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
 
 	if (unlikely(has_isolate_pageblock(zone) ||
 		is_migrate_isolate(migratetype))) {
@@ -3131,7 +3131,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		unsigned long available;
 		unsigned long reclaimable;
 
-		available = reclaimable = zone_reclaimable_pages(zone);
+		available = reclaimable = pgdat_reclaimable_pages(zone->zone_pgdat);
 		available -= DIV_ROUND_UP(no_progress_loops * available,
 					  MAX_RECLAIM_RETRIES);
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
@@ -3914,6 +3914,7 @@ void show_free_areas(unsigned int filter)
 	unsigned long free_pcp = 0;
 	int cpu;
 	struct zone *zone;
+	pg_data_t *pgdat;
 
 	for_each_populated_zone(zone) {
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
@@ -3929,13 +3930,13 @@ void show_free_areas(unsigned int filter)
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
-		global_page_state(NR_ACTIVE_ANON),
-		global_page_state(NR_INACTIVE_ANON),
-		global_page_state(NR_ISOLATED_ANON),
-		global_page_state(NR_ACTIVE_FILE),
-		global_page_state(NR_INACTIVE_FILE),
-		global_page_state(NR_ISOLATED_FILE),
-		global_page_state(NR_UNEVICTABLE),
+		global_node_page_state(NR_ACTIVE_ANON),
+		global_node_page_state(NR_INACTIVE_ANON),
+		global_node_page_state(NR_ISOLATED_ANON),
+		global_node_page_state(NR_ACTIVE_FILE),
+		global_node_page_state(NR_INACTIVE_FILE),
+		global_node_page_state(NR_ISOLATED_FILE),
+		global_node_page_state(NR_UNEVICTABLE),
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
@@ -3949,6 +3950,28 @@ void show_free_areas(unsigned int filter)
 		free_pcp,
 		global_page_state(NR_FREE_CMA_PAGES));
 
+	for_each_online_pgdat(pgdat) {
+		printk("Node %d"
+			" active_anon:%lukB"
+			" inactive_anon:%lukB"
+			" active_file:%lukB"
+			" inactive_file:%lukB"
+			" unevictable:%lukB"
+			" isolated(anon):%lukB"
+			" isolated(file):%lukB"
+			" all_unreclaimable? %s"
+			"\n",
+			pgdat->node_id,
+			K(node_page_state(pgdat, NR_ACTIVE_ANON)),
+			K(node_page_state(pgdat, NR_INACTIVE_ANON)),
+			K(node_page_state(pgdat, NR_ACTIVE_FILE)),
+			K(node_page_state(pgdat, NR_INACTIVE_FILE)),
+			K(node_page_state(pgdat, NR_UNEVICTABLE)),
+			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
+			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
+			!pgdat_reclaimable(pgdat) ? "yes" : "no");
+	}
+
 	for_each_populated_zone(zone) {
 		int i;
 
@@ -3965,13 +3988,6 @@ void show_free_areas(unsigned int filter)
 			" min:%lukB"
 			" low:%lukB"
 			" high:%lukB"
-			" active_anon:%lukB"
-			" inactive_anon:%lukB"
-			" active_file:%lukB"
-			" inactive_file:%lukB"
-			" unevictable:%lukB"
-			" isolated(anon):%lukB"
-			" isolated(file):%lukB"
 			" present:%lukB"
 			" managed:%lukB"
 			" mlocked:%lukB"
@@ -3989,21 +4005,13 @@ void show_free_areas(unsigned int filter)
 			" local_pcp:%ukB"
 			" free_cma:%lukB"
 			" writeback_tmp:%lukB"
-			" pages_scanned:%lu"
-			" all_unreclaimable? %s"
+			" node_pages_scanned:%lu"
 			"\n",
 			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
 			K(high_wmark_pages(zone)),
-			K(zone_page_state(zone, NR_ACTIVE_ANON)),
-			K(zone_page_state(zone, NR_INACTIVE_ANON)),
-			K(zone_page_state(zone, NR_ACTIVE_FILE)),
-			K(zone_page_state(zone, NR_INACTIVE_FILE)),
-			K(zone_page_state(zone, NR_UNEVICTABLE)),
-			K(zone_page_state(zone, NR_ISOLATED_ANON)),
-			K(zone_page_state(zone, NR_ISOLATED_FILE)),
 			K(zone->present_pages),
 			K(zone->managed_pages),
 			K(zone_page_state(zone, NR_MLOCK)),
@@ -4022,9 +4030,7 @@ void show_free_areas(unsigned int filter)
 			K(this_cpu_read(zone->pageset->pcp.count)),
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
-			K(zone_page_state(zone, NR_PAGES_SCANNED)),
-			(!zone_reclaimable(zone) ? "yes" : "no")
-			);
+			K(node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
 			printk(" %ld", zone->lowmem_reserve[i]);
@@ -5579,7 +5585,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
-		lruvec_init(&zone->lruvec);
+		lruvec_init(zone_lruvec(zone));
 		if (!size)
 			continue;
 
@@ -6465,26 +6471,37 @@ void setup_per_zone_wmarks(void)
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-static void __meminit calculate_zone_inactive_ratio(struct zone *zone)
+static void __meminit calculate_node_inactive_ratio(struct pglist_data *pgdat)
 {
 	unsigned int gb, ratio;
+	int z;
+	unsigned long managed_pages = 0;
+
+	for (z = 0; z < MAX_NR_ZONES; z++) {
+		struct zone *zone = &pgdat->node_zones[z];
 
-	/* Zone size in gigabytes */
-	gb = zone->managed_pages >> (30 - PAGE_SHIFT);
+		if (!populated_zone(zone))
+			continue;
+
+		managed_pages += zone->managed_pages;
+	}
+
+	/* Node size in gigabytes */
+	gb = managed_pages >> (30 - PAGE_SHIFT);
 	if (gb)
 		ratio = int_sqrt(10 * gb);
 	else
 		ratio = 1;
 
-	zone->inactive_ratio = ratio;
+	pgdat->inactive_ratio = ratio;
 }
 
-static void __meminit setup_per_zone_inactive_ratio(void)
+static void __meminit setup_per_node_inactive_ratio(void)
 {
-	struct zone *zone;
+	struct pglist_data *pgdat;
 
-	for_each_zone(zone)
-		calculate_zone_inactive_ratio(zone);
+	for_each_online_pgdat(pgdat)
+		calculate_node_inactive_ratio(pgdat);
 }
 
 /*
@@ -6532,7 +6549,7 @@ int __meminit init_per_zone_wmark_min(void)
 	setup_per_zone_wmarks();
 	refresh_zone_stat_thresholds();
 	setup_per_zone_lowmem_reserve();
-	setup_per_zone_inactive_ratio();
+	setup_per_node_inactive_ratio();
 	return 0;
 }
 module_init(init_per_zone_wmark_min)
diff --git a/mm/swap.c b/mm/swap.c
index 4067911033e1..83d3fbd03316 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -60,7 +60,7 @@ static void __page_cache_release(struct page *page)
 		unsigned long flags;
 
 		spin_lock_irqsave(zone_lru_lock(zone), flags);
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
@@ -191,7 +191,7 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 			spin_lock_irqsave(zone_lru_lock(zone), flags);
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		(*move_fn)(page, lruvec, arg);
 	}
 	if (zone)
@@ -313,11 +313,11 @@ static bool need_activate_page_drain(int cpu)
 
 void activate_page(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct pglist_data *pgdat = page_zone(page)->zone_pgdat;
 
-	spin_lock_irq(zone_lru_lock(zone));
-	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
+	__activate_page(page, mem_cgroup_page_lruvec(page, pgdat), NULL);
+	spin_unlock_irq(&pgdat->lru_lock);
 }
 #endif
 
@@ -443,16 +443,16 @@ void lru_cache_add(struct page *page)
  */
 void add_page_to_unevictable_list(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct pglist_data *pgdat = page_zone(page)->zone_pgdat;
 	struct lruvec *lruvec;
 
-	spin_lock_irq(zone_lru_lock(zone));
-	lruvec = mem_cgroup_page_lruvec(page, zone);
+	spin_lock_irq(&pgdat->lru_lock);
+	lruvec = mem_cgroup_page_lruvec(page, pgdat);
 	ClearPageActive(page);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
 	add_page_to_lru_list(page, lruvec, LRU_UNEVICTABLE);
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&pgdat->lru_lock);
 }
 
 /**
@@ -710,7 +710,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 {
 	int i;
 	LIST_HEAD(pages_to_free);
-	struct zone *zone = NULL;
+	struct pglist_data *pgdat = NULL;
 	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
 	unsigned int uninitialized_var(lock_batch);
@@ -721,11 +721,11 @@ void release_pages(struct page **pages, int nr, bool cold)
 		/*
 		 * Make sure the IRQ-safe lock-holding time does not get
 		 * excessive with a continuous string of pages from the
-		 * same zone. The lock is held only if zone != NULL.
+		 * same pgdat. The lock is held only if pgdat != NULL.
 		 */
-		if (zone && ++lock_batch == SWAP_CLUSTER_MAX) {
-			spin_unlock_irqrestore(zone_lru_lock(zone), flags);
-			zone = NULL;
+		if (pgdat && ++lock_batch == SWAP_CLUSTER_MAX) {
+			spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+			pgdat = NULL;
 		}
 
 		page = compound_head(page);
@@ -733,27 +733,27 @@ void release_pages(struct page **pages, int nr, bool cold)
 			continue;
 
 		if (PageCompound(page)) {
-			if (zone) {
-				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
-				zone = NULL;
+			if (pgdat) {
+				spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+				pgdat = NULL;
 			}
 			__put_compound_page(page);
 			continue;
 		}
 
 		if (PageLRU(page)) {
-			struct zone *pagezone = page_zone(page);
+			struct pglist_data *page_pgdat = page_zone(page)->zone_pgdat;
 
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irqrestore(zone_lru_lock(zone),
+			if (page_pgdat != pgdat) {
+				if (pgdat)
+					spin_unlock_irqrestore(&pgdat->lru_lock,
 									flags);
 				lock_batch = 0;
-				zone = pagezone;
-				spin_lock_irqsave(zone_lru_lock(zone), flags);
+				pgdat = page_pgdat;
+				spin_lock_irqsave(&pgdat->lru_lock, flags);
 			}
 
-			lruvec = mem_cgroup_page_lruvec(page, zone);
+			lruvec = mem_cgroup_page_lruvec(page, pgdat);
 			VM_BUG_ON_PAGE(!PageLRU(page), page);
 			__ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
@@ -764,8 +764,8 @@ void release_pages(struct page **pages, int nr, bool cold)
 
 		list_add(&page->lru, &pages_to_free);
 	}
-	if (zone)
-		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+	if (pgdat)
+		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_hot_cold_page_list(&pages_to_free, cold);
@@ -801,7 +801,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
 	VM_BUG_ON(NR_CPUS != 1 &&
-		  !spin_is_locked(zone_lru_lock(lruvec_zone(lruvec))));
+		  !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
 
 	if (!list)
 		SetPageLRU(page_tail);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 13a8ca37ab42..760fdea19729 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -191,26 +191,26 @@ static bool sane_reclaim(struct scan_control *sc)
 }
 #endif
 
-unsigned long zone_reclaimable_pages(struct zone *zone)
+unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
 {
 	unsigned long nr;
 
-	nr = zone_page_state_snapshot(zone, NR_ACTIVE_FILE) +
-	     zone_page_state_snapshot(zone, NR_INACTIVE_FILE) +
-	     zone_page_state_snapshot(zone, NR_ISOLATED_FILE);
+	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
+	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
+	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
 
 	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state_snapshot(zone, NR_ACTIVE_ANON) +
-		      zone_page_state_snapshot(zone, NR_INACTIVE_ANON) +
-		      zone_page_state_snapshot(zone, NR_ISOLATED_ANON);
+		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
+		      node_page_state_snapshot(pgdat, NR_INACTIVE_ANON) +
+		      node_page_state_snapshot(pgdat, NR_ISOLATED_ANON);
 
 	return nr;
 }
 
-bool zone_reclaimable(struct zone *zone)
+bool pgdat_reclaimable(struct pglist_data *pgdat)
 {
-	return zone_page_state_snapshot(zone, NR_PAGES_SCANNED) <
-		zone_reclaimable_pages(zone) * 6;
+	return node_page_state_snapshot(pgdat, NR_PAGES_SCANNED) <
+		pgdat_reclaimable_pages(pgdat) * 6;
 }
 
 unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
@@ -218,7 +218,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_get_lru_size(lruvec, lru);
 
-	return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
+	return node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
 }
 
 /*
@@ -877,7 +877,7 @@ static void page_check_dirty_writeback(struct page *page,
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-				      struct zone *zone,
+				      struct pglist_data *pgdat,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      unsigned long *ret_nr_dirty,
@@ -917,7 +917,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep;
 
 		VM_BUG_ON_PAGE(PageActive(page), page);
-		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
 
 		sc->nr_scanned++;
 
@@ -996,7 +995,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			/* Case 1 above */
 			if (current_is_kswapd() &&
 			    PageReclaim(page) &&
-			    test_bit(ZONE_WRITEBACK, &zone->flags)) {
+			    test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
 				nr_immediate++;
 				goto keep_locked;
 
@@ -1086,7 +1085,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 */
 			if (page_is_file_cache(page) &&
 					(!current_is_kswapd() ||
-					 !test_bit(ZONE_DIRTY, &zone->flags))) {
+					 !test_bit(PGDAT_DIRTY, &pgdat->flags))) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -1260,11 +1259,11 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		}
 	}
 
-	ret = shrink_page_list(&clean_pages, zone, &sc,
+	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
 			TTU_UNMAP|TTU_IGNORE_ACCESS,
 			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
 	list_splice(&clean_pages, page_list);
-	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
+	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
 }
 
@@ -1442,7 +1441,7 @@ int isolate_lru_page(struct page *page)
 		struct lruvec *lruvec;
 
 		spin_lock_irq(zone_lru_lock(zone));
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
 			get_page(page);
@@ -1462,7 +1461,7 @@ int isolate_lru_page(struct page *page)
  * the LRU list will go small and be scanned faster than necessary, leading to
  * unnecessary swapping, thrashing and OOM.
  */
-static int too_many_isolated(struct zone *zone, int file,
+static int too_many_isolated(struct pglist_data *pgdat, int file,
 		struct scan_control *sc)
 {
 	unsigned long inactive, isolated;
@@ -1474,11 +1473,11 @@ static int too_many_isolated(struct zone *zone, int file,
 		return 0;
 
 	if (file) {
-		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
-		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
+		inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
+		isolated = node_page_state(pgdat, NR_ISOLATED_FILE);
 	} else {
-		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
-		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
+		inactive = node_page_state(pgdat, NR_INACTIVE_ANON);
+		isolated = node_page_state(pgdat, NR_ISOLATED_ANON);
 	}
 
 	/*
@@ -1496,7 +1495,7 @@ static noinline_for_stack void
 putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-	struct zone *zone = lruvec_zone(lruvec);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	LIST_HEAD(pages_to_free);
 
 	/*
@@ -1509,13 +1508,13 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page))) {
-			spin_unlock_irq(zone_lru_lock(zone));
+			spin_unlock_irq(&pgdat->lru_lock);
 			putback_lru_page(page);
-			spin_lock_irq(zone_lru_lock(zone));
+			spin_lock_irq(&pgdat->lru_lock);
 			continue;
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
 		SetPageLRU(page);
 		lru = page_lru(page);
@@ -1532,10 +1531,10 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(zone_lru_lock(zone));
+				spin_unlock_irq(&pgdat->lru_lock);
 				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(zone_lru_lock(zone));
+				spin_lock_irq(&pgdat->lru_lock);
 			} else
 				list_add(&page->lru, &pages_to_free);
 		}
@@ -1579,10 +1578,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_immediate = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
-	struct zone *zone = lruvec_zone(lruvec);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(zone, file, sc))) {
+	while (unlikely(too_many_isolated(pgdat, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
@@ -1597,49 +1596,47 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
 
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
+	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, -nr_taken);
+	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 
 	if (global_reclaim(sc)) {
-		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
+		__mod_node_page_state(pgdat, NR_PAGES_SCANNED, nr_scanned);
 		if (current_is_kswapd())
-			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scanned);
+			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
 		else
-			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
+			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
 	}
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&pgdat->lru_lock);
 
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
+	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, TTU_UNMAP,
 				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
 				&nr_writeback, &nr_immediate,
 				false);
 
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (global_reclaim(sc)) {
 		if (current_is_kswapd())
-			__count_zone_vm_events(PGSTEAL_KSWAPD, zone,
-					       nr_reclaimed);
+			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
 		else
-			__count_zone_vm_events(PGSTEAL_DIRECT, zone,
-					       nr_reclaimed);
+			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
 	}
 
 	putback_inactive_pages(lruvec, &page_list);
 
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
+	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&page_list);
 	free_hot_cold_page_list(&page_list, true);
@@ -1659,7 +1656,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * are encountered in the nr_immediate check below.
 	 */
 	if (nr_writeback && nr_writeback == nr_taken)
-		set_bit(ZONE_WRITEBACK, &zone->flags);
+		set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 	/*
 	 * Legacy memcg will stall in page writeback so avoid forcibly
@@ -1671,16 +1668,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * backed by a congested BDI and wait_iff_congested will stall.
 		 */
 		if (nr_dirty && nr_dirty == nr_congested)
-			set_bit(ZONE_CONGESTED, &zone->flags);
+			set_bit(PGDAT_CONGESTED, &pgdat->flags);
 
 		/*
 		 * If dirty pages are scanned that are not queued for IO, it
 		 * implies that flushers are not keeping up. In this case, flag
-		 * the zone ZONE_DIRTY and kswapd will start writing pages from
+		 * the pgdat PGDAT_DIRTY and kswapd will start writing pages from
 		 * reclaim context.
 		 */
 		if (nr_unqueued_dirty == nr_taken)
-			set_bit(ZONE_DIRTY, &zone->flags);
+			set_bit(PGDAT_DIRTY, &pgdat->flags);
 
 		/*
 		 * If kswapd scans pages marked marked for immediate
@@ -1699,9 +1696,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 */
 	if (!sc->hibernation_mode && !current_is_kswapd() &&
 	    current_may_throttle())
-		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
 
-	trace_mm_vmscan_lru_shrink_inactive(zone, nr_scanned, nr_reclaimed,
+	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
+			nr_scanned, nr_reclaimed,
 			sc->priority, file);
 	return nr_reclaimed;
 }
@@ -1729,14 +1727,14 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
 {
-	struct zone *zone = lruvec_zone(lruvec);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	unsigned long pgmoved = 0;
 	struct page *page;
 	int nr_pages;
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		SetPageLRU(page);
@@ -1752,15 +1750,15 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(zone_lru_lock(zone));
+				spin_unlock_irq(&pgdat->lru_lock);
 				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(zone_lru_lock(zone));
+				spin_lock_irq(&pgdat->lru_lock);
 			} else
 				list_add(&page->lru, pages_to_free);
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
@@ -1781,7 +1779,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	unsigned long nr_rotated = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
-	struct zone *zone = lruvec_zone(lruvec);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 
 	lru_add_drain();
 
@@ -1790,19 +1788,19 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
 	if (global_reclaim(sc))
-		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
+		__mod_node_page_state(pgdat, NR_PAGES_SCANNED, nr_scanned);
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
-	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(zone_lru_lock(zone));
+	__count_vm_events(PGREFILL, nr_scanned);
+	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, -nr_taken);
+	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
+	spin_unlock_irq(&pgdat->lru_lock);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1847,7 +1845,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1858,22 +1856,22 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(zone_lru_lock(zone));
+	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
+	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
 	free_hot_cold_page_list(&l_hold, true);
 }
 
 #ifdef CONFIG_SWAP
-static bool inactive_anon_is_low_global(struct zone *zone)
+static bool inactive_anon_is_low_global(struct pglist_data *pgdat)
 {
 	unsigned long active, inactive;
 
-	active = zone_page_state(zone, NR_ACTIVE_ANON);
-	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
+	active = node_page_state(pgdat, NR_ACTIVE_ANON);
+	inactive = node_page_state(pgdat, NR_INACTIVE_ANON);
 
-	return inactive * zone->inactive_ratio < active;
+	return inactive * pgdat->inactive_ratio < active;
 }
 
 /**
@@ -1895,7 +1893,7 @@ static bool inactive_anon_is_low(struct lruvec *lruvec)
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_inactive_anon_is_low(lruvec);
 
-	return inactive_anon_is_low_global(lruvec_zone(lruvec));
+	return inactive_anon_is_low_global(lruvec_pgdat(lruvec));
 }
 #else
 static inline bool inactive_anon_is_low(struct lruvec *lruvec)
@@ -1973,7 +1971,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
 	u64 denominator = 0;	/* gcc */
-	struct zone *zone = lruvec_zone(lruvec);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	unsigned long anon_prio, file_prio;
 	enum scan_balance scan_balance;
 	unsigned long anon, file;
@@ -1994,7 +1992,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * well.
 	 */
 	if (current_is_kswapd()) {
-		if (!zone_reclaimable(zone))
+		if (!pgdat_reclaimable(pgdat))
 			force_scan = true;
 		if (!mem_cgroup_online(memcg))
 			force_scan = true;
@@ -2040,14 +2038,24 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * anon pages.  Try to detect this based on file LRU size.
 	 */
 	if (global_reclaim(sc)) {
-		unsigned long zonefile;
-		unsigned long zonefree;
+		unsigned long pgdatfile;
+		unsigned long pgdatfree;
+		int z;
+		unsigned long total_high_wmark = 0;
+
+		pgdatfree = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
+		pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
+			   node_page_state(pgdat, NR_INACTIVE_FILE);
 
-		zonefree = zone_page_state(zone, NR_FREE_PAGES);
-		zonefile = zone_page_state(zone, NR_ACTIVE_FILE) +
-			   zone_page_state(zone, NR_INACTIVE_FILE);
+		for (z = 0; z < MAX_NR_ZONES; z++) {
+			struct zone *zone = &pgdat->node_zones[z];
+			if (!populated_zone(zone))
+				continue;
+
+			total_high_wmark += high_wmark_pages(zone);
+		}
 
-		if (unlikely(zonefile + zonefree <= high_wmark_pages(zone))) {
+		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
 			scan_balance = SCAN_ANON;
 			goto out;
 		}
@@ -2094,7 +2102,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE) +
 		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
 
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -2115,7 +2123,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 
 	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&pgdat->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -2369,9 +2377,9 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
-	inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
+	inactive_lru_pages = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
 	if (get_nr_swap_pages() > 0)
-		inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
+		inactive_lru_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
@@ -2571,7 +2579,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 				continue;
 
 			if (sc->priority != DEF_PRIORITY &&
-			    !zone_reclaimable(zone))
+			    !pgdat_reclaimable(zone->zone_pgdat))
 				continue;	/* Let kswapd poll it */
 
 			/*
@@ -2709,7 +2717,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 	for (i = 0; i <= ZONE_NORMAL; i++) {
 		zone = &pgdat->node_zones[i];
 		if (!populated_zone(zone) ||
-		    zone_reclaimable_pages(zone) == 0)
+		    pgdat_reclaimable_pages(pgdat) == 0)
 			continue;
 
 		pfmemalloc_reserve += min_wmark_pages(zone);
@@ -3017,7 +3025,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 		 * DEF_PRIORITY. Effectively, it considers them balanced so
 		 * they must be considered balanced here as well!
 		 */
-		if (!zone_reclaimable(zone)) {
+		if (!pgdat_reclaimable(zone->zone_pgdat)) {
 			balanced_pages += zone->managed_pages;
 			continue;
 		}
@@ -3081,6 +3089,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	int testorder = sc->order;
 	unsigned long balance_gap;
 	bool lowmem_pressure;
+	struct pglist_data *pgdat = zone->zone_pgdat;
 
 	/* Reclaim above the high watermark. */
 	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
@@ -3105,7 +3114,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
 
 	shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
 
-	clear_bit(ZONE_WRITEBACK, &zone->flags);
+	/* TODO: ANOMALY */
+	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 	/*
 	 * If a zone reaches its high watermark, consider it to be no longer
@@ -3113,10 +3123,10 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * BDIs but as pressure is relieved, speculatively avoid congestion
 	 * waits.
 	 */
-	if (zone_reclaimable(zone) &&
+	if (pgdat_reclaimable(zone->zone_pgdat) &&
 	    zone_balanced(zone, testorder, false, 0, classzone_idx)) {
-		clear_bit(ZONE_CONGESTED, &zone->flags);
-		clear_bit(ZONE_DIRTY, &zone->flags);
+		clear_bit(PGDAT_CONGESTED, &pgdat->flags);
+		clear_bit(PGDAT_DIRTY, &pgdat->flags);
 	}
 
 	return sc->nr_scanned >= sc->nr_to_reclaim;
@@ -3175,7 +3185,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				continue;
 
 			if (sc.priority != DEF_PRIORITY &&
-			    !zone_reclaimable(zone))
+			    !pgdat_reclaimable(zone->zone_pgdat))
 				continue;
 
 			/*
@@ -3202,9 +3212,11 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				/*
 				 * If balanced, clear the dirty and congested
 				 * flags
+				 *
+				 * TODO: ANOMALY
 				 */
-				clear_bit(ZONE_CONGESTED, &zone->flags);
-				clear_bit(ZONE_DIRTY, &zone->flags);
+				clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
+				clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
 			}
 		}
 
@@ -3234,7 +3246,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				continue;
 
 			if (sc.priority != DEF_PRIORITY &&
-			    !zone_reclaimable(zone))
+			    !pgdat_reclaimable(zone->zone_pgdat))
 				continue;
 
 			sc.nr_scanned = 0;
@@ -3630,8 +3642,8 @@ int sysctl_min_slab_ratio = 5;
 static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
 {
 	unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
-	unsigned long file_lru = zone_page_state(zone, NR_INACTIVE_FILE) +
-		zone_page_state(zone, NR_ACTIVE_FILE);
+	unsigned long file_lru = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
+		node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
 
 	/*
 	 * It's possible for there to be more file mapped pages than
@@ -3734,7 +3746,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
 		return ZONE_RECLAIM_FULL;
 
-	if (!zone_reclaimable(zone))
+	if (!pgdat_reclaimable(zone->zone_pgdat))
 		return ZONE_RECLAIM_FULL;
 
 	/*
@@ -3813,7 +3825,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 			zone = pagezone;
 			spin_lock_irq(zone_lru_lock(zone));
 		}
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 
 		if (!PageLRU(page) || !PageUnevictable(page))
 			continue;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index ea4e6f9f1094..19bd521e161b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -943,11 +943,6 @@ const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
 	"nr_free_pages",
 	"nr_alloc_batch",
-	"nr_inactive_anon",
-	"nr_active_anon",
-	"nr_inactive_file",
-	"nr_active_file",
-	"nr_unevictable",
 	"nr_mlock",
 	"nr_anon_pages",
 	"nr_mapped",
@@ -963,12 +958,9 @@ const char * const vmstat_text[] = {
 	"nr_vmscan_write",
 	"nr_vmscan_immediate_reclaim",
 	"nr_writeback_temp",
-	"nr_isolated_anon",
-	"nr_isolated_file",
 	"nr_shmem",
 	"nr_dirtied",
 	"nr_written",
-	"nr_pages_scanned",
 
 #ifdef CONFIG_NUMA
 	"numa_hit",
@@ -984,6 +976,16 @@ const char * const vmstat_text[] = {
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
 
+	/* Node-based counters */
+	"nr_inactive_anon",
+	"nr_active_anon",
+	"nr_inactive_file",
+	"nr_active_file",
+	"nr_unevictable",
+	"nr_isolated_anon",
+	"nr_isolated_file",
+	"nr_pages_scanned",
+
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
 	"nr_dirty_background_threshold",
@@ -1005,11 +1007,11 @@ const char * const vmstat_text[] = {
 	"pgmajfault",
 	"pglazyfreed",
 
-	TEXTS_FOR_ZONES("pgrefill")
-	TEXTS_FOR_ZONES("pgsteal_kswapd")
-	TEXTS_FOR_ZONES("pgsteal_direct")
-	TEXTS_FOR_ZONES("pgscan_kswapd")
-	TEXTS_FOR_ZONES("pgscan_direct")
+	"pgrefill",
+	"pgsteal_kswapd",
+	"pgsteal_direct",
+	"pgscan_kswapd",
+	"pgscan_direct",
 	"pgscan_direct_throttle",
 
 #ifdef CONFIG_NUMA
@@ -1426,7 +1428,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        min      %lu"
 		   "\n        low      %lu"
 		   "\n        high     %lu"
-		   "\n        scanned  %lu"
+		   "\n   node_scanned  %lu"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu"
 		   "\n        managed  %lu",
@@ -1434,13 +1436,13 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   min_wmark_pages(zone),
 		   low_wmark_pages(zone),
 		   high_wmark_pages(zone),
-		   zone_page_state(zone, NR_PAGES_SCANNED),
+		   node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED),
 		   zone->spanned_pages,
 		   zone->present_pages,
 		   zone->managed_pages);
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
+		seq_printf(m, "\n      %-12s %lu", vmstat_text[i],
 				zone_page_state(zone, i));
 
 	seq_printf(m,
@@ -1470,12 +1472,12 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 #endif
 	}
 	seq_printf(m,
-		   "\n  all_unreclaimable: %u"
-		   "\n  start_pfn:         %lu"
-		   "\n  inactive_ratio:    %u",
-		   !zone_reclaimable(zone),
+		   "\n  node_unreclaimable:  %u"
+		   "\n  start_pfn:           %lu"
+		   "\n  node_inactive_ratio: %u",
+		   !pgdat_reclaimable(zone->zone_pgdat),
 		   zone->zone_start_pfn,
-		   zone->inactive_ratio);
+		   zone->zone_pgdat->inactive_ratio);
 	seq_putc(m, '\n');
 }
 
@@ -1566,7 +1568,6 @@ static int vmstat_show(struct seq_file *m, void *arg)
 {
 	unsigned long *l = arg;
 	unsigned long off = l - (unsigned long *)m->private;
-
 	seq_printf(m, "%s %lu\n", vmstat_text[off], *l);
 	return 0;
 }
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
