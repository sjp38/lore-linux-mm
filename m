Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id B8AE66B006E
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:43 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so81228337lbb.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si5309384wju.110.2015.06.08.06.56.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:40 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/25] mm, vmscan: Move LRU lists to node
Date: Mon,  8 Jun 2015 14:56:09 +0100
Message-Id: <1433771791-30567-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This moves the LRU lists from the zone to the node and all related data
such as counters, tracing, congestion tracking and writeback tracking.
This is mostly a mechanical patch but note that it introduces a number
of anomalies. For example, the scans are per-zone but using per-node
counters. We also mark a node as congested when a zone is congested. This
causes weird problems that are fixed later but is easier to review.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/tile/mm/pgtable.c                    |   8 +-
 drivers/base/node.c                       |  19 +--
 drivers/staging/android/lowmemorykiller.c |   8 +-
 include/linux/backing-dev.h               |   2 +-
 include/linux/memcontrol.h                |   8 +-
 include/linux/mm_inline.h                 |   4 +-
 include/linux/mmzone.h                    |  70 +++++-----
 include/linux/vm_event_item.h             |  10 +-
 include/trace/events/vmscan.h             |  10 +-
 kernel/power/snapshot.c                   |  10 +-
 mm/backing-dev.c                          |  14 +-
 mm/compaction.c                           |  19 +--
 mm/huge_memory.c                          |   6 +-
 mm/internal.h                             |   2 +-
 mm/memcontrol.c                           |  18 +--
 mm/memory-failure.c                       |   4 +-
 mm/memory_hotplug.c                       |   2 +-
 mm/mempolicy.c                            |   2 +-
 mm/migrate.c                              |  21 +--
 mm/mlock.c                                |   2 +-
 mm/page-writeback.c                       |   8 +-
 mm/page_alloc.c                           | 103 +++++++++------
 mm/swap.c                                 |  56 ++++----
 mm/vmscan.c                               | 208 ++++++++++++++++--------------
 mm/vmstat.c                               |  45 +++----
 mm/workingset.c                           |   8 +-
 26 files changed, 354 insertions(+), 313 deletions(-)

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
index 0b6392789b66..b06ae7bfea63 100644
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
index feafa172b155..6463d9278229 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -69,10 +69,10 @@ static unsigned long lowmem_deathpending_timeout;
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
index aff923ae8c4b..6ca09adfd55e 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -277,7 +277,7 @@ enum {
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
 void set_bdi_congested(struct backing_dev_info *bdi, int sync);
 long congestion_wait(int sync, long timeout);
-long wait_iff_congested(struct zone *zone, int sync, long timeout);
+long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout);
 int pdflush_proc_obsolete(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp, loff_t *ppos);
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 72dff5fb0d0c..df225059daf3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -85,7 +85,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 			bool lrucare);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
-struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
+struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
 bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
 			      struct mem_cgroup *root);
