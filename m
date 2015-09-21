Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 64D936B0267
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:06:01 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so110632784wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:06:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s20si16974539wib.107.2015.09.21.06.05.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:55 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 17/18] rcu: Convert RCU gp kthreads into kthread worker API
Date: Mon, 21 Sep 2015 15:03:58 +0200
Message-Id: <1442840639-6963-18-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

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
single kthread for the work. It helps to make sure that it is
available when needed. Also it allows a better control, e.g.
define a scheduling priority.

This patch converts RCU gp threads into the kthread worker API.
They modify the scheduling, have their own logic to bind the process.
They provide functions that are critical for the system to work
and thus deserve a dedicated kthread.

This patch tries to split start of the grace period and the quiescent
state handling into separate works. The motivation is to avoid
wait_events inside the work. Instead it queues the works when
appropriate which is more typical for this API.

On one hand, it should reduce spurious wakeups where the condition
in the wait_event failed and the kthread went to sleep again.

On the other hand, there is a small race window when the other
work might get queued. We could detect and fix this situation
at the beginning of the work but it is a bit ugly.

The patch renames the functions kthread_wake() to kthread_worker_poke()
that sounds more appropriate.

Otherwise, the logic should stay the same. I did a lot of torturing
and I did not see any problem with the current patch. But of course,
it would deserve much more testing and reviewing before applying.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/rcu/tree.c        | 349 ++++++++++++++++++++++++++++++-----------------
 kernel/rcu/tree.h        |   8 +-
 kernel/rcu/tree_plugin.h |  16 +--
 3 files changed, 237 insertions(+), 136 deletions(-)

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 08d1d3e63b9b..e115c3aee65d 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -482,7 +482,7 @@ void show_rcu_gp_kthreads(void)
 
 	for_each_rcu_flavor(rsp) {
 		pr_info("%s: wait state: %d ->state: %#lx\n",
-			rsp->name, rsp->gp_state, rsp->gp_kthread->state);
+			rsp->name, rsp->gp_state, rsp->gp_worker->task->state);
 		/* sched_show_task(rsp->gp_kthread); */
 	}
 }
@@ -1179,7 +1179,7 @@ static void rcu_check_gp_kthread_starvation(struct rcu_state *rsp)
 		       rsp->name, j - gpa,
 		       rsp->gpnum, rsp->completed,
 		       rsp->gp_flags, rsp->gp_state,
-		       rsp->gp_kthread ? rsp->gp_kthread->state : 0);
+		       rsp->gp_worker ? rsp->gp_worker->task->state : 0);
 }
 
 /*
@@ -1577,19 +1577,66 @@ static int rcu_future_gp_cleanup(struct rcu_state *rsp, struct rcu_node *rnp)
 }
 
 /*
- * Awaken the grace-period kthread for the specified flavor of RCU.
- * Don't do a self-awaken, and don't bother awakening when there is
- * nothing for the grace-period kthread to do (as in several CPUs
- * raced to awaken, and we lost), and finally don't try to awaken
- * a kthread that has not yet been created.
+ * Check if it makes sense to queue the kthread work that would
+ * start a new grace period.
  */
