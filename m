Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6DE6B0172
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 07:31:09 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH v2] mm: Make logic in bdi_forker_thread() straight
Date: Fri,  2 Sep 2011 13:31:04 +0200
Message-Id: <1314963064-22109-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <jaxboe@fusionio.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, consul.kautuk@gmail.com

The logic in bdi_forker_thread() is unnecessarily convoluted by setting task
state there and back or calling schedule_timeout() in TASK_RUNNING state. Also
clearing of BDI_pending bit is placed at the and of global loop and cases of a
switch which mustn't reach it must call 'continue' instead of 'break' which is
non-intuitive and thus asking for trouble. So make the logic more obvious.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Wu Fengguang <fengguang.wu@intel.com>
CC: consul.kautuk@gmail.com
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/backing-dev.c |   37 ++++++++++++++++++++-----------------
 1 files changed, 20 insertions(+), 17 deletions(-)

 This should be the right cleanup. Jens?

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index d6edf8d..bdf7d6b 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -359,6 +359,17 @@ static unsigned long bdi_longest_inactive(void)
 	return max(5UL * 60 * HZ, interval);
 }
 
+/*
+ * Clear pending bit and wakeup anybody waiting for flusher thread startup
+ * or teardown.
+ */
+static void bdi_clear_pending(struct backing_dev_info *bdi)
+{
+	clear_bit(BDI_pending, &bdi->state);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&bdi->state, BDI_pending);
+}
+
 static int bdi_forker_thread(void *ptr)
 {
 	struct bdi_writeback *me = ptr;
@@ -390,8 +401,6 @@ static int bdi_forker_thread(void *ptr)
 		}
 
 		spin_lock_bh(&bdi_lock);
-		set_current_state(TASK_INTERRUPTIBLE);
-
 		list_for_each_entry(bdi, &bdi_list, bdi_list) {
 			bool have_dirty_io;
 
@@ -441,13 +450,8 @@ static int bdi_forker_thread(void *ptr)
 		}
 		spin_unlock_bh(&bdi_lock);
 
-		/* Keep working if default bdi still has things to do */
-		if (!list_empty(&me->bdi->work_list))
-			__set_current_state(TASK_RUNNING);
-
 		switch (action) {
 		case FORK_THREAD:
-			__set_current_state(TASK_RUNNING);
 			task = kthread_create(bdi_writeback_thread, &bdi->wb,
 					      "flush-%s", dev_name(bdi->dev));
 			if (IS_ERR(task)) {
@@ -469,14 +473,21 @@ static int bdi_forker_thread(void *ptr)
 				spin_unlock_bh(&bdi->wb_lock);
 				wake_up_process(task);
 			}
+			bdi_clear_pending(bdi);
 			break;
 
 		case KILL_THREAD:
-			__set_current_state(TASK_RUNNING);
 			kthread_stop(task);
+			bdi_clear_pending(bdi);
 			break;
 
 		case NO_ACTION:
+			/* Keep working if default bdi still has things to do */
+			if (!list_empty(&me->bdi->work_list)) {
+				try_to_freeze();
+				break;
+			}
+			set_current_state(TASK_INTERRUPTIBLE);
 			if (!wb_has_dirty_io(me) || !dirty_writeback_interval)
 				/*
 				 * There are no dirty data. The only thing we
@@ -489,16 +500,8 @@ static int bdi_forker_thread(void *ptr)
 			else
 				schedule_timeout(msecs_to_jiffies(dirty_writeback_interval * 10));
 			try_to_freeze();
-			/* Back to the main loop */
-			continue;
+			break;
 		}
-
-		/*
-		 * Clear pending bit and wakeup anybody waiting to tear us down.
-		 */
-		clear_bit(BDI_pending, &bdi->state);
-		smp_mb__after_clear_bit();
-		wake_up_bit(&bdi->state, BDI_pending);
 	}
 
 	return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
