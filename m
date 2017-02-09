Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF44C6B0389
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 18:51:08 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id q20so46754317ioi.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 15:51:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i81si251365ioe.204.2017.02.09.15.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 15:51:07 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v19NmdCe142283
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 18:51:07 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28gr4e2ct8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Feb 2017 18:51:07 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 9 Feb 2017 16:51:06 -0700
Date: Thu, 9 Feb 2017 15:51:03 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC v2 tip/core/rcu] Maintain special bits at bottom of
 ->dynticks counter
Reply-To: paulmck@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20170209235103.GA1368@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: luto@kernel.org, tglx@linutronix.de, fweisbec@gmail.com, cmetcalf@mellanox.com, peterz@infradead.org, mingo@kernel.org

    Currently, IPIs are used to force other CPUs to invalidate their TLBs
    in response to a kernel virtual-memory mapping change.  This works, but
    degrades both battery lifetime (for idle CPUs) and real-time response
    (for nohz_full CPUs), and in addition results in unnecessary IPIs due to
    the fact that CPUs executing in usermode are unaffected by stale kernel
    mappings.  It would be better to cause a CPU executing in usermode to
    wait until it is entering kernel mode to do the flush, first to avoid
    interrupting usemode tasks and second to handle multiple flush requests
    with a single flush in the case of a long-running user task.
    
    This commit therefore reserves a bit at the bottom of the ->dynticks
    counter, which is checked upon exit from extended quiescent states.
    If it is set, it is cleared and then a new rcu_eqs_special_exit() macro is
    invoked, which, if not supplied, is an empty single-pass do-while loop.
    If this bottom bit is set on -entry- to an extended quiescent state,
    then a WARN_ON_ONCE() triggers.
    
    This bottom bit may be set using a new rcu_eqs_special_set() function,
    which returns true if the bit was set, or false if the CPU turned
    out to not be in an extended quiescent state.  Please note that this
    function refuses to set the bit for a non-nohz_full CPU when that CPU
    is executing in usermode because usermode execution is tracked by RCU
    as a dyntick-idle extended quiescent state only for nohz_full CPUs.

    Changes since v1:  Fix ordering of atomic_and() and the call to
    rcu_eqs_special_exit() in rcu_dynticks_eqs_exit().
 
    Reported-by: Andy Lutomirski <luto@amacapital.net>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index 4f9b2fa2173d..7232d199a81c 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -33,6 +33,11 @@ static inline int rcu_dynticks_snap(struct rcu_dynticks *rdtp)
 	return 0;
 }
 
+static inline bool rcu_eqs_special_set(int cpu)
+{
+	return false;  /* Never flag non-existent other CPUs! */
+}
+
 static inline unsigned long get_state_synchronize_rcu(void)
 {
 	return 0;
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index d80e0d2f68c6..a473c9b8987d 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -272,9 +272,19 @@ void rcu_bh_qs(void)
 
 static DEFINE_PER_CPU(int, rcu_sched_qs_mask);
 
+/*
+ * Steal a bit from the bottom of ->dynticks for idle entry/exit
+ * control.  Initially this is for TLB flushing.
+ */
+#define RCU_DYNTICK_CTRL_MASK 0x1
+#define RCU_DYNTICK_CTRL_CTR  (RCU_DYNTICK_CTRL_MASK + 1)
+#ifndef rcu_eqs_special_exit
+#define rcu_eqs_special_exit() do { } while (0)
+#endif
+
 static DEFINE_PER_CPU(struct rcu_dynticks, rcu_dynticks) = {
 	.dynticks_nesting = DYNTICK_TASK_EXIT_IDLE,
-	.dynticks = ATOMIC_INIT(1),
+	.dynticks = ATOMIC_INIT(RCU_DYNTICK_CTRL_CTR),
 #ifdef CONFIG_NO_HZ_FULL_SYSIDLE
 	.dynticks_idle_nesting = DYNTICK_TASK_NEST_VALUE,
 	.dynticks_idle = ATOMIC_INIT(1),
@@ -288,15 +298,20 @@ static DEFINE_PER_CPU(struct rcu_dynticks, rcu_dynticks) = {
 static void rcu_dynticks_eqs_enter(void)
 {
 	struct rcu_dynticks *rdtp = this_cpu_ptr(&rcu_dynticks);
-	int special;
+	int seq;
 
 	/*
 	 * CPUs seeing atomic_inc_return() must see prior RCU read-side
 	 * critical sections, and we also must force ordering with the
 	 * next idle sojourn.
 	 */
-	special = atomic_inc_return(&rdtp->dynticks);
-	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) && special & 0x1);
+	seq = atomic_add_return(RCU_DYNTICK_CTRL_CTR, &rdtp->dynticks);
+	/* Better be in an extended quiescent state! */
+	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) &&
+		     (seq & RCU_DYNTICK_CTRL_CTR));
+	/* Better not have special action (TLB flush) pending! */
+	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) &&
+		     (seq & RCU_DYNTICK_CTRL_MASK));
 }
 
 /*
@@ -306,15 +321,22 @@ static void rcu_dynticks_eqs_enter(void)
 static void rcu_dynticks_eqs_exit(void)
 {
 	struct rcu_dynticks *rdtp = this_cpu_ptr(&rcu_dynticks);
-	int special;
+	int seq;
 
 	/*
 	 * CPUs seeing atomic_inc_return() must see prior idle sojourns,
 	 * and we also must force ordering with the next RCU read-side
 	 * critical section.
 	 */
