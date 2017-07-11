Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF6216B0279
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:13:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g14so4161033pgu.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:13:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t18si224289plj.460.2017.07.11.09.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 09:13:07 -0700 (PDT)
Date: Tue, 11 Jul 2017 18:04:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 05/16] lockdep: Implement crossrelease feature
Message-ID: <20170711160454.GA28975@worktop>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-6-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495616389-29772-6-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


Sorry for the much delayed response; aside from the usual backlog I got
unusually held up by family responsibilities.

My comments in the form of a patch..


--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -542,10 +542,10 @@ extern void crossrelease_hardirq_start(v
 extern void crossrelease_hardirq_end(void);
 extern void crossrelease_softirq_start(void);
 extern void crossrelease_softirq_end(void);
-extern void crossrelease_work_start(void);
-extern void crossrelease_work_end(void);
-extern void init_crossrelease_task(struct task_struct *task);
-extern void free_crossrelease_task(struct task_struct *task);
+extern void crossrelease_hist_start(void);
+extern void crossrelease_hist_end(void);
+extern void lockdep_init_task(struct task_struct *task);
+extern void lockdep_free_task(struct task_struct *task);
 #else
 /*
  * To initialize a lockdep_map statically use this macro.
@@ -558,10 +558,10 @@ static inline void crossrelease_hardirq_
 static inline void crossrelease_hardirq_end(void) {}
 static inline void crossrelease_softirq_start(void) {}
 static inline void crossrelease_softirq_end(void) {}
-static inline void crossrelease_work_start(void) {}
-static inline void crossrelease_work_end(void) {}
-static inline void init_crossrelease_task(struct task_struct *task) {}
-static inline void free_crossrelease_task(struct task_struct *task) {}
+static inline void crossrelease_hist_start(void) {}
+static inline void crossrelease_hist_end(void) {}
+static inline void lockdep_init_task(struct task_struct *task) {}
+static inline void lockdep_free_task(struct task_struct *task) {}
 #endif
 
 #ifdef CONFIG_LOCK_STAT
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -821,7 +821,7 @@ struct task_struct {
 	unsigned int xhlock_idx;
 	unsigned int xhlock_idx_soft; /* For restoring at softirq exit */
 	unsigned int xhlock_idx_hard; /* For restoring at hardirq exit */
-	unsigned int xhlock_idx_work; /* For restoring at work exit */
+	unsigned int xhlock_idx_hist; /* For restoring at history boundaries */
 #endif
 #ifdef CONFIG_UBSAN
 	unsigned int			in_ubsan;
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -933,7 +933,7 @@ void __noreturn do_exit(long code)
 	exit_rcu();
 	TASKS_RCU(__srcu_read_unlock(&tasks_rcu_exit_srcu, tasks_rcu_i));
 
-	free_crossrelease_task(tsk);
+	lockdep_free_task(tsk);
 	do_task_dead();
 }
 EXPORT_SYMBOL_GPL(do_exit);
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -485,7 +485,7 @@ void __init fork_init(void)
 	for (i = 0; i < UCOUNT_COUNTS; i++) {
 		init_user_ns.ucount_max[i] = max_threads/2;
 	}
-	init_crossrelease_task(&init_task);
+	lockdep_init_task(&init_task);
 
 #ifdef CONFIG_VMAP_STACK
 	cpuhp_setup_state(CPUHP_BP_PREPARE_DYN, "fork:vm_stack_cache",
@@ -1694,7 +1694,7 @@ static __latent_entropy struct task_stru
 	p->lockdep_depth = 0; /* no locks held yet */
 	p->curr_chain_key = 0;
 	p->lockdep_recursion = 0;
-	init_crossrelease_task(p);
+	lockdep_init_task(p);
 #endif
 
 #ifdef CONFIG_DEBUG_MUTEXES
@@ -1953,7 +1953,7 @@ static __latent_entropy struct task_stru
 bad_fork_cleanup_perf:
 	perf_event_free_task(p);
 bad_fork_cleanup_policy:
-	free_crossrelease_task(p);
+	lockdep_free_task(p);
 #ifdef CONFIG_NUMA
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_threadgroup_lock:
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -3381,8 +3381,8 @@ static int __lock_acquire(struct lockdep
 	unsigned int depth;
 	int chain_head = 0;
 	int class_idx;
-	int ret;
 	u64 chain_key;
+	int ret;
 
 	if (unlikely(!debug_locks))
 		return 0;
@@ -4653,6 +4653,13 @@ asmlinkage __visible void lockdep_sys_ex
 				curr->comm, curr->pid);
 		lockdep_print_held_locks(curr);
 	}
+
+	/*
+	 * The lock history for each syscall should be independent. So wipe the
+	 * slate clean on return to userspace.
+	 */
+	crossrelease_hist_end();
+	crossrelease_hist_start();
 }
 
 void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
@@ -4708,6 +4715,29 @@ EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious
 
 #ifdef CONFIG_LOCKDEP_CROSSRELEASE
 
