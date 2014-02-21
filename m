Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 98CE96B00BE
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 05:30:12 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so656362wgh.1
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 02:30:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ff4si7824995wjc.62.2014.02.21.02.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 02:30:11 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] Revert "writeback: do not sync data dirtied after sync start"
Date: Fri, 21 Feb 2014 11:30:01 +0100
Message-Id: <1392978601-18002-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>

This reverts commit c4a391b53a72d2df4ee97f96f78c1d5971b47489. Dave
Chinner <david@fromorbit.com> has reported the commit may cause some
inodes to be left out from sync(2). This is because we can call
redirty_tail() for some inode (which sets i_dirtied_when to current time)
after sync(2) has started or similarly requeue_inode() can set
i_dirtied_when to current time if writeback had to skip some pages. The
real problem is in the functions clobbering i_dirtied_when but fixing
that isn't trivial so revert is a safer choice for now.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 33 +++++++++++----------------------
 fs/sync.c                        | 15 ++++++---------
 fs/xfs/xfs_super.c               |  2 +-
 include/linux/writeback.h        |  2 +-
 include/trace/events/writeback.h |  6 +++---
 5 files changed, 22 insertions(+), 36 deletions(-)

I plan to send this to Linus with other fixes I have so this is mostly FYI.

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index e0259a163f98..d754e3cf99a8 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -40,18 +40,13 @@
 struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
-	/*
-	 * Write only inodes dirtied before this time. Don't forget to set
-	 * older_than_this_is_set when you set this.
-	 */
-	unsigned long older_than_this;
+	unsigned long *older_than_this;
 	enum writeback_sync_modes sync_mode;
 	unsigned int tagged_writepages:1;
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
 	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
-	unsigned int older_than_this_is_set:1;
 	enum wb_reason reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
@@ -252,10 +247,10 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 	int do_sb_sort = 0;
 	int moved = 0;
 
-	WARN_ON_ONCE(!work->older_than_this_is_set);
 	while (!list_empty(delaying_queue)) {
 		inode = wb_inode(delaying_queue->prev);
-		if (inode_dirtied_after(inode, work->older_than_this))
+		if (work->older_than_this &&
+		    inode_dirtied_after(inode, *work->older_than_this))
 			break;
 		list_move(&inode->i_wb_list, &tmp);
 		moved++;
@@ -742,8 +737,6 @@ static long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
 		.sync_mode	= WB_SYNC_NONE,
 		.range_cyclic	= 1,
 		.reason		= reason,
-		.older_than_this = jiffies,
-		.older_than_this_is_set = 1,
 	};
 
 	spin_lock(&wb->list_lock);
