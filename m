Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EBF4D900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:17:43 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 11/13] writeback: make background writeback cgroup aware
Date: Wed, 17 Aug 2011 09:15:03 -0700
Message-Id: <1313597705-6093-12-git-send-email-gthelen@google.com>
In-Reply-To: <1313597705-6093-1-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

When the system is under background dirty memory threshold but some
cgroups are over their background dirty memory thresholds, then only
writeback inodes associated with the over-limit cgroups.

In addition to checking if the system dirty memory usage is over the
system background threshold, over_bground_thresh() now checks if any
cgroups are over their respective background dirty memory thresholds.

If over-limit cgroups are found, then the new
wb_writeback_work.for_cgroup field is set to distinguish between system
and memcg overages.  The new wb_writeback_work.shared_inodes field is
also set.  Inodes written by multiple cgroup are marked owned by
I_MEMCG_SHARED rather than a particular cgroup.  Such shared inodes
cannot easily be attributed to a cgroup, so per-cgroup writeback
(futures version of wakeup_flusher_threads and balance_dirty_pages)
performs suboptimally in the presence of shared inodes.  Therefore,
write shared inodes when performing cgroup background writeback.

If performing cgroup writeback, move_expired_inodes() skips inodes that
do not contribute dirty pages to the cgroup being written back.

After writing some pages, wb_writeback() will call
mem_cgroup_writeback_done() to update the set of over-bg-limits memcg.

This change also makes wakeup_flusher_threads() memcg aware so that
per-cgroup try_to_free_pages() is able to operate more efficiently
without having to write pages of foreign containers.  This change adds a
mem_cgroup parameter to wakeup_flusher_threads() to allow callers,
especially try_to_free_pages() and foreground writeback from
balance_dirty_pages(), to specify a particular cgroup to write inodes
from.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v8:

- Added optional memcg parameter to __bdi_start_writeback(),
  bdi_start_writeback(), wakeup_flusher_threads(), writeback_inodes_wb().

- move_expired_inodes() now uses pass in struct wb_writeback_work instead of
  struct writeback_control.

- Added comments to over_bground_thresh().

 fs/buffer.c               |    2 +-
 fs/fs-writeback.c         |   96 +++++++++++++++++++++++++++++++++-----------
 fs/sync.c                 |    2 +-
 include/linux/writeback.h |    6 ++-
 mm/backing-dev.c          |    3 +-
 mm/page-writeback.c       |    3 +-
 mm/vmscan.c               |    3 +-
 7 files changed, 84 insertions(+), 31 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index dd0220b..da1fb23 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -293,7 +293,7 @@ static void free_more_memory(void)
 	struct zone *zone;
 	int nid;
 
-	wakeup_flusher_threads(1024);
+	wakeup_flusher_threads(1024, NULL);
 	yield();
 
 	for_each_online_node(nid) {
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index e91fb82..ba55336 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -38,10 +38,14 @@ struct wb_writeback_work {
 	struct super_block *sb;
 	unsigned long *older_than_this;
 	enum writeback_sync_modes sync_mode;
+	unsigned short memcg_id;	/* If non-zero, then writeback specified
+					 * cgroup. */
 	unsigned int tagged_writepages:1;
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
+	unsigned int for_cgroup:1;	/* cgroup writeback */
+	unsigned int shared_inodes:1;	/* write inodes spanning cgroups */
 
 	struct list_head list;		/* pending work list */
 	struct completion *done;	/* set if the caller waits */
@@ -114,9 +118,12 @@ static void bdi_queue_work(struct backing_dev_info *bdi,
 	spin_unlock_bh(&bdi->wb_lock);
 }
 
+/*
+ * @memcg is optional.  If set, then limit writeback to the specified cgroup.
+ */
 static void
 __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-		      bool range_cyclic)
+		      bool range_cyclic, struct mem_cgroup *memcg)
 {
 	struct wb_writeback_work *work;
 
@@ -136,6 +143,8 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
+	work->memcg_id = memcg ? css_id(mem_cgroup_css(memcg)) : 0;
+	work->for_cgroup = memcg != NULL;
 
 	bdi_queue_work(bdi, work);
 }