-static void rcu_gp_kthread_wake(struct rcu_state *rsp)
+static bool rcu_gp_start_ready(struct rcu_state *rsp)
 {
-	if (current == rsp->gp_kthread ||
-	    !READ_ONCE(rsp->gp_flags) ||
-	    !rsp->gp_kthread)
+	/* Someone like call_rcu() requested a new grace period. */
+	if (READ_ONCE(rsp->gp_flags) & RCU_GP_FLAG_INIT)
+		return true;
+
+	return false;
+
+}
+
+/*
+ * Check if it makes sense to immediately queue the kthread work
+ * that would handle quiescent state.
+ *
+ * It does not check the timeout for forcing the quiescent state
+ * because the delayed kthread work should be scheduled at this
+ * time.
+ */
+static bool rcu_gp_handle_qs_ready(struct rcu_state *rsp)
+{
+	struct rcu_node *rnp = rcu_get_root(rsp);
+
+	/* Someone like call_rcu() requested a force-quiescent-state scan. */
+	if (READ_ONCE(rsp->gp_flags) & RCU_GP_FLAG_FQS)
+		return true;
+
+	/* The current grace period has completed. */
+	if (!READ_ONCE(rnp->qsmask) && !rcu_preempt_blocked_readers_cgp(rnp))
+		return true;
+
+	return false;
+}
+
+/*
+ * Poke the kthread worker that handles grace periods for the specified
+ * flavor of RCU. Return when there is nothing for the grace-period kthread
+ * worker to do (as in several CPUs raced to awaken, and we lost). Also
+ * don't try to use the kthread worker that has not been created yet.
+ * Finally, ignore requests from the kthread servicing the worker itself.
+ */
+static void rcu_gp_kthread_worker_poke(struct rcu_state *rsp)
+{
+	if (!READ_ONCE(rsp->gp_flags) ||
+	    !rsp->gp_worker ||
+	    rsp->gp_worker->task == current)
 		return;
-	wake_up(&rsp->gp_wq);
+
+	if (!rcu_gp_in_progress(rsp)) {
+		if (rcu_gp_start_ready(rsp))
+			queue_kthread_work(rsp->gp_worker, &rsp->gp_start_work);
+		return;
+	}
+
+	if (rcu_gp_handle_qs_ready(rsp))
+		mod_delayed_kthread_work(rsp->gp_worker,
+					 &rsp->gp_handle_qs_work,
+					 0);
 }
 
 /*
@@ -1756,7 +1803,7 @@ static bool __note_gp_changes(struct rcu_state *rsp, struct rcu_node *rnp,
 static void note_gp_changes(struct rcu_state *rsp, struct rcu_data *rdp)
 {
 	unsigned long flags;
-	bool needwake;
+	bool needpoke;
 	struct rcu_node *rnp;
 
 	local_irq_save(flags);
@@ -1769,10 +1816,10 @@ static void note_gp_changes(struct rcu_state *rsp, struct rcu_data *rdp)
 		return;
 	}
 	smp_mb__after_unlock_lock();
-	needwake = __note_gp_changes(rsp, rnp, rdp);
+	needpoke = __note_gp_changes(rsp, rnp, rdp);
 	raw_spin_unlock_irqrestore(&rnp->lock, flags);
-	if (needwake)
-		rcu_gp_kthread_wake(rsp);
+	if (needpoke)
+		rcu_gp_kthread_worker_poke(rsp);
 }
 
 static void rcu_gp_slow(struct rcu_state *rsp, int delay)
@@ -1905,25 +1952,6 @@ static int rcu_gp_init(struct rcu_state *rsp)
 }
 
 /*
- * Helper function for wait_event_interruptible_timeout() wakeup
- * at force-quiescent-state time.
- */
-static bool rcu_gp_fqs_check_wake(struct rcu_state *rsp)
-{
-	struct rcu_node *rnp = rcu_get_root(rsp);
-
-	/* Someone like call_rcu() requested a force-quiescent-state scan. */
-	if (READ_ONCE(rsp->gp_flags) & RCU_GP_FLAG_FQS)
-		return true;
-
-	/* The current grace period has completed. */
-	if (!READ_ONCE(rnp->qsmask) && !rcu_preempt_blocked_readers_cgp(rnp))
-		return true;
-
-	return false;
-}
-
-/*
  * Do one round of quiescent-state forcing.
  */
 static void rcu_gp_fqs(struct rcu_state *rsp)
@@ -2067,94 +2095,157 @@ static unsigned long normalize_jiffies_till_next_fqs(void)
 }
 
 /*
- * Body of kthread that handles grace periods.
+ * Initialize kthread worker for handling grace periods.
  */
