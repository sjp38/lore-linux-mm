Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 00B406B00C3
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:00:19 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so15145933qcb.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:00:18 -0700 (PDT)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id w91si5152366qgw.43.2015.04.06.12.59.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 12:59:53 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so31085745qkg.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:52 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 36/49] writeback: remove bdi_start_writeback()
Date: Mon,  6 Apr 2015 15:58:25 -0400
Message-Id: <1428350318-8215-37-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

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
 fs/fs-writeback.c           | 68 +++++++++++++++++----------------------------
 include/linux/backing-dev.h |  4 +--
 mm/page-writeback.c         |  4 +--
 3 files changed, 29 insertions(+), 47 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 6720af9..de309fa 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -172,33 +172,6 @@ out_unlock:
 	spin_unlock_bh(&wb->work_lock);
 }
 
-static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
-				 bool range_cyclic, enum wb_reason reason)
-{
-	struct wb_writeback_work *work;
-
-	if (!wb_has_dirty_io(wb))
-		return;
-
-	/*
-	 * This is WB_SYNC_NONE writeback, so if allocation fails just
-	 * wakeup the thread for old dirty data writeback
-	 */
-	work = kzalloc(sizeof(*work), GFP_ATOMIC);
-	if (!work) {
-		trace_writeback_nowork(wb->bdi);
-		wb_wakeup(wb);
-		return;
-	}
-
-	work->sync_mode	= WB_SYNC_NONE;
-	work->nr_pages	= nr_pages;
-	work->range_cyclic = range_cyclic;
-	work->reason	= reason;
-
-	wb_queue_work(wb, work);
-}
-
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 /**
@@ -228,22 +201,31 @@ EXPORT_SYMBOL_GPL(inode_congested);
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
-/**
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
+void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
+			bool range_cyclic, enum wb_reason reason)
 {
-	__wb_start_writeback(&bdi->wb, nr_pages, true, reason);
+	struct wb_writeback_work *work;
+
+	if (!wb_has_dirty_io(wb))
+		return;
+
+	/*
+	 * This is WB_SYNC_NONE writeback, so if allocation fails just
+	 * wakeup the thread for old dirty data writeback
+	 */
+	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work) {
+		trace_writeback_nowork(wb->bdi);
+		wb_wakeup(wb);
+		return;
+	}
+
+	work->sync_mode	= WB_SYNC_NONE;
+	work->nr_pages	= nr_pages;
+	work->range_cyclic = range_cyclic;
+	work->reason	= reason;
+
+	wb_queue_work(wb, work);
 }
 
 /**
@@ -1201,7 +1183,7 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
-		__wb_start_writeback(&bdi->wb, nr_pages, false, reason);
+		wb_start_writeback(&bdi->wb, nr_pages, false, reason);
 	rcu_read_unlock();
 }
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index c797980..0ff40c2 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -25,8 +25,8 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
 void bdi_unregister(struct backing_dev_info *bdi);
 int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
-void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-			enum wb_reason reason);
+void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
+			bool range_cyclic, enum wb_reason reason);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
 void wb_workfn(struct work_struct *work);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 8755f80..3b6d79a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1729,8 +1729,8 @@ void laptop_mode_timer_fn(unsigned long data)
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
