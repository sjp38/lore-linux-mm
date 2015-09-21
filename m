Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 355B76B0261
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:49 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so115036677wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vh4si30940966wjc.162.2015.09.21.06.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:48 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 14/18] rcu: Store first_gp_fqs into struct rcu_state
Date: Mon, 21 Sep 2015 15:03:55 +0200
Message-Id: <1442840639-6963-15-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

We are going to try split the rcu kthread into few kthread works.
We will not stay in the funciton all the time and "first_gp_fqs"
variable will not preserve the state. Let's store it into
struct rcu_state.

Note that this change is needed only when the split into more
kthread works is accepted.

The patch does not change the existing behavior.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/rcu/tree.c | 11 +++++------
 kernel/rcu/tree.h |  2 ++
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 5413d87a67c6..5a3e70a21df8 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -1927,7 +1927,7 @@ static bool rcu_gp_fqs_check_wake(struct rcu_state *rsp, int *gfp)
 /*
  * Do one round of quiescent-state forcing.
  */
-static void rcu_gp_fqs(struct rcu_state *rsp, bool first_time)
+static void rcu_gp_fqs(struct rcu_state *rsp)
 {
 	bool isidle = false;
 	unsigned long maxj;
@@ -1935,7 +1935,7 @@ static void rcu_gp_fqs(struct rcu_state *rsp, bool first_time)
 
 	WRITE_ONCE(rsp->gp_activity, jiffies);
 	rsp->n_force_qs++;
-	if (first_time) {
+	if (rsp->first_gp_fqs) {
 		/* Collect dyntick-idle snapshots. */
 		if (is_sysidle_rcu_state(rsp)) {
 			isidle = true;
@@ -1944,6 +1944,7 @@ static void rcu_gp_fqs(struct rcu_state *rsp, bool first_time)
 		force_qs_rnp(rsp, dyntick_save_progress_counter,
 			     &isidle, &maxj);
 		rcu_sysidle_report_gp(rsp, isidle, maxj);
+		rsp->first_gp_fqs = false;
 	} else {
 		/* Handle dyntick-idle and offline CPUs. */
 		isidle = true;
@@ -2038,7 +2039,6 @@ static void rcu_gp_cleanup(struct rcu_state *rsp)
  */
 static int __noreturn rcu_gp_kthread(void *arg)
 {
-	bool first_gp_fqs;
 	int gf;
 	unsigned long j;
 	int ret;
@@ -2070,7 +2070,7 @@ static int __noreturn rcu_gp_kthread(void *arg)
 		}
 
 		/* Handle quiescent-state forcing. */
-		first_gp_fqs = true;
+		rsp->first_gp_fqs = true;
 		j = jiffies_till_first_fqs;
 		if (j > HZ) {
 			j = HZ;
@@ -2098,8 +2098,7 @@ static int __noreturn rcu_gp_kthread(void *arg)
 				trace_rcu_grace_period(rsp->name,
 						       READ_ONCE(rsp->gpnum),
 						       TPS("fqsstart"));
-				rcu_gp_fqs(rsp, first_gp_fqs);
-				first_gp_fqs = false;
+				rcu_gp_fqs(rsp);
 				trace_rcu_grace_period(rsp->name,
 						       READ_ONCE(rsp->gpnum),
 						       TPS("fqsend"));
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index de370b611837..f16578a5eefe 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -470,6 +470,8 @@ struct rcu_state {
 	wait_queue_head_t gp_wq;		/* Where GP task waits. */
 	short gp_flags;				/* Commands for GP task. */
 	short gp_state;				/* GP kthread sleep state. */
+	bool first_gp_fqs;			/* Do we force QS for */
+						/* the first time? */
 
 	/* End of fields guarded by root rcu_node's lock. */
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
