Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 53B006B016A
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 18:48:11 -0400 (EDT)
From: Curt Wohlgemuth <curtw@google.com>
Subject: [PATCH 1/2 v2] writeback: Add a 'reason' to wb_writeback_work
Date: Fri, 12 Aug 2011 15:47:24 -0700
Message-Id: <1313189245-7197-1-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Curt Wohlgemuth <curtw@google.com>

This creates a new 'reason' field in a wb_writeback_work
structure, which unambiguously identifies who initiates
writeback activity.  A 'wb_stats' enumeration has been added
to writeback.h, to enumerate the possible reasons.

The 'writeback_work_class' tracepoint event class is updated
to include the symbolic 'reason' in all trace events.

The 'writeback_queue_io' tracepoint now takes a work object,
in order to print out the 'reason' for queue_io.

And the 'writeback_inodes_sbXXX' family of routines has had
a wb_stats parameter added to them, so callers can specify
why writeback is being started.

Signed-off-by: Curt Wohlgemuth <curtw@google.com>
Acked-by: Jan Kara <jack@suse.cz>
---

Changelog since v1:

  - Added a "enum wb_stats" parameter to writeback_inodes_wb(),
    instead of assuming that the reason for this is always
    WB_STAT_BALANCE_DIRTY

  - Removed change around the call to writeback_inodes_wb() in
    balance_dirty_pages(), meant for patch 2/2 in this series.


 fs/btrfs/extent-tree.c           |    3 +-
 fs/buffer.c                      |    2 +-
 fs/ext4/inode.c                  |    2 +-
 fs/fs-writeback.c                |   49 ++++++++++++++++++++++++--------------
 fs/quota/quota.c                 |    2 +-
 fs/sync.c                        |    4 +-
 fs/ubifs/budget.c                |    2 +-
 include/linux/backing-dev.h      |    3 +-
 include/linux/writeback.h        |   33 +++++++++++++++++++++----
 include/trace/events/writeback.h |   37 +++++++++++++++++++++-------
 mm/backing-dev.c                 |    3 +-
 mm/page-writeback.c              |    6 +++-
 mm/vmscan.c                      |    4 +-
 13 files changed, 104 insertions(+), 46 deletions(-)

diff --git a/fs/btrfs/extent-tree.c b/fs/btrfs/extent-tree.c
index 66bac22..5d085a9 100644
--- a/fs/btrfs/extent-tree.c
+++ b/fs/btrfs/extent-tree.c
@@ -3332,7 +3332,8 @@ static int shrink_delalloc(struct btrfs_trans_handle *trans,
 		smp_mb();
 		nr_pages = min_t(unsigned long, nr_pages,
 		       root->fs_info->delalloc_bytes >> PAGE_CACHE_SHIFT);
-		writeback_inodes_sb_nr_if_idle(root->fs_info->sb, nr_pages);
+		writeback_inodes_sb_nr_if_idle(root->fs_info->sb, nr_pages,
+						WB_STAT_FS_FREE_SPACE);
 
 		spin_lock(&space_info->lock);
 		if (reserved > space_info->bytes_reserved)
diff --git a/fs/buffer.c b/fs/buffer.c
index 1a80b04..cfca642 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -285,7 +285,7 @@ static void free_more_memory(void)
 	struct zone *zone;
 	int nid;
 
-	wakeup_flusher_threads(1024);
+	wakeup_flusher_threads(1024, WB_STAT_FREE_MORE_MEM);
 	yield();
 
 	for_each_online_node(nid) {
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 8fdc298..62aceb7 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2200,7 +2200,7 @@ static int ext4_nonda_switch(struct super_block *sb)
 	 * start pushing delalloc when 1/2 of free blocks are dirty.
 	 */
 	if (free_blocks < 2 * dirty_blocks)
-		writeback_inodes_sb_if_idle(sb);
+		writeback_inodes_sb_if_idle(sb, WB_STAT_FS_FREE_SPACE);
 
 	return 0;
 }
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 04cf3b9..70aa19d 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -41,6 +41,7 @@ struct wb_writeback_work {
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
+	enum wb_stats reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
 	struct completion *done;	/* set if the caller waits */
@@ -115,7 +116,7 @@ static void bdi_queue_work(struct backing_dev_info *bdi,
 
 static void
 __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-		      bool range_cyclic)
+		      bool range_cyclic, enum wb_stats stat)
 {
 	struct wb_writeback_work *work;
 
@@ -135,6 +136,7 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
+	work->reason = stat;
 
 	bdi_queue_work(bdi, work);
 }
@@ -150,9 +152,10 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
  *   completion. Caller need not hold sb s_umount semaphore.
  *
  */
-void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages)
+void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
+			enum wb_stats stat)
 {
-	__bdi_start_writeback(bdi, nr_pages, true);
+	__bdi_start_writeback(bdi, nr_pages, true, stat);
 }
 
 /**
@@ -302,13 +305,14 @@ out:
  *                                           |
  *                                           +--> dequeue for IO
  */
