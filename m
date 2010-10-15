Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 51E2D5F0047
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:17:20 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 07/11] memcg: add dirty limits to mem_cgroup
Date: Fri, 15 Oct 2010 14:14:35 -0700
Message-Id: <1287177279-30876-8-git-send-email-gthelen@google.com>
In-Reply-To: <1287177279-30876-1-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Extend mem_cgroup to contain dirty page limits.  Also add routines
allowing the kernel to query the dirty usage of a memcg.

These interfaces not used by the kernel yet.  A subsequent commit
will add kernel calls to utilize these new routines.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
---
 include/linux/memcontrol.h |   44 ++++++++++
 mm/memcontrol.c            |  186 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 229 insertions(+), 1 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ef2eec7..6f3a136 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -19,6 +19,7 @@
 
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
+#include <linux/writeback.h>
 #include <linux/cgroup.h>
 struct mem_cgroup;
 struct page_cgroup;
@@ -33,6 +34,30 @@ enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
 };
 
+/* Cgroup memory statistics items exported to the kernel. */
+enum mem_cgroup_nr_pages_item {
+	MEMCG_NR_DIRTYABLE_PAGES,
+	MEMCG_NR_RECLAIM_PAGES,
+	MEMCG_NR_WRITEBACK,
+	MEMCG_NR_DIRTY_WRITEBACK_PAGES,
+};
+
+/* Dirty memory parameters */
+struct vm_dirty_param {
+	int dirty_ratio;
+	int dirty_background_ratio;
+	unsigned long dirty_bytes;
+	unsigned long dirty_background_bytes;
+};
+
+static inline void global_vm_dirty_param(struct vm_dirty_param *param)
+{
+	param->dirty_ratio = vm_dirty_ratio;
+	param->dirty_bytes = vm_dirty_bytes;
+	param->dirty_background_ratio = dirty_background_ratio;
+	param->dirty_background_bytes = dirty_background_bytes;
+}
+
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -145,6 +170,10 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
+bool mem_cgroup_has_dirty_limit(void);
+void vm_dirty_param(struct vm_dirty_param *param);
+s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
+
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
@@ -326,6 +355,21 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 {
 }
 
+static inline bool mem_cgroup_has_dirty_limit(void)
+{
+	return false;
+}
+
+static inline void vm_dirty_param(struct vm_dirty_param *param)
+{
+	global_vm_dirty_param(param);
+}
+
+static inline s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
+{
+	return -ENOSYS;
+}
+
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3884a85..eef25fe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -233,6 +233,10 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
+
+	/* control memory cgroup dirty pages */
+	struct vm_dirty_param dirty_param;
+
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
@@ -1149,6 +1153,178 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
 	return swappiness;
 }
 
