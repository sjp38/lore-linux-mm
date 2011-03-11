Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D14218D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:45:47 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v6 7/9] memcg: add dirty limiting routines
Date: Fri, 11 Mar 2011 10:43:29 -0800
Message-Id: <1299869011-26152-8-git-send-email-gthelen@google.com>
In-Reply-To: <1299869011-26152-1-git-send-email-gthelen@google.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>

Add new memcg routines for use by mm to balance and throttle per-memcg
dirty page usage:
- mem_cgroup_balance_dirty_pages() balances memcg dirty memory usage by
  checking memcg foreground and background limits.
- mem_cgroup_hierarchical_dirty_info() searches a memcg hierarchy to
  find the memcg that is closest to (or over) its foreground or
  background dirty limit.

A later change adds kernel calls to these new routines.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h |   35 +++++
 mm/memcontrol.c            |  329 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 364 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 549fa7c..42f5f63 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -34,6 +34,15 @@ enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
 	MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
 	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
+	MEMCG_NR_DIRTYABLE_PAGES, /* # of pages that could be dirty */
+};
+
+struct dirty_info {
+	unsigned long dirty_thresh;
+	unsigned long background_thresh;
+	unsigned long nr_file_dirty;
+	unsigned long nr_writeback;
+	unsigned long nr_unstable_nfs;
 };
 
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
@@ -149,6 +158,14 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
+bool mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
+					bool fg_limit,
+					struct mem_cgroup *memcg,
+					struct dirty_info *info);
+void mem_cgroup_bg_writeback_done(struct mem_cgroup *memcg);
+void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
+				    unsigned long write_chunk);
+
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
@@ -342,6 +359,24 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 {
 }
 
+static inline bool
+mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
+				   bool fg_limit,
+				   struct mem_cgroup *memcg,
+				   struct dirty_info *info)
+{
+	return false;
+}
+
+static inline void mem_cgroup_bg_writeback_done(struct mem_cgroup *memcg)
+{
+}
+
+static inline void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
+						  unsigned long write_chunk)
+{
+}
+
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 07cbb35..25dc077 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -218,6 +218,12 @@ struct vm_dirty_param {
 	unsigned long dirty_background_bytes;
 };
 
