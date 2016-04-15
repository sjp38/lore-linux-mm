Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D340A828E4
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:15:58 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l15so64177067lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:15:58 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id s131si10933324wmf.89.2016.04.15.02.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:15:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id DAAFF1C1B50
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:15:56 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 13/27] mm, memcg: Move memcg limit enforcement from zones to nodes
Date: Fri, 15 Apr 2016 10:13:19 +0100
Message-Id: <1460711613-2761-14-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Memcg was broken by the move of all LRUs to nodes because it is tracking
limits on a per-zone basis while receiving reclaim requests on a per-node
basis. This patch moves limit enforcement to the nodes. Technically, all
the variable names should also change but people are already familiar by
the meaning of "mz" even if "mn" would be a more appropriate name now.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/memcontrol.h |  21 ++---
 include/linux/swap.h       |   2 +-
 mm/memcontrol.c            | 204 +++++++++++++++++++--------------------------
 mm/vmscan.c                |  21 +++--
 mm/workingset.c            |   6 +-
 5 files changed, 110 insertions(+), 144 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 51f4441a69fc..96b973e567f6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -60,7 +60,7 @@ enum mem_cgroup_stat_index {
 };
 
 struct mem_cgroup_reclaim_cookie {
-	struct zone *zone;
+	pg_data_t *pgdat;
 	int priority;
 	unsigned int generation;
 };
