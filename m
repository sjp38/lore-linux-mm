Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0F5556B018D
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 19:27:04 -0400 (EDT)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH -mmotm 4/5] memcg: dirty pages accounting and limiting infrastructure
Date: Mon, 15 Mar 2010 00:26:41 +0100
Message-Id: <1268609202-15581-5-git-send-email-arighi@develer.com>
In-Reply-To: <1268609202-15581-1-git-send-email-arighi@develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Righi <arighi@develer.com>
List-ID: <linux-mm.kvack.org>

Infrastructure to account dirty pages per cgroup and add dirty limit
interfaces in the cgroupfs:

 - Direct write-out: memory.dirty_ratio, memory.dirty_bytes

 - Background write-out: memory.dirty_background_ratio, memory.dirty_background_bytes

Signed-off-by: Andrea Righi <arighi@develer.com>
---
 include/linux/memcontrol.h |   92 ++++++++-
 mm/memcontrol.c            |  484 +++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 540 insertions(+), 36 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 88d3f9e..0602ec9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -19,12 +19,55 @@
 
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
+
+#include <linux/writeback.h>
 #include <linux/cgroup.h>
+
 struct mem_cgroup;
 struct page_cgroup;
 struct page;
 struct mm_struct;
 
+/* Cgroup memory statistics items exported to the kernel */
+enum mem_cgroup_read_page_stat_item {
+	MEMCG_NR_DIRTYABLE_PAGES,
+	MEMCG_NR_RECLAIM_PAGES,
+	MEMCG_NR_WRITEBACK,
+	MEMCG_NR_DIRTY_WRITEBACK_PAGES,
+};
+
+/* File cache pages accounting */
+enum mem_cgroup_write_page_stat_item {
+	MEMCG_NR_FILE_MAPPED,		/* # of pages charged as file rss */
+	MEMCG_NR_FILE_DIRTY,		/* # of dirty pages in page cache */
+	MEMCG_NR_FILE_WRITEBACK,	/* # of pages under writeback */
+	MEMCG_NR_FILE_WRITEBACK_TEMP,	/* # of pages under writeback using
+					   temporary buffers */
+	MEMCG_NR_FILE_UNSTABLE_NFS,	/* # of NFS unstable pages */
+
+	MEMCG_NR_FILE_NSTAT,
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
+/*
+ * TODO: provide a validation check routine. And retry if validation
+ * fails.
+ */
+static inline void get_global_vm_dirty_param(struct vm_dirty_param *param)
+{
+	param->dirty_ratio = vm_dirty_ratio;
+	param->dirty_bytes = vm_dirty_bytes;
+	param->dirty_background_ratio = dirty_background_ratio;
+	param->dirty_background_bytes = dirty_background_bytes;
+}
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -117,6 +160,25 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 extern int do_swap_account;
 #endif
 
+extern bool mem_cgroup_has_dirty_limit(void);
+extern void get_vm_dirty_param(struct vm_dirty_param *param);
+extern s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item);
+
+extern void mem_cgroup_update_page_stat(struct page *page,
+			enum mem_cgroup_write_page_stat_item idx, bool charge);
+
+static inline void mem_cgroup_inc_page_stat(struct page *page,
+		enum mem_cgroup_write_page_stat_item idx)
+{
+	mem_cgroup_update_page_stat(page, idx, true);
+}
+
+static inline void mem_cgroup_dec_page_stat(struct page *page,
+		enum mem_cgroup_write_page_stat_item idx)
+{
+	mem_cgroup_update_page_stat(page, idx, false);
+}
+
 static inline bool mem_cgroup_disabled(void)
 {
 	if (mem_cgroup_subsys.disabled)
@@ -124,12 +186,6 @@ static inline bool mem_cgroup_disabled(void)
 	return false;
 }
 
-enum mem_cgroup_page_stat_item {
-	MEMCG_NR_FILE_MAPPED,
-	MEMCG_NR_FILE_NSTAT,
-};
-
-void mem_cgroup_update_stat(struct page *page, int idx, bool charge);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
 						int zid);
