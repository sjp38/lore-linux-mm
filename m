Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 14BCE6B00AC
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:41 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 25/49] mm: numa: Add fault driven placement and migration
Date: Fri,  7 Dec 2012 10:23:28 +0000
Message-Id: <1354875832-9700-26-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

NOTE: This patch is based on "sched, numa, mm: Add fault driven
	placement and migration policy" but as it throws away all the policy
	to just leave a basic foundation I had to drop the signed-offs-by.

This patch creates a bare-bones method for setting PTEs pte_numa in the
context of the scheduler that when faulted later will be faulted onto the
node the CPU is running on.  In itself this does nothing useful but any
placement policy will fundamentally depend on receiving hints on placement
from fault context and doing something intelligent about it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 arch/sh/mm/Kconfig       |    1 +
 arch/x86/Kconfig         |    2 +
 include/linux/mm_types.h |   11 ++++
 include/linux/sched.h    |   20 ++++++++
 kernel/sched/core.c      |   13 +++++
 kernel/sched/fair.c      |  125 ++++++++++++++++++++++++++++++++++++++++++++++
 kernel/sched/features.h  |    7 +++
 kernel/sched/sched.h     |    6 +++
 kernel/sysctl.c          |   24 ++++++++-
 mm/huge_memory.c         |    5 +-
 mm/memory.c              |   14 +++++-
 11 files changed, 224 insertions(+), 4 deletions(-)

diff --git a/arch/sh/mm/Kconfig b/arch/sh/mm/Kconfig
index cb8f992..0f7c852 100644
--- a/arch/sh/mm/Kconfig
+++ b/arch/sh/mm/Kconfig
@@ -111,6 +111,7 @@ config VSYSCALL
 config NUMA
 	bool "Non Uniform Memory Access (NUMA) Support"
 	depends on MMU && SYS_SUPPORTS_NUMA && EXPERIMENTAL
+	select ARCH_WANT_NUMA_VARIABLE_LOCALITY
 	default n
 	help
 	  Some SH systems have many various memories scattered around
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 46c3bff..1137028 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -22,6 +22,8 @@ config X86
 	def_bool y
 	select HAVE_AOUT if X86_32
 	select HAVE_UNSTABLE_SCHED_CLOCK
+	select ARCH_SUPPORTS_NUMA_BALANCING
+	select ARCH_WANTS_PROT_NUMA_PROT_NONE
 	select HAVE_IDE
 	select HAVE_OPROFILE
 	select HAVE_PCSPKR_PLATFORM
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 31f8a3a..d82accb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -398,6 +398,17 @@ struct mm_struct {
 #ifdef CONFIG_CPUMASK_OFFSTACK
 	struct cpumask cpumask_allocation;
 #endif
+#ifdef CONFIG_BALANCE_NUMA
+	/*
+	 * numa_next_scan is the next time when the PTEs will me marked
+	 * pte_numa to gather statistics and migrate pages to new nodes
+	 * if necessary
+	 */
+	unsigned long numa_next_scan;
+
+	/* numa_scan_seq prevents two threads setting pte_numa */
+	int numa_scan_seq;
+#endif
 	struct uprobes_state uprobes_state;
 };
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0dd42a0..ac71181 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1479,6 +1479,14 @@ struct task_struct {
 	short il_next;
 	short pref_node_fork;
 #endif
+#ifdef CONFIG_BALANCE_NUMA
+	int numa_scan_seq;
+	int numa_migrate_seq;
+	unsigned int numa_scan_period;
+	u64 node_stamp;			/* migration stamp  */
+	struct callback_head numa_work;
+#endif /* CONFIG_BALANCE_NUMA */
+
 	struct rcu_head rcu;
 
 	/*
@@ -1553,6 +1561,14 @@ struct task_struct {
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
+#ifdef CONFIG_BALANCE_NUMA
+extern void task_numa_fault(int node, int pages);
+#else
+static inline void task_numa_fault(int node, int pages)
+{
+}
+#endif
+
 /*
  * Priority of a process goes from 0..MAX_PRIO-1, valid RT
  * priority is 0..MAX_RT_PRIO-1, and SCHED_NORMAL/SCHED_BATCH
@@ -1990,6 +2006,10 @@ enum sched_tunable_scaling {
 };
 extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 
+extern unsigned int sysctl_balance_numa_scan_period_min;
+extern unsigned int sysctl_balance_numa_scan_period_max;
+extern unsigned int sysctl_balance_numa_settle_count;
+
 #ifdef CONFIG_SCHED_DEBUG
 extern unsigned int sysctl_sched_migration_cost;
 extern unsigned int sysctl_sched_nr_migrate;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 2d8927f..81fa185 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1533,6 +1533,19 @@ static void __sched_fork(struct task_struct *p)
 #ifdef CONFIG_PREEMPT_NOTIFIERS
 	INIT_HLIST_HEAD(&p->preempt_notifiers);
 #endif
+
+#ifdef CONFIG_BALANCE_NUMA
+	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
+		p->mm->numa_next_scan = jiffies;
+		p->mm->numa_scan_seq = 0;
+	}
+
+	p->node_stamp = 0ULL;
+	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
+	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
+	p->numa_scan_period = sysctl_balance_numa_scan_period_min;
+	p->numa_work.next = &p->numa_work;
+#endif /* CONFIG_BALANCE_NUMA */
 }
 
 /*
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 6b800a1..b6d3ed7 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -26,6 +26,8 @@
 #include <linux/slab.h>
 #include <linux/profile.h>
 #include <linux/interrupt.h>
+#include <linux/mempolicy.h>
+#include <linux/task_work.h>
 
 #include <trace/events/sched.h>
 
@@ -776,6 +778,126 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
  * Scheduling class queueing methods:
  */
 