@@ -113,7 +113,7 @@ struct mem_cgroup_reclaim_iter {
 /*
  * per-zone information in memory controller.
  */
-struct mem_cgroup_per_zone {
+struct mem_cgroup_per_node {
 	struct lruvec		lruvec;
 	unsigned long		lru_size[NR_LRU_LISTS];
 
@@ -127,10 +127,6 @@ struct mem_cgroup_per_zone {
 						/* use container_of	   */
 };
 
-struct mem_cgroup_per_node {
-	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
-};
-
 struct mem_cgroup_threshold {
 	struct eventfd_ctx *eventfd;
 	unsigned long threshold;
@@ -306,8 +302,7 @@ void mem_cgroup_uncharge_list(struct list_head *page_list);
 
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
 
-struct lruvec *mem_cgroup_lruvec(struct pglist_data *, struct zone *zone,
-				 struct mem_cgroup *);
+struct lruvec *mem_cgroup_lruvec(struct pglist_data *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
@@ -410,9 +405,9 @@ unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 static inline
 unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
-	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_per_node *mz;
 
-	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	mz = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
 	return mz->lru_size[lru];
 }
 
@@ -502,7 +497,7 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
+unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
 
@@ -594,7 +589,7 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
 }
 
 static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
-				struct zone *zone, struct mem_cgroup *memcg)
+				struct mem_cgroup *memcg)
 {
 	return node_lruvec(pgdat);
 }
@@ -718,7 +713,7 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 static inline
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
+unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 					    gfp_t gfp_mask,
 					    unsigned long *total_scanned)
 {
diff --git a/include/linux/swap.h b/include/linux/swap.h
index ba6354fa4909..aa566cec54fb 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -325,7 +325,7 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 						  bool may_swap);
 extern unsigned long mem_cgroup_shrink_node(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
-						struct zone *zone,
+						pg_data_t *pgdat,
 						unsigned long *nr_scanned);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bdeff4b6f394..7ee9f9f727dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -132,15 +132,11 @@ static const char * const mem_cgroup_lru_names[] = {
  * their hierarchy representation
  */
 
-struct mem_cgroup_tree_per_zone {
+struct mem_cgroup_tree_per_node {
 	struct rb_root rb_root;
 	spinlock_t lock;
 };
 
-struct mem_cgroup_tree_per_node {
-	struct mem_cgroup_tree_per_zone rb_tree_per_zone[MAX_NR_ZONES];
-};
-
 struct mem_cgroup_tree {
 	struct mem_cgroup_tree_per_node *rb_tree_per_node[MAX_NUMNODES];
 };
@@ -322,13 +318,10 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 #endif /* !CONFIG_SLOB */
 
-static struct mem_cgroup_per_zone *
-mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
+static struct mem_cgroup_per_node *
+mem_cgroup_nodeinfo(struct mem_cgroup *memcg, pg_data_t *pgdat)
 {
-	int nid = zone_to_nid(zone);
-	int zid = zone_idx(zone);
-
-	return &memcg->nodeinfo[nid]->zoneinfo[zid];
+	return memcg->nodeinfo[pgdat->node_id];
 }
 
 /**
@@ -382,37 +375,35 @@ ino_t page_cgroup_ino(struct page *page)
 	return ino;
 }
 
-static struct mem_cgroup_per_zone *
+static struct mem_cgroup_per_node *
 mem_cgroup_page_zoneinfo(struct mem_cgroup *memcg, struct page *page)
 {
 	int nid = page_to_nid(page);
-	int zid = page_zonenum(page);
 
-	return &memcg->nodeinfo[nid]->zoneinfo[zid];
+	return memcg->nodeinfo[nid];
 }
 
-static struct mem_cgroup_tree_per_zone *
-soft_limit_tree_node_zone(int nid, int zid)
+static struct mem_cgroup_tree_per_node *
+soft_limit_tree_node(int nid)
 {
-	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
+	return soft_limit_tree.rb_tree_per_node[nid];
 }
 
-static struct mem_cgroup_tree_per_zone *
+static struct mem_cgroup_tree_per_node *
 soft_limit_tree_from_page(struct page *page)
 {
 	int nid = page_to_nid(page);
-	int zid = page_zonenum(page);
 
-	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
+	return soft_limit_tree.rb_tree_per_node[nid];
 }
 
-static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_zone *mz,
-					 struct mem_cgroup_tree_per_zone *mctz,
+static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_node *mz,
+					 struct mem_cgroup_tree_per_node *mctz,
 					 unsigned long new_usage_in_excess)
 {
 	struct rb_node **p = &mctz->rb_root.rb_node;
 	struct rb_node *parent = NULL;
-	struct mem_cgroup_per_zone *mz_node;
+	struct mem_cgroup_per_node *mz_node;
 
 	if (mz->on_tree)
 		return;
@@ -422,7 +413,7 @@ static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_zone *mz,
 		return;
 	while (*p) {
 		parent = *p;
-		mz_node = rb_entry(parent, struct mem_cgroup_per_zone,
+		mz_node = rb_entry(parent, struct mem_cgroup_per_node,
 					tree_node);
 		if (mz->usage_in_excess < mz_node->usage_in_excess)
 			p = &(*p)->rb_left;
@@ -438,8 +429,8 @@ static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_zone *mz,
 	mz->on_tree = true;
 }
 
-static void __mem_cgroup_remove_exceeded(struct mem_cgroup_per_zone *mz,
-					 struct mem_cgroup_tree_per_zone *mctz)
+static void __mem_cgroup_remove_exceeded(struct mem_cgroup_per_node *mz,
+					 struct mem_cgroup_tree_per_node *mctz)
 {
 	if (!mz->on_tree)
 		return;
@@ -447,8 +438,8 @@ static void __mem_cgroup_remove_exceeded(struct mem_cgroup_per_zone *mz,
 	mz->on_tree = false;
 }
 
-static void mem_cgroup_remove_exceeded(struct mem_cgroup_per_zone *mz,
-				       struct mem_cgroup_tree_per_zone *mctz)
+static void mem_cgroup_remove_exceeded(struct mem_cgroup_per_node *mz,
+				       struct mem_cgroup_tree_per_node *mctz)
 {
 	unsigned long flags;
 
@@ -472,8 +463,8 @@ static unsigned long soft_limit_excess(struct mem_cgroup *memcg)
 static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
 {
 	unsigned long excess;
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup_tree_per_zone *mctz;
+	struct mem_cgroup_per_node *mz;
+	struct mem_cgroup_tree_per_node *mctz;
 
 	mctz = soft_limit_tree_from_page(page);
 	/*
@@ -506,24 +497,22 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
 
 static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
 {
-	struct mem_cgroup_tree_per_zone *mctz;
-	struct mem_cgroup_per_zone *mz;
-	int nid, zid;
+	struct mem_cgroup_tree_per_node *mctz;
+	struct mem_cgroup_per_node *mz;
+	int nid;
 
 	for_each_node(nid) {
-		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-			mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
-			mctz = soft_limit_tree_node_zone(nid, zid);
-			mem_cgroup_remove_exceeded(mz, mctz);
-		}
+		mz = mem_cgroup_nodeinfo(memcg, NODE_DATA(nid));
+		mctz = soft_limit_tree_node(nid);
+		mem_cgroup_remove_exceeded(mz, mctz);
 	}
 }
 
-static struct mem_cgroup_per_zone *
-__mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
+static struct mem_cgroup_per_node *
+__mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
 {
 	struct rb_node *rightmost = NULL;
-	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_per_node *mz;
 
 retry:
 	mz = NULL;
@@ -531,7 +520,7 @@ __mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 	if (!rightmost)
 		goto done;		/* Nothing to reclaim from */
 
-	mz = rb_entry(rightmost, struct mem_cgroup_per_zone, tree_node);
+	mz = rb_entry(rightmost, struct mem_cgroup_per_node, tree_node);
 	/*
 	 * Remove the node now but someone else can add it back,
 	 * we will to add it back at the end of reclaim to its correct
@@ -545,10 +534,10 @@ __mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 	return mz;
 }
 
-static struct mem_cgroup_per_zone *
-mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
+static struct mem_cgroup_per_node *
+mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
 {
-	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_per_node *mz;
 
 	spin_lock_irq(&mctz->lock);
 	mz = __mem_cgroup_largest_soft_limit_node(mctz);
@@ -642,20 +631,16 @@ unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 					   int nid, unsigned int lru_mask)
 {
 	unsigned long nr = 0;
-	int zid;
+	struct mem_cgroup_per_node *mz;
+	enum lru_list lru;
 
 	VM_BUG_ON((unsigned)nid >= nr_node_ids);
 
-	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-		struct mem_cgroup_per_zone *mz;
-		enum lru_list lru;
-
-		for_each_lru(lru) {
-			if (!(BIT(lru) & lru_mask))
-				continue;
-			mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
-			nr += mz->lru_size[lru];
-		}
+	for_each_lru(lru) {
+		if (!(BIT(lru) & lru_mask))
+			continue;
+		mz = mem_cgroup_nodeinfo(memcg, NODE_DATA(nid));
+		nr += mz->lru_size[lru];
 	}
 	return nr;
 }
@@ -808,9 +793,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	rcu_read_lock();
 
 	if (reclaim) {
-		struct mem_cgroup_per_zone *mz;
+		struct mem_cgroup_per_node *mz;
 
-		mz = mem_cgroup_zone_zoneinfo(root, reclaim->zone);
+		mz = mem_cgroup_nodeinfo(root, reclaim->pgdat);
 		iter = &mz->iter[reclaim->priority];
 
 		if (prev && reclaim->generation != iter->generation)
@@ -909,19 +894,17 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 {
 	struct mem_cgroup *memcg = dead_memcg;
 	struct mem_cgroup_reclaim_iter *iter;
-	struct mem_cgroup_per_zone *mz;
-	int nid, zid;
+	struct mem_cgroup_per_node *mz;
+	int nid;
 	int i;
 
 	while ((memcg = parent_mem_cgroup(memcg))) {
 		for_each_node(nid) {
-			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
-				for (i = 0; i <= DEF_PRIORITY; i++) {
-					iter = &mz->iter[i];
-					cmpxchg(&iter->position,
-						dead_memcg, NULL);
-				}
+			mz = mem_cgroup_nodeinfo(memcg, NODE_DATA(nid));
+			for (i = 0; i <= DEF_PRIORITY; i++) {
+				iter = &mz->iter[i];
+				cmpxchg(&iter->position,
+					dead_memcg, NULL);
 			}
 		}
 	}
@@ -945,7 +928,6 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 /**
  * mem_cgroup_lruvec - get the lru list vector for a node or a memcg zone
  * @node: node of the wanted lruvec
- * @zone: zone of the wanted lruvec
  * @memcg: memcg of the wanted lruvec
  *
  * Returns the lru list vector holding pages for a given @node or a given
@@ -953,9 +935,9 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
  * is disabled.
  */
 struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
-				 struct zone *zone, struct mem_cgroup *memcg)
+				 struct mem_cgroup *memcg)
 {
-	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_per_node *mz;
 	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled()) {
@@ -963,7 +945,7 @@ struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
 		goto out;
 	}
 
