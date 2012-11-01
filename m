Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 7F86C6B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 09:48:45 -0400 (EDT)
Date: Thu, 1 Nov 2012 13:48:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 19/31] sched, numa, mm: Introduce tsk_home_node()
Message-ID: <20121101134840.GW3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124833.940887583@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124833.940887583@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:36PM +0200, Peter Zijlstra wrote:
> Introduce the home-node concept for tasks. In order to keep memory
> locality we need to have a something to stay local to, we define the
> home-node of a task as the node we prefer to allocate memory from and
> prefer to execute on.
> 

That implies that at some point or the other we must be hooking into
alloc_pages_current() and modifying where it calls numa_node_id() to
take the home node into account. Otherwise a process that faults while
running temporarily off the home node will allocate a page in the wrong
node forcing a migration later.

If we don't do that, why not and how do we cope with a task being
temporarily scheduled on a CPU that is not on the home node?

> These are no hard guarantees, merely soft preferences. This allows for
> optimal resource usage, we can run a task away from the home-node, the
> remote memory hit -- while expensive -- is less expensive than not
> running at all, or very little, due to severe cpu overload.
> 
> Similarly, we can allocate memory from another node if our home-node
> is depleted, again, some memory is better than no memory.
> 

Yes.

> This patch merely introduces the basic infrastructure, all policy
> comes later.
> 
> NOTE: we introduce the concept of EMBEDDED_NUMA, these are
> architectures where the memory access cost doesn't depend on the cpu
> but purely on the physical address -- embedded boards with cheap
> (slow) and expensive (fast) memory banks.
> 

This is a bit left-of-center. Is it necessary to deal with this now?

The name EMBEDDED here sucks a bit too as it has nothing to do with
whether the machine is embedded or not. Based on the description
NUMA_LATENCY_VARIABLE or something might have been a better name with a
desription saying that. Not sure as it's not obvious yet how it gets
used.

> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  arch/sh/mm/Kconfig        |    1 +
>  include/linux/init_task.h |    8 ++++++++
>  include/linux/sched.h     |   12 ++++++++++++
>  init/Kconfig              |   14 ++++++++++++++
>  kernel/sched/core.c       |   36 ++++++++++++++++++++++++++++++++++++
>  5 files changed, 71 insertions(+)
> 
> Index: tip/arch/sh/mm/Kconfig
> ===================================================================
> --- tip.orig/arch/sh/mm/Kconfig
> +++ tip/arch/sh/mm/Kconfig
> @@ -111,6 +111,7 @@ config VSYSCALL
>  config NUMA
>  	bool "Non Uniform Memory Access (NUMA) Support"
>  	depends on MMU && SYS_SUPPORTS_NUMA && EXPERIMENTAL
> +	select EMBEDDED_NUMA
>  	default n
>  	help
>  	  Some SH systems have many various memories scattered around
> Index: tip/include/linux/init_task.h
> ===================================================================
> --- tip.orig/include/linux/init_task.h
> +++ tip/include/linux/init_task.h
> @@ -143,6 +143,13 @@ extern struct task_group root_task_group
>  
>  #define INIT_TASK_COMM "swapper"
>  
> +#ifdef CONFIG_SCHED_NUMA
> +# define INIT_TASK_NUMA(tsk)						\
> +	.node = -1,
> +#else
> +# define INIT_TASK_NUMA(tsk)
> +#endif
> +
>  /*
>   *  INIT_TASK is used to set up the first task table, touch at
>   * your own risk!. Base=0, limit=0x1fffff (=2MB)
> @@ -210,6 +217,7 @@ extern struct task_group root_task_group
>  	INIT_TRACE_RECURSION						\
>  	INIT_TASK_RCU_PREEMPT(tsk)					\
>  	INIT_CPUSET_SEQ							\
> +	INIT_TASK_NUMA(tsk)						\
>  }
>  
>  
> Index: tip/include/linux/sched.h
> ===================================================================
> --- tip.orig/include/linux/sched.h
> +++ tip/include/linux/sched.h
> @@ -1479,6 +1479,9 @@ struct task_struct {
>  	short il_next;
>  	short pref_node_fork;
>  #endif
> +#ifdef CONFIG_SCHED_NUMA
> +	int node;
> +#endif

int home_node and a comment. node might be ok in parts of the VM where it
is clear from context what it means but in task_struct, "node" gives very
little hint as to what it is for.

>  	struct rcu_head rcu;
>  
>  	/*
> @@ -1553,6 +1556,15 @@ struct task_struct {
>  /* Future-safe accessor for struct task_struct's cpus_allowed. */
>  #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
>  
> +static inline int tsk_home_node(struct task_struct *p)
> +{
> +#ifdef CONFIG_SCHED_NUMA
> +	return p->node;
> +#else
> +	return -1;
> +#endif
> +}
> +
>  /*
>   * Priority of a process goes from 0..MAX_PRIO-1, valid RT
>   * priority is 0..MAX_RT_PRIO-1, and SCHED_NORMAL/SCHED_BATCH
> Index: tip/init/Kconfig
> ===================================================================
> --- tip.orig/init/Kconfig
> +++ tip/init/Kconfig
> @@ -696,6 +696,20 @@ config LOG_BUF_SHIFT
>  config HAVE_UNSTABLE_SCHED_CLOCK
>  	bool
>  
> +#
> +# For architectures that (ab)use NUMA to represent different memory regions
> +# all cpu-local but of different latencies, such as SuperH.
> +#
> +config EMBEDDED_NUMA
> +	bool
> +
> +config SCHED_NUMA
> +	bool "Memory placement aware NUMA scheduler"
> +	default n
> +	depends on SMP && NUMA && MIGRATION && !EMBEDDED_NUMA
> +	help
> +	  This option adds support for automatic NUMA aware memory/task placement.
> +

I see why you introduce EMBEDDED_NUMA now.  This should have been a separate
patch though explaining why when NUMA is abused like this that automatic NUMA
placement is the wrong thing to do because presumably the lower latency
regions are being manually managed and should not be interfered with.
That, or such architectures need to add a pgdat field that excludes such
nodes from automatic migration.

>  menuconfig CGROUPS
>  	boolean "Control Group support"
>  	depends on EVENTFD
> Index: tip/kernel/sched/core.c
> ===================================================================
> --- tip.orig/kernel/sched/core.c
> +++ tip/kernel/sched/core.c
> @@ -5959,6 +5959,42 @@ static struct sched_domain_topology_leve
>  
>  static struct sched_domain_topology_level *sched_domain_topology = default_topology;
>  
> +#ifdef CONFIG_SCHED_NUMA
> +
> +/*
> + * Requeues a task ensuring its on the right load-balance list so
> + * that it might get migrated to its new home.
> + *
> + * Note that we cannot actively migrate ourselves since our callers
> + * can be from atomic context. We rely on the regular load-balance
> + * mechanisms to move us around -- its all preference anyway.
> + */
> +void sched_setnode(struct task_struct *p, int node)
> +{
> +	unsigned long flags;
> +	int on_rq, running;
> +	struct rq *rq;
> +
> +	rq = task_rq_lock(p, &flags);
> +	on_rq = p->on_rq;
> +	running = task_current(rq, p);
> +
> +	if (on_rq)
> +		dequeue_task(rq, p, 0);
> +	if (running)
> +		p->sched_class->put_prev_task(rq, p);
> +
> +	p->node = node;
> +
> +	if (running)
> +		p->sched_class->set_curr_task(rq);
> +	if (on_rq)
> +		enqueue_task(rq, p, 0);
> +	task_rq_unlock(rq, p, &flags);
> +}
> +

Presumably this thing is called rare enough that rq lock contention will
not be a problem. If it is, it'll be quickly obvious.

> +#endif /* CONFIG_SCHED_NUMA */
> +
>  #ifdef CONFIG_NUMA
>  
>  static int sched_domains_numa_levels;
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
