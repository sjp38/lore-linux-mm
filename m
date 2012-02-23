Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 8B2AD6B0109
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:53:33 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:53:33 -0800 (PST)
Subject: [PATCH v3 21/21] mm: zone lru vectors interleaving
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:53:28 +0400
Message-ID: <20120223135328.12988.87152.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

Split zones into several lru vectors with pfn-based interleaving.
Thus we can redeuce lru_lock contention without using cgroups.

By default there 4 lru with 16Mb interleaving.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/huge_mm.h    |    3 ++
 include/linux/memcontrol.h |    2 +-
 include/linux/mm.h         |   45 +++++++++++++++++++++++++++++------
 include/linux/mmzone.h     |    4 ++-
 mm/Kconfig                 |   16 +++++++++++++
 mm/internal.h              |   19 ++++++++++++++-
 mm/memcontrol.c            |   56 ++++++++++++++++++++++++--------------------
 mm/page_alloc.c            |    7 +++---
 mm/vmscan.c                |   18 ++++++++++----
 9 files changed, 124 insertions(+), 46 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 1b92129..3a45cb3 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -107,6 +107,9 @@ extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
 #if HPAGE_PMD_ORDER > MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
+#if HPAGE_PMD_ORDER > CONFIG_PAGE_LRU_INTERLEAVING
+#error "zone lru interleaving order lower than huge page order"
+#endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
 			    unsigned long *vm_flags, int advice);
 extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c3e46b0..b137d4c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -199,7 +199,7 @@ static inline void mem_cgroup_uncharge_cache_page(struct page *page)
 static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 						    struct mem_cgroup *memcg)
 {
-	return &zone->lruvec;
+	return zone->lruvec;
 }
 
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c6dc4ab..d14db10 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -728,12 +728,46 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
 #endif
 }
 
+#if CONFIG_PAGE_LRU_SPLIT == 1
+
+static inline int page_lruvec_id(struct page *page)
+{
+	return 0;
+}
+
+#else /* CONFIG_PAGE_LRU_SPLIT */
+
+static inline int page_lruvec_id(struct page *page)
+{
+
+	unsigned long pfn = page_to_pfn(page);
+
+	return (pfn >> CONFIG_PAGE_LRU_INTERLEAVING) % CONFIG_PAGE_LRU_SPLIT;
+}
+
+#endif /* CONFIG_PAGE_LRU_SPLIT */
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
-/* Multiple lruvecs in zone */
+/* Dynamic page to lruvec mapping */
 
 extern struct lruvec *page_lruvec(struct page *page);
 
+#else
+
+/* Fixed page to lruvecs mapping */
+
+static inline struct lruvec *page_lruvec(struct page *page)
+{
+	return page_zone(page)->lruvec + page_lruvec_id(page);
+}
+
+#endif
+
+#if defined(CONFIG_CGROUP_MEM_RES_CTLR) || (CONFIG_PAGE_LRU_SPLIT != 1)
+
+/* Multiple lruvecs in zone */
+
 static inline struct zone *lruvec_zone(struct lruvec *lruvec)
 {
 	return lruvec->zone;
@@ -744,15 +778,10 @@ static inline struct pglist_data *lruvec_node(struct lruvec *lruvec)
 	return lruvec->node;
 }
 
-#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+#else /* defined(CONFIG_CGROUP_MEM_RES_CTLR) || (CONFIG_PAGE_LRU_SPLIT != 1) */
 
 /* Single lruvec in zone */
 
-static inline struct lruvec *page_lruvec(struct page *page)
-{
-	return &page_zone(page)->lruvec;
-}
-
 static inline struct zone *lruvec_zone(struct lruvec *lruvec)
 {
 	return container_of(lruvec, struct zone, lruvec);
@@ -763,7 +792,7 @@ static inline struct pglist_data *lruvec_node(struct lruvec *lruvec)
 	return lruvec_zone(lruvec)->zone_pgdat;
 }
 
