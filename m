Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06CD96B2061
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 15:44:24 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id n7-v6so5744865yba.10
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 12:44:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p7-v6sor879701ywc.93.2018.08.21.12.44.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 12:44:16 -0700 (PDT)
Date: Tue, 21 Aug 2018 15:44:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180821194413.GA24538@cmpxchg.org>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803165641.GA2476@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803165641.GA2476@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

a quick update on that feedback before I send out v4:

On Fri, Aug 03, 2018 at 06:56:41PM +0200, Peter Zijlstra wrote:
> On Wed, Aug 01, 2018 at 11:19:57AM -0400, Johannes Weiner wrote:
> > +static bool test_state(unsigned int *tasks, int cpu, enum psi_states state)
> > +{
> > +	switch (state) {
> > +	case PSI_IO_SOME:
> > +		return tasks[NR_IOWAIT];
> > +	case PSI_IO_FULL:
> > +		return tasks[NR_IOWAIT] && !tasks[NR_RUNNING];
> > +	case PSI_MEM_SOME:
> > +		return tasks[NR_MEMSTALL];
> > +	case PSI_MEM_FULL:
> > +		/*
> > +		 * Since we care about lost potential, things are
> > +		 * fully blocked on memory when there are no other
> > +		 * working tasks, but also when the CPU is actively
> > +		 * being used by a reclaimer and nothing productive
> > +		 * could run even if it were runnable.
> > +		 */
> > +		return tasks[NR_MEMSTALL] &&
> > +			(!tasks[NR_RUNNING] ||
> > +			 cpu_curr(cpu)->flags & PF_MEMSTALL);
> 
> I don't think you can do this, there is nothing that guarantees
> cpu_curr() still exists.

As discussed later in this thread, I've replaced this with time
sampling from inside scheduler_tick(): in the unlikely event that
rq->curr is PF_MEMSTALL, it'll record TICK_NSEC worth of MEM_FULL.

However:

> > +		for (s = PSI_NONIDLE; s >= 0; s--) {
> > +			u32 time, delta;
> > +
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
> The alternative is adding an update to scheduler_tick(), that would
> ensure you're never more than nr_cpu_ids * TICK_NSEC behind.

I wasn't able to convert *all* states to tick updates like this.

The reason is that, while testing rq->curr for PF_MEMSTALL is cheap,
other tasks associated with the rq could be from any cgroup in the
system. That means we'd have to do for_each_cgroup() on every tick to
keep the groupc->times that closely uptodate, and that wouldn't scale.
We tend to have hundreds of them, some setups have thousands.

Since we don't need to be *that* current, I left the on-demand update
inside the aggregator for now. It's a bit trickier, but much cheaper.
