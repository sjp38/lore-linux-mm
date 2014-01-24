Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 05D906B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:38:37 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x12so3085813wgg.1
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 07:38:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si776349wjw.100.2014.01.24.07.38.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 07:38:36 -0800 (PST)
Date: Fri, 24 Jan 2014 15:38:33 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/9] numa,sched: build per numa_group active node mask
 from numa_faults_cpu statistics
Message-ID: <20140124153833.GA4963@suse.de>
References: <1390342811-11769-1-git-send-email-riel@redhat.com>
 <1390342811-11769-5-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390342811-11769-5-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Tue, Jan 21, 2014 at 05:20:06PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> The numa_faults_cpu statistics are used to maintain an active_nodes nodemask
> per numa_group. This allows us to be smarter about when to do numa migrations.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  kernel/sched/fair.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 51 insertions(+)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index b98ed61..d4f6df5 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -885,6 +885,7 @@ struct numa_group {
>  	struct list_head task_list;
>  
>  	struct rcu_head rcu;
> +	nodemask_t active_nodes;
>  	unsigned long total_faults;
>  	unsigned long *faults_cpu;
>  	unsigned long faults[0];
> @@ -918,6 +919,12 @@ static inline unsigned long group_faults(struct task_struct *p, int nid)
>  		p->numa_group->faults[task_faults_idx(nid, 1)];
>  }
>  
> +static inline unsigned long group_faults_cpu(struct numa_group *group, int nid)
> +{
> +	return group->faults_cpu[task_faults_idx(nid, 0)] +
> +		group->faults_cpu[task_faults_idx(nid, 1)];
> +}
> +
>  /*
>   * These return the fraction of accesses done by a particular task, or
>   * task group, on a particular numa node.  The group weight is given a
> @@ -1275,6 +1282,40 @@ static void numa_migrate_preferred(struct task_struct *p)
>  }
>  
>  /*
> + * Find the nodes on which the workload is actively running. We do this by
> + * tracking the nodes from which NUMA hinting faults are triggered. This can
> + * be different from the set of nodes where the workload's memory is currently
> + * located.
> + *
> + * The bitmask is used to make smarter decisions on when to do NUMA page
> + * migrations, To prevent flip-flopping, and excessive page migrations, nodes
> + * are added when they cause over 6/16 of the maximum number of faults, but
> + * only removed when they drop below 3/16.
> + */
> +static void update_numa_active_node_mask(struct numa_group *numa_group)
> +{
> +	unsigned long faults, max_faults = 0;
> +	int nid;
> +
> +	for_each_online_node(nid) {
> +		faults = numa_group->faults_cpu[task_faults_idx(nid, 0)] +
> +			 numa_group->faults_cpu[task_faults_idx(nid, 1)];

faults = group_faults_cpu(numa_group, nid)

?

> +		if (faults > max_faults)
> +			max_faults = faults;
> +	}
> +
> +	for_each_online_node(nid) {
> +		faults = numa_group->faults_cpu[task_faults_idx(nid, 0)] +
> +			 numa_group->faults_cpu[task_faults_idx(nid, 1)];

Same?

> +		if (!node_isset(nid, numa_group->active_nodes)) {
> +			if (faults > max_faults * 6 / 16)
> +				node_set(nid, numa_group->active_nodes);
> +		} else if (faults < max_faults * 3 / 16)
> +			node_clear(nid, numa_group->active_nodes);
> +	}
> +}
> +
> +/*
>   * When adapting the scan rate, the period is divided into NUMA_PERIOD_SLOTS
>   * increments. The more local the fault statistics are, the higher the scan
>   * period will be for the next scan window. If local/remote ratio is below
> @@ -1416,6 +1457,7 @@ static void task_numa_placement(struct task_struct *p)
>  	update_task_scan_period(p, fault_types[0], fault_types[1]);
>  
>  	if (p->numa_group) {
> +		update_numa_active_node_mask(p->numa_group);
>  		/*
>  		 * If the preferred task and group nids are different,
>  		 * iterate over the nodes again to find the best place.
> @@ -1478,6 +1520,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>  		/* Second half of the array tracks nids where faults happen */
>  		grp->faults_cpu = grp->faults + 2 * nr_node_ids;
>  
> +		node_set(task_node(current), grp->active_nodes);
> +
>  		for (i = 0; i < 4*nr_node_ids; i++)
>  			grp->faults[i] = p->numa_faults_memory[i];
>  
> @@ -1547,6 +1591,13 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>  	my_grp->nr_tasks--;
>  	grp->nr_tasks++;
>  
> +	/*
> +	 * We just joined a new group, the set of active nodes may have
> +	 * changed. Do not update the nodemask of the old group, since
> +	 * the tasks in that group will probably join the new group soon.
> +	 */
> +	update_numa_active_node_mask(grp);
> +
>  	spin_unlock(&my_grp->lock);
>  	spin_unlock(&grp->lock);
>  

Ok, I guess this stops the old group making very different migration
decisions just because one task left the group. That has difficult to
predict consequences so assuming the new group_faults_cpu helper gets used

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
