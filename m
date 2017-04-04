Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB71B6B03A1
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 18:02:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u77so488269wrb.6
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:02:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 7si1102877wmz.168.2017.04.04.15.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 15:02:00 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/4] mm: memcontrol: use node page state naming scheme for memcg
Date: Tue,  4 Apr 2017 18:01:48 -0400
Message-Id: <20170404220148.28338-4-hannes@cmpxchg.org>
In-Reply-To: <20170404220148.28338-1-hannes@cmpxchg.org>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The memory controllers stat function names are awkwardly long and
arbitrarily different from the zone and node stat functions.

The current interface is named:

  mem_cgroup_read_stat()
  mem_cgroup_update_stat()
  mem_cgroup_inc_stat()
  mem_cgroup_dec_stat()
  mem_cgroup_update_page_stat()
  mem_cgroup_inc_page_stat()
  mem_cgroup_dec_page_stat()

This patch renames it to match the corresponding node stat functions:

  memcg_page_state()		[node_page_state()]
  mod_memcg_state()		[mod_node_state()]
  inc_memcg_state()		[inc_node_state()]
  dec_memcg_state()		[dec_node_state()]
  mod_memcg_page_state()	[mod_node_page_state()]
  inc_memcg_page_state()	[inc_node_page_state()]
  dec_memcg_page_state()	[dec_node_page_state()]

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 73 +++++++++++++++++++++++-----------------------
 mm/memcontrol.c            | 38 ++++++++++++------------
 mm/page-writeback.c        | 10 +++----
 mm/rmap.c                  |  4 +--
 mm/vmscan.c                |  5 ++--
 mm/workingset.c            |  6 ++--
 6 files changed, 68 insertions(+), 68 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0fa1f5de6841..899949bbb2f9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -472,8 +472,8 @@ extern int do_swap_account;
 void lock_page_memcg(struct page *page);
 void unlock_page_memcg(struct page *page);
 
-static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
-						 enum memcg_stat_item idx)
+static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
+					     enum memcg_stat_item idx)
 {
 	long val = 0;
 	int cpu;
@@ -487,27 +487,27 @@ static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 	return val;
 }
 
-static inline void mem_cgroup_update_stat(struct mem_cgroup *memcg,
-					  enum memcg_stat_item idx, int val)
+static inline void mod_memcg_state(struct mem_cgroup *memcg,
+				   enum memcg_stat_item idx, int val)
 {
 	if (!mem_cgroup_disabled())
 		this_cpu_add(memcg->stat->count[idx], val);
 }
 
-static inline void mem_cgroup_inc_stat(struct mem_cgroup *memcg,
-				       enum memcg_stat_item idx)
+static inline void inc_memcg_state(struct mem_cgroup *memcg,
+				   enum memcg_stat_item idx)
 {
-	mem_cgroup_update_stat(memcg, idx, 1);
+	mod_memcg_state(memcg, idx, 1);
 }
 
-static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
-				       enum memcg_stat_item idx)
+static inline void dec_memcg_state(struct mem_cgroup *memcg,
+				   enum memcg_stat_item idx)
 {
-	mem_cgroup_update_stat(memcg, idx, -1);
+	mod_memcg_state(memcg, idx, -1);
 }
 
 /**
- * mem_cgroup_update_page_stat - update page state statistics
+ * mod_memcg_page_state - update page state statistics
  * @page: the page
  * @idx: page state item to account
  * @val: number of pages (positive or negative)
@@ -518,28 +518,28 @@ static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
  *
  *   lock_page(page) or lock_page_memcg(page)
  *   if (TestClearPageState(page))
- *     mem_cgroup_update_page_stat(page, state, -1);
+ *     mod_memcg_page_state(page, state, -1);
  *   unlock_page(page) or unlock_page_memcg(page)
  *
  * Kernel pages are an exception to this, since they'll never move.
  */
