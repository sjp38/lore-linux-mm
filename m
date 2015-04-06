Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCFA6B00D2
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:00:39 -0400 (EDT)
Received: by qgej70 with SMTP id j70so14947073qge.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:38 -0700 (PDT)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com. [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id q67si5154150qgd.39.2015.04.06.13.00.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:00:35 -0700 (PDT)
Received: by qcgx3 with SMTP id x3so15075616qcg.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:35 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 43/49] writeback: implement wb_wait_for_single_work()
Date: Mon,  6 Apr 2015 15:58:32 -0400
Message-Id: <1428350318-8215-44-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

For cgroup writeback, multiple wb_writeback_work items may need to be
issuedto accomplish a single task.  The previous patch updated the
waiting mechanism such that wb_wait_for_completion() can wait for
multiple work items.

Issuing mulitple work items involves memory allocation which may fail.
As most writeback operations can't fail or blocked on memory
allocation, in such cases, we'll fall back to sequential issuing of an
on-stack work item, which would need to be waited upon sequentially.

This patch implements wb_wait_for_single_work() which waits for a
single work item independently from wb_completion waiting so that such
fallback mechanism can be used without getting tangled with the usual
issuing / completion operation.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c | 47 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index faa9272..2a3cd9c 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -52,6 +52,8 @@ struct wb_writeback_work {
 	unsigned int for_background:1;
 	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
 	unsigned int auto_free:1;	/* free on completion */
+	unsigned int single_wait:1;
+	unsigned int single_done:1;
 	enum wb_reason reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
@@ -165,8 +167,11 @@ static void wb_queue_work(struct bdi_writeback *wb,
 	trace_writeback_queue(wb->bdi, work);
 
 	spin_lock_bh(&wb->work_lock);
-	if (!test_bit(WB_registered, &wb->state))
+	if (!test_bit(WB_registered, &wb->state)) {
+		if (work->single_wait)
+			work->single_done = 1;
 		goto out_unlock;
+	}
 	if (work->done)
 		atomic_inc(&work->done->cnt);
 	list_add_tail(&work->list, &wb->work_list);
@@ -221,6 +226,32 @@ int inode_congested(struct inode *inode, int cong_bits)
 EXPORT_SYMBOL_GPL(inode_congested);
 
 /**
+ * wb_wait_for_single_work - wait for completion of a single bdi_writeback_work
+ * @bdi: bdi the work item was issued to
+ * @work: work item to wait for
+ *
+ * Wait for the completion of @work which was issued to one of @bdi's
+ * bdi_writeback's.  The caller must have set @work->single_wait before
+ * issuing it.  This wait operates independently fo
+ * wb_wait_for_completion() and also disables automatic freeing of @work.
+ */
+static void wb_wait_for_single_work(struct backing_dev_info *bdi,
+				    struct wb_writeback_work *work)
+{
+	if (WARN_ON_ONCE(!work->single_wait))
+		return;
+
+	wait_event(bdi->wb_waitq, work->single_done);
+
+	/*
+	 * Paired with smp_wmb() in wb_do_writeback() and ensures that all
+	 * modifications to @work prior to assertion of ->single_done is
+	 * visible to the caller once this function returns.
+	 */
+	smp_rmb();
+}
+
+/**
  * wb_split_bdi_pages - split nr_pages to write according to bandwidth
  * @wb: target bdi_writeback to split @nr_pages to
  * @nr_pages: number of pages to write for the whole bdi
@@ -1159,14 +1190,26 @@ static long wb_do_writeback(struct bdi_writeback *wb)
 	set_bit(WB_writeback_running, &wb->state);
 	while ((work = get_next_work_item(wb)) != NULL) {
 		struct wb_completion *done = work->done;
+		bool need_wake_up = false;
 
 		trace_writeback_exec(wb->bdi, work);
 
 		wrote += wb_writeback(wb, work);
 
-		if (work->auto_free)
+		if (work->single_wait) {
+			WARN_ON_ONCE(work->auto_free);
+			/* paired w/ rmb in wb_wait_for_single_work() */
+			smp_wmb();
+			work->single_done = 1;
+			need_wake_up = true;
+		} else if (work->auto_free) {
 			kfree(work);
+		}
+
 		if (done && atomic_dec_and_test(&done->cnt))
+			need_wake_up = true;
+
+		if (need_wake_up)
 			wake_up_all(&wb->bdi->wb_waitq);
 	}
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
