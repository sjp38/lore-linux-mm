Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 2D4F86B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 11:07:06 -0400 (EDT)
Date: Thu, 1 Nov 2012 15:06:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 23/31] sched, numa, mm: Implement home-node awareness
Message-ID: <20121101150659.GA3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124834.233991291@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124834.233991291@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:40PM +0200, Peter Zijlstra wrote:
> Implement home node preference in the scheduler's load-balancer.
> 
> This is done in four pieces:
> 
>  - task_numa_hot(); make it harder to migrate tasks away from their
>    home-node, controlled using the NUMA_HOT feature flag.
> 

We don't actually know if it's hotm we're guessing. task_numa_stick()?

>  - select_task_rq_fair(); prefer placing the task in their home-node,
>    controlled using the NUMA_TTWU_BIAS feature flag. Disabled by
>    default for we found this to be far too agressive. 
> 

Separate patch then?

>  - load_balance(); during the regular pull load-balance pass, try
>    pulling tasks that are on the wrong node first with a preference
>    of moving them nearer to their home-node through task_numa_hot(),
>    controlled through the NUMA_PULL feature flag.
> 

Sounds sensible.

>  - load_balance(); when the balancer finds no imbalance, introduce
>    some such that it still prefers to move tasks towards their
>    home-node, using active load-balance if needed, controlled through
>    the NUMA_PULL_BIAS feature flag.
> 
>    In particular, only introduce this BIAS if the system is otherwise
>    properly (weight) balanced and we either have an offnode or !numa
>    task to trade for it.
> 

Again, sounds reasonable.

