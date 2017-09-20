Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC3866B0261
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:33:22 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g32so4865878ioj.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:33:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i85sor702839ioa.223.2017.09.20.08.33.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:33:21 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 2/7] fs: kill 'nr_pages' argument from wakeup_flusher_threads()
Date: Wed, 20 Sep 2017 09:32:57 -0600
Message-Id: <1505921582-26709-3-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

Everybody is passing in 0 now, let's get rid of the argument.

Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 fs/buffer.c               | 2 +-
 fs/fs-writeback.c         | 9 ++++-----
 fs/sync.c                 | 2 +-
 include/linux/writeback.h | 2 +-
 mm/vmscan.c               | 2 +-
 5 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 9471a445e370..cf71926797d3 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -260,7 +260,7 @@ static void free_more_memory(void)
 	struct zoneref *z;
 	int nid;
 
-	wakeup_flusher_threads(0, WB_REASON_FREE_MORE_MEM);
+	wakeup_flusher_threads(WB_REASON_FREE_MORE_MEM);
 	yield();
 
 	for_each_online_node(nid) {
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 245c430a2e41..bb6148dc6d24 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1947,12 +1947,12 @@ void wb_workfn(struct work_struct *work)
 }
 
 /*
- * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
- * the whole world.
+ * Wakeup the flusher threads to start writeback of all currently dirty pages
  */
-void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
+void wakeup_flusher_threads(enum wb_reason reason)
 {
 	struct backing_dev_info *bdi;
+	long nr_pages;
 
 	/*
 	 * If we are expecting writeback progress we must submit plugged IO.
@@ -1960,8 +1960,7 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 	if (blk_needs_flush_plug(current))
 		blk_schedule_flush_plug(current);
 
-	if (!nr_pages)
-		nr_pages = get_nr_dirty_pages();
+	nr_pages = get_nr_dirty_pages();
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
diff --git a/fs/sync.c b/fs/sync.c
index a576aa2e6b09..09f96a18dd93 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -108,7 +108,7 @@ SYSCALL_DEFINE0(sync)
 {
 	int nowait = 0, wait = 1;
 
-	wakeup_flusher_threads(0, WB_REASON_SYNC);
+	wakeup_flusher_threads(WB_REASON_SYNC);
 	iterate_supers(sync_inodes_one_sb, NULL);
 	iterate_supers(sync_fs_one_sb, &nowait);
 	iterate_supers(sync_fs_one_sb, &wait);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index d5815794416c..1f9c6db5e29a 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -189,7 +189,7 @@ bool try_to_writeback_inodes_sb(struct super_block *, enum wb_reason reason);
 bool try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 				   enum wb_reason reason);
 void sync_inodes_sb(struct super_block *);
-void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
+void wakeup_flusher_threads(enum wb_reason reason);
 void inode_wait_for_writeback(struct inode *inode);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 13d711dd8776..42a7fdd52d87 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1867,7 +1867,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * also allow kswapd to start writing pages during reclaim.
 		 */
 		if (stat.nr_unqueued_dirty == nr_taken) {
-			wakeup_flusher_threads(0, WB_REASON_VMSCAN);
+			wakeup_flusher_threads(WB_REASON_VMSCAN);
 			set_bit(PGDAT_DIRTY, &pgdat->flags);
 		}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
