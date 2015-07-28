Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id B9CB86B025C
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:18 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so182503074wic.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex6si18412425wid.103.2015.07.28.07.40.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:11 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 08/14] rcu: Convert RCU gp kthreads into kthread worker API
Date: Tue, 28 Jul 2015 16:39:25 +0200
Message-Id: <1438094371-8326-9-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
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
single thread for the work. It helps to make sure that it is
available when needed. Also it allows a better control, e.g.
define a scheduling priority.

This patch converts RCU gp threads into the kthread worker API.
They modify the scheduling, have their own logic to bind the process.
They provide functions that are critical for the system to work
and thus deserve a dedicated kthread. In fact, they most likely
could not be implemented using workqueues because workqueues
are implemented using RCU.

The conversion is rather straightforward. It moves the code from
the main cycle into a single work because they should be done
together.

Note that we would like to provide more helper functions in
the kthread worker API and hide access to worker.task in the
long term. But it is not completely solved in this RFC.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/rcu/tree.c | 175 +++++++++++++++++++++++++++++-------------------------
 kernel/rcu/tree.h |   4 +-
 2 files changed, 96 insertions(+), 83 deletions(-)

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 65137bc28b2b..475bd59509ed 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -485,7 +485,7 @@ void show_rcu_gp_kthreads(void)
 
 	for_each_rcu_flavor(rsp) {
 		pr_info("%s: wait state: %d ->state: %#lx\n",
-			rsp->name, rsp->gp_state, rsp->gp_kthread->state);
+			rsp->name, rsp->gp_state, rsp->gp_worker.task->state);
 		/* sched_show_task(rsp->gp_kthread); */
 	}
 }
@@ -1586,9 +1586,9 @@ static int rcu_future_gp_cleanup(struct rcu_state *rsp, struct rcu_node *rnp)
  */
 static void rcu_gp_kthread_wake(struct rcu_state *rsp)
 {
-	if (current == rsp->gp_kthread ||
+	if (current == rsp->gp_worker.task ||
 	    !READ_ONCE(rsp->gp_flags) ||
-	    !rsp->gp_kthread)
+	    !rsp->gp_worker.task)
 		return;
 	wake_up(&rsp->gp_wq);
 }
@@ -2017,101 +2017,109 @@ static void rcu_gp_cleanup(struct rcu_state *rsp)
 	raw_spin_unlock_irq(&rnp->lock);
 }
 
+static void rcu_gp_kthread_init_func(struct kthread_work *work)
+{
+	struct rcu_state *rsp = container_of(work, struct rcu_state,
+					     gp_init_work);
+
+	rcu_bind_gp_kthread();
+
+	queue_kthread_work(&rsp->gp_worker, &rsp->gp_work);
+}
+
 /*
- * Body of kthread that handles grace periods.
+ * Main work of kthread that handles grace periods.
  */