+#ifdef CONFIG_BALANCE_NUMA
+/*
+ * numa task sample period in ms: 5s
+ */
+unsigned int sysctl_balance_numa_scan_period_min = 5000;
+unsigned int sysctl_balance_numa_scan_period_max = 5000*16;
+
+static void task_numa_placement(struct task_struct *p)
+{
+	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
+
+	if (p->numa_scan_seq == seq)
+		return;
+	p->numa_scan_seq = seq;
+
+	/* FIXME: Scheduling placement policy hints go here */
+}
+
+/*
+ * Got a PROT_NONE fault for a page on @node.
+ */
+void task_numa_fault(int node, int pages)
+{
+	struct task_struct *p = current;
+
+	/* FIXME: Allocate task-specific structure for placement policy here */
+
+	task_numa_placement(p);
+}
+
+/*
+ * The expensive part of numa migration is done from task_work context.
+ * Triggered from task_tick_numa().
+ */
+void task_numa_work(struct callback_head *work)
+{
+	unsigned long migrate, next_scan, now = jiffies;
+	struct task_struct *p = current;
+	struct mm_struct *mm = p->mm;
+
+	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
+
+	work->next = work; /* protect against double add */
+	/*
+	 * Who cares about NUMA placement when they're dying.
+	 *
+	 * NOTE: make sure not to dereference p->mm before this check,
+	 * exit_task_work() happens _after_ exit_mm() so we could be called
+	 * without p->mm even though we still had it when we enqueued this
+	 * work.
+	 */
+	if (p->flags & PF_EXITING)
+		return;
+
+	/*
+	 * Enforce maximal scan/migration frequency..
+	 */
+	migrate = mm->numa_next_scan;
+	if (time_before(now, migrate))
+		return;
+
+	if (p->numa_scan_period == 0)
+		p->numa_scan_period = sysctl_balance_numa_scan_period_min;
+
+	next_scan = now + 2*msecs_to_jiffies(p->numa_scan_period);
+	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
+		return;
+
+	ACCESS_ONCE(mm->numa_scan_seq)++;
+	{
+		struct vm_area_struct *vma;
+
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (!vma_migratable(vma))
+				continue;
+			change_prot_numa(vma, vma->vm_start, vma->vm_end);
+		}
+		up_read(&mm->mmap_sem);
+	}
+}
+
+/*
+ * Drive the periodic memory faults..
+ */
+void task_tick_numa(struct rq *rq, struct task_struct *curr)
+{
+	struct callback_head *work = &curr->numa_work;
+	u64 period, now;
+
+	/*
+	 * We don't care about NUMA placement if we don't have memory.
+	 */
+	if (!curr->mm || (curr->flags & PF_EXITING) || work->next != work)
+		return;
+
+	/*
+	 * Using runtime rather than walltime has the dual advantage that
+	 * we (mostly) drive the selection from busy threads and that the
+	 * task needs to have done some actual work before we bother with
+	 * NUMA placement.
+	 */
+	now = curr->se.sum_exec_runtime;
+	period = (u64)curr->numa_scan_period * NSEC_PER_MSEC;
+
+	if (now - curr->node_stamp > period) {
+		curr->node_stamp = now;
+
+		if (!time_before(jiffies, curr->mm->numa_next_scan)) {
+			init_task_work(work, task_numa_work); /* TODO: move this into sched_fork() */
+			task_work_add(curr, work, true);
+		}
+	}
+}
+#else
+static void task_tick_numa(struct rq *rq, struct task_struct *curr)
+{
+}
+#endif /* CONFIG_BALANCE_NUMA */
+
 static void
 account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 {
@@ -4954,6 +5076,9 @@ static void task_tick_fair(struct rq *rq, struct task_struct *curr, int queued)
 		cfs_rq = cfs_rq_of(se);
 		entity_tick(cfs_rq, se, queued);
 	}
