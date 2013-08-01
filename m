Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 7C1B16B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 11:39:02 -0400 (EDT)
Date: Thu, 1 Aug 2013 16:38:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/18] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130801153857.GD2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-9-git-send-email-mgorman@suse.de>
 <20130801044757.GA6151@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130801044757.GA6151@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 01, 2013 at 10:17:57AM +0530, Srikar Dronamraju wrote:
> * Mel Gorman <mgorman@suse.de> [2013-07-15 16:20:10]:
> 
> > A preferred node is selected based on the node the most NUMA hinting
> > faults was incurred on. There is no guarantee that the task is running
> > on that node at the time so this patch rescheules the task to run on
> > the most idle CPU of the selected node when selected. This avoids
> > waiting for the balancer to make a decision.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  kernel/sched/core.c  | 17 +++++++++++++++++
> >  kernel/sched/fair.c  | 46 +++++++++++++++++++++++++++++++++++++++++++++-
> >  kernel/sched/sched.h |  1 +
> >  3 files changed, 63 insertions(+), 1 deletion(-)
> > 
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index 5e02507..b67a102 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -4856,6 +4856,23 @@ fail:
> >  	return ret;
> >  }
> > 
> > +#ifdef CONFIG_NUMA_BALANCING
> > +/* Migrate current task p to target_cpu */
> > +int migrate_task_to(struct task_struct *p, int target_cpu)
> > +{
> > +	struct migration_arg arg = { p, target_cpu };
> > +	int curr_cpu = task_cpu(p);
> > +
> > +	if (curr_cpu == target_cpu)
> > +		return 0;
> > +
> > +	if (!cpumask_test_cpu(target_cpu, tsk_cpus_allowed(p)))
> > +		return -EINVAL;
> > +
> > +	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
> 
> As I had noted earlier, this upsets schedstats badly.
> Can we add a TODO for this patch, which mentions that schedstats need to
> taken care.
> 

I added a TODO comment because there is a possibility that this will all
change again with the stop_two_cpus patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
