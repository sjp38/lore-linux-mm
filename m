Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF4D6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 10:41:56 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so3853620eae.33
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 07:41:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si10265434eew.223.2014.01.21.07.41.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 07:41:55 -0800 (PST)
Date: Tue, 21 Jan 2014 15:41:51 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/6] numa,sched: build per numa_group active node mask
 from faults_from statistics
Message-ID: <20140121154151.GK4963@suse.de>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
 <1390245667-24193-4-git-send-email-riel@redhat.com>
 <20140121141919.GH4963@suse.de>
 <52DE8D9A.1090405@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52DE8D9A.1090405@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Tue, Jan 21, 2014 at 10:09:14AM -0500, Rik van Riel wrote:
> On 01/21/2014 09:19 AM, Mel Gorman wrote:
> > On Mon, Jan 20, 2014 at 02:21:04PM -0500, riel@redhat.com wrote:
> 
> >> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> >> index 1945ddc..ea8b2ae 100644
> >> --- a/kernel/sched/fair.c
> >> +++ b/kernel/sched/fair.c
> >> @@ -885,6 +885,7 @@ struct numa_group {
> >>  	struct list_head task_list;
> >>  
> >>  	struct rcu_head rcu;
> >> +	nodemask_t active_nodes;
> >>  	unsigned long total_faults;
> >>  	unsigned long *faults_from;
> >>  	unsigned long faults[0];
> > 
> > It's not a concern for now but in the land of unicorns and ponies we'll
> > relook at the size of some of these structures and see what can be
> > optimised.
> 
> Unsigned int should be enough for systems with less than 8TB
> of memory per node :)
> 

Is it not bigger than that?

typedef struct { DECLARE_BITMAP(bits, MAX_NUMNODES); } nodemask_t;

so it depends on the value of NODES_SHIFT? Anyway, not worth getting
into a twist over.

> > Similar to my comment on faults_from I think we could potentially evaluate
> > the fitness of the automatic NUMA balancing feature by looking at the
> > weight of the active_nodes for a numa_group. If
> > bitmask_weight(active_nodes) == nr_online_nodes
> > for all numa_groups in the system then I think it would be an indication
> > that the algorithm has collapsed.
> 
> If the system runs one very large workload, I would expect the
> scheduler to spread that workload across all nodes.
> 
> In that situation, it is perfectly legitimate for all nodes
> to end up being marked as active nodes, and for the system
> to try distribute the workload's memory somewhat evenly
> between them.
> 

In the specific case where the workload is not partitioned and really
accessing all of memory then sure, it'll be spread throughout the
system. However, if we are looking at a case like multiple JVMs sized to
fit within nodes then the metric would hold.

> > It's not a comment on the patch itself. We could could just do with more
> > metrics that help analyse this thing when debugging problems.
> > 
> >> @@ -1275,6 +1276,41 @@ static void numa_migrate_preferred(struct task_struct *p)
> >>  }
> >>  
> >>  /*
> >> + * Find the nodes on which the workload is actively running. We do this by
> > 
> > hmm, it's not the workload though, it's a single NUMA group and a workload
> > may consist of multiple NUMA groups. For example, in an ideal world and
> > a JVM-based workload the application threads and the GC threads would be
> > in different NUMA groups.
> 
> Why should they be in a different numa group?
> 

It would be ideal that they are in different groups so the hinting faults
incurred by the garbage collector (linear scan of the address space)
does not affect scheduling and placement decisions based on the numa
groups fault statistics.

> The rest of the series contains patches to make sure they
> should be just fine together in the same group...
> 
> > The signature is even more misleading because the signature implies that
> > the function is concerned with tasks. Pass in p->numa_group
> 
> Will do.
> 
> >> + * tracking the nodes from which NUMA hinting faults are triggered. This can
> >> + * be different from the set of nodes where the workload's memory is currently
> >> + * located.
> >> + *
> >> + * The bitmask is used to make smarter decisions on when to do NUMA page
> >> + * migrations, To prevent flip-flopping, and excessive page migrations, nodes
> >> + * are added when they cause over 6/16 of the maximum number of faults, but
> >> + * only removed when they drop below 3/16.
> >> + */
> > 
> > Looking at the values, I'm guessing you did it this way to use shifts
> > instead of divides. That's fine, but how did you arrive at those values?
> > Experimentally or just felt reasonable?
> 
> Experimentally I got to 20% and 40%.  Peter suggested I change it
> to 3/16 and 6/16, which appear to give identical performance.
> 

Cool

