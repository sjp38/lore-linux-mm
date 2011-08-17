Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD78900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:17:22 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 08/13] memcg: dirty page accounting support routines
Date: Wed, 17 Aug 2011 09:15:00 -0700
Message-Id: <1313597705-6093-9-git-send-email-gthelen@google.com>
In-Reply-To: <1313597705-6093-1-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

Added memcg dirty page accounting support routines.  These routines are
used by later changes to provide memcg aware writeback and dirty page
limiting.  A mem_cgroup_dirty_info() tracepoint is is also included to
allow for easier understanding of memcg writeback operation.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v8:
- Use 'memcg' rather than 'mem' for local variables and parameters.
  This is consistent with other memory controller code.

 include/linux/memcontrol.h        |    9 ++
 include/trace/events/memcontrol.h |   34 +++++++++
 mm/memcontrol.c                   |  147 +++++++++++++++++++++++++++++++++++++
 3 files changed, 190 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 630d3fa..9cc8841 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -36,6 +36,15 @@ enum mem_cgroup_page_stat_item {
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
diff --git a/include/trace/events/memcontrol.h b/include/trace/events/memcontrol.h
index 781ef9fc..abf1306 100644
--- a/include/trace/events/memcontrol.h
+++ b/include/trace/events/memcontrol.h
@@ -26,6 +26,40 @@ TRACE_EVENT(mem_cgroup_mark_inode_dirty,
 	TP_printk("ino=%ld css_id=%d", __entry->ino, __entry->css_id)
 )
 
+TRACE_EVENT(mem_cgroup_dirty_info,
+	TP_PROTO(unsigned short css_id,
+		 struct dirty_info *dirty_info),
+
+	TP_ARGS(css_id, dirty_info),
+
+	TP_STRUCT__entry(
+		__field(unsigned short, css_id)
+		__field(unsigned long, dirty_thresh)
+		__field(unsigned long, background_thresh)
+		__field(unsigned long, nr_file_dirty)
+		__field(unsigned long, nr_writeback)
+		__field(unsigned long, nr_unstable_nfs)
+		),
+
+	TP_fast_assign(
+		__entry->css_id = css_id;
+		__entry->dirty_thresh = dirty_info->dirty_thresh;
+		__entry->background_thresh = dirty_info->background_thresh;
+		__entry->nr_file_dirty = dirty_info->nr_file_dirty;
+		__entry->nr_writeback = dirty_info->nr_writeback;
+		__entry->nr_unstable_nfs = dirty_info->nr_unstable_nfs;
+		),
+
+	TP_printk("css_id=%d thresh=%ld bg_thresh=%ld dirty=%ld wb=%ld "
+		  "unstable_nfs=%ld",
+		  __entry->css_id,
+		  __entry->dirty_thresh,
+		  __entry->background_thresh,
+		  __entry->nr_file_dirty,
+		  __entry->nr_writeback,
+		  __entry->nr_unstable_nfs)
+)
+
 #endif /* _TRACE_MEMCONTROL_H */
 
 /* This part must be outside protection */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4e01699..d54adf4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1366,6 +1366,11 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
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
@@ -1396,6 +1401,148 @@ static void mem_cgroup_dirty_param(struct vm_dirty_param *param,
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
+		ret = mem_cgroup_read_stat(memcg, LRU_ACTIVE_FILE) +
+			mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
+		if (mem_cgroup_can_swap(memcg))
+			ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_ANON) +
+				mem_cgroup_read_stat(memcg, LRU_INACTIVE_ANON);
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
+		free = (res_counter_read_u64(&memcg->res, RES_LIMIT) -
+			res_counter_read_u64(&memcg->res, RES_USAGE)) >>
+			PAGE_SHIFT;
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
+static unsigned long mem_cgroup_page_stat(struct mem_cgroup *memcg,
+					  enum mem_cgroup_page_stat_item item)
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
+	info->nr_writeback =
+		mem_cgroup_page_stat(memcg, MEMCG_NR_FILE_WRITEBACK);
+	info->nr_unstable_nfs =
+		mem_cgroup_page_stat(memcg, MEMCG_NR_FILE_UNSTABLE_NFS);
+
+	trace_mem_cgroup_dirty_info(css_id(&memcg->css), info);
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
