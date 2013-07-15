Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id A366B6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 16:03:29 -0400 (EDT)
Date: Mon, 15 Jul 2013 22:03:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 16/18] sched: Avoid overloading CPUs on a preferred NUMA
 node
Message-ID: <20130715200321.GN17211@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-17-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-17-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 04:20:18PM +0100, Mel Gorman wrote:
> ---
>  kernel/sched/fair.c | 105 +++++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 83 insertions(+), 22 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 3f0519c..8ee1c8e 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -846,29 +846,92 @@ static inline int task_faults_idx(int nid, int priv)
>  	return 2 * nid + priv;
>  }
>  
> -static unsigned long weighted_cpuload(const int cpu);
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
> +	bool balanced;
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
> +	rcu_read_lock();
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
> +		}
> +	}
> +	rcu_read_unlock();
>  
> +	if (WARN_ON_ONCE(idx == -1))
> +		return src_cpu;
>  
> +	/*
> +	 * XXX the below is mostly nicked from wake_affine(); we should
> +	 * see about sharing a bit if at all possible; also it might want
> +	 * some per entity weight love.
> +	 */
> +	weight = p->se.load.weight;
>  
> +	src_load = source_load(src_cpu, idx);
> +
> +	src_eff_load = 100 + (imbalance_pct - 100) / 2;
> +	src_eff_load *= power_of(src_cpu);
> +	src_eff_load *= src_load + effective_load(tg, src_cpu, -weight, -weight);

So did you try with this effective_load() term 'missing'?

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
> +
> +		/*
> +		 * Destination is considered balanced if the destination CPU is
> +		 * less loaded than the source CPU. Unfortunately there is a
> +		 * risk that a task running on a lightly loaded CPU will not
> +		 * migrate to its preferred node due to load imbalances.
> +		 */
> +		balanced = (dst_eff_load <= src_eff_load);
> +		if (!balanced)
> +			continue;
> +
> +		if (dst_load < min_load) {
> +			min_load = dst_load;
> +			dst_cpu = cpu;
>  		}
>  	}
>  
> +	return dst_cpu;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
