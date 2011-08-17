Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 76C94900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:17:26 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 09/13] memcg: create support routines for writeback
Date: Wed, 17 Aug 2011 09:15:01 -0700
Message-Id: <1313597705-6093-10-git-send-email-gthelen@google.com>
In-Reply-To: <1313597705-6093-1-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

Introduce memcg routines to assist in per-memcg writeback:

- mem_cgroups_over_bground_dirty_thresh() determines if any cgroups need
  writeback because they are over their dirty memory threshold.

- should_writeback_mem_cgroup_inode() will be called by writeback to
  determine if a particular inode should be written back.  The answer
  depends on the writeback context (foreground, background,
  try_to_free_pages, etc.).

- mem_cgroup_writeback_done() is used periodically during writeback to
  update memcg writeback data.

These routines make use of a new over_bground_dirty_thresh bitmap that
indicates which mem_cgroup are over their respective dirty background
threshold.  As this bitmap is indexed by css_id, the largest possible
css_id value is needed to create the bitmap.  So move the definition of
CSS_ID_MAX from cgroup.c to cgroup.h.  This allows users of css_id() to
know the largest possible css_id value.  This knowledge can be used to
build such per-cgroup bitmaps.

Make determine_dirtyable_memory() non-static because it is needed by
mem_cgroup_writeback_done().

Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v8:

- No longer passing struct writeback_control into memcontrol functions.
  Instead the needed attributes (memcg_id, etc.) are explicitly passed in.

- No more field additions to struct writeback_control.

- make determine_dirtyable_memory() non-static.

- rename 'over_limit' in should_writeback_mem_cgroup_inode() to 'wb' because
  should_writeback_mem_cgroup_inode() does not necessarily return just inodes
  that are in over-limit memcg.  It returns inodes that need writeback based
  on input criteria.

- Added more comments to clarify should_writeback_mem_cgroup_inode().

- To handle foreground writeback and try_to_free_pages(),
  should_writeback_mem_cgroup_inode() can check for the inodes in a specific
  memory cgroup.

- Use 'memcg' rather than 'mem' for local variables and parameters.
  This is consistent with other memory controller code.

 include/linux/cgroup.h            |    1 +
 include/linux/memcontrol.h        |   23 ++++++
 include/linux/writeback.h         |    1 +
 include/trace/events/memcontrol.h |   53 +++++++++++++
 kernel/cgroup.c                   |    1 -
 mm/memcontrol.c                   |  153 +++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c               |    2 +-
 7 files changed, 232 insertions(+), 2 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index da7e4bc..9277c8a 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -623,6 +623,7 @@ bool css_is_ancestor(struct cgroup_subsys_state *cg,
 		     const struct cgroup_subsys_state *root);
 
 /* Get id and depth of css */
+#define CSS_ID_MAX	(65535)
 unsigned short css_id(struct cgroup_subsys_state *css);
 unsigned short css_depth(struct cgroup_subsys_state *css);
 struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9cc8841..103d297 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -181,6 +181,12 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
+bool should_writeback_mem_cgroup_inode(struct inode *inode,
+				       unsigned short memcg_id,
+				       bool shared_inodes);
+bool mem_cgroups_over_bground_dirty_thresh(void);
+void mem_cgroup_writeback_done(void);
+
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
@@ -379,6 +385,23 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 {
 }
 
+static inline bool
+should_writeback_mem_cgroup_inode(struct inode *inode,
+				  unsigned short memcg_id,
+				  bool shared_inodes)
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
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 5e8bd6c..d12d070 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -128,6 +128,7 @@ extern unsigned int dirty_expire_interval;
 extern int vm_highmem_is_dirtyable;
 extern int block_dump;
 extern int laptop_mode;
+extern unsigned long determine_dirtyable_memory(void);
 
 extern int dirty_background_ratio_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
diff --git a/include/trace/events/memcontrol.h b/include/trace/events/memcontrol.h
index abf1306..966aac0 100644
--- a/include/trace/events/memcontrol.h
+++ b/include/trace/events/memcontrol.h
@@ -60,6 +60,59 @@ TRACE_EVENT(mem_cgroup_dirty_info,
 		  __entry->nr_unstable_nfs)
 )
 
+TRACE_EVENT(should_writeback_mem_cgroup_inode,
+	TP_PROTO(struct inode *inode,
+		 unsigned short css_id,
+		 bool shared_inodes,
+		 bool wb),
+
+	TP_ARGS(inode, css_id, shared_inodes, wb),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, ino)
+		__field(unsigned short, inode_css_id)
+		__field(unsigned short, css_id)
+		__field(bool, shared_inodes)
+		__field(bool, wb)
+	),
+
+	TP_fast_assign(
+		__entry->ino = inode->i_ino;
+		__entry->inode_css_id =
+			inode->i_mapping ? inode->i_mapping->i_memcg : 0;
+		__entry->css_id = css_id;
+		__entry->shared_inodes = shared_inodes;
+		__entry->wb = wb;
+	),
+
+	TP_printk("ino=%ld inode_css_id=%d css_id=%d shared_inodes=%d wb=%d",
+		  __entry->ino,
+		  __entry->inode_css_id,
+		  __entry->css_id,
+		  __entry->shared_inodes,
+		  __entry->wb)
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
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1d2b6ce..be862c0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -131,7 +131,6 @@ static struct cgroupfs_root rootnode;
  * CSS ID -- ID per subsys's Cgroup Subsys State(CSS). used only when
  * cgroup_subsys->use_id != 0.
  */
