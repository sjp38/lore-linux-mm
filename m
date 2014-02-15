Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4106B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 23:12:26 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so13161242pbc.30
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 20:12:26 -0800 (PST)
Received: from mail-pb0-f73.google.com (mail-pb0-f73.google.com [209.85.160.73])
        by mx.google.com with ESMTPS id vw10si7866417pbc.137.2014.02.14.20.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 20:12:24 -0800 (PST)
Received: by mail-pb0-f73.google.com with SMTP id rq2so1595961pbb.0
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 20:12:22 -0800 (PST)
From: Derek Basehore <dbasehore@chromium.org>
Subject: [PATCH] backing_dev: Fix hung task on sync
Date: Fri, 14 Feb 2014 20:12:17 -0800
Message-Id: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Alexander Viro <viro@zento.linux.org.uk>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Derek Basehore <dbasehore@chromium.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, semenzato@chromium.org

bdi_wakeup_thread_delayed used the mod_delayed_work function to schedule work
to writeback dirty inodes. The problem with this is that it can delay work that
is scheduled for immediate execution, such as the work from sync_inodes_sb.
This can happen since mod_delayed_work can now steal work from a work_queue.
This fixes the problem by using queue_delayed_work instead. This is a
regression from the move to the bdi workqueue design.

The reason that this causes a problem is that laptop-mode will change the
delay, dirty_writeback_centisecs, to 60000 (10 minutes) by default. In the case
that bdi_wakeup_thread_delayed races with sync_inodes_sb, sync will be stopped
for 10 minutes and trigger a hung task. Even if dirty_writeback_centisecs is
not long enough to cause a hung task, we still don't want to delay sync for
that long.

For the same reason, this also changes bdi_writeback_workfn to immediately
queue the work again in the case that the work_list is not empty. The same
problem can happen if the sync work is run on the rescue worker.

Signed-off-by: Derek Basehore <dbasehore@chromium.org>
---
 fs/fs-writeback.c | 5 +++--
 mm/backing-dev.c  | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index e0259a1..95b7b8c 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1047,8 +1047,9 @@ void bdi_writeback_workfn(struct work_struct *work)
 		trace_writeback_pages_written(pages_written);
 	}
 
-	if (!list_empty(&bdi->work_list) ||
-	    (wb_has_dirty_io(wb) && dirty_writeback_interval))
+	if (!list_empty(&bdi->work_list))
+		mod_delayed_work(bdi_wq, &wb->dwork, 0);
+	else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
 		queue_delayed_work(bdi_wq, &wb->dwork,
 			msecs_to_jiffies(dirty_writeback_interval * 10));
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ce682f7..3fde024 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -294,7 +294,7 @@ void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
 	unsigned long timeout;
 
 	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
-	mod_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
+	queue_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
 }
 
 /*
-- 
1.9.0.rc1.175.g0b1dcb5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