> >> +static void update_numa_active_node_mask(struct task_struct *p)
> >> +{
> >> +	unsigned long faults, max_faults = 0;
> >> +	struct numa_group *numa_group = p->numa_group;
> >> +	int nid;
> >> +
> >> +	for_each_online_node(nid) {
> >> +		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
> >> +			 numa_group->faults_from[task_faults_idx(nid, 1)];
> > 
> > task_faults() implements a helper for p->numa_faults equivalent of this.
> > Just as with the other renaming, it would not hurt to rename task_faults()
> > to something like task_faults_memory() and add a task_faults_cpu() for
> > this. The objective again is to be clear about whether we care about CPU
> > or memory locality information.
> 
> Will do.
> 
> >> +		if (faults > max_faults)
> >> +			max_faults = faults;
> >> +	}
> >> +
> >> +	for_each_online_node(nid) {
> >> +		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
> >> +			 numa_group->faults_from[task_faults_idx(nid, 1)];
> > 
> > group_faults would need similar adjustment.
> > 
> >> +		if (!node_isset(nid, numa_group->active_nodes)) {
> >> +			if (faults > max_faults * 6 / 16)
> >> +				node_set(nid, numa_group->active_nodes);
> >> +		} else if (faults < max_faults * 3 / 16)
> >> +			node_clear(nid, numa_group->active_nodes);
> >> +	}
> >> +}
> >> +
> > 
> > I think there is a subtle problem here
> 
> Can you be more specific about what problem you think the hysteresis
> could be causing?
> 

Lets say

Thread A: Most important thread for performance, accesses small amounts
	of memory during each scan window. Lets say it's doing calculations
	over a large cache-aware structure of some description

Thread B: Big stupid linear scanner accessing all of memory for whatever
	reason.

Thread B will incur more NUMA hinting faults because it is accessing
idle memory that is unused by Thread A. The fault stats and placement
decisions are then skewed in favour of Thread B because Thread A did not
trap enough hinting faults.

It's a theoretical problem.

> > /*
> >  * Be mindful that this is subject to sampling error. As we only have
> >  * data on hinting faults active_nodes may miss a heavily referenced
> >  * node due to the references being to a small number of pages. If
> >  * there is a large linear scanner in the same numa group as a
> >  * task operating on a small amount of memory then the latter task
> >  * may be ignored.
> >  */
> > 
> > I have no suggestion on how to handle this
> 
> Since the numa_faults_cpu statistics are all about driving
> memory-follows-cpu, there actually is a decent way to handle
> it.  See patch 5 :)
> 
> >> +/*
> >>   * When adapting the scan rate, the period is divided into NUMA_PERIOD_SLOTS
> >>   * increments. The more local the fault statistics are, the higher the scan
> >>   * period will be for the next scan window. If local/remote ratio is below
> >> @@ -1416,6 +1452,7 @@ static void task_numa_placement(struct task_struct *p)
> >>  	update_task_scan_period(p, fault_types[0], fault_types[1]);
> >>  
> >>  	if (p->numa_group) {
> >> +		update_numa_active_node_mask(p);
> > 
> > We are updating that thing once per scan window, that's fine. There is
> > potentially a wee issue though. If all the tasks in the group are threads
> > then they share p->mm->numa_scan_seq and only one task does the update
> > per scan window. If they are different processes then we could be updating
> > more frequently than necessary.
> > 
> > Functionally it'll be fine but higher cost than necessary. I do not have a
> > better suggestion right now as superficially a numa_scan_seq per numa_group
> > would not be a good fit.
> 
> I suspect this cost will be small anyway, compared to the costs
> incurred in both the earlier part of task_numa_placement, and
> in the code where we may look for a better place to migrate the
> task to.
> 
> This just iterates over memory we have already touched before
> (likely to still be cached), and does some cheap comparisons.
> 

Fair enough. It'll show up in profiles if it's a problem anyway.

> >>  		/*
> >>  		 * If the preferred task and group nids are different,
> >>  		 * iterate over the nodes again to find the best place.
> >> @@ -1478,6 +1515,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
> >>  		/* Second half of the array tracks where faults come from */
> >>  		grp->faults_from = grp->faults + 2 * nr_node_ids;
> >>  
> >> +		node_set(task_node(current), grp->active_nodes);
> >> +
> >>  		for (i = 0; i < 4*nr_node_ids; i++)
> >>  			grp->faults[i] = p->numa_faults[i];
> >>  
> >> @@ -1547,6 +1586,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
> >>  	my_grp->nr_tasks--;
> >>  	grp->nr_tasks++;
> >>  
> >> +	update_numa_active_node_mask(p);
> >> +
> > 
> > This may be subtle enough to deserve a comment
> > 
> > /* Tasks have joined/left groups and the active_mask is no longer valid */
> 
> I have added a comment.
> 
> > If we left a group, we update our new group. Is the old group now out of
> > date and in need of updating too?
> 
> The entire old group will join the new group, and the old group
> is freed.
> 

We reference count the old group so that it only gets freed when the
last task leaves it. If the old group was guaranteed to be destroyed
there would be no need to do stuff like

list_move(&p->numa_entry, &grp->task_list);
my_grp->total_faults -= p->total_numa_faults;
my_grp->nr_tasks--;

All that reads as "a single task is moving group" and not the entire
old group joins the new group. I expected that the old group was only
guaranteed to be destroyed in the case where we had just allocated it
because p->numa_group was NULL when task_numa_group was called.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
