Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9709582F6C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:27:31 -0500 (EST)
Received: by wmdw130 with SMTP id w130so198516276wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:27:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a11si4810893wmh.58.2015.11.18.05.27.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 05:27:30 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v3 18/22] IB/fmr_pool: Convert the cleanup thread into kthread worker API
Date: Wed, 18 Nov 2015 14:25:23 +0100
Message-Id: <1447853127-3461-19-git-send-email-pmladek@suse.com>
In-Reply-To: <1447853127-3461-1-git-send-email-pmladek@suse.com>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org

Kthreads are currently implemented as an infinite loop. Each
has its own variant of checks for terminating, freezing,
awakening. In many cases it is unclear to say in which state
it is and sometimes it is done a wrong way.

The plan is to convert kthreads into kthread_worker or workqueues
API. It allows to split the functionality into separate operations.
It helps to make a better structure. Also it defines a clean state
where no locks are taken, IRQs blocked, the kthread might sleep
or even be safely migrated.

The kthread worker API is useful when we want to have a dedicated
single thread for the work. It helps to make sure that it is
available when needed. Also it allows a better control, e.g.
define a scheduling priority.

This patch converts the frm_pool kthread into the kthread worker
API because I am not sure how busy the thread is. It is well
possible that it does not need a dedicated kthread and workqueues
would be perfectly fine. Well, the conversion between kthread
worker API and workqueues is pretty trivial.

The patch moves one iteration from the kthread into the work function.
It preserves the check for a spurious queuing (wake up). Then it
processes one request. Finally, it re-queues itself if more requests
are pending.

Otherwise, wake_up_process() is replaced by queuing the work.

Important: The change is only compile tested. I did not find an easy
way how to check it in a real life.

Signed-off-by: Petr Mladek <pmladek@suse.com>
CC: Doug Ledford <dledford@redhat.com>
CC: Sean Hefty <sean.hefty@intel.com>
CC: Hal Rosenstock <hal.rosenstock@gmail.com>
CC: linux-rdma@vger.kernel.org
---
 drivers/infiniband/core/fmr_pool.c | 54 ++++++++++++++++++--------------------
 1 file changed, 25 insertions(+), 29 deletions(-)

diff --git a/drivers/infiniband/core/fmr_pool.c b/drivers/infiniband/core/fmr_pool.c
index 9f5ad7cc33c8..5f2b06bd14da 100644
--- a/drivers/infiniband/core/fmr_pool.c
+++ b/drivers/infiniband/core/fmr_pool.c
@@ -96,7 +96,8 @@ struct ib_fmr_pool {
 						   void *              arg);
 	void                     *flush_arg;
 
-	struct task_struct       *thread;
+	struct kthread_worker	  *worker;
+	struct kthread_work	  work;
 
 	atomic_t                  req_ser;
 	atomic_t                  flush_ser;
@@ -174,29 +175,26 @@ static void ib_fmr_batch_release(struct ib_fmr_pool *pool)
 	spin_unlock_irq(&pool->pool_lock);
 }
 
-static int ib_fmr_cleanup_thread(void *pool_ptr)
+static void ib_fmr_cleanup_func(struct kthread_work *work)
 {
-	struct ib_fmr_pool *pool = pool_ptr;
+	struct ib_fmr_pool *pool = container_of(work, struct ib_fmr_pool, work);
 
-	do {
-		if (atomic_read(&pool->flush_ser) - atomic_read(&pool->req_ser) < 0) {
-			ib_fmr_batch_release(pool);
-
-			atomic_inc(&pool->flush_ser);
-			wake_up_interruptible(&pool->force_wait);
+	/*
+	 * The same request might be queued twice when it appears and
+	 * by re-queuing from this work.
+	 */
+	if (atomic_read(&pool->flush_ser) - atomic_read(&pool->req_ser) >= 0)
+		return;
 
-			if (pool->flush_function)
-				pool->flush_function(pool, pool->flush_arg);
-		}
+	ib_fmr_batch_release(pool);
+	atomic_inc(&pool->flush_ser);
+	wake_up_interruptible(&pool->force_wait);
 
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (atomic_read(&pool->flush_ser) - atomic_read(&pool->req_ser) >= 0 &&
-		    !kthread_should_stop())
-			schedule();
-		__set_current_state(TASK_RUNNING);
-	} while (!kthread_should_stop());
+	if (pool->flush_function)
+		pool->flush_function(pool, pool->flush_arg);
 
-	return 0;
+	if (atomic_read(&pool->flush_ser) - atomic_read(&pool->req_ser) < 0)
+		queue_kthread_work(pool->worker, &pool->work);
 }
 
 /**
@@ -286,15 +284,13 @@ struct ib_fmr_pool *ib_create_fmr_pool(struct ib_pd             *pd,
 	atomic_set(&pool->flush_ser, 0);
 	init_waitqueue_head(&pool->force_wait);
 
-	pool->thread = kthread_run(ib_fmr_cleanup_thread,
-				   pool,
-				   "ib_fmr(%s)",
-				   device->name);
-	if (IS_ERR(pool->thread)) {
-		printk(KERN_WARNING PFX "couldn't start cleanup thread\n");
-		ret = PTR_ERR(pool->thread);
+	pool->worker = create_kthread_worker(0, "ib_fmr(%s)", device->name);
+	if (IS_ERR(pool->worker)) {
+		pr_warn(PFX "couldn't start cleanup kthread worker\n");
+		ret = PTR_ERR(pool->worker);
 		goto out_free_pool;
 	}
+	init_kthread_work(&pool->work, ib_fmr_cleanup_func);
 
 	{
 		struct ib_pool_fmr *fmr;
@@ -362,7 +358,7 @@ void ib_destroy_fmr_pool(struct ib_fmr_pool *pool)
 	LIST_HEAD(fmr_list);
 	int                 i;
 
-	kthread_stop(pool->thread);
+	destroy_kthread_worker(pool->worker);
 	ib_fmr_batch_release(pool);
 
 	i = 0;
@@ -412,7 +408,7 @@ int ib_flush_fmr_pool(struct ib_fmr_pool *pool)
 	spin_unlock_irq(&pool->pool_lock);
 
 	serial = atomic_inc_return(&pool->req_ser);
-	wake_up_process(pool->thread);
+	queue_kthread_work(pool->worker, &pool->work);
 
 	if (wait_event_interruptible(pool->force_wait,
 				     atomic_read(&pool->flush_ser) - serial >= 0))
@@ -526,7 +522,7 @@ int ib_fmr_pool_unmap(struct ib_pool_fmr *fmr)
 			list_add_tail(&fmr->list, &pool->dirty_list);
 			if (++pool->dirty_len >= pool->dirty_watermark) {
 				atomic_inc(&pool->req_ser);
-				wake_up_process(pool->thread);
+				queue_kthread_work(pool->worker, &pool->work);
 			}
 		}
 	}
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
