Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id DF2BD6B00D1
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:00:36 -0400 (EDT)
Received: by qku63 with SMTP id 63so30996088qku.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:36 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id 40si5155182qkp.55.2015.04.06.13.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:00:33 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so31098456qkg.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:33 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 42/49] writeback: implement bdi_wait_for_completion()
Date: Mon,  6 Apr 2015 15:58:31 -0400
Message-Id: <1428350318-8215-43-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

If the completion of a wb_writeback_work can be waited upon by setting
its ->done to a struct completion and waiting on it; however, for
cgroup writeback support, it's necessary to issue multiple work items
to multiple bdi_writebacks and wait for the completion of all.

This patch implements wb_completion which can wait for multiple work
items and replaces the struct completion with it.  It can be defined
using DEFINE_WB_COMPLETION_ONSTACK(), used for multiple work items and
waited for by wb_wait_for_completion().

Nobody currently issues multiple work items and this patch doesn't
introduce any behavior changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 57 +++++++++++++++++++++++++++++++---------
 include/linux/backing-dev-defs.h |  2 ++
 mm/backing-dev.c                 |  1 +
 3 files changed, 48 insertions(+), 12 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 306229a..faa9272 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -34,6 +34,10 @@
  */
 #define MIN_WRITEBACK_PAGES	(4096UL >> (PAGE_CACHE_SHIFT - 10))
 
+struct wb_completion {
+	atomic_t		cnt;
+};
+
 /*
  * Passed into wb_writeback(), essentially a subset of writeback_control
  */
@@ -51,9 +55,21 @@ struct wb_writeback_work {
 	enum wb_reason reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
-	struct completion *done;	/* set if the caller waits */
+	struct wb_completion *done;	/* set if the caller waits */
 };
 
+/*
+ * If one wants to wait for one or more wb_writeback_works, each work's
+ * ->done should be set to a wb_completion defined using the following
+ * macro.  Once all work items are issued with wb_queue_work(), the caller
+ * can wait for the completion of all using wb_wait_for_completion().  Work
+ * items which are waited upon aren't freed automatically on completion.
+ */
+#define DEFINE_WB_COMPLETION_ONSTACK(cmpl)				\
+	struct wb_completion cmpl = {					\
+		.cnt		= ATOMIC_INIT(1),			\
+	}
+
 static inline struct inode *wb_inode(struct list_head *head)
 {
 	return list_entry(head, struct inode, i_wb_list);
@@ -149,17 +165,34 @@ static void wb_queue_work(struct bdi_writeback *wb,
 	trace_writeback_queue(wb->bdi, work);
 
 	spin_lock_bh(&wb->work_lock);
-	if (!test_bit(WB_registered, &wb->state)) {
-		if (work->done)
-			complete(work->done);
+	if (!test_bit(WB_registered, &wb->state))
 		goto out_unlock;
-	}
+	if (work->done)
+		atomic_inc(&work->done->cnt);
 	list_add_tail(&work->list, &wb->work_list);
 	mod_delayed_work(bdi_wq, &wb->dwork, 0);
 out_unlock:
 	spin_unlock_bh(&wb->work_lock);
 }
 
+/**
+ * wb_wait_for_completion - wait for completion of bdi_writeback_works
+ * @bdi: bdi work items were issued to
+ * @done: target wb_completion
+ *
+ * Wait for one or more work items issued to @bdi with their ->done field
+ * set to @done, which should have been defined with
+ * DEFINE_WB_COMPLETION_ONSTACK().  This function returns after all such
+ * work items are completed.  Work items which are waited upon aren't freed
+ * automatically on completion.
+ */
+static void wb_wait_for_completion(struct backing_dev_info *bdi,
+				   struct wb_completion *done)
+{
+	atomic_dec(&done->cnt);		/* put down the initial count */
+	wait_event(bdi->wb_waitq, !atomic_read(&done->cnt));
+}
+
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 /**
@@ -1125,7 +1158,7 @@ static long wb_do_writeback(struct bdi_writeback *wb)
 
 	set_bit(WB_writeback_running, &wb->state);
 	while ((work = get_next_work_item(wb)) != NULL) {
-		struct completion *done = work->done;
+		struct wb_completion *done = work->done;
 
 		trace_writeback_exec(wb->bdi, work);
 
@@ -1133,8 +1166,8 @@ static long wb_do_writeback(struct bdi_writeback *wb)
 
 		if (work->auto_free)
 			kfree(work);
-		if (done)
-			complete(done);
+		if (done && atomic_dec_and_test(&done->cnt))
+			wake_up_all(&wb->bdi->wb_waitq);
 	}
 
 	/*
@@ -1438,7 +1471,7 @@ void writeback_inodes_sb_nr(struct super_block *sb,
 			    unsigned long nr,
 			    enum wb_reason reason)
 {
-	DECLARE_COMPLETION_ONSTACK(done);
+	DEFINE_WB_COMPLETION_ONSTACK(done);
 	struct wb_writeback_work work = {
 		.sb			= sb,
 		.sync_mode		= WB_SYNC_NONE,
@@ -1453,7 +1486,7 @@ void writeback_inodes_sb_nr(struct super_block *sb,
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 	wb_queue_work(&bdi->wb, &work);
-	wait_for_completion(&done);
+	wb_wait_for_completion(bdi, &done);
 }
 EXPORT_SYMBOL(writeback_inodes_sb_nr);
 
@@ -1520,7 +1553,7 @@ EXPORT_SYMBOL(try_to_writeback_inodes_sb);
  */
 void sync_inodes_sb(struct super_block *sb)
 {
-	DECLARE_COMPLETION_ONSTACK(done);
+	DEFINE_WB_COMPLETION_ONSTACK(done);
 	struct wb_writeback_work work = {
 		.sb		= sb,
 		.sync_mode	= WB_SYNC_ALL,
@@ -1538,7 +1571,7 @@ void sync_inodes_sb(struct super_block *sb)
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
 	wb_queue_work(&bdi->wb, &work);
-	wait_for_completion(&done);
+	wb_wait_for_completion(bdi, &done);
 
 	wait_sb_inodes(sb);
 }
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 8c857d7..97a92fa 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -155,6 +155,8 @@ struct backing_dev_info {
 	struct rb_root cgwb_congested_tree; /* their congested states */
 	atomic_t usage_cnt; /* counts both cgwbs and cgwb_contested's */
 #endif
+	wait_queue_head_t wb_waitq;
+
 	struct device *dev;
 
 	struct timer_list laptop_mode_wb_timer;
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index d2f16fc9..ad5608d 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -768,6 +768,7 @@ int bdi_init(struct backing_dev_info *bdi)
 	bdi->max_ratio = 100;
 	bdi->max_prop_frac = FPROP_FRAC_BASE;
 	INIT_LIST_HEAD(&bdi->bdi_list);
+	init_waitqueue_head(&bdi->wb_waitq);
 
 	err = wb_init(&bdi->wb, bdi, GFP_KERNEL);
 	if (err)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