-	mz = mem_cgroup_zone_zoneinfo(memcg, zone);
+	mz = mem_cgroup_nodeinfo(memcg, pgdat);
 	lruvec = &mz->lruvec;
 out:
 	/*
@@ -971,8 +953,8 @@ struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
 	 * we have to be prepared to initialize lruvec->zone here;
 	 * and if offlined then reonlined, we need to reinitialize it.
 	 */
-	if (unlikely(lruvec->pgdat != zone->zone_pgdat))
-		lruvec->pgdat = zone->zone_pgdat;
+	if (unlikely(lruvec->pgdat != pgdat))
+		lruvec->pgdat = pgdat;
 	return lruvec;
 }
 
@@ -987,7 +969,7 @@ struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
  */
 struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgdat)
 {
-	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_per_node *mz;
 	struct mem_cgroup *memcg;
 	struct lruvec *lruvec;
 
@@ -1029,13 +1011,13 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgd
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 				int nr_pages)
 {
-	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_per_node *mz;
 	unsigned long *lru_size;
 
 	if (mem_cgroup_disabled())
 		return;
 
-	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	mz = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
 	lru_size = mz->lru_size + lru;
 	*lru_size += nr_pages;
 	VM_BUG_ON((long)(*lru_size) < 0);
@@ -1412,7 +1394,7 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 #endif
 
 static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
-				   struct zone *zone,
+				   pg_data_t *pgdat,
 				   gfp_t gfp_mask,
 				   unsigned long *total_scanned)
 {
@@ -1422,7 +1404,7 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 	unsigned long excess;
 	unsigned long nr_scanned;
 	struct mem_cgroup_reclaim_cookie reclaim = {
-		.zone = zone,
+		.pgdat = pgdat,
 		.priority = 0,
 	};
 
@@ -1453,7 +1435,7 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 			continue;
 		}
 		total += mem_cgroup_shrink_node(victim, gfp_mask, false,
-					zone, &nr_scanned);
+					pgdat, &nr_scanned);
 		*total_scanned += nr_scanned;
 		if (!soft_limit_excess(root_memcg))
 			break;
