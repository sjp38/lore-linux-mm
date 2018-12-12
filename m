Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6B9A8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 05:27:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so8429489edc.9
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 02:27:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b27sor9648066edn.5.2018.12.12.02.26.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 02:27:00 -0800 (PST)
Date: Wed, 12 Dec 2018 11:26:56 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 2/4] kernel.h: Add non_block_start/end()
Message-ID: <20181212102656.GS21184@phenom.ffwll.local>
References: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
 <20181210103641.31259-3-daniel.vetter@ffwll.ch>
 <20181210141337.GQ1286@dhcp22.suse.cz>
 <20181210144711.GN5289@hirez.programming.kicks-ass.net>
 <20181210150159.GR1286@dhcp22.suse.cz>
 <20181210152253.GP5289@hirez.programming.kicks-ass.net>
 <20181210162010.GS1286@dhcp22.suse.cz>
 <20181210163009.GR5289@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210163009.GR5289@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Mon, Dec 10, 2018 at 05:30:09PM +0100, Peter Zijlstra wrote:
> On Mon, Dec 10, 2018 at 05:20:10PM +0100, Michal Hocko wrote:
> > > OK, no real objections to the thing.  Just so long we're all on the same
> > > page as to what it does and doesn't do ;-)
> > 
> > I am not really sure whether there are other potential users besides
> > this one and whether the check as such is justified.
> 
> It's a debug option...
> 
> > > I suppose you could extend the check to include schedule_debug() as
> > > well, maybe something like:
> > 
> > Do you mean to make the check cheaper?
> 
> Nah, so the patch only touched might_sleep(), the below touches
> schedule().
> 
> If there were a patch that hits schedule() without going through a
> might_sleep() (rare in practise I think, but entirely possible) then you
> won't get a splat without something like the below on top.

We have a bunch of schedule() calls in i915, for e.g. waiting for multiple
events at the same time (when we want to unblock if any of them fire). And
there's no might_sleep in these cases afaict. Adding the check in
schedule() sounds useful, I'll include your snippet in v2. Plus try a bit
better to explain in the commit message why Michal suggested these.

Thanks, Daniel

> 
> > > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > > index f66920173370..b1aaa278f1af 100644
> > > --- a/kernel/sched/core.c
> > > +++ b/kernel/sched/core.c
> > > @@ -3278,13 +3278,18 @@ static noinline void __schedule_bug(struct task_struct *prev)
> > >  /*
> > >   * Various schedule()-time debugging checks and statistics:
> > >   */
> > > -static inline void schedule_debug(struct task_struct *prev)
> > > +static inline void schedule_debug(struct task_struct *prev, bool preempt)
> > >  {
> > >  #ifdef CONFIG_SCHED_STACK_END_CHECK
> > >  	if (task_stack_end_corrupted(prev))
> > >  		panic("corrupted stack end detected inside scheduler\n");
> > >  #endif
> > >  
> > > +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> > > +	if (!preempt && prev->state && prev->non_block_count)
> > > +		// splat
> > > +#endif
> > > +
> > >  	if (unlikely(in_atomic_preempt_off())) {
> > >  		__schedule_bug(prev);
> > >  		preempt_count_set(PREEMPT_DISABLED);
> > > @@ -3391,7 +3396,7 @@ static void __sched notrace __schedule(bool preempt)
> > >  	rq = cpu_rq(cpu);
> > >  	prev = rq->curr;
> > >  
> > > -	schedule_debug(prev);
> > > +	schedule_debug(prev, preempt);
> > >  
> > >  	if (sched_feat(HRTICK))
> > >  		hrtick_clear(rq);
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
