Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 74A1A90010C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 04:52:21 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [RFC][PATCH v7 11/14] memcg: create support routines for writeback
Date: Fri, 13 May 2011 01:47:50 -0700
Message-Id: <1305276473-14780-12-git-send-email-gthelen@google.com>
In-Reply-To: <1305276473-14780-1-git-send-email-gthelen@google.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

Introduce memcg routines to assist in per-memcg writeback:

- mem_cgroups_over_bground_dirty_thresh() determines if any cgroups need
  writeback because they are over their dirty memory threshold.

- should_writeback_mem_cgroup_inode() determines if an inode is
  contributing pages to an over-limit memcg.

- mem_cgroup_writeback_done() is used periodically during writeback to
  update memcg writeback data.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h        |   22 +++++++
 include/trace/events/memcontrol.h |   49 ++++++++++++++++
 mm/memcontrol.c                   |  116 +++++++++++++++++++++++++++++++++++++
 3 files changed, 187 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f06c2de..3d72e09 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -26,6 +26,7 @@ struct mem_cgroup;
 struct page_cgroup;
 struct page;
 struct mm_struct;
+struct writeback_control;
 
 /*
  * Per mem_cgroup page counts tracked by kernel.  As pages enter and leave these
@@ -162,6 +163,11 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
+bool should_writeback_mem_cgroup_inode(struct inode *inode,
+				       struct writeback_control *wbc);
+bool mem_cgroups_over_bground_dirty_thresh(void);
+void mem_cgroup_writeback_done(void);
+
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
@@ -361,6 +367,22 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 {
 }
 
+static inline bool
+should_writeback_mem_cgroup_inode(struct inode *inode,
+				  struct writeback_control *wbc)
+{
+	return true;
+}
+
+static inline bool mem_cgroups_over_bground_dirty_thresh(void)
+{
+	return true;
+}
+
+static inline void mem_cgroup_writeback_done(void)
+{
+}
+
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask,
diff --git a/include/trace/events/memcontrol.h b/include/trace/events/memcontrol.h
index abf1306..326a66b 100644
--- a/include/trace/events/memcontrol.h
+++ b/include/trace/events/memcontrol.h
@@ -60,6 +60,55 @@ TRACE_EVENT(mem_cgroup_dirty_info,
 		  __entry->nr_unstable_nfs)
 )
 
+TRACE_EVENT(should_writeback_mem_cgroup_inode,
+	TP_PROTO(struct inode *inode,
+		 struct writeback_control *wbc,
+		 bool over_limit),
+
+	TP_ARGS(inode, wbc, over_limit),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, ino)
+		__field(unsigned short, css_id)
+		__field(bool, shared_inodes)
+		__field(bool, over_limit)
+	),
+
+	TP_fast_assign(
+		__entry->ino = inode->i_ino;
+		__entry->css_id =
+			inode->i_mapping ? inode->i_mapping->i_memcg : 0;
+		__entry->shared_inodes = wbc->shared_inodes;
+		__entry->over_limit = over_limit;
+	),
+
+	TP_printk("ino=%ld css_id=%d shared_inodes=%d over_limit=%d",
+		  __entry->ino,
+		  __entry->css_id,
+		  __entry->shared_inodes,
+		  __entry->over_limit)
+)
+
+TRACE_EVENT(mem_cgroups_over_bground_dirty_thresh,
+	TP_PROTO(bool over_limit,
+		 unsigned short first_id),
+
+	TP_ARGS(over_limit, first_id),
+
+	TP_STRUCT__entry(
+		__field(bool, over_limit)
+		__field(unsigned short, first_id)
+	),
+
+	TP_fast_assign(
+		__entry->over_limit = over_limit;
+		__entry->first_id = first_id;
+	),
+
+	TP_printk("over_limit=%d first_css_id=%d", __entry->over_limit,
+		  __entry->first_id)
+)
+
 #endif /* _TRACE_MEMCONTROL_H */
 
 /* This part must be outside protection */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 75ef32c..230f0fb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -389,10 +389,18 @@ enum charge_type {
 #define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
 #define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
 
+/*
+ * A bitmap representing all possible memcg, indexed by css_id.  Each bit
+ * indicates if the respective memcg is over its background dirty memory
+ * limit.
+ */
+static DECLARE_BITMAP(over_bground_dirty_thresh, CSS_ID_MAX + 1);
+
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
+static struct mem_cgroup *mem_cgroup_lookup(unsigned short id);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -1503,6 +1511,114 @@ static void mem_cgroup_dirty_info(unsigned long sys_available_mem,
 	trace_mem_cgroup_dirty_info(css_id(&mem->css), info);
 }
 
+/* Are any memcg over their background dirty memory limit? */
+bool mem_cgroups_over_bground_dirty_thresh(void)
+{
+	bool over_thresh;
+
+	over_thresh = !bitmap_empty(over_bground_dirty_thresh, CSS_ID_MAX + 1);
+
+	trace_mem_cgroups_over_bground_dirty_thresh(
+		over_thresh,
+		over_thresh ? find_next_bit(over_bground_dirty_thresh,
+					    CSS_ID_MAX + 1, 0) : 0);
+
+	return over_thresh;
+}
+
+/*
+ * Should inode be written back?  wbc indicates if this is foreground or
+ * background writeback and the set of inodes worth considering.
+ */
+bool should_writeback_mem_cgroup_inode(struct inode *inode,
+				       struct writeback_control *wbc)
+{
+	unsigned short id;
+	bool over;
+
+	id = inode->i_mapping->i_memcg;
+	VM_BUG_ON(id >= CSS_ID_MAX + 1);
+
+	if (wbc->shared_inodes && id == I_MEMCG_SHARED)
+		over = true;
+	else
+		over = test_bit(id, over_bground_dirty_thresh);
+
+	trace_should_writeback_mem_cgroup_inode(inode, wbc, over);
+	return over;
+}
+
+/*
+ * Mark all child cgroup as eligible for writeback because @mem is over its bg
+ * threshold.
+ */
+static void mem_cgroup_mark_over_bg_thresh(struct mem_cgroup *mem)
+{
+	struct mem_cgroup *iter;
+
+	/* mark this and all child cgroup as candidates for writeback */
+	for_each_mem_cgroup_tree(iter, mem)
+		set_bit(css_id(&iter->css), over_bground_dirty_thresh);
+}
+
+static void mem_cgroup_queue_bg_writeback(struct mem_cgroup *mem,
+					  struct backing_dev_info *bdi)
+{
+	mem_cgroup_mark_over_bg_thresh(mem);
+	bdi_start_background_writeback(bdi);
+}
+
+/*
+ * This routine is called when per-memcg writeback completes.  It scans any
+ * previously over-bground-thresh memcg to determine if the memcg are still over
+ * their background dirty memory limit.
+ */
+void mem_cgroup_writeback_done(void)
+{
+	struct mem_cgroup *mem;
+	struct mem_cgroup *ref_mem;
+	struct dirty_info info;
+	unsigned long sys_available_mem;
+	int id;
+
+	sys_available_mem = 0;
+
+	/* for each previously over-bg-limit memcg... */
+	for (id = 0; (id = find_next_bit(over_bground_dirty_thresh,
+					 CSS_ID_MAX + 1, id)) < CSS_ID_MAX + 1;
+	     id++) {
+
+		/* reference the memcg */
+		rcu_read_lock();
+		mem = mem_cgroup_lookup(id);
+		if (mem && !css_tryget(&mem->css))
+			mem = NULL;
+		rcu_read_unlock();
+		if (!mem)
+			continue;
+		ref_mem = mem;
+
+		if (!sys_available_mem)
+			sys_available_mem = determine_dirtyable_memory();
+
+		/*
+		 * Walk the ancestry of inode's mem clearing the over-limit bits
+		 * for for any memcg under its dirty memory background
+		 * threshold.
+		 */
+		for (; mem_cgroup_has_dirty_limit(mem);
+		     mem = parent_mem_cgroup(mem)) {
+			mem_cgroup_dirty_info(sys_available_mem, mem, &info);
+			if (dirty_info_reclaimable(&info) >= info.dirty_thresh)
+				break;
+
+			clear_bit(css_id(&mem->css), over_bground_dirty_thresh);
+		}
+
+		css_put(&ref_mem->css);
+	}
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
