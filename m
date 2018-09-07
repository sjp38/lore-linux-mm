Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 840DE6B7DCB
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 06:17:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t26-v6so7395647pfh.0
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 03:17:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id r6-v6si7356194pgp.591.2018.09.07.03.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Sep 2018 03:17:00 -0700 (PDT)
Date: Fri, 7 Sep 2018 12:16:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180907101634.GO24106@hirez.programming.kicks-ass.net>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828172258.3185-9-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Aug 28, 2018 at 01:22:57PM -0400, Johannes Weiner wrote:
> +enum psi_states {
> +	PSI_IO_SOME,
> +	PSI_IO_FULL,
> +	PSI_MEM_SOME,
> +	PSI_MEM_FULL,
> +	PSI_CPU_SOME,
> +	/* Only per-CPU, to weigh the CPU in the global average: */
> +	PSI_NONIDLE,
> +	NR_PSI_STATES,
> +};

> +static u32 get_recent_time(struct psi_group *group, int cpu,
> +			   enum psi_states state)
> +{
> +	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
> +	unsigned int seq;
> +	u32 time, delta;
> +
> +	do {
> +		seq = read_seqcount_begin(&groupc->seq);
> +
> +		time = groupc->times[state];
> +		/*
> +		 * In addition to already concluded states, we also
> +		 * incorporate currently active states on the CPU,
> +		 * since states may last for many sampling periods.
> +		 *
> +		 * This way we keep our delta sampling buckets small
> +		 * (u32) and our reported pressure close to what's
> +		 * actually happening.
> +		 */
> +		if (test_state(groupc->tasks, state))
> +			time += cpu_clock(cpu) - groupc->state_start;
> +	} while (read_seqcount_retry(&groupc->seq, seq));
> +
> +	delta = time - groupc->times_prev[state];
> +	groupc->times_prev[state] = time;
> +
> +	return delta;
> +}

> +static bool update_stats(struct psi_group *group)
> +{
> +	u64 deltas[NR_PSI_STATES - 1] = { 0, };
> +	unsigned long missed_periods = 0;
> +	unsigned long nonidle_total = 0;
> +	u64 now, expires, period;
> +	int cpu;
> +	int s;
> +
> +	mutex_lock(&group->stat_lock);
> +
> +	/*
> +	 * Collect the per-cpu time buckets and average them into a
> +	 * single time sample that is normalized to wallclock time.
> +	 *
> +	 * For averaging, each CPU is weighted by its non-idle time in
> +	 * the sampling period. This eliminates artifacts from uneven
> +	 * loading, or even entirely idle CPUs.
> +	 */
> +	for_each_possible_cpu(cpu) {
> +		u32 nonidle;
> +
> +		nonidle = get_recent_time(group, cpu, PSI_NONIDLE);
> +		nonidle = nsecs_to_jiffies(nonidle);
> +		nonidle_total += nonidle;
> +
> +		for (s = 0; s < PSI_NONIDLE; s++) {
> +			u32 delta;
> +
> +			delta = get_recent_time(group, cpu, s);
> +			deltas[s] += (u64)delta * nonidle;
> +		}
> +	}

This does the whole seqcount thing 6x, which is a bit of a waste.

struct snapshot {
	u32 times[NR_PSI_STATES];
};

static inline struct snapshot get_times_snapshot(struct psi_group *pg, int cpu)
{
	struct pci_group_cpu *pgc = per_cpu_ptr(pg->pcpu, cpu);
	struct snapshot s;
	unsigned int seq;
	u32 delta;
	int i;

	do {
		seq = read_seqcount_begin(&pgc->seq);

		delta = cpu_clock(cpu) - pgc->state_start;
		for (i = 0; i < NR_PSI_STATES; i++) {
			s.times[i] = gpc->times[i];
			if (test_state(pgc->tasks, i))
				s.times[i] += delta;
		}

	} while (read_seqcount_retry(&pgc->seq, seq);

	return s;
}


	for_each_possible_cpu(cpu) {
		struct snapshot s = get_times_snapshot(pg, cpu);

		nonidle = nsecs_to_jiffies(s.times[PSI_NONIDLE]);
		nonidle_total += nonidle;

		for (i = 0; i < PSI_NONIDLE; i++)
			deltas[s] += (u64)s.times[i] * nonidle;

		/* ... */

	}


It's a bit cumbersome, but that's because of C.