@@ -2545,22 +2527,22 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
+unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 					    gfp_t gfp_mask,
 					    unsigned long *total_scanned)
 {
 	unsigned long nr_reclaimed = 0;
-	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
+	struct mem_cgroup_per_node *mz, *next_mz = NULL;
 	unsigned long reclaimed;
 	int loop = 0;
-	struct mem_cgroup_tree_per_zone *mctz;
+	struct mem_cgroup_tree_per_node *mctz;
 	unsigned long excess;
 	unsigned long nr_scanned;
 
 	if (order > 0)
 		return 0;
 
-	mctz = soft_limit_tree_node_zone(zone_to_nid(zone), zone_idx(zone));
+	mctz = soft_limit_tree_node(pgdat->node_id);
 	/*
 	 * This loop can run a while, specially if mem_cgroup's continuously
 	 * keep exceeding their soft limit and putting the system under
@@ -2575,7 +2557,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 			break;
 
 		nr_scanned = 0;
-		reclaimed = mem_cgroup_soft_reclaim(mz->memcg, zone,
+		reclaimed = mem_cgroup_soft_reclaim(mz->memcg, pgdat,
 						    gfp_mask, &nr_scanned);
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
@@ -3194,22 +3176,21 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 
 #ifdef CONFIG_DEBUG_VM
 	{
-		int nid, zid;
-		struct mem_cgroup_per_zone *mz;
+		pg_data_t *pgdat;
+		struct mem_cgroup_per_node *mz;
 		struct zone_reclaim_stat *rstat;
 		unsigned long recent_rotated[2] = {0, 0};
 		unsigned long recent_scanned[2] = {0, 0};
 
-		for_each_online_node(nid)
-			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
-				rstat = &mz->lruvec.reclaim_stat;
+		for_each_online_pgdat(pgdat) {
+			mz = mem_cgroup_nodeinfo(memcg, pgdat);
+			rstat = &mz->lruvec.reclaim_stat;
 
-				recent_rotated[0] += rstat->recent_rotated[0];
-				recent_rotated[1] += rstat->recent_rotated[1];
-				recent_scanned[0] += rstat->recent_scanned[0];
-				recent_scanned[1] += rstat->recent_scanned[1];
-			}
+			recent_rotated[0] += rstat->recent_rotated[0];
+			recent_rotated[1] += rstat->recent_rotated[1];
+			recent_scanned[0] += rstat->recent_scanned[0];
+			recent_scanned[1] += rstat->recent_scanned[1];
+		}
 		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[0]);
 		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[1]);
 		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[0]);
@@ -4035,11 +4016,10 @@ static struct cftype mem_cgroup_legacy_files[] = {
 	{ },	/* terminate */
 };
 
