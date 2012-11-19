Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 6F5576B0083
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:15:58 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1265406eaa.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:15:57 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 17/27] sched, numa, mm: Add the scanning page fault machinery
Date: Mon, 19 Nov 2012 03:14:34 +0100
Message-Id: <1353291284-2998-18-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Add the NUMA working set scanning/hinting page fault machinery,
with no policy yet.

[ The earliest versions had the mpol_misplaced() function from
  Lee Schermerhorn - this was heavily modified later on. ]

Also-written-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Hugh Dickins <hughd@google.com>
[ split it out of the main policy patch - as suggested by Mel Gorman ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/init_task.h |   8 +++
 include/linux/mempolicy.h |   6 +-
 include/linux/mm_types.h  |   4 ++
 include/linux/sched.h     |  41 ++++++++++++--
 init/Kconfig              |  73 +++++++++++++++++++-----
 kernel/sched/core.c       |  15 +++++
 kernel/sysctl.c           |  31 ++++++++++-
 mm/huge_memory.c          |   1 +
 mm/mempolicy.c            | 137 ++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 294 insertions(+), 22 deletions(-)

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
 
 
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index f329306..c511e25 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -198,6 +198,8 @@ static inline int vma_migratable(struct vm_area_struct *vma)
 	return 1;
 }
 
+extern int mpol_misplaced(struct page *, struct vm_area_struct *, unsigned long);
+
 #else
 
 struct mempolicy {};
@@ -323,11 +325,11 @@ static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
 	return 0;
 }
 
-#endif /* CONFIG_NUMA */
-
 static inline int mpol_misplaced(struct page *page, struct vm_area_struct *vma,
 				 unsigned long address)
 {
 	return -1; /* no node preference */
 }
