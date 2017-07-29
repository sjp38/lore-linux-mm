Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED5F36B058B
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 05:11:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c14so301369653pgn.11
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 02:11:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a61si12534272plc.914.2017.07.29.02.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 02:11:04 -0700 (PDT)
Date: Sat, 29 Jul 2017 11:10:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170729091055.GA6524@worktop.programming.kicks-ass.net>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727153010.23347-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

So no, this doesn't have a change in hell of making it.

On Thu, Jul 27, 2017 at 11:30:10AM -0400, Johannes Weiner wrote:
> +static void domain_cpu_update(struct memdelay_domain *md, int cpu,
> +			      int old, int new)
> +{
> +	enum memdelay_domain_state state;
> +	struct memdelay_domain_cpu *mdc;
> +	unsigned long now, delta;
> +	unsigned long flags;
> +
> +	mdc = per_cpu_ptr(md->mdcs, cpu);
> +	spin_lock_irqsave(&mdc->lock, flags);

Afaict this is inside scheduler locks, this cannot be a spinlock. Also,
do we really want to add more atomics there?

> +	if (old) {
> +		WARN_ONCE(!mdc->tasks[old], "cpu=%d old=%d new=%d counter=%d\n",
> +			  cpu, old, new, mdc->tasks[old]);
> +		mdc->tasks[old] -= 1;
> +	}
> +	if (new)
> +		mdc->tasks[new] += 1;
> +
> +	/*
> +	 * The domain is somewhat delayed when a number of tasks are
> +	 * delayed but there are still others running the workload.
> +	 *
> +	 * The domain is fully delayed when all non-idle tasks on the
> +	 * CPU are delayed, or when a delayed task is actively running
> +	 * and preventing productive tasks from making headway.
> +	 *
> +	 * The state times then add up over all CPUs in the domain: if
> +	 * the domain is fully blocked on one CPU and there is another
> +	 * one running the workload, the domain is considered fully
> +	 * blocked 50% of the time.
> +	 */
> +	if (!mdc->tasks[MTS_DELAYED_ACTIVE] && !mdc->tasks[MTS_DELAYED])
> +		state = MDS_NONE;
> +	else if (mdc->tasks[MTS_WORKING])
> +		state = MDS_SOME;
> +	else
> +		state = MDS_FULL;
> +
> +	if (mdc->state == state)
> +		goto unlock;
> +
> +	now = ktime_to_ns(ktime_get());

ktime_get_ns(), also no ktime in scheduler code.

> +	delta = now - mdc->state_start;
> +
> +	domain_move_clock(md);
> +	md->times[mdc->state] += delta;
> +
> +	mdc->state = state;
> +	mdc->state_start = now;
> +unlock:
> +	spin_unlock_irqrestore(&mdc->lock, flags);
> +}
> +
> +static struct memdelay_domain *memcg_domain(struct mem_cgroup *memcg)
> +{
> +#ifdef CONFIG_MEMCG
> +	if (!mem_cgroup_disabled())
> +		return memcg->memdelay_domain;
> +#endif
> +	return &memdelay_global_domain;
> +}
> +
> +/**
> + * memdelay_task_change - note a task changing its delay/work state
> + * @task: the task changing state
> + * @delayed: 1 when task enters delayed state, -1 when it leaves
> + * @working: 1 when task enters working state, -1 when it leaves
> + * @active_delay: 1 when task enters active delay, -1 when it leaves
> + *
> + * Updates the task's domain counters to reflect a change in the
> + * task's delayed/working state.
> + */
> +void memdelay_task_change(struct task_struct *task, int old, int new)
> +{
> +	int cpu = task_cpu(task);
> +	struct mem_cgroup *memcg;
> +	unsigned long delay = 0;
> +
> +#ifdef CONFIG_DEBUG_VM
> +	WARN_ONCE(task->memdelay_state != old,
> +		  "cpu=%d task=%p state=%d (in_iowait=%d PF_MEMDELAYED=%d) old=%d new=%d\n",
> +		  cpu, task, task->memdelay_state, task->in_iowait,
> +		  !!(task->flags & PF_MEMDELAY), old, new);
> +	task->memdelay_state = new;
> +#endif
> +
> +	/* Account when tasks are entering and leaving delays */
> +	if (old < MTS_DELAYED && new >= MTS_DELAYED) {
> +		task->memdelay_start = ktime_to_ms(ktime_get());
> +	} else if (old >= MTS_DELAYED && new < MTS_DELAYED) {
> +		delay = ktime_to_ms(ktime_get()) - task->memdelay_start;
> +		task->memdelay_total += delay;
> +	}

Scheduler stuff will _NOT_ user ktime_get() and will _NOT_ do pointless
divisions into ms.

> +
> +	/* Account domain state changes */
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(task);
> +	do {
> +		struct memdelay_domain *md;
> +
> +		md = memcg_domain(memcg);
> +		md->aggregate += delay;
> +		domain_cpu_update(md, cpu, old, new);
> +	} while (memcg && (memcg = parent_mem_cgroup(memcg)));
> +	rcu_read_unlock();

We are _NOT_ going to do a 3rd cgroup iteration for every task action.

> +};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