@@ -243,13 +243,13 @@ static inline void mem_cgroup_migrate(struct page *oldpage,
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
 
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index cf55945c83fb..275b10b2ace4 100644
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
index 4c824d6996eb..fab74af19f26 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -115,12 +115,6 @@ enum zone_stat_item {
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
@@ -138,12 +132,9 @@ enum zone_stat_item {
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
@@ -160,6 +151,15 @@ enum zone_stat_item {
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
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
 #ifdef CONFIG_MEMCG
-	struct zone *zone;
+	struct pglist_data *pgdat;
 #endif
 };
 
@@ -352,13 +352,6 @@ struct zone {
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
 
@@ -496,12 +489,6 @@ struct zone {
 
 	/* Write-intensive fields used by page reclaim */
 
-	/* Fields commonly accessed by the page reclaim scanner */
-	struct lruvec		lruvec;
-
-	/* Evictions & activations on the inactive file list */
-	atomic_long_t		inactive_age;
-
 	/*
 	 * When free pages are below this point, additional steps are taken
 	 * when reading the number of free pages to avoid per-cpu counter
@@ -540,17 +527,20 @@ struct zone {
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
@@ -774,6 +764,21 @@ typedef struct pglist_data {
 	ZONE_PADDING(_pad1_)
 	spinlock_t		lru_lock;
 
+	/* Fields commonly accessed by the page reclaim scanner */
+	struct lruvec		lruvec;
+
+	/* Evictions & activations on the inactive file list */
+	atomic_long_t		inactive_age;
+
+	/*
+	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
+	 * this zone's LRU.  Maintained by the pageout code.
+	 */
+	unsigned int inactive_ratio;
+
+	unsigned long		flags;
+
+	ZONE_PADDING(_pad2_)
 	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
 	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
 } pg_data_t;
@@ -794,6 +799,11 @@ static inline spinlock_t *zone_lru_lock(struct zone *zone)
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
@@ -823,12 +833,12 @@ extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
 
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
 
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 9246d32dc973..4ce4d59d361e 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,11 +25,11 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
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
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 69590b6ffc09..bbeaa12ae0c3 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -353,15 +353,14 @@ TRACE_EVENT(mm_vmscan_writepage,
 
 TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 
-	TP_PROTO(int nid, int zid,
+	TP_PROTO(int nid,
 			unsigned long nr_scanned, unsigned long nr_reclaimed,
 			int priority, int reclaim_flags),
 
-	TP_ARGS(nid, zid, nr_scanned, nr_reclaimed, priority, reclaim_flags),
+	TP_ARGS(nid, nr_scanned, nr_reclaimed, priority, reclaim_flags),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
-		__field(int, zid)
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_reclaimed)
 		__field(int, priority)
@@ -370,15 +369,14 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 
 	TP_fast_assign(
 		__entry->nid = nid;
-		__entry->zid = zid;
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_reclaimed = nr_reclaimed;
 		__entry->priority = priority;
 		__entry->reclaim_flags = reclaim_flags;
 	),
 
-	TP_printk("nid=%d zid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
-		__entry->nid, __entry->zid,
+	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
+		__entry->nid,
 		__entry->nr_scanned, __entry->nr_reclaimed,
 		__entry->priority,
 		show_reclaim_flags(__entry->reclaim_flags))
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 5235dd4e1e2f..1012eaf6e4c1 100644
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
index 6dc4580df2af..513e15d428e1 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -542,24 +542,24 @@ long congestion_wait(int sync, long timeout)
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
@@ -568,11 +568,11 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 
 	/*
 	 * If there is no congestion, or heavy congestion is not being
-	 * encountered in the current zone, yield if necessary instead
+	 * encountered in the current pgdat, yield if necessary instead
 	 * of sleeping on the congestion queue
 	 */
 	if (atomic_read(&nr_bdi_congested[sync]) == 0 ||
-	    !test_bit(ZONE_CONGESTED, &zone->flags)) {
+	    !test_bit(PGDAT_CONGESTED, &pgdat->flags)) {
 		cond_resched();
 
 		/* In case we scheduled, work out time remaining */
diff --git a/mm/compaction.c b/mm/compaction.c
index e0b547953e36..d73c509ea801 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -625,21 +625,22 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 	list_for_each_entry(page, &cc->migratepages, lru)
 		count[!!page_is_file_cache(page)]++;
 
-	mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
-	mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
+	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON, count[0]);
+	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, count[1]);
 }
 
 /* Similar to reclaim, but different enough that they don't share logic */
 static bool too_many_isolated(struct zone *zone)
 {
+	pg_data_t *pgdat = zone->zone_pgdat;
 	unsigned long active, inactive, isolated;
 
-	inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
-					zone_page_state(zone, NR_INACTIVE_ANON);
-	active = zone_page_state(zone, NR_ACTIVE_FILE) +
-					zone_page_state(zone, NR_ACTIVE_ANON);
-	isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
-					zone_page_state(zone, NR_ISOLATED_ANON);
+	inactive = node_page_state(pgdat, NR_INACTIVE_FILE) +
+					node_page_state(pgdat, NR_INACTIVE_ANON);
+	active = node_page_state(pgdat, NR_ACTIVE_FILE) +
+					node_page_state(pgdat, NR_ACTIVE_ANON);
+	isolated = node_page_state(pgdat, NR_ISOLATED_FILE) +
+					node_page_state(pgdat, NR_ISOLATED_ANON);
 
 	return isolated > (inactive + active) / 2;
 }
@@ -794,7 +795,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			}
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, isolate_mode) != 0)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cdc87f90c4eb..b56c14a41d96 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1635,7 +1635,7 @@ static void __split_huge_page_refcount(struct page *page,
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(zone_lru_lock(zone));
-	lruvec = mem_cgroup_page_lruvec(page, zone);
+	lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 
 	compound_lock(page);
 	/* complete memcg works before add pages to LRU */
@@ -2100,7 +2100,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 static void release_pte_page(struct page *page)
 {
 	/* 0 stands for page_is_file_cache(page) == false */
-	dec_zone_page_state(page, NR_ISOLATED_ANON + 0);
+	dec_node_page_state(page, NR_ISOLATED_ANON + 0);
 	unlock_page(page);
 	putback_lru_page(page);
 }
@@ -2181,7 +2181,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			goto out;
 		}
 		/* 0 stands for page_is_file_cache(page) == false */
