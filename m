Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFE16B0005
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 13:19:42 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q12-v6so17681820plr.17
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 10:19:42 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0070.outbound.protection.outlook.com. [104.47.40.70])
        by mx.google.com with ESMTPS id 33-v6si8559873pla.452.2018.04.05.10.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 10:19:40 -0700 (PDT)
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: [PATCH 5/5] smp: Lazy synchronization for EQS CPUs in kick_all_cpus_sync()
Date: Thu,  5 Apr 2018 20:18:00 +0300
Message-Id: <20180405171800.5648-6-ynorov@caviumnetworks.com>
In-Reply-To: <20180405171800.5648-1-ynorov@caviumnetworks.com>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>
Cc: Yury Norov <ynorov@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

kick_all_cpus_sync() forces all CPUs to sync caches by sending broadcast
IPI.  If CPU is in extended quiescent state (idle task or nohz_full
userspace), this work may be done at the exit of this state. Delaying
synchronization helps to save power if CPU is in idle state and decrease
latency for real-time tasks.

This patch introduces rcu_get_eqs_cpus() and uses it in
kick_all_cpus_sync() to delay synchronization.

For task isolation (https://lkml.org/lkml/2017/11/3/589), IPI to the CPU
running isolated task is fatal, as it breaks isolation. The approach with
lazy synchronization helps to maintain isolated state.

I've tested it with test from task isolation series on ThunderX2 for
more than 10 hours (10k giga-ticks) without breaking isolation.

Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
---
 include/linux/rcutiny.h |  2 ++
 include/linux/rcutree.h |  1 +
 kernel/rcu/tiny.c       |  9 +++++++++
 kernel/rcu/tree.c       | 23 +++++++++++++++++++++++
 kernel/smp.c            | 21 +++++++++++++--------
 5 files changed, 48 insertions(+), 8 deletions(-)

diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index ce9beec35e34..dc7e2ea731fa 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -36,6 +36,8 @@ static inline int rcu_dynticks_snap(struct rcu_dynticks *rdtp)
 /* Never flag non-existent other CPUs! */
 static inline bool rcu_eqs_special_set(int cpu) { return false; }
 
+void rcu_get_eqs_cpus(struct cpumask *cpus, int choose_eqs);
+
 static inline unsigned long get_state_synchronize_rcu(void)
 {
 	return 0;
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index fd996cdf1833..7a34eb8c0df3 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -74,6 +74,7 @@ static inline void synchronize_rcu_bh_expedited(void)
 void rcu_barrier(void);
 void rcu_barrier_bh(void);
 void rcu_barrier_sched(void);
+void rcu_get_eqs_cpus(struct cpumask *cpus, int choose_eqs);
 unsigned long get_state_synchronize_rcu(void);
 void cond_synchronize_rcu(unsigned long oldstate);
 unsigned long get_state_synchronize_sched(void);
diff --git a/kernel/rcu/tiny.c b/kernel/rcu/tiny.c
index a64eee0db39e..d4e94e1b0570 100644
--- a/kernel/rcu/tiny.c
+++ b/kernel/rcu/tiny.c
@@ -128,6 +128,15 @@ void rcu_check_callbacks(int user)
 		rcu_note_voluntary_context_switch(current);
 }
 
+/*
+ * For tiny RCU, all CPUs are active (non-EQS).
+ */
+void rcu_get_eqs_cpus(struct cpumask *cpus, int choose_eqs)
+{
+	if (!choose_eqs)
+		cpumask_copy(cpus, cpu_online_mask);
+}
+
 /*
  * Invoke the RCU callbacks on the specified rcu_ctrlkblk structure
  * whose grace period has elapsed.
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 363f91776b66..cb0d3afe7ea8 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -419,6 +419,29 @@ bool rcu_eqs_special_set(int cpu)
 	return true;
 }
 
+/*
+ * Get EQS CPUs. If @choose_eqs is 0, set of active (non-EQS)
+ * CPUs is returned instead.
+ *
+ * Call with disabled preemption. Make sure @cpus is cleared.
+ */
+void rcu_get_eqs_cpus(struct cpumask *cpus, int choose_eqs)
+{
+	int cpu, in_eqs;
+	struct rcu_dynticks *rdtp;
+
+	for_each_online_cpu(cpu) {
+		rdtp = &per_cpu(rcu_dynticks, cpu);
+		in_eqs = rcu_dynticks_in_eqs(atomic_read(&rdtp->dynticks));
+
+		if (in_eqs && choose_eqs)
+			cpumask_set_cpu(cpu, cpus);
+
+		if (!in_eqs && !choose_eqs)
+			cpumask_set_cpu(cpu, cpus);
+	}
+}
+
 /*
  * Let the RCU core know that this CPU has gone through the scheduler,
  * which is a quiescent state.  This is called when the need for a
diff --git a/kernel/smp.c b/kernel/smp.c
index 084c8b3a2681..5e6cfb57da22 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -708,19 +708,24 @@ static void do_nothing(void *unused)
 /**
  * kick_all_cpus_sync - Force all cpus out of idle
  *
- * Used to synchronize the update of pm_idle function pointer. It's
- * called after the pointer is updated and returns after the dummy
- * callback function has been executed on all cpus. The execution of
- * the function can only happen on the remote cpus after they have
- * left the idle function which had been called via pm_idle function
- * pointer. So it's guaranteed that nothing uses the previous pointer
- * anymore.
+ * - on current CPU call smp_mb() explicitly;
+ * - on CPUs in extended quiescent state (idle or nohz_full userspace), memory
+ *   is synchronized at the exit of that mode, so do nothing (it's safe to delay
+ *   synchronization because EQS CPUs don't run kernel code);
+ * - on other CPUs fire IPI for synchronization, which implies barrier.
  */
 void kick_all_cpus_sync(void)
 {
+	struct cpumask active_cpus;
+
 	/* Make sure the change is visible before we kick the cpus */
 	smp_mb();
-	smp_call_function(do_nothing, NULL, 1);
+
+	cpumask_clear(&active_cpus);
+	preempt_disable();
+	rcu_get_eqs_cpus(&active_cpus, 0);
+	smp_call_function_many(&active_cpus, do_nothing, NULL, 1);
+	preempt_enable();
 }
 EXPORT_SYMBOL_GPL(kick_all_cpus_sync);
 
-- 
2.14.1
