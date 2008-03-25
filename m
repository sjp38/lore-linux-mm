Message-Id: <20080325021956.492502000@polaris-admin.engr.sgi.com>
References: <20080325021954.979158000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:20:04 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 10/10] sched: Remove fixed NR_CPUS sized arrays in kernel_sched.c
Content-Disposition: inline; filename=nr_cpus-in-kernel_sched
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Change fixed size arrays to per_cpu variables or dynamically allocated
arrays in sched_init() and sched_init_smp().

 (1)	static struct sched_entity *init_sched_entity_p[NR_CPUS];
 (1)	static struct cfs_rq *init_cfs_rq_p[NR_CPUS];
 (1)	static struct sched_rt_entity *init_sched_rt_entity_p[NR_CPUS];
 (1)	static struct rt_rq *init_rt_rq_p[NR_CPUS];
	static struct sched_group **sched_group_nodes_bycpu[NR_CPUS];
	char str[NR_CPUS];
	int ints[NR_CPUS], i;

(1 - these arrays are allocated via alloc_bootmem_low())

Also in sched_create_group() we allocate new arrays based on nr_cpu_ids.

Based on linux-2.6.25-rc5-mm1

Cc: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 kernel/sched.c |   92 +++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 63 insertions(+), 29 deletions(-)

--- linux-2.6.25-rc5.orig/kernel/sched.c
+++ linux-2.6.25-rc5/kernel/sched.c
@@ -67,6 +67,7 @@
 #include <linux/pagemap.h>
 #include <linux/hrtimer.h>
 #include <linux/tick.h>
+#include <linux/bootmem.h>
 
 #include <asm/tlb.h>
 #include <asm/irq_regs.h>
@@ -194,17 +195,11 @@ struct task_group {
 static DEFINE_PER_CPU(struct sched_entity, init_sched_entity);
 /* Default task group's cfs_rq on each cpu */
 static DEFINE_PER_CPU(struct cfs_rq, init_cfs_rq) ____cacheline_aligned_in_smp;
-
-static struct sched_entity *init_sched_entity_p[NR_CPUS];
-static struct cfs_rq *init_cfs_rq_p[NR_CPUS];
 #endif
 
 #ifdef CONFIG_RT_GROUP_SCHED
 static DEFINE_PER_CPU(struct sched_rt_entity, init_sched_rt_entity);
 static DEFINE_PER_CPU(struct rt_rq, init_rt_rq) ____cacheline_aligned_in_smp;
-
-static struct sched_rt_entity *init_sched_rt_entity_p[NR_CPUS];
-static struct rt_rq *init_rt_rq_p[NR_CPUS];
 #endif
 
 /* task_group_lock serializes add/remove of task groups and also changes to
@@ -228,17 +223,7 @@ static int init_task_group_load = INIT_T
 /* Default task group.
  *	Every task in system belong to this group at bootup.
  */
-struct task_group init_task_group = {
-#ifdef CONFIG_FAIR_GROUP_SCHED
-	.se	= init_sched_entity_p,
-	.cfs_rq = init_cfs_rq_p,
-#endif
-
-#ifdef CONFIG_RT_GROUP_SCHED
-	.rt_se	= init_sched_rt_entity_p,
-	.rt_rq	= init_rt_rq_p,
-#endif
-};
+struct task_group init_task_group;
 
 /* return group to which a task belongs */
 static inline struct task_group *task_group(struct task_struct *p)
@@ -3587,7 +3572,7 @@ static inline void trigger_load_balance(
 			 */
 			int ilb = first_cpu(nohz.cpu_mask);
 
-			if (ilb != NR_CPUS)
+			if (ilb < nr_cpu_ids)
 				resched_cpu(ilb);
 		}
 	}