+/*
+ * Returns a snapshot of the current dirty limits which is not synchronized with
+ * the routines that change the dirty limits.  If this routine races with an
+ * update to the dirty bytes/ratio value, then the caller must handle the case
+ * where both dirty_[background_]_ratio and _bytes are set.
+ */
+static void __mem_cgroup_dirty_param(struct vm_dirty_param *param,
+				     struct mem_cgroup *mem)
+{
+	if (mem && !mem_cgroup_is_root(mem)) {
+		param->dirty_ratio = mem->dirty_param.dirty_ratio;
+		param->dirty_bytes = mem->dirty_param.dirty_bytes;
+		param->dirty_background_ratio =
+			mem->dirty_param.dirty_background_ratio;
+		param->dirty_background_bytes =
+			mem->dirty_param.dirty_background_bytes;
+	} else {
+		global_vm_dirty_param(param);
+	}
+}
+
+/*
+ * Get dirty memory parameters of the current memcg or global values (if memory
+ * cgroups are disabled or querying the root cgroup).
+ *
+ * The current task may be moved to other cgroup while we access cgroup changing
+ * the task's dirty limit.  But a precise check is meaningless because the task
+ * can be moved after our access and writeback tends to take long time.  At
+ * least, "memcg" will not be freed while holding rcu_read_lock().
+ */
+void vm_dirty_param(struct vm_dirty_param *param)
+{
+	struct mem_cgroup *memcg;
+
+	if (mem_cgroup_disabled()) {
+		global_vm_dirty_param(param);
+		return;
+	}
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	__mem_cgroup_dirty_param(param, memcg);
+	rcu_read_unlock();
+}
+
+/*
+ * Return true if the current memory cgroup has local dirty memory settings.
+ * There is an allowed race between the current task migrating in-to/out-of the
+ * root cgroup while this routine runs.  So the return value may be incorrect if
+ * the current task is being simultaneously migrated.
+ */
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
+	ret = mem && !mem_cgroup_is_root(mem);
+	rcu_read_unlock();
+
+	return ret;
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
+				      enum mem_cgroup_nr_pages_item item)
+{
+	s64 ret;
+
+	switch (item) {
+	case MEMCG_NR_DIRTYABLE_PAGES:
+		ret = mem_cgroup_read_stat(mem, LRU_ACTIVE_FILE) +
+			mem_cgroup_read_stat(mem, LRU_INACTIVE_FILE);
+		if (mem_cgroup_can_swap(mem))
+			ret += mem_cgroup_read_stat(mem, LRU_ACTIVE_ANON) +
+				mem_cgroup_read_stat(mem, LRU_INACTIVE_ANON);
+		break;
+	case MEMCG_NR_RECLAIM_PAGES:
+		ret = mem_cgroup_read_stat(mem,	MEM_CGROUP_STAT_FILE_DIRTY) +
+			mem_cgroup_read_stat(mem,
+					     MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
+		break;
+	case MEMCG_NR_WRITEBACK:
+		ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_WRITEBACK);
+		break;
+	case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
+		ret = mem_cgroup_read_stat(mem,
+					   MEM_CGROUP_STAT_FILE_WRITEBACK) +
+			mem_cgroup_read_stat(mem,
+					     MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return ret;
+}
+
+static unsigned long long
+memcg_hierarchical_free_pages(struct mem_cgroup *mem)
+{
+	struct cgroup *cgroup;
+	unsigned long long min_free, free;
+
+	min_free = res_counter_read_u64(&mem->res, RES_LIMIT) -
+		res_counter_read_u64(&mem->res, RES_USAGE);
+	cgroup = mem->css.cgroup;
+	if (!mem->use_hierarchy)
+		goto out;
+
+	while (cgroup->parent) {
+		cgroup = cgroup->parent;
+		mem = mem_cgroup_from_cont(cgroup);
+		if (!mem->use_hierarchy)
+			break;
+		free = res_counter_read_u64(&mem->res, RES_LIMIT) -
+			res_counter_read_u64(&mem->res, RES_USAGE);
+		min_free = min(min_free, free);
+	}
+out:
+	/* Translate free memory in pages */
+	return min_free >> PAGE_SHIFT;
+}
+
+/*
+ * mem_cgroup_page_stat() - get memory cgroup file cache statistics
+ * @item:      memory statistic item exported to the kernel
+ *
+ * Return the accounted statistic value.
+ */
+s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
+{
+	struct mem_cgroup *mem;
+	struct mem_cgroup *iter;
+	s64 value;
+
+	rcu_read_lock();
+	mem = mem_cgroup_from_task(current);
+	if (mem && !mem_cgroup_is_root(mem)) {
+		/*
+		 * If we're looking for dirtyable pages we need to evaluate
+		 * free pages depending on the limit and usage of the parents
+		 * first of all.
+		 */
+		if (item == MEMCG_NR_DIRTYABLE_PAGES)
+			value = memcg_hierarchical_free_pages(mem);
+		else
+			value = 0;
+		/*
+		 * Recursively evaluate page statistics against all cgroup
+		 * under hierarchy tree
+		 */
+		for_each_mem_cgroup_tree(iter, mem)
+			value += mem_cgroup_local_page_stat(iter, item);
+	} else
+		value = -EINVAL;
+	rcu_read_unlock();
+
+	return value;
+}
+
 static void mem_cgroup_start_move(struct mem_cgroup *mem)
 {
 	int cpu;
@@ -4452,8 +4628,16 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	spin_lock_init(&mem->reclaim_param_lock);
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
+
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
