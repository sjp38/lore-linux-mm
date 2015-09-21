Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F1B2F6B025F
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:45 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so144845801wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id go6si3936948wib.82.2015.09.21.06.05.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:44 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 13/18] rcu: Finish folding ->fqs_state into ->gp_state
Date: Mon, 21 Sep 2015 15:03:54 +0200
Message-Id: <1442840639-6963-14-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Commit commit 4cdfc175c25c89ee ("rcu: Move quiescent-state forcing
into kthread") started the process of folding the old ->fqs_state into
->gp_state, but did not complete it.  This situation does not cause
any malfunction, but can result in extremely confusing trace output.
This commit completes this task of eliminating ->fqs_state in favor
of ->gp_state.

The old ->fqs_state was also used to decide when to collect dyntick-idle
snapshots.  For this purpose, we add a boolean variable into the kthread,
which is set on the first call to rcu_gp_fqs() for a given grace period
and clear otherwise.

Signed-off-by: Petr Mladek <pmladek@suse.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 kernel/rcu/tree.c       | 18 ++++++++----------
 kernel/rcu/tree.h       | 14 +++-----------
 kernel/rcu/tree_trace.c |  2 +-
 3 files changed, 12 insertions(+), 22 deletions(-)

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 9f75f25cc5d9..5413d87a67c6 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -98,7 +98,7 @@ struct rcu_state sname##_state = { \
 	.level = { &sname##_state.node[0] }, \
 	.rda = &sname##_data, \
 	.call = cr, \
-	.fqs_state = RCU_GP_IDLE, \
+	.gp_state = RCU_GP_IDLE, \
 	.gpnum = 0UL - 300UL, \
 	.completed = 0UL - 300UL, \
 	.orphan_lock = __RAW_SPIN_LOCK_UNLOCKED(&sname##_state.orphan_lock), \
@@ -1927,16 +1927,15 @@ static bool rcu_gp_fqs_check_wake(struct rcu_state *rsp, int *gfp)
 /*
  * Do one round of quiescent-state forcing.
  */
-static int rcu_gp_fqs(struct rcu_state *rsp, int fqs_state_in)
+static void rcu_gp_fqs(struct rcu_state *rsp, bool first_time)
 {
-	int fqs_state = fqs_state_in;
 	bool isidle = false;
 	unsigned long maxj;
 	struct rcu_node *rnp = rcu_get_root(rsp);
 
 	WRITE_ONCE(rsp->gp_activity, jiffies);
 	rsp->n_force_qs++;
-	if (fqs_state == RCU_SAVE_DYNTICK) {
+	if (first_time) {
 		/* Collect dyntick-idle snapshots. */
 		if (is_sysidle_rcu_state(rsp)) {
 			isidle = true;
@@ -1945,7 +1944,6 @@ static int rcu_gp_fqs(struct rcu_state *rsp, int fqs_state_in)
 		force_qs_rnp(rsp, dyntick_save_progress_counter,
 			     &isidle, &maxj);
 		rcu_sysidle_report_gp(rsp, isidle, maxj);
-		fqs_state = RCU_FORCE_QS;
 	} else {
 		/* Handle dyntick-idle and offline CPUs. */
 		isidle = true;
@@ -1959,7 +1957,6 @@ static int rcu_gp_fqs(struct rcu_state *rsp, int fqs_state_in)
 			   READ_ONCE(rsp->gp_flags) & ~RCU_GP_FLAG_FQS);
 		raw_spin_unlock_irq(&rnp->lock);
 	}
-	return fqs_state;
 }
 
 /*
@@ -2023,7 +2020,7 @@ static void rcu_gp_cleanup(struct rcu_state *rsp)
 	/* Declare grace period done. */
 	WRITE_ONCE(rsp->completed, rsp->gpnum);
 	trace_rcu_grace_period(rsp->name, rsp->completed, TPS("end"));
-	rsp->fqs_state = RCU_GP_IDLE;
+	rsp->gp_state = RCU_GP_IDLE;
 	rdp = this_cpu_ptr(rsp->rda);
 	/* Advance CBs to reduce false positives below. */
 	needgp = rcu_advance_cbs(rsp, rnp, rdp) || needgp;
@@ -2041,7 +2038,7 @@ static void rcu_gp_cleanup(struct rcu_state *rsp)
  */
 static int __noreturn rcu_gp_kthread(void *arg)
 {
-	int fqs_state;
+	bool first_gp_fqs;
 	int gf;
 	unsigned long j;
 	int ret;
@@ -2073,7 +2070,7 @@ static int __noreturn rcu_gp_kthread(void *arg)
 		}
 
 		/* Handle quiescent-state forcing. */
-		fqs_state = RCU_SAVE_DYNTICK;
+		first_gp_fqs = true;
 		j = jiffies_till_first_fqs;
 		if (j > HZ) {
 			j = HZ;
@@ -2101,7 +2098,8 @@ static int __noreturn rcu_gp_kthread(void *arg)
 				trace_rcu_grace_period(rsp->name,
 						       READ_ONCE(rsp->gpnum),
 						       TPS("fqsstart"));
-				fqs_state = rcu_gp_fqs(rsp, fqs_state);
+				rcu_gp_fqs(rsp, first_gp_fqs);
+				first_gp_fqs = false;
 				trace_rcu_grace_period(rsp->name,
 						       READ_ONCE(rsp->gpnum),
 						       TPS("fqsend"));
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index 2e991f8361e4..de370b611837 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -412,13 +412,6 @@ struct rcu_data {
 	struct rcu_state *rsp;
 };
 
-/* Values for fqs_state field in struct rcu_state. */
-#define RCU_GP_IDLE		0	/* No grace period in progress. */
-#define RCU_GP_INIT		1	/* Grace period being initialized. */
-#define RCU_SAVE_DYNTICK	2	/* Need to scan dyntick state. */
-#define RCU_FORCE_QS		3	/* Need to force quiescent state. */
-#define RCU_SIGNAL_INIT		RCU_SAVE_DYNTICK
-
 /* Values for nocb_defer_wakeup field in struct rcu_data. */
 #define RCU_NOGP_WAKE_NOT	0
 #define RCU_NOGP_WAKE		1
@@ -469,9 +462,8 @@ struct rcu_state {
 
 	/* The following fields are guarded by the root rcu_node's lock. */
 
-	u8	fqs_state ____cacheline_internodealigned_in_smp;
-						/* Force QS state. */
-	u8	boost;				/* Subject to priority boost. */
+	u8	boost ____cacheline_internodealigned_in_smp;
+						/* Subject to priority boost. */
 	unsigned long gpnum;			/* Current gp number. */
 	unsigned long completed;		/* # of last completed gp. */
 	struct task_struct *gp_kthread;		/* Task for grace periods. */
@@ -539,7 +531,7 @@ struct rcu_state {
 #define RCU_GP_FLAG_FQS  0x2	/* Need grace-period quiescent-state forcing. */
 
 /* Values for rcu_state structure's gp_flags field. */
-#define RCU_GP_WAIT_INIT 0	/* Initial state. */
+#define RCU_GP_IDLE	 0	/* Initial state and no GP in progress. */
 #define RCU_GP_WAIT_GPS  1	/* Wait for grace-period start. */
 #define RCU_GP_DONE_GPS  2	/* Wait done for grace-period start. */
 #define RCU_GP_WAIT_FQS  3	/* Wait for force-quiescent-state time. */
diff --git a/kernel/rcu/tree_trace.c b/kernel/rcu/tree_trace.c
index 6fc4c5ff3bb5..1d61f5ba4641 100644
--- a/kernel/rcu/tree_trace.c
+++ b/kernel/rcu/tree_trace.c
@@ -268,7 +268,7 @@ static void print_one_rcu_state(struct seq_file *m, struct rcu_state *rsp)
 	gpnum = rsp->gpnum;
 	seq_printf(m, "c=%ld g=%ld s=%d jfq=%ld j=%x ",
 		   ulong2long(rsp->completed), ulong2long(gpnum),
-		   rsp->fqs_state,
+		   rsp->gp_state,
 		   (long)(rsp->jiffies_force_qs - jiffies),
 		   (int)(jiffies & 0xffff));
 	seq_printf(m, "nfqs=%lu/nfqsng=%lu(%lu) fqlh=%lu oqlen=%ld/%ld\n",
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