-static inline void mem_cgroup_update_page_stat(struct page *page,
-				 enum memcg_stat_item idx, int val)
+static inline void mod_memcg_page_state(struct page *page,
+					enum memcg_stat_item idx, int val)
 {
 	if (page->mem_cgroup)
-		mem_cgroup_update_stat(page->mem_cgroup, idx, val);
+		mod_memcg_state(page->mem_cgroup, idx, val);
 }
 
-static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum memcg_stat_item idx)
+static inline void inc_memcg_page_state(struct page *page,
+					enum memcg_stat_item idx)
 {
-	mem_cgroup_update_page_stat(page, idx, 1);
+	mod_memcg_page_state(page, idx, 1);
 }
 
-static inline void mem_cgroup_dec_page_stat(struct page *page,
-					    enum memcg_stat_item idx)
+static inline void dec_memcg_page_state(struct page *page,
+					enum memcg_stat_item idx)
 {
-	mem_cgroup_update_page_stat(page, idx, -1);
+	mod_memcg_page_state(page, idx, -1);
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
@@ -739,40 +739,41 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
 	return false;
 }
 
-static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
-						 enum mem_cgroup_stat_index idx)
+static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
+					     enum memcg_stat_item idx)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_update_stat(struct mem_cgroup *memcg,
-					  enum memcg_stat_item idx, int val)
+static inline void mod_memcg_state(struct mem_cgroup *memcg,
+				   enum memcg_stat_item idx,
+				   int nr)
 {
 }
 
-static inline void mem_cgroup_inc_stat(struct mem_cgroup *memcg,
-				       enum memcg_stat_item idx)
+static inline void inc_memcg_state(struct mem_cgroup *memcg,
+				   enum memcg_stat_item idx)
 {
 }
 
-static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
-				       enum memcg_stat_item idx)
+static inline void dec_memcg_state(struct mem_cgroup *memcg,
+				   enum memcg_stat_item idx)
 {
 }
 
-static inline void mem_cgroup_update_page_stat(struct page *page,
-					       enum memcg_stat_item idx,
-					       int nr)
+static inline void mod_memcg_page_state(struct page *page,
+					enum memcg_stat_item idx,
+					int nr)
 {
 }
 
-static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum memcg_stat_item idx)
+static inline void inc_memcg_page_state(struct page *page,
+					enum memcg_stat_item idx)
 {
 }
 
-static inline void mem_cgroup_dec_page_stat(struct page *page,
-					    enum memcg_stat_item idx)
+static inline void dec_memcg_page_state(struct page *page,
+					enum memcg_stat_item idx)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6fe4c7fafbfc..ff73899af61a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -552,8 +552,8 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
  * implemented.
  */
 
-static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
-					    enum memcg_event_item event)
+static unsigned long memcg_sum_events(struct mem_cgroup *memcg,
+				      enum memcg_event_item event)
 {
 	unsigned long val = 0;
 	int cpu;
@@ -1180,7 +1180,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 			if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
 				continue;
 			pr_cont(" %s:%luKB", memcg1_stat_names[i],
-				K(mem_cgroup_read_stat(iter, memcg1_stats[i])));
+				K(memcg_page_state(iter, memcg1_stats[i])));
 		}
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
@@ -2713,7 +2713,7 @@ static void tree_stat(struct mem_cgroup *memcg, unsigned long *stat)
 
 	for_each_mem_cgroup_tree(iter, memcg) {
 		for (i = 0; i < MEMCG_NR_STAT; i++)
-			stat[i] += mem_cgroup_read_stat(iter, i);
+			stat[i] += memcg_page_state(iter, i);
 	}
 }
 
@@ -2726,7 +2726,7 @@ static void tree_events(struct mem_cgroup *memcg, unsigned long *events)
 
 	for_each_mem_cgroup_tree(iter, memcg) {
 		for (i = 0; i < MEMCG_NR_EVENTS; i++)
-			events[i] += mem_cgroup_read_events(iter, i);
+			events[i] += memcg_sum_events(iter, i);
 	}
 }
 