@@ -299,8 +355,18 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
-static inline void mem_cgroup_update_file_mapped(struct page *page,
-							int val)
+static inline s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item)
+{
+	return -ENOSYS;
+}
+
+static inline void mem_cgroup_inc_page_stat(struct page *page,
+			enum mem_cgroup_write_page_stat_item idx)
+{
+}
+
+static inline void mem_cgroup_dec_page_stat(struct page *page,
+			enum mem_cgroup_write_page_stat_item idx)
 {
 }
 
@@ -311,6 +377,16 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	return 0;
 }
 
+static inline bool mem_cgroup_has_dirty_limit(void)
+{
+	return false;
+}
+
+static inline void get_vm_dirty_param(struct vm_dirty_param *param)
+{
+	get_global_vm_dirty_param(param);
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b7c23ea..91770d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -80,14 +80,21 @@ enum mem_cgroup_stat_index {
 	/*
 	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
 	 */
-	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
+	MEM_CGROUP_STAT_CACHE,	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
 
+	/* File cache pages accounting */
+	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
+	MEM_CGROUP_STAT_FILE_DIRTY,   /* # of dirty pages in page cache */
+	MEM_CGROUP_STAT_WRITEBACK,   /* # of pages under writeback */
+	MEM_CGROUP_STAT_WRITEBACK_TEMP,   /* # of pages under writeback using
+						temporary buffers */
+	MEM_CGROUP_STAT_UNSTABLE_NFS,   /* # of NFS unstable pages */
+
 	MEM_CGROUP_STAT_NSTATS,
 };
 
@@ -95,6 +102,19 @@ struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
 };
 
+/* Per cgroup page statistics */
+struct mem_cgroup_page_stat {
+	enum mem_cgroup_read_page_stat_item item;
+	s64 value;
+};
+
+enum {
+	MEM_CGROUP_DIRTY_RATIO,
+	MEM_CGROUP_DIRTY_BYTES,
+	MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
+	MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
+};
+
 /*
  * per-zone information in memory controller.
  */
@@ -208,6 +228,9 @@ struct mem_cgroup {
 
 	unsigned int	swappiness;
 
+	/* control memory cgroup dirty pages */
+	struct vm_dirty_param dirty_param;
+
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
@@ -1033,6 +1056,189 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
 	return swappiness;
 }
 