+
+#endif /* CONFIG_NUMA */
 #endif
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
index a0a2808..418d405 100644
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
@@ -1575,7 +1587,25 @@ struct task_struct {
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
+#ifdef CONFIG_NUMA_BALANCING
+extern void task_numa_fault(int node, int cpu, int pages);
+#else
 static inline void task_numa_fault(int node, int cpu, int pages) { }
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
 
 /*
  * Priority of a process goes from 0..MAX_PRIO-1, valid RT
@@ -2014,6 +2044,10 @@ enum sched_tunable_scaling {
 };
 extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 
+extern unsigned int sysctl_sched_numa_scan_period_min;
+extern unsigned int sysctl_sched_numa_scan_period_max;
+extern unsigned int sysctl_sched_numa_settle_count;
+
 #ifdef CONFIG_SCHED_DEBUG
 extern unsigned int sysctl_sched_migration_cost;
 extern unsigned int sysctl_sched_nr_migrate;
@@ -2024,18 +2058,17 @@ extern unsigned int sysctl_sched_shares_window;
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
index cf3e79c..9511f0d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -697,6 +697,65 @@ config HAVE_UNSTABLE_SCHED_CLOCK
 	bool
 
 #
+# For architectures that (ab)use NUMA to represent different memory regions
+# all cpu-local but of different latencies, such as SuperH.
+#
+config ARCH_WANTS_NUMA_VARIABLE_LOCALITY
+	bool
+
+#
+# For architectures that want to enable NUMA-affine scheduling
+# and memory placement:
+#
+config ARCH_SUPPORTS_NUMA_BALANCING
+	bool
+
+#
+# For architectures that want to reuse the PROT_NONE bits
+# to implement NUMA protection bits:
+#
+config ARCH_WANTS_NUMA_GENERIC_PGPROT
+	bool
+
+config NUMA_BALANCING
+	bool "NUMA-optimizing scheduler"
+	default n
+	depends on ARCH_SUPPORTS_NUMA_BALANCING
+	depends on !ARCH_WANTS_NUMA_VARIABLE_LOCALITY
+	depends on SMP && NUMA && MIGRATION
+	help
+	  This option enables NUMA-aware, transparent, automatic
+	  placement optimizations of memory, tasks and task groups.
+
+	  The optimizations work by (transparently) runtime sampling the
+	  workload sharing relationship between threads and processes
+	  of long-run workloads, and scheduling them based on these
+	  measured inter-task relationships (or the lack thereof).
+
+	  ("Long-run" means several seconds of CPU runtime at least.)
+
+	  Tasks that predominantly perform their own processing, without
+	  interacting with other tasks much will be independently balanced
+	  to a CPU and their working set memory will migrate to that CPU/node.
+
+	  Tasks that share a lot of data with each other will be attempted to
+	  be scheduled on as few nodes as possible, with their memory
+	  following them there and being distributed between those nodes.
+
+	  This optimization can improve the performance of long-run CPU-bound
+	  workloads by 10% or more. The sampling and migration has a small
+	  but nonzero cost, so if your NUMA workload is already perfectly
+	  placed (for example by use of explicit CPU and memory bindings,
+	  or because the stock scheduler does a good job already) then you
+	  probably don't need this feature.
+
+	  [ On non-NUMA systems this feature will not be active. You can query
+	    whether your system is a NUMA system via looking at the output of
+	    "numactl --hardware". ]
+
+	  Say N if unsure.
+
+#
 # Helper Kconfig switches to express compound feature dependencies
 # and thus make the .h/.c code more readable:
 #
@@ -718,20 +777,6 @@ config ARCH_USES_NUMA_GENERIC_PGPROT_HUGEPAGE
 	depends on ARCH_USES_NUMA_GENERIC_PGPROT
 	depends on TRANSPARENT_HUGEPAGE
 
-#
-# For architectures that (ab)use NUMA to represent different memory regions
-# all cpu-local but of different latencies, such as SuperH.
-#
-config ARCH_WANTS_NUMA_VARIABLE_LOCALITY
-	bool
-
-#
-# For architectures that want to enable the PROT_NONE driven,
-# NUMA-affine scheduler balancing logic:
-#
-config ARCH_SUPPORTS_NUMA_BALANCING
-	bool
-
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
index b0fa5ad..7736b9e 100644
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
index 814e3ea..92e101f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1456,6 +1456,7 @@ static void __split_huge_page_refcount(struct page *page)
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
+		page_xchg_last_cpu(page, page_last_cpu(page_tail));
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d04a8a5..318043a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2175,6 +2175,143 @@ static void sp_free(struct sp_node *n)
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
+/**
+ * mpol_misplaced - check whether current page node is valid in policy
+ *
+ * @page   - page to be checked
+ * @vma    - vm area where page mapped
+ * @addr   - virtual address where page mapped
+ * @multi  - use multi-stage node binding
+ *
+ * Lookup current policy node id for vma,addr and "compare to" page's
+ * node id.
+ *
+ * Returns:
+ *	-1	- not misplaced, page is in the right node
+ *	node	- node id where the page should be
+ *
+ * Policy determination "mimics" alloc_page_vma().
+ * Called from fault path where we know the vma and faulting address.
+ */
+int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr)
+{
+	int best_nid = -1, page_nid;
+	int cpu_last_access, this_cpu;
+	struct mempolicy *pol;
+	unsigned long pgoff;
+	struct zone *zone;
+
+	BUG_ON(!vma);
+
+	this_cpu = raw_smp_processor_id();
+	page_nid = page_to_nid(page);
+
+	cpu_last_access = page_xchg_last_cpu(page, this_cpu);
+
+	pol = get_vma_policy(current, vma, addr);
+	if (!(task_numa_shared(current) >= 0))
+		goto out_keep_page;
+
+	switch (pol->mode) {
+	case MPOL_INTERLEAVE:
+		BUG_ON(addr >= vma->vm_end);
+		BUG_ON(addr < vma->vm_start);
+
+		pgoff = vma->vm_pgoff;
+		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
+		best_nid = offset_il_node(pol, vma, pgoff);
+		break;
+
+	case MPOL_PREFERRED:
+		if (pol->flags & MPOL_F_LOCAL)
+			best_nid = numa_migration_target(page, page_nid, current, this_cpu, cpu_last_access);
+		else
+			best_nid = pol->v.preferred_node;
+		break;
+
+	case MPOL_BIND:
+		/*
+		 * allows binding to multiple nodes.
+		 * use current page if in policy nodemask,
+		 * else select nearest allowed node, if any.
+		 * If no allowed nodes, use current [!misplaced].
+		 */
+		if (node_isset(page_nid, pol->v.nodes))
+			goto out_keep_page;
+		(void)first_zones_zonelist(
+				node_zonelist(numa_node_id(), GFP_HIGHUSER),
+				gfp_zone(GFP_HIGHUSER),
+				&pol->v.nodes, &zone);
+		best_nid = zone->node;
+		break;
+
+	default:
+		BUG();
+	}
+
+out_keep_page:
+	mpol_cond_put(pol);
+
+	return best_nid;
+}
+
 static void sp_delete(struct shared_policy *sp, struct sp_node *n)
 {
 	pr_debug("deleting %lx-l%lx\n", n->start, n->end);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
