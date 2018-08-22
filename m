Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 090EE6B238F
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:10:34 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 132-v6so773124pga.18
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:10:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t10-v6si1077641plz.414.2018.08.22.02.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 02:10:32 -0700 (PDT)
Date: Wed, 22 Aug 2018 11:10:24 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180822091024.GU24124@hirez.programming.kicks-ass.net>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803172139.GE2494@hirez.programming.kicks-ass.net>
 <20180821201115.GB24538@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821201115.GB24538@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Aug 21, 2018 at 04:11:15PM -0400, Johannes Weiner wrote:
> On Fri, Aug 03, 2018 at 07:21:39PM +0200, Peter Zijlstra wrote:
> > On Wed, Aug 01, 2018 at 11:19:57AM -0400, Johannes Weiner wrote:
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
> > As is, groupc->state_start needs a READ_ONCE() above and a WRITE_ONCE()
> > below. But like stated earlier, doing an update in scheduler_tick() is
> > probably easier.
> 
> I've wrapped these in READ_ONCE/WRITE_ONCE.

I just realized, these are u64, so READ_ONCE/WRITE_ONCE will not work
correct on 32bit.