+static bool dirty_param_is_valid(struct vm_dirty_param *param)
+{
+	if (param->dirty_ratio && param->dirty_bytes)
+		return false;
+	if (param->dirty_background_ratio && param->dirty_background_bytes)
+		return false;
+	return true;
+}
+
+static void __mem_cgroup_get_dirty_param(struct vm_dirty_param *param,
+				struct mem_cgroup *mem)
+{
+	param->dirty_ratio = mem->dirty_param.dirty_ratio;
+	param->dirty_bytes = mem->dirty_param.dirty_bytes;
+	param->dirty_background_ratio = mem->dirty_param.dirty_background_ratio;
+	param->dirty_background_bytes = mem->dirty_param.dirty_background_bytes;
+}
+
+/*
+ * get_vm_dirty_param() - get dirty memory parameters of the current memcg
+ * @param:	a structure that is filled with the dirty memory settings
+ *
+ * The function fills @param with the current memcg dirty memory settings. If
+ * memory cgroup is disabled or in case of error the structure is filled with
+ * the global dirty memory settings.
+ */
+void get_vm_dirty_param(struct vm_dirty_param *param)
+{
+	struct mem_cgroup *memcg;
+
+	if (mem_cgroup_disabled()) {
+		get_global_vm_dirty_param(param);
+		return;
+	}
+	/*
+	 * It's possible that "current" may be moved to other cgroup while we
+	 * access cgroup. But precise check is meaningless because the task can
+	 * be moved after our access and writeback tends to take long time.
+	 * At least, "memcg" will not be freed under rcu_read_lock().
+	 */
+	while (1) {
+		rcu_read_lock();
+		memcg = mem_cgroup_from_task(current);
+		if (likely(memcg))
+			__mem_cgroup_get_dirty_param(param, memcg);
+		else
+			get_global_vm_dirty_param(param);
+		rcu_read_unlock();
+		/*
+		 * Since global and memcg vm_dirty_param are not protected we
+		 * try to speculatively read them and retry if we get
+		 * inconsistent values.
+		 */
+		if (likely(dirty_param_is_valid(param)))
+			break;
+	}
+}
+
+/*
+ * mem_cgroup_has_dirty_limit() - check if current memcg has local dirty limits
+ *
+ * Return true if the current memory cgroup has local dirty memory settings,
+ * false otherwise.
+ */
+bool mem_cgroup_has_dirty_limit(void)
+{
+	struct mem_cgroup *mem;
+
+	if (mem_cgroup_disabled())
+		return false;
+	mem = mem_cgroup_from_task(current);
+	return mem && !mem_cgroup_is_root(mem);
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
+static s64 mem_cgroup_get_local_page_stat(struct mem_cgroup *memcg,
+				enum mem_cgroup_read_page_stat_item item)
+{
+	s64 ret;
+
+	switch (item) {
+	case MEMCG_NR_DIRTYABLE_PAGES:
+		ret = mem_cgroup_read_stat(memcg, LRU_ACTIVE_FILE) +
+			mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
+		if (mem_cgroup_can_swap(memcg))
+			ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_ANON) +
+				mem_cgroup_read_stat(memcg, LRU_INACTIVE_ANON);
+		break;
+	case MEMCG_NR_RECLAIM_PAGES:
+		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY) +
+			mem_cgroup_read_stat(memcg,
+					MEM_CGROUP_STAT_UNSTABLE_NFS);
+		break;
+	case MEMCG_NR_WRITEBACK:
+		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
+		break;
+	case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
+		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) +
+			mem_cgroup_read_stat(memcg,
+				MEM_CGROUP_STAT_UNSTABLE_NFS);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return ret;
+}
+
+static int mem_cgroup_page_stat_cb(struct mem_cgroup *mem, void *data)
+{
+	struct mem_cgroup_page_stat *stat = (struct mem_cgroup_page_stat *)data;
+
+	stat->value += mem_cgroup_get_local_page_stat(mem, stat->item);
+	return 0;
+}
+
+static unsigned long long
+memcg_get_hierarchical_free_pages(struct mem_cgroup *mem)
+{
+	struct cgroup *cgroup;
+	unsigned long long min_free, free;
+
+	min_free = res_counter_read_u64(&mem->res, RES_LIMIT) -
+			res_counter_read_u64(&mem->res, RES_USAGE);
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
+ * @item:	memory statistic item exported to the kernel
+ *
+ * Return the accounted statistic value, or a negative value in case of error.
+ */
+s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item)
+{
+	struct mem_cgroup_page_stat stat = {};
+	struct mem_cgroup *mem;
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
+			stat.value = memcg_get_hierarchical_free_pages(mem);
+		/*
+		 * Recursively evaluate page statistics against all cgroup
+		 * under hierarchy tree
+		 */
+		stat.item = item;
+		mem_cgroup_walk_tree(mem, &stat, mem_cgroup_page_stat_cb);
+	} else
+		stat.value = -EINVAL;
+	rcu_read_unlock();
+
+	return stat.value;
+}
+
 static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
 {
 	int *val = data;
@@ -1344,24 +1550,16 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 	return true;
 }
 
