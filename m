Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id B7B6E6B026F
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:37 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id v23-v6so10865822ioh.16
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:37 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x5-v6si28285916iob.138.2018.11.05.08.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:35 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 05/13] workqueue, ktask: renice helper threads to prevent starvation
Date: Mon,  5 Nov 2018 11:55:50 -0500
Message-Id: <20181105165558.11698-6-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

With ktask helper threads running at MAX_NICE, it's possible for one or
more of them to begin chunks of the task and then have their CPU time
constrained by higher priority threads.  The main ktask thread, running
at normal priority, may finish all available chunks of the task and then
wait on the MAX_NICE helpers to finish the last in-progress chunks, for
longer than it would have if no helpers were used.

Avoid this by having the main thread assign its priority to each
unfinished helper one at a time so that on a heavily loaded system,
exactly one thread in a given ktask call is running at the main thread's
priority.  At least one thread to ensure forward progress, and at most
one thread to limit excessive multithreading.

Since the workqueue interface, on which ktask is built, does not provide
access to worker threads, ktask can't adjust their priorities directly,
so add a new interface to allow a previously-queued work item to run at
a different priority than the one controlled by the corresponding
workqueue's 'nice' attribute.  The worker assigned to the work item will
run the work at the given priority, temporarily overriding the worker's
priority.

The interface is flush_work_at_nice, which ensures the given work item's
assigned worker runs at the specified nice level and waits for the work
item to finish.

An alternative choice would have been to simply requeue the work item to
a pool with workers of the new priority, but this doesn't seem feasible
because a worker may have already started executing the work and there's
currently no way to interrupt it midway through.  The proposed interface
solves this issue because a worker's priority can be adjusted while it's
executing the work.

TODO:  flush_work_at_nice is a proof-of-concept only, and it may be
desired to have the interface set the work's nice without also waiting
for it to finish.  It's implemented in the flush path for this RFC
because it was fairly simple to write ;-)

I ran tests similar to the ones in the last patch with a couple of
differences:
 - The non-ktask workload uses 8 CPUs instead of 7 to compete with the
   main ktask thread as well as the ktask helpers, so that when the main
   thread finishes, its CPU is completely occupied by the non-ktask
   workload, meaning MAX_NICE helpers can't run as often.
 - The non-ktask workload starts before the ktask workload, rather
   than after, to maximize the chance that it starves helpers.

Runtimes in seconds.

Case 1: Synthetic, worst-case CPU contention

  ktask_test - a tight loop doing integer multiplication to max out on CPU;
               used for testing only, does not appear in this series
  stress-ng  - cpu stressor ("-c --cpu-method ackerman --cpu-ops 1200");

             8_ktask_thrs           8_ktask_thrs
               w/o_renice  (stdev)   with_renice  (stdev)  1_ktask_thr  (stdev)
             ------------------------------------------------------------------
  ktask_test        41.98  ( 0.22)         25.15  ( 2.98)        30.40  ( 0.61)
  stress-ng         44.79  ( 1.11)         46.37  ( 0.69)        53.29  ( 1.91)

Without renicing, ktask_test finishes just after stress-ng does because
stress-ng needs to free up CPUs for the helpers to finish (ktask_test
shows a shorter runtime than stress-ng because ktask_test was started
later).  Renicing lets ktask_test finish 40% sooner, and running the
same amount of work in ktask_test with 1 thread instead of 8 finishes in
a comparable amount of time, though longer than "with_renice" because
MAX_NICE threads still get some CPU time, and the effect over 8 threads
adds up.

stress-ng's total runtime gets a little longer going from no renicing to
renicing, as expected, because each reniced ktask thread takes more CPU
time than before when the helpers were starved.