@@ -2738,10 +2738,10 @@ static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 		struct mem_cgroup *iter;
 
 		for_each_mem_cgroup_tree(iter, memcg) {
-			val += mem_cgroup_read_stat(iter, MEMCG_CACHE);
-			val += mem_cgroup_read_stat(iter, MEMCG_RSS);
+			val += memcg_page_state(iter, MEMCG_CACHE);
+			val += memcg_page_state(iter, MEMCG_RSS);
 			if (swap)
-				val += mem_cgroup_read_stat(iter, MEMCG_SWAP);
+				val += memcg_page_state(iter, MEMCG_SWAP);
 		}
 	} else {
 		if (!swap)
@@ -3145,13 +3145,13 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
 		seq_printf(m, "%s %lu\n", memcg1_stat_names[i],
-			   mem_cgroup_read_stat(memcg, memcg1_stats[i]) *
+			   memcg_page_state(memcg, memcg1_stats[i]) *
 			   PAGE_SIZE);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
 		seq_printf(m, "%s %lu\n", memcg1_event_names[i],
-			   mem_cgroup_read_events(memcg, memcg1_events[i]));
+			   memcg_sum_events(memcg, memcg1_events[i]));
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
@@ -3175,7 +3175,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
 		for_each_mem_cgroup_tree(mi, memcg)
-			val += mem_cgroup_read_stat(mi, memcg1_stats[i]) *
+			val += memcg_page_state(mi, memcg1_stats[i]) *
 			PAGE_SIZE;
 		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i], val);
 	}
@@ -3184,7 +3184,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		unsigned long long val = 0;
 
 		for_each_mem_cgroup_tree(mi, memcg)
-			val += mem_cgroup_read_events(mi, memcg1_events[i]);
+			val += memcg_sum_events(mi, memcg1_events[i]);
 		seq_printf(m, "total_%s %llu\n", memcg1_event_names[i], val);
 	}
 
@@ -3650,10 +3650,10 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
 	struct mem_cgroup *parent;
 
-	*pdirty = mem_cgroup_read_stat(memcg, NR_FILE_DIRTY);
+	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
 
 	/* this should eventually include NR_UNSTABLE_NFS */
-	*pwriteback = mem_cgroup_read_stat(memcg, NR_WRITEBACK);
+	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
 	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
 						     (1 << LRU_ACTIVE_FILE));
 	*pheadroom = PAGE_COUNTER_MAX;
