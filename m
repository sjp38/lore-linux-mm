Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9182C6B7ED5
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 10:44:30 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id v14-v6so8825865ywv.18
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 07:44:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y184-v6sor1258500ywe.426.2018.09.07.07.44.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 07:44:24 -0700 (PDT)
Date: Fri, 7 Sep 2018 10:44:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180907144422.GA11088@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
 <20180907101634.GO24106@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180907101634.GO24106@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Sep 07, 2018 at 12:16:34PM +0200, Peter Zijlstra wrote:
> On Tue, Aug 28, 2018 at 01:22:57PM -0400, Johannes Weiner wrote:
> > +enum psi_states {
> > +	PSI_IO_SOME,
> > +	PSI_IO_FULL,
> > +	PSI_MEM_SOME,
> > +	PSI_MEM_FULL,
> > +	PSI_CPU_SOME,
> > +	/* Only per-CPU, to weigh the CPU in the global average: */
> > +	PSI_NONIDLE,
> > +	NR_PSI_STATES,
> > +};
> 
> > +static u32 get_recent_time(struct psi_group *group, int cpu,
> > +			   enum psi_states state)
> > +{
> > +	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
> > +	unsigned int seq;
> > +	u32 time, delta;
> > +
> > +	do {
> > +		seq = read_seqcount_begin(&groupc->seq);
> > +
> > +		time = groupc->times[state];
> > +		/*
> > +		 * In addition to already concluded states, we also
> > +		 * incorporate currently active states on the CPU,
> > +		 * since states may last for many sampling periods.
> > +		 *
> > +		 * This way we keep our delta sampling buckets small
> > +		 * (u32) and our reported pressure close to what's
> > +		 * actually happening.
> > +		 */
> > +		if (test_state(groupc->tasks, state))
> > +			time += cpu_clock(cpu) - groupc->state_start;
> > +	} while (read_seqcount_retry(&groupc->seq, seq));
> > +
> > +	delta = time - groupc->times_prev[state];
> > +	groupc->times_prev[state] = time;
> > +
> > +	return delta;
> > +}
> 
> > +static bool update_stats(struct psi_group *group)
> > +{
> > +	u64 deltas[NR_PSI_STATES - 1] = { 0, };
> > +	unsigned long missed_periods = 0;
> > +	unsigned long nonidle_total = 0;
> > +	u64 now, expires, period;
> > +	int cpu;
> > +	int s;
> > +
> > +	mutex_lock(&group->stat_lock);
> > +
> > +	/*
> > +	 * Collect the per-cpu time buckets and average them into a
> > +	 * single time sample that is normalized to wallclock time.
> > +	 *
> > +	 * For averaging, each CPU is weighted by its non-idle time in
> > +	 * the sampling period. This eliminates artifacts from uneven
> > +	 * loading, or even entirely idle CPUs.
> > +	 */
> > +	for_each_possible_cpu(cpu) {
> > +		u32 nonidle;
> > +
> > +		nonidle = get_recent_time(group, cpu, PSI_NONIDLE);
> > +		nonidle = nsecs_to_jiffies(nonidle);
> > +		nonidle_total += nonidle;
> > +
> > +		for (s = 0; s < PSI_NONIDLE; s++) {
> > +			u32 delta;
> > +
> > +			delta = get_recent_time(group, cpu, s);
> > +			deltas[s] += (u64)delta * nonidle;
> > +		}
> > +	}
> 
> This does the whole seqcount thing 6x, which is a bit of a waste.

[...]

> It's a bit cumbersome, but that's because of C.

I was actually debating exactly this with Suren before, but since this
is a super cold path I went with readability. I was also thinking that
restarts could happen quite regularly under heavy scheduler load, and
so keeping the individual retry sections small could be helpful - but
I didn't instrument this in any way.

No strong opinion from me, I can send an updated patch if you prefer.
