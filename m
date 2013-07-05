Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E4D0C6B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 08:49:33 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 5 Jul 2013 06:49:33 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 1A8FD3E40040
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 06:49:11 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r65CnV7l133882
	for <linux-mm@kvack.org>; Fri, 5 Jul 2013 06:49:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r65CnUWA019577
	for <linux-mm@kvack.org>; Fri, 5 Jul 2013 06:49:31 -0600
Date: Fri, 5 Jul 2013 18:19:25 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC WIP] Process weights based scheduling for better
 consolidation
Message-ID: <20130705124925.GB31348@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <20130704180227.GA31348@linux.vnet.ibm.com>
 <20130705101654.GL23916@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130705101654.GL23916@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2013-07-05 12:16:54]:

> On Thu, Jul 04, 2013 at 11:32:27PM +0530, Srikar Dronamraju wrote:
> > Here is an approach to look at numa balanced scheduling from a non numa fault
> > angle. This approach uses process weights instead of faults as a basis to
> > move or bring tasks together.
> 
> That doesn't make any sense..... how would weight be related to numa
> placement?
> 

Since groups tasks to a node, makes sure that all the memory moves to
that node (courtesy the existing numa balancing in the kernel). So we
have both the tasks and memory in the same node. 

> What it appears to do it simply group tasks based on ->mm. And by
> keeping them somewhat sticky to the same node it gets locality.
> 

Yes, thats the key thing it tries to achieve.

> What about multi-process shared memory workloads? Its one of the things
> I disliked about autonuma. It completely disregards the multi-process
> scenario.
> 

Yes, This approach doesnt work that well with multi-process shared
memory workloads.  However the current Mel's proposal also disregards
shared pages for preferred_node logic.  Further if we consider multiple
processes sharing memory, then they would probably be sharing more memory
within themselves. And that one of the observations that Mel made in
defense of accounting private faults.

Also the processes that share data within themselves are probably very
very high compared to processes that share data with other processes. 
Shouldnt we be optimizing for the majority case first.

With my suggested approach, it would be a problem if two process share
data and are of so big size that they cannot be part of the same node.

I think numa faults should be part of scheduling and should solve these
cases but it might/should kick in later. Do you agree that solving the
case where tasks share data within themselves is more important problem
to solve now. (I too had the code for numa faults, but I thought we need
to get this in first, so moved it out. And I am happy that Mel is taking
care of that approach.)

> If you want to go without faults; you also won't migrate memory along
> and if you just happen to place your workload elsewhere you've no idea

Why, the memory moves to the workload because of numa faults, I am not
disabling numa faults. So if all or majority of the task move to that
node, the memory obviously should follow to that node and I seeing that
happen. Do you see a reason why it wouldnt move?

> where your memory is. If you have the faults, you might as well account
> them to get a notion of where the memory is at; its nearly free at that
> point anyway.
> 

And I am not against numa fault based scheduling, I, for now think the
primary step should be based on grouping task based on mm and then on
fault stats.

> Load spikes/fluctuations can easily lead to transient task movement to
> keep balance. If these movements are indeed transient you want to return
> to where you came from; however if they are not.. you want the memory to
> come to you.
> 

Yes, this should be achieved because in the load spike not all load runs
on that node, not all tasks from this mm gets move out of the node. And
hence the node weights should still be in similar proportions. Infact
we have checks and iterations in can_migrate_task(), its most
likely that these tasks that have a numa weightage get a preference to
stay in their node. 

> > +static void account_numa_enqueue(struct cfs_rq *cfs_rq, struct task_struct *p)
> > +{
> > +	struct rq *rq = rq_of(cfs_rq);
> > +	unsigned long task_load = 0;
> > +	int curnode = cpu_to_node(cpu_of(rq));
> > +#ifdef CONFIG_SCHED_AUTOGROUP
> > +	struct sched_entity *se;
> > +
> > +	se = cfs_rq->tg->se[cpu_of(rq)];
> > +	if (!se)
> > +		return;
> > +
> > +	if (cfs_rq->load.weight) {
> > +		task_load =  p->se.load.weight * se->load.weight;
> > +		task_load /= cfs_rq->load.weight;
> > +	} else {
> > +		task_load = 0;
> > +	}
> > +#else
> > +	task_load = p->se.load.weight;
> > +#endif
> 
> This looks broken; didn't you want to use task_h_load() here? There's
> nothing autogroup specific about task_load. If anything you want to do
> full cgroup which I think reduces to task_h_load() here.
> 

Yes, I realize, 
I actually tried task_h_load, In the autogroup case the load on the cpu
was showing 83, while task_h_load returned 1024. the cgroup load was
2048 and the cgroups se load was 12. 

So I concluded that the cgroups load contributing to the total load is 
12 out of 83 and the proportion of this se was 6. Hence the equation. 
I will retry.

There are probably half-a-dozen such crap in my code which I
still need to fix. Thanks for pointing this one.

One other easy to locate issue is some sort of missing synchronization
in migrate_from_cpu/migrate_from_node.

> > +	p->task_load = 0;
> > +	if (!task_load)
> > +		return;
> > +
> > +	if (p->mm && p->mm->numa_weights) {
> > +		p->mm->numa_weights[curnode] += task_load;
> > +		p->mm->numa_weights[nr_node_ids] += task_load;
> > +	}
> > +
> > +	if (p->nr_cpus_allowed != num_online_cpus())
> > +		rq->pinned_load += task_load;
> > +	p->task_load = task_load;
> > +}
> > +
> 
> > @@ -5529,6 +5769,76 @@ static void rebalance_domains(int cpu, enum cpu_idle_type idle)
> >  		if (!balance)
> >  			break;
> >  	}
> > +#ifdef CONFIG_NUMA_BALANCING
> > +	if (!rq->nr_running) {
> 
> This would only work for under utilized systems...
> 

Why? Even on 2x  or 4x load machines, I see rebalance_domain calling
with NEWLY_IDLE and failing to do any balance. I made this observation
based on schedstats. So unless we see 0% idle times, this code should
kick in. Right?

Further if the machine is loaded, our checks introduced by
preferred_node, force_migrate will be more than useful to move tasks, 
We would ideally need active balance on lightly loaded machines because
then the tasks that we want to move are more likely to be active on the
cpus and hence the regular scheduler cannot do the right thing.

> > +	}
> > +#endif
> 

And finally, thanks for taking a look.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