-static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
+static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
-	struct mem_cgroup_per_zone *mz;
-	int zone, tmp = node;
+	int tmp = node;
 	/*
 	 * This routine is called against possible nodes.
 	 * But it's BUG to call kmalloc() against offline node.
@@ -4054,18 +4034,16 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return 1;
 
-	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-		mz = &pn->zoneinfo[zone];
-		lruvec_init(&mz->lruvec);
-		mz->usage_in_excess = 0;
-		mz->on_tree = false;
-		mz->memcg = memcg;
-	}
+	lruvec_init(&pn->lruvec);
+	pn->usage_in_excess = 0;
+	pn->on_tree = false;
+	pn->memcg = memcg;
+
 	memcg->nodeinfo[node] = pn;
 	return 0;
 }
 
-static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
+static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 {
 	kfree(memcg->nodeinfo[node]);
 }
@@ -4076,7 +4054,7 @@ static void mem_cgroup_free(struct mem_cgroup *memcg)
 
 	memcg_wb_domain_exit(memcg);
 	for_each_node(node)
-		free_mem_cgroup_per_zone_info(memcg, node);
+		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->stat);
 	kfree(memcg);
 }
@@ -4099,7 +4077,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 		goto fail;
 
 	for_each_node(node)
-		if (alloc_mem_cgroup_per_zone_info(memcg, node))
+		if (alloc_mem_cgroup_per_node_info(memcg, node))
 			goto fail;
 
 	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
@@ -5688,18 +5666,12 @@ static int __init mem_cgroup_init(void)
 
 	for_each_node(node) {
 		struct mem_cgroup_tree_per_node *rtpn;
-		int zone;
 
 		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
 				    node_online(node) ? node : NUMA_NO_NODE);
 
-		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			struct mem_cgroup_tree_per_zone *rtpz;
-
-			rtpz = &rtpn->rb_tree_per_zone[zone];
-			rtpz->rb_root = RB_ROOT;
-			spin_lock_init(&rtpz->lock);
-		}
+		rtpn->rb_root = RB_ROOT;
+		spin_lock_init(&rtpn->lock);
 		soft_limit_tree.rb_tree_per_node[node] = rtpn;
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 65c6da3d9d4c..9cf27598f49f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2222,8 +2222,7 @@ static inline void init_tlb_ubc(void)
 static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memcg,
 			      struct scan_control *sc, unsigned long *lru_pages)
 {
-	struct zone *zone = &pgdat->node_zones[sc->reclaim_idx];
-	struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, zone, memcg);
+	struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -2430,7 +2429,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
 		struct mem_cgroup_reclaim_cookie reclaim = {
-			.zone = &pgdat->node_zones[classzone_idx],
+			.pgdat = pgdat,
 			.priority = sc->priority,
 		};
 		unsigned long node_lru_pages = 0;
@@ -2628,7 +2627,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 			 * and balancing, not for a memcg's limit.
 			 */
 			nr_soft_scanned = 0;
