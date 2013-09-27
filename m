Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 13090900026
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:47 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so2612976pdi.14
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:46 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 55/63] sched: numa: Avoid migrating tasks that are placed on their preferred node
Date: Fri, 27 Sep 2013 14:27:40 +0100
Message-Id: <1380288468-5551-56-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

(This changelog needs more work, it's currently inaccurate and it's not
clear at exactly what point rt > env->fbq_type is true for the logic to
kick in)

This patch classifies scheduler domains and runqueues into FBQ (cannot
guess what this expands to) types which are one of

regular: There are tasks running that do not care about their NUMA
	placement

remote: There are tasks running that care about their placement but are
	currently running on a node remote to their ideal placement

all: No distinction

To implement this the patch tracks the number of tasks that are optimally
NUMA placed (rq->nr_preferred_running) and the number of tasks running that
care about their placement (nr_numa_running). The load balancer uses this
information to avoid migrating idea placed NUMA tasks as long as better
options for load balancing exists.

Not-signed-off-by: Peter Zijlstra
---
 kernel/sched/core.c  |  29 ++++++++++++
 kernel/sched/fair.c  | 128 ++++++++++++++++++++++++++++++++++++++++++++++-----
 kernel/sched/sched.h |   5 ++
 3 files changed, 150 insertions(+), 12 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 336a8ba..7abbae9 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4485,6 +4485,35 @@ int migrate_task_to(struct task_struct *p, int target_cpu)
 
 	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
 }
+
+/*
+ * Requeue a task on a given node and accurately track the number of NUMA
+ * tasks on the runqueues
+ */
+void sched_setnuma(struct task_struct *p, int nid)
+{
+	struct rq *rq;
+	unsigned long flags;
+	bool on_rq, running;
+
+	rq = task_rq_lock(p, &flags);
+	on_rq = p->on_rq;
+	running = task_current(rq, p);
+
+	if (on_rq)
+		dequeue_task(rq, p, 0);
+	if (running)
+		p->sched_class->put_prev_task(rq, p);
+
+	p->numa_preferred_nid = nid;
+	p->numa_migrate_seq = 1;
+
+	if (running)
+		p->sched_class->set_curr_task(rq);
+	if (on_rq)
+		enqueue_task(rq, p, 0);
+	task_rq_unlock(rq, p, &flags);
+}
 #endif
 
 /*
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f232be6..83c6e69 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -888,6 +888,18 @@ static unsigned int task_scan_max(struct task_struct *p)
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 4;
 
+static void account_numa_enqueue(struct rq *rq, struct task_struct *p)
+{
+	rq->nr_numa_running += (p->numa_preferred_nid != -1);
+	rq->nr_preferred_running += (p->numa_preferred_nid == task_node(p));
+}
+
+static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
+{
+	rq->nr_numa_running -= (p->numa_preferred_nid != -1);
+	rq->nr_preferred_running -= (p->numa_preferred_nid == task_node(p));
+}
+
 struct numa_group {
 	atomic_t refcount;
 
@@ -1227,6 +1239,8 @@ static int task_numa_migrate(struct task_struct *p)
 	if (env.best_cpu == -1)
 		return -EAGAIN;
 
+	sched_setnuma(p, env.dst_nid);
+
 	if (env.best_task == NULL) {
 		int ret = migrate_task_to(p, env.best_cpu);
 		return ret;
@@ -1342,8 +1356,7 @@ static void task_numa_placement(struct task_struct *p)
 	/* Preferred node as the node with the most faults */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
 		/* Update the preferred nid and migrate task if possible */
-		p->numa_preferred_nid = max_nid;
-		p->numa_migrate_seq = 1;
+		sched_setnuma(p, max_nid);
 		numa_migrate_preferred(p);
 	}
 }
@@ -1741,6 +1754,14 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 {
 }
