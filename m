Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC556B014F
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:10 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id n4so232771qaq.2
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:10 -0800 (PST)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id 43si54428554qgc.68.2015.01.06.13.27.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:09 -0800 (PST)
Received: by mail-qg0-f42.google.com with SMTP id q108so71856qgd.15
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:08 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 22/45] writeback: make bdi_start_background_writeback() take bdi_writeback instead of backing_dev_info
Date: Tue,  6 Jan 2015 16:25:59 -0500
Message-Id: <1420579582-8516-23-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

bdi_start_background_writeback() currently takes @bdi and kicks the
root wb (bdi_writeback).  In preparation for cgroup writeback support,
make it take wb instead.

This patch doesn't make any functional difference.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c           | 12 ++++++------
 include/linux/backing-dev.h |  2 +-
 mm/page-writeback.c         |  4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 6ab113b..c209ff1 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -244,23 +244,23 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 }
 
 /**
- * bdi_start_background_writeback - start background writeback
- * @bdi: the backing device to write from
+ * wb_start_background_writeback - start background writeback
+ * @wb: bdi_writback to write from
  *
  * Description:
  *   This makes sure WB_SYNC_NONE background writeback happens. When
- *   this function returns, it is only guaranteed that for given BDI
+ *   this function returns, it is only guaranteed that for given wb
  *   some IO is happening if we are over background dirty threshold.
  *   Caller need not hold sb s_umount semaphore.
  */
-void bdi_start_background_writeback(struct backing_dev_info *bdi)
+void wb_start_background_writeback(struct bdi_writeback *wb)
 {
 	/*
 	 * We just wake up the flusher thread. It will perform background
 	 * writeback as soon as there is no other work to do.
 	 */
-	trace_writeback_wake_background(bdi);
-	wb_wakeup(&bdi->wb);
+	trace_writeback_wake_background(wb->bdi);
+	wb_wakeup(wb);
 }
 
 /**
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 953fa01..4cdab7c 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -28,7 +28,7 @@ void bdi_unregister(struct backing_dev_info *bdi);
 int __must_check bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
 void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 			bool range_cyclic, enum wb_reason reason);
-void bdi_start_background_writeback(struct backing_dev_info *bdi);
+void wb_start_background_writeback(struct bdi_writeback *wb);
 void wb_workfn(struct work_struct *work);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b250ee2..4cf365c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1450,7 +1450,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		}
 
 		if (unlikely(!writeback_in_progress(wb)))
-			bdi_start_background_writeback(bdi);
+			wb_start_background_writeback(wb);
 
 		if (!strictlimit)
 			wb_dirty_limits(wb, dirty_thresh, background_thresh,
@@ -1583,7 +1583,7 @@ pause:
 		return;
 
 	if (nr_reclaimable > background_thresh)
-		bdi_start_background_writeback(bdi);
+		wb_start_background_writeback(wb);
 }
 
 static DEFINE_PER_CPU(int, bdp_ratelimits);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
