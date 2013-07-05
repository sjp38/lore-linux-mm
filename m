Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 958A46B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 06:17:01 -0400 (EDT)
Date: Fri, 5 Jul 2013 12:16:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH RFC WIP] Process weights based scheduling for better
 consolidation
Message-ID: <20130705101654.GL23916@twins.programming.kicks-ass.net>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <20130704180227.GA31348@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130704180227.GA31348@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 04, 2013 at 11:32:27PM +0530, Srikar Dronamraju wrote:
> Here is an approach to look at numa balanced scheduling from a non numa fault
> angle. This approach uses process weights instead of faults as a basis to
> move or bring tasks together.

That doesn't make any sense..... how would weight be related to numa
placement?

What it appears to do it simply group tasks based on ->mm. And by
keeping them somewhat sticky to the same node it gets locality.

What about multi-process shared memory workloads? Its one of the things
I disliked about autonuma. It completely disregards the multi-process
scenario.

If you want to go without faults; you also won't migrate memory along
and if you just happen to place your workload elsewhere you've no idea
where your memory is. If you have the faults, you might as well account
them to get a notion of where the memory is at; its nearly free at that
point anyway.

Load spikes/fluctuations can easily lead to transient task movement to
keep balance. If these movements are indeed transient you want to return
to where you came from; however if they are not.. you want the memory to
come to you.

> +static void account_numa_enqueue(struct cfs_rq *cfs_rq, struct task_struct *p)
> +{
> +	struct rq *rq = rq_of(cfs_rq);
> +	unsigned long task_load = 0;
> +	int curnode = cpu_to_node(cpu_of(rq));
> +#ifdef CONFIG_SCHED_AUTOGROUP
> +	struct sched_entity *se;
> +
> +	se = cfs_rq->tg->se[cpu_of(rq)];
> +	if (!se)
> +		return;
> +
> +	if (cfs_rq->load.weight) {
> +		task_load =  p->se.load.weight * se->load.weight;
> +		task_load /= cfs_rq->load.weight;
> +	} else {
> +		task_load = 0;
> +	}
> +#else
> +	task_load = p->se.load.weight;
> +#endif

This looks broken; didn't you want to use task_h_load() here? There's
nothing autogroup specific about task_load. If anything you want to do
full cgroup which I think reduces to task_h_load() here.

> +	p->task_load = 0;
> +	if (!task_load)
> +		return;
> +
> +	if (p->mm && p->mm->numa_weights) {
> +		p->mm->numa_weights[curnode] += task_load;
> +		p->mm->numa_weights[nr_node_ids] += task_load;
> +	}
> +
> +	if (p->nr_cpus_allowed != num_online_cpus())
> +		rq->pinned_load += task_load;
> +	p->task_load = task_load;
> +}
> +

> @@ -5529,6 +5769,76 @@ static void rebalance_domains(int cpu, enum cpu_idle_type idle)
>  		if (!balance)
>  			break;
>  	}
> +#ifdef CONFIG_NUMA_BALANCING
> +	if (!rq->nr_running) {

This would only work for under utilized systems...

> +	}
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
