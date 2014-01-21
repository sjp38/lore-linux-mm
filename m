Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id D54DA6B0037
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 07:21:35 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e49so4015148eek.15
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 04:21:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si9110978eef.152.2014.01.21.04.21.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 04:21:34 -0800 (PST)
Date: Tue, 21 Jan 2014 12:21:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] numa,sched: track from which nodes NUMA faults are
 triggered
Message-ID: <20140121122130.GG4963@suse.de>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
 <1390245667-24193-3-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390245667-24193-3-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Mon, Jan 20, 2014 at 02:21:03PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> Track which nodes NUMA faults are triggered from, in other words
> the CPUs on which the NUMA faults happened. This uses a similar
> mechanism to what is used to track the memory involved in numa faults.
> 
> The next patches use this to build up a bitmap of which nodes a
> workload is actively running on.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  include/linux/sched.h | 10 ++++++++--
>  kernel/sched/fair.c   | 30 +++++++++++++++++++++++-------
>  2 files changed, 31 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 97efba4..a9f7f05 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1492,6 +1492,14 @@ struct task_struct {
>  	unsigned long *numa_faults_buffer;
>  
>  	/*
> +	 * Track the nodes where faults are incurred. This is not very
> +	 * interesting on a per-task basis, but it help with smarter
> +	 * numa memory placement for groups of processes.
> +	 */
> +	unsigned long *numa_faults_from;
> +	unsigned long *numa_faults_from_buffer;
> +

As an aside I wonder if we can derive any useful metric from this. One
potential santiy check would be the number of nodes that a task is incurring
faults on. It would be best if the highest number of faults were recorded
on the node the task is currently running on. After that we either want
to minimise the number of nodes trapping faults or interleave between
all available nodes to avoid applying too much memory pressure on any
one node. For interleaving to always be the best option we would have to
assume that all nodes are equal distance but that would be a reasonable
assumption to start with.

> +	/*
>  	 * numa_faults_locality tracks if faults recorded during the last
>  	 * scan window were remote/local. The task scan period is adapted
>  	 * based on the locality of the faults with different weights
> @@ -1594,8 +1602,6 @@ extern void task_numa_fault(int last_node, int node, int pages, int flags);
>  extern pid_t task_numa_group_id(struct task_struct *p);
>  extern void set_numabalancing_state(bool enabled);
>  extern void task_numa_free(struct task_struct *p);
> -
> -extern unsigned int sysctl_numa_balancing_migrate_deferred;
>  #else
>  static inline void task_numa_fault(int last_node, int node, int pages,
>  				   int flags)
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 41e2176..1945ddc 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -886,6 +886,7 @@ struct numa_group {
>  
>  	struct rcu_head rcu;
>  	unsigned long total_faults;
> +	unsigned long *faults_from;
>  	unsigned long faults[0];
>  };
>  

faults_from is not ambiguous but it does not tell us a lot of information
either. If I am reading this right then fundamentally this patch means we
are tracking two pieces of information

1. The node the data resided on at the time of the hinting fault (numa_faults)
2. The node the accessing task was residing on at the time of the fault (faults_from)

We should be able to have names that reflect that. How about
memory_faults_locality and cpu_faults_locality with a prepartion patch
doing a simple rename for numa_faults and this patch adding
cpu_faults_locality?

It will be tough to be consistent about this but the clearer we are about
making decisions based on task locationo vs data location the happier we
will be in the long run.

> @@ -1372,10 +1373,11 @@ static void task_numa_placement(struct task_struct *p)
>  		int priv, i;
>  
>  		for (priv = 0; priv < 2; priv++) {
> -			long diff;
> +			long diff, f_diff;
>  
>  			i = task_faults_idx(nid, priv);
>  			diff = -p->numa_faults[i];
> +			f_diff = -p->numa_faults_from[i];
>  
>  			/* Decay existing window, copy faults since last scan */
>  			p->numa_faults[i] >>= 1;
> @@ -1383,12 +1385,18 @@ static void task_numa_placement(struct task_struct *p)
>  			fault_types[priv] += p->numa_faults_buffer[i];
>  			p->numa_faults_buffer[i] = 0;
>  
> +			p->numa_faults_from[i] >>= 1;
> +			p->numa_faults_from[i] += p->numa_faults_from_buffer[i];
> +			p->numa_faults_from_buffer[i] = 0;
> +
>  			faults += p->numa_faults[i];
>  			diff += p->numa_faults[i];
> +			f_diff += p->numa_faults_from[i];
>  			p->total_numa_faults += diff;
>  			if (p->numa_group) {
>  				/* safe because we can only change our own group */
>  				p->numa_group->faults[i] += diff;
> +				p->numa_group->faults_from[i] += f_diff;
>  				p->numa_group->total_faults += diff;
>  				group_faults += p->numa_group->faults[i];
>  			}
> @@ -1457,7 +1465,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>  
>  	if (unlikely(!p->numa_group)) {
>  		unsigned int size = sizeof(struct numa_group) +
> -				    2*nr_node_ids*sizeof(unsigned long);
> +				    4*nr_node_ids*sizeof(unsigned long);
>  

Should we convert that magic number to a define? NR_NUMA_HINT_FAULT_STATS?

>  		grp = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
>  		if (!grp)
> @@ -1467,8 +1475,10 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>  		spin_lock_init(&grp->lock);
>  		INIT_LIST_HEAD(&grp->task_list);
>  		grp->gid = p->pid;
> +		/* Second half of the array tracks where faults come from */
> +		grp->faults_from = grp->faults + 2 * nr_node_ids;
>  

We have accessors when we overload arrays like this such as task_faults_idx
for example. We should have similar accessors for this in case those
offsets very change.

> -		for (i = 0; i < 2*nr_node_ids; i++)
> +		for (i = 0; i < 4*nr_node_ids; i++)
>  			grp->faults[i] = p->numa_faults[i];
>  

This is a little obscure now. Functionally it is copying both numa_faults and
numa_faults_from but a casual reading of that will get confused. Minimally
it needs a comment explaining what is being copied here. Also, why did we
not use memcpy?

>  		grp->total_faults = p->total_numa_faults;
> @@ -1526,7 +1536,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>  
>  	double_lock(&my_grp->lock, &grp->lock);
>  
> -	for (i = 0; i < 2*nr_node_ids; i++) {
> +	for (i = 0; i < 4*nr_node_ids; i++) {
>  		my_grp->faults[i] -= p->numa_faults[i];
>  		grp->faults[i] += p->numa_faults[i];
>  	}

The same obscure trick is used throughout and I'm not sure how
maintainable that will be. Would it be better to be explicit about this?

/* NUMA hinting faults may be either shared or private faults */
#define NR_NUMA_HINT_FAULT_TYPES 2

/* Track shared and private faults
#define NR_NUMA_HINT_FAULT_STATS (NR_NUMA_HINT_FAULT_TYPES*2)

> @@ -1558,7 +1568,7 @@ void task_numa_free(struct task_struct *p)
>  
>  	if (grp) {
>  		spin_lock(&grp->lock);
> -		for (i = 0; i < 2*nr_node_ids; i++)
> +		for (i = 0; i < 4*nr_node_ids; i++)
>  			grp->faults[i] -= p->numa_faults[i];
>  		grp->total_faults -= p->total_numa_faults;
>  
> @@ -1571,6 +1581,8 @@ void task_numa_free(struct task_struct *p)
>  
>  	p->numa_faults = NULL;
>  	p->numa_faults_buffer = NULL;
> +	p->numa_faults_from = NULL;
> +	p->numa_faults_from_buffer = NULL;
>  	kfree(numa_faults);
>  }
>  
> @@ -1581,6 +1593,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
>  {
>  	struct task_struct *p = current;
>  	bool migrated = flags & TNF_MIGRATED;
> +	int this_node = task_node(current);
>  	int priv;
>  
>  	if (!numabalancing_enabled)
> @@ -1596,7 +1609,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
>  
>  	/* Allocate buffer to track faults on a per-node basis */
>  	if (unlikely(!p->numa_faults)) {
> -		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
> +		int size = sizeof(*p->numa_faults) * 4 * nr_node_ids;
>  
>  		/* numa_faults and numa_faults_buffer share the allocation */
>  		p->numa_faults = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
> @@ -1604,7 +1617,9 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
>  			return;
>  
>  		BUG_ON(p->numa_faults_buffer);
> -		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
> +		p->numa_faults_from = p->numa_faults + (2 * nr_node_ids);
> +		p->numa_faults_buffer = p->numa_faults + (4 * nr_node_ids);
> +		p->numa_faults_from_buffer = p->numa_faults + (6 * nr_node_ids);
>  		p->total_numa_faults = 0;
>  		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
>  	}
> @@ -1634,6 +1649,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
>  		p->numa_pages_migrated += pages;
>  
>  	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
> +	p->numa_faults_from_buffer[task_faults_idx(this_node, priv)] += pages;
>  	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;

this_node and node is similarly ambiguous in terms of name. Rename of
data_node and cpu_node would have been clearer.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
