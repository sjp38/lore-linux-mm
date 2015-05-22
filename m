Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5D616829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:35 -0400 (EDT)
Received: by qget53 with SMTP id t53so16192545qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:35 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id z9si2363190qcn.27.2015.05.22.14.15.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:34 -0700 (PDT)
Received: by qgew3 with SMTP id w3so16211136qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:34 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 40/51] writeback: make bdi_start_background_writeback() take bdi_writeback instead of backing_dev_info
Date: Fri, 22 May 2015 17:13:54 -0400
Message-Id: <1432329245-5844-41-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

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
index 45baf6c..92aaf64 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -228,23 +228,23 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
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
 
 /*
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index f04956c..9cc11e5 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -27,7 +27,7 @@ void bdi_unregister(struct backing_dev_info *bdi);
 int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
 void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 			bool range_cyclic, enum wb_reason reason);
-void bdi_start_background_writeback(struct backing_dev_info *bdi);
+void wb_start_background_writeback(struct bdi_writeback *wb);
 void wb_workfn(struct work_struct *work);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e3b5c1d..70cf98d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1456,7 +1456,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		}
 
 		if (unlikely(!writeback_in_progress(wb)))
-			bdi_start_background_writeback(bdi);
+			wb_start_background_writeback(wb);
 
 		if (!strictlimit)
 			wb_dirty_limits(wb, dirty_thresh, background_thresh,
@@ -1588,7 +1588,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		return;
 
 	if (nr_reclaimable > background_thresh)
-		bdi_start_background_writeback(bdi);
+		wb_start_background_writeback(wb);
 }
 
 static DEFINE_PER_CPU(int, bdp_ratelimits);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