-#define CSS_ID_MAX	(65535)
 struct css_id {
 	/*
 	 * The css to which this ID points. This pointer is set to valid value
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d54adf4..5092a68 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -432,10 +432,18 @@ enum charge_type {
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
 static void drain_all_stock_async(struct mem_cgroup *mem);
+static struct mem_cgroup *mem_cgroup_lookup(unsigned short id);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -1543,6 +1551,151 @@ static void mem_cgroup_dirty_info(unsigned long sys_available_mem,
 	trace_mem_cgroup_dirty_info(css_id(&memcg->css), info);
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
+ * This routine is used by per-memcg writeback to determine if @inode should be
+ * written back.  The routine checks memcg attributes to determine if the inode
+ * should be written.  Note: non-memcg writeback code may choose to writeback
+ * this inode for non-memcg factors: dirtied_when time, etc.
+ *
+ * The optional @memcg_id parameter indicates the specific memcg being written
+ * back.  If set (non-zero), then only writeback inodes dirtied by @memcg_id.
+ * If unset (zero), then writeback inodes dirtied by memcg over background dirty
+ * page limit.
+ *
+ * If @shared_inodes is set, then also consider any inodes dirtied by multiple
+ * memcg.
+ *
+ * Returns true if the inode should be written back, false otherwise.
+ */
+bool should_writeback_mem_cgroup_inode(struct inode *inode,
+				       unsigned short memcg_id,
+				       bool shared_inodes)
+{
+	struct mem_cgroup *memcg;
+	struct mem_cgroup *inode_memcg;
+	unsigned short inode_id;
+	bool wb;
+
+	inode_id = inode->i_mapping->i_memcg;
+	VM_BUG_ON(inode_id >= CSS_ID_MAX + 1);
+
+	if (shared_inodes && inode_id == I_MEMCG_SHARED)
+		wb = true;
+	else if (memcg_id) {
+		if (memcg_id == inode_id)
+			wb = true;
+		else {
+			/*
+			 * Determine if inode is owned by a hierarchy child of
+			 * memcg_id.
+			 */
+			rcu_read_lock();
+			memcg = mem_cgroup_lookup(memcg_id);
+			inode_memcg = mem_cgroup_lookup(inode_id);
+			wb = memcg && inode_memcg &&
+				memcg->use_hierarchy &&
+				css_is_ancestor(&inode_memcg->css,
+						&memcg->css);
+			rcu_read_unlock();
+		}
+	} else
+		wb = test_bit(inode_id, over_bground_dirty_thresh);
+
+	trace_should_writeback_mem_cgroup_inode(inode, memcg_id, shared_inodes,
+						wb);
+	return wb;
+}
+
+/*
+ * Mark all child cgroup as eligible for writeback because @memcg is over its bg
+ * threshold.
+ */
+static void mem_cgroup_mark_over_bg_thresh(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *iter;
+
+	/* mark this and all child cgroup as candidates for writeback */
+	for_each_mem_cgroup_tree(iter, memcg)
+		set_bit(css_id(&iter->css), over_bground_dirty_thresh);
+}
+
+static void mem_cgroup_queue_bg_writeback(struct mem_cgroup *memcg,
+					  struct backing_dev_info *bdi)
+{
+	mem_cgroup_mark_over_bg_thresh(memcg);
+	bdi_start_background_writeback(bdi);
+}
+
+/*
+ * This routine is called as writeback writes inode pages.  The routine clears
+ * any over-background-limit bits for memcg that are no longer over their
+ * background dirty limit.
+ */
+void mem_cgroup_writeback_done(void)
+{
+	struct mem_cgroup *memcg;
+	struct mem_cgroup *ref_memcg;
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
+		memcg = mem_cgroup_lookup(id);
+		if (memcg && !css_tryget(&memcg->css))
+			memcg = NULL;
+		rcu_read_unlock();
+		if (!memcg) {
+			clear_bit(id, over_bground_dirty_thresh);
+			continue;
+		}
+		ref_memcg = memcg;
+
+		if (!sys_available_mem)
+			sys_available_mem = determine_dirtyable_memory();
+
+		/*
+		 * Walk the ancestry of inode's memcg clearing the over-limit
+		 * bits for for any memcg under its dirty memory background
+		 * threshold.
+		 */
+		for (; mem_cgroup_has_dirty_limit(memcg);
+		     memcg = parent_mem_cgroup(memcg)) {
+			mem_cgroup_dirty_info(sys_available_mem, memcg, &info);
+			if (dirty_info_reclaimable(&info) >=
+			    info.background_thresh)
+				break;
+
+			clear_bit(css_id(&memcg->css),
+				  over_bground_dirty_thresh);
+		}
+
+		css_put(&ref_memcg->css);
+	}
+}
+
 static void mem_cgroup_start_move(struct mem_cgroup *mem)
 {
 	int cpu;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b1f2390..12b3900 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -190,7 +190,7 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
  * Returns the numebr of pages that can currently be freed and used
  * by the kernel for direct mappings.
  */
-static unsigned long determine_dirtyable_memory(void)
+unsigned long determine_dirtyable_memory(void)
 {
 	unsigned long x;
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
