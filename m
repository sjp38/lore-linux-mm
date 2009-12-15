Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0C5466B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:36:42 -0500 (EST)
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead
 prepare_to_wait()
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <1260865739.30062.16.camel@marge.simson.net>
References: <20091214212936.BBBA.A69D9226@jp.fujitsu.com>
	 <4B264CCA.5010609@redhat.com> <20091215085631.CDAD.A69D9226@jp.fujitsu.com>
	 <1260855146.6126.30.camel@marge.simson.net>
	 <1260865739.30062.16.camel@marge.simson.net>
Content-Type: text/plain
Date: Tue, 15 Dec 2009 15:36:30 +0100
Message-Id: <1260887790.8754.22.camel@marge.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-12-15 at 09:29 +0100, Mike Galbraith wrote:
> On Tue, 2009-12-15 at 06:32 +0100, Mike Galbraith wrote:
> > On Tue, 2009-12-15 at 09:45 +0900, KOSAKI Motohiro wrote:
> > > > On 12/14/2009 07:30 AM, KOSAKI Motohiro wrote:
> > > > > if we don't use exclusive queue, wake_up() function wake _all_ waited
> > > > > task. This is simply cpu wasting.
> > > > >
> > > > > Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> > > > 
> > > > >   		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
> > > > >   					0, 0)) {
> > > > > -			wake_up(wq);
> > > > > +			wake_up_all(wq);
> > > > >   			finish_wait(wq,&wait);
> > > > >   			sc->nr_reclaimed += sc->nr_to_reclaim;
> > > > >   			return -ERESTARTSYS;
> > > > 
> > > > I believe we want to wake the processes up one at a time
> > > > here.  If the queue of waiting processes is very large
> > > > and the amount of excess free memory is fairly low, the
> > > > first processes that wake up can take the amount of free
> > > > memory back down below the threshold.  The rest of the
> > > > waiters should stay asleep when this happens.
> > > 
> > > OK.
> > > 
> > > Actually, wake_up() and wake_up_all() aren't different so much.
> > > Although we use wake_up(), the task wake up next task before
> > > try to alloate memory. then, it's similar to wake_up_all().
> > 
> > What happens to waiters should running tasks not allocate for a while?
> > 
> > > However, there are few difference. recent scheduler latency improvement
> > > effort reduce default scheduler latency target. it mean, if we have
> > > lots tasks of running state, the task have very few time slice. too
> > > frequently context switch decrease VM efficiency.
> > > Thank you, Rik. I didn't notice wake_up() makes better performance than
> > > wake_up_all() on current kernel.
> > 
> > Perhaps this is a spot where an explicit wake_up_all_nopreempt() would
> > be handy....
> 
> Maybe something like below.  I can also imagine that under _heavy_ vm
> pressure, it'd likely be good for throughput to not provide for sleeper
> fairness for these wakeups as well, as that increases vruntime spread,
> and thus increases preemption with no benefit in sight.

Copy/pasting some methods, and hardcoding futexes, where I know vmark
loads to the point of ridiculous on my little box, it's good for ~17%
throughput boost.  Used prudently, something along these lines could
save some thrashing when core code knows it's handling a surge.  It
would have a very negative effect at low to modest load though.

Hohum.

---
 include/linux/completion.h |    2 
 include/linux/sched.h      |   10 ++-
 include/linux/wait.h       |    3 
 kernel/sched.c             |  140 ++++++++++++++++++++++++++++++++++++---------
 kernel/sched_fair.c        |   32 +++++-----
 kernel/sched_idletask.c    |    2 
 kernel/sched_rt.c          |    6 -
 7 files changed, 146 insertions(+), 49 deletions(-)

Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1065,12 +1065,16 @@ struct sched_domain;
  */
 #define WF_SYNC		0x01		/* waker goes to sleep after wakup */
 #define WF_FORK		0x02		/* child wakeup after fork */
+#define WF_BATCH	0x04		/* batch wakeup, not preemptive */
+#define WF_REQUEUE	0x00		/* task requeue */
+#define WF_WAKE		0x10		/* task waking */
+#define WF_SLEEP	0x20		/* task going to sleep */
 
 struct sched_class {
 	const struct sched_class *next;
 
-	void (*enqueue_task) (struct rq *rq, struct task_struct *p, int wakeup);
-	void (*dequeue_task) (struct rq *rq, struct task_struct *p, int sleep);
+	void (*enqueue_task) (struct rq *rq, struct task_struct *p, int flags);
+	void (*dequeue_task) (struct rq *rq, struct task_struct *p, int flags);
 	void (*yield_task) (struct rq *rq);
 
 	void (*check_preempt_curr) (struct rq *rq, struct task_struct *p, int flags);
@@ -2028,6 +2032,8 @@ extern void do_timer(unsigned long ticks
 
 extern int wake_up_state(struct task_struct *tsk, unsigned int state);
 extern int wake_up_process(struct task_struct *tsk);
+extern int wake_up_state_batch(struct task_struct *tsk, unsigned int state);
+extern int wake_up_process_batch(struct task_struct *tsk);
 extern void wake_up_new_task(struct task_struct *tsk,
 				unsigned long clone_flags);
 #ifdef CONFIG_SMP
Index: linux-2.6/include/linux/wait.h
===================================================================
--- linux-2.6.orig/include/linux/wait.h
+++ linux-2.6/include/linux/wait.h
@@ -140,6 +140,7 @@ static inline void __remove_wait_queue(w
 }
 
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
+void __wake_up_batch(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
 void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
 void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr,
 			void *key);
@@ -154,8 +155,10 @@ int out_of_line_wait_on_bit_lock(void *,
 wait_queue_head_t *bit_waitqueue(void *, int);
 
 #define wake_up(x)			__wake_up(x, TASK_NORMAL, 1, NULL)
+#define wake_up_batch(x)		__wake_up_batch(x, TASK_NORMAL, 1, NULL)
 #define wake_up_nr(x, nr)		__wake_up(x, TASK_NORMAL, nr, NULL)
 #define wake_up_all(x)			__wake_up(x, TASK_NORMAL, 0, NULL)
+#define wake_up_all_batch(x)		__wake_up_batch(x, TASK_NORMAL, 0, NULL)
 #define wake_up_locked(x)		__wake_up_locked((x), TASK_NORMAL)
 
 #define wake_up_interruptible(x)	__wake_up(x, TASK_INTERRUPTIBLE, 1, NULL)
Index: linux-2.6/kernel/sched.c
===================================================================
--- linux-2.6.orig/kernel/sched.c
+++ linux-2.6/kernel/sched.c
@@ -1392,7 +1392,7 @@ static const u32 prio_to_wmult[40] = {
  /*  15 */ 119304647, 148102320, 186737708, 238609294, 286331153,
 };
 
-static void activate_task(struct rq *rq, struct task_struct *p, int wakeup);
+static void activate_task(struct rq *rq, struct task_struct *p, int flags);
 
 /*
  * runqueue iterator, to support SMP load-balancing between different
@@ -1962,24 +1962,24 @@ static int effective_prio(struct task_st
 /*
  * activate_task - move a task to the runqueue.
  */
-static void activate_task(struct rq *rq, struct task_struct *p, int wakeup)
+static void activate_task(struct rq *rq, struct task_struct *p, int flags)
 {
 	if (task_contributes_to_load(p))
 		rq->nr_uninterruptible--;
 
-	enqueue_task(rq, p, wakeup);
+	enqueue_task(rq, p, flags);
 	inc_nr_running(rq);
 }
 
 /*
  * deactivate_task - remove a task from the runqueue.
  */
-static void deactivate_task(struct rq *rq, struct task_struct *p, int sleep)
+static void deactivate_task(struct rq *rq, struct task_struct *p, int flags)
 {
 	if (task_contributes_to_load(p))
 		rq->nr_uninterruptible++;
 
-	dequeue_task(rq, p, sleep);
+	dequeue_task(rq, p, flags);
 	dec_nr_running(rq);
 }
 
@@ -2415,7 +2415,7 @@ out_activate:
 		schedstat_inc(p, se.nr_wakeups_local);
 	else
 		schedstat_inc(p, se.nr_wakeups_remote);
-	activate_task(rq, p, 1);
+	activate_task(rq, p, wake_flags);
 	success = 1;
 
 	/*
@@ -2474,13 +2474,35 @@ out:
  */
 int wake_up_process(struct task_struct *p)
 {
-	return try_to_wake_up(p, TASK_ALL, 0);
+	return try_to_wake_up(p, TASK_ALL, WF_WAKE);
 }
 EXPORT_SYMBOL(wake_up_process);
 
+/**
+ * wake_up_process_batch - Wake up a specific process
+ * @p: The process to be woken up.
+ *
+ * Attempt to wake up the nominated process and move it to the set of runnable
+ * processes.  Returns 1 if the process was woken up, 0 if it was already
+ * running.
+ *
+ * It may be assumed that this function implies a write memory barrier before
+ * changing the task state if and only if any tasks are woken up.
+ */
+int wake_up_process_batch(struct task_struct *p)
+{
+	return try_to_wake_up(p, TASK_ALL, WF_WAKE|WF_BATCH);
+}
+EXPORT_SYMBOL(wake_up_process_batch);
+
 int wake_up_state(struct task_struct *p, unsigned int state)
 {
-	return try_to_wake_up(p, state, 0);
+	return try_to_wake_up(p, state, WF_WAKE);
+}
+
+int wake_up_state_batch(struct task_struct *p, unsigned int state)
+{
+	return try_to_wake_up(p, state, WF_WAKE|WF_BATCH);
 }
 
 /*
@@ -2628,7 +2650,7 @@ void wake_up_new_task(struct task_struct
 	rq = task_rq_lock(p, &flags);
 	BUG_ON(p->state != TASK_RUNNING);
 	update_rq_clock(rq);
-	activate_task(rq, p, 0);
+	activate_task(rq, p, WF_WAKE|WF_FORK);
 	trace_sched_wakeup_new(rq, p, 1);
 	check_preempt_curr(rq, p, WF_FORK);
 #ifdef CONFIG_SMP
@@ -3156,9 +3178,9 @@ void sched_exec(void)
 static void pull_task(struct rq *src_rq, struct task_struct *p,
 		      struct rq *this_rq, int this_cpu)
 {
-	deactivate_task(src_rq, p, 0);
+	deactivate_task(src_rq, p, WF_REQUEUE);
 	set_task_cpu(p, this_cpu);
-	activate_task(this_rq, p, 0);
+	activate_task(this_rq, p, WF_REQUEUE);
 	check_preempt_curr(this_rq, p, 0);
 }
 
@@ -5468,7 +5490,7 @@ need_resched_nonpreemptible:
 		if (unlikely(signal_pending_state(prev->state, prev)))
 			prev->state = TASK_RUNNING;
 		else
-			deactivate_task(rq, prev, 1);
+			deactivate_task(rq, prev, WF_SLEEP);
 		switch_count = &prev->nvcsw;
 	}
 
@@ -5634,7 +5656,7 @@ asmlinkage void __sched preempt_schedule
 int default_wake_function(wait_queue_t *curr, unsigned mode, int wake_flags,
 			  void *key)
 {
-	return try_to_wake_up(curr->private, mode, wake_flags);
+	return try_to_wake_up(curr->private, mode, wake_flags|WF_WAKE);
 }
 EXPORT_SYMBOL(default_wake_function);
 
@@ -5677,22 +5699,43 @@ void __wake_up(wait_queue_head_t *q, uns
 	unsigned long flags;
 
 	spin_lock_irqsave(&q->lock, flags);
-	__wake_up_common(q, mode, nr_exclusive, 0, key);
+	__wake_up_common(q, mode, nr_exclusive, WF_WAKE, key);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL(__wake_up);
 
+/**
+ * __wake_up_batch - wake up threads blocked on a waitqueue.
+ * @q: the waitqueue
+ * @mode: which threads
+ * @nr_exclusive: how many wake-one or wake-many threads to wake up
+ * @key: is directly passed to the wakeup function
+ *
+ * It may be assumed that this function implies a write memory barrier before
+ * changing the task state if and only if any tasks are woken up.
+ */
+void __wake_up_batch(wait_queue_head_t *q, unsigned int mode,
+			int nr_exclusive, void *key)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&q->lock, flags);
+	__wake_up_common(q, mode, nr_exclusive, WF_WAKE|WF_BATCH, key);
+	spin_unlock_irqrestore(&q->lock, flags);
+}
+EXPORT_SYMBOL(__wake_up_batch);
+
 /*
  * Same as __wake_up but called with the spinlock in wait_queue_head_t held.
  */
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode)
 {
-	__wake_up_common(q, mode, 1, 0, NULL);
+	__wake_up_common(q, mode, 1, WF_WAKE, NULL);
 }
 
 void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key)
 {
-	__wake_up_common(q, mode, 1, 0, key);
+	__wake_up_common(q, mode, 1, WF_WAKE, key);
 }
 
 /**
@@ -5716,7 +5759,7 @@ void __wake_up_sync_key(wait_queue_head_
 			int nr_exclusive, void *key)
 {
 	unsigned long flags;
-	int wake_flags = WF_SYNC;
+	int wake_flags = WF_WAKE|WF_SYNC;
 
 	if (unlikely(!q))
 		return;
@@ -5757,12 +5800,35 @@ void complete(struct completion *x)
 
 	spin_lock_irqsave(&x->wait.lock, flags);
 	x->done++;
-	__wake_up_common(&x->wait, TASK_NORMAL, 1, 0, NULL);
+	__wake_up_common(&x->wait, TASK_NORMAL, 1, WF_WAKE, NULL);
 	spin_unlock_irqrestore(&x->wait.lock, flags);
 }
 EXPORT_SYMBOL(complete);
 
 /**
+ * complete_batch: - signals a single thread waiting on this completion
+ * @x:  holds the state of this particular completion
+ *
+ * This will wake up a single thread waiting on this completion. Threads will be
+ * awakened in the same order in which they were queued.
+ *
+ * See also complete_all(), wait_for_completion() and related routines.
+ *
+ * It may be assumed that this function implies a write memory barrier before
+ * changing the task state if and only if any tasks are woken up.
+ */
+void complete_batch(struct completion *x)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&x->wait.lock, flags);
+	x->done++;
+	__wake_up_common(&x->wait, TASK_NORMAL, 1, WF_WAKE|WF_BATCH, NULL);
+	spin_unlock_irqrestore(&x->wait.lock, flags);
+}
+EXPORT_SYMBOL(complete_batch);
+
+/**
  * complete_all: - signals all threads waiting on this completion
  * @x:  holds the state of this particular completion
  *
@@ -5777,11 +5843,31 @@ void complete_all(struct completion *x)
 
 	spin_lock_irqsave(&x->wait.lock, flags);
 	x->done += UINT_MAX/2;
-	__wake_up_common(&x->wait, TASK_NORMAL, 0, 0, NULL);
+	__wake_up_common(&x->wait, TASK_NORMAL, 0, WF_WAKE, NULL);
 	spin_unlock_irqrestore(&x->wait.lock, flags);
 }
 EXPORT_SYMBOL(complete_all);
 
+/**
+ * complete_all_batch: - signals all threads waiting on this completion
+ * @x:  holds the state of this particular completion
+ *
+ * This will wake up all threads waiting on this particular completion event.
+ *
+ * It may be assumed that this function implies a write memory barrier before
+ * changing the task state if and only if any tasks are woken up.
+ */
+void complete_all_batch(struct completion *x)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&x->wait.lock, flags);
+	x->done += UINT_MAX/2;
+	__wake_up_common(&x->wait, TASK_NORMAL, 0, WF_WAKE|WF_BATCH, NULL);
+	spin_unlock_irqrestore(&x->wait.lock, flags);
+}
+EXPORT_SYMBOL(complete_all_batch);
+
 static inline long __sched
 do_wait_for_common(struct completion *x, long timeout, int state)
 {
@@ -6344,7 +6430,7 @@ recheck:
 	on_rq = p->se.on_rq;
 	running = task_current(rq, p);
 	if (on_rq)
-		deactivate_task(rq, p, 0);
+		deactivate_task(rq, p, WF_REQUEUE);
 	if (running)
 		p->sched_class->put_prev_task(rq, p);
 
@@ -6356,7 +6442,7 @@ recheck:
 	if (running)
 		p->sched_class->set_curr_task(rq);
 	if (on_rq) {
-		activate_task(rq, p, 0);
+		activate_task(rq, p, WF_REQUEUE);
 
 		check_class_changed(rq, p, prev_class, oldprio, running);
 	}
@@ -7172,11 +7258,11 @@ static int __migrate_task(struct task_st
 
 	on_rq = p->se.on_rq;
 	if (on_rq)
-		deactivate_task(rq_src, p, 0);
+		deactivate_task(rq_src, p, WF_REQUEUE);
 
 	set_task_cpu(p, dest_cpu);
 	if (on_rq) {
-		activate_task(rq_dest, p, 0);
+		activate_task(rq_dest, p, WF_REQUEUE);
 		check_preempt_curr(rq_dest, p, 0);
 	}
 done:
@@ -7368,7 +7454,7 @@ void sched_idle_next(void)
 	__setscheduler(rq, p, SCHED_FIFO, MAX_RT_PRIO-1);
 
 	update_rq_clock(rq);
-	activate_task(rq, p, 0);
+	activate_task(rq, p, WF_REQUEUE);
 
 	raw_spin_unlock_irqrestore(&rq->lock, flags);
 }
@@ -7707,7 +7793,7 @@ migration_call(struct notifier_block *nf
 		/* Idle task back to normal (off runqueue, low prio) */
 		raw_spin_lock_irq(&rq->lock);
 		update_rq_clock(rq);
-		deactivate_task(rq, rq->idle, 0);
+		deactivate_task(rq, rq->idle, WF_REQUEUE);
 		__setscheduler(rq, rq->idle, SCHED_NORMAL, 0);
 		rq->idle->sched_class = &idle_sched_class;
 		migrate_dead_tasks(cpu);
@@ -9698,10 +9784,10 @@ static void normalize_task(struct rq *rq
 	update_rq_clock(rq);
 	on_rq = p->se.on_rq;
 	if (on_rq)
-		deactivate_task(rq, p, 0);
+		deactivate_task(rq, p, WF_REQUEUE);
 	__setscheduler(rq, p, SCHED_NORMAL, 0);
 	if (on_rq) {
-		activate_task(rq, p, 0);
+		activate_task(rq, p, WF_REQUEUE);
 		resched_task(rq->curr);
 	}
 }
Index: linux-2.6/kernel/sched_fair.c
===================================================================
--- linux-2.6.orig/kernel/sched_fair.c
+++ linux-2.6/kernel/sched_fair.c
@@ -722,7 +722,7 @@ static void check_spread(struct cfs_rq *
 }
 
 static void
-place_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int initial)
+place_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)
 {
 	u64 vruntime = cfs_rq->min_vruntime;
 
@@ -732,11 +732,11 @@ place_entity(struct cfs_rq *cfs_rq, stru
 	 * little, place the new task so that it fits in the slot that
 	 * stays open at the end.
 	 */
-	if (initial && sched_feat(START_DEBIT))
+	if (flags & WF_FORK && sched_feat(START_DEBIT))
 		vruntime += sched_vslice(cfs_rq, se);
 
 	/* sleeps up to a single latency don't count. */
-	if (!initial && sched_feat(FAIR_SLEEPERS)) {
+	if (!(flags & (WF_FORK|WF_BATCH)) && sched_feat(FAIR_SLEEPERS)) {
 		unsigned long thresh = sysctl_sched_latency;
 
 		/*
@@ -766,7 +766,7 @@ place_entity(struct cfs_rq *cfs_rq, stru
 }
 
 static void
-enqueue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int wakeup)
+enqueue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)
 {
 	/*
 	 * Update run-time statistics of the 'current'.
@@ -774,8 +774,8 @@ enqueue_entity(struct cfs_rq *cfs_rq, st
 	update_curr(cfs_rq);
 	account_entity_enqueue(cfs_rq, se);
 
-	if (wakeup) {
-		place_entity(cfs_rq, se, 0);
+	if (flags & WF_WAKE) {
+		place_entity(cfs_rq, se, flags);
 		enqueue_sleeper(cfs_rq, se);
 	}
 
@@ -801,7 +801,7 @@ static void clear_buddies(struct cfs_rq
 }
 
 static void
-dequeue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int sleep)
+dequeue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)
 {
 	/*
 	 * Update run-time statistics of the 'current'.
@@ -809,7 +809,7 @@ dequeue_entity(struct cfs_rq *cfs_rq, st
 	update_curr(cfs_rq);
 
 	update_stats_dequeue(cfs_rq, se);
-	if (sleep) {
+	if (flags & WF_SLEEP) {
 #ifdef CONFIG_SCHEDSTATS
 		if (entity_is_task(se)) {
 			struct task_struct *tsk = task_of(se);
@@ -1034,7 +1034,7 @@ static inline void hrtick_update(struct
  * increased. Here we update the fair scheduling stats and
  * then put the task into the rbtree:
  */
-static void enqueue_task_fair(struct rq *rq, struct task_struct *p, int wakeup)
+static void enqueue_task_fair(struct rq *rq, struct task_struct *p, int flags)
 {
 	struct cfs_rq *cfs_rq;
 	struct sched_entity *se = &p->se;
@@ -1043,8 +1043,8 @@ static void enqueue_task_fair(struct rq
 		if (se->on_rq)
 			break;
 		cfs_rq = cfs_rq_of(se);
-		enqueue_entity(cfs_rq, se, wakeup);
-		wakeup = 1;
+		enqueue_entity(cfs_rq, se, flags);
+		flags |= WF_WAKE;
 	}
 
 	hrtick_update(rq);
@@ -1055,18 +1055,18 @@ static void enqueue_task_fair(struct rq
  * decreased. We remove the task from the rbtree and
  * update the fair scheduling stats:
  */
-static void dequeue_task_fair(struct rq *rq, struct task_struct *p, int sleep)
+static void dequeue_task_fair(struct rq *rq, struct task_struct *p, int flags)
 {
 	struct cfs_rq *cfs_rq;
 	struct sched_entity *se = &p->se;
 
 	for_each_sched_entity(se) {
 		cfs_rq = cfs_rq_of(se);
-		dequeue_entity(cfs_rq, se, sleep);
+		dequeue_entity(cfs_rq, se, flags);
 		/* Don't dequeue parent if it has other entities besides us */
 		if (cfs_rq->load.weight)
 			break;
-		sleep = 1;
+		flags |= WF_SLEEP;
 	}
 
 	hrtick_update(rq);
@@ -1709,7 +1709,7 @@ static void check_preempt_wakeup(struct
 			pse->avg_overlap < sysctl_sched_migration_cost)
 		goto preempt;
 
-	if (!sched_feat(WAKEUP_PREEMPT))
+	if (!sched_feat(WAKEUP_PREEMPT) || (wake_flags & WF_BATCH))
 		return;
 
 	update_curr(cfs_rq);
@@ -1964,7 +1964,7 @@ static void task_fork_fair(struct task_s
 
 	if (curr)
 		se->vruntime = curr->vruntime;
-	place_entity(cfs_rq, se, 1);
+	place_entity(cfs_rq, se, WF_FORK);
 
 	if (sysctl_sched_child_runs_first && curr && entity_before(curr, se)) {
 		/*
Index: linux-2.6/include/linux/completion.h
===================================================================
--- linux-2.6.orig/include/linux/completion.h
+++ linux-2.6/include/linux/completion.h
@@ -88,6 +88,8 @@ extern bool completion_done(struct compl
 
 extern void complete(struct completion *);
 extern void complete_all(struct completion *);
+extern void complete_batch(struct completion *);
+extern void complete_all_batch(struct completion *);
 
 /**
  * INIT_COMPLETION: - reinitialize a completion structure
Index: linux-2.6/kernel/sched_rt.c
===================================================================
--- linux-2.6.orig/kernel/sched_rt.c
+++ linux-2.6/kernel/sched_rt.c
@@ -878,11 +878,11 @@ static void dequeue_rt_entity(struct sch
 /*
  * Adding/removing a task to/from a priority array:
  */
-static void enqueue_task_rt(struct rq *rq, struct task_struct *p, int wakeup)
+static void enqueue_task_rt(struct rq *rq, struct task_struct *p, int flags)
 {
 	struct sched_rt_entity *rt_se = &p->rt;
 
-	if (wakeup)
+	if (flags & WF_WAKE)
 		rt_se->timeout = 0;
 
 	enqueue_rt_entity(rt_se);
@@ -891,7 +891,7 @@ static void enqueue_task_rt(struct rq *r
 		enqueue_pushable_task(rq, p);
 }
 
-static void dequeue_task_rt(struct rq *rq, struct task_struct *p, int sleep)
+static void dequeue_task_rt(struct rq *rq, struct task_struct *p, int flags)
 {
 	struct sched_rt_entity *rt_se = &p->rt;
 
Index: linux-2.6/kernel/sched_idletask.c
===================================================================
--- linux-2.6.orig/kernel/sched_idletask.c
+++ linux-2.6/kernel/sched_idletask.c
@@ -32,7 +32,7 @@ static struct task_struct *pick_next_tas
  * message if some code attempts to do it:
  */
 static void
-dequeue_task_idle(struct rq *rq, struct task_struct *p, int sleep)
+dequeue_task_idle(struct rq *rq, struct task_struct *p, int flags)
 {
 	raw_spin_unlock_irq(&rq->lock);
 	pr_err("bad: scheduling from the idle thread!\n");


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