+
+	if (sched_feat_numa(NUMA))
+		task_tick_numa(rq, curr);
 }
 
 /*
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index eebefca..7cfd289 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -61,3 +61,10 @@ SCHED_FEAT(TTWU_QUEUE, true)
 SCHED_FEAT(FORCE_SD_OVERLAP, false)
 SCHED_FEAT(RT_RUNTIME_SHARE, true)
 SCHED_FEAT(LB_MIN, false)
+
+/*
+ * Apply the automatic NUMA scheduling policy
+ */
+#ifdef CONFIG_BALANCE_NUMA
+SCHED_FEAT(NUMA,	true)
+#endif
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 7a7db09..9a43241 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -648,6 +648,12 @@ extern struct static_key sched_feat_keys[__SCHED_FEAT_NR];
 #define sched_feat(x) (sysctl_sched_features & (1UL << __SCHED_FEAT_##x))
 #endif /* SCHED_DEBUG && HAVE_JUMP_LABEL */
 
+#ifdef CONFIG_BALANCE_NUMA
+#define sched_feat_numa(x) sched_feat(x)
+#else
+#define sched_feat_numa(x) (0)
+#endif
+
 static inline u64 global_rt_period(void)
 {
 	return (u64)sysctl_sched_rt_period * NSEC_PER_USEC;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 26f65ea..1359f51 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -256,9 +256,11 @@ static int min_sched_granularity_ns = 100000;		/* 100 usecs */
 static int max_sched_granularity_ns = NSEC_PER_SEC;	/* 1 second */
 static int min_wakeup_granularity_ns;			/* 0 usecs */
 static int max_wakeup_granularity_ns = NSEC_PER_SEC;	/* 1 second */
+#ifdef CONFIG_SMP
 static int min_sched_tunable_scaling = SCHED_TUNABLESCALING_NONE;
 static int max_sched_tunable_scaling = SCHED_TUNABLESCALING_END-1;
-#endif
+#endif /* CONFIG_SMP */
+#endif /* CONFIG_SCHED_DEBUG */
 
 #ifdef CONFIG_COMPACTION
 static int min_extfrag_threshold;
@@ -301,6 +303,7 @@ static struct ctl_table kern_table[] = {
 		.extra1		= &min_wakeup_granularity_ns,
 		.extra2		= &max_wakeup_granularity_ns,
 	},
+#ifdef CONFIG_SMP
 	{
 		.procname	= "sched_tunable_scaling",
 		.data		= &sysctl_sched_tunable_scaling,
@@ -347,7 +350,24 @@ static struct ctl_table kern_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
-#endif
+#endif /* CONFIG_SMP */
+#ifdef CONFIG_BALANCE_NUMA
+	{
+		.procname	= "balance_numa_scan_period_min_ms",
+		.data		= &sysctl_balance_numa_scan_period_min,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "balance_numa_scan_period_max_ms",
+		.data		= &sysctl_balance_numa_scan_period_max,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif /* CONFIG_BALANCE_NUMA */
+#endif /* CONFIG_SCHED_DEBUG */
 	{
 		.procname	= "sched_rt_period_us",
 		.data		= &sysctl_sched_rt_period,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 68e0412..b3d4c4b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1045,6 +1045,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	split_huge_page(page);
 	put_page(page);
+
 	return 0;
 
 clear_pmdnuma:
@@ -1059,8 +1060,10 @@ clear_pmdnuma:
 
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
-	if (page)
+	if (page) {
 		put_page(page);
+		task_numa_fault(numa_node_id(), HPAGE_PMD_NR);
+	}
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 1757ad8..1d6f85a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3454,7 +3454,8 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page = NULL;
 	spinlock_t *ptl;
-	int current_nid, target_nid;
+	int current_nid = -1;
+	int target_nid;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3501,6 +3502,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		current_nid = target_nid;
 
 out:
+	task_numa_fault(current_nid, 1);
 	return 0;
 }
 
@@ -3537,6 +3539,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
 		pte_t pteval = *pte;
 		struct page *page;
+		int curr_nid;
 		if (!pte_present(pteval))
 			continue;
 		if (!pte_numa(pteval))
@@ -3554,6 +3557,15 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page = vm_normal_page(vma, addr, pteval);
 		if (unlikely(!page))
 			continue;
+		/* only check non-shared pages */
+		if (unlikely(page_mapcount(page) != 1))
+			continue;
+		pte_unmap_unlock(pte, ptl);
+
+		curr_nid = page_to_nid(page);
+		task_numa_fault(curr_nid, 1);
+
+		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
 	pte_unmap_unlock(orig_pte, ptl);
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
