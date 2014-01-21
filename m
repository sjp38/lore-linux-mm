Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAD56B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 09:19:24 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so3774917ead.22
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 06:19:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y48si9832602eew.121.2014.01.21.06.19.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 06:19:23 -0800 (PST)
Date: Tue, 21 Jan 2014 14:19:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/6] numa,sched: build per numa_group active node mask
 from faults_from statistics
Message-ID: <20140121141919.GH4963@suse.de>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
 <1390245667-24193-4-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390245667-24193-4-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Mon, Jan 20, 2014 at 02:21:04PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> The faults_from statistics are used to maintain an active_nodes nodemask
> per numa_group. This allows us to be smarter about when to do numa migrations.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  kernel/sched/fair.c | 41 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 41 insertions(+)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 1945ddc..ea8b2ae 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -885,6 +885,7 @@ struct numa_group {
>  	struct list_head task_list;
>  
>  	struct rcu_head rcu;
> +	nodemask_t active_nodes;
>  	unsigned long total_faults;
>  	unsigned long *faults_from;
>  	unsigned long faults[0];

It's not a concern for now but in the land of unicorns and ponies we'll
relook at the size of some of these structures and see what can be
optimised.

Similar to my comment on faults_from I think we could potentially evaluate
the fitness of the automatic NUMA balancing feature by looking at the
weight of the active_nodes for a numa_group. If
bitmask_weight(active_nodes) == nr_online_nodes
for all numa_groups in the system then I think it would be an indication
that the algorithm has collapsed.

It's not a comment on the patch itself. We could could just do with more
metrics that help analyse this thing when debugging problems.

> @@ -1275,6 +1276,41 @@ static void numa_migrate_preferred(struct task_struct *p)
>  }
>  
>  /*
> + * Find the nodes on which the workload is actively running. We do this by

hmm, it's not the workload though, it's a single NUMA group and a workload
may consist of multiple NUMA groups. For example, in an ideal world and
a JVM-based workload the application threads and the GC threads would be
in different NUMA groups.

The signature is even more misleading because the signature implies that
the function is concerned with tasks. Pass in p->numa_group


> + * tracking the nodes from which NUMA hinting faults are triggered. This can
> + * be different from the set of nodes where the workload's memory is currently
> + * located.
> + *
> + * The bitmask is used to make smarter decisions on when to do NUMA page
> + * migrations, To prevent flip-flopping, and excessive page migrations, nodes
> + * are added when they cause over 6/16 of the maximum number of faults, but
> + * only removed when they drop below 3/16.
> + */

Looking at the values, I'm guessing you did it this way to use shifts
instead of divides. That's fine, but how did you arrive at those values?
Experimentally or just felt reasonable?

> +static void update_numa_active_node_mask(struct task_struct *p)
> +{
> +	unsigned long faults, max_faults = 0;
> +	struct numa_group *numa_group = p->numa_group;
> +	int nid;
> +
> +	for_each_online_node(nid) {
> +		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
> +			 numa_group->faults_from[task_faults_idx(nid, 1)];

task_faults() implements a helper for p->numa_faults equivalent of this.
Just as with the other renaming, it would not hurt to rename task_faults()
to something like task_faults_memory() and add a task_faults_cpu() for
this. The objective again is to be clear about whether we care about CPU
or memory locality information.

> +		if (faults > max_faults)
> +			max_faults = faults;
> +	}
> +
> +	for_each_online_node(nid) {
> +		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
> +			 numa_group->faults_from[task_faults_idx(nid, 1)];

group_faults would need similar adjustment.

> +		if (!node_isset(nid, numa_group->active_nodes)) {
> +			if (faults > max_faults * 6 / 16)
> +				node_set(nid, numa_group->active_nodes);
> +		} else if (faults < max_faults * 3 / 16)
> +			node_clear(nid, numa_group->active_nodes);
> +	}
> +}
> +

I think there is a subtle problem here

/*
 * Be mindful that this is subject to sampling error. As we only have
 * data on hinting faults active_nodes may miss a heavily referenced
 * node due to the references being to a small number of pages. If
 * there is a large linear scanner in the same numa group as a
 * task operating on a small amount of memory then the latter task
 * may be ignored.
 */

I have no suggestion on how to handle this because we're vulnerable to
sampling errors in a number of places but it does not hurt to be reminded
of that in a few places.

> +/*
>   * When adapting the scan rate, the period is divided into NUMA_PERIOD_SLOTS
>   * increments. The more local the fault statistics are, the higher the scan
>   * period will be for the next scan window. If local/remote ratio is below
> @@ -1416,6 +1452,7 @@ static void task_numa_placement(struct task_struct *p)
>  	update_task_scan_period(p, fault_types[0], fault_types[1]);
>  
>  	if (p->numa_group) {
> +		update_numa_active_node_mask(p);

We are updating that thing once per scan window, that's fine. There is
potentially a wee issue though. If all the tasks in the group are threads
then they share p->mm->numa_scan_seq and only one task does the update
per scan window. If they are different processes then we could be updating
more frequently than necessary.

Functionally it'll be fine but higher cost than necessary. I do not have a
better suggestion right now as superficially a numa_scan_seq per numa_group
would not be a good fit.

If we think of nothing better and the issue is real then we can at least
stick a comment there for future reference.

>  		/*
>  		 * If the preferred task and group nids are different,
>  		 * iterate over the nodes again to find the best place.
> @@ -1478,6 +1515,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>  		/* Second half of the array tracks where faults come from */
>  		grp->faults_from = grp->faults + 2 * nr_node_ids;
>  
> +		node_set(task_node(current), grp->active_nodes);
> +
>  		for (i = 0; i < 4*nr_node_ids; i++)
>  			grp->faults[i] = p->numa_faults[i];
>  
> @@ -1547,6 +1586,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>  	my_grp->nr_tasks--;
>  	grp->nr_tasks++;
>  
> +	update_numa_active_node_mask(p);
> +

This may be subtle enough to deserve a comment

/* Tasks have joined/left groups and the active_mask is no longer valid */

If we left a group, we update our new group. Is the old group now out of
date and in need of updating too? If so, then we should update both and
only update the old group if it still has tasks in it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
