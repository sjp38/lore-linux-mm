Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2B0366B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 17:57:58 -0500 (EST)
Message-ID: <50A2D069.4070206@redhat.com>
Date: Tue, 13 Nov 2012 17:57:45 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] sched, numa, mm: Add adaptive NUMA affinity support
References: <20121112160451.189715188@chello.nl> <20121112161215.782018877@chello.nl>
In-Reply-To: <20121112161215.782018877@chello.nl>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On 11/12/2012 11:04 AM, Peter Zijlstra wrote:
> The principal ideas behind this patch are the fundamental
> difference between shared and privately used memory and the very
> strong desire to only rely on per-task behavioral state for
> scheduling decisions.
>
> We define 'shared memory' as all user memory that is frequently
> accessed by multiple tasks and conversely 'private memory' is
> the user memory used predominantly by a single task.
>
> To approximate the above strict definition we recognise that
> task placement is dominantly per cpu and thus using cpu granular
> page access state is a natural fit. Thus we introduce
> page::last_cpu as the cpu that last accessed a page.
>
> Using this, we can construct two per-task node-vectors, 'S_i'
> and 'P_i' reflecting the amount of shared and privately used
> pages of this task respectively. Pages for which two consecutive
> 'hits' are of the same cpu are assumed private and the others
> are shared.

That is an intriguing idea. It will be interesting to see how
well it works with various workloads.

> [ Note that for shared tasks we only see '1/n' the total number
>    of shared pages for the other tasks will take the other
>    faults; where 'n' is the number of tasks sharing the memory.
>    So for an equal comparison we should divide total private by
>    'n' as well, but we don't have 'n' so we pick 2. ]

Unless I am misreading the code (it is a little hard to read in places,
more on that further down), the number picked appears to be 4.

> We can also compute which node holds most of our memory, running
> on this node will be called 'ideal placement' (As per previous
> patches we will prefer to pull memory towards wherever we run.)
>
> We change the load-balancer to prefer moving tasks in order of:
>
>    1) !numa tasks and numa tasks in the direction of more faults
>    2) allow !ideal tasks getting worse in the direction of faults
>    3) allow private tasks to get worse
>    4) allow shared tasks to get worse

This reflects some of the things autonuma does, so I
suspect it will work in your code too :)

It is interesting to see how sched/numa has moved from
the homenodes-through-syscalls concepts to something so
close to what autonuma does.

> Index: linux/Documentation/scheduler/numa-problem.txt
> ===================================================================
> --- linux.orig/Documentation/scheduler/numa-problem.txt
> +++ linux/Documentation/scheduler/numa-problem.txt
> @@ -133,6 +133,8 @@ XXX properties of this M vs a potential
>
>    2b) migrate memory towards 'n_i' using 2 samples.
>
> +XXX include the statistical babble on double sampling somewhere near
> +

This document is becoming less and less reflective of what
the code actually does :)


> Index: linux/include/linux/sched.h
> ===================================================================
> --- linux.orig/include/linux/sched.h
> +++ linux/include/linux/sched.h