+
+static inline void account_numa_enqueue(struct rq *rq, struct task_struct *p)
+{
+}
+
+static inline void account_numa_dequeue(struct rq *rq, struct task_struct *p)
+{
+}
 #endif /* CONFIG_NUMA_BALANCING */
 
 static void
@@ -1750,8 +1771,12 @@ account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	if (!parent_entity(se))
 		update_load_add(&rq_of(cfs_rq)->load, se->load.weight);
 #ifdef CONFIG_SMP
-	if (entity_is_task(se))
-		list_add(&se->group_node, &rq_of(cfs_rq)->cfs_tasks);
+	if (entity_is_task(se)) {
+		struct rq *rq = rq_of(cfs_rq);
+
+		account_numa_enqueue(rq, task_of(se));
+		list_add(&se->group_node, &rq->cfs_tasks);
+	}
 #endif
 	cfs_rq->nr_running++;
 }
@@ -1762,8 +1787,10 @@ account_entity_dequeue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	update_load_sub(&cfs_rq->load, se->load.weight);
 	if (!parent_entity(se))
 		update_load_sub(&rq_of(cfs_rq)->load, se->load.weight);
-	if (entity_is_task(se))
+	if (entity_is_task(se)) {
+		account_numa_dequeue(rq_of(cfs_rq), task_of(se));
 		list_del_init(&se->group_node);
+	}
 	cfs_rq->nr_running--;
 }
 
@@ -4558,6 +4585,8 @@ static bool yield_to_task_fair(struct rq *rq, struct task_struct *p, bool preemp
 
 static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 
+enum fbq_type { regular, remote, all };
+
 #define LBF_ALL_PINNED	0x01
 #define LBF_NEED_BREAK	0x02
 #define LBF_DST_PINNED  0x04
@@ -4584,6 +4613,8 @@ struct lb_env {
 	unsigned int		loop;
 	unsigned int		loop_break;
 	unsigned int		loop_max;
+
+	enum fbq_type		fbq_type;
 };
 
 /*
@@ -5049,6 +5080,10 @@ struct sg_lb_stats {
 	unsigned int group_weight;
 	int group_imb; /* Is there an imbalance in the group ? */
 	int group_has_capacity; /* Is there extra capacity in the group? */
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned int nr_numa_running;
+	unsigned int nr_preferred_running;
+#endif
 };
 
 /*
@@ -5340,6 +5375,10 @@ static inline void update_sg_lb_stats(struct lb_env *env,
 
 		sgs->group_load += load;
 		sgs->sum_nr_running += nr_running;
+#ifdef CONFIG_NUMA_BALANCING
+		sgs->nr_numa_running += rq->nr_numa_running;
+		sgs->nr_preferred_running += rq->nr_preferred_running;
+#endif
 		sgs->sum_weighted_load += weighted_cpuload(i);
 		if (idle_cpu(i))
 			sgs->idle_cpus++;
@@ -5414,14 +5453,43 @@ static bool update_sd_pick_busiest(struct lb_env *env,
 	return false;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static inline enum fbq_type fbq_classify_group(struct sg_lb_stats *sgs)
+{
+	if (sgs->sum_nr_running > sgs->nr_numa_running)
+		return regular;
+	if (sgs->sum_nr_running > sgs->nr_preferred_running)
+		return remote;
+	return all;
+}
+
+static inline enum fbq_type fbq_classify_rq(struct rq *rq)
+{
+	if (rq->nr_running > rq->nr_numa_running)
+		return regular;
+	if (rq->nr_running > rq->nr_preferred_running)
+		return remote;
+	return all;
+}
+#else
+static inline enum fbq_type fbq_classify_group(struct sg_lb_stats *sgs)
+{
+	return all;
+}
+
+static inline enum fbq_type fbq_classify_rq(struct rq *rq)
+{
+	return regular;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 /**
  * update_sd_lb_stats - Update sched_domain's statistics for load balancing.
  * @env: The load balancing environment.
  * @balance: Should we balance.
  * @sds: variable to hold the statistics for this sched_domain.
  */
