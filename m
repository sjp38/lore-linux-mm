Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4019C8D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 16:38:43 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v5 7/9] memcg: add dirty limits to mem_cgroup
Date: Fri, 25 Feb 2011 13:35:58 -0800
Message-Id: <1298669760-26344-8-git-send-email-gthelen@google.com>
In-Reply-To: <1298669760-26344-1-git-send-email-gthelen@google.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Extend mem_cgroup to contain dirty page limits.  Also add routines
allowing the kernel to query the dirty usage of a memcg.

These interfaces not used by the kernel yet.  A subsequent commit
will add kernel calls to utilize these new routines.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
Changelog since v4:
- Added support for hierarchical dirty limits.
- Simplified __mem_cgroup_dirty_param().
- Simplified mem_cgroup_page_stat().
- Deleted mem_cgroup_nr_pages_item enum, which was added little value.
  Instead the mem_cgroup_page_stat_item enum values are used to identify
  memcg dirty statistics exported to kernel.
- Fixed overflow issues in mem_cgroup_hierarchical_free_pages().

Changelog since v3:
- Previously memcontrol.c used struct vm_dirty_param and vm_dirty_param() to
  advertise dirty memory limits.  Now struct dirty_info and
  mem_cgroup_dirty_info() is used to share dirty limits between memcontrol and
  the rest of the kernel.
- __mem_cgroup_has_dirty_limit() now returns false if use_hierarchy is set.
- memcg_hierarchical_free_pages() now uses parent_mem_cgroup() and is simpler.
- created internal routine, __mem_cgroup_has_dirty_limit(), to consolidate the
  logic.

Changelog since v1:
- Rename (for clarity):
  - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
  - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item
- Removed unnecessary get_ prefix from get_xxx() functions.
- Avoid lockdep warnings by using rcu_read_[un]lock() in
  mem_cgroup_has_dirty_limit().

 include/linux/memcontrol.h |   28 +++++
 mm/memcontrol.c            |  269 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 296 insertions(+), 1 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e1f70a9..8c00c06 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -19,6 +19,7 @@
 
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
+#include <linux/writeback.h>
 #include <linux/cgroup.h>
 struct mem_cgroup;
 struct page_cgroup;
@@ -31,6 +32,7 @@ enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
 	MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
 	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
+	MEMCG_NR_DIRTYABLE_PAGES, /* # of pages that could be dirty */
 };
 
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
@@ -145,6 +147,13 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
+bool mem_cgroup_has_dirty_limit(void);
+bool mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
+					struct mem_cgroup *memcg,
+					struct dirty_info *info);
+unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
+				   enum mem_cgroup_page_stat_item item);
+
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
@@ -333,6 +342,25 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 {
 }
 
+static inline bool mem_cgroup_has_dirty_limit(void)
+{
+	return false;
+}
+
+static inline bool
+mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
+				   struct mem_cgroup *memcg,
+				   struct dirty_info *info)
+{
+	return false;
+}
+
+static inline unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
+	enum mem_cgroup_page_stat_item item)
+{
+	return -ENOSYS;
+}
+
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 38f786b..bc86329 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -198,6 +198,14 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
+/* Dirty memory parameters */
+struct vm_dirty_param {
+	int dirty_ratio;
+	int dirty_background_ratio;
+	unsigned long dirty_bytes;
+	unsigned long dirty_background_bytes;
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -237,6 +245,10 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
+
+	/* control memory cgroup dirty pages */
+	struct vm_dirty_param dirty_param;
+
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
@@ -1128,6 +1140,254 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
 	return memcg->swappiness;
 }
 
