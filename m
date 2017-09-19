Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5806B0260
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 15:53:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so914721pff.6
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 12:53:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d89sor1096455pfb.128.2017.09.19.12.53.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 12:53:23 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 5/6] fs-writeback: move nr_pages == 0 logic to one location
Date: Tue, 19 Sep 2017 13:53:06 -0600
Message-Id: <1505850787-18311-6-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

Now that we have no external callers of wb_start_writeback(),
we can move the nr_pages == 0 logic into that function.

Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 fs/fs-writeback.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 7564347914f8..a9a86644cb9f 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -933,6 +933,17 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
+/*
+ * Add in the number of potentially dirty inodes, because each inode
+ * write can dirty pagecache in the underlying blockdev.
+ */
+static unsigned long get_nr_dirty_pages(void)
+{
+	return global_node_page_state(NR_FILE_DIRTY) +
+		global_node_page_state(NR_UNSTABLE_NFS) +
+		get_nr_dirty_inodes();
+}
+
 static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 			       bool range_cyclic, enum wb_reason reason)
 {
@@ -942,6 +953,12 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 		return;
 
 	/*
+	 * If someone asked for zero pages, we write out the WORLD
+	 */
+	if (!nr_pages)
+		nr_pages = get_nr_dirty_pages();
+
+	/*
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
@@ -1814,17 +1831,6 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
 	return work;
 }
 
-/*
- * Add in the number of potentially dirty inodes, because each inode
- * write can dirty pagecache in the underlying blockdev.
- */
-static unsigned long get_nr_dirty_pages(void)
-{
-	return global_node_page_state(NR_FILE_DIRTY) +
-		global_node_page_state(NR_UNSTABLE_NFS) +
-		get_nr_dirty_inodes();
-}
-
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
 	if (wb_over_bg_thresh(wb)) {
@@ -1966,9 +1972,6 @@ static void __wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
 void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi, long nr_pages,
 				enum wb_reason reason)
 {
-	if (!nr_pages)
-		nr_pages = get_nr_dirty_pages();
-
 	rcu_read_lock();
 	__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
 	rcu_read_unlock();
@@ -1988,9 +1991,6 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 	if (blk_needs_flush_plug(current))
 		blk_schedule_flush_plug(current);
 
-	if (!nr_pages)
-		nr_pages = get_nr_dirty_pages();
-
 	rcu_read_lock();
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
 		__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
