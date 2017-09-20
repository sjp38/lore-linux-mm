Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3099C6B0266
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:33:25 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k101so4853773iod.1
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:33:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i185sor2405336ita.92.2017.09.20.08.33.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:33:24 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 3/7] fs-writeback: provide a wakeup_flusher_threads_bdi()
Date: Wed, 20 Sep 2017 09:32:58 -0600
Message-Id: <1505921582-26709-4-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

Similar to wakeup_flusher_threads(), except that we only wake
up the flusher threads on the specified backing device.

No functional changes in this patch.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Tested-by: Chris Mason <clm@fb.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 fs/fs-writeback.c         | 39 +++++++++++++++++++++++++++++----------
 include/linux/writeback.h |  2 ++
 2 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index bb6148dc6d24..c7f99fd2c7f0 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1947,6 +1947,33 @@ void wb_workfn(struct work_struct *work)
 }
 
 /*
+ * Start writeback of `nr_pages' pages on this bdi. If `nr_pages' is zero,
+ * write back the whole world.
+ */
+static void __wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
+					 long nr_pages, enum wb_reason reason)
+{
+	struct bdi_writeback *wb;
+
+	if (!bdi_has_dirty_io(bdi))
+		return;
+
+	list_for_each_entry_rcu(wb, &bdi->wb_list, bdi_node)
+		wb_start_writeback(wb, wb_split_bdi_pages(wb, nr_pages),
+					   false, reason);
+}
+
+void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
+				enum wb_reason reason)
+{
+	long nr_pages = get_nr_dirty_pages();
+
+	rcu_read_lock();
+	__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
+	rcu_read_unlock();
+}
+
+/*
  * Wakeup the flusher threads to start writeback of all currently dirty pages
  */
 void wakeup_flusher_threads(enum wb_reason reason)
@@ -1963,16 +1990,8 @@ void wakeup_flusher_threads(enum wb_reason reason)
 	nr_pages = get_nr_dirty_pages();
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
-		struct bdi_writeback *wb;
-
-		if (!bdi_has_dirty_io(bdi))
-			continue;
-
-		list_for_each_entry_rcu(wb, &bdi->wb_list, bdi_node)
-			wb_start_writeback(wb, wb_split_bdi_pages(wb, nr_pages),
-					   false, reason);
-	}
+	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
+		__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
 	rcu_read_unlock();
 }
 
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 1f9c6db5e29a..9c0091678af4 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -190,6 +190,8 @@ bool try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 				   enum wb_reason reason);
 void sync_inodes_sb(struct super_block *);
 void wakeup_flusher_threads(enum wb_reason reason);
+void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
+				enum wb_reason reason);
 void inode_wait_for_writeback(struct inode *inode);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