@@ -802,13 +795,12 @@ static long wb_writeback(struct bdi_writeback *wb,
 {
 	unsigned long wb_start = jiffies;
 	long nr_pages = work->nr_pages;
+	unsigned long oldest_jif;
 	struct inode *inode;
 	long progress;
 
-	if (!work->older_than_this_is_set) {
-		work->older_than_this = jiffies;
-		work->older_than_this_is_set = 1;
-	}
+	oldest_jif = jiffies;
+	work->older_than_this = &oldest_jif;
 
 	spin_lock(&wb->list_lock);
 	for (;;) {
@@ -842,10 +834,10 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 * safe.
 		 */
 		if (work->for_kupdate) {
-			work->older_than_this = jiffies -
+			oldest_jif = jiffies -
 				msecs_to_jiffies(dirty_expire_interval * 10);
 		} else if (work->for_background)
-			work->older_than_this = jiffies;
+			oldest_jif = jiffies;
 
 		trace_writeback_start(wb->bdi, work);
 		if (list_empty(&wb->b_io))
@@ -1357,21 +1349,18 @@ EXPORT_SYMBOL(try_to_writeback_inodes_sb);
 
 /**
  * sync_inodes_sb	-	sync sb inode pages
- * @sb:			the superblock
- * @older_than_this:	timestamp
+ * @sb: the superblock
  *
  * This function writes and waits on any dirty inode belonging to this
- * superblock that has been dirtied before given timestamp.
+ * super_block.
  */
-void sync_inodes_sb(struct super_block *sb, unsigned long older_than_this)
+void sync_inodes_sb(struct super_block *sb)
 {
 	DECLARE_COMPLETION_ONSTACK(done);
 	struct wb_writeback_work work = {
 		.sb		= sb,
 		.sync_mode	= WB_SYNC_ALL,
 		.nr_pages	= LONG_MAX,
-		.older_than_this = older_than_this,
-		.older_than_this_is_set = 1,
 		.range_cyclic	= 0,
 		.done		= &done,
 		.reason		= WB_REASON_SYNC,
diff --git a/fs/sync.c b/fs/sync.c
index e8ba024a055b..b28d1dd10e8b 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -27,11 +27,10 @@
  * wait == 1 case since in that case write_inode() functions do
  * sync_dirty_buffer() and thus effectively write one block at a time.
  */
-static int __sync_filesystem(struct super_block *sb, int wait,
-			     unsigned long start)
+static int __sync_filesystem(struct super_block *sb, int wait)
 {
 	if (wait)
-		sync_inodes_sb(sb, start);
+		sync_inodes_sb(sb);
 	else
 		writeback_inodes_sb(sb, WB_REASON_SYNC);
 
@@ -48,7 +47,6 @@ static int __sync_filesystem(struct super_block *sb, int wait,
 int sync_filesystem(struct super_block *sb)
 {
 	int ret;
-	unsigned long start = jiffies;
 
 	/*
 	 * We need to be protected against the filesystem going from
@@ -62,17 +60,17 @@ int sync_filesystem(struct super_block *sb)
 	if (sb->s_flags & MS_RDONLY)
 		return 0;
 
-	ret = __sync_filesystem(sb, 0, start);
+	ret = __sync_filesystem(sb, 0);
 	if (ret < 0)
 		return ret;
-	return __sync_filesystem(sb, 1, start);
+	return __sync_filesystem(sb, 1);
 }
 EXPORT_SYMBOL_GPL(sync_filesystem);
 
 static void sync_inodes_one_sb(struct super_block *sb, void *arg)
 {
 	if (!(sb->s_flags & MS_RDONLY))
-		sync_inodes_sb(sb, *((unsigned long *)arg));
+		sync_inodes_sb(sb);
 }
 
 static void sync_fs_one_sb(struct super_block *sb, void *arg)
@@ -104,10 +102,9 @@ static void fdatawait_one_bdev(struct block_device *bdev, void *arg)
 SYSCALL_DEFINE0(sync)
 {
 	int nowait = 0, wait = 1;
-	unsigned long start = jiffies;
 
 	wakeup_flusher_threads(0, WB_REASON_SYNC);
-	iterate_supers(sync_inodes_one_sb, &start);
+	iterate_supers(sync_inodes_one_sb, NULL);
 	iterate_supers(sync_fs_one_sb, &nowait);
 	iterate_supers(sync_fs_one_sb, &wait);
 	iterate_bdevs(fdatawrite_one_bdev, NULL);
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index f317488263dd..d971f4932b5d 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -913,7 +913,7 @@ xfs_flush_inodes(
 	struct super_block	*sb = mp->m_super;
 
 	if (down_read_trylock(&sb->s_umount)) {
-		sync_inodes_sb(sb, jiffies);
+		sync_inodes_sb(sb);
 		up_read(&sb->s_umount);
 	}
 }
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index fc0e4320aa6d..021b8a319b9e 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -97,7 +97,7 @@ void writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 int try_to_writeback_inodes_sb(struct super_block *, enum wb_reason reason);
 int try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 				  enum wb_reason reason);
-void sync_inodes_sb(struct super_block *sb, unsigned long older_than_this);
+void sync_inodes_sb(struct super_block *);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
 void inode_wait_for_writeback(struct inode *inode);
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index c7bbbe794e65..464ea82e10db 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -287,11 +287,11 @@ TRACE_EVENT(writeback_queue_io,
 		__field(int,		reason)
 	),
 	TP_fast_assign(
-		unsigned long older_than_this = work->older_than_this;
+		unsigned long *older_than_this = work->older_than_this;
 		strncpy(__entry->name, dev_name(wb->bdi->dev), 32);
-		__entry->older	= older_than_this;
+		__entry->older	= older_than_this ?  *older_than_this : 0;
 		__entry->age	= older_than_this ?
-				  (jiffies - older_than_this) * 1000 / HZ : -1;
+				  (jiffies - *older_than_this) * 1000 / HZ : -1;
 		__entry->moved	= moved;
 		__entry->reason	= work->reason;
 	),
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