-static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
+static void queue_io(struct bdi_writeback *wb, struct wb_writeback_work *work)
 {
 	int moved;
 	assert_spin_locked(&wb->list_lock);
 	list_splice_init(&wb->b_more_io, &wb->b_io);
-	moved = move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
-	trace_writeback_queue_io(wb, older_than_this, moved);
+	moved = move_expired_inodes(&wb->b_dirty, &wb->b_io,
+					work->older_than_this);
+	trace_writeback_queue_io(wb, work, moved);
 }
 
 static int write_inode(struct inode *inode, struct writeback_control *wbc)
@@ -641,17 +645,19 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 	return wrote;
 }
 
-long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages)
+long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
+				enum wb_stats stat)
 {
 	struct wb_writeback_work work = {
 		.nr_pages	= nr_pages,
 		.sync_mode	= WB_SYNC_NONE,
 		.range_cyclic	= 1,
+		.reason		= stat,
 	};
 
 	spin_lock(&wb->list_lock);
 	if (list_empty(&wb->b_io))
-		queue_io(wb, NULL);
+		queue_io(wb, &work);
 	__writeback_inodes_wb(wb, &work);
 	spin_unlock(&wb->list_lock);
 
@@ -738,7 +744,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 
 		trace_writeback_start(wb->bdi, work);
 		if (list_empty(&wb->b_io))
-			queue_io(wb, work->older_than_this);
+			queue_io(wb, work);
 		if (work->sb)
 			progress = writeback_sb_inodes(work->sb, wb, work);
 		else
@@ -818,6 +824,7 @@ static long wb_check_background_flush(struct bdi_writeback *wb)
 			.sync_mode	= WB_SYNC_NONE,
 			.for_background	= 1,
 			.range_cyclic	= 1,
+			.reason		= WB_STAT_BG_WRITEOUT,
 		};
 
 		return wb_writeback(wb, &work);
@@ -851,6 +858,7 @@ static long wb_check_old_data_flush(struct bdi_writeback *wb)
 			.sync_mode	= WB_SYNC_NONE,
 			.for_kupdate	= 1,
 			.range_cyclic	= 1,
+			.reason		= WB_STAT_KUPDATE,
 		};
 
 		return wb_writeback(wb, &work);
@@ -969,7 +977,7 @@ int bdi_writeback_thread(void *data)
  * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
  * the whole world.
  */
-void wakeup_flusher_threads(long nr_pages)
+void wakeup_flusher_threads(long nr_pages, enum wb_stats stat)
 {
 	struct backing_dev_info *bdi;
 
@@ -982,7 +990,7 @@ void wakeup_flusher_threads(long nr_pages)
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (!bdi_has_dirty_io(bdi))
 			continue;
-		__bdi_start_writeback(bdi, nr_pages, false);
+		__bdi_start_writeback(bdi, nr_pages, false, stat);
 	}
 	rcu_read_unlock();
 }
@@ -1203,7 +1211,9 @@ static void wait_sb_inodes(struct super_block *sb)
  * on how many (if any) will be written, and this function does not wait
  * for IO completion of submitted IO.
  */
