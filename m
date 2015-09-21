Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 042346B0262
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:53 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so115039358wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fv8si16999267wic.73.2015.09.21.06.05.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:51 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 15/18] rcu: Clean up timeouts for forcing the quiescent state
Date: Mon, 21 Sep 2015 15:03:56 +0200
Message-Id: <1442840639-6963-16-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

This patch does some code refactoring that will help us to split the rcu
kthread into more kthread works. It fixes rather theoretical and innocent
race. Otherwise, the changes should not be visible to the user.

First, it moves the code that limits the maximal timeout into separate
functions, see normalize_jiffies*().

The commit 88d6df612cc3c99f5 ("rcu: Prevent spurious-wakeup DoS attack
on rcu_gp_kthread()") suggests that a spurious wakeup is possible.
In this case, the thread continue waiting and
wait_event_interruptible_timeout() should be called with the remaining
timeout. It is newly computed in the new variable "timeout".

wait_event_interruptible_timeout() returns "1" when the condition is true
after the timeout elapsed. This might happen when there is a race between
fulfilling the condition and the wakeup. Therefore, it is cleaner to
update "rsp->jiffies_force_qs" when QS is forced and do not rely on
the "ret" value.

Finally, this the patch moves cond_resched_rcu_qs() to a single place.
It changes the order of the check for the pending signal. But there never
should be a pending signal. If there was we would have bigger problems
because wait_event() would never sleep again until someone flushed
the signal.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/rcu/tree.c | 77 ++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 53 insertions(+), 24 deletions(-)

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 5a3e70a21df8..286e300794f0 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -2035,13 +2035,45 @@ static void rcu_gp_cleanup(struct rcu_state *rsp)
 }
 
 /*
+ * Normalize, update, and return the first timeout.
+ */
+static unsigned long normalize_jiffies_till_first_fqs(void)
+{
+	unsigned long j = jiffies_till_first_fqs;
+
+	if (unlikely(j > HZ)) {
+		j = HZ;
+		jiffies_till_first_fqs = HZ;
+	}
+
+	return j;
+}
+
+/*
+ * Normalize, update, and return the next timeout.
+ */
+static unsigned long normalize_jiffies_till_next_fqs(void)
+{
+	unsigned long j = jiffies_till_next_fqs;
+
+	if (unlikely(j > HZ)) {
+		j = HZ;
+		jiffies_till_next_fqs = HZ;
+	} else if (unlikely(j < 1)) {
+		j = 1;
+		jiffies_till_next_fqs = 1;
+	}
+
+	return j;
+}
+
+/*
  * Body of kthread that handles grace periods.
  */
 static int __noreturn rcu_gp_kthread(void *arg)
 {
 	int gf;
-	unsigned long j;
-	int ret;
+	unsigned long timeout, j;
 	struct rcu_state *rsp = arg;
 	struct rcu_node *rnp = rcu_get_root(rsp);
 
@@ -2071,22 +2103,18 @@ static int __noreturn rcu_gp_kthread(void *arg)
 
 		/* Handle quiescent-state forcing. */
 		rsp->first_gp_fqs = true;
-		j = jiffies_till_first_fqs;
-		if (j > HZ) {
-			j = HZ;
-			jiffies_till_first_fqs = HZ;
-		}
-		ret = 0;
+		timeout = normalize_jiffies_till_first_fqs();
+		rsp->jiffies_force_qs = jiffies + timeout;
 		for (;;) {
-			if (!ret)
-				rsp->jiffies_force_qs = jiffies + j;
 			trace_rcu_grace_period(rsp->name,
 					       READ_ONCE(rsp->gpnum),
 					       TPS("fqswait"));
 			rsp->gp_state = RCU_GP_WAIT_FQS;
-			ret = wait_event_interruptible_timeout(rsp->gp_wq,
-					rcu_gp_fqs_check_wake(rsp, &gf), j);
+			wait_event_interruptible_timeout(rsp->gp_wq,
+					rcu_gp_fqs_check_wake(rsp, &gf),
+					timeout);
 			rsp->gp_state = RCU_GP_DOING_FQS;
+try_again:
 			/* Locking provides needed memory barriers. */
 			/* If grace period done, leave loop. */
 			if (!READ_ONCE(rnp->qsmask) &&
@@ -2099,28 +2127,29 @@ static int __noreturn rcu_gp_kthread(void *arg)
 						       READ_ONCE(rsp->gpnum),
 						       TPS("fqsstart"));
 				rcu_gp_fqs(rsp);
+				timeout = normalize_jiffies_till_next_fqs();
+				rsp->jiffies_force_qs = jiffies + timeout;
 				trace_rcu_grace_period(rsp->name,
 						       READ_ONCE(rsp->gpnum),
 						       TPS("fqsend"));
-				cond_resched_rcu_qs();
-				WRITE_ONCE(rsp->gp_activity, jiffies);
 			} else {
 				/* Deal with stray signal. */
-				cond_resched_rcu_qs();
-				WRITE_ONCE(rsp->gp_activity, jiffies);
 				WARN_ON(signal_pending(current));
 				trace_rcu_grace_period(rsp->name,
 						       READ_ONCE(rsp->gpnum),
 						       TPS("fqswaitsig"));
 			}
-			j = jiffies_till_next_fqs;
-			if (j > HZ) {
-				j = HZ;
-				jiffies_till_next_fqs = HZ;
-			} else if (j < 1) {
-				j = 1;
-				jiffies_till_next_fqs = 1;
-			}
+			cond_resched_rcu_qs();
+			WRITE_ONCE(rsp->gp_activity, jiffies);
+			/*
+			 * Count the remaining timeout when it was a spurious
+			 * wakeup. Well, it is useful also when we have slept
+			 * in the cond_resched().
+			 */
+			j = jiffies;
+			if (ULONG_CMP_GE(j, rsp->jiffies_force_qs))
+				goto try_again;
+			timeout = rsp->jiffies_force_qs - j;
 		}
 
 		/* Handle grace-period end. */
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
