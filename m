Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C56886B0033
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 08:39:50 -0400 (EDT)
Date: Thu, 11 Jul 2013 14:39:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 16/16] sched: Select least loaded CPU on preferred NUMA
 node
Message-ID: <20130711123902.GI25631@dyad.programming.kicks-ass.net>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
 <1373536020-2799-17-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373536020-2799-17-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 10:47:00AM +0100, Mel Gorman wrote:
> +++ b/kernel/sched/fair.c
> @@ -841,29 +841,81 @@ static unsigned int task_scan_max(struct task_struct *p)
>   */
>  unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
>  
> +static unsigned long source_load(int cpu, int type);
> +static unsigned long target_load(int cpu, int type);
> +static unsigned long power_of(int cpu);
> +static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
> +
> +static int task_numa_find_cpu(struct task_struct *p, int nid)
> +{
> +	int node_cpu = cpumask_first(cpumask_of_node(nid));
> +	int cpu, src_cpu = task_cpu(p), dst_cpu = src_cpu;
> +	unsigned long src_load, dst_load;
> +	unsigned long min_load = ULONG_MAX;
> +	struct task_group *tg = task_group(p);
> +	s64 src_eff_load, dst_eff_load;
> +	struct sched_domain *sd;
> +	unsigned long weight;
> +	int imbalance_pct, idx = -1;
>  
> +	/* No harm being optimistic */
> +	if (idle_cpu(node_cpu))
> +		return node_cpu;
>  
> +	/*
> +	 * Find the lowest common scheduling domain covering the nodes of both
> +	 * the CPU the task is currently running on and the target NUMA node.
> +	 */
>  	rcu_read_lock();
> +	for_each_domain(src_cpu, sd) {
> +		if (cpumask_test_cpu(node_cpu, sched_domain_span(sd))) {
> +			/*
> +			 * busy_idx is used for the load decision as it is the
> +			 * same index used by the regular load balancer for an
> +			 * active cpu.
> +			 */
> +			idx = sd->busy_idx;
> +			imbalance_pct = sd->imbalance_pct;
> +			break;
>  		}
>  	}
>  	rcu_read_unlock();
>  
> +	if (WARN_ON_ONCE(idx == -1))
> +		return src_cpu;
> +
> +	/*
> +	 * XXX the below is mostly nicked from wake_affine(); we should
> +	 * see about sharing a bit if at all possible; also it might want
> +	 * some per entity weight love.
> +	 */
> +	weight = p->se.load.weight;
> + 
> +	src_load = source_load(src_cpu, idx);
> +
> +	src_eff_load = 100 + (imbalance_pct - 100) / 2;
> +	src_eff_load *= power_of(src_cpu);
> +	src_eff_load *= src_load + effective_load(tg, src_cpu, -weight, -weight);
> +
> +	for_each_cpu(cpu, cpumask_of_node(nid)) {
> +		dst_load = target_load(cpu, idx);
> +
> +		/* If the CPU is idle, use it */
> +		if (!dst_load)
> +			return dst_cpu;
> +
> +		/* Otherwise check the target CPU load */
> +		dst_eff_load = 100;
> +		dst_eff_load *= power_of(cpu);
> +		dst_eff_load *= dst_load + effective_load(tg, cpu, weight, weight);

So the missing part is:

		/*
		 * Do not allow the destination CPU to be loaded significantly
		 * more than the CPU we came from.
		 */
		if (dst_eff_load <= src_eff_load)
			continue;

> +
> +		if (dst_load < min_load) {
> +			min_load = dst_load;
> +			dst_cpu = cpu;
> +		}
> + 	}
> +
> +	return dst_cpu;
>  }

This is almost a big fat NOP. It did a scan for the least loaded cpu and now it
still does. It also doesn't cure the problem Srikar saw where we kept migrating
all tasks back to the one node with all the memory.

Task migration must be subject to fairness limits; otherwise there's nothing
avoiding heaping all tasks on a single pile.

One thing we could do to maybe relax things a little bit is take away the
effective_load() term in the src_eff_load() computation. That way we compare
the current src load to the future dst load, instead of using the future load
for both.

But we must put a limit on the migration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