-		inc_zone_page_state(page, NR_ISOLATED_ANON + 0);
+		inc_node_page_state(page, NR_ISOLATED_ANON + 0);
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/internal.h b/mm/internal.h
index a96da5b0029d..2e4cee6a8739 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -98,7 +98,7 @@ extern unsigned long highest_memmap_pfn;
  */
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
-extern bool zone_reclaimable(struct zone *zone);
+extern bool pgdat_reclaimable(struct pglist_data *pgdat);
 
 /*
  * in mm/rmap.c:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1e7932a5f921..10eed58506a0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1185,7 +1185,7 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled()) {
-		lruvec = &zone->lruvec;
+		lruvec = zone_lruvec(zone);
 		goto out;
 	}
 
@@ -1197,8 +1197,8 @@ out:
 	 * we have to be prepared to initialize lruvec->zone here;
 	 * and if offlined then reonlined, we need to reinitialize it.
 	 */
-	if (unlikely(lruvec->zone != zone))
-		lruvec->zone = zone;
+	if (unlikely(lruvec->pgdat != zone->zone_pgdat))
+		lruvec->pgdat = zone->zone_pgdat;
 	return lruvec;
 }
 
@@ -1211,14 +1211,14 @@ out:
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
 
@@ -1238,8 +1238,8 @@ out:
 	 * we have to be prepared to initialize lruvec->zone here;
 	 * and if offlined then reonlined, we need to reinitialize it.
 	 */
-	if (unlikely(lruvec->zone != zone))
-		lruvec->zone = zone;
+	if (unlikely(lruvec->pgdat != pgdat))
+		lruvec->pgdat = pgdat;
 	return lruvec;
 }
 
