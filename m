Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id A7BBF6B0085
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:55:42 -0400 (EDT)
Received: by qgez102 with SMTP id z102so48338632qge.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:42 -0700 (PDT)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com. [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id d91si3604765qga.94.2015.03.22.21.55.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:35 -0700 (PDT)
Received: by qcto4 with SMTP id o4so136677284qct.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:35 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 15/48] writeback: reorganize mm/backing-dev.c
Date: Mon, 23 Mar 2015 00:54:26 -0400
Message-Id: <1427086499-15657-16-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Move wb_shutdown(), bdi_register(), bdi_register_dev(),
bdi_prune_sb(), bdi_remove_from_list() and bdi_unregister() so that
init / exit functions are grouped together.  This will make updating
init / exit paths for cgroup writeback support easier.

This is pure source file reorganization.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/backing-dev.c | 174 +++++++++++++++++++++++++++----------------------------
 1 file changed, 87 insertions(+), 87 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 597f0ce..ff85ecb 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -286,93 +286,6 @@ void wb_wakeup_delayed(struct bdi_writeback *wb)
 }
 
 /*
- * Remove bdi from bdi_list, and ensure that it is no longer visible
- */
-static void bdi_remove_from_list(struct backing_dev_info *bdi)
-{
-	spin_lock_bh(&bdi_lock);
-	list_del_rcu(&bdi->bdi_list);
-	spin_unlock_bh(&bdi_lock);
-
-	synchronize_rcu_expedited();
-}
-
-int bdi_register(struct backing_dev_info *bdi, struct device *parent,
-		const char *fmt, ...)
-{
-	va_list args;
-	struct device *dev;
-
-	if (bdi->dev)	/* The driver needs to use separate queues per device */
-		return 0;
-
-	va_start(args, fmt);
-	dev = device_create_vargs(bdi_class, parent, MKDEV(0, 0), bdi, fmt, args);
-	va_end(args);
-	if (IS_ERR(dev))
-		return PTR_ERR(dev);
-
-	bdi->dev = dev;
-
-	bdi_debug_register(bdi, dev_name(dev));
-	set_bit(WB_registered, &bdi->wb.state);
-
-	spin_lock_bh(&bdi_lock);
-	list_add_tail_rcu(&bdi->bdi_list, &bdi_list);
-	spin_unlock_bh(&bdi_lock);
-
-	trace_writeback_bdi_register(bdi);
-	return 0;
-}
-EXPORT_SYMBOL(bdi_register);
-
-int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev)
-{
-	return bdi_register(bdi, NULL, "%u:%u", MAJOR(dev), MINOR(dev));
-}
-EXPORT_SYMBOL(bdi_register_dev);
-
-/*
- * Remove bdi from the global list and shutdown any threads we have running
- */
-static void wb_shutdown(struct bdi_writeback *wb)
-{
-	/* Make sure nobody queues further work */
-	spin_lock_bh(&wb->work_lock);
-	if (!test_and_clear_bit(WB_registered, &wb->state)) {
-		spin_unlock_bh(&wb->work_lock);
-		return;
-	}
-	spin_unlock_bh(&wb->work_lock);
-
-	/*
-	 * Drain work list and shutdown the delayed_work.  !WB_registered
-	 * tells wb_workfn() that @wb is dying and its work_list needs to
-	 * be drained no matter what.
-	 */
-	mod_delayed_work(bdi_wq, &wb->dwork, 0);
-	flush_delayed_work(&wb->dwork);
-	WARN_ON(!list_empty(&wb->work_list));
-}
-
-/*
- * Called when the device behind @bdi has been removed or ejected.
- *
- * We can't really do much here except for reducing the dirty ratio at
- * the moment.  In the future we should be able to set a flag so that
- * the filesystem can handle errors at mark_inode_dirty time instead
- * of only at writeback time.
- */
-void bdi_unregister(struct backing_dev_info *bdi)
-{
-	if (WARN_ON_ONCE(!bdi->dev))
-		return;
-
-	bdi_set_min_ratio(bdi, 0);
-}
-EXPORT_SYMBOL(bdi_unregister);
-
-/*
  * Initial write bandwidth: 100 MB/s
  */
 #define INIT_BW		(100 << (20 - PAGE_SHIFT))
