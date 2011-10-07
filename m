Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id EBEC16B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 11:28:06 -0400 (EDT)
Date: Fri, 7 Oct 2011 23:28:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/2 v2] writeback: Add a 'reason' to wb_writeback_work
Message-ID: <20111007152801.GA18460@localhost>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
 <20110928150242.GB16159@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110928150242.GB16159@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Curt Wohlgemuth <curtw@google.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Sep 28, 2011 at 11:02:42PM +0800, Christoph Hellwig wrote:
> Did we get to any conclusion on this series?  I think having these
> additional reasons in the tracepoints and the additional statistics
> would be extremely useful for us who have to deal with writeback
> issues frequently.

I think we've reached reasonable agreements on the first patch, which
has been split into two ones by Curt:

1/2 writeback: send work item to queue_io, move_expired_inodes
2/2 writeback: Add a 'reason' to wb_writeback_work

I further incorporated some suggested changes by Jan and get the below
updated patch 2/2, with changes

- replace the tracing symbol array with wb_reason_name[]
- remove the balance_dirty_pages reason (no longer exists)
- rename @stat to @reason in the function declarations
- rename "FS_free_space" to "fs_free_space"

If no objections, I can push the two patches to linux-next tomorrow.

Thanks,
Fengguang
---
Subject: writeback: Add a 'reason' to wb_writeback_work
Date: Fri Oct 07 21:54:10 CST 2011

From: Curt Wohlgemuth <curtw@google.com>

This creates a new 'reason' field in a wb_writeback_work
structure, which unambiguously identifies who initiates
writeback activity.  A 'wb_reason' enumeration has been
added to writeback.h, to enumerate the possible reasons.

The 'writeback_work_class' and tracepoint event class and
'writeback_queue_io' tracepoints are updated to include the
symbolic 'reason' in all trace events.

And the 'writeback_inodes_sbXXX' family of routines has had
a wb_stats parameter added to them, so callers can specify
why writeback is being started.

Acked-by: Jan Kara <jack@suse.cz>
Signed-off-by: Curt Wohlgemuth <curtw@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---

Changes since v2:

   - enum wb_stats renamed enum wb_reason
   - All WB_STAT_xxx enum constants now named WB_REASON_xxx
   - All 'reason' strings in tracepoints match the WB_REASON name
   - The change to send 'work' to queue_io, move_expired_inodes, and
     trace_writeback_queue_io are in a separate commit

 fs/btrfs/extent-tree.c           |    3 +
 fs/buffer.c                      |    2 -
 fs/ext4/inode.c                  |    2 -
 fs/fs-writeback.c                |   49 +++++++++++++++++++++--------
 fs/quota/quota.c                 |    2 -
 fs/sync.c                        |    4 +-
 fs/ubifs/budget.c                |    2 -
 include/linux/backing-dev.h      |    3 +
 include/linux/writeback.h        |   32 +++++++++++++++---
 include/trace/events/writeback.h |   14 +++++---
 mm/backing-dev.c                 |    3 +
 mm/page-writeback.c              |    3 +
 mm/vmscan.c                      |    3 +
 13 files changed, 88 insertions(+), 34 deletions(-)

