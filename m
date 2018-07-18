Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 603766B0007
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:03:40 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id w19-v6so3207007ioa.10
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:03:40 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f8-v6si2266218iok.1.2018.07.18.05.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Jul 2018 05:03:38 -0700 (PDT)
Date: Wed, 18 Jul 2018 14:03:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718120318.GC2476@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712172942.10094-9-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> +/* Tracked task states */
> +enum psi_task_count {
> +	NR_RUNNING,
> +	NR_IOWAIT,
> +	NR_MEMSTALL,
> +	NR_PSI_TASK_COUNTS,
> +};
> +
> +/* Task state bitmasks */
> +#define TSK_RUNNING	(1 << NR_RUNNING)
> +#define TSK_IOWAIT	(1 << NR_IOWAIT)
> +#define TSK_MEMSTALL	(1 << NR_MEMSTALL)
> +
> +/* Resources that workloads could be stalled on */
> +enum psi_res {
> +	PSI_CPU,
> +	PSI_MEM,
> +	PSI_IO,
> +	NR_PSI_RESOURCES,
> +};
> +
> +/* Pressure states for a group of tasks */
> +enum psi_state {
> +	PSI_NONE,		/* No stalled tasks */
> +	PSI_SOME,		/* Stalled tasks & working tasks */
> +	PSI_FULL,		/* Stalled tasks & no working tasks */
> +	NR_PSI_STATES,
> +};
> +
> +struct psi_resource {
> +	/* Current pressure state for this resource */
> +	enum psi_state state;

This has a 4 byte hole here (really 7 but GCC is generous and uses 4
bytes for the enum that spans the value range [0-2]).

> +	/* Start of current state (rq_clock) */
> +	u64 state_start;
> +
> +	/* Time sampling buckets for pressure states SOME and FULL (ns) */
> +	u64 times[2];
> +};
> +
> +struct psi_group_cpu {
> +	/* States of the tasks belonging to this group */
> +	unsigned int tasks[NR_PSI_TASK_COUNTS];
> +
> +	/* There are runnable or D-state tasks */
> +	int nonidle;
> +
> +	/* Start of current non-idle state (rq_clock) */
> +	u64 nonidle_start;
> +
> +	/* Time sampling bucket for non-idle state (ns) */
> +	u64 nonidle_time;
> +
> +	/* Per-resource pressure tracking in this group */
> +	struct psi_resource res[NR_PSI_RESOURCES];
> +};

> +static DEFINE_PER_CPU(struct psi_group_cpu, system_group_cpus);

Since psi_group_cpu is exactly 2 lines big, I think you want the above
to be DEFINE_PER_CPU_SHARED_ALIGNED() to minimize cache misses on
accounting. Also, I think you want to stick ____cacheline_aligned_in_smp
on the structure, such that alloc_percpu() also DTRT.

Of those 2 lines, 12 bytes are wasted because of that hole above, and a
further 8 are wasted because PSI_CPU does not use FULL, for a total of
20 wasted bytes in there.

> +static void time_state(struct psi_resource *res, int state, u64 now)
> +{
> +	if (res->state != PSI_NONE) {
> +		bool was_full = res->state == PSI_FULL;
> +
> +		res->times[was_full] += now - res->state_start;
> +	}
> +	if (res->state != state)
> +		res->state = state;
> +	if (res->state != PSI_NONE)
> +		res->state_start = now;
> +}

Does the compiler optimize that and fold the two != NONE branches?

