Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69F1C6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 19:16:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v78so9969112pgb.4
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 16:16:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j17sor20027pga.318.2017.10.05.16.16.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 16:16:26 -0700 (PDT)
Date: Thu, 5 Oct 2017 16:16:23 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2] block/laptop_mode: Convert timers to use timer_setup()
Message-ID: <20171005231623.GA109154@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Jeff Layton <jlayton@redhat.com>
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
v2: Rebased to linux-block.git/for-4.15/timer
---
 block/blk-core.c          | 10 +++++-----
 include/linux/writeback.h |  2 +-
 mm/page-writeback.c       |  7 ++++---
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 14f7674fa0b1..596255822d7d 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -803,9 +803,9 @@ static void blk_queue_usage_counter_release(struct percpu_ref *ref)
 	wake_up_all(&q->mq_freeze_wq);
 }
 
-static void blk_rq_timed_out_timer(unsigned long data)
+static void blk_rq_timed_out_timer(struct timer_list *t)
 {
-	struct request_queue *q = (struct request_queue *)data;
+	struct request_queue *q = from_timer(q, t, timeout);
 
 	kblockd_schedule_work(&q->timeout_work);
 }
@@ -841,9 +841,9 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	q->backing_dev_info->name = "block";
 	q->node = node_id;
 
-	setup_timer(&q->backing_dev_info->laptop_mode_wb_timer,
-		    laptop_mode_timer_fn, (unsigned long) q);
-	setup_timer(&q->timeout, blk_rq_timed_out_timer, (unsigned long) q);
+	timer_setup(&q->backing_dev_info->laptop_mode_wb_timer,
+		    laptop_mode_timer_fn, 0);
+	timer_setup(&q->timeout, blk_rq_timed_out_timer, 0);
 	INIT_LIST_HEAD(&q->queue_head);
 	INIT_LIST_HEAD(&q->timeout_list);
 	INIT_LIST_HEAD(&q->icq_list);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index dd1d2c23f743..80944e6bf484 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -309,7 +309,7 @@ static inline void cgroup_writeback_umount(void)
 void laptop_io_completion(struct backing_dev_info *info);
 void laptop_sync_completion(void);
 void laptop_mode_sync(struct work_struct *work);
-void laptop_mode_timer_fn(unsigned long data);
+void laptop_mode_timer_fn(struct timer_list *t);
 #else
 static inline void laptop_sync_completion(void) { }
 #endif
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 8d1fc593bce8..138b8016f759 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1977,11 +1977,12 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 }
 
 #ifdef CONFIG_BLOCK
-void laptop_mode_timer_fn(unsigned long data)
+void laptop_mode_timer_fn(struct timer_list *t)
 {
-	struct request_queue *q = (struct request_queue *)data;
+	struct backing_dev_info *backing_dev_info =
+		from_timer(backing_dev_info, t, laptop_mode_wb_timer);
 
-	wakeup_flusher_threads_bdi(q->backing_dev_info, WB_REASON_LAPTOP_TIMER);
+	wakeup_flusher_threads_bdi(backing_dev_info, WB_REASON_LAPTOP_TIMER);
 }
 
 /*
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