+/* Define per-memcg flags */
+enum mem_cgroup_flags {
+	/* is background writeback in-progress for this memcg? */
+	MEM_CGROUP_BG_WRITEBACK,
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -261,6 +267,9 @@ struct mem_cgroup {
 	/* control memory cgroup dirty pages */
 	struct vm_dirty_param dirty_param;
 
+	/* see enum mem_cgroup_flags for bit definitions */
+	unsigned long	flags;
+
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
@@ -1217,6 +1226,11 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
 	return memcg->swappiness;
 }
 
+static unsigned long dirty_info_reclaimable(struct dirty_info *info)
+{
+	return info->nr_file_dirty + info->nr_unstable_nfs;
+}
+
 /*
  * Return true if the current memory cgroup has local dirty memory settings.
  * There is an allowed race between the current task migrating in-to/out-of the
@@ -1247,6 +1261,321 @@ static void mem_cgroup_dirty_param(struct vm_dirty_param *param,
 	}
 }
 
+static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
+{
+	if (!do_swap_account)
+		return nr_swap_pages > 0;
+	return !memcg->memsw_is_minimum &&
+		(res_counter_read_u64(&memcg->memsw, RES_LIMIT) > 0);
+}
+
+static s64 mem_cgroup_local_page_stat(struct mem_cgroup *mem,
+				      enum mem_cgroup_page_stat_item item)
+{
+	s64 ret;
+
+	switch (item) {
+	case MEMCG_NR_FILE_DIRTY:
+		ret = mem_cgroup_read_stat(mem,	MEM_CGROUP_STAT_FILE_DIRTY);
+		break;
+	case MEMCG_NR_FILE_WRITEBACK:
+		ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_WRITEBACK);
+		break;
+	case MEMCG_NR_FILE_UNSTABLE_NFS:
+		ret = mem_cgroup_read_stat(mem,
+					   MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
+		break;
+	case MEMCG_NR_DIRTYABLE_PAGES:
+		ret = mem_cgroup_read_stat(mem, LRU_ACTIVE_FILE) +
+			mem_cgroup_read_stat(mem, LRU_INACTIVE_FILE);
+		if (mem_cgroup_can_swap(mem))
+			ret += mem_cgroup_read_stat(mem, LRU_ACTIVE_ANON) +
+				mem_cgroup_read_stat(mem, LRU_INACTIVE_ANON);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return ret;
+}
+
+/*
+ * Return the number of additional pages that the @mem cgroup could allocate.
+ * If use_hierarchy is set, then this involves checking parent mem cgroups to
+ * find the cgroup with the smallest free space.
+ */
+static unsigned long
+mem_cgroup_hierarchical_free_pages(struct mem_cgroup *mem)
+{
+	u64 free;
+	unsigned long min_free;
+
+	min_free = global_page_state(NR_FREE_PAGES);
+
+	while (mem) {
+		free = (res_counter_read_u64(&mem->res, RES_LIMIT) -
+			res_counter_read_u64(&mem->res, RES_USAGE)) >>
+			PAGE_SHIFT;
+		min_free = min((u64)min_free, free);
+		mem = parent_mem_cgroup(mem);
+	}
+
+	return min_free;
+}
+
+/*
+ * mem_cgroup_page_stat() - get memory cgroup file cache statistics
+ * @mem:       memory cgroup to query
+ * @item:      memory statistic item exported to the kernel
+ *
+ * Return the accounted statistic value.
+ */
+static unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
+					  enum mem_cgroup_page_stat_item item)
+{
+	struct mem_cgroup *iter;
+	s64 value;
+
+	VM_BUG_ON(!mem);
+	VM_BUG_ON(mem_cgroup_is_root(mem));
+
+	/*
+	 * If we're looking for dirtyable pages we need to evaluate free pages
+	 * depending on the limit and usage of the parents first of all.
+	 */
+	if (item == MEMCG_NR_DIRTYABLE_PAGES)
+		value = mem_cgroup_hierarchical_free_pages(mem);
+	else
+		value = 0;
+
+	/*
+	 * Recursively evaluate page statistics against all cgroup under
+	 * hierarchy tree
+	 */
+	for_each_mem_cgroup_tree(iter, mem)
+		value += mem_cgroup_local_page_stat(iter, item);
+
+	/*
+	 * Summing of unlocked per-cpu counters is racy and may yield a slightly
+	 * negative value.  Zero is the only sensible value in such cases.
+	 */
+	if (unlikely(value < 0))
+		value = 0;
+
+	return value;
+}
+
+/* Return dirty thresholds and usage for @memcg. */
+static void mem_cgroup_dirty_info(unsigned long sys_available_mem,
+				  struct mem_cgroup *memcg,
+				  struct dirty_info *info)
+{
+	unsigned long uninitialized_var(available_mem);
+	struct vm_dirty_param dirty_param;
+
+	mem_cgroup_dirty_param(&dirty_param, memcg);
+
+	if (!dirty_param.dirty_bytes || !dirty_param.dirty_background_bytes)
+		available_mem = min(
+			sys_available_mem,
+			mem_cgroup_page_stat(memcg, MEMCG_NR_DIRTYABLE_PAGES));
+
+	if (dirty_param.dirty_bytes)
+		info->dirty_thresh =
+			DIV_ROUND_UP(dirty_param.dirty_bytes, PAGE_SIZE);
+	else
+		info->dirty_thresh =
+			(dirty_param.dirty_ratio * available_mem) / 100;
+
+	if (dirty_param.dirty_background_bytes)
+		info->background_thresh =
+			DIV_ROUND_UP(dirty_param.dirty_background_bytes,
+				     PAGE_SIZE);
+	else
+		info->background_thresh =
+			(dirty_param.dirty_background_ratio *
+			       available_mem) / 100;
+
+	info->nr_file_dirty = mem_cgroup_page_stat(memcg, MEMCG_NR_FILE_DIRTY);
+	info->nr_writeback = mem_cgroup_page_stat(memcg,
+						  MEMCG_NR_FILE_WRITEBACK);
+	info->nr_unstable_nfs =
+		mem_cgroup_page_stat(memcg, MEMCG_NR_FILE_UNSTABLE_NFS);
+}
+
+/*
+ * Releases memcg reference.  Called when per-memcg background writeback
+ * completes.
+ */
+void mem_cgroup_bg_writeback_done(struct mem_cgroup *memcg)
+{
+	VM_BUG_ON(!test_bit(MEM_CGROUP_BG_WRITEBACK, &memcg->flags));
+	clear_bit(MEM_CGROUP_BG_WRITEBACK, &memcg->flags);
+	css_put(&memcg->css);
+}
+
+/*
+ * This routine must be called by processes which are generating dirty pages.
+ * It considers the dirty pages usage and thresholds of the current cgroup and
+ * (depending if hierarchical accounting is enabled) ancestral memcg.  If any of
+ * the considered memcg are over their background dirty limit, then background
+ * writeback is queued.  If any are over the foreground dirty limit then
+ * throttle the dirtying task while writing dirty data.  The per-memcg dirty
+ * limits check by this routine are distinct from either the per-system,
+ * per-bdi, or per-task limits considered by balance_dirty_pages().
+ */
+void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
+				    unsigned long write_chunk)
+{
+	unsigned long nr_reclaimable;
+	unsigned long sys_available_mem;
+	struct mem_cgroup *memcg;
+	struct mem_cgroup *ref_memcg;
+	struct dirty_info info;
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	unsigned long pause = 1;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	sys_available_mem = determine_dirtyable_memory();
+
+	/* reference the memcg so it is not deleted during this routine */
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	ref_memcg = memcg;
+	if (memcg)
+		css_get(&ref_memcg->css);
+	rcu_read_unlock();
+
+	/* balance entire ancestry of current's memcg. */
+	while (mem_cgroup_has_dirty_limit(memcg)) {
+		/*
+		 * keep throttling and writing inode data so long as memcg is
+		 * over its dirty limit.
+		 */
+		while (true) {
+			struct writeback_control wbc = {
+				.sync_mode	= WB_SYNC_NONE,
+				.older_than_this = NULL,
+				.nr_to_write	= write_chunk,
+				.range_cyclic	= 1,
+			};
+
+			mem_cgroup_dirty_info(sys_available_mem, memcg, &info);
+			nr_reclaimable = dirty_info_reclaimable(&info);
+
+			/* if memcg is over dirty limit, then throttle. */
+			if (nr_reclaimable >= info.dirty_thresh) {
+				writeback_inodes_wb(&bdi->wb, &wbc);
+				/*
+				 * Sleep up to 100ms to throttle writer and wait
+				 * for queued background I/O to complete.
+				 */
+				__set_current_state(TASK_UNINTERRUPTIBLE);
+				io_schedule_timeout(pause);
+				pause <<= 1;
+				if (pause > HZ / 10)
+					pause = HZ / 10;
+			} else
+				break;
+		}
+
+		/* if memcg is over background limit, then queue bg writeback */
+		if ((nr_reclaimable >= info.background_thresh) &&
+		    !test_and_set_bit(MEM_CGROUP_BG_WRITEBACK, &memcg->flags)) {
+			/*
+			 * grab css reference that will be released by
+			 * mem_cgroup_bg_writeback_done().
+			 */
+			css_get(&memcg->css);
+			bdi_start_background_writeback(bdi);
+		}
+
+		/* continue walking up hierarchy enabled parents */
+		memcg = parent_mem_cgroup(memcg);
+		if (!memcg || !memcg->use_hierarchy)
+			break;
+	}
+
+	if (ref_memcg)
+		css_put(&ref_memcg->css);
+}
+
+/*
+ * Return the dirty thresholds and usage for the memcg (within the ancestral
+ * chain of @memcg) closest to its limit or the first memcg over its limit.
+ * If @fg_limit is set, then check the dirty_limit, otherwise check
+ * background_limit.  If @memcg is not set, then use the current task's memcg.
+ *
+ * The current task may be moved to another cgroup while this routine accesses
+ * the dirty limit.  But a precise check is meaningless because the task can be
+ * moved after our access and writeback tends to take long time.  At least,
+ * "memcg" will not be freed while holding rcu_read_lock().
+ */
+bool mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
+					bool fg_limit,
+					struct mem_cgroup *memcg,
+					struct dirty_info *info)
+{
+	unsigned long usage;
+	struct dirty_info uninitialized_var(cur_info);
+	struct mem_cgroup *ref_memcg = NULL;
+
+	if (mem_cgroup_disabled())
+		return false;
+
+	info->nr_writeback = ULONG_MAX;  /* invalid initial value */
+
+	/* reference current's memcg unless a memcg was provided by caller */
+	if (!memcg) {
+		rcu_read_lock();
+		memcg = mem_cgroup_from_task(current);
+		if (memcg)
+			css_get(&memcg->css);
+		ref_memcg = memcg;
+		rcu_read_unlock();
+	}
+
+	while (mem_cgroup_has_dirty_limit(memcg)) {
+		mem_cgroup_dirty_info(sys_available_mem, memcg, &cur_info);
+		usage = dirty_info_reclaimable(&cur_info) +
+			cur_info.nr_writeback;
+
+		/* if over limit, stop searching */
+		if (usage >= (fg_limit ? cur_info.dirty_thresh :
+			      cur_info.background_thresh)) {
+			*info = cur_info;
+			break;
+		}
+
+		/*
+		 * Save dirty usage of memcg closest to its limit if either:
+		 *     - memcg is the first memcg considered
+		 *     - memcg dirty margin is smaller than last recorded one
+		 */
+		/* cur_memcg_margin <  */
+		if ((info->nr_writeback == ULONG_MAX) ||
+		    ((fg_limit ? cur_info.dirty_thresh :
+		      cur_info.background_thresh) - usage <
+		     (fg_limit ? info->dirty_thresh :
+		      info->background_thresh) -
+		     (dirty_info_reclaimable(info) + info->nr_writeback)))
+
+			*info = cur_info;
+
+		/* continue walking up hierarchy enabled parents */
+		memcg = parent_mem_cgroup(memcg);
+		if (!memcg || !memcg->use_hierarchy)
+			break;
+	}
+
+	if (ref_memcg)
+		css_put(&ref_memcg->css);
+
+	return info->nr_writeback != ULONG_MAX;
+}
+
 static void mem_cgroup_start_move(struct mem_cgroup *mem)
 {
 	int cpu;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