Running with one ktask thread, stress-ng's reported walltime goes up
because that single thread interferes with fewer stress-ng threads,
but with more impact, causing a greater spread in the time it takes for
individual stress-ng threads to finish.  Averages of the per-thread
stress-ng times from "with_renice" to "1_ktask_thr" come out roughly
the same, though, 43.81 and 43.89 respectively.  So the total runtime of
stress-ng across all threads is unaffected, but the time stress-ng takes
to finish running its threads completely actually improves by spreading
the ktask_test work over more threads.

Case 2: Real-world CPU contention

  ktask_vfio - VFIO page pin a 32G kvm guest
  usemem     - faults in 86G of anonymous THP per thread, PAGE_SIZE stride;
               used to mimic the page clearing that dominates in ktask_vfio
               so that usemem competes for the same system resources

             8_ktask_thrs           8_ktask_thrs
               w/o_renice  (stdev)   with_renice  (stdev)  1_ktask_thr  (stdev)
             ------------------------------------------------------------------
  ktask_vfio        18.59  ( 0.19)         14.62  ( 2.03)        16.24  ( 0.90)
      usemem        47.54  ( 0.89)         48.18  ( 0.77)        49.70  ( 1.20)

These results are similar to case 1's, though the differences between
times are not quite as pronounced because ktask_vfio ran shorter
compared to usemem.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/workqueue.h |   5 ++
 kernel/ktask.c            |  81 ++++++++++++++++++-----------
 kernel/workqueue.c        | 106 +++++++++++++++++++++++++++++++++++---
 3 files changed, 156 insertions(+), 36 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 60d673e15632..d2976547c9c3 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -95,6 +95,10 @@ enum {
 	WORK_BUSY_PENDING	= 1 << 0,
 	WORK_BUSY_RUNNING	= 1 << 1,
 
+	/* flags for flush_work and similar functions */
+	WORK_FLUSH_FROM_CANCEL  = 1 << 0,
+	WORK_FLUSH_AT_NICE      = 1 << 1,
+
 	/* maximum string length for set_worker_desc() */
 	WORKER_DESC_LEN		= 24,
 };
@@ -477,6 +481,7 @@ extern int schedule_on_each_cpu(work_func_t func);
 int execute_in_process_context(work_func_t fn, struct execute_work *);
 
 extern bool flush_work(struct work_struct *work);
+extern bool flush_work_at_nice(struct work_struct *work, long nice);
 extern bool cancel_work_sync(struct work_struct *work);
 
 extern bool flush_delayed_work(struct delayed_work *dwork);
diff --git a/kernel/ktask.c b/kernel/ktask.c
index 72293a0f50c3..9d2727ce430c 100644
--- a/kernel/ktask.c
+++ b/kernel/ktask.c
@@ -16,7 +16,6 @@
 
 #include <linux/cpu.h>
 #include <linux/cpumask.h>
-#include <linux/completion.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
@@ -24,6 +23,7 @@
 #include <linux/mutex.h>
 #include <linux/printk.h>
 #include <linux/random.h>
+#include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
@@ -41,6 +41,11 @@ static size_t *ktask_rlim_node_max;
 #define	KTASK_CPUFRAC_NUMER	4
 #define	KTASK_CPUFRAC_DENOM	5
 