@@ -153,7 +162,7 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
  */
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages)
 {
-	__bdi_start_writeback(bdi, nr_pages, true);
+	__bdi_start_writeback(bdi, nr_pages, true, NULL);
 }
 
 /**
@@ -257,15 +266,20 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
-	struct inode *inode;
+	struct inode *inode, *tmp_inode;
 	int do_sb_sort = 0;
 	int moved = 0;
 
-	while (!list_empty(delaying_queue)) {
-		inode = wb_inode(delaying_queue->prev);
+	list_for_each_entry_safe_reverse(inode, tmp_inode, delaying_queue,
+					 i_wb_list) {
 		if (work->older_than_this &&
 		    inode_dirtied_after(inode, *work->older_than_this))
 			break;
+		if (work->for_cgroup &&
+		    !should_writeback_mem_cgroup_inode(inode,
+						       work->memcg_id,
+						       work->shared_inodes))
+			continue;
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
 		sb = inode->i_sb;
@@ -643,31 +657,63 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 	return wrote;
 }
 
-long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages)
+/*
+ * @memcg is optional.  If set, then limit writeback to the specified cgroup.
+ * If @shared_inodes is set then writeback inodes shared by several memcg.
+ */
+long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
+			 struct mem_cgroup *memcg, bool shared_inodes)
 {
 	struct wb_writeback_work work = {
 		.nr_pages	= nr_pages,
 		.sync_mode	= WB_SYNC_NONE,
+		.memcg_id	= memcg ? css_id(mem_cgroup_css(memcg)) : 0,
+		.for_cgroup	= (memcg != NULL) || shared_inodes,
+		.shared_inodes	= shared_inodes,
 		.range_cyclic	= 1,
 	};
 
 	spin_lock(&wb->list_lock);
 	if (list_empty(&wb->b_io))
-		queue_io(wb, NULL);
+		queue_io(wb, &work);
 	__writeback_inodes_wb(wb, &work);
 	spin_unlock(&wb->list_lock);
 
 	return nr_pages - work.nr_pages;
 }
 
-static inline bool over_bground_thresh(void)
+static inline bool over_bground_thresh(struct wb_writeback_work *work)
 {
 	unsigned long background_thresh, dirty_thresh;
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 
-	return (global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
+	if (global_page_state(NR_FILE_DIRTY) +
+	    global_page_state(NR_UNSTABLE_NFS) > background_thresh) {
+		work->for_cgroup = 0;
+		return true;
+	}
+
+	/*
+	 * System dirty memory is below system background limit.  Check if any
+	 * memcg are over memcg background limit.
+	 */
+	if (mem_cgroups_over_bground_dirty_thresh()) {
+		work->for_cgroup = 1;
+
+		/*
+		 * Set shared_inodes so that background flusher writes shared
+		 * inodes in addition to inodes in over-limit memcg.  Such
+		 * shared inodes should be rarer than inodes written by a single
+		 * memcg.  Shared inodes limit the ability to map from memcg to
+		 * inode in wakeup_flusher_threads() and writeback_inodes_wb().
+		 * So the quicker such shared inodes are written, the better.
+		 */
+		work->shared_inodes = 1;
+		return true;
+	}
+
+	return false;
 }
 
 /*
@@ -729,7 +775,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
-		if (work->for_background && !over_bground_thresh())
+		if (work->for_background && !over_bground_thresh(work))
 			break;
 
 		if (work->for_kupdate) {
@@ -749,6 +795,9 @@ static long wb_writeback(struct bdi_writeback *wb,
 
 		wb_update_bandwidth(wb, wb_start);
 
+		if (progress)
+			mem_cgroup_writeback_done();
+
 		/*
 		 * Did we write something? Try for more
 		 *
@@ -813,17 +862,15 @@ static unsigned long get_nr_dirty_pages(void)
 
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
-	if (over_bground_thresh()) {
-
-		struct wb_writeback_work work = {
-			.nr_pages	= LONG_MAX,
-			.sync_mode	= WB_SYNC_NONE,
-			.for_background	= 1,
-			.range_cyclic	= 1,
-		};
+	struct wb_writeback_work work = {
+		.nr_pages	= LONG_MAX,
+		.sync_mode	= WB_SYNC_NONE,
+		.for_background	= 1,
+		.range_cyclic	= 1,
+	};
 
+	if (over_bground_thresh(&work))
 		return wb_writeback(wb, &work);
-	}
 
 	return 0;
 }
@@ -968,10 +1015,11 @@ int bdi_writeback_thread(void *data)
 
 
 /*
- * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
- * the whole world.
+ * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back the
+ * whole world.  If 'memcg' is non-NULL, then limit attempt to only write pages
+ * from the specified cgroup.
  */
-void wakeup_flusher_threads(long nr_pages)
+void wakeup_flusher_threads(long nr_pages, struct mem_cgroup *memcg)
 {
 	struct backing_dev_info *bdi;
 
@@ -984,7 +1032,7 @@ void wakeup_flusher_threads(long nr_pages)
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (!bdi_has_dirty_io(bdi))
 			continue;
-		__bdi_start_writeback(bdi, nr_pages, false);
+		__bdi_start_writeback(bdi, nr_pages, false, memcg);
 	}
 	rcu_read_unlock();
 }