> In order to easily find off-node tasks, split the per-cpu task list
> into two parts.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Paul Turner <pjt@google.com>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  include/linux/sched.h   |    3 
>  kernel/sched/core.c     |   28 +++
>  kernel/sched/debug.c    |    3 
>  kernel/sched/fair.c     |  349 +++++++++++++++++++++++++++++++++++++++++++++---
>  kernel/sched/features.h |   10 +
>  kernel/sched/sched.h    |   17 ++
>  6 files changed, 384 insertions(+), 26 deletions(-)
> 
> Index: tip/include/linux/sched.h
> ===================================================================
> --- tip.orig/include/linux/sched.h
> +++ tip/include/linux/sched.h
> @@ -823,6 +823,7 @@ enum cpu_idle_type {
>  #define SD_ASYM_PACKING		0x0800  /* Place busy groups earlier in the domain */
>  #define SD_PREFER_SIBLING	0x1000	/* Prefer to place tasks in a sibling domain */
>  #define SD_OVERLAP		0x2000	/* sched_domains of this level overlap */
> +#define SD_NUMA			0x4000	/* cross-node balancing */
>  
>  extern int __weak arch_sd_sibiling_asym_packing(void);
>  
> @@ -1481,6 +1482,7 @@ struct task_struct {
>  #endif
>  #ifdef CONFIG_SCHED_NUMA
>  	int node;
> +	unsigned long numa_contrib;

comment!

/*
 * numa_contrib records how much of this tasks load factor was due to
 * running away from its homoe node
 */

It contributes to numa_offnode_weight but where do we make any decisions
based on it? Superficially this is for stats but it gets bubbled all the
way up to the sched domain where the actual decisions are made. The
comment could be a lot more helpful in spelling this out.

>  #endif
>  	struct rcu_head rcu;
>  
> @@ -2084,6 +2086,7 @@ extern int sched_setscheduler(struct tas
>  			      const struct sched_param *);
>  extern int sched_setscheduler_nocheck(struct task_struct *, int,
>  				      const struct sched_param *);
> +extern void sched_setnode(struct task_struct *p, int node);
>  extern struct task_struct *idle_task(int cpu);
>  /**
>   * is_idle_task - is the specified task an idle task?
> Index: tip/kernel/sched/core.c
> ===================================================================
> --- tip.orig/kernel/sched/core.c
> +++ tip/kernel/sched/core.c
> @@ -5484,7 +5484,9 @@ static void destroy_sched_domains(struct
>  DEFINE_PER_CPU(struct sched_domain *, sd_llc);
>  DEFINE_PER_CPU(int, sd_llc_id);
>  
> -static void update_top_cache_domain(int cpu)
> +DEFINE_PER_CPU(struct sched_domain *, sd_node);
> +
> +static void update_domain_cache(int cpu)
>  {
>  	struct sched_domain *sd;
>  	int id = cpu;
> @@ -5495,6 +5497,15 @@ static void update_top_cache_domain(int
>  
>  	rcu_assign_pointer(per_cpu(sd_llc, cpu), sd);
>  	per_cpu(sd_llc_id, cpu) = id;
> +
> +	for_each_domain(cpu, sd) {
> +		if (cpumask_equal(sched_domain_span(sd),
> +				  cpumask_of_node(cpu_to_node(cpu))))
> +			goto got_node;
> +	}
> +	sd = NULL;
> +got_node:
> +	rcu_assign_pointer(per_cpu(sd_node, cpu), sd);
>  }

Not obvious how this connects to the rest of the patch at all.

>  
>  /*
> @@ -5537,7 +5548,7 @@ cpu_attach_domain(struct sched_domain *s
>  	rcu_assign_pointer(rq->sd, sd);
>  	destroy_sched_domains(tmp, cpu);
>  
> -	update_top_cache_domain(cpu);
> +	update_domain_cache(cpu);
>  }
>  
>  /* cpus with isolated domains */
> @@ -5965,9 +5976,9 @@ static struct sched_domain_topology_leve
>   * Requeues a task ensuring its on the right load-balance list so
>   * that it might get migrated to its new home.
>   *
> - * Note that we cannot actively migrate ourselves since our callers
> - * can be from atomic context. We rely on the regular load-balance
> - * mechanisms to move us around -- its all preference anyway.
> + * Since home-node is pure preference there's no hard migrate to force
> + * us anywhere, this also allows us to call this from atomic context if
> + * required.
>   */
>  void sched_setnode(struct task_struct *p, int node)
>  {
> @@ -6040,6 +6051,7 @@ sd_numa_init(struct sched_domain_topolog
>  					| 0*SD_SHARE_PKG_RESOURCES
>  					| 1*SD_SERIALIZE
>  					| 0*SD_PREFER_SIBLING
> +					| 1*SD_NUMA
>  					| sd_local_flags(level)
>  					,
>  		.last_balance		= jiffies,
> @@ -6901,6 +6913,12 @@ void __init sched_init(void)
>  		rq->avg_idle = 2*sysctl_sched_migration_cost;
>  
>  		INIT_LIST_HEAD(&rq->cfs_tasks);
> +#ifdef CONFIG_SCHED_NUMA
> +		INIT_LIST_HEAD(&rq->offnode_tasks);
> +		rq->onnode_running = 0;
> +		rq->offnode_running = 0;
> +		rq->offnode_weight = 0;
> +#endif
>  
>  		rq_attach_root(rq, &def_root_domain);
>  #ifdef CONFIG_NO_HZ
> Index: tip/kernel/sched/debug.c
> ===================================================================
> --- tip.orig/kernel/sched/debug.c
> +++ tip/kernel/sched/debug.c
> @@ -132,6 +132,9 @@ print_task(struct seq_file *m, struct rq
>  	SEQ_printf(m, "%15Ld %15Ld %15Ld.%06ld %15Ld.%06ld %15Ld.%06ld",
>  		0LL, 0LL, 0LL, 0L, 0LL, 0L, 0LL, 0L);
>  #endif
> +#ifdef CONFIG_SCHED_NUMA
> +	SEQ_printf(m, " %d/%d", p->node, cpu_to_node(task_cpu(p)));
> +#endif
>  #ifdef CONFIG_CGROUP_SCHED
>  	SEQ_printf(m, " %s", task_group_path(task_group(p)));
>  #endif
> Index: tip/kernel/sched/fair.c
> ===================================================================
> --- tip.orig/kernel/sched/fair.c
> +++ tip/kernel/sched/fair.c
> @@ -26,6 +26,7 @@
>  #include <linux/slab.h>
>  #include <linux/profile.h>
>  #include <linux/interrupt.h>
> +#include <linux/random.h>
>  
>  #include <trace/events/sched.h>
>  
> @@ -773,6 +774,51 @@ update_stats_curr_start(struct cfs_rq *c
>  }
>  
>  /**************************************************
> + * Scheduling class numa methods.
> + */
> +
> +#ifdef CONFIG_SMP
> +static unsigned long task_h_load(struct task_struct *p);
> +#endif
> +
> +#ifdef CONFIG_SCHED_NUMA
> +static struct list_head *account_numa_enqueue(struct rq *rq, struct task_struct *p)
> +{
> +	struct list_head *tasks = &rq->cfs_tasks;
> +
> +	if (tsk_home_node(p) != cpu_to_node(task_cpu(p))) {
> +		p->numa_contrib = task_h_load(p);
> +		rq->offnode_weight += p->numa_contrib;
> +		rq->offnode_running++;
> +		tasks = &rq->offnode_tasks;
> +	} else
> +		rq->onnode_running++;
> +
> +	return tasks;
> +}
> +
> +static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
> +{
> +	if (tsk_home_node(p) != cpu_to_node(task_cpu(p))) {
> +		rq->offnode_weight -= p->numa_contrib;
> +		rq->offnode_running--;
> +	} else
> +		rq->onnode_running--;
> +}
> +#else
> +#ifdef CONFIG_SMP
> +static struct list_head *account_numa_enqueue(struct rq *rq, struct task_struct *p)
> +{
> +	return NULL;
> +}
> +#endif
> +
> +static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
> +{
> +}
> +#endif /* CONFIG_SCHED_NUMA */
> +
> +/**************************************************
>   * Scheduling class queueing methods:
>   */
>  
> @@ -783,9 +829,17 @@ account_entity_enqueue(struct cfs_rq *cf
>  	if (!parent_entity(se))
>  		update_load_add(&rq_of(cfs_rq)->load, se->load.weight);
>  #ifdef CONFIG_SMP
> -	if (entity_is_task(se))
> -		list_add(&se->group_node, &rq_of(cfs_rq)->cfs_tasks);
> -#endif
> +	if (entity_is_task(se)) {
> +		struct rq *rq = rq_of(cfs_rq);
> +		struct task_struct *p = task_of(se);
> +		struct list_head *tasks = &rq->cfs_tasks;
> +
> +		if (tsk_home_node(p) != -1)
> +			tasks = account_numa_enqueue(rq, p);
> +
> +		list_add(&se->group_node, tasks);
> +	}
> +#endif /* CONFIG_SMP */
>  	cfs_rq->nr_running++;
>  }
>  
> @@ -795,8 +849,14 @@ account_entity_dequeue(struct cfs_rq *cf
>  	update_load_sub(&cfs_rq->load, se->load.weight);
>  	if (!parent_entity(se))
>  		update_load_sub(&rq_of(cfs_rq)->load, se->load.weight);
> -	if (entity_is_task(se))
> +	if (entity_is_task(se)) {
> +		struct task_struct *p = task_of(se);
> +
>  		list_del_init(&se->group_node);
> +
> +		if (tsk_home_node(p) != -1)
> +			account_numa_dequeue(rq_of(cfs_rq), p);
> +	}
>  	cfs_rq->nr_running--;
>  }
>  
> @@ -2681,6 +2741,35 @@ done:
>  	return target;
>  }
>  
> +#ifdef CONFIG_SCHED_NUMA
> +static inline bool pick_numa_rand(int n)
> +{
> +	return !(get_random_int() % n);
> +}
> +

"return get_random_int() % n" I could understand but this thing looks like
it only returns 1 if the random number is 0 or some multiple of n. Hard
to see how this is going to randomly select a node as such.

> +/*
> + * Pick a random elegible CPU in the target node, hopefully faster
> + * than doing a least-loaded scan.
> + */
> +static int numa_select_node_cpu(struct task_struct *p, int node)
> +{
> +	int weight = cpumask_weight(cpumask_of_node(node));
> +	int i, cpu = -1;
> +
> +	for_each_cpu_and(i, cpumask_of_node(node), tsk_cpus_allowed(p)) {
> +		if (cpu < 0 || pick_numa_rand(weight))
> +			cpu = i;
> +	}
> +
> +	return cpu;
> +}
> +#else
> +static int numa_select_node_cpu(struct task_struct *p, int node)
> +{
> +	return -1;
> +}
> +#endif /* CONFIG_SCHED_NUMA */
> +
>  /*
>   * sched_balance_self: balance the current task (running on cpu) in domains
>   * that have the 'flag' flag set. In practice, this is SD_BALANCE_FORK and
> @@ -2701,6 +2790,7 @@ select_task_rq_fair(struct task_struct *
>  	int new_cpu = cpu;
>  	int want_affine = 0;
>  	int sync = wake_flags & WF_SYNC;
> +	int node = tsk_home_node(p);
>  
>  	if (p->nr_cpus_allowed == 1)
>  		return prev_cpu;
> @@ -2712,6 +2802,36 @@ select_task_rq_fair(struct task_struct *
>  	}
>  
>  	rcu_read_lock();
> +	if (sched_feat_numa(NUMA_TTWU_BIAS) && node != -1) {
> +		/*
> +		 * For fork,exec find the idlest cpu in the home-node.
> +		 */
> +		if (sd_flag & (SD_BALANCE_FORK|SD_BALANCE_EXEC)) {
> +			int node_cpu = numa_select_node_cpu(p, node);
> +			if (node_cpu < 0)
> +				goto find_sd;
> +
> +			new_cpu = cpu = node_cpu;
> +			sd = per_cpu(sd_node, cpu);
> +			goto pick_idlest;
> +		}
> +
> +		/*
> +		 * For wake, pretend we were running in the home-node.
> +		 */
> +		if (cpu_to_node(prev_cpu) != node) {
> +			int node_cpu = numa_select_node_cpu(p, node);
> +			if (node_cpu < 0)
> +				goto find_sd;
> +
> +			if (sched_feat_numa(NUMA_TTWU_TO))
> +				cpu = node_cpu;
> +			else
> +				prev_cpu = node_cpu;
> +		}
> +	}
> +
> +find_sd:
>  	for_each_domain(cpu, tmp) {
>  		if (!(tmp->flags & SD_LOAD_BALANCE))
>  			continue;
> @@ -2738,6 +2858,7 @@ select_task_rq_fair(struct task_struct *
>  		goto unlock;
>  	}
>  
> +pick_idlest:
>  	while (sd) {
>  		int load_idx = sd->forkexec_idx;
>  		struct sched_group *group;
> @@ -3060,6 +3181,8 @@ struct lb_env {
>  
>  	unsigned int		flags;
>  
> +	struct list_head	*tasks;
> +
>  	unsigned int		loop;
>  	unsigned int		loop_break;
>  	unsigned int		loop_max;
> @@ -3080,11 +3203,28 @@ static void move_task(struct task_struct
>  	check_preempt_curr(env->dst_rq, p, 0);
>  }
>  
> +static int task_numa_hot(struct task_struct *p, struct lb_env *env)
> +{

bool

document return value.

It's not actually returning if the node is "hot" or "cold", it's
returning if it should stick with the current node or not.

> +	int from_dist, to_dist;
> +	int node = tsk_home_node(p);
> +
> +	if (!sched_feat_numa(NUMA_HOT) || node == -1)
> +		return 0; /* no node preference */
> +
> +	from_dist = node_distance(cpu_to_node(env->src_cpu), node);
> +	to_dist = node_distance(cpu_to_node(env->dst_cpu), node);
> +
> +	if (to_dist < from_dist)
> +		return 0; /* getting closer is ok */
> +
> +	return 1; /* stick to where we are */
> +}
> +

Ok.

>  /*
>   * Is this task likely cache-hot:
>   */
>  static int
> -task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
> +task_hot(struct task_struct *p, struct lb_env *env)
>  {
>  	s64 delta;
>  
> @@ -3107,7 +3247,7 @@ task_hot(struct task_struct *p, u64 now,
>  	if (sysctl_sched_migration_cost == 0)
>  		return 0;
>  
> -	delta = now - p->se.exec_start;
> +	delta = env->src_rq->clock_task - p->se.exec_start;
>  

This looks like a cleanup. Not obviously connected with the rest of the
patch.

>  	return delta < (s64)sysctl_sched_migration_cost;
>  }
> @@ -3164,7 +3304,9 @@ int can_migrate_task(struct task_struct
>  	 * 2) too many balance attempts have failed.
>  	 */
>  
> -	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
> +	tsk_cache_hot = task_hot(p, env);
> +	if (env->idle == CPU_NOT_IDLE)
> +		tsk_cache_hot |= task_numa_hot(p, env);
>  	if (!tsk_cache_hot ||
>  		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
>  #ifdef CONFIG_SCHEDSTATS
> @@ -3190,11 +3332,11 @@ int can_migrate_task(struct task_struct
>   *
>   * Called with both runqueues locked.
>   */
> -static int move_one_task(struct lb_env *env)
> +static int __move_one_task(struct lb_env *env)
>  {
>  	struct task_struct *p, *n;
>  
> -	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
> +	list_for_each_entry_safe(p, n, env->tasks, se.group_node) {
>  		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
>  			continue;
>  
> @@ -3213,7 +3355,20 @@ static int move_one_task(struct lb_env *
>  	return 0;
>  }
>  
> -static unsigned long task_h_load(struct task_struct *p);
> +static int move_one_task(struct lb_env *env)
> +{

This function is not actually used in this patch. Glancing forward I see
that you later call this from the load balancer which makes sense but overall
this patch is hard to follow because it's not clear which parts are relevant
and which are not as this hunk is not critical to the concept of home-node
awareness.  It's part of the CPU migration policy when schednuma is enabled.

> +	if (sched_feat_numa(NUMA_PULL)) {
> +		env->tasks = offnode_tasks(env->src_rq);
> +		if (__move_one_task(env))
> +			return 1;
> +	}
> +
> +	env->tasks = &env->src_rq->cfs_tasks;
> +	if (__move_one_task(env))
> +		return 1;
> +
> +	return 0;
> +}
>  
>  static const unsigned int sched_nr_migrate_break = 32;
>  
> @@ -3226,7 +3381,6 @@ static const unsigned int sched_nr_migra
>   */
>  static int move_tasks(struct lb_env *env)
>  {
> -	struct list_head *tasks = &env->src_rq->cfs_tasks;
>  	struct task_struct *p;
>  	unsigned long load;
>  	int pulled = 0;
> @@ -3234,8 +3388,9 @@ static int move_tasks(struct lb_env *env
>  	if (env->imbalance <= 0)
>  		return 0;
>  
> -	while (!list_empty(tasks)) {
> -		p = list_first_entry(tasks, struct task_struct, se.group_node);
> +again:
> +	while (!list_empty(env->tasks)) {
> +		p = list_first_entry(env->tasks, struct task_struct, se.group_node);
>  
>  		env->loop++;
>  		/* We've more or less seen every task there is, call it quits */
> @@ -3246,7 +3401,7 @@ static int move_tasks(struct lb_env *env
>  		if (env->loop > env->loop_break) {
>  			env->loop_break += sched_nr_migrate_break;
>  			env->flags |= LBF_NEED_BREAK;
> -			break;
> +			goto out;
>  		}
>  
>  		if (throttled_lb_pair(task_group(p), env->src_cpu, env->dst_cpu))
> @@ -3274,7 +3429,7 @@ static int move_tasks(struct lb_env *env
>  		 * the critical section.
>  		 */
>  		if (env->idle == CPU_NEWLY_IDLE)
> -			break;
> +			goto out;
>  #endif
>  
>  		/*
> @@ -3282,13 +3437,20 @@ static int move_tasks(struct lb_env *env
>  		 * weighted load.
>  		 */
>  		if (env->imbalance <= 0)
> -			break;
> +			goto out;
>  
>  		continue;
>  next:
> -		list_move_tail(&p->se.group_node, tasks);
> +		list_move_tail(&p->se.group_node, env->tasks);
> +	}
> +
> +	if (env->tasks == offnode_tasks(env->src_rq)) {
> +		env->tasks = &env->src_rq->cfs_tasks;
> +		env->loop = 0;
> +		goto again;
>  	}
>  
> +out:
>  	/*
>  	 * Right now, this is one of only two places move_task() is called,
>  	 * so we can safely collect move_task() stats here rather than
> @@ -3407,12 +3569,13 @@ static inline void update_shares(int cpu
>  static inline void update_h_load(long cpu)
>  {
>  }
> -
> +#ifdef CONFIG_SMP
>  static unsigned long task_h_load(struct task_struct *p)
>  {
>  	return p->se.load.weight;
>  }
>  #endif
> +#endif
>  
>  /********** Helpers for find_busiest_group ************************/
>  /*
> @@ -3443,6 +3606,14 @@ struct sd_lb_stats {
>  	unsigned int  busiest_group_weight;
>  
>  	int group_imb; /* Is there imbalance in this sd */
> +#ifdef CONFIG_SCHED_NUMA
> +	struct sched_group *numa_group; /* group which has offnode_tasks */
> +	unsigned long numa_group_weight;
> +	unsigned long numa_group_running;
> +
> +	unsigned long this_offnode_running;
> +	unsigned long this_onnode_running;
> +#endif

So from here is where the actual home-node awareness part kicks in.

>  };
>  
>  /*
> @@ -3458,6 +3629,11 @@ struct sg_lb_stats {
>  	unsigned long group_weight;
>  	int group_imb; /* Is there an imbalance in the group ? */
>  	int group_has_capacity; /* Is there extra capacity in the group? */
> +#ifdef CONFIG_SCHED_NUMA
> +	unsigned long numa_offnode_weight;
> +	unsigned long numa_offnode_running;
> +	unsigned long numa_onnode_running;
> +#endif
>  };
>  
>  /**
> @@ -3486,6 +3662,121 @@ static inline int get_sd_load_idx(struct
>  	return load_idx;
>  }
>  
> +#ifdef CONFIG_SCHED_NUMA
> +static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
> +{
> +	sgs->numa_offnode_weight += rq->offnode_weight;
> +	sgs->numa_offnode_running += rq->offnode_running;
> +	sgs->numa_onnode_running += rq->onnode_running;
> +}
> +
> +/*
> + * Since the offnode lists are indiscriminate (they contain tasks for all other
> + * nodes) it is impossible to say if there's any task on there that wants to
> + * move towards the pulling cpu. Therefore select a random offnode list to pull
> + * from such that eventually we'll try them all.
> + *
> + * Select a random group that has offnode tasks as sds->numa_group
> + */

The comment says we select a random group but this thing returns void.
We're not selecting anything.

> +static inline void update_sd_numa_stats(struct sched_domain *sd,
> +		struct sched_group *group, struct sd_lb_stats *sds,
> +		int local_group, struct sg_lb_stats *sgs)
> +{
> +	if (!(sd->flags & SD_NUMA))
> +		return;
> +
> +	if (local_group) {
> +		sds->this_offnode_running = sgs->numa_offnode_running;
> +		sds->this_onnode_running  = sgs->numa_onnode_running;
> +		return;
> +	}
> +
> +	if (!sgs->numa_offnode_running)
> +		return;
> +
> +	if (!sds->numa_group || pick_numa_rand(sd->span_weight / group->group_weight)) {

What does passing in sd->span_weight / group->group_weight) mean?

> +		sds->numa_group = group;
> +		sds->numa_group_weight = sgs->numa_offnode_weight;
> +		sds->numa_group_running = sgs->numa_offnode_running;
> +	}
> +}
> +
> +/*
> + * Pick a random queue from the group that has offnode tasks.
> + */
> +static struct rq *find_busiest_numa_queue(struct lb_env *env,
> +					  struct sched_group *group)
> +{
> +	struct rq *busiest = NULL, *rq;
> +	int cpu;
> +
> +	for_each_cpu_and(cpu, sched_group_cpus(group), env->cpus) {
> +		rq = cpu_rq(cpu);
> +		if (!rq->offnode_running)
> +			continue;
> +		if (!busiest || pick_numa_rand(group->group_weight))
> +			busiest = rq;
> +	}
> +
> +	return busiest;
> +}

So if the random number if 0 or group_weight it will be randomly considered
the busiest runqueue. Any idea how often that happens?  I have a suspicion
that the random perturb logic to avoid worst-case scenarios may not be
operating as expected.

> +
> +/*
> + * Called in case of no other imbalance, if there is a queue running offnode
> + * tasksk we'll say we're imbalanced anyway to nudge these tasks towards their
> + * proper node.
> + */
> +static inline int check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
> +{
> +	if (!sched_feat(NUMA_PULL_BIAS))
> +		return 0;
> +
> +	if (!sds->numa_group)
> +		return 0;
> +
> +	/*
> +	 * Only pull an offnode task home if we've got offnode or !numa tasks to trade for it.
> +	 */
> +	if (!sds->this_offnode_running &&
> +	    !(sds->this_nr_running - sds->this_onnode_running - sds->this_offnode_running))
> +		return 0;
> +
> +	env->imbalance = sds->numa_group_weight / sds->numa_group_running;
> +	sds->busiest = sds->numa_group;
> +	env->find_busiest_queue = find_busiest_numa_queue;
> +	return 1;
> +}
> +
> +static inline bool need_active_numa_balance(struct lb_env *env)
> +{
> +	return env->find_busiest_queue == find_busiest_numa_queue &&
> +			env->src_rq->offnode_running == 1 &&
> +			env->src_rq->nr_running == 1;
> +}
> +
> +#else /* CONFIG_SCHED_NUMA */
> +
> +static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
> +{
> +}
> +
> +static inline void update_sd_numa_stats(struct sched_domain *sd,
> +		struct sched_group *group, struct sd_lb_stats *sds,
> +		int local_group, struct sg_lb_stats *sgs)
> +{
> +}
> +
> +static inline int check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
> +{
> +	return 0;
> +}
> +
> +static inline bool need_active_numa_balance(struct lb_env *env)
> +{
> +	return false;
> +}
> +#endif /* CONFIG_SCHED_NUMA */
> +
>  unsigned long default_scale_freq_power(struct sched_domain *sd, int cpu)
>  {
>  	return SCHED_POWER_SCALE;
> @@ -3701,6 +3992,8 @@ static inline void update_sg_lb_stats(st
>  		sgs->sum_weighted_load += weighted_cpuload(i);
>  		if (idle_cpu(i))
>  			sgs->idle_cpus++;
> +
> +		update_sg_numa_stats(sgs, rq);
>  	}
>  
>  	/*
> @@ -3854,6 +4147,8 @@ static inline void update_sd_lb_stats(st
>  			sds->group_imb = sgs.group_imb;
>  		}
>  
> +		update_sd_numa_stats(env->sd, sg, sds, local_group, &sgs);
> +
>  		sg = sg->next;
>  	} while (sg != env->sd->groups);
>  }
> @@ -4084,7 +4379,7 @@ find_busiest_group(struct lb_env *env, i
>  
>  	/* There is no busy sibling group to pull tasks from */
>  	if (!sds.busiest || sds.busiest_nr_running == 0)
> -		goto out_balanced;
> +		goto ret;
>  
>  	sds.avg_load = (SCHED_POWER_SCALE * sds.total_load) / sds.total_pwr;
>  
> @@ -4106,14 +4401,14 @@ find_busiest_group(struct lb_env *env, i
>  	 * don't try and pull any tasks.
>  	 */
>  	if (sds.this_load >= sds.max_load)
> -		goto out_balanced;
> +		goto ret;
>  
>  	/*
>  	 * Don't pull any tasks if this group is already above the domain
>  	 * average load.
>  	 */
>  	if (sds.this_load >= sds.avg_load)
> -		goto out_balanced;
> +		goto ret;
>  
>  	if (env->idle == CPU_IDLE) {
>  		/*
> @@ -4140,6 +4435,9 @@ force_balance:
>  	return sds.busiest;
>  
>  out_balanced:
> +	if (check_numa_busiest_group(env, &sds))
> +		return sds.busiest;
> +
>  ret:
>  	env->imbalance = 0;
>  	return NULL;
> @@ -4218,6 +4516,9 @@ static int need_active_balance(struct lb
>  			return 1;
>  	}
>  
> +	if (need_active_numa_balance(env))
> +		return 1;
> +
>  	return unlikely(sd->nr_balance_failed > sd->cache_nice_tries+2);
>  }
>  
> @@ -4270,6 +4571,8 @@ redo:
>  		schedstat_inc(sd, lb_nobusyq[idle]);
>  		goto out_balanced;
>  	}
> +	env.src_rq  = busiest;
> +	env.src_cpu = busiest->cpu;
>  
>  	BUG_ON(busiest == env.dst_rq);
>  
> @@ -4288,6 +4591,10 @@ redo:
>  		env.src_cpu   = busiest->cpu;
>  		env.src_rq    = busiest;
>  		env.loop_max  = min(sysctl_sched_nr_migrate, busiest->nr_running);
> +		if (sched_feat_numa(NUMA_PULL))
> +			env.tasks = offnode_tasks(busiest);
> +		else
> +			env.tasks = &busiest->cfs_tasks;
>  
>  		update_h_load(env.src_cpu);
>  more_balance:
> Index: tip/kernel/sched/features.h
> ===================================================================
> --- tip.orig/kernel/sched/features.h
> +++ tip/kernel/sched/features.h
> @@ -61,3 +61,13 @@ SCHED_FEAT(TTWU_QUEUE, true)
>  SCHED_FEAT(FORCE_SD_OVERLAP, false)
>  SCHED_FEAT(RT_RUNTIME_SHARE, true)
>  SCHED_FEAT(LB_MIN, false)
> +
> +#ifdef CONFIG_SCHED_NUMA
> +SCHED_FEAT(NUMA,           true)
> +SCHED_FEAT(NUMA_HOT,       true)
> +SCHED_FEAT(NUMA_TTWU_BIAS, false)
> +SCHED_FEAT(NUMA_TTWU_TO,   false)
> +SCHED_FEAT(NUMA_PULL,      true)
> +SCHED_FEAT(NUMA_PULL_BIAS, true)
> +#endif

Many of the other SCHED_FEAT flags got a nice explanation.

> +
> Index: tip/kernel/sched/sched.h
> ===================================================================
> --- tip.orig/kernel/sched/sched.h
> +++ tip/kernel/sched/sched.h
> @@ -418,6 +418,13 @@ struct rq {
>  
>  	struct list_head cfs_tasks;
>  
> +#ifdef CONFIG_SCHED_NUMA
> +	unsigned long    onnode_running;
> +	unsigned long    offnode_running;
> +	unsigned long	 offnode_weight;
> +	struct list_head offnode_tasks;
> +#endif
> +
>  	u64 rt_avg;
>  	u64 age_stamp;
>  	u64 idle_stamp;
> @@ -469,6 +476,15 @@ struct rq {
>  #endif
>  };
>  
> +static inline struct list_head *offnode_tasks(struct rq *rq)
> +{
> +#ifdef CONFIG_SCHED_NUMA
> +	return &rq->offnode_tasks;
> +#else
> +	return NULL;
> +#endif
> +}
> +
>  static inline int cpu_of(struct rq *rq)
>  {
>  #ifdef CONFIG_SMP
> @@ -529,6 +545,7 @@ static inline struct sched_domain *highe
>  
>  DECLARE_PER_CPU(struct sched_domain *, sd_llc);
>  DECLARE_PER_CPU(int, sd_llc_id);
> +DECLARE_PER_CPU(struct sched_domain *, sd_node);
>  
>  extern int group_balance_cpu(struct sched_group *sg);
>  
> 
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
