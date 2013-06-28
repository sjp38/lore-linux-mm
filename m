Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 5E4856B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:08:39 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 02:08:38 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BF2C6C90026
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:08:33 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5S68Yjg323998
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:08:34 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5S68WqM028330
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 03:08:34 -0300
Date: Fri, 28 Jun 2013 11:38:29 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/8] sched: Track NUMA hinting faults on per-node basis
Message-ID: <20130628060829.GA17195@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1372257487-9749-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-06-26 15:38:01]:

> This patch tracks what nodes numa hinting faults were incurred on.  Greater
> weight is given if the pages were to be migrated on the understanding
> that such faults cost significantly more. If a task has paid the cost to
> migrating data to that node then in the future it would be preferred if the
> task did not migrate the data again unnecessarily. This information is later
> used to schedule a task on the node incurring the most NUMA hinting faults.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/sched.h |  2 ++
>  kernel/sched/core.c   |  3 +++
>  kernel/sched/fair.c   | 12 +++++++++++-
>  kernel/sched/sched.h  | 12 ++++++++++++
>  4 files changed, 28 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index e692a02..72861b4 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1505,6 +1505,8 @@ struct task_struct {
>  	unsigned int numa_scan_period;
>  	u64 node_stamp;			/* migration stamp  */
>  	struct callback_head numa_work;
> +
> +	unsigned long *numa_faults;
>  #endif /* CONFIG_NUMA_BALANCING */
>  
>  	struct rcu_head rcu;
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 67d0465..f332ec0 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1594,6 +1594,7 @@ static void __sched_fork(struct task_struct *p)
>  	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
>  	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
>  	p->numa_work.next = &p->numa_work;
> +	p->numa_faults = NULL;
>  #endif /* CONFIG_NUMA_BALANCING */
>  }
>  
> @@ -1853,6 +1854,8 @@ static void finish_task_switch(struct rq *rq, struct task_struct *prev)
>  	if (mm)
>  		mmdrop(mm);
>  	if (unlikely(prev_state == TASK_DEAD)) {
> +		task_numa_free(prev);
> +
>  		/*
>  		 * Remove function-return probe instances associated with this
>  		 * task and put them back on the free list.
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 7a33e59..904fd6f 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -815,7 +815,14 @@ void task_numa_fault(int node, int pages, bool migrated)
>  	if (!sched_feat_numa(NUMA))
>  		return;
>  
> -	/* FIXME: Allocate task-specific structure for placement policy here */
> +	/* Allocate buffer to track faults on a per-node basis */
> +	if (unlikely(!p->numa_faults)) {
> +		int size = sizeof(*p->numa_faults) * nr_node_ids;
> +
> +		p->numa_faults = kzalloc(size, GFP_KERNEL);
> +		if (!p->numa_faults)
> +			return;
> +	}
>  
>  	/*
>  	 * If pages are properly placed (did not migrate) then scan slower.
> @@ -826,6 +833,9 @@ void task_numa_fault(int node, int pages, bool migrated)
>  			p->numa_scan_period + jiffies_to_msecs(10));
>  
>  	task_numa_placement(p);
> +
> +	/* Record the fault, double the weight if pages were migrated */
> +	p->numa_faults[node] += pages << migrated;


Why are we doing this after the placement.
I mean we should probably be doing this in the task_numa_placement,


Since doubling the pages can have an effect on the preferred node. If we
do it here, wont it end up in a case where the numa_faults on one node
is actually higher but it may end up being not the preferred node?

>  }
>  
>  static void reset_ptenuma_scan(struct task_struct *p)
> diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
> index cc03cfd..9c26d88 100644
> --- a/kernel/sched/sched.h
> +++ b/kernel/sched/sched.h
> @@ -503,6 +503,18 @@ DECLARE_PER_CPU(struct rq, runqueues);
>  #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
>  #define raw_rq()		(&__raw_get_cpu_var(runqueues))
>  
> +#ifdef CONFIG_NUMA_BALANCING
> +extern void sched_setnuma(struct task_struct *p, int node, int shared);
> +static inline void task_numa_free(struct task_struct *p)
> +{
> +	kfree(p->numa_faults);
> +}
> +#else /* CONFIG_NUMA_BALANCING */
> +static inline void task_numa_free(struct task_struct *p)
> +{
> +}
> +#endif /* CONFIG_NUMA_BALANCING */
> +
>  #ifdef CONFIG_SMP
>  
>  #define rcu_dereference_check_sched_domain(p) \
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