-/*
- * Currently used to update mapped file statistics, but the routine can be
- * generalized to update other statistics as well.
- */
-void __mem_cgroup_update_stat(struct page_cgroup *pc, int idx, bool charge)
+static void __mem_cgroup_update_page_stat(struct page_cgroup *pc,
+				int idx, bool charge)
 {
 	struct mem_cgroup *mem;
-	int val;
+	int val = charge ? 1 : -1;
 
 	mem = pc->mem_cgroup;
 	if (!mem || !PageCgroupUsed(pc))
 		return;
 
-	if (charge)
-		val = 1;
-	else
-		val = -1;
-
 	switch (idx) {
 	case MEMCG_NR_FILE_MAPPED:
 		if (charge) {
@@ -1377,6 +1575,62 @@ void __mem_cgroup_update_stat(struct page_cgroup *pc, int idx, bool charge)
 		}
 		idx = MEM_CGROUP_STAT_FILE_MAPPED;
 		break;
+	case MEMCG_NR_FILE_DIRTY:
+		if (charge) {
+			if (!PageCgroupFileDirty(pc))
+				SetPageCgroupFileDirty(pc);
+			else
+				val = 0;
+		} else {
+			if (PageCgroupFileDirty(pc))
+				ClearPageCgroupFileDirty(pc);
+			else
+				val = 0;
+		}
+		idx = MEM_CGROUP_STAT_FILE_DIRTY;
+		break;
+	case MEMCG_NR_FILE_WRITEBACK:
+		if (charge) {
+			if (!PageCgroupFileWriteback(pc))
+				SetPageCgroupFileWriteback(pc);
+			else
+				val = 0;
+		} else {
+			if (PageCgroupFileWriteback(pc))
+				ClearPageCgroupFileWriteback(pc);
+			else
+				val = 0;
+		}
+		idx = MEM_CGROUP_STAT_WRITEBACK;
+		break;
+	case MEMCG_NR_FILE_WRITEBACK_TEMP:
+		if (charge) {
+			if (!PageCgroupFileWritebackTemp(pc))
+				SetPageCgroupFileWritebackTemp(pc);
+			else
+				val = 0;
+		} else {
+			if (PageCgroupFileWritebackTemp(pc))
+				ClearPageCgroupFileWritebackTemp(pc);
+			else
+				val = 0;
+		}
+		idx = MEM_CGROUP_STAT_WRITEBACK_TEMP;
+		break;
+	case MEMCG_NR_FILE_UNSTABLE_NFS:
+		if (charge) {
+			if (!PageCgroupFileUnstableNFS(pc))
+				SetPageCgroupFileUnstableNFS(pc);
+			else
+				val = 0;
+		} else {
+			if (PageCgroupFileUnstableNFS(pc))
+				ClearPageCgroupFileUnstableNFS(pc);
+			else
+				val = 0;
+		}
+		idx = MEM_CGROUP_STAT_UNSTABLE_NFS;
+		break;
 	default:
 		BUG();
 		break;
@@ -1384,34 +1638,81 @@ void __mem_cgroup_update_stat(struct page_cgroup *pc, int idx, bool charge)
 	/*
 	 * Preemption is already disabled. We can use __this_cpu_xxx
 	 */
-	__this_cpu_add(mem->stat->count[idx], val);
+	if (val)
+		__this_cpu_add(mem->stat->count[idx], val);
 }
 
-void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
+/*
+ * mem_cgroup_update_page_stat() - update memcg file cache's accounting
+ * @page:	the page involved in a file cache operation.
+ * @idx:	the particular file cache statistic.
+ * @charge:	true to increment, false to decrement the statistic specified
+ *		by @idx.
+ *
+ * Update memory cgroup file cache's accounting.
+ */
+void mem_cgroup_update_page_stat(struct page *page,
+			enum mem_cgroup_write_page_stat_item idx, bool charge)
 {
 	struct page_cgroup *pc;
 
+	if (mem_cgroup_disabled())
+		return;
 	pc = lookup_page_cgroup(page);
 	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
 		return;
 
 	if (trylock_page_cgroup(pc)) {
-		__mem_cgroup_update_stat(pc, idx, charge);
+		__mem_cgroup_update_page_stat(pc, idx, charge);
 		unlock_page_cgroup(pc);
 	}
-	return;
 }
+EXPORT_SYMBOL_GPL(mem_cgroup_update_page_stat);
 
-static void mem_cgroup_migrate_stat(struct page_cgroup *pc,
+/* Update file cache accounted statistics on task migration. */
+static void mem_cgroup_migrate_file_stat(struct page_cgroup *pc,
 	struct mem_cgroup *from, struct mem_cgroup *to)
 {
 	if (PageCgroupFileMapped(pc)) {
 		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		if (!mem_cgroup_is_root(to)) {
-			__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		} else {
+		if (!mem_cgroup_is_root(to))
+			__this_cpu_inc(
+				to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		else
 			ClearPageCgroupFileMapped(pc);
-		}
+	}
+	if (PageCgroupFileDirty(pc)) {
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_DIRTY]);
+		if (!mem_cgroup_is_root(to))
+			__this_cpu_inc(
+				to->stat->count[MEM_CGROUP_STAT_FILE_DIRTY]);
+		else
+			ClearPageCgroupFileDirty(pc);
+	}
+	if (PageCgroupFileWriteback(pc)) {
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WRITEBACK]);
+		if (!mem_cgroup_is_root(to))
+			__this_cpu_inc(
+				to->stat->count[MEM_CGROUP_STAT_WRITEBACK]);
+		else
+			ClearPageCgroupFileWriteback(pc);
+	}
+	if (PageCgroupFileWritebackTemp(pc)) {
+		__this_cpu_dec(
+			from->stat->count[MEM_CGROUP_STAT_WRITEBACK_TEMP]);
+		if (!mem_cgroup_is_root(to))
+			__this_cpu_inc(to->stat->count[
+					MEM_CGROUP_STAT_WRITEBACK_TEMP]);
+		else
+			ClearPageCgroupFileWritebackTemp(pc);
+	}
+	if (PageCgroupFileUnstableNFS(pc)) {
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
+		if (!mem_cgroup_is_root(to))
+			__this_cpu_inc(
+				to->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
+		else
+			ClearPageCgroupFileUnstableNFS(pc);
 	}
 }
 