@@ -418,6 +331,29 @@ static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
 	return 0;
 }
 
+/*
+ * Remove bdi from the global list and shutdown any threads we have running
+ */
+static void wb_shutdown(struct bdi_writeback *wb)
+{
+	/* Make sure nobody queues further work */
+	spin_lock_bh(&wb->work_lock);
+	if (!test_and_clear_bit(WB_registered, &wb->state)) {
+		spin_unlock_bh(&wb->work_lock);
+		return;
+	}
+	spin_unlock_bh(&wb->work_lock);
+
+	/*
+	 * Drain work list and shutdown the delayed_work.  !WB_registered
+	 * tells wb_workfn() that @wb is dying and its work_list needs to
+	 * be drained no matter what.
+	 */
+	mod_delayed_work(bdi_wq, &wb->dwork, 0);
+	flush_delayed_work(&wb->dwork);
+	WARN_ON(!list_empty(&wb->work_list));
+}
+
 static void wb_exit(struct bdi_writeback *wb)
 {
 	int i;
@@ -449,6 +385,70 @@ int bdi_init(struct backing_dev_info *bdi)
 }
 EXPORT_SYMBOL(bdi_init);
 
+int bdi_register(struct backing_dev_info *bdi, struct device *parent,
+		const char *fmt, ...)
+{
+	va_list args;
+	struct device *dev;
+
+	if (bdi->dev)	/* The driver needs to use separate queues per device */
+		return 0;
+
+	va_start(args, fmt);
+	dev = device_create_vargs(bdi_class, parent, MKDEV(0, 0), bdi, fmt, args);
+	va_end(args);
+	if (IS_ERR(dev))
+		return PTR_ERR(dev);
+
+	bdi->dev = dev;
+
+	bdi_debug_register(bdi, dev_name(dev));
+	set_bit(WB_registered, &bdi->wb.state);
+
+	spin_lock_bh(&bdi_lock);
+	list_add_tail_rcu(&bdi->bdi_list, &bdi_list);
+	spin_unlock_bh(&bdi_lock);
+
+	trace_writeback_bdi_register(bdi);
+	return 0;
+}
+EXPORT_SYMBOL(bdi_register);
+
+int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev)
+{
+	return bdi_register(bdi, NULL, "%u:%u", MAJOR(dev), MINOR(dev));
+}
+EXPORT_SYMBOL(bdi_register_dev);
+
+/*
+ * Remove bdi from bdi_list, and ensure that it is no longer visible
+ */
+static void bdi_remove_from_list(struct backing_dev_info *bdi)
+{
+	spin_lock_bh(&bdi_lock);
+	list_del_rcu(&bdi->bdi_list);
+	spin_unlock_bh(&bdi_lock);
+
+	synchronize_rcu_expedited();
+}
+
+/*
+ * Called when the device behind @bdi has been removed or ejected.
+ *
+ * We can't really do much here except for reducing the dirty ratio at
+ * the moment.  In the future we should be able to set a flag so that
+ * the filesystem can handle errors at mark_inode_dirty time instead
+ * of only at writeback time.
+ */
+void bdi_unregister(struct backing_dev_info *bdi)
+{
+	if (WARN_ON_ONCE(!bdi->dev))
+		return;
+
+	bdi_set_min_ratio(bdi, 0);
+}
+EXPORT_SYMBOL(bdi_unregister);
+
 void bdi_destroy(struct backing_dev_info *bdi)
 {
 	/* make sure nobody finds us on the bdi_list anymore */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
