Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 24CF6900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:17:52 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 12/13] memcg: create support routines for page writeback
Date: Wed, 17 Aug 2011 09:15:04 -0700
Message-Id: <1313597705-6093-13-git-send-email-gthelen@google.com>
In-Reply-To: <1313597705-6093-1-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

Introduce memcg routines to assist in per-memcg dirty page management:

- mem_cgroup_balance_dirty_pages() walks a memcg hierarchy comparing
  dirty memory usage against memcg foreground and background thresholds.
  If an over-background-threshold memcg is found, then per-memcg
  background writeback is queued.  Per-memcg writeback differs from
  classic, non-memcg, per bdi writeback by setting the new
  writeback_control.for_cgroup bit.

  If an over-foreground-threshold memcg is found, then foreground
  writeout occurs.  When performing foreground writeout, first consider
  inodes exclusive to the memcg.  If unable to make enough progress,
  then consider inodes shared between memcg.  Such cross-memcg inode
  sharing likely to be rare in situations that use per-cgroup memory
  isolation.  So the approach tries to handle the common case well
  without falling over in cases where such sharing exists.  This routine
  is used by balance_dirty_pages() in a later change.

- mem_cgroup_hierarchical_dirty_info() returns the dirty memory usage
  and limits of the memcg closest to (or over) its dirty limit.  This
  will be used by throttle_vm_writeout() in a latter change.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v8:

- Use 'memcg' rather than 'mem' for local variables and parameters.
  This is consistent with other memory controller code.

- No more field additions to struct writeback_control.

- Added more comments to mem_cgroup_balance_dirty_pages().

- Adapted to changes in writeback_inodes_wb().

- Improved mem_cgroup_hierarchical_dirty_info() comment.

 include/linux/memcontrol.h        |   18 ++++
 include/trace/events/memcontrol.h |   88 ++++++++++++++++++++
 mm/memcontrol.c                   |  165 +++++++++++++++++++++++++++++++++++++
 3 files changed, 271 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 103d297..f49bd2d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -186,6 +186,11 @@ bool should_writeback_mem_cgroup_inode(struct inode *inode,
 				       bool shared_inodes);
 bool mem_cgroups_over_bground_dirty_thresh(void);
 void mem_cgroup_writeback_done(void);
+bool mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
+					struct mem_cgroup *memcg,
+					struct dirty_info *info);
+void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
+				    unsigned long write_chunk);
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
@@ -402,6 +407,19 @@ static inline void mem_cgroup_writeback_done(void)
 {
 }
 
+static inline void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
+						  unsigned long write_chunk)
+{
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
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask,
diff --git a/include/trace/events/memcontrol.h b/include/trace/events/memcontrol.h
index 966aac0..20bbb85 100644
--- a/include/trace/events/memcontrol.h
+++ b/include/trace/events/memcontrol.h
@@ -113,6 +113,94 @@ TRACE_EVENT(mem_cgroups_over_bground_dirty_thresh,
 		  __entry->first_id)
 )
 