+enum ktask_work_flags {
+	KTASK_WORK_FINISHED	= 1,
+	KTASK_WORK_UNDO		= 2,
+};
+
 /* Used to pass ktask data to the workqueue API. */
 struct ktask_work {
 	struct work_struct	kw_work;
@@ -53,6 +58,7 @@ struct ktask_work {
 	void			*kw_error_end;
 	/* ktask_free_works, kn_failed_works linkage */
 	struct list_head	kw_list;
+	enum ktask_work_flags	kw_flags;
 };
 
 static LIST_HEAD(ktask_free_works);
@@ -68,10 +74,7 @@ struct ktask_task {
 	struct ktask_node	*kt_nodes;
 	size_t			kt_nr_nodes;
 	size_t			kt_nr_nodes_left;
-	size_t			kt_nworks;
-	size_t			kt_nworks_fini;
 	int			kt_error; /* first error from thread_func */
-	struct completion	kt_ktask_done;
 };
 
 /*
@@ -97,6 +100,7 @@ static void ktask_init_work(struct ktask_work *kw, struct ktask_task *kt,
 	kw->kw_task = kt;
 	kw->kw_ktask_node_i = ktask_node_i;
 	kw->kw_queue_nid = queue_nid;
+	kw->kw_flags = 0;
 }
 
 static void ktask_queue_work(struct ktask_work *kw)
@@ -171,7 +175,6 @@ static void ktask_thread(struct work_struct *work)
 	struct ktask_task  *kt = kw->kw_task;
 	struct ktask_ctl   *kc = &kt->kt_ctl;
 	struct ktask_node  *kn = &kt->kt_nodes[kw->kw_ktask_node_i];
-	bool               done;
 
 	mutex_lock(&kt->kt_mutex);
 
@@ -239,6 +242,7 @@ static void ktask_thread(struct work_struct *work)
 			 * about where this thread failed for ktask_undo.
 			 */
 			if (kc->kc_undo_func) {
+				kw->kw_flags |= KTASK_WORK_UNDO;
 				list_move(&kw->kw_list, &kn->kn_failed_works);
 				kw->kw_error_start = position;
 				kw->kw_error_offset = position_offset;
@@ -250,13 +254,8 @@ static void ktask_thread(struct work_struct *work)
 	WARN_ON(kt->kt_nr_nodes_left > 0 &&
 		kt->kt_error == KTASK_RETURN_SUCCESS);
 
-	++kt->kt_nworks_fini;
-	WARN_ON(kt->kt_nworks_fini > kt->kt_nworks);
-	done = (kt->kt_nworks_fini == kt->kt_nworks);
+	kw->kw_flags |= KTASK_WORK_FINISHED;
 	mutex_unlock(&kt->kt_mutex);
-
-	if (done)
-		complete(&kt->kt_ktask_done);
 }
 
 /*
@@ -294,7 +293,7 @@ static size_t ktask_chunk_size(size_t task_size, size_t min_chunk_size,
  */
 static size_t ktask_init_works(struct ktask_node *nodes, size_t nr_nodes,
 			       struct ktask_task *kt,
-			       struct list_head *works_list)
+			       struct list_head *unfinished_works)
 {
 	size_t i, nr_works, nr_works_check;
 	size_t min_chunk_size = kt->kt_ctl.kc_min_chunk_size;
@@ -342,7 +341,7 @@ static size_t ktask_init_works(struct ktask_node *nodes, size_t nr_nodes,
 		WARN_ON(list_empty(&ktask_free_works));
 		kw = list_first_entry(&ktask_free_works, struct ktask_work,
 				      kw_list);
-		list_move_tail(&kw->kw_list, works_list);
+		list_move_tail(&kw->kw_list, unfinished_works);
 		ktask_init_work(kw, kt, ktask_node_i, queue_nid);
 
 		++ktask_rlim_cur;
@@ -355,14 +354,14 @@ static size_t ktask_init_works(struct ktask_node *nodes, size_t nr_nodes,
 
 static void ktask_fini_works(struct ktask_task *kt,
 			     struct ktask_work *stack_work,
-			     struct list_head *works_list)
+			     struct list_head *finished_works)
 {
 	struct ktask_work *work, *next;
 
 	spin_lock(&ktask_rlim_lock);
 
 	/* Put the works back on the free list, adjusting rlimits. */
-	list_for_each_entry_safe(work, next, works_list, kw_list) {
+	list_for_each_entry_safe(work, next, finished_works, kw_list) {
 		if (work == stack_work) {
 			/* On this thread's stack, so not subject to rlimits. */
 			list_del(&work->kw_list);
@@ -393,7 +392,7 @@ static int ktask_error_cmp(void *unused, struct list_head *a,
 }
 
 static void ktask_undo(struct ktask_node *nodes, size_t nr_nodes,
-		       struct ktask_ctl *ctl, struct list_head *works_list)
+		       struct ktask_ctl *ctl, struct list_head *finished_works)
 {
 	size_t i;
 
@@ -424,7 +423,8 @@ static void ktask_undo(struct ktask_node *nodes, size_t nr_nodes,
 
 			if (failed_work) {
 				undo_pos = failed_work->kw_error_end;
-				list_move(&failed_work->kw_list, works_list);
+				list_move(&failed_work->kw_list,
+					  finished_works);
 			} else {
 				undo_pos = undo_end;
 			}
@@ -433,20 +433,46 @@ static void ktask_undo(struct ktask_node *nodes, size_t nr_nodes,
 	}
 }
 
+static void ktask_wait_for_completion(struct ktask_task *kt,
+				      struct list_head *unfinished_works,
+				      struct list_head *finished_works)
+{
+	struct ktask_work *work;
+
+	mutex_lock(&kt->kt_mutex);
+	while (!list_empty(unfinished_works)) {
+		work = list_first_entry(unfinished_works, struct ktask_work,
+					kw_list);
+		if (!(work->kw_flags & KTASK_WORK_FINISHED)) {
+			mutex_unlock(&kt->kt_mutex);
+			flush_work_at_nice(&work->kw_work, task_nice(current));
+			mutex_lock(&kt->kt_mutex);
+			WARN_ON_ONCE(!(work->kw_flags & KTASK_WORK_FINISHED));
+		}
+		/*
+		 * Leave works used in ktask_undo on kn->kn_failed_works.
+		 * ktask_undo will move them to finished_works.
+		 */
+		if (!(work->kw_flags & KTASK_WORK_UNDO))
+			list_move(&work->kw_list, finished_works);
+	}
+	mutex_unlock(&kt->kt_mutex);
+}
+
 int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
 		   struct ktask_ctl *ctl)
 {
-	size_t i;
+	size_t i, nr_works;
 	struct ktask_work kw;
 	struct ktask_work *work;
-	LIST_HEAD(works_list);
+	LIST_HEAD(unfinished_works);
+	LIST_HEAD(finished_works);
 	struct ktask_task kt = {
 		.kt_ctl             = *ctl,
 		.kt_total_size      = 0,
 		.kt_nodes           = nodes,
 		.kt_nr_nodes        = nr_nodes,
 		.kt_nr_nodes_left   = nr_nodes,
-		.kt_nworks_fini     = 0,
 		.kt_error           = KTASK_RETURN_SUCCESS,
 	};
 
@@ -465,14 +491,12 @@ int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
 		return KTASK_RETURN_SUCCESS;
 
 	mutex_init(&kt.kt_mutex);
-	init_completion(&kt.kt_ktask_done);
 
-	kt.kt_nworks = ktask_init_works(nodes, nr_nodes, &kt, &works_list);
+	nr_works = ktask_init_works(nodes, nr_nodes, &kt, &unfinished_works);
 	kt.kt_chunk_size = ktask_chunk_size(kt.kt_total_size,
-					    ctl->kc_min_chunk_size,
-					    kt.kt_nworks);
+					    ctl->kc_min_chunk_size, nr_works);
 
-	list_for_each_entry(work, &works_list, kw_list)
+	list_for_each_entry(work, &unfinished_works, kw_list)
 		ktask_queue_work(work);
 
 	/* Use the current thread, which saves starting a workqueue worker. */
@@ -480,13 +504,12 @@ int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
 	INIT_LIST_HEAD(&kw.kw_list);
 	ktask_thread(&kw.kw_work);
 
-	/* Wait for all the jobs to finish. */
-	wait_for_completion(&kt.kt_ktask_done);
+	ktask_wait_for_completion(&kt, &unfinished_works, &finished_works);
 
 	if (kt.kt_error && ctl->kc_undo_func)
-		ktask_undo(nodes, nr_nodes, ctl, &works_list);
+		ktask_undo(nodes, nr_nodes, ctl, &finished_works);
 
-	ktask_fini_works(&kt, &kw, &works_list);
+	ktask_fini_works(&kt, &kw, &finished_works);
 	mutex_destroy(&kt.kt_mutex);
 
 	return kt.kt_error;
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 0280deac392e..9fbae3fc9cca 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -79,6 +79,7 @@ enum {
 	WORKER_CPU_INTENSIVE	= 1 << 6,	/* cpu intensive */
 	WORKER_UNBOUND		= 1 << 7,	/* worker is unbound */
 	WORKER_REBOUND		= 1 << 8,	/* worker was rebound */
+	WORKER_NICED		= 1 << 9,	/* worker's nice was adjusted */
 
 	WORKER_NOT_RUNNING	= WORKER_PREP | WORKER_CPU_INTENSIVE |
 				  WORKER_UNBOUND | WORKER_REBOUND,
@@ -2184,6 +2185,18 @@ __acquires(&pool->lock)
 	if (unlikely(cpu_intensive))
 		worker_clr_flags(worker, WORKER_CPU_INTENSIVE);
 
+	/*
+	 * worker's nice level was adjusted (see flush_work_at_nice).  Use the
+	 * work's color to distinguish between the work that sets the nice
+	 * level (== NO_COLOR) and the work for which the adjustment was made
+	 * (!= NO_COLOR) to avoid prematurely restoring the nice level.
+	 */
+	if (unlikely(worker->flags & WORKER_NICED &&
+		     work_color != WORK_NO_COLOR)) {
+		set_user_nice(worker->task, worker->pool->attrs->nice);
+		worker_clr_flags(worker, WORKER_NICED);
+	}
+
 	/* we're done with it, release */
 	hash_del(&worker->hentry);
 	worker->current_work = NULL;
@@ -2846,8 +2859,53 @@ void drain_workqueue(struct workqueue_struct *wq)
 }
 EXPORT_SYMBOL_GPL(drain_workqueue);
 
+struct nice_work {
+	struct work_struct work;
+	long nice;
+};
+
+static void nice_work_func(struct work_struct *work)
+{
+	struct nice_work *nw = container_of(work, struct nice_work, work);
+	struct worker *worker = current_wq_worker();
+
+	if (WARN_ON_ONCE(!worker))
+		return;
+
+	set_user_nice(current, nw->nice);
+	worker->flags |= WORKER_NICED;
+}
+
+/**
+ * insert_nice_work - insert a nice_work into a pwq
+ * @pwq: pwq to insert nice_work into
+ * @nice_work: nice_work to insert
+ * @target: target work to attach @nice_work to
+ *
+ * @nice_work is linked to @target such that @target starts executing only
+ * after @nice_work finishes execution.
+ *
+ * @nice_work's only job is to ensure @target's assigned worker runs at the
+ * nice level contained in @nice_work.
+ *
+ * CONTEXT:
+ * spin_lock_irq(pool->lock).
+ */
+static void insert_nice_work(struct pool_workqueue *pwq,
+			     struct nice_work *nice_work,
+			     struct work_struct *target)
+{
+	/* see comment above similar code in insert_wq_barrier */
+	INIT_WORK_ONSTACK(&nice_work->work, nice_work_func);
+	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&nice_work->work));
+
+	debug_work_activate(&nice_work->work);
+	insert_work(pwq, &nice_work->work, &target->entry,
+		    work_color_to_flags(WORK_NO_COLOR) | WORK_STRUCT_LINKED);
+}
+
 static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
-			     bool from_cancel)
+			     struct nice_work *nice_work, int flags)
 {
 	struct worker *worker = NULL;
 	struct worker_pool *pool;
@@ -2868,11 +2926,19 @@ static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
 	if (pwq) {
 		if (unlikely(pwq->pool != pool))
 			goto already_gone;
+
+		/* not yet started, insert linked work before work */
+		if (unlikely(flags & WORK_FLUSH_AT_NICE))
+			insert_nice_work(pwq, nice_work, work);
 	} else {
 		worker = find_worker_executing_work(pool, work);
 		if (!worker)
 			goto already_gone;
 		pwq = worker->current_pwq;
+		if (unlikely(flags & WORK_FLUSH_AT_NICE)) {
+			set_user_nice(worker->task, nice_work->nice);
+			worker->flags |= WORKER_NICED;
+		}
 	}
 
 	check_flush_dependency(pwq->wq, work);
@@ -2889,7 +2955,7 @@ static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
 	 * workqueues the deadlock happens when the rescuer stalls, blocking
 	 * forward progress.
 	 */
-	if (!from_cancel &&
+	if (!(flags & WORK_FLUSH_FROM_CANCEL) &&
 	    (pwq->wq->saved_max_active == 1 || pwq->wq->rescuer)) {
 		lock_map_acquire(&pwq->wq->lockdep_map);
 		lock_map_release(&pwq->wq->lockdep_map);
@@ -2901,19 +2967,23 @@ static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
 	return false;
 }
 
-static bool __flush_work(struct work_struct *work, bool from_cancel)
+static bool __flush_work(struct work_struct *work, int flags, long nice)
 {
 	struct wq_barrier barr;
+	struct nice_work nice_work;
 
 	if (WARN_ON(!wq_online))
 		return false;
 
-	if (!from_cancel) {
+	if (!(flags & WORK_FLUSH_FROM_CANCEL)) {
 		lock_map_acquire(&work->lockdep_map);
 		lock_map_release(&work->lockdep_map);
 	}
 
-	if (start_flush_work(work, &barr, from_cancel)) {
+	if (unlikely(flags & WORK_FLUSH_AT_NICE))
+		nice_work.nice = nice;
+
+	if (start_flush_work(work, &barr, &nice_work, flags)) {
 		wait_for_completion(&barr.done);
 		destroy_work_on_stack(&barr.work);
 		return true;
@@ -2935,10 +3005,32 @@ static bool __flush_work(struct work_struct *work, bool from_cancel)
  */
 bool flush_work(struct work_struct *work)
 {
-	return __flush_work(work, false);
+	return __flush_work(work, 0, 0);
 }
 EXPORT_SYMBOL_GPL(flush_work);
 
+/**
+ * flush_work_at_nice - set a work's nice level and wait for it to finish
+ * @work: the target work
+ * @nice: nice level @work's assigned worker should run at
+ *
+ * Makes @work's assigned worker run at @nice for the duration of @work.
+ * Waits until @work has finished execution.  @work is guaranteed to be idle
+ * on return if it hasn't been requeued since flush started.
+ *
+ * Avoids priority inversion where a high priority task queues @work on a
+ * workqueue with low priority workers and may wait indefinitely for @work's
+ * completion.  That task can will its priority to @work.
+ *
+ * Return:
+ * %true if flush_work_at_nice() waited for the work to finish execution,
+ * %false if it was already idle.
+ */
+bool flush_work_at_nice(struct work_struct *work, long nice)
+{
+	return __flush_work(work, WORK_FLUSH_AT_NICE, nice);
+}
+
 struct cwt_wait {
 	wait_queue_entry_t		wait;
 	struct work_struct	*work;
@@ -3001,7 +3093,7 @@ static bool __cancel_work_timer(struct work_struct *work, bool is_dwork)
 	 * isn't executing.
 	 */
 	if (wq_online)
-		__flush_work(work, true);
+		__flush_work(work, WORK_FLUSH_FROM_CANCEL, 0);
 
 	clear_work_data(work);
 
-- 
2.19.1
