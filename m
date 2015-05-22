Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 07EA8829F2
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:47 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so22257226qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:46 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id r10si3697379qkh.86.2015.05.22.14.15.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:45 -0700 (PDT)
Received: by qgfa63 with SMTP id a63so16287055qgf.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:45 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 46/51] writeback: restructure try_writeback_inodes_sb[_nr]()
Date: Fri, 22 May 2015 17:14:00 -0400
Message-Id: <1432329245-5844-47-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

try_writeback_inodes_sb_nr() wraps writeback_inodes_sb_nr() so that it
handles s_umount locking and skips if writeback is already in
progress.  The in progress test is performed on the root wb
(bdi_writeback) which isn't sufficient for cgroup writeback support.
The test must be done per-wb.

To prepare for the change, this patch factors out
__writeback_inodes_sb_nr() from writeback_inodes_sb_nr() and adds
@skip_if_busy and moves the in progress test right before queueing the
wb_writeback_work.  try_writeback_inodes_sb_nr() now just grabs
s_umount and invokes __writeback_inodes_sb_nr() with asserted
@skip_if_busy.  This way, later addition of multiple wb handling can
skip only the wb's which already have writeback in progress.

This swaps the order between in progress test and s_umount test which
can flip the return value when writeback is in progress and s_umount
is being held by someone else but this shouldn't cause any meaningful
difference.  It's a fringe condition and the return value is an
unsynchronized hint anyway.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c         | 52 ++++++++++++++++++++++++++---------------------
 include/linux/writeback.h |  6 +++---
 2 files changed, 32 insertions(+), 26 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 093b959..0039c58 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1581,19 +1581,8 @@ static void wait_sb_inodes(struct super_block *sb)
 	iput(old_inode);
 }
 
-/**
- * writeback_inodes_sb_nr -	writeback dirty inodes from given super_block
- * @sb: the superblock
- * @nr: the number of pages to write
- * @reason: reason why some writeback work initiated
- *
- * Start writeback on some inodes on this super_block. No guarantees are made
- * on how many (if any) will be written, and this function does not wait
- * for IO completion of submitted IO.
- */
-void writeback_inodes_sb_nr(struct super_block *sb,
-			    unsigned long nr,
-			    enum wb_reason reason)
+static void __writeback_inodes_sb_nr(struct super_block *sb, unsigned long nr,
+				     enum wb_reason reason, bool skip_if_busy)
 {
 	DEFINE_WB_COMPLETION_ONSTACK(done);
 	struct wb_writeback_work work = {
@@ -1609,9 +1598,30 @@ void writeback_inodes_sb_nr(struct super_block *sb,
 	if (!bdi_has_dirty_io(bdi) || bdi == &noop_backing_dev_info)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
+
+	if (skip_if_busy && writeback_in_progress(&bdi->wb))
+		return;
+
 	wb_queue_work(&bdi->wb, &work);
 	wb_wait_for_completion(bdi, &done);
 }
+
+/**
+ * writeback_inodes_sb_nr -	writeback dirty inodes from given super_block
+ * @sb: the superblock
+ * @nr: the number of pages to write
+ * @reason: reason why some writeback work initiated
+ *
+ * Start writeback on some inodes on this super_block. No guarantees are made
+ * on how many (if any) will be written, and this function does not wait
+ * for IO completion of submitted IO.
+ */
+void writeback_inodes_sb_nr(struct super_block *sb,
+			    unsigned long nr,
+			    enum wb_reason reason)
+{
+	__writeback_inodes_sb_nr(sb, nr, reason, false);
+}
 EXPORT_SYMBOL(writeback_inodes_sb_nr);
 
 /**
@@ -1638,19 +1648,15 @@ EXPORT_SYMBOL(writeback_inodes_sb);
  * Invoke writeback_inodes_sb_nr if no writeback is currently underway.
  * Returns 1 if writeback was started, 0 if not.
  */
-int try_to_writeback_inodes_sb_nr(struct super_block *sb,
-				  unsigned long nr,
-				  enum wb_reason reason)
+bool try_to_writeback_inodes_sb_nr(struct super_block *sb, unsigned long nr,
+				   enum wb_reason reason)
 {
-	if (writeback_in_progress(&sb->s_bdi->wb))
-		return 1;
-
 	if (!down_read_trylock(&sb->s_umount))
-		return 0;
+		return false;
 
-	writeback_inodes_sb_nr(sb, nr, reason);
+	__writeback_inodes_sb_nr(sb, nr, reason, true);
 	up_read(&sb->s_umount);
-	return 1;
+	return true;
 }
 EXPORT_SYMBOL(try_to_writeback_inodes_sb_nr);
 
@@ -1662,7 +1668,7 @@ EXPORT_SYMBOL(try_to_writeback_inodes_sb_nr);
  * Implement by try_to_writeback_inodes_sb_nr()
  * Returns 1 if writeback was started, 0 if not.
  */
-int try_to_writeback_inodes_sb(struct super_block *sb, enum wb_reason reason)
+bool try_to_writeback_inodes_sb(struct super_block *sb, enum wb_reason reason)
 {
 	return try_to_writeback_inodes_sb_nr(sb, get_nr_dirty_pages(), reason);
 }
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index a6b9db7..23af355 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -93,9 +93,9 @@ struct bdi_writeback;
 void writeback_inodes_sb(struct super_block *, enum wb_reason reason);
 void writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 							enum wb_reason reason);
-int try_to_writeback_inodes_sb(struct super_block *, enum wb_reason reason);
-int try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
-				  enum wb_reason reason);
+bool try_to_writeback_inodes_sb(struct super_block *, enum wb_reason reason);
+bool try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
+				   enum wb_reason reason);
 void sync_inodes_sb(struct super_block *);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
 void inode_wait_for_writeback(struct inode *inode);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