+DECLARE_EVENT_CLASS(mem_cgroup_consider_writeback,
+	TP_PROTO(unsigned short css_id,
+		 struct backing_dev_info *bdi,
+		 unsigned long nr_reclaimable,
+		 unsigned long thresh,
+		 bool over_limit),
+
+	TP_ARGS(css_id, bdi, nr_reclaimable, thresh, over_limit),
+
+	TP_STRUCT__entry(
+		__field(unsigned short, css_id)
+		__field(struct backing_dev_info *, bdi)
+		__field(unsigned long, nr_reclaimable)
+		__field(unsigned long, thresh)
+		__field(bool, over_limit)
+	),
+
+	TP_fast_assign(
+		__entry->css_id = css_id;
+		__entry->bdi = bdi;
+		__entry->nr_reclaimable = nr_reclaimable;
+		__entry->thresh = thresh;
+		__entry->over_limit = over_limit;
+	),
+
+	TP_printk("css_id=%d bdi=%p nr_reclaimable=%ld thresh=%ld "
+		  "over_limit=%d", __entry->css_id, __entry->bdi,
+		  __entry->nr_reclaimable, __entry->thresh, __entry->over_limit)
+)
+
+#define DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(name) \
+DEFINE_EVENT(mem_cgroup_consider_writeback, name, \
+	TP_PROTO(unsigned short id, \
+		 struct backing_dev_info *bdi, \
+		 unsigned long nr_reclaimable, \
+		 unsigned long thresh, \
+		 bool over_limit), \
+	TP_ARGS(id, bdi, nr_reclaimable, thresh, over_limit) \
+)
+
+DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(mem_cgroup_consider_bg_writeback);
+DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(mem_cgroup_consider_fg_writeback);
+
+TRACE_EVENT(mem_cgroup_fg_writeback,
+	TP_PROTO(unsigned long write_chunk,
+		 long nr_written,
+		 unsigned short css_id,
+		 bool shared_inodes),
+
+	TP_ARGS(write_chunk, nr_written, css_id, shared_inodes),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, write_chunk)
+		__field(long, nr_written)
+		__field(unsigned short, css_id)
+		__field(bool, shared_inodes)
+	),
+
+	TP_fast_assign(
+		__entry->write_chunk = write_chunk;
+		__entry->nr_written = nr_written;
+		__entry->css_id = css_id;
+		__entry->shared_inodes = shared_inodes;
+	),
+
+	TP_printk("css_id=%d write_chunk=%ld nr_written=%ld shared_inodes=%d",
+		  __entry->css_id,
+		  __entry->write_chunk,
+		  __entry->nr_written,
+		  __entry->shared_inodes)
+)
+
+TRACE_EVENT(mem_cgroup_enable_shared_writeback,
+	TP_PROTO(unsigned short css_id),
+
+	TP_ARGS(css_id),
+
+	TP_STRUCT__entry(
+		__field(unsigned short, css_id)
+		),
+
+	TP_fast_assign(
+		__entry->css_id = css_id;
+		),
+
+	TP_printk("enabling shared writeback for memcg %d", __entry->css_id)
+)
+
 #endif /* _TRACE_MEMCONTROL_H */
 
 /* This part must be outside protection */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5092a68..9d0b559 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1696,6 +1696,171 @@ void mem_cgroup_writeback_done(void)
 	}
 }
 
