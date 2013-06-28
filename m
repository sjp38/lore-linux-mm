Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id DAEDD6B0031
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 08:30:22 -0400 (EDT)
Date: Fri, 28 Jun 2013 13:30:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/8] sched: Track NUMA hinting faults on per-node basis
Message-ID: <20130628123015.GT1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-3-git-send-email-mgorman@suse.de>
 <20130628060829.GA17195@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130628060829.GA17195@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 11:38:29AM +0530, Srikar Dronamraju wrote:
> * Mel Gorman <mgorman@suse.de> [2013-06-26 15:38:01]:
> 
> > This patch tracks what nodes numa hinting faults were incurred on.  Greater
> > weight is given if the pages were to be migrated on the understanding
> > that such faults cost significantly more. If a task has paid the cost to
> > migrating data to that node then in the future it would be preferred if the
> > task did not migrate the data again unnecessarily. This information is later
> > used to schedule a task on the node incurring the most NUMA hinting faults.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  include/linux/sched.h |  2 ++
> >  kernel/sched/core.c   |  3 +++
> >  kernel/sched/fair.c   | 12 +++++++++++-
> >  kernel/sched/sched.h  | 12 ++++++++++++
> >  4 files changed, 28 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index e692a02..72861b4 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1505,6 +1505,8 @@ struct task_struct {
> >  	unsigned int numa_scan_period;
> >  	u64 node_stamp;			/* migration stamp  */
> >  	struct callback_head numa_work;
> > +
> > +	unsigned long *numa_faults;
> >  #endif /* CONFIG_NUMA_BALANCING */
> >  
> >  	struct rcu_head rcu;
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index 67d0465..f332ec0 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -1594,6 +1594,7 @@ static void __sched_fork(struct task_struct *p)
> >  	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
> >  	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
> >  	p->numa_work.next = &p->numa_work;
> > +	p->numa_faults = NULL;
> >  #endif /* CONFIG_NUMA_BALANCING */
> >  }
> >  
> > @@ -1853,6 +1854,8 @@ static void finish_task_switch(struct rq *rq, struct task_struct *prev)
> >  	if (mm)
> >  		mmdrop(mm);
> >  	if (unlikely(prev_state == TASK_DEAD)) {
> > +		task_numa_free(prev);
> > +
> >  		/*
> >  		 * Remove function-return probe instances associated with this
> >  		 * task and put them back on the free list.
> > diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> > index 7a33e59..904fd6f 100644
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -815,7 +815,14 @@ void task_numa_fault(int node, int pages, bool migrated)
> >  	if (!sched_feat_numa(NUMA))
> >  		return;
> >  
> > -	/* FIXME: Allocate task-specific structure for placement policy here */
> > +	/* Allocate buffer to track faults on a per-node basis */
> > +	if (unlikely(!p->numa_faults)) {
> > +		int size = sizeof(*p->numa_faults) * nr_node_ids;
> > +
> > +		p->numa_faults = kzalloc(size, GFP_KERNEL);
> > +		if (!p->numa_faults)
> > +			return;
> > +	}
> >  
> >  	/*
> >  	 * If pages are properly placed (did not migrate) then scan slower.
> > @@ -826,6 +833,9 @@ void task_numa_fault(int node, int pages, bool migrated)
> >  			p->numa_scan_period + jiffies_to_msecs(10));
> >  
> >  	task_numa_placement(p);
> > +
> > +	/* Record the fault, double the weight if pages were migrated */
> > +	p->numa_faults[node] += pages << migrated;
> 
> 
> Why are we doing this after the placement.
> I mean we should probably be doing this in the task_numa_placement,
> 

Peter covered this.

> Since doubling the pages can have an effect on the preferred node. If we
> do it here, wont it end up in a case where the numa_faults on one node
> is actually higher but it may end up being not the preferred node?
> 

Possibly but it's important to take into account the cost of migration. I
want to prefer keeping tasks on nodes that data was migrated to.

There is a much more serious problem with fault sampling that I have yet
to think of a good solution for. Consider a task that exhibits very high
locality and occasionally updates shared statistics. This hypothetical
workload is dominated by addressing a small array with the shared statistics
in a large array. In this case the PTE scanner will incur a larger number
of faults in the shared array even though it's less important to the
workload. The preferred node will be wrong in this case and is a much more
serious problem.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