-static int __noreturn rcu_gp_kthread(void *arg)
+static void rcu_gp_init_func(struct kthread_work *work)
 {
-	unsigned long timeout, j;
-	struct rcu_state *rsp = arg;
-	struct rcu_node *rnp = rcu_get_root(rsp);
+	struct rcu_state *rsp = container_of(work, struct rcu_state,
+					     gp_init_work);
 
 	rcu_bind_gp_kthread();
-	for (;;) {
 
-		/* Handle grace-period start. */
-		for (;;) {
-			trace_rcu_grace_period(rsp->name,
-					       READ_ONCE(rsp->gpnum),
-					       TPS("reqwait"));
-			rsp->gp_state = RCU_GP_WAIT_GPS;
-			wait_event_interruptible(rsp->gp_wq,
-						 READ_ONCE(rsp->gp_flags) &
-						 RCU_GP_FLAG_INIT);
-			rsp->gp_state = RCU_GP_DONE_GPS;
-			/* Locking provides needed memory barrier. */
-			if (rcu_gp_init(rsp))
-				break;
-			cond_resched_rcu_qs();
-			WRITE_ONCE(rsp->gp_activity, jiffies);
-			WARN_ON(signal_pending(current));
-			trace_rcu_grace_period(rsp->name,
-					       READ_ONCE(rsp->gpnum),
-					       TPS("reqwaitsig"));
+	trace_rcu_grace_period(rsp->name,
+			       READ_ONCE(rsp->gpnum),
+			       TPS("reqwait"));
+	rsp->gp_state = RCU_GP_WAIT_GPS;
+}
+
+/*
+ * Function for RCU kthread work that starts a new grace period.
+ */
+static void rcu_gp_start_func(struct kthread_work *work)
+{
+	unsigned long timeout;
+	struct rcu_state *rsp = container_of(work, struct rcu_state,
+					     gp_start_work);
+
+	/*
+	 * There is a small race window in rcu_gp_kthread_worker_poke().
+	 * Check if the grace period has already started and the quiescent
+	 * state should get handled instead.
+	 */
+	if (rcu_gp_in_progress(rsp)) {
+		if (rcu_gp_handle_qs_ready(rsp)) {
+			mod_delayed_kthread_work(rsp->gp_worker,
+						 &rsp->gp_handle_qs_work,
+						 0);
 		}
+		return;
+	}
 
+	rsp->gp_state = RCU_GP_DONE_GPS;
+	if (rcu_gp_init(rsp)) {
 		/* Handle quiescent-state forcing. */
 		rsp->first_gp_fqs = true;
 		timeout = normalize_jiffies_till_first_fqs();
 		rsp->jiffies_force_qs = jiffies + timeout;
-		for (;;) {
-			trace_rcu_grace_period(rsp->name,
-					       READ_ONCE(rsp->gpnum),
-					       TPS("fqswait"));
-			rsp->gp_state = RCU_GP_WAIT_FQS;
-			wait_event_interruptible_timeout(rsp->gp_wq,
-					rcu_gp_fqs_check_wake(rsp),
-					timeout);
-			rsp->gp_state = RCU_GP_DOING_FQS;
-try_again:
-			/* Locking provides needed memory barriers. */
-			/* If grace period done, leave loop. */
-			if (!READ_ONCE(rnp->qsmask) &&
-			    !rcu_preempt_blocked_readers_cgp(rnp))
-				break;
-			/* If time for quiescent-state forcing, do it. */
-			if (ULONG_CMP_GE(jiffies, rsp->jiffies_force_qs) ||
-			    (READ_ONCE(rsp->gp_flags) & RCU_GP_FLAG_FQS)) {
-				trace_rcu_grace_period(rsp->name,
-						       READ_ONCE(rsp->gpnum),
-						       TPS("fqsstart"));
-				rcu_gp_fqs(rsp);
-				timeout = normalize_jiffies_till_next_fqs();
-				rsp->jiffies_force_qs = jiffies + timeout;
-				trace_rcu_grace_period(rsp->name,
-						       READ_ONCE(rsp->gpnum),
-						       TPS("fqsend"));
-			} else {
-				/* Deal with stray signal. */
-				WARN_ON(signal_pending(current));
-				trace_rcu_grace_period(rsp->name,
-						       READ_ONCE(rsp->gpnum),
-						       TPS("fqswaitsig"));
-			}
-			cond_resched_rcu_qs();
-			WRITE_ONCE(rsp->gp_activity, jiffies);
-			/*
-			 * Count the remaining timeout when it was a spurious
-			 * wakeup. Well, it is useful also when we have slept
-			 * in the cond_resched().
-			 */
-			j = jiffies;
-			if (ULONG_CMP_GE(j, rsp->jiffies_force_qs))
-				goto try_again;
-			timeout = rsp->jiffies_force_qs - j;
-		}
+		trace_rcu_grace_period(rsp->name,
+				       READ_ONCE(rsp->gpnum),
+				       TPS("fqswait"));
+		rsp->gp_state = RCU_GP_WAIT_FQS;
+		queue_delayed_kthread_work(rsp->gp_worker,
+					   &rsp->gp_handle_qs_work,
+					   timeout);
+		return;
+	}
+
+	cond_resched_rcu_qs();
+	WRITE_ONCE(rsp->gp_activity, jiffies);
+	WARN_ON(signal_pending(current));
+	trace_rcu_grace_period(rsp->name,
+			       READ_ONCE(rsp->gpnum),
+			       TPS("reqwaitsig"));
+	trace_rcu_grace_period(rsp->name,
+			       READ_ONCE(rsp->gpnum),
+			       TPS("reqwait"));
+}
+
+/*
+ * Function for RCU kthread work that handles a quiescent state
+ * and closes the related grace period.
+ */
+static void rcu_gp_handle_qs_func(struct kthread_work *work)
+{
+	unsigned long timeout, j;
+	struct rcu_state *rsp = container_of(work, struct rcu_state,
+					     gp_handle_qs_work.work);
+	struct rcu_node *rnp = rcu_get_root(rsp);
+
 
+	/*
+	 * There is a small race window in rcu_gp_kthread_worker_poke()
+	 * when the work might be queued more times. First, check if
+	 * we are already waiting for the GP start instead.
+	 */
+	if (!rcu_gp_in_progress(rsp)) {
+		if (rcu_gp_start_ready(rsp))
+			queue_kthread_work(rsp->gp_worker, &rsp->gp_start_work);
+		return;
+	}
+
+	/*
+	 * Second, we might have been queued more times to force QS.
+	 * Just continue waiting if we have already forced it.
+	 */
+	if (!rcu_gp_handle_qs_ready(rsp) &&
+	    ULONG_CMP_LT(jiffies, rsp->jiffies_force_qs))
+		goto wait_continue;
+
+	rsp->gp_state = RCU_GP_DOING_FQS;
+try_again:
+	/* Locking provides needed memory barriers. */
+	/* If grace period done, leave loop. */
+	if (!READ_ONCE(rnp->qsmask) &&
+	    !rcu_preempt_blocked_readers_cgp(rnp)) {
 		/* Handle grace-period end. */
 		rsp->gp_state = RCU_GP_CLEANUP;
 		rcu_gp_cleanup(rsp);
 		rsp->gp_state = RCU_GP_CLEANED;
+		trace_rcu_grace_period(rsp->name,
+				       READ_ONCE(rsp->gpnum),
+				       TPS("reqwait"));
+		rsp->gp_state = RCU_GP_WAIT_GPS;
+		return;
+	}
+
+	/* If time for quiescent-state forcing, do it. */
+	if (ULONG_CMP_GE(jiffies, rsp->jiffies_force_qs) ||
+	    (READ_ONCE(rsp->gp_flags) & RCU_GP_FLAG_FQS)) {
+		trace_rcu_grace_period(rsp->name,
+				       READ_ONCE(rsp->gpnum),
+				       TPS("fqsstart"));
+		rcu_gp_fqs(rsp);
+		timeout = normalize_jiffies_till_next_fqs();
+		rsp->jiffies_force_qs = jiffies + timeout;
+		trace_rcu_grace_period(rsp->name,
+				       READ_ONCE(rsp->gpnum),
+				       TPS("fqsend"));
+	} else {
+		/* Deal with stray signal. */
+		WARN_ON(signal_pending(current));
+		trace_rcu_grace_period(rsp->name,
+				       READ_ONCE(rsp->gpnum),
+				       TPS("fqswaitsig"));
 	}
+wait_continue:
+	cond_resched_rcu_qs();
+	WRITE_ONCE(rsp->gp_activity, jiffies);
+	/*
+	 * Count the remaining timeout when it was a spurious
+	 * wakeup. Well, it is useful also when we have slept
+	 * in the cond_resched().
+	 */
+	j = jiffies;
+	if (ULONG_CMP_GE(j, rsp->jiffies_force_qs))
+		goto try_again;
+	timeout = rsp->jiffies_force_qs - j;
+
+	trace_rcu_grace_period(rsp->name,
+			       READ_ONCE(rsp->gpnum),
+			       TPS("fqswait"));
+	rsp->gp_state = RCU_GP_WAIT_FQS;
+	queue_delayed_kthread_work(rsp->gp_worker, &rsp->gp_handle_qs_work,
+				   timeout);
 }
 
 /*
@@ -2172,7 +2263,7 @@ static bool
 rcu_start_gp_advanced(struct rcu_state *rsp, struct rcu_node *rnp,
 		      struct rcu_data *rdp)
 {
-	if (!rsp->gp_kthread || !cpu_needs_another_gp(rsp, rdp)) {
+	if (!rsp->gp_worker || !cpu_needs_another_gp(rsp, rdp)) {
 		/*
 		 * Either we have not yet spawned the grace-period
 		 * task, this CPU does not need another grace period,
@@ -2234,7 +2325,7 @@ static void rcu_report_qs_rsp(struct rcu_state *rsp, unsigned long flags)
 	WARN_ON_ONCE(!rcu_gp_in_progress(rsp));
 	WRITE_ONCE(rsp->gp_flags, READ_ONCE(rsp->gp_flags) | RCU_GP_FLAG_FQS);
 	raw_spin_unlock_irqrestore(&rcu_get_root(rsp)->lock, flags);
-	rcu_gp_kthread_wake(rsp);
+	rcu_gp_kthread_worker_poke(rsp);
 }
 
 /*
@@ -2355,7 +2446,7 @@ rcu_report_qs_rdp(int cpu, struct rcu_state *rsp, struct rcu_data *rdp)
 {
 	unsigned long flags;
 	unsigned long mask;
-	bool needwake;
+	bool needpoke;
 	struct rcu_node *rnp;
 
 	rnp = rdp->mynode;
@@ -2387,12 +2478,12 @@ rcu_report_qs_rdp(int cpu, struct rcu_state *rsp, struct rcu_data *rdp)
 		 * This GP can't end until cpu checks in, so all of our
 		 * callbacks can be processed during the next GP.
 		 */
-		needwake = rcu_accelerate_cbs(rsp, rnp, rdp);
+		needpoke = rcu_accelerate_cbs(rsp, rnp, rdp);
 
 		rcu_report_qs_rnp(mask, rsp, rnp, rnp->gpnum, flags);
 		/* ^^^ Released rnp->lock */
-		if (needwake)
-			rcu_gp_kthread_wake(rsp);
+		if (needpoke)
+			rcu_gp_kthread_worker_poke(rsp);
 	}
 }
 
