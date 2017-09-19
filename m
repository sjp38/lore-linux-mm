Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 882616B0253
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 15:53:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a7so933046pfj.3
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 12:53:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y1sor1070871pgq.312.2017.09.19.12.53.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 12:53:17 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 2/6] fs-writeback: provide a wakeup_flusher_threads_bdi()
Date: Tue, 19 Sep 2017 13:53:03 -0600
Message-Id: <1505850787-18311-3-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

Similar to wakeup_flusher_threads(), except that we only wake
up the flusher threads on the specified backing device.

No functional changes in this patch.

Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 fs/fs-writeback.c         | 40 ++++++++++++++++++++++++++++++----------
 include/linux/writeback.h |  2 ++
 2 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 245c430a2e41..03fda0830bf8 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1947,6 +1947,34 @@ void wb_workfn(struct work_struct *work)
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
+void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi, long nr_pages,
+				enum wb_reason reason)
+{
+	if (!nr_pages)
+		nr_pages = get_nr_dirty_pages();
+
+	rcu_read_lock();
+	__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
+	rcu_read_unlock();
+}
+
+/*
  * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
  * the whole world.
  */
@@ -1964,16 +1992,8 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
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
index d5815794416c..5a7ed74d1f6f 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -190,6 +190,8 @@ bool try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 				   enum wb_reason reason);
 void sync_inodes_sb(struct super_block *);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
+void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi, long nr_pages,
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