+/*
+ * Return true if the current memory cgroup has local dirty memory settings.
+ * There is an allowed race between the current task migrating in-to/out-of the
+ * root cgroup while this routine runs.  So the return value may be incorrect if
+ * the current task is being simultaneously migrated.
+ */
+static bool __mem_cgroup_has_dirty_limit(struct mem_cgroup *mem)
+{
+	return mem && !mem_cgroup_is_root(mem);
+}
+
+bool mem_cgroup_has_dirty_limit(void)
+{
+	struct mem_cgroup *mem;
+	bool ret;
+
+	if (mem_cgroup_disabled())
+		return false;
+
+	rcu_read_lock();
+	mem = mem_cgroup_from_task(current);
+	ret = __mem_cgroup_has_dirty_limit(mem);
+	rcu_read_unlock();
+
+	return ret;
+}
+
+/*
+ * Returns a snapshot of the current dirty limits which is not synchronized with
+ * the routines that change the dirty limits.  If this routine races with an
+ * update to the dirty bytes/ratio value, then the caller must handle the case
+ * where neither dirty_[background_]_ratio nor _bytes are set.
+ */
+static void __mem_cgroup_dirty_param(struct vm_dirty_param *param,
+				     struct mem_cgroup *mem)
+{
+	if (__mem_cgroup_has_dirty_limit(mem)) {
+		*param = mem->dirty_param;
+	} else {
+		param->dirty_ratio = vm_dirty_ratio;
+		param->dirty_bytes = vm_dirty_bytes;
+		param->dirty_background_ratio = dirty_background_ratio;
+		param->dirty_background_bytes = dirty_background_bytes;
+	}
+}
+
+/* Return dirty thresholds and usage metrics for @memcg. */
+static void mem_cgroup_dirty_info(unsigned long sys_available_mem,
+				  struct mem_cgroup *memcg,
+				  struct dirty_info *info)
+{
+	unsigned long available_mem;
+	struct vm_dirty_param dirty_param;
+
+	__mem_cgroup_dirty_param(&dirty_param, memcg);
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
+ * Return the dirty thresholds and usage metrics for the memcg (within the
+ * ancestral chain of @memcg) closest to its limit.  If @memcg is not set, then
+ * use the current task's memcg.
+ *
+ * The current task may be moved to another cgroup while this routine accesses
+ * the dirty limit.  But a precise check is meaningless because the task can be
+ * moved after our access and writeback tends to take long time.  At least,
+ * "memcg" will not be freed while holding rcu_read_lock().
+ */
+bool mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
+					struct mem_cgroup *memcg,
+					struct dirty_info *info)
+{
+	unsigned long usage;
+	struct dirty_info uninitialized_var(cur_info);
+
+	if (mem_cgroup_disabled())
+		return false;
+
+	info->nr_writeback = ULONG_MAX;  /* invalid initial value */
+
+	/*
+	 * Routine within mem_cgroup_page_stat() need online cpus locked.
+	 * get_online_cpus() can sleep so it must be called before
+	 * rcu_read_lock().
+	 */
+	get_online_cpus();
+	rcu_read_lock();
+	if (!memcg)
+		memcg = mem_cgroup_from_task(current);
+
+	while (__mem_cgroup_has_dirty_limit(memcg)) {
+		mem_cgroup_dirty_info(sys_available_mem, memcg, &cur_info);
+		usage = dirty_info_reclaimable(&cur_info) +
+			cur_info.nr_writeback;
+
+		if (!memcg->use_hierarchy || usage >= cur_info.dirty_thresh) {
+			*info = cur_info;
+			break;
+		}
+
+		/* save dirty stats for memcg closest to its limit */
+		if ((info->nr_writeback == ULONG_MAX) ||
+		    (cur_info.dirty_thresh - usage <
+		     info->dirty_thresh - dirty_info_reclaimable(info) -
+		     info->nr_writeback))
+			*info = cur_info;
+
+		/* continue walking up hierarchy enabled parents */
+		memcg = parent_mem_cgroup(memcg);
+		if (!memcg || !memcg->use_hierarchy)
+			break;
+	}
+
+	rcu_read_unlock();
+	put_online_cpus();
+	return info->nr_writeback != ULONG_MAX;
+}
+
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
+unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
+				   enum mem_cgroup_page_stat_item item)
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
 static void mem_cgroup_start_move(struct mem_cgroup *mem)
 {
 	int cpu;
@@ -4578,8 +4838,15 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	INIT_LIST_HEAD(&mem->oom_notify);
 
-	if (parent)
+	if (parent) {
 		mem->swappiness = get_swappiness(parent);
+		__mem_cgroup_dirty_param(&mem->dirty_param, parent);
+	} else {
+		/*
+		 * The root cgroup dirty_param field is not used, instead,
+		 * system-wide dirty limits are used.
+		 */
+	}
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
