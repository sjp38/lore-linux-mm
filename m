Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id D4D476B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 10:08:38 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e49so4171623eek.29
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 07:08:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9si10085921eev.189.2014.01.21.07.08.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 07:08:37 -0800 (PST)
Date: Tue, 21 Jan 2014 15:08:33 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/6] numa,sched,mm: use active_nodes nodemask to limit
 numa migrations
Message-ID: <20140121150833.GI4963@suse.de>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
 <1390245667-24193-5-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390245667-24193-5-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Mon, Jan 20, 2014 at 02:21:05PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> Use the active_nodes nodemask to make smarter decisions on NUMA migrations.
> 
> In order to maximize performance of workloads that do not fit in one NUMA
> node, we want to satisfy the following criteria:
> 1) keep private memory local to each thread
> 2) avoid excessive NUMA migration of pages
> 3) distribute shared memory across the active nodes, to
>    maximize memory bandwidth available to the workload
> 
> This patch accomplishes that by implementing the following policy for
> NUMA migrations:
> 1) always migrate on a private fault

Makes sense

> 2) never migrate to a node that is not in the set of active nodes
>    for the numa_group

This will work out in every case *except* where we miss an active node
because the task running there is faulting a very small number of pages.
Worth recording that in case we ever see a bug that could be explained
by it.

> 3) always migrate from a node outside of the set of active nodes,
>    to a node that is in that set

Clever

A *potential* consequence of this is that we may see large amounts of
migration traffic if we ever implement something that causes tasks to
enter/leave numa groups frequently.

> 4) within the set of active nodes in the numa_group, only migrate
>    from a node with more NUMA page faults, to a node with fewer
>    NUMA page faults, with a 25% margin to avoid ping-ponging
> 

Of the four, this is the highest risk again because we might miss tasks
in an active node due to them accessing a small number of pages.

Not suggesting you change the policy at this point, we should just keep
an eye out for it. It could be argued that a task accessing a small amount
of memory on a large NUMA machine is not a task we care about anyway :/

> This results in most pages of a workload ending up on the actively
> used nodes, with reduced ping-ponging of pages between those nodes.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  include/linux/sched.h |  7 +++++++
>  kernel/sched/fair.c   | 37 +++++++++++++++++++++++++++++++++++++
>  mm/mempolicy.c        |  3 +++
>  3 files changed, 47 insertions(+)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index a9f7f05..0af6c1a 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1602,6 +1602,8 @@ extern void task_numa_fault(int last_node, int node, int pages, int flags);
>  extern pid_t task_numa_group_id(struct task_struct *p);
>  extern void set_numabalancing_state(bool enabled);
>  extern void task_numa_free(struct task_struct *p);
> +extern bool should_numa_migrate(struct task_struct *p, int last_cpupid,
> +				int src_nid, int dst_nid);
>  #else
>  static inline void task_numa_fault(int last_node, int node, int pages,
>  				   int flags)
> @@ -1617,6 +1619,11 @@ static inline void set_numabalancing_state(bool enabled)
>  static inline void task_numa_free(struct task_struct *p)
>  {
>  }
> +static inline bool should_numa_migrate(struct task_struct *p, int last_cpupid,
> +				       int src_nid, int dst_nid)
> +{
> +	return true;
> +}
>  #endif
>  
>  static inline struct pid *task_pid(struct task_struct *task)
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index ea8b2ae..ea873b6 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -948,6 +948,43 @@ static inline unsigned long group_weight(struct task_struct *p, int nid)
>  	return 1000 * group_faults(p, nid) / p->numa_group->total_faults;
>  }
>  
> +bool should_numa_migrate(struct task_struct *p, int last_cpupid,
> +			 int src_nid, int dst_nid)
> +{

In light of the memory/data distinction, how about

should_numa_migrate_memory?

> +	struct numa_group *ng = p->numa_group;
> +
> +	/* Always allow migrate on private faults */
> +	if (cpupid_match_pid(p, last_cpupid))
> +		return true;
> +

We now have the two-stage filter detection in mpol_misplaced and the rest
of the migration decision logic here. Keep them in the same place? It
might necessitate passing in the page being faulted as well but then the
return value will be clearer

/*
 * This function returns true if the @page is misplaced and should be
 * migrated.
 */

It may need a name change as well if you decide to move everything into
this function including the call to page_cpupid_xchg_last

> +	/* A shared fault, but p->numa_group has not been set up yet. */
> +	if (!ng)
> +		return true;
> +
> +	/*
> +	 * Do not migrate if the destination is not a node that
> +	 * is actively used by this numa group.
> +	 */
> +	if (!node_isset(dst_nid, ng->active_nodes))
> +		return false;
> +

If I'm right about the sampling error potentially missing tasks accessing a
small number of pages then a reminder about the sampling error would not hurt

> +	/*
> +	 * Source is a node that is not actively used by this
> +	 * numa group, while the destination is. Migrate.
> +	 */
> +	if (!node_isset(src_nid, ng->active_nodes))
> +		return true;
> +
> +	/*
> +	 * Both source and destination are nodes in active
> +	 * use by this numa group. Maximize memory bandwidth
> +	 * by migrating from more heavily used groups, to less
> +	 * heavily used ones, spreading the load around.
> +	 * Use a 1/4 hysteresis to avoid spurious page movement.
> +	 */
> +	return group_faults(p, dst_nid) < (group_faults(p, src_nid) * 3 / 4);
> +}

I worried initially about how this would interact with the scheduler
placement which is concerned with the number of faults per node. I think
it's ok though because it should flatten out and the interleaved nodes
should not look like good scheduling candidates. Something to keep in
mind in the future.

I do not see why this is a 1/4 hysteresis though. It looks more like a
threshold based on the number of faults than anything to do with
hysteresis.

Finally, something like this is approximately the same as three-quarters
but does not use divides as a micro-optimisation. The approximation will
always be a greater value but the difference in error is marginal

src_group_faults = group_faults(p, src_nid);
src_group_faults -= src_group_faults >> 2;


> +
>  static unsigned long weighted_cpuload(const int cpu);
>  static unsigned long source_load(int cpu, int type);
>  static unsigned long target_load(int cpu, int type);
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 052abac..050962b 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2405,6 +2405,9 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
>  		if (!cpupid_pid_unset(last_cpupid) && cpupid_to_nid(last_cpupid) != thisnid) {
>  			goto out;
>  		}
> +
> +		if (!should_numa_migrate(current, last_cpupid, curnid, polnid))
> +			goto out;
>  	}
>  
>  	if (curnid != polnid)
> -- 
> 1.8.4.2
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
