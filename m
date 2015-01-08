Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E47C76B0080
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 12:46:54 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so3945437wgg.10
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 09:46:53 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id hw9si13431016wjb.136.2015.01.08.09.46.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 09:46:39 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/12] fs: don't reassign dirty inodes to default_backing_dev_info
Date: Thu,  8 Jan 2015 18:45:32 +0100
Message-Id: <1420739133-27514-12-git-send-email-hch@lst.de>
In-Reply-To: <1420739133-27514-1-git-send-email-hch@lst.de>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

If we have dirty inodes we need to call the filesystem for it, even if the
device has been removed and the filesystem will error out early.  The
current code does that by reassining all dirty inodes to the default
backing_dev_info when a bdi is unlinked, but that's pretty pointless given
that the bdi must always outlive the super block.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/backing-dev.c | 91 +++++++++++++++-----------------------------------------
 1 file changed, 24 insertions(+), 67 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 52e0c76..3ebba25 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -37,17 +37,6 @@ LIST_HEAD(bdi_list);
 /* bdi_wq serves all asynchronous writeback tasks */
 struct workqueue_struct *bdi_wq;
 
-static void bdi_lock_two(struct bdi_writeback *wb1, struct bdi_writeback *wb2)
-{
-	if (wb1 < wb2) {
-		spin_lock(&wb1->list_lock);
-		spin_lock_nested(&wb2->list_lock, 1);
-	} else {
-		spin_lock(&wb2->list_lock);
-		spin_lock_nested(&wb1->list_lock, 1);
-	}
-}
-
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
@@ -352,19 +341,19 @@ EXPORT_SYMBOL(bdi_register_dev);
  */
 static void bdi_wb_shutdown(struct backing_dev_info *bdi)
 {
-	if (!bdi_cap_writeback_dirty(bdi))
+	/* Make sure nobody queues further work */
+	spin_lock_bh(&bdi->wb_lock);
+	if (!test_and_clear_bit(BDI_registered, &bdi->state)) {
+		spin_unlock_bh(&bdi->wb_lock);
 		return;
+	}
+	spin_unlock_bh(&bdi->wb_lock);
 
 	/*
 	 * Make sure nobody finds us on the bdi_list anymore
 	 */
 	bdi_remove_from_list(bdi);
 
-	/* Make sure nobody queues further work */
-	spin_lock_bh(&bdi->wb_lock);
-	clear_bit(BDI_registered, &bdi->state);
-	spin_unlock_bh(&bdi->wb_lock);
-
 	/*
 	 * Drain work list and shutdown the delayed_work.  At this point,
 	 * @bdi->bdi_list is empty telling bdi_Writeback_workfn() that @bdi
@@ -372,37 +361,22 @@ static void bdi_wb_shutdown(struct backing_dev_info *bdi)
 	 */
 	mod_delayed_work(bdi_wq, &bdi->wb.dwork, 0);
 	flush_delayed_work(&bdi->wb.dwork);
-	WARN_ON(!list_empty(&bdi->work_list));
-	WARN_ON(delayed_work_pending(&bdi->wb.dwork));
 }
 
 /*
- * This bdi is going away now, make sure that no super_blocks point to it
+ * Called when the device behind @bdi has been removed or ejected.
+ *
+ * We can't really do much here except for reducing the dirty ratio at
+ * the moment.  In the future we should be able to set a flag so that
+ * the filesystem can handle errors at mark_inode_dirty time instead
+ * of only at writeback time.
  */
-static void bdi_prune_sb(struct backing_dev_info *bdi)
-{
-	struct super_block *sb;
-
-	spin_lock(&sb_lock);
-	list_for_each_entry(sb, &super_blocks, s_list) {
-		if (sb->s_bdi == bdi)
-			sb->s_bdi = &default_backing_dev_info;
-	}
-	spin_unlock(&sb_lock);
-}
-
 void bdi_unregister(struct backing_dev_info *bdi)
 {
-	if (bdi->dev) {
-		bdi_set_min_ratio(bdi, 0);
-		trace_writeback_bdi_unregister(bdi);
-		bdi_prune_sb(bdi);
+	if (WARN_ON_ONCE(!bdi->dev))
+		return;
 
-		bdi_wb_shutdown(bdi);
-		bdi_debug_unregister(bdi);
-		device_unregister(bdi->dev);
-		bdi->dev = NULL;
-	}
+	bdi_set_min_ratio(bdi, 0);
 }
 EXPORT_SYMBOL(bdi_unregister);
 
@@ -471,37 +445,20 @@ void bdi_destroy(struct backing_dev_info *bdi)
 {
 	int i;
 
-	/*
-	 * Splice our entries to the default_backing_dev_info.  This
-	 * condition shouldn't happen.  @wb must be empty at this point and
-	 * dirty inodes on it might cause other issues.  This workaround is
-	 * added by ce5f8e779519 ("writeback: splice dirty inode entries to
-	 * default bdi on bdi_destroy()") without root-causing the issue.
-	 *
-	 * http://lkml.kernel.org/g/1253038617-30204-11-git-send-email-jens.axboe@oracle.com
-	 * http://thread.gmane.org/gmane.linux.file-systems/35341/focus=35350
-	 *
-	 * We should probably add WARN_ON() to find out whether it still
-	 * happens and track it down if so.
-	 */
-	if (bdi_has_dirty_io(bdi)) {
-		struct bdi_writeback *dst = &default_backing_dev_info.wb;
-
-		bdi_lock_two(&bdi->wb, dst);
-		list_splice(&bdi->wb.b_dirty, &dst->b_dirty);
-		list_splice(&bdi->wb.b_io, &dst->b_io);
-		list_splice(&bdi->wb.b_more_io, &dst->b_more_io);
-		spin_unlock(&bdi->wb.list_lock);
-		spin_unlock(&dst->list_lock);
-	}
-
-	bdi_unregister(bdi);
+	bdi_wb_shutdown(bdi);
 
+	WARN_ON(!list_empty(&bdi->work_list));
+	WARN_ON(delayed_work_pending(&bdi->wb.dwork));
 	WARN_ON(delayed_work_pending(&bdi->wb.dwork));
 
+	if (bdi->dev) {
+		bdi_debug_unregister(bdi);
+		device_unregister(bdi->dev);
+		bdi->dev = NULL;
+	}
+
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
-
 	fprop_local_destroy_percpu(&bdi->completions);
 }
 EXPORT_SYMBOL(bdi_destroy);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
