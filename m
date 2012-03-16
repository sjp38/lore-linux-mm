Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id DCA166B00FE
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:12 -0400 (EDT)
Message-Id: <20120316144241.215796412@chello.nl>
Date: Fri, 16 Mar 2012 15:40:45 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 17/26] srcu: revert1
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=srcu-revert-1.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

    rcu: Call out dangers of expedited RCU primitives

    The expedited RCU primitives can be quite useful, but they have some
    high costs as well.  This commit updates and creates docbook comments
    calling out the costs, and updates the RCU documentation as well.

    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/RCU/checklist.txt |   14 --------------
 include/linux/rcutree.h         |   16 ----------------
 kernel/rcutree.c                |   22 ++++++++--------------
 kernel/rcutree_plugin.h         |   20 ++++----------------
 kernel/srcu.c                   |   27 ++++++++++-----------------
 5 files changed, 22 insertions(+), 77 deletions(-)

--- a/Documentation/RCU/checklist.txt
+++ b/Documentation/RCU/checklist.txt
@@ -180,20 +180,6 @@ over a rather long period of time, but i
 	operations that would not normally be undertaken while a real-time
 	workload is running.
 
-	In particular, if you find yourself invoking one of the expedited
-	primitives repeatedly in a loop, please do everyone a favor:
-	Restructure your code so that it batches the updates, allowing
-	a single non-expedited primitive to cover the entire batch.
-	This will very likely be faster than the loop containing the
-	expedited primitive, and will be much much easier on the rest
-	of the system, especially to real-time workloads running on
-	the rest of the system.
-
-	In addition, it is illegal to call the expedited forms from
-	a CPU-hotplug notifier, or while holding a lock that is acquired
-	by a CPU-hotplug notifier.  Failing to observe this restriction
-	will result in deadlock.
-
 7.	If the updater uses call_rcu() or synchronize_rcu(), then the
 	corresponding readers must use rcu_read_lock() and
 	rcu_read_unlock().  If the updater uses call_rcu_bh() or
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -63,22 +63,6 @@ extern void synchronize_rcu_expedited(vo
 
 void kfree_call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *rcu));
 
-/**
- * synchronize_rcu_bh_expedited - Brute-force RCU-bh grace period
- *
- * Wait for an RCU-bh grace period to elapse, but use a "big hammer"
- * approach to force the grace period to end quickly.  This consumes
- * significant time on all CPUs and is unfriendly to real-time workloads,
- * so is thus not recommended for any sort of common-case code.  In fact,
- * if you are using synchronize_rcu_bh_expedited() in a loop, please
- * restructure your code to batch your updates, and then use a single
- * synchronize_rcu_bh() instead.
- *
- * Note that it is illegal to call this function while holding any lock
- * that is acquired by a CPU-hotplug notifier.  And yes, it is also illegal
- * to call this function from a CPU-hotplug notifier.  Failing to observe
- * these restriction will result in deadlock.
- */
 static inline void synchronize_rcu_bh_expedited(void)
 {
 	synchronize_sched_expedited();
--- a/kernel/rcutree.c
+++ b/kernel/rcutree.c
@@ -1970,21 +1970,15 @@ static int synchronize_sched_expedited_c
 	return 0;
 }
 