diff --git a/fs/sync.c b/fs/sync.c
index c98a747..7c1ba55 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -98,7 +98,7 @@ static void sync_filesystems(int wait)
  */
 SYSCALL_DEFINE0(sync)
 {
-	wakeup_flusher_threads(0);
+	wakeup_flusher_threads(0, NULL);
 	sync_filesystems(0);
 	sync_filesystems(1);
 	if (unlikely(laptop_mode))
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index d12d070..e6790e8 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -40,6 +40,7 @@
 #define MIN_WRITEBACK_PAGES	(4096UL >> (PAGE_CACHE_SHIFT - 10))
 
 struct backing_dev_info;
+struct mem_cgroup;
 
 /*
  * fs/fs-writeback.c
@@ -85,9 +86,10 @@ void writeback_inodes_sb_nr(struct super_block *, unsigned long nr);
 int writeback_inodes_sb_if_idle(struct super_block *);
 int writeback_inodes_sb_nr_if_idle(struct super_block *, unsigned long nr);
 void sync_inodes_sb(struct super_block *);
-long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages);
+long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
+			 struct mem_cgroup *memcg, bool shared_inodes);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
-void wakeup_flusher_threads(long nr_pages);
+void wakeup_flusher_threads(long nr_pages, struct mem_cgroup *memcg);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index d6edf8d..60d101d 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -456,7 +456,8 @@ static int bdi_forker_thread(void *ptr)
 				 * the bdi from the thread. Hopefully 1024 is
 				 * large enough for efficient IO.
 				 */
-				writeback_inodes_wb(&bdi->wb, 1024);
+				writeback_inodes_wb(&bdi->wb, 1024, NULL,
+						    false);
 			} else {
 				/*
 				 * The spinlock makes sure we do not lose
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 12b3900..64de98c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -736,7 +736,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 		trace_balance_dirty_start(bdi);
 		if (bdi_nr_reclaimable > task_bdi_thresh) {
 			pages_written += writeback_inodes_wb(&bdi->wb,
-							     write_chunk);
+							     write_chunk,
+							     NULL, false);
 			trace_balance_dirty_written(bdi, pages_written);
 			if (pages_written >= write_chunk)
 				break;		/* We've done our duty */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3153729..fb0ae99 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2223,7 +2223,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
+			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
+					       sc->mem_cgroup);
 			sc->may_writepage = 1;
 		}
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