-#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
+#endif /* defined(CONFIG_CGROUP_MEM_RES_CTLR) || (CONFIG_PAGE_LRU_SPLIT != 1) */
 
 /*
  * Some inline functions in vmstat.h depend on page_zone()
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9880150..a52f423 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -311,7 +311,7 @@ struct lruvec {
 
 	struct zone_reclaim_stat	reclaim_stat;
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#if defined(CONFIG_CGROUP_MEM_RES_CTLR) || (CONFIG_PAGE_LRU_SPLIT != 1)
 	struct zone		*zone;
 	struct pglist_data	*node;
 #endif
@@ -388,7 +388,7 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	struct lruvec		lruvec;
+	struct lruvec		lruvec[CONFIG_PAGE_LRU_SPLIT];
 
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
diff --git a/mm/Kconfig b/mm/Kconfig
index 2613c91..48ff866 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -183,6 +183,22 @@ config SPLIT_PTLOCK_CPUS
 	default "999999" if DEBUG_SPINLOCK || DEBUG_LOCK_ALLOC
 	default "4"
 
+config PAGE_LRU_SPLIT
+	int "Memory lru lists per zone"
+	default	4 if EXPERIMENTAL && SPARSEMEM_VMEMMAP
+	default 1
+	help
+	  The number of lru lists in each memory zone for interleaving.
+	  Allows to redeuce lru_lock contention, but adds some overhead.
+	  Without SPARSEMEM_VMEMMAP might be costly. "1" means no split.
+
+config PAGE_LRU_INTERLEAVING
+	int "Memory lru lists interleaving page-order"
+	default	12
+	help
+	  Page order for lru lists interleaving. By default 12 (16Mb).
+	  Must be greater than huge-page order.
+	  With CONFIG_PAGE_LRU_SPLIT=1 has no effect.
 #
 # support for memory compaction
 config COMPACTION
diff --git a/mm/internal.h b/mm/internal.h
index 9a9fd53..f429911 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -13,6 +13,15 @@
 
 #include <linux/mm.h>
 
+#define for_each_zone_id(zone_id) \
+	for ( zone_id = 0 ; zone_id < MAX_NR_ZONES ; zone_id++ )
+
+#define for_each_lruvec_id(lruvec_id) \
+	for ( lruvec_id = 0 ; lruvec_id < CONFIG_PAGE_LRU_SPLIT ; lruvec_id++ )
+
+#define for_each_zone_and_lruvec_id(zone_id, lruvec_id) \
+	for_each_zone_id(zone_id) for_each_lruvec_id(lruvec_id)
+
 static inline void lock_lruvec(struct lruvec *lruvec, unsigned long *flags)
 {
 	spin_lock_irqsave(&lruvec->lru_lock, *flags);
@@ -125,7 +134,15 @@ static inline void __wait_lruvec_unlock(struct lruvec *lruvec)
 static inline struct lruvec *__relock_page_lruvec(struct lruvec *locked_lruvec,
 						  struct page *page)
 {
-	/* Currently ony one lruvec per-zone */
+#if CONFIG_PAGE_LRU_SPLIT != 1
+	struct lruvec *lruvec = page_lruvec(page);
+
+	if (unlikely(lruvec != locked_lruvec)) {
+		spin_unlock(&locked_lruvec->lru_lock);
+		spin_lock(&lruvec->lru_lock);
+		locked_lruvec = lruvec;
+	}
+#endif
 	return locked_lruvec;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fbeff85..59fe4b0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -134,7 +134,7 @@ struct mem_cgroup_reclaim_iter {
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_zone {
-	struct lruvec		lruvec;
+	struct lruvec		lruvec[CONFIG_PAGE_LRU_SPLIT];
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
@@ -694,12 +694,15 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 	struct mem_cgroup_per_zone *mz;
 	enum lru_list lru;
 	unsigned long ret = 0;
+	int lruvec_id;
 
 	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
-	for_each_lru_counter(lru) {
-		if (BIT(lru) & lru_mask)
-			ret += mz->lruvec.pages_count[lru];
+	for_each_lruvec_id(lruvec_id) {
+		for_each_lru_counter(lru) {
+			if (BIT(lru) & lru_mask)
+				ret += mz->lruvec[lruvec_id].pages_count[lru];
+		}
 	}
 	return ret;
 }
@@ -995,7 +998,7 @@ out:
 EXPORT_SYMBOL(mem_cgroup_count_vm_event);
 
 /**
- * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
+ * mem_cgroup_zone_lruvec - get the array of lruvecs for a zone and memcg
  * @zone: zone of the wanted lruvec
  * @mem: memcg of the wanted lruvec
  *
@@ -1009,10 +1012,10 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 	struct mem_cgroup_per_zone *mz;
 
 	if (mem_cgroup_disabled())
-		return &zone->lruvec;
+		return zone->lruvec;
 
 	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
-	return &mz->lruvec;
+	return mz->lruvec;
 }
 
 /**
@@ -1027,14 +1030,15 @@ struct lruvec *page_lruvec(struct page *page)
 {
 	struct mem_cgroup_per_zone *mz;
 	struct page_cgroup *pc;
+	int lruvec_id = page_lruvec_id(page);
 
 	if (mem_cgroup_disabled())
-		return &page_zone(page)->lruvec;
+		return page_zone(page)->lruvec + lruvec_id;
 
 	pc = lookup_page_cgroup(page);
 	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
 			page_to_nid(page), page_zonenum(page));
-	return &mz->lruvec;
+	return mz->lruvec + lruvec_id;
 }
 
 /*
@@ -3495,7 +3499,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
 static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
-				int node, int zid, enum lru_list lru)
+				int node, int zid, int lid, enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags, loop;
@@ -3507,7 +3511,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 
 	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
-	lruvec = &mz->lruvec;
+	lruvec = mz->lruvec + lid;
 	list = &lruvec->pages_lru[lru];
 	loop = lruvec->pages_count[lru];
 	/* give some margin against EBUSY etc...*/
@@ -3558,7 +3562,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
 {
 	int ret;
-	int node, zid, shrink;
+	int node, zid, lid, shrink;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct cgroup *cgrp = memcg->css.cgroup;
 
@@ -3582,18 +3586,17 @@ move_account:
 		ret = 0;
 		mem_cgroup_start_move(memcg);
 		for_each_node_state(node, N_HIGH_MEMORY) {
-			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
+			for_each_zone_and_lruvec_id(zid, lid) {
 				enum lru_list lru;
 				for_each_lru(lru) {
 					ret = mem_cgroup_force_empty_list(memcg,
-							node, zid, lru);
+							node, zid, lid, lru);
 					if (ret)
-						break;
+						goto abort;
 				}
 			}
-			if (ret)
-				break;
 		}
+abort:
 		mem_cgroup_end_move(memcg);
 		memcg_oom_recover(memcg);
 		/* it seems parent cgroup doesn't have enough mem */
@@ -4061,16 +4064,16 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 
 #ifdef CONFIG_DEBUG_VM
 	{
-		int nid, zid;
+		int nid, zid, lid;
 		struct mem_cgroup_per_zone *mz;
 		struct zone_reclaim_stat *rs;
 		unsigned long recent_rotated[2] = {0, 0};
 		unsigned long recent_scanned[2] = {0, 0};
 
 		for_each_online_node(nid)
-			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			for_each_zone_and_lruvec_id(zid, lid) {
 				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
-				rs = &mz->lruvec.reclaim_stat;
+				rs = &mz->lruvec[lid].reclaim_stat;
 
 				recent_rotated[0] += rs->recent_rotated[0];
 				recent_rotated[1] += rs->recent_rotated[1];
@@ -4618,7 +4621,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
-	int zone, tmp = node;
+	int zone, lruvec_id, tmp = node;
 	/*
 	 * This routine is called against possible nodes.
 	 * But it's BUG to call kmalloc() against offline node.
@@ -4635,8 +4638,9 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		init_zone_lruvec(&NODE_DATA(node)->node_zones[zone],
-				 &mz->lruvec);
+		for_each_lruvec_id(lruvec_id)
+			init_zone_lruvec(&NODE_DATA(node)->node_zones[zone],
+					 &mz->lruvec[lruvec_id]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
@@ -4648,13 +4652,13 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn = memcg->info.nodeinfo[node];
-	int zone;
+	int zone, lruvec;
 
 	if (!pn)
 		return;
 
-	for (zone = 0; zone < MAX_NR_ZONES; zone++)
-		wait_lruvec_unlock(&pn->zoneinfo[zone].lruvec);
+	for_each_zone_and_lruvec_id(zone, lruvec)
+		wait_lruvec_unlock(&pn->zoneinfo[zone].lruvec[lruvec]);
 
 	kfree(pn);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index beadcc9..9b0cc92 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4297,7 +4297,7 @@ void init_zone_lruvec(struct zone *zone, struct lruvec *lruvec)
 	spin_lock_init(&lruvec->lru_lock);
 	for_each_lru(lru)
 		INIT_LIST_HEAD(&lruvec->pages_lru[lru]);
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#if defined(CONFIG_CGROUP_MEM_RES_CTLR) || (CONFIG_PAGE_LRU_SPLIT != 1)
 	lruvec->node = zone->zone_pgdat;
 	lruvec->zone = zone;
 #endif
@@ -4312,7 +4312,7 @@ void init_zone_lruvec(struct zone *zone, struct lruvec *lruvec)
 static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		unsigned long *zones_size, unsigned long *zholes_size)
 {
-	enum zone_type j;
+	enum zone_type j, lruvec_id;
 	int nid = pgdat->node_id;
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 	int ret;
@@ -4374,7 +4374,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
-		init_zone_lruvec(zone, &zone->lruvec);
+		for_each_lruvec_id(lruvec_id)
+			init_zone_lruvec(zone, &zone->lruvec[lruvec_id]);
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1ff010..aaf2b0e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2202,12 +2202,14 @@ static void shrink_zone(int priority, struct zone *zone,
 	};
 	struct mem_cgroup *memcg;
 	struct lruvec *lruvec;
+	int lruvec_id;
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
 		lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
-		shrink_lruvec(priority, lruvec, sc);
+		for_each_lruvec_id(lruvec_id)
+			shrink_lruvec(priority, lruvec + lruvec_id, sc);
 
 		/*
 		 * Limit reclaim has historically picked one memcg and
@@ -2529,6 +2531,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 		.target_mem_cgroup = memcg,
 	};
 	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	int lruvec_id;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2544,7 +2547,8 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_lruvec(0, lruvec, &sc);
+	for_each_lruvec_id(lruvec_id)
+		shrink_lruvec(0, lruvec + lruvec_id, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -2599,6 +2603,7 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc,
 			    int priority)
 {
 	struct mem_cgroup *memcg;
+	int lruvec_id;
 
 	if (!total_swap_pages)
 		return;
@@ -2607,9 +2612,12 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc,
 	do {
 		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
-		if (inactive_anon_is_low(lruvec))
-			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
-					   sc, priority, 0);
+		for_each_lruvec_id(lruvec_id) {
+			if (inactive_anon_is_low(lruvec + lruvec_id))
+				shrink_active_list(SWAP_CLUSTER_MAX,
+						   lruvec + lruvec_id,
+						   sc, priority, 0);
+		}
 
 		memcg = mem_cgroup_iter(NULL, memcg, NULL);
 	} while (memcg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