+/*
+ * Crossrelease works by recording a lock history for each thread and
+ * connecting those historic locks that were taken after the
+ * wait_for_completion() in the complete() context.
+ *
+ * Task-A				Task-B
+ *
+ *					mutex_lock(&A);
+ *					mutex_unlock(&A);
+ *
+ * wait_for_completion(&C);
+ *   lock_acquire_crosslock();
+ *     atomic_inc_return(&cross_gen_id);
+ *                                |
+ *				  |	mutex_lock(&B);
+ *				  |	mutex_unlock(&B);
+ *                                |
+ *				  |	complete(&C);
+ *				  `--	  lock_commit_crosslock();
+ *
+ * Which will then add a dependency between B and C.
+ */
+
 #define xhlock(i)         (current->xhlocks[(i) % MAX_XHLOCKS_NR])
 
 /*
@@ -4715,6 +4745,25 @@ EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious
  */
 static atomic_t cross_gen_id; /* Can be wrapped */
 
+/*
+ * Lock history stacks; we have 3 nested lock history stacks:
+ *
+ *   Hard IRQ
+ *   Soft IRQ
+ *   History / Task
+ *
+ * The thing is that once we complete a (Hard/Soft) IRQ the future task locks
+ * should not depend on any of the locks observed while running the IRQ.
+ *
+ * So what we do is rewind the history buffer and erase all our knowledge of
+ * that temporal event.
+ *
+ * If the rewind wraps the history ring buffer ... XXX explain how we'll
+ * discard stuff. I cannot readily find how a rewind of exactly MAX_XHLOCKS_NR
+ * is not a NOP... should we make xhlock_valid() trigger when the rewind >=
+ * MAX_XHLOCKS_NR ? Possibly re-instroduce hist_gen_id ?
+ */
+
 void crossrelease_hardirq_start(void)
 {
 	if (current->xhlocks)
@@ -4740,20 +4789,31 @@ void crossrelease_softirq_end(void)
 }
 
 /*
- * Each work of workqueue might run in a different context,
- * thanks to concurrency support of workqueue. So we have to
- * distinguish each work to avoid false positive.
+ * We need this to annotate lock history boundaries. Take for instance
+ * workqueues; each work is independent of the last. The completion of a future
+ * work does not depend on the completion of a past work (in general).
+ * Therefore we must not carry that (lock) dependency across works.
+ *
+ * This is true for many things; pretty much all kthreads fall into this
+ * pattern, where they have an 'idle' state and future completions do not
+ * depend on past completions. Its just that since they all have the 'same'
+ * form -- the kthread does the same over and over -- it doesn't typically
+ * matter.
+ *
+ * The same is true for system-calls, once a system call is completed (we've
+ * returned to userspace) the next system call does not depend on the lock
+ * history of the previous system call.
  */
-void crossrelease_work_start(void)
+void crossrelease_hist_start(void)
 {
 	if (current->xhlocks)
-		current->xhlock_idx_work = current->xhlock_idx;
+		current->xhlock_idx_hist = current->xhlock_idx;
 }
 
-void crossrelease_work_end(void)
+void crossrelease_hist_end(void)
 {
 	if (current->xhlocks)
-		current->xhlock_idx = current->xhlock_idx_work;
+		current->xhlock_idx = current->xhlock_idx_hist;
 }
 
 static int cross_lock(struct lockdep_map *lock)
@@ -5053,17 +5113,17 @@ static void cross_init(struct lockdep_ma
 	BUILD_BUG_ON(MAX_XHLOCKS_NR & (MAX_XHLOCKS_NR - 1));
 }
 
-void init_crossrelease_task(struct task_struct *task)
+void lockdep_init_task(struct task_struct *task)
 {
 	task->xhlock_idx = UINT_MAX;
 	task->xhlock_idx_soft = UINT_MAX;
 	task->xhlock_idx_hard = UINT_MAX;
-	task->xhlock_idx_work = UINT_MAX;
+	task->xhlock_idx_hist = UINT_MAX;
 	task->xhlocks = kzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR,
 				GFP_KERNEL);
 }
 
-void free_crossrelease_task(struct task_struct *task)
+void lockdep_free_task(struct task_struct *task)
 {
 	if (task->xhlocks) {
 		void *tmp = task->xhlocks;
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2093,7 +2093,7 @@ __acquires(&pool->lock)
 
 	lock_map_acquire_read(&pwq->wq->lockdep_map);
 	lock_map_acquire(&lockdep_map);
-	crossrelease_work_start();
+	crossrelease_hist_start();
 	trace_workqueue_execute_start(work);
 	worker->current_func(work);
 	/*
@@ -2101,7 +2101,7 @@ __acquires(&pool->lock)
 	 * point will only record its address.
 	 */
 	trace_workqueue_execute_end(work);
-	crossrelease_work_end();
+	crossrelease_hist_end();
 	lock_map_release(&lockdep_map);
 	lock_map_release(&pwq->wq->lockdep_map);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
