Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 79D6C6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 00:27:00 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so106520080pad.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 21:27:00 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id dg5si26436899pbb.15.2015.10.22.21.26.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 21:26:59 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so106519739pad.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 21:26:59 -0700 (PDT)
Date: Fri, 23 Oct 2015 13:26:49 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151023042649.GB18907@mtj.duckdns.org>
References: <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022142155.GB30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220923130.23591@east.gentwo.org>
 <20151022142429.GC30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220925160.23638@east.gentwo.org>
 <20151022143349.GD30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
 <20151022151414.GF30579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022151414.GF30579@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello,

So, something like the following.  Just compile tested but this is
essentially partial revert of 3270476a6c0c ("workqueue: reimplement
WQ_HIGHPRI using a separate worker_pool") - resurrecting the old
WQ_HIGHPRI implementation under WQ_IMMEDIATE, so we know this works.
If for some reason, it gets decided against simply adding one jiffy
sleep, please let me know.  I'll verify the operation and post a
proper patch.  That said, given that this prolly needs -stable
backport and vmstat is likely to be the only user (busy loops are
really rare in the kernel after all), I think the better approach
would be reinstating the short sleep.

Thanks.

---
 include/linux/workqueue.h |    7 ++---
 kernel/workqueue.c        |   63 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 63 insertions(+), 7 deletions(-)

--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -278,9 +278,10 @@ enum {
 	WQ_UNBOUND		= 1 << 1, /* not bound to any cpu */
 	WQ_FREEZABLE		= 1 << 2, /* freeze during suspend */
 	WQ_MEM_RECLAIM		= 1 << 3, /* may be used for memory reclaim */
-	WQ_HIGHPRI		= 1 << 4, /* high priority */
-	WQ_CPU_INTENSIVE	= 1 << 5, /* cpu intensive workqueue */
-	WQ_SYSFS		= 1 << 6, /* visible in sysfs, see wq_sysfs_register() */
+	WQ_IMMEDIATE		= 1 << 4, /* bypass concurrency management */
+	WQ_HIGHPRI		= 1 << 5, /* high priority */
+	WQ_CPU_INTENSIVE	= 1 << 6, /* cpu intensive workqueue */
+	WQ_SYSFS		= 1 << 7, /* visible in sysfs, see wq_sysfs_register() */
 
 	/*
 	 * Per-cpu workqueues are generally preferred because they tend to
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -68,6 +68,7 @@ enum {
 	 * attach_mutex to avoid changing binding state while
 	 * worker_attach_to_pool() is in progress.
 	 */
+	POOL_IMMEDIATE_PENDING	= 1 << 0,	/* WQ_IMMEDIATE items on queue */
 	POOL_DISASSOCIATED	= 1 << 2,	/* cpu can't serve workers */
 
 	/* worker flags */
@@ -731,7 +732,8 @@ static bool work_is_canceling(struct wor
 
 static bool __need_more_worker(struct worker_pool *pool)
 {
-	return !atomic_read(&pool->nr_running);
+	return !atomic_read(&pool->nr_running) ||
+		(pool->flags & POOL_IMMEDIATE_PENDING);
 }
 
 /*
@@ -757,7 +759,8 @@ static bool may_start_working(struct wor
 static bool keep_working(struct worker_pool *pool)
 {
 	return !list_empty(&pool->worklist) &&
-		atomic_read(&pool->nr_running) <= 1;
+		(atomic_read(&pool->nr_running) <= 1 ||
+		 (pool->flags & POOL_IMMEDIATE_PENDING));
 }
 
 /* Do we need a new worker?  Called from manager. */
@@ -1021,6 +1024,42 @@ static void move_linked_works(struct wor
 }
 
 /**
+ * pwq_determine_ins_pos - find insertion position
+ * @pwq: pwq a work is being queued for
+ *
+ * A work for @pwq is about to be queued on @pwq->pool, determine insertion
+ * position for the work.  If @pwq is for IMMEDIATE wq, the work item is
+ * queued at the head of the queue but in FIFO order with respect to other
+ * IMMEDIATE work items; otherwise, at the end of the queue.  This function
+ * also sets POOL_IMMEDIATE_PENDING flag to hint @pool that there are
+ * IMMEDIATE works pending.
+ *
+ * CONTEXT:
+ * spin_lock_irq(gcwq->lock).
+ *
+ * RETURNS:
+ * Pointer to insertion position.
+ */
+static struct list_head *pwq_determine_ins_pos(struct pool_workqueue *pwq)
+{
+	struct worker_pool *pool = pwq->pool;
+	struct work_struct *twork;
+
+	if (likely(!(pwq->wq->flags & WQ_IMMEDIATE)))
+		return &pool->worklist;
+
+	list_for_each_entry(twork, &pool->worklist, entry) {
+		struct pool_workqueue *tpwq = get_work_pwq(twork);
+
+		if (!(tpwq->wq->flags & WQ_IMMEDIATE))
+			break;
+	}
+
+	pool->flags |= POOL_IMMEDIATE_PENDING;
+	return &twork->entry;
+}
+
+/**
  * get_pwq - get an extra reference on the specified pool_workqueue
  * @pwq: pool_workqueue to get
  *
@@ -1081,9 +1120,10 @@ static void put_pwq_unlocked(struct pool
 static void pwq_activate_delayed_work(struct work_struct *work)
 {
 	struct pool_workqueue *pwq = get_work_pwq(work);
+	struct list_head *pos = pwq_determine_ins_pos(pwq);
 
 	trace_workqueue_activate_work(work);
-	move_linked_works(work, &pwq->pool->worklist, NULL);
+	move_linked_works(work, pos, NULL);
 	__clear_bit(WORK_STRUCT_DELAYED_BIT, work_data_bits(work));
 	pwq->nr_active++;
 }
@@ -1384,7 +1424,7 @@ retry:
 	if (likely(pwq->nr_active < pwq->max_active)) {
 		trace_workqueue_activate_work(work);
 		pwq->nr_active++;
-		worklist = &pwq->pool->worklist;
+		worklist = pwq_determine_ins_pos(pwq);
 	} else {
 		work_flags |= WORK_STRUCT_DELAYED;
 		worklist = &pwq->delayed_works;
@@ -1996,6 +2036,21 @@ __acquires(&pool->lock)
 	list_del_init(&work->entry);
 
 	/*
+	 * If IMMEDIATE_PENDING, check the next work, and, if IMMEDIATE,
+	 * wake up another worker; otherwise, clear IMMEDIATE_PENDING.
+	 */
+	if (unlikely(pool->flags & POOL_IMMEDIATE_PENDING)) {
+		struct work_struct *nwork = list_first_entry(&pool->worklist,
+						struct work_struct, entry);
+
+		if (!list_empty(&pool->worklist) &&
+		    get_work_pwq(nwork)->wq->flags & WQ_IMMEDIATE)
+			wake_up_worker(pool);
+		else
+			pool->flags &= ~POOL_IMMEDIATE_PENDING;
+	}
+
+	/*
 	 * CPU intensive works don't participate in concurrency management.
 	 * They're the scheduler's responsibility.  This takes @worker out
 	 * of concurrency management and the next code block will chain

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