-	special = atomic_inc_return(&rdtp->dynticks);
-	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) && !(special & 0x1));
+	seq = atomic_add_return(RCU_DYNTICK_CTRL_CTR, &rdtp->dynticks);
+	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) &&
+		     !(seq & RCU_DYNTICK_CTRL_CTR));
+	if (seq & RCU_DYNTICK_CTRL_MASK) {
+		atomic_and(~RCU_DYNTICK_CTRL_MASK, &rdtp->dynticks);
+		smp_mb__after_atomic(); /* _exit after clearing mask. */
+		/* Prefer duplicate flushes to losing a flush. */
+		rcu_eqs_special_exit();
+	}
 }
 
 /*
@@ -331,9 +353,9 @@ static void rcu_dynticks_eqs_online(void)
 {
 	struct rcu_dynticks *rdtp = this_cpu_ptr(&rcu_dynticks);
 
-	if (atomic_read(&rdtp->dynticks) & 0x1)
+	if (atomic_read(&rdtp->dynticks) & RCU_DYNTICK_CTRL_CTR)
 		return;
-	atomic_add(0x1, &rdtp->dynticks);
+	atomic_add(RCU_DYNTICK_CTRL_CTR, &rdtp->dynticks);
 }
 
 /*
@@ -345,7 +367,7 @@ bool rcu_dynticks_curr_cpu_in_eqs(void)
 {
 	struct rcu_dynticks *rdtp = this_cpu_ptr(&rcu_dynticks);
 
-	return !(atomic_read(&rdtp->dynticks) & 0x1);
+	return !(atomic_read(&rdtp->dynticks) & RCU_DYNTICK_CTRL_CTR);
 }
 
 /*
@@ -356,7 +378,7 @@ int rcu_dynticks_snap(struct rcu_dynticks *rdtp)
 {
 	int snap = atomic_add_return(0, &rdtp->dynticks);
 
-	return snap;
+	return snap & ~RCU_DYNTICK_CTRL_MASK;
 }
 
 /*
@@ -365,7 +387,7 @@ int rcu_dynticks_snap(struct rcu_dynticks *rdtp)
  */
 static bool rcu_dynticks_in_eqs(int snap)
 {
-	return !(snap & 0x1);
+	return !(snap & RCU_DYNTICK_CTRL_CTR);
 }
 
 /*
@@ -385,10 +407,33 @@ static bool rcu_dynticks_in_eqs_since(struct rcu_dynticks *rdtp, int snap)
 static void rcu_dynticks_momentary_idle(void)
 {
 	struct rcu_dynticks *rdtp = this_cpu_ptr(&rcu_dynticks);
-	int special = atomic_add_return(2, &rdtp->dynticks);
+	int special = atomic_add_return(2 * RCU_DYNTICK_CTRL_CTR,
+					&rdtp->dynticks);
 
 	/* It is illegal to call this from idle state. */
-	WARN_ON_ONCE(!(special & 0x1));
+	WARN_ON_ONCE(!(special & RCU_DYNTICK_CTRL_CTR));
+}
+
+/*
+ * Set the special (bottom) bit of the specified CPU so that it
+ * will take special action (such as flushing its TLB) on the
+ * next exit from an extended quiescent state.  Returns true if
+ * the bit was successfully set, or false if the CPU was not in
+ * an extended quiescent state.
+ */
+bool rcu_eqs_special_set(int cpu)
+{
+	int old;
+	int new;
+	struct rcu_dynticks *rdtp = &per_cpu(rcu_dynticks, cpu);
+
+	do {
+		old = atomic_read(&rdtp->dynticks);
+		if (old & RCU_DYNTICK_CTRL_CTR)
+			return false;
+		new = old | RCU_DYNTICK_CTRL_MASK;
+	} while (atomic_cmpxchg(&rdtp->dynticks, old, new) != old);
+	return true;
 }
 
 DEFINE_PER_CPU_SHARED_ALIGNED(unsigned long, rcu_qs_ctr);
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index b60f2b6caa14..5a2ad582b4b6 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -595,6 +595,7 @@ extern struct rcu_state rcu_preempt_state;
 #endif /* #ifdef CONFIG_PREEMPT_RCU */
 
 int rcu_dynticks_snap(struct rcu_dynticks *rdtp);
+bool rcu_eqs_special_set(int cpu);
 
 #ifdef CONFIG_RCU_BOOST
 DECLARE_PER_CPU(unsigned int, rcu_cpu_kthread_status);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