@@ -1425,6 +1726,23 @@ __mem_cgroup_stat_fixup(struct page_cgroup *pc, struct mem_cgroup *mem)
 		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		ClearPageCgroupFileMapped(pc);
 	}
+	if (PageCgroupFileDirty(pc)) {
+		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_DIRTY]);
+		ClearPageCgroupFileDirty(pc);
+	}
+	if (PageCgroupFileWriteback(pc)) {
+		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_WRITEBACK]);
+		ClearPageCgroupFileWriteback(pc);
+	}
+	if (PageCgroupFileWritebackTemp(pc)) {
+		__this_cpu_dec(
+			mem->stat->count[MEM_CGROUP_STAT_WRITEBACK_TEMP]);
+		ClearPageCgroupFileWritebackTemp(pc);
+	}
+	if (PageCgroupFileUnstableNFS(pc)) {
+		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
+		ClearPageCgroupFileUnstableNFS(pc);
+	}
 }
 
 /*
@@ -1863,7 +2181,7 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	VM_BUG_ON(pc->mem_cgroup != from);
 
 	page = pc->page;
-	mem_cgroup_migrate_stat(pc, from, to);
+	mem_cgroup_migrate_file_stat(pc, from, to);
 	mem_cgroup_charge_statistics(from, pc, false);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
@@ -3168,10 +3486,14 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 enum {
 	MCS_CACHE,
 	MCS_RSS,
-	MCS_FILE_MAPPED,
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
+	MCS_FILE_MAPPED,
+	MCS_FILE_DIRTY,
+	MCS_WRITEBACK,
+	MCS_WRITEBACK_TEMP,
+	MCS_UNSTABLE_NFS,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3190,10 +3512,14 @@ struct {
 } memcg_stat_strings[NR_MCS_STAT] = {
 	{"cache", "total_cache"},
 	{"rss", "total_rss"},
-	{"mapped_file", "total_mapped_file"},
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
+	{"mapped_file", "total_mapped_file"},
+	{"filedirty", "dirty_pages"},
+	{"writeback", "writeback_pages"},
+	{"writeback_tmp", "writeback_temp_pages"},
+	{"nfs", "nfs_unstable"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3212,8 +3538,6 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
 	s->stat[MCS_CACHE] += val * PAGE_SIZE;
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
-	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGIN_COUNT);
 	s->stat[MCS_PGPGIN] += val;
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGOUT_COUNT);
@@ -3222,6 +3546,16 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
+	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_DIRTY);
+	s->stat[MCS_FILE_DIRTY] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK);
+	s->stat[MCS_WRITEBACK] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK_TEMP);
+	s->stat[MCS_WRITEBACK_TEMP] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_UNSTABLE_NFS);
+	s->stat[MCS_UNSTABLE_NFS] += val;
 
 	/* per zone stat */
 	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