--- linux-next.orig/fs/btrfs/extent-tree.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/fs/btrfs/extent-tree.c	2011-10-07 22:24:47.000000000 +0800
@@ -3340,7 +3340,8 @@ static int shrink_delalloc(struct btrfs_
 		smp_mb();
 		nr_pages = min_t(unsigned long, nr_pages,
 		       root->fs_info->delalloc_bytes >> PAGE_CACHE_SHIFT);
-		writeback_inodes_sb_nr_if_idle(root->fs_info->sb, nr_pages);
+		writeback_inodes_sb_nr_if_idle(root->fs_info->sb, nr_pages,
+						WB_REASON_FS_FREE_SPACE);
 
 		spin_lock(&space_info->lock);
 		if (reserved > space_info->bytes_reserved)
--- linux-next.orig/fs/buffer.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/fs/buffer.c	2011-10-07 22:24:47.000000000 +0800
@@ -285,7 +285,7 @@ static void free_more_memory(void)
 	struct zone *zone;
 	int nid;
 
-	wakeup_flusher_threads(1024);
+	wakeup_flusher_threads(1024, WB_REASON_FREE_MORE_MEM);
 	yield();
 
 	for_each_online_node(nid) {
--- linux-next.orig/fs/ext4/inode.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/fs/ext4/inode.c	2011-10-07 22:24:47.000000000 +0800
@@ -2241,7 +2241,7 @@ static int ext4_nonda_switch(struct supe
 	 * start pushing delalloc when 1/2 of free blocks are dirty.
 	 */
 	if (free_blocks < 2 * dirty_blocks)
-		writeback_inodes_sb_if_idle(sb);
+		writeback_inodes_sb_if_idle(sb, WB_REASON_FS_FREE_SPACE);
 
 	return 0;
 }
--- linux-next.orig/fs/fs-writeback.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-10-07 22:24:47.000000000 +0800
@@ -41,11 +41,23 @@ struct wb_writeback_work {
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
+	enum wb_reason reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
 	struct completion *done;	/* set if the caller waits */
 };
 
+const char *wb_reason_name[] = {
+	[WB_REASON_BACKGROUND]		= "background",
+	[WB_REASON_TRY_TO_FREE_PAGES]	= "try_to_free_pages",
+	[WB_REASON_SYNC]		= "sync",
+	[WB_REASON_PERIODIC]		= "periodic",
+	[WB_REASON_LAPTOP_TIMER]	= "laptop_timer",
+	[WB_REASON_FREE_MORE_MEM]	= "free_more_memory",
+	[WB_REASON_FS_FREE_SPACE]	= "fs_free_space",
+	[WB_REASON_FORKER_THREAD]	= "forker_thread"
+};
+
 /*
  * Include the creation of the trace points after defining the
  * wb_writeback_work structure so that the definition remains local to this
@@ -115,7 +127,7 @@ static void bdi_queue_work(struct backin
 
 static void
 __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-		      bool range_cyclic)
+		      bool range_cyclic, enum wb_reason reason)
 {
 	struct wb_writeback_work *work;
 
@@ -135,6 +147,7 @@ __bdi_start_writeback(struct backing_dev
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
+	work->reason	= reason;
 
 	bdi_queue_work(bdi, work);
 }
@@ -150,9 +163,10 @@ __bdi_start_writeback(struct backing_dev
  *   completion. Caller need not hold sb s_umount semaphore.
  *
  */
-void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages)
+void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
+			enum wb_reason reason)
 {
-	__bdi_start_writeback(bdi, nr_pages, true);
+	__bdi_start_writeback(bdi, nr_pages, true, reason);
 }
 
 /**
@@ -641,12 +655,14 @@ static long __writeback_inodes_wb(struct
 	return wrote;
 }
 
-long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages)
+long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
+				enum wb_reason reason)
 {
 	struct wb_writeback_work work = {
 		.nr_pages	= nr_pages,
 		.sync_mode	= WB_SYNC_NONE,
 		.range_cyclic	= 1,
+		.reason		= reason,
 	};
 
 	spin_lock(&wb->list_lock);
@@ -825,6 +841,7 @@ static long wb_check_background_flush(st
 			.sync_mode	= WB_SYNC_NONE,
 			.for_background	= 1,
 			.range_cyclic	= 1,
+			.reason		= WB_REASON_BACKGROUND,
 		};
 
 		return wb_writeback(wb, &work);
@@ -858,6 +875,7 @@ static long wb_check_old_data_flush(stru
 			.sync_mode	= WB_SYNC_NONE,
 			.for_kupdate	= 1,
 			.range_cyclic	= 1,
+			.reason		= WB_REASON_PERIODIC,
 		};
 
 		return wb_writeback(wb, &work);
@@ -976,7 +994,7 @@ int bdi_writeback_thread(void *data)
  * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
  * the whole world.
  */
-void wakeup_flusher_threads(long nr_pages)
+void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 {
 	struct backing_dev_info *bdi;
 
@@ -989,7 +1007,7 @@ void wakeup_flusher_threads(long nr_page
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (!bdi_has_dirty_io(bdi))
 			continue;
-		__bdi_start_writeback(bdi, nr_pages, false);
+		__bdi_start_writeback(bdi, nr_pages, false, reason);
 	}
 	rcu_read_unlock();
 }