@@ -2895,7 +2986,7 @@ static void force_quiescent_state(struct rcu_state *rsp)
 	}
 	WRITE_ONCE(rsp->gp_flags, READ_ONCE(rsp->gp_flags) | RCU_GP_FLAG_FQS);
 	raw_spin_unlock_irqrestore(&rnp_old->lock, flags);
-	rcu_gp_kthread_wake(rsp);
+	rcu_gp_kthread_worker_poke(rsp);
 }
 
 /*
@@ -2907,7 +2998,7 @@ static void
 __rcu_process_callbacks(struct rcu_state *rsp)
 {
 	unsigned long flags;
-	bool needwake;
+	bool needpoke;
 	struct rcu_data *rdp = raw_cpu_ptr(rsp->rda);
 
 	WARN_ON_ONCE(rdp->beenonline == 0);
@@ -2919,10 +3010,10 @@ __rcu_process_callbacks(struct rcu_state *rsp)
 	local_irq_save(flags);
 	if (cpu_needs_another_gp(rsp, rdp)) {
 		raw_spin_lock(&rcu_get_root(rsp)->lock); /* irqs disabled. */
-		needwake = rcu_start_gp(rsp);
+		needpoke = rcu_start_gp(rsp);
 		raw_spin_unlock_irqrestore(&rcu_get_root(rsp)->lock, flags);