@@ -3583,6 +3917,63 @@ unlock:
 	return ret;
 }
 
+static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	switch (cft->private) {
+	case MEM_CGROUP_DIRTY_RATIO:
+		return memcg->dirty_param.dirty_ratio;
+	case MEM_CGROUP_DIRTY_BYTES:
+		return memcg->dirty_param.dirty_bytes;
+	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
+		return memcg->dirty_param.dirty_background_ratio;
+	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
+		return memcg->dirty_param.dirty_background_bytes;
+	default:
+		BUG();
+	}
+}
+
+static int
+mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	int type = cft->private;
+
+	if (cgrp->parent == NULL)
+		return -EINVAL;
+	if ((type == MEM_CGROUP_DIRTY_RATIO ||
+		type == MEM_CGROUP_DIRTY_BACKGROUND_RATIO) && val > 100)
+		return -EINVAL;
+	/*
+	 * TODO: provide a validation check routine. And retry if validation
+	 * fails.
+	 */
+	switch (type) {
+	case MEM_CGROUP_DIRTY_RATIO:
+		memcg->dirty_param.dirty_ratio = val;
+		memcg->dirty_param.dirty_bytes = 0;
+		break;
+	case MEM_CGROUP_DIRTY_BYTES:
+		memcg->dirty_param.dirty_ratio  = 0;
+		memcg->dirty_param.dirty_bytes = val;
+		break;
+	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
+		memcg->dirty_param.dirty_background_ratio = val;
+		memcg->dirty_param.dirty_background_bytes = 0;
+		break;
+	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
+		memcg->dirty_param.dirty_background_ratio = 0;
+		memcg->dirty_param.dirty_background_bytes = val;
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return 0;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -3634,6 +4025,30 @@ static struct cftype mem_cgroup_files[] = {
 		.write_u64 = mem_cgroup_swappiness_write,
 	},
 	{
+		.name = "dirty_ratio",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_RATIO,
+	},
+	{
+		.name = "dirty_bytes",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_BYTES,
+	},
+	{
+		.name = "dirty_background_ratio",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
+	},
+	{
+		.name = "dirty_background_bytes",
+		.read_u64 = mem_cgroup_dirty_read,
+		.write_u64 = mem_cgroup_dirty_write,
+		.private = MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
+	},
+	{
 		.name = "move_charge_at_immigrate",
 		.read_u64 = mem_cgroup_move_charge_read,
 		.write_u64 = mem_cgroup_move_charge_write,
@@ -3892,8 +4307,21 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
 
-	if (parent)
+	if (parent) {
 		mem->swappiness = get_swappiness(parent);
+		mem->dirty_param = parent->dirty_param;
+	} else {
+		while (1) {
+			get_global_vm_dirty_param(&mem->dirty_param);
+			/*
+			 * Since global dirty parameters are not protected we
+			 * try to speculatively read them and retry if we get
+			 * inconsistent values.
+			 */
+			if (likely(dirty_param_is_valid(&mem->dirty_param)))
+				break;
+		}
+	}
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
