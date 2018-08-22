Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4DAE6B257D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 13:28:35 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id z83-v6so1377220ywg.3
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 10:28:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n127-v6sor533468ywe.547.2018.08.22.10.28.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 10:28:27 -0700 (PDT)
Date: Wed, 22 Aug 2018 13:28:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180822172825.GA1317@cmpxchg.org>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803172139.GE2494@hirez.programming.kicks-ass.net>
 <20180821201115.GB24538@cmpxchg.org>
 <20180822091024.GU24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822091024.GU24124@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Aug 22, 2018 at 11:10:24AM +0200, Peter Zijlstra wrote:
> On Tue, Aug 21, 2018 at 04:11:15PM -0400, Johannes Weiner wrote:
> > On Fri, Aug 03, 2018 at 07:21:39PM +0200, Peter Zijlstra wrote:
> > > On Wed, Aug 01, 2018 at 11:19:57AM -0400, Johannes Weiner wrote:
> > > > +			time = READ_ONCE(groupc->times[s]);
> > > > +			/*
> > > > +			 * In addition to already concluded states, we
> > > > +			 * also incorporate currently active states on
> > > > +			 * the CPU, since states may last for many
> > > > +			 * sampling periods.
> > > > +			 *
> > > > +			 * This way we keep our delta sampling buckets
> > > > +			 * small (u32) and our reported pressure close
> > > > +			 * to what's actually happening.
> > > > +			 */
> > > > +			if (test_state(groupc->tasks, cpu, s)) {
> > > > +				/*
> > > > +				 * We can race with a state change and
> > > > +				 * need to make sure the state_start
> > > > +				 * update is ordered against the
> > > > +				 * updates to the live state and the
> > > > +				 * time buckets (groupc->times).
> > > > +				 *
> > > > +				 * 1. If we observe task state that
> > > > +				 * needs to be recorded, make sure we
> > > > +				 * see state_start from when that
> > > > +				 * state went into effect or we'll
> > > > +				 * count time from the previous state.
> > > > +				 *
> > > > +				 * 2. If the time delta has already
> > > > +				 * been added to the bucket, make sure
> > > > +				 * we don't see it in state_start or
> > > > +				 * we'll count it twice.
> > > > +				 *
> > > > +				 * If the time delta is out of
> > > > +				 * state_start but not in the time
> > > > +				 * bucket yet, we'll miss it entirely
> > > > +				 * and handle it in the next period.
> > > > +				 */
> > > > +				smp_rmb();
> > > > +				time += cpu_clock(cpu) - groupc->state_start;
> > > > +			}
> > > 
> > > As is, groupc->state_start needs a READ_ONCE() above and a WRITE_ONCE()
> > > below. But like stated earlier, doing an update in scheduler_tick() is
> > > probably easier.
> > 
> > I've wrapped these in READ_ONCE/WRITE_ONCE.
> 
> I just realized, these are u64, so READ_ONCE/WRITE_ONCE will not work
> correct on 32bit.

Ah, right.

Actually, that race described in the comment above - "If the time
delta is out of state_start but not in the time bucket yet, we'll miss
it entirely and handle it in the next period" - can cause bogus time
samples if state persists for more than 2s. Because if we observed a
live state and included it in our private copy of the time bucket
(times_prev), missing the delta in transit to the time bucket in the
next aggregation results in times_prev being ahead of 'time', which
causes the delta to underflow into a bogusly large sample.

Memory barriers alone cannot guarantee full coherency here (neither
seeing the delta twice, nor missing it entirely) so I'm switching this
over to seqcount to make sure the aggregator sees something sensible.

And then I don't need the READ_ONCE/WRITE_ONCE.
