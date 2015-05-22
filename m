Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id AB974829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:29 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so22251737qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:29 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id b5si3691819qkh.96.2015.05.22.14.15.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:29 -0700 (PDT)
Received: by qgez61 with SMTP id z61so16261036qge.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:28 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 37/51] writeback: remove bdi_start_writeback()
Date: Fri, 22 May 2015 17:13:51 -0400
Message-Id: <1432329245-5844-38-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

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
index 921a9e4..79f11af 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -184,33 +184,6 @@ static void wb_queue_work(struct bdi_writeback *wb,
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
@@ -240,22 +213,31 @@ EXPORT_SYMBOL_GPL(inode_congested);
 
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
@@ -1219,7 +1201,7 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 
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
index 9b55f12..6301af2 100644
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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
