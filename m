Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 10 Dec 2018 17:20:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] kernel.h: Add non_block_start/end()
Message-ID: <20181210162010.GS1286@dhcp22.suse.cz>
References: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
 <20181210103641.31259-3-daniel.vetter@ffwll.ch>
 <20181210141337.GQ1286@dhcp22.suse.cz>
 <20181210144711.GN5289@hirez.programming.kicks-ass.net>
 <20181210150159.GR1286@dhcp22.suse.cz>
 <20181210152253.GP5289@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210152253.GP5289@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon 10-12-18 16:22:53, Peter Zijlstra wrote:
> On Mon, Dec 10, 2018 at 04:01:59PM +0100, Michal Hocko wrote:
> > On Mon 10-12-18 15:47:11, Peter Zijlstra wrote:
> > > On Mon, Dec 10, 2018 at 03:13:37PM +0100, Michal Hocko wrote:
> > > > I do not see any scheduler guys Cced and it would be really great to get
> > > > their opinion here.
> > > > 
> > > > On Mon 10-12-18 11:36:39, Daniel Vetter wrote:
> > > > > In some special cases we must not block, but there's not a
> > > > > spinlock, preempt-off, irqs-off or similar critical section already
> > > > > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > > > > pair to annotate these.
> > > > > 
> > > > > This will be used in the oom paths of mmu-notifiers, where blocking is
> > > > > not allowed to make sure there's forward progress.
> > > > 
> > > > Considering the only alternative would be to abuse
> > > > preempt_{disable,enable}, and that really has a different semantic, I
> > > > think this makes some sense. The cotext is preemptible but we do not
> > > > want notifier to sleep on any locks, WQ etc.
> > > 
> > > I'm confused... what is this supposed to do?
> > > 
> > > And what does 'block' mean here? Without preempt_disable/IRQ-off we're
> > > subject to regular preemption and execution can stall for arbitrary
> > > amounts of time.
> > 
> > The notifier is called from quite a restricted context - oom_reaper - 
> > which shouldn't depend on any locks or sleepable conditionals. 
> 
> You want to exclude spinlocks too? We could maybe frob something with
> lockdep if you need that?

Spinlocks are less of a problem because you cannot have a (in)direct
dependency on the page allocator that would deadlock. Spinlocks, or
preemption disabled in general should be short enough to guarantee a
forward progress.

> > The code
> > should be swift as well but we mostly do care about it to make a forward
> > progress. Checking for sleepable context is the best thing we could come
> > up with that would describe these demands at least partially.
> 
> OK, no real objections to the thing.  Just so long we're all on the same
> page as to what it does and doesn't do ;-)

I am not really sure whether there are other potential users besides
this one and whether the check as such is justified.

> I suppose you could extend the check to include schedule_debug() as
> well, maybe something like:

Do you mean to make the check cheaper?

> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index f66920173370..b1aaa278f1af 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3278,13 +3278,18 @@ static noinline void __schedule_bug(struct task_struct *prev)
>  /*
>   * Various schedule()-time debugging checks and statistics:
>   */
> -static inline void schedule_debug(struct task_struct *prev)
> +static inline void schedule_debug(struct task_struct *prev, bool preempt)
>  {
>  #ifdef CONFIG_SCHED_STACK_END_CHECK
>  	if (task_stack_end_corrupted(prev))
>  		panic("corrupted stack end detected inside scheduler\n");
>  #endif
>  
> +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> +	if (!preempt && prev->state && prev->non_block_count)
> +		// splat
> +#endif
> +
>  	if (unlikely(in_atomic_preempt_off())) {
>  		__schedule_bug(prev);
>  		preempt_count_set(PREEMPT_DISABLED);
> @@ -3391,7 +3396,7 @@ static void __sched notrace __schedule(bool preempt)
>  	rq = cpu_rq(cpu);
>  	prev = rq->curr;
>  
> -	schedule_debug(prev);
> +	schedule_debug(prev, preempt);
>  
>  	if (sched_feat(HRTICK))
>  		hrtick_clear(rq);

-- 
Michal Hocko
SUSE Labs
