Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 443FC6B0031
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 16:11:17 -0400 (EDT)
Date: Mon, 15 Jul 2013 22:11:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 18/18] sched: Swap tasks when reschuling if a CPU on a
 target node is imbalanced
Message-ID: <20130715201110.GO17211@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-19-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-19-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 04:20:20PM +0100, Mel Gorman wrote:
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 53d8465..d679b01 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -4857,10 +4857,13 @@ fail:
>  
>  #ifdef CONFIG_NUMA_BALANCING
>  /* Migrate current task p to target_cpu */
> -int migrate_task_to(struct task_struct *p, int target_cpu)
> +int migrate_task_to(struct task_struct *p, int target_cpu,
> +		    struct task_struct *swap_p)
>  {
>  	struct migration_arg arg = { p, target_cpu };
>  	int curr_cpu = task_cpu(p);
> +	struct rq *rq;
> +	int retval;
>  
>  	if (curr_cpu == target_cpu)
>  		return 0;
> @@ -4868,7 +4871,39 @@ int migrate_task_to(struct task_struct *p, int target_cpu)
>  	if (!cpumask_test_cpu(target_cpu, tsk_cpus_allowed(p)))
>  		return -EINVAL;
>  
> -	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
> +	if (swap_p == NULL)
> +		return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
> +
> +	/* Make sure the target is still running the expected task */
> +	rq = cpu_rq(target_cpu);
> +	local_irq_disable();
> +	raw_spin_lock(&rq->lock);

raw_spin_lock_irq() :-)

> +	if (rq->curr != swap_p) {
> +		raw_spin_unlock(&rq->lock);
> +		local_irq_enable();
> +		return -EINVAL;
> +	}
> +
> +	/* Take a reference on the running task on the target cpu */
> +	get_task_struct(swap_p);
> +	raw_spin_unlock(&rq->lock);
> +	local_irq_enable();

raw_spin_unlock_irq()

> +
> +	/* Move current running task to target CPU */
> +	retval = stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
> +	if (raw_smp_processor_id() != target_cpu) {
> +		put_task_struct(swap_p);
> +		return retval;
> +	}

(1)

> +	/* Move the remote task to the CPU just vacated */
> +	local_irq_disable();
> +	if (raw_smp_processor_id() == target_cpu)
> +		__migrate_task(swap_p, target_cpu, curr_cpu);
> +	local_irq_enable();
> +
> +	put_task_struct(swap_p);
> +	return retval;
>  }

So I know this is very much like what Ingo did in his patches, but
there's a whole heap of 'problems' with this approach to task flipping.

So at (1) we just moved ourselves to the remote cpu. This might have
left our original cpu idle and we might have done a newidle balance,
even though we intend another task to run here.

At (1) we just moved ourselves to the remote cpu, however we might not
be eligible to run, so moving the other task to our original CPU might
take a while -- exacerbating the previously mention issue.

Since (1) might take a whole lot of time, it might become rather
unlikely that our task @swap_p is still queued on the cpu where we
expected him to be.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
