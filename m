Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D58976B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 22:22:26 -0500 (EST)
Date: Thu, 4 Mar 2010 14:22:09 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/4] cpuset: fix the problem that
 cpuset_mem_spread_node() returns an offline node(was: Re: [regression]
 cpuset,mm: update tasks' mems_allowed in time (58568d2))
Message-ID: <20100304032209.GM8653@laptop>
References: <4B8E3DAB.1090307@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B8E3DAB.1090307@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, David Rientjes <rientjes@google.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 03, 2010 at 06:44:59PM +0800, Miao Xie wrote:
> cpuset_mem_spread_node() returns an offline node, and causes an oops.
> 
> This patch fixes it by initializing task->mems_allowed to
> node_states[N_HIGH_MEMORY], and updating task->mems_allowed when doing
> memory hotplug.

Thanks for these.

> 
> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
> ---
>  init/main.c      |    2 +-
>  kernel/cpuset.c  |   30 ++++++++++++++++++++++--------
>  kernel/kthread.c |    2 +-
>  3 files changed, 24 insertions(+), 10 deletions(-)
> 
> diff --git a/init/main.c b/init/main.c
> index c75dcd6..acb4edf 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -848,7 +848,7 @@ static int __init kernel_init(void * unused)
>  	/*
>  	 * init can allocate pages on any node
>  	 */
> -	set_mems_allowed(node_possible_map);
> +	set_mems_allowed(node_states[N_HIGH_MEMORY]);
>  	/*
>  	 * init can run on any cpu.
>  	 */
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index ba401fa..f732ff7 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -920,9 +920,6 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
>   *    call to guarantee_online_mems(), as we know no one is changing
>   *    our task's cpuset.
>   *
> - *    Hold callback_mutex around the two modifications of our tasks
> - *    mems_allowed to synchronize with cpuset_mems_allowed().
> - *
>   *    While the mm_struct we are migrating is typically from some
>   *    other task, the task_struct mems_allowed that we are hacking
>   *    is for our current task, which must allocate new pages for that
> @@ -936,9 +933,23 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
>  
>  	tsk->mems_allowed = *to;
>  
> +	/* 
> +	 * After current->mems_allowed is set to a new value, current will
> +	 * allocate new pages for the migrating memory region. So we must
> +	 * ensure that update of current->mems_allowed have been completed
> +	 * by this moment.
> +	 */
> +	smp_wmb();
>  	do_migrate_pages(mm, from, to, MPOL_MF_MOVE_ALL);
>  
>  	guarantee_online_mems(task_cs(tsk),&tsk->mems_allowed);
> +
> +	/* 
> +	 * After doing migrate pages, current will allocate new pages for
> +	 * itself not the other tasks. So we must ensure that update of
> +	 * current->mems_allowed have been completed by this moment.
> +	 */
> +	smp_wmb();

The comments don't really make sense. A task always sees its own
memory operations in program order. You keep saying *current* allocates
pages so *current*->mems_allowed must be updated. This doesn't make
sense. Do you mean to say tsk->?

Secondly, memory ordering operations do not ensure anything is
completed. They only ensure ordering. So to make sense to use them,
you generally need corresponding barriers in other code that can
run concurrently.

So you need to comment what is being ordered (ie. at least 2 memory
operations). And what other code might be running that requires this
ordering.

You need to comment to all these sites and operations. Sprinkling of
memory barriers just gets unmaintainable.

>  }
>  
>  /*
> @@ -1391,11 +1402,10 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
>  
>  	if (cs == &top_cpuset) {
>  		cpumask_copy(cpus_attach, cpu_possible_mask);
> -		to = node_possible_map;
>  	} else {
>  		guarantee_online_cpus(cs, cpus_attach);
> -		guarantee_online_mems(cs, &to);
>  	}
> +	guarantee_online_mems(cs, &to);
>  
>  	/* do per-task migration stuff possibly for each in the threadgroup */
>  	cpuset_attach_task(tsk, &to, cs);
> @@ -2090,15 +2100,19 @@ static int cpuset_track_online_cpus(struct notifier_block *unused_nb,
>  static int cpuset_track_online_nodes(struct notifier_block *self,
>  				unsigned long action, void *arg)
>  {
> +	nodemask_t oldmems;
> +
>  	cgroup_lock();
>  	switch (action) {
>  	case MEM_ONLINE:
> -	case MEM_OFFLINE:
> +		oldmems = top_cpuset.mems_allowed;
>  		mutex_lock(&callback_mutex);
>  		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
>  		mutex_unlock(&callback_mutex);
> -		if (action == MEM_OFFLINE)
> -			scan_for_empty_cpusets(&top_cpuset);
> +		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
> +		break;
> +	case MEM_OFFLINE:
> +		scan_for_empty_cpusets(&top_cpuset);
>  		break;
>  	default:
>  		break;
> diff --git a/kernel/kthread.c b/kernel/kthread.c
> index 82ed0ea..83911c7 100644
> --- a/kernel/kthread.c
> +++ b/kernel/kthread.c
> @@ -219,7 +219,7 @@ int kthreadd(void *unused)
>  	set_task_comm(tsk, "kthreadd");
>  	ignore_signals(tsk);
>  	set_cpus_allowed_ptr(tsk, cpu_all_mask);
> -	set_mems_allowed(node_possible_map);
> +	set_mems_allowed(node_states[N_HIGH_MEMORY]);
>  
>  	current->flags |= PF_NOFREEZE | PF_FREEZER_NOSIG;
>  
> -- 
> 1.6.5.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