-void writeback_inodes_sb_nr(struct super_block *sb, unsigned long nr)
+void writeback_inodes_sb_nr(struct super_block *sb,
+			    unsigned long nr,
+			    enum wb_stats stat)
 {
 	DECLARE_COMPLETION_ONSTACK(done);
 	struct wb_writeback_work work = {
@@ -1212,6 +1222,7 @@ void writeback_inodes_sb_nr(struct super_block *sb, unsigned long nr)
 		.tagged_writepages	= 1,
 		.done			= &done,
 		.nr_pages		= nr,
+		.reason			= stat,
 	};
 
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
@@ -1228,9 +1239,9 @@ EXPORT_SYMBOL(writeback_inodes_sb_nr);
  * on how many (if any) will be written, and this function does not wait
  * for IO completion of submitted IO.
  */
-void writeback_inodes_sb(struct super_block *sb)
+void writeback_inodes_sb(struct super_block *sb, enum wb_stats stat)
 {
-	return writeback_inodes_sb_nr(sb, get_nr_dirty_pages());
+	return writeback_inodes_sb_nr(sb, get_nr_dirty_pages(), stat);
 }
 EXPORT_SYMBOL(writeback_inodes_sb);
 
@@ -1241,11 +1252,11 @@ EXPORT_SYMBOL(writeback_inodes_sb);
  * Invoke writeback_inodes_sb if no writeback is currently underway.
  * Returns 1 if writeback was started, 0 if not.
  */
-int writeback_inodes_sb_if_idle(struct super_block *sb)
+int writeback_inodes_sb_if_idle(struct super_block *sb, enum wb_stats stat)
 {
 	if (!writeback_in_progress(sb->s_bdi)) {
 		down_read(&sb->s_umount);
-		writeback_inodes_sb(sb);
+		writeback_inodes_sb(sb, stat);
 		up_read(&sb->s_umount);
 		return 1;
 	} else
@@ -1262,11 +1273,12 @@ EXPORT_SYMBOL(writeback_inodes_sb_if_idle);
  * Returns 1 if writeback was started, 0 if not.
  */
 int writeback_inodes_sb_nr_if_idle(struct super_block *sb,
-				   unsigned long nr)
+				   unsigned long nr,
+				   enum wb_stats stat)
 {
 	if (!writeback_in_progress(sb->s_bdi)) {
 		down_read(&sb->s_umount);
-		writeback_inodes_sb_nr(sb, nr);
+		writeback_inodes_sb_nr(sb, nr, stat);
 		up_read(&sb->s_umount);
 		return 1;
 	} else
@@ -1290,6 +1302,7 @@ void sync_inodes_sb(struct super_block *sb)
 		.nr_pages	= LONG_MAX,
 		.range_cyclic	= 0,
 		.done		= &done,
+		.reason		= WB_STAT_SYNC,
 	};
 
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
diff --git a/fs/quota/quota.c b/fs/quota/quota.c
index b34bdb2..a3d158c 100644
--- a/fs/quota/quota.c
+++ b/fs/quota/quota.c
@@ -286,7 +286,7 @@ static int do_quotactl(struct super_block *sb, int type, int cmd, qid_t id,
 		/* caller already holds s_umount */
 		if (sb->s_flags & MS_RDONLY)
 			return -EROFS;
-		writeback_inodes_sb(sb);
+		writeback_inodes_sb(sb, WB_STAT_SYNC);
 		return 0;
 	default:
 		return -EINVAL;
diff --git a/fs/sync.c b/fs/sync.c
index c98a747..b333bb4 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -43,7 +43,7 @@ static int __sync_filesystem(struct super_block *sb, int wait)
 	if (wait)
 		sync_inodes_sb(sb);
 	else
-		writeback_inodes_sb(sb);
+		writeback_inodes_sb(sb, WB_STAT_SYNC);
 
 	if (sb->s_op->sync_fs)
 		sb->s_op->sync_fs(sb, wait);
@@ -98,7 +98,7 @@ static void sync_filesystems(int wait)
  */
 SYSCALL_DEFINE0(sync)
 {
-	wakeup_flusher_threads(0);
+	wakeup_flusher_threads(0, WB_STAT_SYNC);
 	sync_filesystems(0);
 	sync_filesystems(1);
 	if (unlikely(laptop_mode))
diff --git a/fs/ubifs/budget.c b/fs/ubifs/budget.c
index 315de66..9a392a0 100644
--- a/fs/ubifs/budget.c
+++ b/fs/ubifs/budget.c
@@ -63,7 +63,7 @@
 static void shrink_liability(struct ubifs_info *c, int nr_to_write)
 {
 	down_read(&c->vfs_sb->s_umount);
-	writeback_inodes_sb(c->vfs_sb);
+	writeback_inodes_sb(c->vfs_sb, WB_STAT_FS_FREE_SPACE);
 	up_read(&c->vfs_sb->s_umount);
 }
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 3b2f9cb..9da81ef 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -107,7 +107,8 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
 void bdi_unregister(struct backing_dev_info *bdi);
 int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
-void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages);
+void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
+			enum wb_stats stat);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
 int bdi_writeback_thread(void *data);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index f1bfa12e..a70696d 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -50,6 +50,24 @@ enum writeback_sync_modes {
 };
 
 /*
+ * why this writeback was initiated
+ */
+enum wb_stats {
+	/* The following are counts of pages written for a specific cause */
+	WB_STAT_BALANCE_DIRTY,
+	WB_STAT_BG_WRITEOUT,
+	WB_STAT_TRY_TO_FREE_PAGES,
+	WB_STAT_SYNC,
+	WB_STAT_KUPDATE,
+	WB_STAT_LAPTOP_TIMER,
+	WB_STAT_FREE_MORE_MEM,
+	WB_STAT_FS_FREE_SPACE,
+	WB_STAT_FORKER_THREAD,
+
+	WB_STAT_MAX,
+};
+
+/*
  * A control structure which tells the writeback code what to do.  These are
  * always on the stack, and hence need no locking.  They are always initialised
  * in a manner such that unspecified fields are set to zero.
@@ -80,14 +98,17 @@ struct writeback_control {
  */	
 struct bdi_writeback;
 int inode_wait(void *);
-void writeback_inodes_sb(struct super_block *);
-void writeback_inodes_sb_nr(struct super_block *, unsigned long nr);
-int writeback_inodes_sb_if_idle(struct super_block *);
-int writeback_inodes_sb_nr_if_idle(struct super_block *, unsigned long nr);
+void writeback_inodes_sb(struct super_block *, enum wb_stats stat);
+void writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
+							enum wb_stats stat);
+int writeback_inodes_sb_if_idle(struct super_block *, enum wb_stats stat);
+int writeback_inodes_sb_nr_if_idle(struct super_block *, unsigned long nr,
+							enum wb_stats stat);
 void sync_inodes_sb(struct super_block *);