> +static void psi_group_change(struct psi_group *group, int cpu, u64 now,
> +			     unsigned int clear, unsigned int set)
> +{
> +	enum psi_state state = PSI_NONE;
> +	struct psi_group_cpu *groupc;
> +	unsigned int *tasks;
> +	unsigned int to, bo;
> +
> +	groupc = per_cpu_ptr(group->cpus, cpu);
> +	tasks = groupc->tasks;

	bool was_nonidle = tasks[NR_RUNNING] || tasks[NR_IOWAIT] || tasks[NR_MEMSTALL];

> +	/* Update task counts according to the set/clear bitmasks */
> +	for (to = 0; (bo = ffs(clear)); to += bo, clear >>= bo) {
> +		int idx = to + (bo - 1);
> +
> +		if (tasks[idx] == 0 && !psi_bug) {
> +			printk_deferred(KERN_ERR "psi: task underflow! cpu=%d idx=%d tasks=[%u %u %u] clear=%x set=%x\n",
> +					cpu, idx, tasks[0], tasks[1], tasks[2],
> +					clear, set);
> +			psi_bug = 1;
> +		}

		WARN_ONCE(!tasks[idx], ...);

> +		tasks[idx]--;
> +	}
> +	for (to = 0; (bo = ffs(set)); to += bo, set >>= bo)
> +		tasks[to + (bo - 1)]++;

You want to benchmark this, but since it's only 3 consecutive bits, it
might actually be faster to not use ffs() and simply test all 3 bits:

	for (to = set, bo = 0; to; to &= ~(1 << bo), bo++)
		tasks[bo]++;

or something like that.

> +
> +	/* Time in which tasks wait for the CPU */
> +	state = PSI_NONE;
> +	if (tasks[NR_RUNNING] > 1)
> +		state = PSI_SOME;
> +	time_state(&groupc->res[PSI_CPU], state, now);
> +
> +	/* Time in which tasks wait for memory */
> +	state = PSI_NONE;
> +	if (tasks[NR_MEMSTALL]) {
> +		if (!tasks[NR_RUNNING] ||
> +		    (cpu_curr(cpu)->flags & PF_MEMSTALL))

I'm confused, why do we care if the current tasks is MEMSTALL or not?

> +			state = PSI_FULL;
> +		else
> +			state = PSI_SOME;
> +	}
> +	time_state(&groupc->res[PSI_MEM], state, now);
> +
> +	/* Time in which tasks wait for IO */
> +	state = PSI_NONE;
> +	if (tasks[NR_IOWAIT]) {
> +		if (!tasks[NR_RUNNING])
> +			state = PSI_FULL;
> +		else
> +			state = PSI_SOME;
> +	}
> +	time_state(&groupc->res[PSI_IO], state, now);
> +
> +	/* Time in which tasks are non-idle, to weigh the CPU in summaries */
	if (was_nonidle);
> +		groupc->nonidle_time += now - groupc->nonidle_start;

	if (tasks[NR_RUNNING] || tasks[NR_IOWAIT] || tasks[NR_MEMSTALL])
> +		groupc->nonidle_start = now;

Does away with groupc->nonidle, giving us 24 bytes free.

> +	/* Kick the stats aggregation worker if it's gone to sleep */
> +	if (!delayed_work_pending(&group->clock_work))
> +		schedule_delayed_work(&group->clock_work, PSI_FREQ);
> +}

If you always update the time buckets, rename nonidle_start as last_time
and do away with psi_resource::state_start, you gain another 24 bytes,
giving 48 bytes free.

And as said before, we can compress the state from 12 bytes, to 6 bits
(or 1 byte), giving another 11 bytes for 59 bytes free.

Leaving us just 5 bytes short of needing a single cacheline :/

struct ponies {
        unsigned int               tasks[3];                                             /*     0    12 */
        unsigned int               cpu_state:2;                                          /*    12:30  4 */
        unsigned int               io_state:2;                                           /*    12:28  4 */
        unsigned int               mem_state:2;                                          /*    12:26  4 */

        /* XXX 26 bits hole, try to pack */

        /* typedef u64 */ long long unsigned int     last_time;                          /*    16     8 */
        /* typedef u64 */ long long unsigned int     some_time[3];                       /*    24    24 */
        /* typedef u64 */ long long unsigned int     full_time[2];                       /*    48    16 */
        /* --- cacheline 1 boundary (64 bytes) --- */
        /* typedef u64 */ long long unsigned int     nonidle_time;                       /*    64     8 */

        /* size: 72, cachelines: 2, members: 8 */
        /* bit holes: 1, sum bit holes: 26 bits */
        /* last cacheline: 8 bytes */
};

ARGGH!