-static inline void update_sd_lb_stats(struct lb_env *env,
-					struct sd_lb_stats *sds)
+static inline void update_sd_lb_stats(struct lb_env *env, struct sd_lb_stats *sds)
 {
 	struct sched_domain *child = env->sd->child;
 	struct sched_group *sg = env->sd->groups;
@@ -5471,6 +5539,9 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 
 		sg = sg->next;
 	} while (sg != env->sd->groups);
+
+	if (env->sd->flags & SD_NUMA)
+		env->fbq_type = fbq_classify_group(&sds->busiest_stat);
 }
 
 /**
@@ -5773,15 +5844,47 @@ static struct rq *find_busiest_queue(struct lb_env *env,
 	int i;
 
 	for_each_cpu_and(i, sched_group_cpus(group), env->cpus) {
-		unsigned long power = power_of(i);
-		unsigned long capacity = DIV_ROUND_CLOSEST(power,
-							   SCHED_POWER_SCALE);
-		unsigned long wl;
+		unsigned long power, capacity, wl;
+		enum fbq_type rt;
 
+		rq = cpu_rq(i);
+		rt = fbq_classify_rq(rq);
+
+#ifdef CONFIG_NUMA_BALANCING
+		trace_printk("group(%d:%pc) rq(%d): wl: %lu nr: %d nrn: %d nrp: %d gt:%d rt:%d\n",
+				env->sd->level, sched_group_cpus(group), i,
+				weighted_cpuload(i), rq->nr_running,
+				rq->nr_numa_running, rq->nr_preferred_running,
+				env->fbq_type, rt);
+#endif
+
+		/*
+		 * We classify groups/runqueues into three groups:
+		 *  - regular: there are !numa tasks
+		 *  - remote:  there are numa tasks that run on the 'wrong' node
+		 *  - all:     there is no distinction
+		 *
+		 * In order to avoid migrating ideally placed numa tasks,
+		 * ignore those when there's better options.
+		 *
+		 * If we ignore the actual busiest queue to migrate another
+		 * task, the next balance pass can still reduce the busiest
+		 * queue by moving tasks around inside the node.
+		 *
+		 * If we cannot move enough load due to this classification
+		 * the next pass will adjust the group classification and
+		 * allow migration of more tasks.
+		 *
+		 * Both cases only affect the total convergence complexity.
+		 */
+		if (rt > env->fbq_type)
+			continue;
+
+		power = power_of(i);
+		capacity = DIV_ROUND_CLOSEST(power, SCHED_POWER_SCALE);
 		if (!capacity)
 			capacity = fix_small_capacity(env->sd, group);
 
-		rq = cpu_rq(i);
 		wl = weighted_cpuload(i);
 
 		/*
@@ -5893,6 +5996,7 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 		.idle		= idle,
 		.loop_break	= sched_nr_migrate_break,
 		.cpus		= cpus,
+		.fbq_type	= all,
 	};
 
 	/*
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 657472d..22c470c 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -407,6 +407,10 @@ struct rq {
 	 * remote CPUs use both these fields when doing load calculation.
 	 */
 	unsigned int nr_running;
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned int nr_numa_running;
+	unsigned int nr_preferred_running;
+#endif
 	#define CPU_LOAD_IDX_MAX 5
 	unsigned long cpu_load[CPU_LOAD_IDX_MAX];
 	unsigned long last_load_update_tick;
@@ -555,6 +559,7 @@ static inline u64 rq_clock_task(struct rq *rq)
 }
 
 #ifdef CONFIG_NUMA_BALANCING
+extern void sched_setnuma(struct task_struct *p, int node);
 extern int migrate_task_to(struct task_struct *p, int cpu);
 extern int migrate_swap(struct task_struct *, struct task_struct *);
 #endif /* CONFIG_NUMA_BALANCING */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