@@ -2396,7 +2396,7 @@ static void lock_page_lru(struct page *page, int *isolated)
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		*isolated = 1;
@@ -2411,7 +2411,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 	if (isolated) {
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d487f8dc6d39..e5415186f48f 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1620,7 +1620,7 @@ static int __soft_offline_page(struct page *page, int flags)
 	put_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
-		inc_zone_page_state(page, NR_ISOLATED_ANON +
+		inc_node_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
@@ -1628,7 +1628,7 @@ static int __soft_offline_page(struct page *page, int flags)
 		if (ret) {
 			if (!list_empty(&pagelist)) {
 				list_del(&page->lru);
-				dec_zone_page_state(page, NR_ISOLATED_ANON +
+				dec_node_page_state(page, NR_ISOLATED_ANON +
 						page_is_file_cache(page));
 				putback_lru_page(page);
 			}
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 65842d688b7c..b59da0f78415 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1426,7 +1426,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			put_page(page);
 			list_add_tail(&page->lru, &source);
 			move_pages--;
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
+			inc_node_page_state(page, NR_ISOLATED_ANON +
 					    page_is_file_cache(page));
 
 		} else {
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4721046a134a..ea211f16e3b7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -933,7 +933,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
 		if (!isolate_lru_page(page)) {
 			list_add_tail(&page->lru, pagelist);
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
+			inc_node_page_state(page, NR_ISOLATED_ANON +
 					    page_is_file_cache(page));
 		}
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index 85e042686031..a33e4b4ed60d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -90,7 +90,7 @@ void putback_movable_pages(struct list_head *l)
 			continue;
 		}
 		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
+		dec_node_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		if (unlikely(isolated_balloon_page(page)))
 			balloon_page_putback(page);
@@ -935,7 +935,7 @@ out:
 		 * restored.
 		 */
 		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
+		dec_node_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		putback_lru_page(page);
 	}
@@ -1244,7 +1244,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		err = isolate_lru_page(page);
 		if (!err) {
 			list_add_tail(&page->lru, &pagelist);
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
+			inc_node_page_state(page, NR_ISOLATED_ANON +
 					    page_is_file_cache(page));
 		}
 put_and_set:
@@ -1514,15 +1514,16 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
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
@@ -1636,7 +1637,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 	}
 
 	page_lru = page_is_file_cache(page);
-	mod_zone_page_state(page_zone(page), NR_ISOLATED_ANON + page_lru,
+	mod_node_page_state(page_zone(page)->zone_pgdat, NR_ISOLATED_ANON + page_lru,
 				hpage_nr_pages(page));
 
 	/*
@@ -1694,7 +1695,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	if (nr_remaining) {
 		if (!list_empty(&migratepages)) {
 			list_del(&page->lru);
-			dec_zone_page_state(page, NR_ISOLATED_ANON +
+			dec_node_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
 			putback_lru_page(page);
 		}
@@ -1784,7 +1785,7 @@ fail_putback:
 		/* Retake the callers reference and putback on LRU */
 		get_page(page);
 		putback_lru_page(page);
-		mod_zone_page_state(page_zone(page),
+		mod_node_page_state(page_zone(page)->zone_pgdat,
 			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
 
 		goto out_unlock;
@@ -1837,7 +1838,7 @@ fail_putback:
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-	mod_zone_page_state(page_zone(page),
+	mod_node_page_state(page_zone(page)->zone_pgdat,
 			NR_ISOLATED_ANON + page_lru,
 			-HPAGE_PMD_NR);
 	return isolated;
diff --git a/mm/mlock.c b/mm/mlock.c
index 4b5b4a0a2191..144bd5086260 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -100,7 +100,7 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, page_zone(page));
+		lruvec = mem_cgroup_page_lruvec(page, page_zone(page)->zone_pgdat);
 		if (getpage)
 			get_page(page);
 		ClearPageLRU(page);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 644bcb665773..9707c450c7c5 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -187,8 +187,8 @@ static unsigned long zone_dirtyable_memory(struct zone *zone)
 	nr_pages = zone_page_state(zone, NR_FREE_PAGES);
 	nr_pages -= min(nr_pages, zone->dirty_balance_reserve);
 
-	nr_pages += zone_page_state(zone, NR_INACTIVE_FILE);
-	nr_pages += zone_page_state(zone, NR_ACTIVE_FILE);
+	nr_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
+	nr_pages += node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
 
 	return nr_pages;
 }
@@ -241,8 +241,8 @@ static unsigned long global_dirtyable_memory(void)
 	x = global_page_state(NR_FREE_PAGES);
 	x -= min(x, dirty_balance_reserve);
 
-	x += global_page_state(NR_INACTIVE_FILE);
-	x += global_page_state(NR_ACTIVE_FILE);
+	x += global_node_page_state(NR_INACTIVE_FILE);
+	x += global_node_page_state(NR_ACTIVE_FILE);
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3dde181c3b8b..49a29e8ae493 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -700,9 +700,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	unsigned long nr_scanned;
 
 	spin_lock(&zone->lock);
-	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
+	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
 	if (nr_scanned)
-		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
+		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
 
 	while (to_free) {
 		struct page *page;
@@ -751,9 +751,9 @@ static void free_one_page(struct zone *zone,
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
@@ -2527,8 +2527,8 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 						ALLOC_NO_WATERMARKS, ac);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC,
-									HZ/50);
+			wait_iff_congested(ac->preferred_zone->zone_pgdat,
+					   BLK_RW_ASYNC, HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
@@ -2772,7 +2772,7 @@ retry:
 				goto nopage;
 		}
 		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(ac->preferred_zone->zone_pgdat, BLK_RW_ASYNC, HZ/50);
 		goto retry;
 	} else {
 		/*
@@ -3208,6 +3208,7 @@ void show_free_areas(unsigned int filter)
 {
 	int cpu;
 	struct zone *zone;
+	pg_data_t *pgdat;
 
 	for_each_populated_zone(zone) {
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
@@ -3233,13 +3234,13 @@ void show_free_areas(unsigned int filter)
 		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
 		" free_cma:%lu\n",
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
@@ -3252,6 +3253,28 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_BOUNCE),
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
 
@@ -3263,13 +3286,6 @@ void show_free_areas(unsigned int filter)
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
@@ -3285,21 +3301,13 @@ void show_free_areas(unsigned int filter)
 			" bounce:%lukB"
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
@@ -3316,9 +3324,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
-			K(zone_page_state(zone, NR_PAGES_SCANNED)),
-			(!zone_reclaimable(zone) ? "yes" : "no")
-			);
+			K(node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
 			printk(" %ld", zone->lowmem_reserve[i]);
@@ -4942,7 +4948,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
-		lruvec_init(&zone->lruvec);
+		lruvec_init(zone_lruvec(zone));
 		if (!size)
 			continue;
 
@@ -5788,26 +5794,37 @@ void setup_per_zone_wmarks(void)
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
+		if (populated_zone(zone))
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
@@ -5855,7 +5872,7 @@ int __meminit init_per_zone_wmark_min(void)
 	setup_per_zone_wmarks();
 	refresh_zone_stat_thresholds();
 	setup_per_zone_lowmem_reserve();
-	setup_per_zone_inactive_ratio();
+	setup_per_node_inactive_ratio();
 	return 0;
 }
 module_init(init_per_zone_wmark_min)
diff --git a/mm/swap.c b/mm/swap.c
index e31761ec280c..cbee80f8d88d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -56,7 +56,7 @@ static void __page_cache_release(struct page *page)
 		unsigned long flags;
 
 		spin_lock_irqsave(zone_lru_lock(zone), flags);
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
@@ -427,7 +427,7 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 			spin_lock_irqsave(zone_lru_lock(zone), flags);
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		(*move_fn)(page, lruvec, arg);
 	}
 	if (zone)
@@ -549,11 +549,11 @@ static bool need_activate_page_drain(int cpu)
 
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
 
@@ -676,16 +676,16 @@ void lru_cache_add(struct page *page)
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
@@ -900,7 +900,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 {
 	int i;
 	LIST_HEAD(pages_to_free);
-	struct zone *zone = NULL;
+	struct pglist_data *pgdat = NULL;
 	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
 	unsigned int uninitialized_var(lock_batch);
@@ -909,9 +909,9 @@ void release_pages(struct page **pages, int nr, bool cold)
 		struct page *page = pages[i];
 
 		if (unlikely(PageCompound(page))) {
-			if (zone) {
-				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
-				zone = NULL;
+			if (pgdat) {
+				spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+				pgdat = NULL;
 			}
 			put_compound_page(page);
 			continue;
@@ -920,29 +920,29 @@ void release_pages(struct page **pages, int nr, bool cold)
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
 
 		if (!put_page_testzero(page))
 			continue;
 
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
@@ -953,8 +953,8 @@ void release_pages(struct page **pages, int nr, bool cold)
 
 		list_add(&page->lru, &pages_to_free);
 	}
-	if (zone)
-		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+	if (pgdat)
+		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_hot_cold_page_list(&pages_to_free, cold);
@@ -990,7 +990,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
 	VM_BUG_ON(NR_CPUS != 1 &&
-		  !spin_is_locked(zone_lru_lock(lruvec_zone(lruvec))));
+		  !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
 
 	if (!list)
 		SetPageLRU(page_tail);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8ebdc4e5e720..a11d7d6d2070 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -161,32 +161,34 @@ static bool global_reclaim(struct scan_control *sc)
 }
 #endif
 
-static unsigned long zone_reclaimable_pages(struct zone *zone)
+static unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
 {
 	int nr;
 
-	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
+	nr = node_page_state(pgdat, NR_ACTIVE_FILE) +
+	     node_page_state(pgdat, NR_INACTIVE_FILE);
 
 	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
+		nr += node_page_state(pgdat, NR_ACTIVE_ANON) +
+		      node_page_state(pgdat, NR_INACTIVE_ANON);
 
 	return nr;
 }
 
-bool zone_reclaimable(struct zone *zone)
+bool pgdat_reclaimable(struct pglist_data *pgdat)
 {
-	return zone_page_state(zone, NR_PAGES_SCANNED) <
-		zone_reclaimable_pages(zone) * 6;
+	return node_page_state(pgdat, NR_PAGES_SCANNED) <
+		pgdat_reclaimable_pages(pgdat) * 6;
 }
 
 static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_get_lru_size(lruvec, lru);
 
-	return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
+	return node_page_state(pgdat, NR_LRU_BASE + lru);
 }
 
 /*
@@ -841,7 +843,7 @@ static void page_check_dirty_writeback(struct page *page,
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-				      struct zone *zone,
+				      struct pglist_data *pgdat,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      unsigned long *ret_nr_dirty,
@@ -879,7 +881,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep;
 
 		VM_BUG_ON_PAGE(PageActive(page), page);
-		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
 
 		sc->nr_scanned++;
 
@@ -962,7 +963,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			/* Case 1 above */
 			if (current_is_kswapd() &&
 			    PageReclaim(page) &&
-			    test_bit(ZONE_WRITEBACK, &zone->flags)) {
+			    test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
 				nr_immediate++;
 				goto keep_locked;
 
@@ -1044,7 +1045,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 */
 			if (page_is_file_cache(page) &&
 					(!current_is_kswapd() ||
-					 !test_bit(ZONE_DIRTY, &zone->flags))) {
+					 !test_bit(PGDAT_DIRTY, &pgdat->flags))) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -1208,11 +1209,11 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
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
 
@@ -1388,7 +1389,7 @@ int isolate_lru_page(struct page *page)
 		struct lruvec *lruvec;
 
 		spin_lock_irq(zone_lru_lock(zone));
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
 			get_page(page);
@@ -1408,7 +1409,7 @@ int isolate_lru_page(struct page *page)
  * the LRU list will go small and be scanned faster than necessary, leading to
  * unnecessary swapping, thrashing and OOM.
  */
-static int too_many_isolated(struct zone *zone, int file,
+static int too_many_isolated(struct pglist_data *pgdat, int file,
 		struct scan_control *sc)
 {
 	unsigned long inactive, isolated;
@@ -1420,11 +1421,11 @@ static int too_many_isolated(struct zone *zone, int file,
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
@@ -1442,7 +1443,7 @@ static noinline_for_stack void
 putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-	struct zone *zone = lruvec_zone(lruvec);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	LIST_HEAD(pages_to_free);
 
 	/*
@@ -1455,13 +1456,13 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
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
@@ -1478,10 +1479,10 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
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
@@ -1525,10 +1526,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
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
@@ -1543,49 +1544,47 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
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
@@ -1605,7 +1604,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * are encountered in the nr_immediate check below.
 	 */
 	if (nr_writeback && nr_writeback == nr_taken)
-		set_bit(ZONE_WRITEBACK, &zone->flags);
+		set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 	/*
 	 * memcg will stall in page writeback so only consider forcibly
@@ -1617,16 +1616,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
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
@@ -1645,10 +1644,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 */
 	if (!sc->hibernation_mode && !current_is_kswapd() &&
 	    current_may_throttle())
-		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
 
-	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
-		zone_idx(zone),
+	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
 		nr_scanned, nr_reclaimed,
 		sc->priority,
 		trace_shrink_flags(file));
@@ -1678,14 +1676,14 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
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
@@ -1701,15 +1699,15 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
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
@@ -1730,7 +1728,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	unsigned long nr_rotated = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
-	struct zone *zone = lruvec_zone(lruvec);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 
 	lru_add_drain();
 
@@ -1739,19 +1737,19 @@ static void shrink_active_list(unsigned long nr_to_scan,
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
@@ -1796,7 +1794,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1807,22 +1805,22 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
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
-static int inactive_anon_is_low_global(struct zone *zone)
+static int inactive_anon_is_low_global(struct pglist_data *pgdat)
 {
 	unsigned long active, inactive;
 
-	active = zone_page_state(zone, NR_ACTIVE_ANON);
-	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
+	active = node_page_state(pgdat, NR_ACTIVE_ANON);
+	inactive = node_page_state(pgdat, NR_INACTIVE_ANON);
 
-	if (inactive * zone->inactive_ratio < active)
+	if (inactive * pgdat->inactive_ratio < active)
 		return 1;
 
 	return 0;
@@ -1847,7 +1845,7 @@ static int inactive_anon_is_low(struct lruvec *lruvec)
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_inactive_anon_is_low(lruvec);
 
-	return inactive_anon_is_low_global(lruvec_zone(lruvec));
+	return inactive_anon_is_low_global(lruvec_pgdat(lruvec));
 }
 #else
 static inline int inactive_anon_is_low(struct lruvec *lruvec)
@@ -1924,7 +1922,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
 	u64 denominator = 0;	/* gcc */
-	struct zone *zone = lruvec_zone(lruvec);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	unsigned long anon_prio, file_prio;
 	enum scan_balance scan_balance;
 	unsigned long anon, file;
@@ -1945,7 +1943,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	 * well.
 	 */
 	if (current_is_kswapd()) {
-		if (!zone_reclaimable(zone))
+		if (!pgdat_reclaimable(pgdat))
 			force_scan = true;
 		if (!mem_cgroup_lruvec_online(lruvec))
 			force_scan = true;
@@ -1991,14 +1989,24 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
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
+		pgdatfree = node_page_state(pgdat, NR_FREE_PAGES);
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
@@ -2039,7 +2047,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
 		get_lru_size(lruvec, LRU_INACTIVE_FILE);
 
-	spin_lock_irq(zone_lru_lock(zone));
+	spin_lock_irq(&pgdat->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -2060,7 +2068,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 
 	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(zone_lru_lock(zone));
+	spin_unlock_irq(&pgdat->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -2294,9 +2302,9 @@ static inline bool should_continue_reclaim(struct zone *zone,
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
@@ -2495,7 +2503,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 				continue;
 
 			if (sc->priority != DEF_PRIORITY &&
-			    !zone_reclaimable(zone))
+			    !pgdat_reclaimable(zone->zone_pgdat))
 				continue;	/* Let kswapd poll it */
 
 			/*
@@ -2536,7 +2544,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			reclaimable = true;
 
 		if (global_reclaim(sc) &&
-		    !reclaimable && zone_reclaimable(zone))
+		    !reclaimable && pgdat_reclaimable(zone->zone_pgdat))
 			reclaimable = true;
 	}
 
@@ -2951,7 +2959,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 		 * DEF_PRIORITY. Effectively, it considers them balanced so
 		 * they must be considered balanced here as well!
 		 */
-		if (!zone_reclaimable(zone)) {
+		if (!pgdat_reclaimable(zone->zone_pgdat)) {
 			balanced_pages += zone->managed_pages;
 			continue;
 		}
@@ -3016,6 +3024,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	int testorder = sc->order;
 	unsigned long balance_gap;
 	bool lowmem_pressure;
+	struct pglist_data *pgdat = zone->zone_pgdat;
 
 	/* Reclaim above the high watermark. */
 	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
@@ -3054,7 +3063,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	/* Account for the number of pages attempted to reclaim */
 	*nr_attempted += sc->nr_to_reclaim;
 
-	clear_bit(ZONE_WRITEBACK, &zone->flags);
+	/* TODO: ANOMALY */
+	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 	/*
 	 * If a zone reaches its high watermark, consider it to be no longer
@@ -3062,10 +3072,10 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * BDIs but as pressure is relieved, speculatively avoid congestion
 	 * waits.
 	 */
-	if (zone_reclaimable(zone) &&
+	if (pgdat_reclaimable(zone->zone_pgdat) &&
 	    zone_balanced(zone, testorder, 0, classzone_idx)) {
-		clear_bit(ZONE_CONGESTED, &zone->flags);
-		clear_bit(ZONE_DIRTY, &zone->flags);
+		clear_bit(PGDAT_CONGESTED, &pgdat->flags);
+		clear_bit(PGDAT_DIRTY, &pgdat->flags);
 	}
 
 	return sc->nr_scanned >= sc->nr_to_reclaim;
@@ -3127,7 +3137,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				continue;
 
 			if (sc.priority != DEF_PRIORITY &&
-			    !zone_reclaimable(zone))
+			    !pgdat_reclaimable(zone->zone_pgdat))
 				continue;
 
 			/*
@@ -3154,9 +3164,11 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
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
 
@@ -3204,7 +3216,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				continue;
 
 			if (sc.priority != DEF_PRIORITY &&
-			    !zone_reclaimable(zone))
+			    !pgdat_reclaimable(zone->zone_pgdat))
 				continue;
 
 			sc.nr_scanned = 0;
@@ -3620,8 +3632,8 @@ int sysctl_min_slab_ratio = 5;
 static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
 {
 	unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
-	unsigned long file_lru = zone_page_state(zone, NR_INACTIVE_FILE) +
-		zone_page_state(zone, NR_ACTIVE_FILE);
+	unsigned long file_lru = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
+		node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
 
 	/*
 	 * It's possible for there to be more file mapped pages than
@@ -3724,7 +3736,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
 		return ZONE_RECLAIM_FULL;
 
-	if (!zone_reclaimable(zone))
+	if (!pgdat_reclaimable(zone->zone_pgdat))
 		return ZONE_RECLAIM_FULL;
 
 	/*
@@ -3803,7 +3815,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 			zone = pagezone;
 			spin_lock_irq(zone_lru_lock(zone));
 		}
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 
 		if (!PageLRU(page) || !PageUnevictable(page))
 			continue;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index effafdb80975..36897da22792 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -894,11 +894,6 @@ const char * const vmstat_text[] = {
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
@@ -914,12 +909,9 @@ const char * const vmstat_text[] = {
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
@@ -935,6 +927,16 @@ const char * const vmstat_text[] = {
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
@@ -955,11 +957,11 @@ const char * const vmstat_text[] = {
 	"pgfault",
 	"pgmajfault",
 
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
@@ -1385,7 +1387,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        min      %lu"
 		   "\n        low      %lu"
 		   "\n        high     %lu"
-		   "\n        scanned  %lu"
+		   "\n   node_scanned  %lu"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu"
 		   "\n        managed  %lu",
@@ -1393,13 +1395,13 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
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
@@ -1429,12 +1431,12 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
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
 
@@ -1525,7 +1527,6 @@ static int vmstat_show(struct seq_file *m, void *arg)
 {
 	unsigned long *l = arg;
 	unsigned long off = l - (unsigned long *)m->private;
-
 	seq_printf(m, "%s %lu\n", vmstat_text[off], *l);
 	return 0;
 }
diff --git a/mm/workingset.c b/mm/workingset.c
index aa017133744b..ca080cc11797 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -180,7 +180,7 @@ static void unpack_shadow(void *shadow,
 
 	*zone = NODE_DATA(nid)->node_zones + zid;
 
-	refault = atomic_long_read(&(*zone)->inactive_age);
+	refault = atomic_long_read(&(*zone)->zone_pgdat->inactive_age);
 	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
 			RADIX_TREE_EXCEPTIONAL_SHIFT);
 	/*
@@ -215,7 +215,7 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 	struct zone *zone = page_zone(page);
 	unsigned long eviction;
 
-	eviction = atomic_long_inc_return(&zone->inactive_age);
+	eviction = atomic_long_inc_return(&zone->zone_pgdat->inactive_age);
 	return pack_shadow(eviction, zone);
 }
 
@@ -236,7 +236,7 @@ bool workingset_refault(void *shadow)
 	unpack_shadow(shadow, &zone, &refault_distance);
 	inc_zone_state(zone, WORKINGSET_REFAULT);
 
-	if (refault_distance <= zone_page_state(zone, NR_ACTIVE_FILE)) {
+	if (refault_distance <= node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE)) {
 		inc_zone_state(zone, WORKINGSET_ACTIVATE);
 		return true;
 	}
@@ -249,7 +249,7 @@ bool workingset_refault(void *shadow)
  */
 void workingset_activation(struct page *page)
 {
-	atomic_long_inc(&page_zone(page)->inactive_age);
+	atomic_long_inc(&page_zone(page)->zone_pgdat->inactive_age);
 }
 
 /*
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
