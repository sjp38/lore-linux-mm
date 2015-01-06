Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 07EA66B0149
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:04 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id i13so194718qae.10
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:03 -0800 (PST)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com. [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id c90si51211154qgc.123.2015.01.06.13.27.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:03 -0800 (PST)
Received: by mail-qc0-f180.google.com with SMTP id i8so64363qcq.25
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:02 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 19/45] writeback: remove bdi_start_writeback()
Date: Tue,  6 Jan 2015 16:25:56 -0500
Message-Id: <1420579582-8516-20-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

bdi_start_writeback() is a thin wrapper on top of
__wb_start_writeback() which is used only by laptop_mode_timer_fn().
This patches removes bdi_start_writeback(), renames
__wb_start_writeback() to wb_start_writeback() and makes
laptop_mode_timer_fn() use it instead.

This doesn't cause any functional difference and will ease making
laptop_mode_timer_fn() cgroup writeback aware.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c           | 24 +++---------------------
 include/linux/backing-dev.h |  4 ++--
 mm/page-writeback.c         |  4 ++--
 3 files changed, 7 insertions(+), 25 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index bb8dbe8..18d8e72 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -229,8 +229,8 @@ void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode)
 	dctx->wb = &inode_to_bdi(inode)->wb;
 }
 
-static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
-				 bool range_cyclic, enum wb_reason reason)
+void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
+			bool range_cyclic, enum wb_reason reason)
 {
 	struct wb_writeback_work *work;
 
@@ -257,24 +257,6 @@ static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 }
 
 /**
- * bdi_start_writeback - start writeback
- * @bdi: the backing device to write from
- * @nr_pages: the number of pages to write
- * @reason: reason why some writeback work was initiated
- *
- * Description:
- *   This does WB_SYNC_NONE opportunistic writeback. The IO is only
- *   started when this function returns, we make no guarantees on
- *   completion. Caller need not hold sb s_umount semaphore.
- *
- */
-void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-			enum wb_reason reason)
-{
-	__wb_start_writeback(&bdi->wb, nr_pages, true, reason);
-}
-
-/**
  * bdi_start_background_writeback - start background writeback
  * @bdi: the backing device to write from
  *
@@ -1253,7 +1235,7 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
-		__wb_start_writeback(&bdi->wb, nr_pages, false, reason);
+		wb_start_writeback(&bdi->wb, nr_pages, false, reason);
 	rcu_read_unlock();
 }
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 37c4299..c6278ee 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -26,8 +26,8 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
 void bdi_unregister(struct backing_dev_info *bdi);
 int __must_check bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
-void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-			enum wb_reason reason);
+void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
+			bool range_cyclic, enum wb_reason reason);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
 void wb_workfn(struct work_struct *work);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e1b74d7..18bf51d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1731,8 +1731,8 @@ void laptop_mode_timer_fn(unsigned long data)
 	 * threshold
 	 */
 	if (bdi_has_dirty_io(&q->backing_dev_info))
-		bdi_start_writeback(&q->backing_dev_info, nr_pages,
-					WB_REASON_LAPTOP_TIMER);
+		wb_start_writeback(&q->backing_dev_info.wb, nr_pages, true,
+				   WB_REASON_LAPTOP_TIMER);
 }
 
 /*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
