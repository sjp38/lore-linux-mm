Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id F19566B00A0
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:15:40 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3578138eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:15:40 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 26/31] sched, numa, mm: Add the scanning page fault machinery
Date: Tue, 13 Nov 2012 18:13:49 +0100
Message-Id: <1352826834-11774-27-git-send-email-mingo@kernel.org>
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Add the NUMA working set scanning/hinting page fault machinery,
with no policy yet.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
[ split it out of the main policy patch - as suggested by Mel Gorman ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/init_task.h |  8 ++++
 include/linux/mm_types.h  |  4 ++
 include/linux/sched.h     | 43 +++++++++++++++++++--
 init/Kconfig              |  9 +++++
 kernel/sched/core.c       | 15 ++++++++
 kernel/sysctl.c           | 31 +++++++++++++++-
 mm/huge_memory.c          |  7 +++-
 mm/memory.c               |  6 ++-
 mm/mempolicy.c            | 95 +++++++++++++++++++++++++++++++++++++++--------
 9 files changed, 193 insertions(+), 25 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 6d087c5..ed98982 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -143,6 +143,13 @@ extern struct task_group root_task_group;
 
 #define INIT_TASK_COMM "swapper"
 
+#ifdef CONFIG_NUMA_BALANCING
+# define INIT_TASK_NUMA(tsk)						\
+	.numa_shared = -1,
+#else
+# define INIT_TASK_NUMA(tsk)
+#endif
+
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -210,6 +217,7 @@ extern struct task_group root_task_group;
 	INIT_TRACE_RECURSION						\
 	INIT_TASK_RCU_PREEMPT(tsk)					\
 	INIT_CPUSET_SEQ							\
+	INIT_TASK_NUMA(tsk)						\
 }
 
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7e9f758..48760e9 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -403,6 +403,10 @@ struct mm_struct {
 #ifdef CONFIG_CPUMASK_OFFSTACK
 	struct cpumask cpumask_allocation;
 #endif
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned long numa_next_scan;
+	int numa_scan_seq;
+#endif
 	struct uprobes_state uprobes_state;
 };
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e1581a0..418d405 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1501,6 +1501,18 @@ struct task_struct {
 	short il_next;
 	short pref_node_fork;
 #endif
+#ifdef CONFIG_NUMA_BALANCING
+	int numa_shared;
+	int numa_max_node;
+	int numa_scan_seq;
+	int numa_migrate_seq;
+	unsigned int numa_scan_period;
+	u64 node_stamp;			/* migration stamp  */
+	unsigned long numa_weight;
+	unsigned long *numa_faults;
+	struct callback_head numa_work;
+#endif /* CONFIG_NUMA_BALANCING */
+
 	struct rcu_head rcu;
 
 	/*
@@ -1575,6 +1587,26 @@ struct task_struct {
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
+#ifdef CONFIG_NUMA_BALANCING
+extern void task_numa_fault(int node, int cpu, int pages);
+#else
+static inline void task_numa_fault(int node, int cpu, int pages) { }
+#endif /* CONFIG_NUMA_BALANCING */
+
+/*
+ * -1: non-NUMA task
+ *  0: NUMA task with a dominantly 'private' working set
+ *  1: NUMA task with a dominantly 'shared' working set
+ */
+static inline int task_numa_shared(struct task_struct *p)
+{
+#ifdef CONFIG_NUMA_BALANCING
+	return p->numa_shared;
+#else
+	return -1;
+#endif
+}
+
 /*
  * Priority of a process goes from 0..MAX_PRIO-1, valid RT
  * priority is 0..MAX_RT_PRIO-1, and SCHED_NORMAL/SCHED_BATCH
@@ -2012,6 +2044,10 @@ enum sched_tunable_scaling {
 };
 extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 
+extern unsigned int sysctl_sched_numa_scan_period_min;
+extern unsigned int sysctl_sched_numa_scan_period_max;
+extern unsigned int sysctl_sched_numa_settle_count;
+
 #ifdef CONFIG_SCHED_DEBUG
 extern unsigned int sysctl_sched_migration_cost;
 extern unsigned int sysctl_sched_nr_migrate;
@@ -2022,18 +2058,17 @@ extern unsigned int sysctl_sched_shares_window;
 int sched_proc_update_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *length,
 		loff_t *ppos);
-#endif
-#ifdef CONFIG_SCHED_DEBUG
+
 static inline unsigned int get_sysctl_timer_migration(void)
 {
 	return sysctl_timer_migration;
 }
-#else
+#else /* CONFIG_SCHED_DEBUG */
 static inline unsigned int get_sysctl_timer_migration(void)
 {
 	return 1;
 }
-#endif
+#endif /* CONFIG_SCHED_DEBUG */
 extern unsigned int sysctl_sched_rt_period;
 extern int sysctl_sched_rt_runtime;
 
diff --git a/init/Kconfig b/init/Kconfig
index 78807b3..4367c62 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -710,6 +710,15 @@ config ARCH_WANT_NUMA_VARIABLE_LOCALITY
 config ARCH_SUPPORTS_NUMA_BALANCING
 	bool
 
+config NUMA_BALANCING
+	bool "Memory placement aware NUMA scheduler"
+	default n
+	depends on ARCH_SUPPORTS_NUMA_BALANCING
+	depends on !ARCH_WANT_NUMA_VARIABLE_LOCALITY
+	depends on SMP && NUMA && MIGRATION
+	help
+	  This option adds support for automatic NUMA aware memory/task placement.
+
 menuconfig CGROUPS
 	boolean "Control Group support"
 	depends on EVENTFD
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 5dae0d2..3611f5f 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1544,6 +1544,21 @@ static void __sched_fork(struct task_struct *p)
 #ifdef CONFIG_PREEMPT_NOTIFIERS
 	INIT_HLIST_HEAD(&p->preempt_notifiers);
 #endif
+
+#ifdef CONFIG_NUMA_BALANCING
+	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
+		p->mm->numa_next_scan = jiffies;
+		p->mm->numa_scan_seq = 0;
+	}
+
+	p->numa_shared = -1;
+	p->node_stamp = 0ULL;
+	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
+	p->numa_migrate_seq = 2;
+	p->numa_faults = NULL;
+	p->numa_scan_period = sysctl_sched_numa_scan_period_min;
+	p->numa_work.next = &p->numa_work;
+#endif /* CONFIG_NUMA_BALANCING */
 }
 
 /*
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 26f65ea..f6cd550 100644
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
@@ -347,7 +350,31 @@ static struct ctl_table kern_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
-#endif
+#endif /* CONFIG_SMP */
+#ifdef CONFIG_NUMA_BALANCING
+	{
+		.procname	= "sched_numa_scan_period_min_ms",
+		.data		= &sysctl_sched_numa_scan_period_min,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "sched_numa_scan_period_max_ms",
+		.data		= &sysctl_sched_numa_scan_period_max,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "sched_numa_settle_count",
+		.data		= &sysctl_sched_numa_settle_count,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif /* CONFIG_NUMA_BALANCING */
+#endif /* CONFIG_SCHED_DEBUG */
 	{
 		.procname	= "sched_rt_period_us",
 		.data		= &sysctl_sched_rt_period,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fbff718..088f23b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -776,9 +776,10 @@ fixup:
 
 unlock:
 	spin_unlock(&mm->page_table_lock);
-	if (page)
+	if (page) {
+		task_numa_fault(page_to_nid(page), last_cpu, HPAGE_PMD_NR);
 		put_page(page);
-
+	}
 	return;
 
 migrate:
@@ -847,6 +848,8 @@ migrate:
 
 	put_page(page);			/* Drop the rmap reference */
 
+	task_numa_fault(node, last_cpu, HPAGE_PMD_NR);
+
 	if (lru)
 		put_page(page);		/* drop the LRU isolation reference */
 
diff --git a/mm/memory.c b/mm/memory.c
index ebd18fd..a13da1e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3484,6 +3484,7 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page = NULL;
 	int node, page_nid = -1;
+	int last_cpu = -1;
 	spinlock_t *ptl;
 
 	ptl = pte_lockptr(mm, pmd);
@@ -3495,6 +3496,7 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (page) {
 		get_page(page);
 		page_nid = page_to_nid(page);
+		last_cpu = page_last_cpu(page);
 		node = mpol_misplaced(page, vma, address);
 		if (node != -1)
 			goto migrate;
@@ -3514,8 +3516,10 @@ out_pte_upgrade_unlock:
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out:
-	if (page)
+	if (page) {
+		task_numa_fault(page_nid, last_cpu, 1);
 		put_page(page);
+	}
 
 	return 0;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 5ee326c..e31571c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2194,12 +2194,70 @@ static void sp_free(struct sp_node *n)
 	kmem_cache_free(sn_cache, n);
 }
 
+/*
+ * Multi-stage node selection is used in conjunction with a periodic
+ * migration fault to build a temporal task<->page relation. By
+ * using a two-stage filter we remove short/unlikely relations.
+ *
+ * Using P(p) ~ n_p / n_t as per frequentist probability, we can
+ * equate a task's usage of a particular page (n_p) per total usage
+ * of this page (n_t) (in a given time-span) to a probability.
+ *
+ * Our periodic faults will then sample this probability and getting
+ * the same result twice in a row, given these samples are fully
+ * independent, is then given by P(n)^2, provided our sample period
+ * is sufficiently short compared to the usage pattern.
+ *
+ * This quadric squishes small probabilities, making it less likely
+ * we act on an unlikely task<->page relation.
+ *
+ * Return the best node ID this page should be on, or -1 if it should
+ * stay where it is.
+ */
+static int
+numa_migration_target(struct page *page, int page_nid,
+		      struct task_struct *p, int this_cpu,
+		      int cpu_last_access)
+{
+	int nid_last_access;
+	int this_nid;
+
+	if (task_numa_shared(p) < 0)
+		return -1;
+
+	/*
+	 * Possibly migrate towards the current node, depends on
+	 * task_numa_placement() and access details.
+	 */
+	nid_last_access = cpu_to_node(cpu_last_access);
+	this_nid = cpu_to_node(this_cpu);
+
+	if (nid_last_access != this_nid) {
+		/*
+		 * 'Access miss': the page got last accessed from a remote node.
+		 */
+		return -1;
+	}
+	/*
+	 * 'Access hit': the page got last accessed from our node.
+	 *
+	 * Migrate the page if needed.
+	 */
+
+	/* The page is already on this node: */
+	if (page_nid == this_nid)
+		return -1;
+
+	return this_nid;
+}
+
 /**
  * mpol_misplaced - check whether current page node is valid in policy
  *
  * @page   - page to be checked
  * @vma    - vm area where page mapped
  * @addr   - virtual address where page mapped
+ * @multi  - use multi-stage node binding
  *
  * Lookup current policy node id for vma,addr and "compare to" page's
  * node id.
@@ -2213,18 +2271,22 @@ static void sp_free(struct sp_node *n)
  */
 int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr)
 {
+	int best_nid = -1, page_nid;
+	int cpu_last_access, this_cpu;
 	struct mempolicy *pol;
-	struct zone *zone;
-	int curnid = page_to_nid(page);
 	unsigned long pgoff;
-	int polnid = -1;
-	int ret = -1;
+	struct zone *zone;
 
 	BUG_ON(!vma);
 
+	this_cpu = raw_smp_processor_id();
+	page_nid = page_to_nid(page);
+
+	cpu_last_access = page_xchg_last_cpu(page, this_cpu);
+
 	pol = get_vma_policy(current, vma, addr);
-	if (!(pol->flags & MPOL_F_MOF))
-		goto out;
+	if (!(pol->flags & MPOL_F_MOF) && !(task_numa_shared(current) >= 0))
+		goto out_keep_page;
 
 	switch (pol->mode) {
 	case MPOL_INTERLEAVE:
@@ -2233,14 +2295,14 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 		pgoff = vma->vm_pgoff;
 		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
-		polnid = offset_il_node(pol, vma, pgoff);
+		best_nid = offset_il_node(pol, vma, pgoff);
 		break;
 
 	case MPOL_PREFERRED:
 		if (pol->flags & MPOL_F_LOCAL)
-			polnid = numa_node_id();
+			best_nid = numa_node_id();
 		else
-			polnid = pol->v.preferred_node;
+			best_nid = pol->v.preferred_node;
 		break;
 
 	case MPOL_BIND:
@@ -2250,24 +2312,25 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * else select nearest allowed node, if any.
 		 * If no allowed nodes, use current [!misplaced].
 		 */
-		if (node_isset(curnid, pol->v.nodes))
-			goto out;
+		if (node_isset(page_nid, pol->v.nodes))
+			goto out_keep_page;
 		(void)first_zones_zonelist(
 				node_zonelist(numa_node_id(), GFP_HIGHUSER),
 				gfp_zone(GFP_HIGHUSER),
 				&pol->v.nodes, &zone);
-		polnid = zone->node;
+		best_nid = zone->node;
 		break;
 
 	default:
 		BUG();
 	}
-	if (curnid != polnid)
-		ret = polnid;
-out:
+
+	best_nid = numa_migration_target(page, page_nid, current, this_cpu, cpu_last_access);
+
+out_keep_page:
 	mpol_cond_put(pol);
 
-	return ret;
+	return best_nid;
 }
 
 static void sp_delete(struct shared_policy *sp, struct sp_node *n)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
