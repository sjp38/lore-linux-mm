Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC226B2397
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:16:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n17-v6so833542pff.17
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:16:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 15-v6si1277529pgu.205.2018.08.22.02.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 02:16:48 -0700 (PDT)
Date: Wed, 22 Aug 2018 11:16:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180822091640.GV24124@hirez.programming.kicks-ass.net>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803165641.GA2476@hirez.programming.kicks-ass.net>
 <20180821194413.GA24538@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821194413.GA24538@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Aug 21, 2018 at 03:44:13PM -0400, Johannes Weiner wrote:

> > > +		for (s = PSI_NONIDLE; s >= 0; s--) {
> > > +			u32 time, delta;
> > > +
> > > +			time = READ_ONCE(groupc->times[s]);
> > > +			/*
> > > +			 * In addition to already concluded states, we
> > > +			 * also incorporate currently active states on
> > > +			 * the CPU, since states may last for many
> > > +			 * sampling periods.
> > > +			 *
> > > +			 * This way we keep our delta sampling buckets
> > > +			 * small (u32) and our reported pressure close
> > > +			 * to what's actually happening.
> > > +			 */
> > > +			if (test_state(groupc->tasks, cpu, s)) {
> > > +				/*
> > > +				 * We can race with a state change and
> > > +				 * need to make sure the state_start
> > > +				 * update is ordered against the
> > > +				 * updates to the live state and the
> > > +				 * time buckets (groupc->times).
> > > +				 *
> > > +				 * 1. If we observe task state that
> > > +				 * needs to be recorded, make sure we
> > > +				 * see state_start from when that
> > > +				 * state went into effect or we'll
> > > +				 * count time from the previous state.
> > > +				 *
> > > +				 * 2. If the time delta has already
> > > +				 * been added to the bucket, make sure
> > > +				 * we don't see it in state_start or
> > > +				 * we'll count it twice.
> > > +				 *
> > > +				 * If the time delta is out of
> > > +				 * state_start but not in the time
> > > +				 * bucket yet, we'll miss it entirely
> > > +				 * and handle it in the next period.
> > > +				 */
> > > +				smp_rmb();
> > > +				time += cpu_clock(cpu) - groupc->state_start;
> > > +			}
> > 
> > The alternative is adding an update to scheduler_tick(), that would
> > ensure you're never more than nr_cpu_ids * TICK_NSEC behind.
> 
> I wasn't able to convert *all* states to tick updates like this.
> 
> The reason is that, while testing rq->curr for PF_MEMSTALL is cheap,
> other tasks associated with the rq could be from any cgroup in the
> system. That means we'd have to do for_each_cgroup() on every tick to
> keep the groupc->times that closely uptodate, and that wouldn't scale.
> We tend to have hundreds of them, some setups have thousands.
> 
> Since we don't need to be *that* current, I left the on-demand update
> inside the aggregator for now. It's a bit trickier, but much cheaper.

ARGH indeed; I was thinking we only need to update current. But because
we're tracking blocked state that doesn't work.

Sorry for that :/