-			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
+			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone->zone_pgdat,
 						sc->order, sc->gfp_mask,
 						&nr_soft_scanned);
 			sc->nr_reclaimed += nr_soft_reclaimed;
@@ -2909,7 +2908,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 
 unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 						gfp_t gfp_mask, bool noswap,
-						struct zone *zone,
+						pg_data_t *pgdat,
 						unsigned long *nr_scanned)
 {
 	struct scan_control sc = {
@@ -2917,7 +2916,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 		.target_mem_cgroup = memcg,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
-		.reclaim_idx = zone_idx(zone),
+		.reclaim_idx = MAX_NR_ZONES - 1,
 		.may_swap = !noswap,
 	};
 	unsigned long lru_pages;
@@ -2936,7 +2935,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_node_memcg(zone->zone_pgdat, memcg, &sc, &lru_pages);
+	shrink_node_memcg(pgdat, memcg, &sc, &lru_pages);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -2985,7 +2984,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 #endif
 
 static void age_active_anon(struct pglist_data *pgdat,
-				struct zone *zone, struct scan_control *sc)
+				struct scan_control *sc)
 {
 	struct mem_cgroup *memcg;
 
@@ -2994,7 +2993,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
-		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, zone, memcg);
+		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 
 		if (inactive_anon_is_low(lruvec))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
@@ -3182,7 +3181,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * pages are rotated regardless of classzone as this is
 		 * about consistent aging.
 		 */
-		age_active_anon(pgdat, &pgdat->node_zones[MAX_NR_ZONES - 1], &sc);
+		age_active_anon(pgdat, &sc);
 
 		/*
 		 * If we're getting trouble reclaiming, start doing writepage
@@ -3194,7 +3193,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		/* Call soft limit reclaim before calling shrink_node. */
 		sc.nr_scanned = 0;
 		nr_soft_scanned = 0;
-		nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone, sc.order,
+		nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(pgdat, sc.order,
 						sc.gfp_mask, &nr_soft_scanned);
 		sc.nr_reclaimed += nr_soft_reclaimed;
 
diff --git a/mm/workingset.c b/mm/workingset.c
index f68cc74a7795..d06d69670b5d 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -218,7 +218,7 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 	VM_BUG_ON_PAGE(page_count(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
-	lruvec = mem_cgroup_lruvec(zone->zone_pgdat, zone, memcg);
+	lruvec = mem_cgroup_lruvec(zone->zone_pgdat, memcg);
 	eviction = atomic_long_inc_return(&lruvec->inactive_age);
 	return pack_shadow(memcgid, zone, eviction);
 }
@@ -267,7 +267,7 @@ bool workingset_refault(void *shadow)
 		rcu_read_unlock();
 		return false;
 	}
-	lruvec = mem_cgroup_lruvec(zone->zone_pgdat, zone, memcg);
+	lruvec = mem_cgroup_lruvec(zone->zone_pgdat, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
 	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
 	rcu_read_unlock();
@@ -317,7 +317,7 @@ void workingset_activation(struct page *page)
 	 */
 	if (!mem_cgroup_disabled() && !page_memcg(page))
 		goto out;
-	lruvec = mem_cgroup_lruvec(page_zone(page)->zone_pgdat, page_zone(page), page_memcg(page));
+	lruvec = mem_cgroup_lruvec(page_zone(page)->zone_pgdat, page_memcg(page));
 	atomic_long_inc(&lruvec->inactive_age);
 out:
 	unlock_page_memcg(page);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