-/**
- * synchronize_sched_expedited - Brute-force RCU-sched grace period
- *
- * Wait for an RCU-sched grace period to elapse, but use a "big hammer"
- * approach to force the grace period to end quickly.  This consumes
- * significant time on all CPUs and is unfriendly to real-time workloads,
- * so is thus not recommended for any sort of common-case code.  In fact,
- * if you are using synchronize_sched_expedited() in a loop, please
- * restructure your code to batch your updates, and then use a single
- * synchronize_sched() instead.
+/*
+ * Wait for an rcu-sched grace period to elapse, but use "big hammer"
+ * approach to force grace period to end quickly.  This consumes
+ * significant time on all CPUs, and is thus not recommended for
+ * any sort of common-case code.
  *
- * Note that it is illegal to call this function while holding any lock
- * that is acquired by a CPU-hotplug notifier.  And yes, it is also illegal
- * to call this function from a CPU-hotplug notifier.  Failing to observe
- * these restriction will result in deadlock.
+ * Note that it is illegal to call this function while holding any
+ * lock that is acquired by a CPU-hotplug notifier.  Failing to
+ * observe this restriction will result in deadlock.
  *
  * This implementation can be thought of as an application of ticket
  * locking to RCU, with sync_sched_expedited_started and
--- a/kernel/rcutree_plugin.h
+++ b/kernel/rcutree_plugin.h
@@ -835,22 +835,10 @@ sync_rcu_preempt_exp_init(struct rcu_sta
 		rcu_report_exp_rnp(rsp, rnp, false); /* Don't wake self. */
 }
 
-/**
- * synchronize_rcu_expedited - Brute-force RCU grace period
- *
- * Wait for an RCU-preempt grace period, but expedite it.  The basic
- * idea is to invoke synchronize_sched_expedited() to push all the tasks to
- * the ->blkd_tasks lists and wait for this list to drain.  This consumes
- * significant time on all CPUs and is unfriendly to real-time workloads,
- * so is thus not recommended for any sort of common-case code.
- * In fact, if you are using synchronize_rcu_expedited() in a loop,
- * please restructure your code to batch your updates, and then Use a
- * single synchronize_rcu() instead.
- *
- * Note that it is illegal to call this function while holding any lock
- * that is acquired by a CPU-hotplug notifier.  And yes, it is also illegal
- * to call this function from a CPU-hotplug notifier.  Failing to observe
- * these restriction will result in deadlock.
+/*
+ * Wait for an rcu-preempt grace period, but expedite it.  The basic idea
+ * is to invoke synchronize_sched_expedited() to push all the tasks to
+ * the ->blkd_tasks lists and wait for this list to drain.
  */
 void synchronize_rcu_expedited(void)
 {
--- a/kernel/srcu.c
+++ b/kernel/srcu.c
@@ -286,26 +286,19 @@ void synchronize_srcu(struct srcu_struct
 EXPORT_SYMBOL_GPL(synchronize_srcu);
 
 /**
- * synchronize_srcu_expedited - Brute-force SRCU grace period
+ * synchronize_srcu_expedited - like synchronize_srcu, but less patient
  * @sp: srcu_struct with which to synchronize.
  *
- * Wait for an SRCU grace period to elapse, but use a "big hammer"
- * approach to force the grace period to end quickly.  This consumes
- * significant time on all CPUs and is unfriendly to real-time workloads,
- * so is thus not recommended for any sort of common-case code.  In fact,
- * if you are using synchronize_srcu_expedited() in a loop, please
- * restructure your code to batch your updates, and then use a single
- * synchronize_srcu() instead.
+ * Flip the completed counter, and wait for the old count to drain to zero.
+ * As with classic RCU, the updater must use some separate means of
+ * synchronizing concurrent updates.  Can block; must be called from
+ * process context.
  *
- * Note that it is illegal to call this function while holding any lock
- * that is acquired by a CPU-hotplug notifier.  And yes, it is also illegal
- * to call this function from a CPU-hotplug notifier.  Failing to observe
- * these restriction will result in deadlock.  It is also illegal to call
- * synchronize_srcu_expedited() from the corresponding SRCU read-side
- * critical section; doing so will result in deadlock.  However, it is
- * perfectly legal to call synchronize_srcu_expedited() on one srcu_struct
- * from some other srcu_struct's read-side critical section, as long as
- * the resulting graph of srcu_structs is acyclic.
+ * Note that it is illegal to call synchronize_srcu_expedited()
+ * from the corresponding SRCU read-side critical section; doing so
+ * will result in deadlock.  However, it is perfectly legal to call
+ * synchronize_srcu_expedited() on one srcu_struct from some other
+ * srcu_struct's read-side critical section.
  */
 void synchronize_srcu_expedited(struct srcu_struct *sp)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