@@ -5544,11 +5529,11 @@ static void move_task_off_dead_cpu(int d
 		dest_cpu = any_online_cpu(mask);
 
 		/* On any allowed CPU? */
-		if (dest_cpu == NR_CPUS)
+		if (dest_cpu >= nr_cpu_ids)
 			dest_cpu = any_online_cpu(p->cpus_allowed);
 
 		/* No more Mr. Nice Guy. */
-		if (dest_cpu == NR_CPUS) {
+		if (dest_cpu >= nr_cpu_ids) {
 			cpumask_t cpus_allowed = cpuset_cpus_allowed_locked(p);
 			/*
 			 * Try to stay on the same cpuset, where the
@@ -6001,9 +5986,16 @@ static int sched_domain_debug_one(struct
 {
 	struct sched_group *group = sd->groups;
 	cpumask_t groupmask;
-	char str[NR_CPUS];
+	int len = cpumask_scnprintf_len(nr_cpu_ids);
+	char *str = kmalloc(len, GFP_KERNEL);
+	int ret = 0;
+
+	if (!str) {
+		printk(KERN_DEBUG "Cannot load-balance (no memory)\n");
+		return -1;
+	}
 
-	cpumask_scnprintf(str, NR_CPUS, sd->span);
+	cpumask_scnprintf(str, len, sd->span);
 	cpus_clear(groupmask);
 
 	printk(KERN_DEBUG "%*s domain %d: ", level, "", level);
@@ -6013,6 +6005,7 @@ static int sched_domain_debug_one(struct
 		if (sd->parent)
 			printk(KERN_ERR "ERROR: !SD_LOAD_BALANCE domain"
 					" has parent");
+		kfree(str);
 		return -1;
 	}
 
@@ -6056,7 +6049,7 @@ static int sched_domain_debug_one(struct
 
 		cpus_or(groupmask, groupmask, group->cpumask);
 
-		cpumask_scnprintf(str, NR_CPUS, group->cpumask);
+		cpumask_scnprintf(str, len, group->cpumask);
 		printk(KERN_CONT " %s", str);
 
 		group = group->next;
@@ -6069,6 +6062,8 @@ static int sched_domain_debug_one(struct
 	if (sd->parent && !cpus_subset(groupmask, sd->parent->span))
 		printk(KERN_ERR "ERROR: parent span is not a superset "
 			"of domain->span\n");
+
+	kfree(str);
 	return 0;
 }
 
@@ -6250,7 +6245,7 @@ cpu_attach_domain(struct sched_domain *s
 /*
  * init_sched_build_groups takes the cpumask we wish to span, and a pointer
  * to a function which identifies what group(along with sched group) a CPU
- * belongs to. The return value of group_fn must be a >= 0 and < NR_CPUS
+ * belongs to. The return value of group_fn must be a >= 0 and < nr_cpu_ids
  * (due to the fact that we keep track of groups covered with a cpumask_t).
  *
  * init_sched_build_groups will build a circular linked list of the groups
@@ -6448,7 +6443,7 @@ cpu_to_phys_group(int cpu, const cpumask
  * gets dynamically allocated.
  */
 static DEFINE_PER_CPU(struct sched_domain, node_domains);
-static struct sched_group **sched_group_nodes_bycpu[NR_CPUS];
+static struct sched_group ***sched_group_nodes_bycpu;
 
 static DEFINE_PER_CPU(struct sched_domain, allnodes_domains);
 static DEFINE_PER_CPU(struct sched_group, sched_group_allnodes);
@@ -7086,6 +7081,11 @@ void __init sched_init_smp(void)
 {
 	cpumask_t non_isolated_cpus;
 
+#if defined(CONFIG_NUMA)
+	sched_group_nodes_bycpu = kzalloc(nr_cpu_ids * sizeof(void **),
+								GFP_KERNEL);
+	BUG_ON(sched_group_nodes_bycpu == NULL);
+#endif
 	get_online_cpus();
 	arch_init_sched_domains(&cpu_online_map);
 	non_isolated_cpus = cpu_possible_map;
@@ -7103,6 +7103,11 @@ void __init sched_init_smp(void)
 #else
 void __init sched_init_smp(void)
 {
+#if defined(CONFIG_NUMA)
+	sched_group_nodes_bycpu = kzalloc(nr_cpu_ids * sizeof(void **),
+								GFP_KERNEL);
+	BUG_ON(sched_group_nodes_bycpu == NULL);
+#endif
 	sched_init_granularity();
 }
 #endif /* CONFIG_SMP */
@@ -7196,6 +7201,35 @@ static void init_tg_rt_entry(struct rq *
 void __init sched_init(void)
 {
 	int i, j;
+	unsigned long alloc_size = 0, ptr;
+
+#ifdef CONFIG_FAIR_GROUP_SCHED
+	alloc_size += 2 * nr_cpu_ids * sizeof(void **);
+#endif
+#ifdef CONFIG_RT_GROUP_SCHED
+	alloc_size += 2 * nr_cpu_ids * sizeof(void **);
+#endif
+	/*
+	 * As sched_init() is called before page_alloc is setup,
+	 * we use alloc_bootmem().
+	 */
+	if (alloc_size) {
+		ptr = (unsigned long)alloc_bootmem_low(alloc_size);
+
+#ifdef CONFIG_FAIR_GROUP_SCHED
+		init_task_group.se = (struct sched_entity **)ptr;
+		ptr += nr_cpu_ids * sizeof(void **);
+
+		init_task_group.cfs_rq = (struct cfs_rq **)ptr;
+		ptr += nr_cpu_ids * sizeof(void **);
+#endif
+#ifdef CONFIG_RT_GROUP_SCHED
+		init_task_group.rt_se = (struct sched_rt_entity **)ptr;
+		ptr += nr_cpu_ids * sizeof(void **);
+
+		init_task_group.rt_rq = (struct rt_rq **)ptr;
+#endif
+	}
 
 #ifdef CONFIG_SMP
 	init_defrootdomain();
@@ -7442,10 +7476,10 @@ static int alloc_fair_sched_group(struct
 	struct rq *rq;
 	int i;
 
-	tg->cfs_rq = kzalloc(sizeof(cfs_rq) * NR_CPUS, GFP_KERNEL);
+	tg->cfs_rq = kzalloc(sizeof(cfs_rq) * nr_cpu_ids, GFP_KERNEL);
 	if (!tg->cfs_rq)
 		goto err;
-	tg->se = kzalloc(sizeof(se) * NR_CPUS, GFP_KERNEL);
+	tg->se = kzalloc(sizeof(se) * nr_cpu_ids, GFP_KERNEL);
 	if (!tg->se)
 		goto err;
 
@@ -7525,10 +7559,10 @@ static int alloc_rt_sched_group(struct t
 	struct rq *rq;
 	int i;
 
-	tg->rt_rq = kzalloc(sizeof(rt_rq) * NR_CPUS, GFP_KERNEL);
+	tg->rt_rq = kzalloc(sizeof(rt_rq) * nr_cpu_ids, GFP_KERNEL);
 	if (!tg->rt_rq)
 		goto err;
-	tg->rt_se = kzalloc(sizeof(rt_se) * NR_CPUS, GFP_KERNEL);
+	tg->rt_se = kzalloc(sizeof(rt_se) * nr_cpu_ids, GFP_KERNEL);
 	if (!tg->rt_se)
 		goto err;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