-		if (needwake)
-			rcu_gp_kthread_wake(rsp);
+		if (needpoke)
+			rcu_gp_kthread_worker_poke(rsp);
 	} else {
 		local_irq_restore(flags);
 	}
@@ -2980,7 +3071,7 @@ static void invoke_rcu_core(void)
 static void __call_rcu_core(struct rcu_state *rsp, struct rcu_data *rdp,
 			    struct rcu_head *head, unsigned long flags)
 {
-	bool needwake;
+	bool needpoke;
 
 	/*
 	 * If called from an extended quiescent state, invoke the RCU
@@ -3011,10 +3102,10 @@ static void __call_rcu_core(struct rcu_state *rsp, struct rcu_data *rdp,
 
 			raw_spin_lock(&rnp_root->lock);
 			smp_mb__after_unlock_lock();
-			needwake = rcu_start_gp(rsp);
+			needpoke = rcu_start_gp(rsp);
 			raw_spin_unlock(&rnp_root->lock);
-			if (needwake)
-				rcu_gp_kthread_wake(rsp);
+			if (needpoke)
+				rcu_gp_kthread_worker_poke(rsp);
 		} else {
 			/* Give the grace period a kick. */
 			rdp->blimit = LONG_MAX;
@@ -4044,7 +4135,7 @@ static int __init rcu_spawn_gp_kthread(void)
 	struct rcu_node *rnp;
 	struct rcu_state *rsp;
 	struct sched_param sp;
-	struct task_struct *t;
+	struct kthread_worker *w;
 
 	/* Force priority into range. */
 	if (IS_ENABLED(CONFIG_RCU_BOOST) && kthread_prio < 1)
@@ -4059,16 +4150,20 @@ static int __init rcu_spawn_gp_kthread(void)
 
 	rcu_scheduler_fully_active = 1;
 	for_each_rcu_flavor(rsp) {
-		t = kthread_create(rcu_gp_kthread, rsp, "%s", rsp->name);
-		BUG_ON(IS_ERR(t));
+		init_kthread_work(&rsp->gp_init_work, rcu_gp_init_func);
+		init_kthread_work(&rsp->gp_start_work, rcu_gp_start_func);
+		init_delayed_kthread_work(&rsp->gp_handle_qs_work,
+					  rcu_gp_handle_qs_func);
+		w = create_kthread_worker("%s", rsp->name);
+		BUG_ON(IS_ERR(w));
 		rnp = rcu_get_root(rsp);
 		raw_spin_lock_irqsave(&rnp->lock, flags);
-		rsp->gp_kthread = t;
+		rsp->gp_worker = w;
 		if (kthread_prio) {
 			sp.sched_priority = kthread_prio;
-			sched_setscheduler_nocheck(t, SCHED_FIFO, &sp);
+			sched_setscheduler_nocheck(w->task, SCHED_FIFO, &sp);
 		}
-		wake_up_process(t);
+		queue_kthread_work(w, &rsp->gp_init_work);
 		raw_spin_unlock_irqrestore(&rnp->lock, flags);
 	}
 	rcu_spawn_nocb_kthreads();
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index f16578a5eefe..b9490e975dd7 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -25,6 +25,7 @@
 #include <linux/cache.h>
 #include <linux/spinlock.h>
 #include <linux/threads.h>
+#include <linux/kthread.h>
 #include <linux/cpumask.h>
 #include <linux/seqlock.h>
 #include <linux/stop_machine.h>
@@ -466,7 +467,12 @@ struct rcu_state {
 						/* Subject to priority boost. */
 	unsigned long gpnum;			/* Current gp number. */
 	unsigned long completed;		/* # of last completed gp. */
-	struct task_struct *gp_kthread;		/* Task for grace periods. */
+	struct kthread_worker *gp_worker;	/* Worker for grace periods */
+	struct kthread_work gp_init_work;	/* Init work for handling gp */
+	struct kthread_work gp_start_work;	/* Work for starting gp */
+	struct delayed_kthread_work
+		gp_handle_qs_work;		/* Work for QS state handling */
+
 	wait_queue_head_t gp_wq;		/* Where GP task waits. */
 	short gp_flags;				/* Commands for GP task. */
 	short gp_state;				/* GP kthread sleep state. */
diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
index b2bf3963a0ae..55ae68530b7a 100644
--- a/kernel/rcu/tree_plugin.h
+++ b/kernel/rcu/tree_plugin.h
@@ -1476,7 +1476,7 @@ int rcu_needs_cpu(u64 basemono, u64 *nextevt)
  */
 static void rcu_prepare_for_idle(void)
 {
-	bool needwake;
+	bool needpoke;
 	struct rcu_data *rdp;
 	struct rcu_dynticks *rdtp = this_cpu_ptr(&rcu_dynticks);
 	struct rcu_node *rnp;
@@ -1528,10 +1528,10 @@ static void rcu_prepare_for_idle(void)
 		rnp = rdp->mynode;
 		raw_spin_lock(&rnp->lock); /* irqs already disabled. */
 		smp_mb__after_unlock_lock();
-		needwake = rcu_accelerate_cbs(rsp, rnp, rdp);
+		needpoke = rcu_accelerate_cbs(rsp, rnp, rdp);
 		raw_spin_unlock(&rnp->lock); /* irqs remain disabled. */
-		if (needwake)
-			rcu_gp_kthread_wake(rsp);
+		if (needpoke)
+			rcu_gp_kthread_worker_poke(rsp);
 	}
 }
 
@@ -2020,15 +2020,15 @@ static void rcu_nocb_wait_gp(struct rcu_data *rdp)
 	unsigned long c;
 	bool d;
 	unsigned long flags;
-	bool needwake;
+	bool needpoke;
 	struct rcu_node *rnp = rdp->mynode;
 
 	raw_spin_lock_irqsave(&rnp->lock, flags);
 	smp_mb__after_unlock_lock();
-	needwake = rcu_start_future_gp(rnp, rdp, &c);
+	needpoke = rcu_start_future_gp(rnp, rdp, &c);
 	raw_spin_unlock_irqrestore(&rnp->lock, flags);
-	if (needwake)
-		rcu_gp_kthread_wake(rdp->rsp);
+	if (needpoke)
+		rcu_gp_kthread_worker_poke(rdp->rsp);
 
 	/*
 	 * Wait for the grace period.  Do so interruptibly to avoid messing
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
