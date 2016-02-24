Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 089386B0255
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:10:48 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id yy13so20561035pab.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:10:48 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id y1si7815649pfi.229.2016.02.24.15.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 15:10:47 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id e127so21066294pfe.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:10:47 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] writeback: call writeback tracepoints withoud holding list_lock in wb_writeback()
Date: Wed, 24 Feb 2016 14:47:23 -0800
Message-Id: <1456354043-31420-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, tglx@linutronix.de, rostedt@goodmis.org, bigeasy@linutronix.de, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

commit 5634cc2aa9aebc77bc862992e7805469dcf83dac ("writeback: update writeback
tracepoints to report cgroup") made writeback tracepoints report cgroup
writeback, but it may trigger the below bug on -rt kernel due to the list_lock
held for the for loop in wb_writeback().

BUG: sleeping function called from invalid context at kernel/locking/rtmutex.c:930
in_atomic(): 1, irqs_disabled(): 0, pid: 625, name: kworker/u16:3
INFO: lockdep is turned off.
Preemption disabled at:[<ffffffc000374a5c>] wb_writeback+0xec/0x830

CPU: 7 PID: 625 Comm: kworker/u16:3 Not tainted 4.4.1-rt5 #20
Hardware name: Freescale Layerscape 2085a RDB Board (DT)
Workqueue: writeback wb_workfn (flush-7:0)
Call trace:
[<ffffffc00008d708>] dump_backtrace+0x0/0x200
[<ffffffc00008d92c>] show_stack+0x24/0x30
[<ffffffc0007b0f40>] dump_stack+0x88/0xa8
[<ffffffc000127d74>] ___might_sleep+0x2ec/0x300
[<ffffffc000d5d550>] rt_spin_lock+0x38/0xb8
[<ffffffc0003e0548>] kernfs_path_len+0x30/0x90
[<ffffffc00036b360>] trace_event_raw_event_writeback_work_class+0xe8/0x2e8
[<ffffffc000374f90>] wb_writeback+0x620/0x830
[<ffffffc000376224>] wb_workfn+0x61c/0x950
[<ffffffc000110adc>] process_one_work+0x3ac/0xb30
[<ffffffc0001112fc>] worker_thread+0x9c/0x7a8
[<ffffffc00011a9e8>] kthread+0x190/0x1b0
[<ffffffc000086ca0>] ret_from_fork+0x10/0x30

The list_lock was moved outside the for loop by commit
e8dfc30582995ae12454cda517b17d6294175b07 ("writeback: elevate queue_io()
into wb_writeback())", however, the commit log says "No behavior change", so
it sounds safe to have the list_lock acquired inside the for loop as it did
before.

Just acquire list_lock at the necessary points and keep all writeback
tracepoints outside the critical area protected by list_lock in
wb_writeback().

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 fs/fs-writeback.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1f76d89..9b7b5f6 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1623,7 +1623,6 @@ static long wb_writeback(struct bdi_writeback *wb,
 	work->older_than_this = &oldest_jif;
 
 	blk_start_plug(&plug);
-	spin_lock(&wb->list_lock);
 	for (;;) {
 		/*
 		 * Stop writeback when nr_pages has been consumed
@@ -1661,15 +1660,19 @@ static long wb_writeback(struct bdi_writeback *wb,
 			oldest_jif = jiffies;
 
 		trace_writeback_start(wb, work);
+
+		spin_lock(&wb->list_lock);
 		if (list_empty(&wb->b_io))
 			queue_io(wb, work);
 		if (work->sb)
 			progress = writeback_sb_inodes(work->sb, wb, work);
 		else
 			progress = __writeback_inodes_wb(wb, work);
-		trace_writeback_written(wb, work);
 
 		wb_update_bandwidth(wb, wb_start);
+		spin_unlock(&wb->list_lock);
+
+		trace_writeback_written(wb, work);
 
 		/*
 		 * Did we write something? Try for more
@@ -1693,15 +1696,14 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 */
 		if (!list_empty(&wb->b_more_io))  {
 			trace_writeback_wait(wb, work);
+			spin_lock(&wb->list_lock);
 			inode = wb_inode(wb->b_more_io.prev);
-			spin_lock(&inode->i_lock);
 			spin_unlock(&wb->list_lock);
+			spin_lock(&inode->i_lock);
 			/* This function drops i_lock... */
 			inode_sleep_on_writeback(inode);
-			spin_lock(&wb->list_lock);
 		}
 	}
-	spin_unlock(&wb->list_lock);
 	blk_finish_plug(&plug);
 
 	return nr_pages - work->nr_pages;
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
