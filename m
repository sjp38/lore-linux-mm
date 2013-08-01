Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id B89976B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 11:42:41 -0400 (EDT)
Date: Thu, 1 Aug 2013 16:42:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 16/18] sched: Avoid overloading CPUs on a preferred NUMA
 node
Message-ID: <20130801154228.GE2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-17-git-send-email-mgorman@suse.de>
 <20130801071013.GG4880@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130801071013.GG4880@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 01, 2013 at 12:40:13PM +0530, Srikar Dronamraju wrote:
> > +static int task_numa_find_cpu(struct task_struct *p, int nid)
> > +{
> > +	int node_cpu = cpumask_first(cpumask_of_node(nid));
> > +	int cpu, src_cpu = task_cpu(p), dst_cpu = src_cpu;
> > +	unsigned long src_load, dst_load;
> > +	unsigned long min_load = ULONG_MAX;
> > +	struct task_group *tg = task_group(p);
> > +	s64 src_eff_load, dst_eff_load;
> > +	struct sched_domain *sd;
> > +	unsigned long weight;
> > +	bool balanced;
> > +	int imbalance_pct, idx = -1;
> > 
> > +	/* No harm being optimistic */
> > +	if (idle_cpu(node_cpu))
> > +		return node_cpu;
> 
> Cant this lead to lot of imbalance across nodes? Wont this lead to lot
> of ping-pong of tasks between different nodes resulting in performance
> hit?

Ideally it wouldn't because if we are trying to migrate the task to here in
the first place then it must have been scheduled there for long enough to
accumulate those faults. Now, there might be a ping-pong effect because a
tasks gets moved off by the load balancer because the CPUs are overloaded and
now we're trying to move it back. If we can detect that this is happening
then one way of dealing with it would be to clear p->numa_faults[] when
a task is moved off a node due to compute overload.

> Lets say the system is not fully loaded, something like a numa01
> but with far lesser number of threads probably nr_cpus/2 or nr_cpus/4,
> then all threads will try to move to single node as we can keep seeing
> idle threads. No? Wont it lead all load moving to one node and load
> balancer spreading it out...
> 

I cannot be 100% certain. I'm not strong enough on the scheduler yet and
the compute overloading handling is currently too weak.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
