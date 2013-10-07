Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 21F4C9C0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:33 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so6897473pbc.3
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:32 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 52/63] sched: numa: add debugging
Date: Mon,  7 Oct 2013 11:29:30 +0100
Message-Id: <1381141781-10992-53-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Ingo Molnar <mingo@kernel.org>

Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Link: http://lkml.kernel.org/n/tip-5giqjcqnc93a89q01ymtjxpr@git.kernel.org
---
 include/linux/sched.h |  6 ++++++
 kernel/sched/debug.c  | 60 +++++++++++++++++++++++++++++++++++++++++++++++++--
 kernel/sched/fair.c   |  5 ++++-
 3 files changed, 68 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5315607..390004b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1356,6 +1356,7 @@ struct task_struct {
 	unsigned long *numa_faults_buffer;
 
 	int numa_preferred_nid;
+	unsigned long numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
@@ -2587,6 +2588,11 @@ static inline unsigned int task_cpu(const struct task_struct *p)
 	return task_thread_info(p)->cpu;
 }
 
+static inline int task_node(const struct task_struct *p)
+{
+	return cpu_to_node(task_cpu(p));
+}
+
 extern void set_task_cpu(struct task_struct *p, unsigned int cpu);
 
 #else
diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index 1965599..e6ba5e3 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -15,6 +15,7 @@
 #include <linux/seq_file.h>
 #include <linux/kallsyms.h>
 #include <linux/utsname.h>
+#include <linux/mempolicy.h>
 
 #include "sched.h"
 
@@ -137,6 +138,9 @@ print_task(struct seq_file *m, struct rq *rq, struct task_struct *p)
 	SEQ_printf(m, "%15Ld %15Ld %15Ld.%06ld %15Ld.%06ld %15Ld.%06ld",
 		0LL, 0LL, 0LL, 0L, 0LL, 0L, 0LL, 0L);
 #endif
+#ifdef CONFIG_NUMA_BALANCING
+	SEQ_printf(m, " %d", cpu_to_node(task_cpu(p)));
+#endif
 #ifdef CONFIG_CGROUP_SCHED
 	SEQ_printf(m, " %s", task_group_path(task_group(p)));
 #endif
@@ -159,7 +163,7 @@ static void print_rq(struct seq_file *m, struct rq *rq, int rq_cpu)
 	read_lock_irqsave(&tasklist_lock, flags);
 
 	do_each_thread(g, p) {
-		if (!p->on_rq || task_cpu(p) != rq_cpu)
+		if (task_cpu(p) != rq_cpu)
 			continue;
 
 		print_task(m, rq, p);
@@ -345,7 +349,7 @@ static void sched_debug_header(struct seq_file *m)
 	cpu_clk = local_clock();
 	local_irq_restore(flags);
 
-	SEQ_printf(m, "Sched Debug Version: v0.10, %s %.*s\n",
+	SEQ_printf(m, "Sched Debug Version: v0.11, %s %.*s\n",
 		init_utsname()->release,
 		(int)strcspn(init_utsname()->version, " "),
 		init_utsname()->version);
@@ -488,6 +492,56 @@ static int __init init_sched_debug_procfs(void)
 
 __initcall(init_sched_debug_procfs);
 
+#define __P(F) \
+	SEQ_printf(m, "%-45s:%21Ld\n", #F, (long long)F)
+#define P(F) \
+	SEQ_printf(m, "%-45s:%21Ld\n", #F, (long long)p->F)
+#define __PN(F) \
+	SEQ_printf(m, "%-45s:%14Ld.%06ld\n", #F, SPLIT_NS((long long)F))
+#define PN(F) \
+	SEQ_printf(m, "%-45s:%14Ld.%06ld\n", #F, SPLIT_NS((long long)p->F))
+
+
+static void sched_show_numa(struct task_struct *p, struct seq_file *m)
+{
+#ifdef CONFIG_NUMA_BALANCING
+	struct mempolicy *pol;
+	int node, i;
+
+	if (p->mm)
+		P(mm->numa_scan_seq);
+
+	task_lock(p);
+	pol = p->mempolicy;
+	if (pol && !(pol->flags & MPOL_F_MORON))
+		pol = NULL;
+	mpol_get(pol);
+	task_unlock(p);
+
+	SEQ_printf(m, "numa_migrations, %ld\n", xchg(&p->numa_pages_migrated, 0));
+
+	for_each_online_node(node) {
+		for (i = 0; i < 2; i++) {
+			unsigned long nr_faults = -1;
+			int cpu_current, home_node;
+
+			if (p->numa_faults)
+				nr_faults = p->numa_faults[2*node + i];
+
+			cpu_current = !i ? (task_node(p) == node) :
+				(pol && node_isset(node, pol->v.nodes));
+
+			home_node = (p->numa_preferred_nid == node);
+
+			SEQ_printf(m, "numa_faults, %d, %d, %d, %d, %ld\n",
+				i, node, cpu_current, home_node, nr_faults);
+		}
+	}
+
+	mpol_put(pol);
+#endif
+}
+
 void proc_sched_show_task(struct task_struct *p, struct seq_file *m)
 {
 	unsigned long nr_switches;
@@ -591,6 +645,8 @@ void proc_sched_show_task(struct task_struct *p, struct seq_file *m)
 		SEQ_printf(m, "%-45s:%21Ld\n",
 			   "clock-delta", (long long)(t1-t0));
 	}
+
+	sched_show_numa(p, m);
 }
 
 void proc_sched_set_task(struct task_struct *p)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index dc0c376..58d1070 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1137,7 +1137,7 @@ static int task_numa_migrate(struct task_struct *p)
 		.p = p,
 
 		.src_cpu = task_cpu(p),
-		.src_nid = cpu_to_node(task_cpu(p)),
+		.src_nid = task_node(p),
 
 		.imbalance_pct = 112,
 
@@ -1515,6 +1515,9 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 	if (p->numa_migrate_retry && time_after(jiffies, p->numa_migrate_retry))
 		numa_migrate_preferred(p);
 
+	if (migrated)
+		p->numa_pages_migrated += pages;
+
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
 }
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
