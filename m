Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4726B026A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:02:03 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id t65-v6so981715iof.23
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:02:03 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p7-v6si974085iof.19.2018.07.17.08.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Jul 2018 08:02:00 -0700 (PDT)
Date: Tue, 17 Jul 2018 17:01:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180717150142.GG2494@hirez.programming.kicks-ass.net>
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
> +static bool psi_update_stats(struct psi_group *group)
> +{
> +	u64 some[NR_PSI_RESOURCES] = { 0, };
> +	u64 full[NR_PSI_RESOURCES] = { 0, };
> +	unsigned long nonidle_total = 0;
> +	unsigned long missed_periods;
> +	unsigned long expires;
> +	int cpu;
> +	int r;
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
> +	 *
> +	 * We could pin the online CPUs here, but the noise introduced
> +	 * by missing up to one sample period from CPUs that are going
> +	 * away shouldn't matter in practice - just like the noise of
> +	 * previously offlined CPUs returning with a non-zero sample.

But why!? cpuu_read_lock() is neither expensive nor complicated. So why
try and avoid it?

> +	 */
> +	for_each_online_cpu(cpu) {
> +		struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
> +		unsigned long nonidle;
> +
> +		if (!groupc->nonidle_time)
> +			continue;
> +
> +		nonidle = nsecs_to_jiffies(groupc->nonidle_time);
> +		groupc->nonidle_time = 0;
> +		nonidle_total += nonidle;
> +
> +		for (r = 0; r < NR_PSI_RESOURCES; r++) {
> +			struct psi_resource *res = &groupc->res[r];
> +
> +			some[r] += (res->times[0] + res->times[1]) * nonidle;
> +			full[r] += res->times[1] * nonidle;
> +
> +			/* It's racy, but we can tolerate some error */
> +			res->times[0] = 0;
> +			res->times[1] = 0;
> +		}
> +	}
> +
> +	/*
> +	 * Integrate the sample into the running statistics that are
> +	 * reported to userspace: the cumulative stall times and the
> +	 * decaying averages.
> +	 *
> +	 * Pressure percentages are sampled at PSI_FREQ. We might be
> +	 * called more often when the user polls more frequently than
> +	 * that; we might be called less often when there is no task
> +	 * activity, thus no data, and clock ticks are sporadic. The
> +	 * below handles both.
> +	 */
> +
> +	/* total= */
> +	for (r = 0; r < NR_PSI_RESOURCES; r++) {
> +		do_div(some[r], max(nonidle_total, 1UL));
> +		do_div(full[r], max(nonidle_total, 1UL));
> +
> +		group->some[r] += some[r];
> +		group->full[r] += full[r];

		group->some[r] = div64_ul(some[r], max(nonidle_total, 1UL));
		group->full[r] = div64_ul(full[r], max(nonidle_total, 1UL));

Is easier to read imo.

> +	}
> +
> +	/* avgX= */
> +	expires = group->period_expires;
> +	if (time_before(jiffies, expires))
> +		goto out;
> +
> +	missed_periods = (jiffies - expires) / PSI_FREQ;
> +	group->period_expires = expires + ((1 + missed_periods) * PSI_FREQ);
> +
> +	for (r = 0; r < NR_PSI_RESOURCES; r++) {
> +		u64 some, full;
> +
> +		some = group->some[r] - group->last_some[r];
> +		full = group->full[r] - group->last_full[r];
> +
> +		calc_avgs(group->avg_some[r], some, missed_periods);
> +		calc_avgs(group->avg_full[r], full, missed_periods);
> +
> +		group->last_some[r] = group->some[r];
> +		group->last_full[r] = group->full[r];
> +	}
> +out:
> +	mutex_unlock(&group->stat_lock);
> +	return nonidle_total;
> +}
