Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 0BF7C6B004D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:27:30 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 39/39] autonuma: NUMA scheduler SMT awareness
Date: Mon, 26 Mar 2012 19:46:26 +0200
Message-Id: <1332783986-24195-40-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Add SMT awareness to the NUMA scheduler so that it will not move load
from fully idle SMT threads, to semi idle SMT threads.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_flags.h |   10 ++++++++
 kernel/sched/numa.c            |   50 +++++++++++++++++++++++++++++++++++++--
 mm/autonuma.c                  |    7 +++++
 3 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
index 9c702fd..d6b34b0 100644
--- a/include/linux/autonuma_flags.h
+++ b/include/linux/autonuma_flags.h
@@ -8,6 +8,7 @@ enum autonuma_flag {
 	AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG,
 	AUTONUMA_SCHED_CLONE_RESET_FLAG,
 	AUTONUMA_SCHED_FORK_RESET_FLAG,
+	AUTONUMA_SCHED_SMT_FLAG,
 	AUTONUMA_SCAN_PMD_FLAG,
 	AUTONUMA_SCAN_USE_WORKING_SET_FLAG,
 	AUTONUMA_MIGRATE_DEFER_FLAG,
@@ -43,6 +44,15 @@ static bool inline autonuma_sched_fork_reset(void)
 			  &autonuma_flags);
 }
 
+static bool inline autonuma_sched_smt(void)
+{
+#ifdef CONFIG_SCHED_SMT
+	return !!test_bit(AUTONUMA_SCHED_SMT_FLAG, &autonuma_flags);
+#else
+	return 0;
+#endif
+}
+
 static bool inline autonuma_scan_pmd(void)
 {
 	return !!test_bit(AUTONUMA_SCAN_PMD_FLAG, &autonuma_flags);
diff --git a/kernel/sched/numa.c b/kernel/sched/numa.c
index d51e1ec..4211305 100644
--- a/kernel/sched/numa.c
+++ b/kernel/sched/numa.c
@@ -11,6 +11,30 @@
 
 #include "sched.h"
 
+static inline bool idle_cpu_avg(int cpu, bool require_avg_idle)
+{
+	struct rq *rq = cpu_rq(cpu);
+	return idle_cpu(cpu) && (!require_avg_idle ||
+				 rq->avg_idle > sysctl_sched_migration_cost);
+}
+
+/* A false avg_idle param makes it easier for smt_idle() to return true */
+static bool smt_idle(int _cpu, bool require_avg_idle)
+{
+#ifdef CONFIG_SCHED_SMT
+	int cpu;
+
+	for_each_cpu_and(cpu, topology_thread_cpumask(_cpu), cpu_online_mask) {
+		if (cpu == _cpu)
+			continue;
+		if (!idle_cpu_avg(cpu, require_avg_idle))
+			return false;
+	}
+#endif
+
+	return true;
+}
+
 #define AUTONUMA_BALANCE_SCALE 1000
 
 /*
@@ -47,6 +71,7 @@ void sched_autonuma_balance(void)
 	int cpu, nid, selected_cpu, selected_nid;
 	int cpu_nid = numa_node_id();
 	int this_cpu = smp_processor_id();
+	int this_smt_idle;
 	unsigned long p_w, p_t, m_w, m_t;
 	unsigned long weight_delta_max, weight;
 	struct cpumask *allowed;
@@ -96,6 +121,7 @@ void sched_autonuma_balance(void)
 		weight_current[nid] = p_w*AUTONUMA_BALANCE_SCALE/p_t;
 	}
 
+	this_smt_idle = smt_idle(this_cpu, false);
 	bitmap_zero(mm_mask, NR_CPUS);
 	for_each_online_node(nid) {
 		if (nid == cpu_nid)
@@ -103,11 +129,24 @@ void sched_autonuma_balance(void)
 		for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
 			struct mm_struct *mm;
 			struct rq *rq = cpu_rq(cpu);
+			bool other_smt_idle;
 			if (!cpu_online(cpu))
 				continue;
 			weight_others[cpu] = LONG_MAX;
-			if (idle_cpu(cpu) &&
-			    rq->avg_idle > sysctl_sched_migration_cost) {
+
+			other_smt_idle = smt_idle(cpu, true);
+			if (autonuma_sched_smt() &&
+			    this_smt_idle && !other_smt_idle)
+				continue;
+
+			if (idle_cpu_avg(cpu, true)) {
+				if (autonuma_sched_smt() &&
+				    !this_smt_idle && other_smt_idle) {
+					/* NUMA affinity override */
+					weight_others[cpu] = -2;
+					continue;
+				}
+
 				if (weight_current[nid] >
 				    weight_current[cpu_nid] &&
 				    weight_current_mm[nid] >
@@ -115,6 +154,11 @@ void sched_autonuma_balance(void)
 					weight_others[cpu] = -1;
 				continue;
 			}
+
+			if (autonuma_sched_smt() &&
+			    this_smt_idle && cpu_rq(this_cpu)->nr_running <= 1)
+				continue;
+
 			mm = rq->curr->mm;
 			if (!mm)
 				continue;
@@ -169,7 +213,7 @@ void sched_autonuma_balance(void)
 				w_cpu_nid = weight_current_mm[cpu_nid];
 			}
 			if (w_nid > weight_others[cpu] &&
-			    w_nid > w_cpu_nid) {
+			    (w_nid > w_cpu_nid || weight_others[cpu] == -2)) {
 				weight = w_nid -
 					weight_others[cpu] +
 					w_nid -
diff --git a/mm/autonuma.c b/mm/autonuma.c
index 7ca4992..4cce6a1 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -23,6 +23,7 @@ unsigned long autonuma_flags __read_mostly =
 	(1<<AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG)|
 	(1<<AUTONUMA_SCHED_CLONE_RESET_FLAG)|
 	(1<<AUTONUMA_SCHED_FORK_RESET_FLAG)|
+	(1<<AUTONUMA_SCHED_SMT_FLAG)|
 #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
 	(1<<AUTONUMA_FLAG)|
 #endif
@@ -1089,6 +1090,9 @@ SYSFS_ENTRY(defer, AUTONUMA_MIGRATE_DEFER_FLAG);
 SYSFS_ENTRY(load_balance_strict, AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG);
 SYSFS_ENTRY(clone_reset, AUTONUMA_SCHED_CLONE_RESET_FLAG);
 SYSFS_ENTRY(fork_reset, AUTONUMA_SCHED_FORK_RESET_FLAG);
+#ifdef CONFIG_SCHED_SMT
+SYSFS_ENTRY(smt, AUTONUMA_SCHED_SMT_FLAG);
+#endif
 
 #undef SYSFS_ENTRY
 
@@ -1205,6 +1209,9 @@ static struct attribute *scheduler_attr[] = {
 	&clone_reset_attr.attr,
 	&fork_reset_attr.attr,
 	&load_balance_strict_attr.attr,
+#ifdef CONFIG_SCHED_SMT
+	&smt_attr.attr,
+#endif
 	NULL,
 };
 static struct attribute_group scheduler_attr_group = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