-long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages);
+long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
+				enum wb_stats stat);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
-void wakeup_flusher_threads(long nr_pages);
+void wakeup_flusher_threads(long nr_pages, enum wb_stats stat);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 6bca4cc..dbb8330 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -21,6 +21,18 @@
 		{I_REFERENCED,		"I_REFERENCED"}		\
 	)
 
+#define show_work_reason(reason)					\
+	__print_symbolic(reason,					\
+		{WB_STAT_BALANCE_DIRTY,		"balance_dirty"},	\
+		{WB_STAT_BG_WRITEOUT,		"background"},		\
+		{WB_STAT_TRY_TO_FREE_PAGES,	"try_to_free_pages"},	\
+		{WB_STAT_SYNC,			"sync"},		\
+		{WB_STAT_KUPDATE,		"periodic"},		\
+		{WB_STAT_LAPTOP_TIMER,		"laptop_timer"},	\
+		{WB_STAT_FREE_MORE_MEM,		"free_more_memory"},	\
+		{WB_STAT_FS_FREE_SPACE,		"FS_free_space"}	\
+	)
+
 struct wb_writeback_work;
 
 DECLARE_EVENT_CLASS(writeback_work_class,
@@ -34,6 +46,7 @@ DECLARE_EVENT_CLASS(writeback_work_class,
 		__field(int, for_kupdate)
 		__field(int, range_cyclic)
 		__field(int, for_background)
+		__field(int, reason)
 	),
 	TP_fast_assign(
 		strncpy(__entry->name, dev_name(bdi->dev), 32);
@@ -43,16 +56,18 @@ DECLARE_EVENT_CLASS(writeback_work_class,
 		__entry->for_kupdate = work->for_kupdate;
 		__entry->range_cyclic = work->range_cyclic;
 		__entry->for_background	= work->for_background;
+		__entry->reason = work->reason;
 	),
 	TP_printk("bdi %s: sb_dev %d:%d nr_pages=%ld sync_mode=%d "
-		  "kupdate=%d range_cyclic=%d background=%d",
+		  "kupdate=%d range_cyclic=%d background=%d reason=%s",
 		  __entry->name,
 		  MAJOR(__entry->sb_dev), MINOR(__entry->sb_dev),
 		  __entry->nr_pages,
 		  __entry->sync_mode,
 		  __entry->for_kupdate,
 		  __entry->range_cyclic,
-		  __entry->for_background
+		  __entry->for_background,
+		  show_work_reason(__entry->reason)
 	)
 );
 #define DEFINE_WRITEBACK_WORK_EVENT(name) \
@@ -181,27 +196,31 @@ DEFINE_WBC_EVENT(wbc_writepage);
 
 TRACE_EVENT(writeback_queue_io,
 	TP_PROTO(struct bdi_writeback *wb,
-		 unsigned long *older_than_this,
+		 struct wb_writeback_work *work,
 		 int moved),
-	TP_ARGS(wb, older_than_this, moved),
+	TP_ARGS(wb, work, moved),
 	TP_STRUCT__entry(
 		__array(char,		name, 32)
 		__field(unsigned long,	older)
 		__field(long,		age)
 		__field(int,		moved)
+		__field(int,		reason)
 	),
 	TP_fast_assign(
 		strncpy(__entry->name, dev_name(wb->bdi->dev), 32);
-		__entry->older	= older_than_this ?  *older_than_this : 0;
-		__entry->age	= older_than_this ?
-				  (jiffies - *older_than_this) * 1000 / HZ : -1;
+		__entry->older	= work->older_than_this ?
+						*work->older_than_this : 0;
+		__entry->age	= work->older_than_this ?
+			  (jiffies - *work->older_than_this) * 1000 / HZ : -1;
 		__entry->moved	= moved;
+		__entry->reason	= work->reason;
 	),
-	TP_printk("bdi %s: older=%lu age=%ld enqueue=%d",
+	TP_printk("bdi %s: older=%lu age=%ld enqueue=%d reason=%s",
 		__entry->name,
 		__entry->older,	/* older_than_this in jiffies */
 		__entry->age,	/* older_than_this in relative milliseconds */
-		__entry->moved)
+		__entry->moved,
+		show_work_reason(__entry->reason))
 );
 
 TRACE_EVENT(global_dirty_state,
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index d6edf8d..63b3b29 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -456,7 +456,8 @@ static int bdi_forker_thread(void *ptr)
 				 * the bdi from the thread. Hopefully 1024 is
 				 * large enough for efficient IO.
 				 */
-				writeback_inodes_wb(&bdi->wb, 1024);
+				writeback_inodes_wb(&bdi->wb, 1024,
+							WB_STAT_FORKER_THREAD);
 			} else {
 				/*
 				 * The spinlock makes sure we do not lose
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d196074..5503461 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -738,7 +738,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 		trace_balance_dirty_start(bdi);
 		if (bdi_nr_reclaimable > task_bdi_thresh) {
 			pages_written += writeback_inodes_wb(&bdi->wb,
-							     write_chunk);
+						write_chunk,
+						WB_STAT_BALANCE_DIRTY);
 			trace_balance_dirty_written(bdi, pages_written);
 			if (pages_written >= write_chunk)
 				break;		/* We've done our duty */
@@ -909,7 +910,8 @@ void laptop_mode_timer_fn(unsigned long data)
 	 * threshold
 	 */
 	if (bdi_has_dirty_io(&q->backing_dev_info))
-		bdi_start_writeback(&q->backing_dev_info, nr_pages);
+		bdi_start_writeback(&q->backing_dev_info, nr_pages,
+					WB_STAT_LAPTOP_TIMER);
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7ef6912..4a882ca 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -495,7 +495,6 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 			return PAGE_ACTIVATE;
 		}
-
 		/*
 		 * Wait on writeback if requested to. This happens when
 		 * direct reclaiming a large contiguous area and the
@@ -2198,7 +2197,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
+			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
+						WB_STAT_TRY_TO_FREE_PAGES);
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
