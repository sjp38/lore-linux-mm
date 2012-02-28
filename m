Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 20BEF6B007E
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:56:22 -0500 (EST)
Message-Id: <20120228144747.124608935@intel.com>
Date: Tue, 28 Feb 2012 22:00:26 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 4/9] memcg: dirty page accounting support routines
References: <20120228140022.614718843@intel.com>
Content-Disposition: inline; filename=memcg-dirty-page-accounting-support-routines.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

From: Greg Thelen <gthelen@google.com>

Added memcg dirty page accounting support routines.  These routines are
used by later changes to provide memcg aware writeback and dirty page
limiting.  A mem_cgroup_dirty_info() tracepoint is is also included to
allow for easier understanding of memcg writeback operation.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
Changelog since v8:
- Use 'memcg' rather than 'mem' for local variables and parameters.
  This is consistent with other memory controller code.

 include/linux/memcontrol.h |    5 +
 mm/memcontrol.c            |  112 +++++++++++++++++++++++++++++++++++
 2 files changed, 117 insertions(+)

--- linux.orig/include/linux/memcontrol.h	2012-02-25 20:48:34.337580646 +0800
+++ linux/include/linux/memcontrol.h	2012-02-25 20:48:34.361580646 +0800
@@ -36,8 +36,13 @@ enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
 	MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
 	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
+	MEMCG_NR_DIRTYABLE_PAGES, /* # of pages that could be dirty */
 };
 
+unsigned long mem_cgroup_page_stat(struct mem_cgroup *memcg,
+				   enum mem_cgroup_page_stat_item item);
+unsigned long mem_cgroup_dirty_pages(struct mem_cgroup *memcg);
+
 struct mem_cgroup_reclaim_cookie {
 	struct zone *zone;
 	int priority;
--- linux.orig/mm/memcontrol.c	2012-02-25 20:48:34.337580646 +0800
+++ linux/mm/memcontrol.c	2012-02-25 21:09:54.073554384 +0800
@@ -1255,6 +1255,118 @@ int mem_cgroup_swappiness(struct mem_cgr
 	return memcg->swappiness;
 }
 
+static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
+{
+	if (nr_swap_pages == 0)
+		return false;
+	if (!do_swap_account)
+		return true;
+	if (memcg->memsw_is_minimum)
+		return false;
+	if (res_counter_margin(&memcg->memsw) == 0)
+		return false;
+	return true;
+}
+
+static s64 mem_cgroup_local_page_stat(struct mem_cgroup *memcg,
+				      enum mem_cgroup_page_stat_item item)
+{
+	s64 ret;
+
+	switch (item) {
+	case MEMCG_NR_FILE_DIRTY:
+		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY);
+		break;
+	case MEMCG_NR_FILE_WRITEBACK:
+		ret = mem_cgroup_read_stat(memcg,
+					   MEM_CGROUP_STAT_FILE_WRITEBACK);
+		break;
+	case MEMCG_NR_FILE_UNSTABLE_NFS:
+		ret = mem_cgroup_read_stat(memcg,
+					   MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
+		break;
+	case MEMCG_NR_DIRTYABLE_PAGES:
+		ret = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_FILE)) +
+			mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_FILE));
+		if (mem_cgroup_can_swap(memcg))
+			ret += mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_ANON)) +
+				mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_ANON));
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return ret;
+}
+
+/*
+ * Return the number of additional pages that the @memcg cgroup could allocate.
+ * If use_hierarchy is set, then this involves checking parent mem cgroups to
+ * find the cgroup with the smallest free space.
+ */
+static unsigned long
+mem_cgroup_hierarchical_free_pages(struct mem_cgroup *memcg)
+{
+	u64 free;
+	unsigned long min_free;
+
+	min_free = global_page_state(NR_FREE_PAGES);
+
+	while (memcg) {
+		free = mem_cgroup_margin(memcg);
+		min_free = min_t(u64, min_free, free);
+		memcg = parent_mem_cgroup(memcg);
+	}
+
+	return min_free;
+}
+
+/*
+ * mem_cgroup_page_stat() - get memory cgroup file cache statistics
+ * @memcg:     memory cgroup to query
+ * @item:      memory statistic item exported to the kernel
+ *
+ * Return the accounted statistic value.
+ */
+unsigned long mem_cgroup_page_stat(struct mem_cgroup *memcg,
+				   enum mem_cgroup_page_stat_item item)
+{
+	struct mem_cgroup *iter;
+	s64 value;
+
+	/*
+	 * If we're looking for dirtyable pages we need to evaluate free pages
+	 * depending on the limit and usage of the parents first of all.
+	 */
+	if (item == MEMCG_NR_DIRTYABLE_PAGES)
+		value = mem_cgroup_hierarchical_free_pages(memcg);
+	else
+		value = 0;
+
+	/*
+	 * Recursively evaluate page statistics against all cgroup under
+	 * hierarchy tree
+	 */
+	for_each_mem_cgroup_tree(iter, memcg)
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
+unsigned long mem_cgroup_dirty_pages(struct mem_cgroup *memcg)
+{
+	return mem_cgroup_page_stat(memcg, MEMCG_NR_FILE_DIRTY) +
+		mem_cgroup_page_stat(memcg, MEMCG_NR_FILE_WRITEBACK) +
+		mem_cgroup_page_stat(memcg, MEMCG_NR_FILE_UNSTABLE_NFS);
+}
+
 static void mem_cgroup_start_move(struct mem_cgroup *memcg)
 {
 	int cpu;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
