Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 2C5BF6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 04:11:29 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 04:11:28 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 45F6238C8047
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 04:11:24 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5S8BPrN275604
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 04:11:25 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5S8BO85004097
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 05:11:24 -0300
Date: Fri, 28 Jun 2013 13:41:20 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130628081120.GE17195@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1372257487-9749-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-06-26 15:38:04]:

> This patch favours moving tasks towards the preferred NUMA node when
> it has just been selected. Ideally this is self-reinforcing as the
> longer the the task runs on that node, the more faults it should incur
> causing task_numa_placement to keep the task running on that node. In
> reality a big weakness is that the nodes CPUs can be overloaded and it
> would be more effficient to queue tasks on an idle node and migrate to
> the new node. This would require additional smarts in the balancer so
> for now the balancer will simply prefer to place the task on the
> preferred node for a tunable number of PTE scans.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  Documentation/sysctl/kernel.txt |  8 +++++++-
>  include/linux/sched.h           |  1 +
>  kernel/sched/core.c             |  4 +++-
>  kernel/sched/fair.c             | 40 ++++++++++++++++++++++++++++++++++++++--
>  kernel/sysctl.c                 |  7 +++++++
>  5 files changed, 56 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
> index 0fe678c..246b128 100644
> --- a/Documentation/sysctl/kernel.txt
> +++ b/Documentation/sysctl/kernel.txt
> @@ -374,7 +374,8 @@ feature should be disabled. Otherwise, if the system overhead from the
>  feature is too high then the rate the kernel samples for NUMA hinting
>  faults may be controlled by the numa_balancing_scan_period_min_ms,
>  numa_balancing_scan_delay_ms, numa_balancing_scan_period_reset,
> -numa_balancing_scan_period_max_ms and numa_balancing_scan_size_mb sysctls.
> +numa_balancing_scan_period_max_ms, numa_balancing_scan_size_mb and
> +numa_balancing_settle_count sysctls.
>  
>  ==============================================================
>  
> @@ -418,6 +419,11 @@ scanned for a given scan.
>  numa_balancing_scan_period_reset is a blunt instrument that controls how
>  often a tasks scan delay is reset to detect sudden changes in task behaviour.
>  
> +numa_balancing_settle_count is how many scan periods must complete before
> +the schedule balancer stops pushing the task towards a preferred node. This
> +gives the scheduler a chance to place the task on an alternative node if the
> +preferred node is overloaded.
> +
>  ==============================================================
>  
>  osrelease, ostype & version:
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 42f9818..82a6136 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -815,6 +815,7 @@ enum cpu_idle_type {
>  #define SD_ASYM_PACKING		0x0800  /* Place busy groups earlier in the domain */
>  #define SD_PREFER_SIBLING	0x1000	/* Prefer to place tasks in a sibling domain */
>  #define SD_OVERLAP		0x2000	/* sched_domains of this level overlap */
> +#define SD_NUMA			0x4000	/* cross-node balancing */
>  
>  extern int __weak arch_sd_sibiling_asym_packing(void);
>  
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index b00b81a..ba9470e 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1591,7 +1591,7 @@ static void __sched_fork(struct task_struct *p)
>  
>  	p->node_stamp = 0ULL;
>  	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
> -	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
> +	p->numa_migrate_seq = 0;
>  	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
>  	p->numa_preferred_nid = -1;
>  	p->numa_work.next = &p->numa_work;
> @@ -5721,6 +5721,7 @@ struct sched_domain_topology_level;
>  void sched_setnuma(struct task_struct *p, int nid)
>  {
>  	p->numa_preferred_nid = nid;
> +	p->numa_migrate_seq = 0;
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
>  
> @@ -6150,6 +6151,7 @@ sd_numa_init(struct sched_domain_topology_level *tl, int cpu)
>  					| 0*SD_SHARE_PKG_RESOURCES
>  					| 1*SD_SERIALIZE
>  					| 0*SD_PREFER_SIBLING
> +					| 1*SD_NUMA
>  					| sd_local_flags(level)
>  					,
>  		.last_balance		= jiffies,
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 5893399..5e7f728 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -791,6 +791,15 @@ unsigned int sysctl_numa_balancing_scan_size = 256;
>  /* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
>  unsigned int sysctl_numa_balancing_scan_delay = 1000;
>  
> +/*
> + * Once a preferred node is selected the scheduler balancer will prefer moving
> + * a task to that node for sysctl_numa_balancing_settle_count number of PTE
> + * scans. This will give the process the chance to accumulate more faults on
> + * the preferred node but still allow the scheduler to move the task again if
> + * the nodes CPUs are overloaded.
> + */
> +unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
> +
>  static void task_numa_placement(struct task_struct *p)
>  {
>  	int seq, nid, max_nid = 0;
> @@ -802,6 +811,7 @@ static void task_numa_placement(struct task_struct *p)
>  	if (p->numa_scan_seq == seq)
>  		return;
>  	p->numa_scan_seq = seq;
> +	p->numa_migrate_seq++;
>  
>  	/* Find the node with the highest number of faults */
>  	for (nid = 0; nid < nr_node_ids; nid++) {
> @@ -3897,6 +3907,28 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
>  	return delta < (s64)sysctl_sched_migration_cost;
>  }
>  
> +/* Returns true if the destination node has incurred more faults */
> +static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
> +{
> +	int src_nid, dst_nid;
> +
> +	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
> +		return false;
> +
> +	src_nid = cpu_to_node(env->src_cpu);
> +	dst_nid = cpu_to_node(env->dst_cpu);
> +
> +	if (src_nid == dst_nid)
> +		return false;
> +
> +	if (p->numa_migrate_seq < sysctl_numa_balancing_settle_count &&

Lets say even if the numa_migrate_seq is greater than settle_count but running
on a wrong node, then shouldnt this be taken as a good opportunity to 
move the task?

> +	    p->numa_preferred_nid == dst_nid)
> +		return true;
> +
> +	return false;
> +}
> +
> +
>  /*
>   * can_migrate_task - may task p from runqueue rq be migrated to this_cpu?
>   */
> @@ -3945,10 +3977,14 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
>  
>  	/*
>  	 * Aggressive migration if:
> -	 * 1) task is cache cold, or
> -	 * 2) too many balance attempts have failed.
> +	 * 1) destination numa is preferred
> +	 * 2) task is cache cold, or
> +	 * 3) too many balance attempts have failed.
>  	 */
>  
> +	if (migrate_improves_locality(p, env))
> +		return 1;

Shouldnt this be under tsk_cache_hot check?

If the task is cache hot, then we would have to update the corresponding  schedstat
metrics.


> +
>  	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
>  	if (!tsk_cache_hot ||
>  		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index afc1dc6..263486f 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -393,6 +393,13 @@ static struct ctl_table kern_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
>  	},
> +	{
> +		.procname       = "numa_balancing_settle_count",
> +		.data           = &sysctl_numa_balancing_settle_count,
> +		.maxlen         = sizeof(unsigned int),
> +		.mode           = 0644,
> +		.proc_handler   = proc_dointvec,
> +	},
>  #endif /* CONFIG_NUMA_BALANCING */
>  #endif /* CONFIG_SCHED_DEBUG */
>  	{
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