@@ -1210,7 +1228,9 @@ static void wait_sb_inodes(struct super_
  * on how many (if any) will be written, and this function does not wait
  * for IO completion of submitted IO.
  */
-void writeback_inodes_sb_nr(struct super_block *sb, unsigned long nr)
+void writeback_inodes_sb_nr(struct super_block *sb,
+			    unsigned long nr,
+			    enum wb_reason reason)
 {
 	DECLARE_COMPLETION_ONSTACK(done);
 	struct wb_writeback_work work = {
@@ -1219,6 +1239,7 @@ void writeback_inodes_sb_nr(struct super
 		.tagged_writepages	= 1,
 		.done			= &done,
 		.nr_pages		= nr,
+		.reason			= reason,
 	};
 
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
@@ -1235,9 +1256,9 @@ EXPORT_SYMBOL(writeback_inodes_sb_nr);
  * on how many (if any) will be written, and this function does not wait
  * for IO completion of submitted IO.
  */
-void writeback_inodes_sb(struct super_block *sb)
+void writeback_inodes_sb(struct super_block *sb, enum wb_reason reason)
 {
-	return writeback_inodes_sb_nr(sb, get_nr_dirty_pages());
+	return writeback_inodes_sb_nr(sb, get_nr_dirty_pages(), reason);
 }
 EXPORT_SYMBOL(writeback_inodes_sb);
 
@@ -1248,11 +1269,11 @@ EXPORT_SYMBOL(writeback_inodes_sb);
  * Invoke writeback_inodes_sb if no writeback is currently underway.
  * Returns 1 if writeback was started, 0 if not.
  */
-int writeback_inodes_sb_if_idle(struct super_block *sb)
+int writeback_inodes_sb_if_idle(struct super_block *sb, enum wb_reason reason)
 {
 	if (!writeback_in_progress(sb->s_bdi)) {
 		down_read(&sb->s_umount);
-		writeback_inodes_sb(sb);
+		writeback_inodes_sb(sb, reason);
 		up_read(&sb->s_umount);
 		return 1;
 	} else
@@ -1269,11 +1290,12 @@ EXPORT_SYMBOL(writeback_inodes_sb_if_idl
  * Returns 1 if writeback was started, 0 if not.
  */
 int writeback_inodes_sb_nr_if_idle(struct super_block *sb,
-				   unsigned long nr)
+				   unsigned long nr,
+				   enum wb_reason reason)
 {
 	if (!writeback_in_progress(sb->s_bdi)) {
 		down_read(&sb->s_umount);
-		writeback_inodes_sb_nr(sb, nr);
+		writeback_inodes_sb_nr(sb, nr, reason);
 		up_read(&sb->s_umount);
 		return 1;
 	} else
@@ -1297,6 +1319,7 @@ void sync_inodes_sb(struct super_block *
 		.nr_pages	= LONG_MAX,
 		.range_cyclic	= 0,
 		.done		= &done,
+		.reason		= WB_REASON_SYNC,
 	};
 
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
--- linux-next.orig/fs/quota/quota.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/fs/quota/quota.c	2011-10-07 22:24:47.000000000 +0800
@@ -286,7 +286,7 @@ static int do_quotactl(struct super_bloc
 		/* caller already holds s_umount */
 		if (sb->s_flags & MS_RDONLY)
 			return -EROFS;
-		writeback_inodes_sb(sb);
+		writeback_inodes_sb(sb, WB_REASON_SYNC);
 		return 0;
 	default:
 		return -EINVAL;
--- linux-next.orig/fs/sync.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/fs/sync.c	2011-10-07 22:24:47.000000000 +0800
@@ -43,7 +43,7 @@ static int __sync_filesystem(struct supe
 	if (wait)
 		sync_inodes_sb(sb);
 	else
-		writeback_inodes_sb(sb);
+		writeback_inodes_sb(sb, WB_REASON_SYNC);
 
 	if (sb->s_op->sync_fs)
 		sb->s_op->sync_fs(sb, wait);
@@ -98,7 +98,7 @@ static void sync_filesystems(int wait)
  */
 SYSCALL_DEFINE0(sync)
 {
-	wakeup_flusher_threads(0);
+	wakeup_flusher_threads(0, WB_REASON_SYNC);
 	sync_filesystems(0);
 	sync_filesystems(1);
 	if (unlikely(laptop_mode))
--- linux-next.orig/fs/ubifs/budget.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/fs/ubifs/budget.c	2011-10-07 22:24:47.000000000 +0800
@@ -63,7 +63,7 @@
 static void shrink_liability(struct ubifs_info *c, int nr_to_write)
 {
 	down_read(&c->vfs_sb->s_umount);
-	writeback_inodes_sb(c->vfs_sb);
+	writeback_inodes_sb(c->vfs_sb, WB_REASON_FS_FREE_SPACE);
 	up_read(&c->vfs_sb->s_umount);
 }
 
--- linux-next.orig/include/linux/backing-dev.h	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-10-07 22:24:47.000000000 +0800
@@ -118,7 +118,8 @@ int bdi_register(struct backing_dev_info
 int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
 void bdi_unregister(struct backing_dev_info *bdi);
 int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
-void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages);
+void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
+			enum wb_reason reason);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
 int bdi_writeback_thread(void *data);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
--- linux-next.orig/include/linux/writeback.h	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-10-07 22:24:47.000000000 +0800
@@ -39,6 +39,23 @@ enum writeback_sync_modes {
 };
 
 /*
+ * why some writeback work was initiated
+ */
+enum wb_reason {
+	WB_REASON_BACKGROUND,
+	WB_REASON_TRY_TO_FREE_PAGES,
+	WB_REASON_SYNC,
+	WB_REASON_PERIODIC,
+	WB_REASON_LAPTOP_TIMER,
+	WB_REASON_FREE_MORE_MEM,
+	WB_REASON_FS_FREE_SPACE,
+	WB_REASON_FORKER_THREAD,
+
+	WB_REASON_MAX,
+};
+extern const char *wb_reason_name[];
+
+/*
  * A control structure which tells the writeback code what to do.  These are
  * always on the stack, and hence need no locking.  They are always initialised
  * in a manner such that unspecified fields are set to zero.
@@ -69,14 +86,17 @@ struct writeback_control {
  */	
 struct bdi_writeback;
 int inode_wait(void *);
-void writeback_inodes_sb(struct super_block *);
-void writeback_inodes_sb_nr(struct super_block *, unsigned long nr);
-int writeback_inodes_sb_if_idle(struct super_block *);
-int writeback_inodes_sb_nr_if_idle(struct super_block *, unsigned long nr);
+void writeback_inodes_sb(struct super_block *, enum wb_reason reason);
+void writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
+							enum wb_reason reason);
+int writeback_inodes_sb_if_idle(struct super_block *, enum wb_reason reason);
+int writeback_inodes_sb_nr_if_idle(struct super_block *, unsigned long nr,
+							enum wb_reason reason);
 void sync_inodes_sb(struct super_block *);
-long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages);
+long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
+				enum wb_reason reason);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
-void wakeup_flusher_threads(long nr_pages);
+void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
--- linux-next.orig/include/trace/events/writeback.h	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-10-07 22:24:47.000000000 +0800
@@ -34,6 +34,7 @@ DECLARE_EVENT_CLASS(writeback_work_class
 		__field(int, for_kupdate)
 		__field(int, range_cyclic)
 		__field(int, for_background)
+		__field(int, reason)
 	),
 	TP_fast_assign(
 		strncpy(__entry->name, dev_name(bdi->dev), 32);
@@ -43,16 +44,18 @@ DECLARE_EVENT_CLASS(writeback_work_class
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
+		  wb_reason_name[__entry->reason]
 	)
 );
 #define DEFINE_WRITEBACK_WORK_EVENT(name) \
@@ -165,6 +168,7 @@ TRACE_EVENT(writeback_queue_io,
 		__field(unsigned long,	older)
 		__field(long,		age)
 		__field(int,		moved)
+		__field(int,		reason)
 	),
 	TP_fast_assign(
 		unsigned long *older_than_this = work->older_than_this;
@@ -173,12 +177,14 @@ TRACE_EVENT(writeback_queue_io,
 		__entry->age	= older_than_this ?
 				  (jiffies - *older_than_this) * 1000 / HZ : -1;
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
+		wb_reason_name[__entry->reason])
 );
 
 TRACE_EVENT(global_dirty_state,
--- linux-next.orig/mm/backing-dev.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-10-07 22:24:47.000000000 +0800
@@ -476,7 +476,8 @@ static int bdi_forker_thread(void *ptr)
 				 * the bdi from the thread. Hopefully 1024 is
 				 * large enough for efficient IO.
 				 */
-				writeback_inodes_wb(&bdi->wb, 1024);
+				writeback_inodes_wb(&bdi->wb, 1024,
+						    WB_REASON_FORKER_THREAD);
 			} else {
 				/*
 				 * The spinlock makes sure we do not lose
--- linux-next.orig/mm/page-writeback.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-07 22:24:47.000000000 +0800
@@ -1304,7 +1304,8 @@ void laptop_mode_timer_fn(unsigned long 
 	 * threshold
 	 */
 	if (bdi_has_dirty_io(&q->backing_dev_info))
-		bdi_start_writeback(&q->backing_dev_info, nr_pages);
+		bdi_start_writeback(&q->backing_dev_info, nr_pages,
+					WB_REASON_LAPTOP_TIMER);
 }
 
 /*
--- linux-next.orig/mm/vmscan.c	2011-10-07 22:23:35.000000000 +0800
+++ linux-next/mm/vmscan.c	2011-10-07 22:24:47.000000000 +0800
@@ -2181,7 +2181,8 @@ static unsigned long do_try_to_free_page
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
+			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
+						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
