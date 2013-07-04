Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id F1E236B0036
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 09:29:43 -0400 (EDT)
Date: Thu, 4 Jul 2013 14:29:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/13] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130704132939.GQ1875@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-7-git-send-email-mgorman@suse.de>
 <20130704122644.GA29916@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130704122644.GA29916@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 04, 2013 at 05:56:44PM +0530, Srikar Dronamraju wrote:
> * Mel Gorman <mgorman@suse.de> [2013-07-03 15:21:33]:
> 
> > 
> > diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> > index 2a0bbc2..b9139be 100644
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -800,6 +800,37 @@ unsigned int sysctl_numa_balancing_scan_delay = 1000;
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
> > +			raw_spin_lock_irq(&rq->lock);
> 
> Not sure why we need this spin_lock? Cant this be done in a rcu block
> instead?
> 

Judging by how find_idlest_cpu works it would appear you are correct.
Thanks very much, I'm still pretty much a scheduler wuss. I know what I
want but not always how to get it :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
