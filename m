Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6D286B207E
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 16:11:23 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id b64-v6so10394669yba.22
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:11:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13-v6sor2768639ywa.345.2018.08.21.13.11.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 13:11:18 -0700 (PDT)
Date: Tue, 21 Aug 2018 16:11:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180821201115.GB24538@cmpxchg.org>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803172139.GE2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803172139.GE2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Aug 03, 2018 at 07:21:39PM +0200, Peter Zijlstra wrote:
> On Wed, Aug 01, 2018 at 11:19:57AM -0400, Johannes Weiner wrote:
> > +			time = READ_ONCE(groupc->times[s]);
> > +			/*
> > +			 * In addition to already concluded states, we
> > +			 * also incorporate currently active states on
> > +			 * the CPU, since states may last for many
> > +			 * sampling periods.
> > +			 *
> > +			 * This way we keep our delta sampling buckets
> > +			 * small (u32) and our reported pressure close
> > +			 * to what's actually happening.
> > +			 */
> > +			if (test_state(groupc->tasks, cpu, s)) {
> > +				/*
> > +				 * We can race with a state change and
> > +				 * need to make sure the state_start
> > +				 * update is ordered against the
> > +				 * updates to the live state and the
> > +				 * time buckets (groupc->times).
> > +				 *
> > +				 * 1. If we observe task state that
> > +				 * needs to be recorded, make sure we
> > +				 * see state_start from when that
> > +				 * state went into effect or we'll
> > +				 * count time from the previous state.
> > +				 *
> > +				 * 2. If the time delta has already
> > +				 * been added to the bucket, make sure
> > +				 * we don't see it in state_start or
> > +				 * we'll count it twice.
> > +				 *
> > +				 * If the time delta is out of
> > +				 * state_start but not in the time
> > +				 * bucket yet, we'll miss it entirely
> > +				 * and handle it in the next period.
> > +				 */
> > +				smp_rmb();
> > +				time += cpu_clock(cpu) - groupc->state_start;
> > +			}
> 
> As is, groupc->state_start needs a READ_ONCE() above and a WRITE_ONCE()
> below. But like stated earlier, doing an update in scheduler_tick() is
> probably easier.

I've wrapped these in READ_ONCE/WRITE_ONCE.

> > +static void psi_group_change(struct psi_group *group, int cpu, u64 now,
> > +			     unsigned int clear, unsigned int set)
> > +{
> > +	struct psi_group_cpu *groupc;
> > +	unsigned int t, m;
> > +	u32 delta;
> > +
> > +	groupc = per_cpu_ptr(group->pcpu, cpu);
> > +
> > +	/*
> > +	 * First we assess the aggregate resource states these CPU's
> > +	 * tasks have been in since the last change, and account any
> > +	 * SOME and FULL time that may have resulted in.
> > +	 *
> > +	 * Then we update the task counts according to the state
> > +	 * change requested through the @clear and @set bits.
> > +	 */
> > +
> > +	delta = now - groupc->state_start;
> > +	groupc->state_start = now;
> > +
> > +	/*
> > +	 * Update state_start before recording time in the sampling
> > +	 * buckets and changing task counts, to prevent a racing
> > +	 * aggregation from counting the delta twice or attributing it
> > +	 * to an old state.
> > +	 */
> > +	smp_wmb();
> > +
> > +	if (test_state(groupc->tasks, cpu, PSI_IO_SOME)) {
> > +		groupc->times[PSI_IO_SOME] += delta;
> > +		if (test_state(groupc->tasks, cpu, PSI_IO_FULL))
> > +			groupc->times[PSI_IO_FULL] += delta;
> > +	}
> > +	if (test_state(groupc->tasks, cpu, PSI_MEM_SOME)) {
> > +		groupc->times[PSI_MEM_SOME] += delta;
> > +		if (test_state(groupc->tasks, cpu, PSI_MEM_FULL))
> > +			groupc->times[PSI_MEM_FULL] += delta;
> > +	}
> 
> Might we worth checking the compiler does the right thing here and
> optimizes this branch fest into something sensible.

Yup, the results looked good. It recognizes that SOME and FULL have
overlapping conditions and then lays out the branches such that it
does not have to do redundant tests. It also recognizes that NONIDLE
is true when any of the other states is true and collapses that.

> > +	if (test_state(groupc->tasks, cpu, PSI_CPU_SOME))
> > +		groupc->times[PSI_CPU_SOME] += delta;
> > +	if (test_state(groupc->tasks, cpu, PSI_NONIDLE))
> > +		groupc->times[PSI_NONIDLE] += delta;