-static int __noreturn rcu_gp_kthread(void *arg)
+static void rcu_gp_kthread_func(struct kthread_work *work)
 {
 	int fqs_state;
 	int gf;
 	unsigned long j;
 	int ret;
-	struct rcu_state *rsp = arg;
+	struct rcu_state *rsp = container_of(work, struct rcu_state, gp_work);
 	struct rcu_node *rnp = rcu_get_root(rsp);
 
-	rcu_bind_gp_kthread();
+	/* Handle grace-period start. */
 	for (;;) {
+		trace_rcu_grace_period(rsp->name,
+				       READ_ONCE(rsp->gpnum),
+				       TPS("reqwait"));
+		rsp->gp_state = RCU_GP_WAIT_GPS;
+		wait_event_interruptible(rsp->gp_wq,
+					 READ_ONCE(rsp->gp_flags) &
+					 RCU_GP_FLAG_INIT);
+		/* Locking provides needed memory barrier. */
+		if (rcu_gp_init(rsp))
+			break;
+		cond_resched_rcu_qs();
+		WRITE_ONCE(rsp->gp_activity, jiffies);
+		WARN_ON(signal_pending(current));
+		trace_rcu_grace_period(rsp->name,
+				       READ_ONCE(rsp->gpnum),
+				       TPS("reqwaitsig"));
+	}
 
-		/* Handle grace-period start. */
-		for (;;) {
+	/* Handle quiescent-state forcing. */
+	fqs_state = RCU_SAVE_DYNTICK;
+	j = jiffies_till_first_fqs;
+	if (j > HZ) {
+		j = HZ;
+		jiffies_till_first_fqs = HZ;
+	}
+	ret = 0;
+	for (;;) {
+		if (!ret)
+			rsp->jiffies_force_qs = jiffies + j;
+		trace_rcu_grace_period(rsp->name,
+				       READ_ONCE(rsp->gpnum),
+				       TPS("fqswait"));
+		rsp->gp_state = RCU_GP_WAIT_FQS;
+		ret = wait_event_interruptible_timeout(rsp->gp_wq,
+				((gf = READ_ONCE(rsp->gp_flags)) &
+				 RCU_GP_FLAG_FQS) ||
+				(!READ_ONCE(rnp->qsmask) &&
+				 !rcu_preempt_blocked_readers_cgp(rnp)),
+				j);
+		/* Locking provides needed memory barriers. */
+		/* If grace period done, leave loop. */
+		if (!READ_ONCE(rnp->qsmask) &&
+		    !rcu_preempt_blocked_readers_cgp(rnp))
+			break;
+		/* If time for quiescent-state forcing, do it. */
+		if (ULONG_CMP_GE(jiffies, rsp->jiffies_force_qs) ||
+		    (gf & RCU_GP_FLAG_FQS)) {
 			trace_rcu_grace_period(rsp->name,
 					       READ_ONCE(rsp->gpnum),
-					       TPS("reqwait"));
-			rsp->gp_state = RCU_GP_WAIT_GPS;
-			wait_event_interruptible(rsp->gp_wq,
-						 READ_ONCE(rsp->gp_flags) &
-						 RCU_GP_FLAG_INIT);
-			/* Locking provides needed memory barrier. */
-			if (rcu_gp_init(rsp))
-				break;
+					       TPS("fqsstart"));
+			fqs_state = rcu_gp_fqs(rsp, fqs_state);
+			trace_rcu_grace_period(rsp->name,
+					       READ_ONCE(rsp->gpnum),
+					       TPS("fqsend"));
+			cond_resched_rcu_qs();
+			WRITE_ONCE(rsp->gp_activity, jiffies);
+		} else {
+			/* Deal with stray signal. */
 			cond_resched_rcu_qs();
 			WRITE_ONCE(rsp->gp_activity, jiffies);
 			WARN_ON(signal_pending(current));
 			trace_rcu_grace_period(rsp->name,
 					       READ_ONCE(rsp->gpnum),
-					       TPS("reqwaitsig"));
+					       TPS("fqswaitsig"));
 		}
-
-		/* Handle quiescent-state forcing. */
-		fqs_state = RCU_SAVE_DYNTICK;
-		j = jiffies_till_first_fqs;
+		j = jiffies_till_next_fqs;
 		if (j > HZ) {
 			j = HZ;
-			jiffies_till_first_fqs = HZ;
+			jiffies_till_next_fqs = HZ;
+		} else if (j < 1) {
+			j = 1;
+			jiffies_till_next_fqs = 1;
 		}
-		ret = 0;
-		for (;;) {
-			if (!ret)
-				rsp->jiffies_force_qs = jiffies + j;
-			trace_rcu_grace_period(rsp->name,
-					       READ_ONCE(rsp->gpnum),
-					       TPS("fqswait"));
-			rsp->gp_state = RCU_GP_WAIT_FQS;
-			ret = wait_event_interruptible_timeout(rsp->gp_wq,
-					((gf = READ_ONCE(rsp->gp_flags)) &
-					 RCU_GP_FLAG_FQS) ||
-					(!READ_ONCE(rnp->qsmask) &&
-					 !rcu_preempt_blocked_readers_cgp(rnp)),
-					j);
-			/* Locking provides needed memory barriers. */
-			/* If grace period done, leave loop. */
-			if (!READ_ONCE(rnp->qsmask) &&
-			    !rcu_preempt_blocked_readers_cgp(rnp))
-				break;
-			/* If time for quiescent-state forcing, do it. */
-			if (ULONG_CMP_GE(jiffies, rsp->jiffies_force_qs) ||
-			    (gf & RCU_GP_FLAG_FQS)) {
-				trace_rcu_grace_period(rsp->name,
-						       READ_ONCE(rsp->gpnum),
-						       TPS("fqsstart"));
-				fqs_state = rcu_gp_fqs(rsp, fqs_state);
-				trace_rcu_grace_period(rsp->name,
-						       READ_ONCE(rsp->gpnum),
-						       TPS("fqsend"));
-				cond_resched_rcu_qs();
-				WRITE_ONCE(rsp->gp_activity, jiffies);
-			} else {
-				/* Deal with stray signal. */
-				cond_resched_rcu_qs();
-				WRITE_ONCE(rsp->gp_activity, jiffies);
-				WARN_ON(signal_pending(current));
-				trace_rcu_grace_period(rsp->name,
-						       READ_ONCE(rsp->gpnum),
-						       TPS("fqswaitsig"));
-			}
-			j = jiffies_till_next_fqs;
-			if (j > HZ) {
-				j = HZ;
-				jiffies_till_next_fqs = HZ;
-			} else if (j < 1) {
-				j = 1;
-				jiffies_till_next_fqs = 1;
-			}
-		}
-
-		/* Handle grace-period end. */
-		rcu_gp_cleanup(rsp);
 	}