+/*
+ * This routine must be called periodically by processes which generate dirty
+ * pages.  It considers the dirty pages usage and thresholds of the current
+ * cgroup and (depending if hierarchical accounting is enabled) ancestral memcg.
+ * If any of the considered memcg are over their background dirty limit, then
+ * background writeback is queued.  If any are over the foreground dirty limit
+ * then the dirtying task is throttled while writing dirty data.  The per-memcg
+ * dirty limits checked by this routine are distinct from either the per-system,
+ * per-bdi, or per-task limits considered by balance_dirty_pages().
+ *
+ *   Example hierarchy:
+ *                 root
+ *            A            B
+ *        A1      A2         B1
+ *     A11 A12  A21 A22
+ *
+ * Assume that mem_cgroup_balance_dirty_pages() is called on A11.  This routine
+ * starts at A11 walking upwards towards the root.  If A11 is over dirty limit,
+ * then writeback A11 inodes until under limit.  Next check A1, if over limit
+ * then write A1,A11,A12.  Then check A.  If A is over A limit, then invoke
+ * writeback on A* until A is under A limit.
+ */
+void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
+				    unsigned long write_chunk)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct mem_cgroup *memcg;
+	struct mem_cgroup *ref_memcg;
+	struct dirty_info info;
+	unsigned long nr_reclaimable;
+	unsigned long nr_written;
+	unsigned long sys_available_mem;
+	unsigned long pause = 1;
+	unsigned short id;
+	bool over;
+	bool shared_inodes;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	sys_available_mem = determine_dirtyable_memory();
+
+	/* reference the memcg so it is not deleted during this routine */
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	if (memcg && mem_cgroup_is_root(memcg))
+		memcg = NULL;
+	if (memcg)
+		css_get(&memcg->css);
+	rcu_read_unlock();
+	ref_memcg = memcg;
+
+	/* balance entire ancestry of current's memcg. */
+	for (; mem_cgroup_has_dirty_limit(memcg);
+	     memcg = parent_mem_cgroup(memcg)) {
+		id = css_id(&memcg->css);
+
+		/*
+		 * Keep throttling and writing inode data so long as memcg is
+		 * over its dirty limit.  Inode being written by multiple memcg
+		 * (aka shared_inodes) cannot easily be attributed a particular
+		 * memcg.  Shared inodes are thought to be much rarer than
+		 * shared inodes.  First try to satisfy this memcg's dirty
+		 * limits using non-shared inodes.
+		 */
+		for (shared_inodes = false; ; ) {
+			/*
+			 * if memcg is under dirty limit, then break from
+			 * throttling loop.
+			 */
+			mem_cgroup_dirty_info(sys_available_mem, memcg, &info);
+			nr_reclaimable = dirty_info_reclaimable(&info);
+			over = nr_reclaimable > info.dirty_thresh;
+			trace_mem_cgroup_consider_fg_writeback(
+				id, bdi, nr_reclaimable, info.dirty_thresh,
+				over);
+			if (!over)
+				break;
+
+			nr_written = writeback_inodes_wb(&bdi->wb, write_chunk,
+							 memcg, shared_inodes);
+			trace_mem_cgroup_fg_writeback(write_chunk, nr_written,
+						      id, shared_inodes);
+			/* if no progress, then consider shared inodes */
+			if ((nr_written == 0) && !shared_inodes) {
+				trace_mem_cgroup_enable_shared_writeback(id);
+				shared_inodes = true;
+			}
+
+			__set_current_state(TASK_UNINTERRUPTIBLE);
+			io_schedule_timeout(pause);
+
+			/*
+			 * Increase the delay for each loop, up to our previous
+			 * default of taking a 100ms nap.
+			 */
+			pause <<= 1;
+			if (pause > HZ / 10)
+				pause = HZ / 10;
+		}
+
+		/* if memcg is over background limit, then queue bg writeback */
+		over = nr_reclaimable >= info.background_thresh;
+		trace_mem_cgroup_consider_bg_writeback(
+			id, bdi, nr_reclaimable, info.background_thresh,
+			over);
+		if (over)
+			mem_cgroup_queue_bg_writeback(memcg, bdi);
+	}
+
+	if (ref_memcg)
+		css_put(&ref_memcg->css);
+}
+
+/*
+ * Set @info to the dirty thresholds and usage of the memcg (within the
+ * ancestral chain of @memcg) closest to its dirty limit or the first memcg over
+ * its limit.
+ *
+ * The check is not stable because the usage and limits can change asynchronous
+ * to this routine.
+ *
+ * If @memcg has no per-cgroup dirty limits, then returns false.
+ * Otherwise @info is set and returns true.
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
+	/* walk up hierarchy enabled parents */
+	for (; mem_cgroup_has_dirty_limit(memcg);
+	     memcg = parent_mem_cgroup(memcg)) {
+		mem_cgroup_dirty_info(sys_available_mem, memcg, &cur_info);
+		usage = dirty_info_reclaimable(&cur_info) +
+			cur_info.nr_writeback;
+
+		/* if over limit, stop searching */
+		if (usage >= cur_info.dirty_thresh) {
+			*info = cur_info;
+			break;
+		}
+
+		/*
+		 * Save dirty usage of memcg closest to its limit if either:
+		 *     - memcg is the first memcg considered
+		 *     - memcg dirty margin is smaller than last recorded one
+		 */
+		if ((info->nr_writeback == ULONG_MAX) ||
+		    (cur_info.dirty_thresh - usage) <
+		    (info->dirty_thresh -
+		     (dirty_info_reclaimable(info) + info->nr_writeback)))
+			*info = cur_info;
+	}
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