> @@ -1501,6 +1502,18 @@ struct task_struct {
>   	short il_next;
>   	short pref_node_fork;
>   #endif
> +#ifdef CONFIG_SCHED_NUMA
> +	int numa_shared;
> +	int numa_max_node;
> +	int numa_scan_seq;
> +	int numa_migrate_seq;
> +	unsigned int numa_scan_period;
> +	u64 node_stamp;			/* migration stamp  */
> +	unsigned long numa_weight;
> +	unsigned long *numa_faults;
> +	struct callback_head numa_work;
> +#endif /* CONFIG_SCHED_NUMA */
> +

All these struct members could use comments explaining what
they are.  Having a struct as central to the operation of
the kernel as task_struct full of undocumented members is a
bad idea - lets not make it worse.

> +/*
> + * -1: non-NUMA task
> + *  0: NUMA task with a dominantly 'private' working set
> + *  1: NUMA task with a dominantly 'shared' working set
> + */
> +static inline int task_numa_shared(struct task_struct *p)
> +{
> +#ifdef CONFIG_SCHED_NUMA
> +	return p->numa_shared;
> +#else
> +	return -1;
> +#endif
> +}

Just what is a "non-NUMA task"?  That is not at all obvious, and
could use a better comment.

> Index: linux/include/uapi/linux/mempolicy.h
> ===================================================================
> --- linux.orig/include/uapi/linux/mempolicy.h
> +++ linux/include/uapi/linux/mempolicy.h
> @@ -69,6 +69,7 @@ enum mpol_rebind_step {
>   #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
>   #define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
>   #define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
> +#define MPOL_F_HOME	(1 << 4) /* this is the home-node policy */

What does that imply?

How is it different from migrate on fault?

> Index: linux/kernel/sched/core.c
> ===================================================================
> --- linux.orig/kernel/sched/core.c
> +++ linux/kernel/sched/core.c
> @@ -1544,6 +1544,21 @@ static void __sched_fork(struct task_str
>   #ifdef CONFIG_PREEMPT_NOTIFIERS
>   	INIT_HLIST_HEAD(&p->preempt_notifiers);
>   #endif
> +
> +#ifdef CONFIG_SCHED_NUMA
> +	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
> +		p->mm->numa_next_scan = jiffies;
> +		p->mm->numa_scan_seq = 0;
> +	}
> +
> +	p->numa_shared = -1;
> +	p->node_stamp = 0ULL;
> +	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
> +	p->numa_migrate_seq = 2;

Why is it set to 2?

What happens when the number overflows?  (can it?)

This kind of thing is just begging for a comment...

> @@ -5970,6 +5997,37 @@ static struct sched_domain_topology_leve
>
>   static struct sched_domain_topology_level *sched_domain_topology = default_topology;
>
> +#ifdef CONFIG_SCHED_NUMA
> +
> +/*
     * Set the preferred home node for a task. Hopefully the load
     * balancer will move it later.
> + */

Excellent, this function has a comment. Too bad it's empty.
You may want to fix that :)

> +void sched_setnuma(struct task_struct *p, int node, int shared)
> +{
> +	unsigned long flags;
> +	int on_rq, running;
> +	struct rq *rq;

> +/*
> + * numa task sample period in ms: 5s
> + */
> +unsigned int sysctl_sched_numa_scan_period_min = 5000;
> +unsigned int sysctl_sched_numa_scan_period_max = 5000*16;
> +
> +/*
> + * Wait for the 2-sample stuff to settle before migrating again
> + */
> +unsigned int sysctl_sched_numa_settle_count = 2;

These two could do with longer comments, explaining why these
defaults are set to these values.

> +static void task_numa_placement(struct task_struct *p)
> +{
> +	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
> +	unsigned long total[2] = { 0, 0 };
> +	unsigned long faults, max_faults = 0;
> +	int node, priv, shared, max_node = -1;
> +
> +	if (p->numa_scan_seq == seq)
> +		return;
> +
> +	p->numa_scan_seq = seq;
> +
> +	for (node = 0; node < nr_node_ids; node++) {
> +		faults = 0;
> +		for (priv = 0; priv < 2; priv++) {
> +			faults += p->numa_faults[2*node + priv];
> +			total[priv] += p->numa_faults[2*node + priv];
> +			p->numa_faults[2*node + priv] /= 2;
> +		}

What is "priv"?

If it is fault type (not sure, but it looks like it might be from
reading the rest of the code), would it be better to do this with
an enum?

That way we can see some of the symbolic names of what we are
iterating over, and figure out what is going on.

> +		if (faults > max_faults) {
> +			max_faults = faults;
> +			max_node = node;
> +		}
> +	}
> +
> +	if (max_node != p->numa_max_node)
> +		sched_setnuma(p, max_node, task_numa_shared(p));
> +
> +	p->numa_migrate_seq++;
> +	if (sched_feat(NUMA_SETTLE) &&
> +	    p->numa_migrate_seq < sysctl_sched_numa_settle_count)
> +		return;
> +
> +	/*
> +	 * Note: shared is spread across multiple tasks and in the future
> +	 * we might want to consider a different equation below to reduce
> +	 * the impact of a little private memory accesses.
> +	 */
> +	shared = (total[0] >= total[1] / 4);

That would also allow us to use the enum here, which would allow
me to figure out which of these indexes is used for shared faults,
and which for private ones.

Btw, is the 4 above the factor 2 from the changelog? :)

> +	if (shared != task_numa_shared(p)) {
> +		sched_setnuma(p, p->numa_max_node, shared);
> +		p->numa_migrate_seq = 0;
> +	}
> +}
> +
> +/*
> + * Got a PROT_NONE fault for a page on @node.
> + */
> +void task_numa_fault(int node, int last_cpu, int pages)

Neither the comment nor the function name hint at the primary function
of this function: updating the numa fault statistics.

> +{
> +	struct task_struct *p = current;
> +	int priv = (task_cpu(p) == last_cpu);

One quick question: why are you using last_cpu and not simply the last
node, since the load balancer is free to move tasks around inside each
NUMA node?

I have some ideas on why you are doing it, but it would be good to
explicitly document it.

> +	if (unlikely(!p->numa_faults)) {
> +		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
> +
> +		p->numa_faults = kzalloc(size, GFP_KERNEL);
> +		if (!p->numa_faults)
> +			return;
> +	}
> +
> +	task_numa_placement(p);
> +	p->numa_faults[2*node + priv] += pages;
> +}

Ahhh, so private faults are the second number, and shared faults
the first one. Would have been nice if that had been documented
somewhere...

> +/*
> + * Can we migrate a NUMA task? The rules are rather involved:
> + */

Yes, they are.  I have read this part of the patch several times,
and am still not sure what exactly the code is doing, or why.

> +static bool can_migrate_numa_task(struct task_struct *p, struct lb_env *env)
> +{
>   	/*
> -	 * Aggressive migration if:
> -	 * 1) task is cache cold, or
> -	 * 2) too many balance attempts have failed.
> +	 * iteration:
> +	 *   0		   -- only allow improvement, or !numa
> +	 *   1		   -- + worsen !ideal
> +	 *   2                         priv
> +	 *   3                         shared (everything)
> +	 *
> +	 * NUMA_HOT_DOWN:
> +	 *   1 .. nodes    -- allow getting worse by step
> +	 *   nodes+1	   -- punt, everything goes!
> +	 *
> +	 * LBF_NUMA_RUN    -- numa only, only allow improvement
> +	 * LBF_NUMA_SHARED -- shared only
> +	 *
> +	 * LBF_KEEP_SHARED -- do not touch shared tasks
>   	 */

These comments do not explain why things are done this way,
nor are they verbose enough to even explain what they are doing.

It is taking a lot of scrolling through the patch to find where
this function is invoked with different iteration values. Documenting
that here would be nice.

>
> -	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
> -	if (!tsk_cache_hot ||
> -		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
> -#ifdef CONFIG_SCHEDSTATS
> -		if (tsk_cache_hot) {
> -			schedstat_inc(env->sd, lb_hot_gained[env->idle]);
> -			schedstat_inc(p, se.statistics.nr_forced_migrations);
> -		}
> +	/* a numa run can only move numa tasks about to improve things */
> +	if (env->flags & LBF_NUMA_RUN) {
> +		if (task_numa_shared(p) < 0)
> +			return false;

What does <0 mean again?  A comment would be good.

> +		/* can only pull shared tasks */
> +		if ((env->flags & LBF_NUMA_SHARED) && !task_numa_shared(p))
> +			return false;

Why?

> +	} else {
> +		if (task_numa_shared(p) < 0)
> +			goto try_migrate;
> + 	}
> +
> +	/* can not move shared tasks */
> +	if ((env->flags & LBF_KEEP_SHARED) && task_numa_shared(p) == 1)
> +		return false;
> +
> +	if (task_faults_up(p, env))
> +		return true; /* memory locality beats cache hotness */

Does "task_faults_up" mean "move to a node with better memory locality"?

> +
> +	if (env->iteration < 1)
> +		return false;
> +
> +#ifdef CONFIG_SCHED_NUMA
> +	if (p->numa_max_node != cpu_to_node(task_cpu(p))) /* !ideal */
> +		goto demote;
>   #endif
> -		return 1;
> -	}
>
> -	if (tsk_cache_hot) {
> -		schedstat_inc(p, se.statistics.nr_failed_migrations_hot);
> -		return 0;
> -	}
> -	return 1;
> +	if (env->iteration < 2)
> +		return false;
> +
> +	if (task_numa_shared(p) == 0) /* private */
> +		goto demote;

It would be good to document why we are demoting in this case.

> +
> +	if (env->iteration < 3)
> +		return false;
> +
> +demote:
> +	if (env->iteration < 5)
> +		return task_faults_down(p, env);

And why we are demoting if env->iteration is 3 or 4...

> @@ -3976,7 +4376,7 @@ struct sd_lb_stats {
>   	unsigned long this_load;
>   	unsigned long this_load_per_task;
>   	unsigned long this_nr_running;
> -	unsigned long this_has_capacity;
> +	unsigned int  this_has_capacity;
>   	unsigned int  this_idle_cpus;
>
>   	/* Statistics of the busiest group */
> @@ -3985,10 +4385,28 @@ struct sd_lb_stats {
>   	unsigned long busiest_load_per_task;
>   	unsigned long busiest_nr_running;
>   	unsigned long busiest_group_capacity;
> -	unsigned long busiest_has_capacity;
> +	unsigned int  busiest_has_capacity;
>   	unsigned int  busiest_group_weight;
>
>   	int group_imb; /* Is there imbalance in this sd */
> +
> +#ifdef CONFIG_SCHED_NUMA
> +	unsigned long this_numa_running;
> +	unsigned long this_numa_weight;
> +	unsigned long this_shared_running;
> +	unsigned long this_ideal_running;
> +	unsigned long this_group_capacity;
> +
> +	struct sched_group *numa;
> +	unsigned long numa_load;
> +	unsigned long numa_nr_running;
> +	unsigned long numa_numa_running;
> +	unsigned long numa_shared_running;
> +	unsigned long numa_ideal_running;
> +	unsigned long numa_numa_weight;
> +	unsigned long numa_group_capacity;
> +	unsigned int  numa_has_capacity;
> +#endif

Same comment as for task_struct.  It would be most useful to have
the members of this structure documented.

> @@ -4723,6 +5329,9 @@ static struct rq *find_busiest_queue(str
>   		if (capacity && rq->nr_running == 1 && wl > env->imbalance)
>   			continue;
>
> +		if ((env->flags & LBF_KEEP_SHARED) && !(rq->nr_running - rq->nr_shared_running))
> +			continue;

If the runqueue struct entries were documented, we would know what
this condition was testing. Please add documentation.

> +/*
> + * See can_migrate_numa_task()
> + */

Wait a moment. When I read that function, I wondered why it was
called with certain parameters, and the function setting that
parameter is referring me to the function that is being called?

Having some comment explaining what the strategy is would be useful,
to say the least.

> +static int lb_max_iteration(struct lb_env *env)
> +{
> +	if (!(env->sd->flags & SD_NUMA))
> +		return 0;
> +
> +	if (env->flags & LBF_NUMA_RUN)
> +		return 0; /* NUMA_RUN may only improve */
> +
> +	if (sched_feat_numa(NUMA_FAULTS_DOWN))
> +		return 5; /* nodes^2  would suck */
> +
> +	return 3;
> +}

> @@ -4895,92 +5523,72 @@ more_balance:
>   		}
>
>   		/* All tasks on this runqueue were pinned by CPU affinity */
> -		if (unlikely(env.flags & LBF_ALL_PINNED)) {
> -			cpumask_clear_cpu(cpu_of(busiest), cpus);
> -			if (!cpumask_empty(cpus)) {
> -				env.loop = 0;
> -				env.loop_break = sched_nr_migrate_break;
> -				goto redo;
> -			}
> -			goto out_balanced;
> +		if (unlikely(env.flags & LBF_ALL_PINNED))
> +			goto out_pinned;
> +
> +		if (!ld_moved && env.iteration < lb_max_iteration(&env)) {
> +			env.iteration++;
> +			env.loop = 0;
> +			goto more_balance;
>   		}

Things are starting to make some sense. Overall, this code could use
better comments explaining why it does things the way it does.

> ===================================================================
> --- linux.orig/kernel/sched/features.h
> +++ linux/kernel/sched/features.h
> @@ -66,3 +66,12 @@ SCHED_FEAT(TTWU_QUEUE, true)
>   SCHED_FEAT(FORCE_SD_OVERLAP, false)
>   SCHED_FEAT(RT_RUNTIME_SHARE, true)
>   SCHED_FEAT(LB_MIN, false)
> +
> +#ifdef CONFIG_SCHED_NUMA
> +/* Do the working set probing faults: */
> +SCHED_FEAT(NUMA,             true)
> +SCHED_FEAT(NUMA_FAULTS_UP,   true)
> +SCHED_FEAT(NUMA_FAULTS_DOWN, false)
> +SCHED_FEAT(NUMA_SETTLE,      true)
> +#endif

Are these documented somewhere?



-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
