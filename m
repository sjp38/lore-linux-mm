Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 7FF856B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 12:29:58 -0400 (EDT)
Date: Tue, 2 Jul 2013 17:29:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/8] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130702162953.GE1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-7-git-send-email-mgorman@suse.de>
 <20130702120655.GA2959@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130702120655.GA2959@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 02, 2013 at 05:36:55PM +0530, Srikar Dronamraju wrote:
> > A preferred node is selected based on the node the most NUMA hinting
> > faults was incurred on. There is no guarantee that the task is running
> > on that node at the time so this patch rescheules the task to run on
> > the most idle CPU of the selected node when selected. This avoids
> > waiting for the balancer to make a decision.
> > 
> 
> Should we be making this decisions just on the numa hinting faults alone? 
> 

No, we should not. More is required which will expand the scope of this
series. If a task is not running on the preferred node then why? Probably
because it was compute overloaded and the scheduler moved it off. Now
this is trying to push it back on. Instead we should account for how many
"preferred placed" tasks are running on that node and if it's more than
the number of CPUs then select the second-preferred or more preferred node
instead. Alternatively on the preferred node, find the task with the fewest
faults for that node and swap nodes with it.

> How are we making sure that the preferred node selection is persistent?

We aren't. That's why we only stick to a node a number of PTE scans with
this check with the full series applied

        if (*src_nid == *dst_nid ||
            p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
                return false;


> i.e due to memory accesses patterns, what if the preferred node
> selection keeps moving.
> 

If the preferred node keeps moving we are certainly in trouble currently.

> If a large process having several threads were to allocate memory in one
> node, then all threads will try to mark that node as their preferred
> node. Till they get a chance those tasks will move pages over to the
> local node. But if they get a chance to move to their preferred node
> before moving enough number of pages, then it would have to fetch back
> all the pages.
> 
> Can we look at using accumulating process weights and using the process
> weights to consolidate tasks to one node?
> 

Yes, that is ultimately required. Peter's original numacore series did
something like this but I had not disected which parts of it actually
matter in this round.

> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  kernel/sched/core.c  | 18 +++++++++++++++--
> >  kernel/sched/fair.c  | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++--
> >  kernel/sched/sched.h |  2 +-
> >  3 files changed, 70 insertions(+), 5 deletions(-)
> > 
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index ba9470e..b4722d6 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -5717,11 +5717,25 @@ struct sched_domain_topology_level;
> >  
> >  #ifdef CONFIG_NUMA_BALANCING
> >  
> > -/* Set a tasks preferred NUMA node */
> > -void sched_setnuma(struct task_struct *p, int nid)
> > +/* Set a tasks preferred NUMA node and reschedule to it */
> > +void sched_setnuma(struct task_struct *p, int nid, int idlest_cpu)
> >  {
> > +	int curr_cpu = task_cpu(p);
> > +	struct migration_arg arg = { p, idlest_cpu };
> > +
> >  	p->numa_preferred_nid = nid;
> >  	p->numa_migrate_seq = 0;
> > +
> > +	/* Do not reschedule if already running on the target CPU */
> > +	if (idlest_cpu == curr_cpu)
> > +		return;
> > +
> > +	/* Ensure the target CPU is eligible */
> > +	if (!cpumask_test_cpu(idlest_cpu, tsk_cpus_allowed(p)))
> > +		return;
> > +
> > +	/* Move current running task to idlest CPU on preferred node */
> > +	stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
> 
> Here, moving tasks this way doesnt update the schedstats at all.

I did not update stats because the existing users did not either. Then
again they are doing things like exec or updating the allowed mask so
it's not "interesting" as such

> So task migrations from perf stat and schedstats dont match.
> I know migration_cpu_stop was used this way before, but we are making
> schedstats more unreliable. Also I dont think migration_cpu_stop was
> used all that much. But now it gets used pretty persistently.

I know, this is going to be a concern, particularly when task swapping is
added to the mix. However, I'm not seeing a better way around it right now
other than waiting of the load balancer to kick in which is far from optimal.

> Probably we need to make migration_cpu_stop schedstats aware.
> 

Due to a lack of deep familiarity with the scheduler, it's not obvious
what the appropriate stats are. Do you mean duplicating something like
what set_task_cpu does within migration_cpu_stop?

> migration_cpu_stop has the other drawback that it doesnt check for
> cpu_throttling. So we might move a task from the present cpu to a
> different cpu and task might end up being throttled instead of being
> run.
> 

find_idlest_cpu_node at least reduces the risk of this but sure, if even if
the most idle CPU on the target node is overloaded then it's still a problem.

> >  }
> >  #endif /* CONFIG_NUMA_BALANCING */
> >  
> > diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> > index 5e7f728..99951a8 100644
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -800,6 +800,39 @@ unsigned int sysctl_numa_balancing_scan_delay = 1000;
> >   */
> >  unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
> >  
> > +static unsigned long weighted_cpuload(const int cpu);
> > +
> > +static int
> > +find_idlest_cpu_node(int this_cpu, int nid)
> > +{
> > +	unsigned long load, min_load = ULONG_MAX;
> > +	int i, idlest_cpu = this_cpu;
> > +
> > +	BUG_ON(cpu_to_node(this_cpu) == nid);
> > +
> > +	for_each_cpu(i, cpumask_of_node(nid)) {
> > +		load = weighted_cpuload(i);
> > +
> > +		if (load < min_load) {
> > +			struct task_struct *p;
> > +
> > +			/* Do not preempt a task running on its preferred node */
> > +			struct rq *rq = cpu_rq(i);
> > +			local_irq_disable();
> > +			raw_spin_lock(&rq->lock);
> > +			p = rq->curr;
> > +			if (p->numa_preferred_nid != nid) {
> > +				min_load = load;
> > +				idlest_cpu = i;
> > +			}
> > +			raw_spin_unlock(&rq->lock);
> > +			local_irq_disable();
> > +		}
> > +	}
> > +
> > +	return idlest_cpu;
> 
> Here we are not checking the preferred node is already loaded.

Correct. Long term we would need to check load based on number of "preferred
node" tasks running on it and also what the absolute load is. I had not
planned on dealing with it in this cycle as this number of patches is
already quite a mouthful but I'm aware the problem needs to be addressed.

> If the
> preferred node is already loaded than the current local node, (either
> because of task pinning, cpuset configurations,) pushing task to that
> node might only end up with the task being pulled back in the next
> balancing cycle.
> 

Yes, this is true.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