+
+	/* Handle grace-period end. */
+	rcu_gp_cleanup(rsp);
+
+	queue_kthread_work(&rsp->gp_worker, &rsp->gp_work);
 }
 
 /*
@@ -2129,7 +2137,7 @@ static bool
 rcu_start_gp_advanced(struct rcu_state *rsp, struct rcu_node *rnp,
 		      struct rcu_data *rdp)
 {
-	if (!rsp->gp_kthread || !cpu_needs_another_gp(rsp, rdp)) {
+	if (!rsp->gp_worker.task || !cpu_needs_another_gp(rsp, rdp)) {
 		/*
 		 * Either we have not yet spawned the grace-period
 		 * task, this CPU does not need another grace period,
@@ -3909,7 +3917,7 @@ static int __init rcu_spawn_gp_kthread(void)
 	struct rcu_node *rnp;
 	struct rcu_state *rsp;
 	struct sched_param sp;
-	struct task_struct *t;
+	int ret;
 
 	/* Force priority into range. */
 	if (IS_ENABLED(CONFIG_RCU_BOOST) && kthread_prio < 1)
@@ -3924,16 +3932,19 @@ static int __init rcu_spawn_gp_kthread(void)
 
 	rcu_scheduler_fully_active = 1;
 	for_each_rcu_flavor(rsp) {
-		t = kthread_create(rcu_gp_kthread, rsp, "%s", rsp->name);
-		BUG_ON(IS_ERR(t));
+		init_kthread_worker(&rsp->gp_worker);
+		init_kthread_work(&rsp->gp_init_work, rcu_gp_kthread_init_func);
+		init_kthread_work(&rsp->gp_work, rcu_gp_kthread_func);
+		ret = create_kthread_worker(&rsp->gp_worker, "%s", rsp->name);
+		BUG_ON(ret);
 		rnp = rcu_get_root(rsp);
 		raw_spin_lock_irqsave(&rnp->lock, flags);
-		rsp->gp_kthread = t;
 		if (kthread_prio) {
 			sp.sched_priority = kthread_prio;
-			sched_setscheduler_nocheck(t, SCHED_FIFO, &sp);
+			sched_setscheduler_nocheck(rsp->gp_worker.task,
+						   SCHED_FIFO, &sp);
 		}
-		wake_up_process(t);
+		queue_kthread_work(&rsp->gp_worker, &rsp->gp_init_work);
 		raw_spin_unlock_irqrestore(&rnp->lock, flags);
 	}
 	rcu_spawn_nocb_kthreads();
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index 4adb7ca0bf47..2f318d406a53 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -457,7 +457,9 @@ struct rcu_state {
 	u8	boost;				/* Subject to priority boost. */
 	unsigned long gpnum;			/* Current gp number. */
 	unsigned long completed;		/* # of last completed gp. */
-	struct task_struct *gp_kthread;		/* Task for grace periods. */
+	struct kthread_worker gp_worker;	/* Worker for grace periods */
+	struct kthread_work gp_init_work;	/* Init work for handling gp */
+	struct kthread_work gp_work;		/* Main work for handling gp */
 	wait_queue_head_t gp_wq;		/* Where GP task waits. */
 	short gp_flags;				/* Commands for GP task. */
 	short gp_state;				/* GP kthread sleep state. */
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
