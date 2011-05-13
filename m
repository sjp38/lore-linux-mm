Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAF66B0027
	for <linux-mm@kvack.org>; Fri, 13 May 2011 04:51:58 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [RFC][PATCH v7 10/14] memcg: dirty page accounting support routines
Date: Fri, 13 May 2011 01:47:49 -0700
Message-Id: <1305276473-14780-11-git-send-email-gthelen@google.com>
In-Reply-To: <1305276473-14780-1-git-send-email-gthelen@google.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

Added memcg dirty page accounting support routines.  These routines are
used by later changes to provide memcg aware writeback and dirty page
limiting.  A mem_cgroup_dirty_info() tracepoint is is also included to
allow for easier understanding of memcg writeback operation.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h        |    9 +++
 include/trace/events/memcontrol.h |   34 +++++++++
 mm/memcontrol.c                   |  145 +++++++++++++++++++++++++++++++++++++
 3 files changed, 188 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f1261e5..f06c2de 100644
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
index 248396c..75ef32c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1328,6 +1328,11 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
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
@@ -1358,6 +1363,146 @@ static void mem_cgroup_dirty_param(struct vm_dirty_param *param,
 	}
 }
 
+static inline bool mem_cgroup_can_swap(struct mem_cgroup *mem)
+{
+	if (!do_swap_account)
+		return nr_swap_pages > 0;
+	return !mem->memsw_is_minimum &&
+		(res_counter_read_u64(&mem->memsw, RES_LIMIT) > 0);
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
+/* Return dirty thresholds and usage for @mem. */
+static void mem_cgroup_dirty_info(unsigned long sys_available_mem,
+				  struct mem_cgroup *mem,
+				  struct dirty_info *info)
+{
+	unsigned long uninitialized_var(available_mem);
+	struct vm_dirty_param dirty_param;
+
+	mem_cgroup_dirty_param(&dirty_param, mem);
+
+	if (!dirty_param.dirty_bytes || !dirty_param.dirty_background_bytes)
+		available_mem = min(
+			sys_available_mem,
+			mem_cgroup_page_stat(mem, MEMCG_NR_DIRTYABLE_PAGES));
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
+	info->nr_file_dirty = mem_cgroup_page_stat(mem, MEMCG_NR_FILE_DIRTY);
+	info->nr_writeback = mem_cgroup_page_stat(mem, MEMCG_NR_FILE_WRITEBACK);
+	info->nr_unstable_nfs =
+		mem_cgroup_page_stat(mem, MEMCG_NR_FILE_UNSTABLE_NFS);
+
+	trace_mem_cgroup_dirty_info(css_id(&mem->css), info);
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
