Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id C62386B0037
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 10:09:50 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id e16so7047228qcx.38
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 07:09:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t8si3285512qeu.132.2014.01.21.07.09.48
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 07:09:49 -0800 (PST)
Message-ID: <52DE8D9A.1090405@redhat.com>
Date: Tue, 21 Jan 2014 10:09:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] numa,sched: build per numa_group active node mask
 from faults_from statistics
References: <1390245667-24193-1-git-send-email-riel@redhat.com> <1390245667-24193-4-git-send-email-riel@redhat.com> <20140121141919.GH4963@suse.de>
In-Reply-To: <20140121141919.GH4963@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On 01/21/2014 09:19 AM, Mel Gorman wrote:
> On Mon, Jan 20, 2014 at 02:21:04PM -0500, riel@redhat.com wrote:

>> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
>> index 1945ddc..ea8b2ae 100644
>> --- a/kernel/sched/fair.c
>> +++ b/kernel/sched/fair.c
>> @@ -885,6 +885,7 @@ struct numa_group {
>>  	struct list_head task_list;
>>  
>>  	struct rcu_head rcu;
>> +	nodemask_t active_nodes;
>>  	unsigned long total_faults;
>>  	unsigned long *faults_from;
>>  	unsigned long faults[0];
> 
> It's not a concern for now but in the land of unicorns and ponies we'll
> relook at the size of some of these structures and see what can be
> optimised.

Unsigned int should be enough for systems with less than 8TB
of memory per node :)

> Similar to my comment on faults_from I think we could potentially evaluate
> the fitness of the automatic NUMA balancing feature by looking at the
> weight of the active_nodes for a numa_group. If
> bitmask_weight(active_nodes) == nr_online_nodes
> for all numa_groups in the system then I think it would be an indication
> that the algorithm has collapsed.

If the system runs one very large workload, I would expect the
scheduler to spread that workload across all nodes.

In that situation, it is perfectly legitimate for all nodes
to end up being marked as active nodes, and for the system
to try distribute the workload's memory somewhat evenly
between them.

> It's not a comment on the patch itself. We could could just do with more
> metrics that help analyse this thing when debugging problems.
> 
>> @@ -1275,6 +1276,41 @@ static void numa_migrate_preferred(struct task_struct *p)
>>  }
>>  
>>  /*
>> + * Find the nodes on which the workload is actively running. We do this by
> 
> hmm, it's not the workload though, it's a single NUMA group and a workload
> may consist of multiple NUMA groups. For example, in an ideal world and
> a JVM-based workload the application threads and the GC threads would be
> in different NUMA groups.

Why should they be in a different numa group?

The rest of the series contains patches to make sure they
should be just fine together in the same group...

> The signature is even more misleading because the signature implies that
> the function is concerned with tasks. Pass in p->numa_group

Will do.

>> + * tracking the nodes from which NUMA hinting faults are triggered. This can
>> + * be different from the set of nodes where the workload's memory is currently
>> + * located.
>> + *
>> + * The bitmask is used to make smarter decisions on when to do NUMA page
>> + * migrations, To prevent flip-flopping, and excessive page migrations, nodes
>> + * are added when they cause over 6/16 of the maximum number of faults, but
>> + * only removed when they drop below 3/16.
>> + */
> 
> Looking at the values, I'm guessing you did it this way to use shifts
> instead of divides. That's fine, but how did you arrive at those values?
> Experimentally or just felt reasonable?

Experimentally I got to 20% and 40%.  Peter suggested I change it
to 3/16 and 6/16, which appear to give identical performance.

>> +static void update_numa_active_node_mask(struct task_struct *p)
>> +{
>> +	unsigned long faults, max_faults = 0;
>> +	struct numa_group *numa_group = p->numa_group;
>> +	int nid;
>> +
>> +	for_each_online_node(nid) {
>> +		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
>> +			 numa_group->faults_from[task_faults_idx(nid, 1)];
> 
> task_faults() implements a helper for p->numa_faults equivalent of this.
> Just as with the other renaming, it would not hurt to rename task_faults()
> to something like task_faults_memory() and add a task_faults_cpu() for
> this. The objective again is to be clear about whether we care about CPU
> or memory locality information.

Will do.

>> +		if (faults > max_faults)
>> +			max_faults = faults;
>> +	}
>> +
>> +	for_each_online_node(nid) {
>> +		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
>> +			 numa_group->faults_from[task_faults_idx(nid, 1)];
> 
> group_faults would need similar adjustment.
> 
>> +		if (!node_isset(nid, numa_group->active_nodes)) {
>> +			if (faults > max_faults * 6 / 16)
>> +				node_set(nid, numa_group->active_nodes);
>> +		} else if (faults < max_faults * 3 / 16)
>> +			node_clear(nid, numa_group->active_nodes);
>> +	}
>> +}
>> +
> 
> I think there is a subtle problem here

Can you be more specific about what problem you think the hysteresis
could be causing?

> /*
>  * Be mindful that this is subject to sampling error. As we only have
>  * data on hinting faults active_nodes may miss a heavily referenced
>  * node due to the references being to a small number of pages. If
>  * there is a large linear scanner in the same numa group as a
>  * task operating on a small amount of memory then the latter task
>  * may be ignored.
>  */
> 
> I have no suggestion on how to handle this

Since the numa_faults_cpu statistics are all about driving
memory-follows-cpu, there actually is a decent way to handle
it.  See patch 5 :)

>> +/*
>>   * When adapting the scan rate, the period is divided into NUMA_PERIOD_SLOTS
>>   * increments. The more local the fault statistics are, the higher the scan
>>   * period will be for the next scan window. If local/remote ratio is below
>> @@ -1416,6 +1452,7 @@ static void task_numa_placement(struct task_struct *p)
>>  	update_task_scan_period(p, fault_types[0], fault_types[1]);
>>  
>>  	if (p->numa_group) {
>> +		update_numa_active_node_mask(p);
> 
> We are updating that thing once per scan window, that's fine. There is
> potentially a wee issue though. If all the tasks in the group are threads
> then they share p->mm->numa_scan_seq and only one task does the update
> per scan window. If they are different processes then we could be updating
> more frequently than necessary.
> 
> Functionally it'll be fine but higher cost than necessary. I do not have a
> better suggestion right now as superficially a numa_scan_seq per numa_group
> would not be a good fit.

I suspect this cost will be small anyway, compared to the costs
incurred in both the earlier part of task_numa_placement, and
in the code where we may look for a better place to migrate the
task to.

This just iterates over memory we have already touched before
(likely to still be cached), and does some cheap comparisons.

>>  		/*
>>  		 * If the preferred task and group nids are different,
>>  		 * iterate over the nodes again to find the best place.
>> @@ -1478,6 +1515,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>>  		/* Second half of the array tracks where faults come from */
>>  		grp->faults_from = grp->faults + 2 * nr_node_ids;
>>  
>> +		node_set(task_node(current), grp->active_nodes);
>> +
>>  		for (i = 0; i < 4*nr_node_ids; i++)
>>  			grp->faults[i] = p->numa_faults[i];
>>  
>> @@ -1547,6 +1586,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>>  	my_grp->nr_tasks--;
>>  	grp->nr_tasks++;
>>  
>> +	update_numa_active_node_mask(p);
>> +
> 
> This may be subtle enough to deserve a comment
> 
> /* Tasks have joined/left groups and the active_mask is no longer valid */

I have added a comment.

> If we left a group, we update our new group. Is the old group now out of
> date and in need of updating too?

The entire old group will join the new group, and the old group
is freed.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
