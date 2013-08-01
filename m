Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 6D9CC6B0034
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 11:49:03 -0400 (EDT)
Date: Thu, 1 Aug 2013 16:48:58 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 18/18] sched: Swap tasks when reschuling if a CPU on a
 target node is imbalanced
Message-ID: <20130801154858.GG2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-19-git-send-email-mgorman@suse.de>
 <20130801045958.GB6151@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130801045958.GB6151@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 01, 2013 at 10:29:58AM +0530, Srikar Dronamraju wrote:
> > @@ -904,6 +908,8 @@ static int task_numa_find_cpu(struct task_struct *p, int nid)
> >  	src_eff_load *= src_load + effective_load(tg, src_cpu, -weight, -weight);
> > 
> >  	for_each_cpu(cpu, cpumask_of_node(nid)) {
> > +		struct task_struct *swap_candidate = NULL;
> > +
> >  		dst_load = target_load(cpu, idx);
> > 
> >  		/* If the CPU is idle, use it */
> > @@ -922,12 +928,41 @@ static int task_numa_find_cpu(struct task_struct *p, int nid)
> >  		 * migrate to its preferred node due to load imbalances.
> >  		 */
> >  		balanced = (dst_eff_load <= src_eff_load);
> > -		if (!balanced)
> > -			continue;
> > +		if (!balanced) {
> > +			struct rq *rq = cpu_rq(cpu);
> > +			unsigned long src_faults, dst_faults;
> > +
> > +			/* Do not move tasks off their preferred node */
> > +			if (rq->curr->numa_preferred_nid == nid)
> > +				continue;
> > +
> > +			/* Do not attempt an illegal migration */
> > +			if (!cpumask_test_cpu(cpu, tsk_cpus_allowed(rq->curr)))
> > +				continue;
> > +
> > +			/*
> > +			 * Do not impair locality for the swap candidate.
> > +			 * Destination for the swap candidate is the source cpu
> > +			 */
> > +			if (rq->curr->numa_faults) {
> > +				src_faults = rq->curr->numa_faults[task_faults_idx(nid, 1)];
> > +				dst_faults = rq->curr->numa_faults[task_faults_idx(src_cpu_node, 1)];
> > +				if (src_faults > dst_faults)
> > +					continue;
> > +			}
> > +
> > +			/*
> > +			 * The destination is overloaded but running a task
> > +			 * that is not running on its preferred node. Consider
> > +			 * swapping the CPU tasks are running on.
> > +			 */
> > +			swap_candidate = rq->curr;
> > +		}
> > 
> >  		if (dst_load < min_load) {
> >  			min_load = dst_load;
> >  			dst_cpu = cpu;
> > +			*swap_p = swap_candidate;
> 
> Are we some times passing a wrong candidate?
> Lets say the first cpu balanced is false and we set the swap_candidate,
> but find the second cpu(/or later cpus) to be idle or has lesser effective load, then we
> could be sending the task that is running on the first cpu as the swap
> candidate.

Then at the second or later CPU swap_candidate == NULL so swap_p is
cleared too.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
