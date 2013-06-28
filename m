Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 058F16B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 09:54:57 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:54:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/8] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130628135454.GZ1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-7-git-send-email-mgorman@suse.de>
 <20130627145458.GU28407@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130627145458.GU28407@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 27, 2013 at 04:54:58PM +0200, Peter Zijlstra wrote:
> On Wed, Jun 26, 2013 at 03:38:05PM +0100, Mel Gorman wrote:
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
> 
> raw_spin_lock_irq() ?
> 

/me slaps self

Fixed. Thanks.

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
> > +}

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