@@ -4515,7 +4515,7 @@ static int mem_cgroup_move_account(struct page *page,
 
 	/*
 	 * move_lock grabbed above and caller set from->moving_account, so
-	 * mem_cgroup_update_page_stat() will serialize updates to PageDirty.
+	 * mod_memcg_page_state will serialize updates to PageDirty.
 	 * So mapping should be stable for dirty pages.
 	 */
 	if (!anon && PageDirty(page)) {
@@ -5161,10 +5161,10 @@ static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 
-	seq_printf(m, "low %lu\n", mem_cgroup_read_events(memcg, MEMCG_LOW));
-	seq_printf(m, "high %lu\n", mem_cgroup_read_events(memcg, MEMCG_HIGH));
-	seq_printf(m, "max %lu\n", mem_cgroup_read_events(memcg, MEMCG_MAX));
-	seq_printf(m, "oom %lu\n", mem_cgroup_read_events(memcg, MEMCG_OOM));
+	seq_printf(m, "low %lu\n", memcg_sum_events(memcg, MEMCG_LOW));
+	seq_printf(m, "high %lu\n", memcg_sum_events(memcg, MEMCG_HIGH));
+	seq_printf(m, "max %lu\n", memcg_sum_events(memcg, MEMCG_MAX));
+	seq_printf(m, "oom %lu\n", memcg_sum_events(memcg, MEMCG_OOM));
 
 	return 0;
 }
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 777711203809..2359608d2568 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2427,7 +2427,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		inode_attach_wb(inode, page);
 		wb = inode_to_wb(inode);
 
-		mem_cgroup_inc_page_stat(page, NR_FILE_DIRTY);
+		inc_memcg_page_state(page, NR_FILE_DIRTY);
 		__inc_node_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
@@ -2449,7 +2449,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb)
 {
 	if (mapping_cap_account_dirty(mapping)) {
-		mem_cgroup_dec_page_stat(page, NR_FILE_DIRTY);
+		dec_memcg_page_state(page, NR_FILE_DIRTY);
 		dec_node_page_state(page, NR_FILE_DIRTY);
 		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
@@ -2706,7 +2706,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 */
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
-			mem_cgroup_dec_page_stat(page, NR_FILE_DIRTY);
+			dec_memcg_page_state(page, NR_FILE_DIRTY);
 			dec_node_page_state(page, NR_FILE_DIRTY);
 			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
@@ -2753,7 +2753,7 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
-		mem_cgroup_dec_page_stat(page, NR_WRITEBACK);
+		dec_memcg_page_state(page, NR_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK);
 		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		inc_node_page_state(page, NR_WRITTEN);
@@ -2808,7 +2808,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		ret = TestSetPageWriteback(page);
 	}
 	if (!ret) {
-		mem_cgroup_inc_page_stat(page, NR_WRITEBACK);
+		inc_memcg_page_state(page, NR_WRITEBACK);
 		inc_node_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index f6bbfcf01422..e116a8e80468 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1158,7 +1158,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 			goto out;
 	}
 	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, nr);
-	mem_cgroup_update_page_stat(page, NR_FILE_MAPPED, nr);
+	mod_memcg_page_state(page, NR_FILE_MAPPED, nr);
 out:
 	unlock_page_memcg(page);
 }
@@ -1198,7 +1198,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
 	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, -nr);
-	mem_cgroup_update_page_stat(page, NR_FILE_MAPPED, -nr);
+	mod_memcg_page_state(page, NR_FILE_MAPPED, -nr);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d77c97552ed3..eac4a9a73ba9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2046,7 +2046,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
 	if (memcg)
-		refaults = mem_cgroup_read_stat(memcg, WORKINGSET_ACTIVATE);
+		refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
 	else
 		refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
 
@@ -2740,8 +2740,7 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		struct lruvec *lruvec;
 
 		if (memcg)
-			refaults = mem_cgroup_read_stat(memcg,
-							WORKINGSET_ACTIVATE);
+			refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
 		else
 			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
 
diff --git a/mm/workingset.c b/mm/workingset.c
index 37fc1057cd86..b8c9ab678479 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -289,11 +289,11 @@ bool workingset_refault(void *shadow)
 	refault_distance = (refault - eviction) & EVICTION_MASK;
 
 	inc_node_state(pgdat, WORKINGSET_REFAULT);
-	mem_cgroup_inc_stat(memcg, WORKINGSET_REFAULT);
+	inc_memcg_state(memcg, WORKINGSET_REFAULT);
 
 	if (refault_distance <= active_file) {
 		inc_node_state(pgdat, WORKINGSET_ACTIVATE);
-		mem_cgroup_inc_stat(memcg, WORKINGSET_ACTIVATE);
+		inc_memcg_state(memcg, WORKINGSET_ACTIVATE);
 		rcu_read_unlock();
 		return true;
 	}
@@ -475,7 +475,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	if (WARN_ON_ONCE(node->exceptional))
 		goto out_invalid;
 	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
-	mem_cgroup_inc_page_stat(virt_to_page(node), WORKINGSET_NODERECLAIM);
+	inc_memcg_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->page_tree, node,
 				 workingset_update_node, mapping);
 
-- 
2.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
