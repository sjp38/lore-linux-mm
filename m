Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 2C71A6B0033
	for <linux-mm@kvack.org>; Sat,  6 Jul 2013 06:39:01 -0400 (EDT)
Date: Sat, 6 Jul 2013 12:38:13 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 06/15] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130706103813.GQ18898@dyad.programming.kicks-ass.net>
References: <1373065742-9753-1-git-send-email-mgorman@suse.de>
 <1373065742-9753-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373065742-9753-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jul 06, 2013 at 12:08:53AM +0100, Mel Gorman wrote:
> +static int
> +find_idlest_cpu_node(int this_cpu, int nid)
> +{
> +	unsigned long load, min_load = ULONG_MAX;
> +	int i, idlest_cpu = this_cpu;
> +
> +	BUG_ON(cpu_to_node(this_cpu) == nid);
> +
> +	rcu_read_lock();
> +	for_each_cpu(i, cpumask_of_node(nid)) {
> +		load = weighted_cpuload(i);
> +
> +		if (load < min_load) {
> +			/*
> +			 * Kernel threads can be preempted. For others, do
> +			 * not preempt if running on their preferred node
> +			 * or pinned.
> +			 */
> +			struct task_struct *p = cpu_rq(i)->curr;
> +			if ((p->flags & PF_KTHREAD) ||
> +			    (p->numa_preferred_nid != nid && p->nr_cpus_allowed > 1)) {
> +				min_load = load;
> +				idlest_cpu = i;
> +			}

So I really don't get this stuff.. if it is indeed the idlest cpu preempting
others shouldn't matter. Also, migrating a task there doesn't actually mean it
will get preempted either.

In overloaded scenarios it expected that multiple tasks will run on the same
cpu. So this condition will also explicitly make overloaded scenarios work less
well.

> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	return idlest_cpu;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
