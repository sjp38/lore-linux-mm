Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2C66B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 21:05:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so39164400pge.5
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 18:05:50 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id c8si2723736pfj.54.2017.01.16.18.05.48
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 18:05:48 -0800 (PST)
Date: Tue, 17 Jan 2017 11:05:42 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Message-ID: <20170117020541.GF3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-8-git-send-email-byungchul.park@lge.com>
 <20170116151001.GD3144@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170116151001.GD3144@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Mon, Jan 16, 2017 at 04:10:01PM +0100, Peter Zijlstra wrote:
> On Fri, Dec 09, 2016 at 02:12:03PM +0900, Byungchul Park wrote:
> 
> > @@ -143,6 +149,9 @@ struct lock_class_stats lock_stats(struct lock_class *class);
> >  void clear_lock_stats(struct lock_class *class);
> >  #endif
> >  
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +struct cross_lock;
> > +#endif
> 
> That seems like pointless wrappery, unused (fwd) declarations are
> harmless.

OK.

> >  /*
> >   * Map the lock object (the lock instance) to the lock-class object.
> >   * This is embedded into specific lock instances:
> > @@ -155,6 +164,9 @@ struct lockdep_map {
> >  	int				cpu;
> >  	unsigned long			ip;
> >  #endif
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +	struct cross_lock		*xlock;
> > +#endif
> 
> The use of this escapes me; why does the lockdep_map need a pointer to
> this?

Lockdep interfaces e.g. lock_acquire(), lock_release() and lock_commit()
use lockdep_map as an arg, but crossrelease need to extract cross_lock
instances from that.

> 
> >  };
> >  
> >  static inline void lockdep_copy_map(struct lockdep_map *to,
> > @@ -258,7 +270,82 @@ struct held_lock {
> >  	unsigned int hardirqs_off:1;
> >  	unsigned int references:12;					/* 32 bits */
> >  	unsigned int pin_count;
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +	/*
> > +	 * This is used to find out the first plock among plocks having
> > +	 * been acquired since a crosslock was held. Crossrelease feature
> > +	 * uses chain cache between the crosslock and the first plock to
> > +	 * avoid building unnecessary dependencies, like how lockdep uses
> > +	 * a sort of chain cache for normal locks.
> > +	 */
> > +	unsigned int gen_id;
> > +#endif
> > +};
> 
> Makes sense, except we'll have a bunch of different generation numbers
> (see below), so I think it makes sense to name it more explicitly.

Right. I will try it.

> > +
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +#define MAX_PLOCK_TRACE_ENTRIES		5
> 
> Why 5? ;-)

What nr are you recommanding to store one stack_trace?

> 
> > +/*
> > + * This is for keeping locks waiting for commit to happen so that
> > + * dependencies are actually built later at commit step.
> > + *
> > + * Every task_struct has an array of pend_lock. Each entiry will be
> > + * added with a lock whenever lock_acquire() is called for normal lock.
> > + */
> > +struct pend_lock {
> 
> Like said before, I'm not sure "pending" is the right word, we track
> locks that have very much been released. Would something like "lock
> history" make more sense?

Good idea. But I want to avoid using 'h'istory lock because it could be
confused with 'h'eld lock when I call something like hlock_class(). But
I will use "lock history" if I cannot find better words. What about
"logged lock"?

> 
> > +	/*
> > +	 * prev_gen_id is used to check whether any other hlock in the
> > +	 * current is already dealing with the xlock, with which commit
> > +	 * is performed. If so, this plock can be skipped.
> > +	 */
> > +	unsigned int		prev_gen_id;
> 
> Confused..

Sorry. My explanation is insufficient. I will try to make it sufficient.

For example,

Context X
---------
gen_id : 10 when acquiring AX (crosslock)

Context Y
---------
gen_id : 9 when acquiring B
gen_id : 12 when acquiring C (Original lockdep adds B -> C)
gen_id : 15 when acquiring D (Original lockdep adds C -> D)
gen_id : 19 when acquiring E (Original lockdep adds D -> E)
release AX <- focus here!
(will release E, D, C and B in future..)

In this situation, it's enough to connect only AX and C, "AX -> C".
"AX -> D" and "AX -> E" are unnecessary because it can be covered by
"AX -> C", "C -> D" and "D -> E", even though "AX -> D" and "AX -> E"
are also true dependencies, but unnecessary.

To handle this optimization, I decided to keep prev_gen_id in pend_lock
which stores gen_id of the previous lock in held_locks so that I can
decide whether the previous lock can be handled with the xlock. If so,
I can skip this dependency because this can be covered by
"the xlock -> the previous lock" and "the previous lock -> current lock".

> 
> > +	/*
> > +	 * A kind of global timestamp increased and set when this plock
> > +	 * is inserted.

Sorry. This comment is wrong. I will fix it. This should be,

"This will be set to a value of a global timestamp, cross_gen_id, when
inserting this plock."

> > +	 */
> > +	unsigned int		gen_id;
> 
> Right, except you also have pend_lock::hlock::gen_id, which I think is
> the very same generation number, no?

pend_lock::gen_id is equal to or greater than pend_lock::hlock::gen_id
because atomic_inc_return(&cross_gen_id) can happen between these two
stores.

pend_lock::gen_id is used to compare with cross_lock::gen_id when
identifying dependencies.

held_lock::gen_id is used to decide whether the previous lock in held_locks
can handle necessary dependencies on behalf of current lock.

> > +
> > +	int			hardirq_context;
> > +	int			softirq_context;
> 
> This would fit in 2 bit, why do you use 8 bytes?

Right. 2 bits are enough. I will change it.

> 
> > +
> > +	/*
> > +	 * Whenever irq happens, these are updated so that we can
> > +	 * distinguish each irq context uniquely.
> > +	 */
> > +	unsigned int		hardirq_id;
> > +	unsigned int		softirq_id;
> 
> An alternative approach would be to 'unwind' or discard all historical
> events from a nested context once we exit it.

That's one of what I considered. However, it would make code complex to
detect if pend_lock ring buffer was wrapped.

> 
> After all, all we care about is the history of the release context, once
> the context is gone, we don't care.

We must care it and decide if the next plock in the ring buffer might be
valid one or not.

> 
> > +
> > +	/*
> > +	 * Seperate stack_trace data. This will be used at commit step.
> > +	 */
> > +	struct stack_trace	trace;
> > +	unsigned long		trace_entries[MAX_PLOCK_TRACE_ENTRIES];
> > +
> > +	/*
> > +	 * Seperate hlock instance. This will be used at commit step.
> > +	 */
> > +	struct held_lock	hlock;
> > +};
> > +
> > +/*
> > + * One cross_lock per one lockdep_map.
> > + *
> > + * To initialize a lock as crosslock, lockdep_init_map_crosslock() should
> > + * be used instead of lockdep_init_map(), where the pointer of cross_lock
> > + * instance should be passed as a parameter.
> > + */
> > +struct cross_lock {
> > +	unsigned int		gen_id;
> 
> Again, you already have hlock::gen_id for this, no?

(Not implemented yet though) To add "xlock -> xlock", xlock should be both a
pend_lock and a cross_lock.

hlock::gen_id should have the time holding it to decide representative locks
among held_locks to handle dependencies in a optimized way.

xlock::gen_id should have increased value when acquiring crosslock and be
used to compare with plock::gen_id and decide true dependencies.

I think both are necessary.

> > +	struct list_head	xlock_entry;
> > +
> > +	/*
> > +	 * Seperate hlock instance. This will be used at commit step.
> > +	 */
> > +	struct held_lock	hlock;
> > +
> > +	int			ref; /* reference count */
> >  };
> 
> Why not do something like:
> 
> struct lockdep_map_cross {
> 	struct lockdep_map	map;
> 	struct held_lock	hlock;
> }
> 
> That saves at least that pointer.
> 
> But I still have to figure out why we need this hlock.
> 
> Also note that a full hlock contains superfluous information:
> 
>  - prev_chain_key; not required, we can compute the 2 entry chain hash
>  		   on demand when we need.
>  - instance: we already have the lockdep_map right here, pointers to
>  	     self are kinda pointless
>  - nest_lock: not sure that makes sense wrt this stuff.
>  - class_idx: can recompute if we have lockdep_map
>  - reference: see nest_lock

I agree with you. I will try to extract only necessary fields from hlock
and remove held_lock from xlock.

> 
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 253538f..592ee368 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1719,6 +1719,11 @@ struct task_struct {
> >  	struct held_lock held_locks[MAX_LOCK_DEPTH];
> >  	gfp_t lockdep_reclaim_gfp;
> >  #endif
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +#define MAX_PLOCKS_NR 1024UL
> > +	int plock_index;
> > +	struct pend_lock *plocks;
> > +#endif
> 
> That's a giant heap of memory.. why 1024?

Could you recommand the nr which is the size of ring buffer for plocks?

> 
> 
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index 4a7ec0c..91ab81b 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> 
> > @@ -1443,6 +1451,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
> >  	p->lockdep_depth = 0; /* no locks held yet */
> >  	p->curr_chain_key = 0;
> >  	p->lockdep_recursion = 0;
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +	p->plock_index = 0;
> > +	p->plocks = vzalloc(sizeof(struct pend_lock) * MAX_PLOCKS_NR);
> 
> And while I understand why you need vmalloc for that amount of memory,
> do realize that on 32bit kernels you'll very quickly run out of space
> this way.

OK. I also think it should be smaller. Please recommand proper nr.

> That pend_lock thing could maybe be shrunk to 128 bytes, at which point
> you can fit 64 in two pages, is that not sufficient?

Do you think 64 is sufficient? I will apply it. Actually the size is not
much important, it only causes missing some dependencies. By the way, I
forgot how much nr was used while running crossrelease. I will check it
again and let you know.

> 
> 
> > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > index 11580ec..2c8b2c1 100644
> > --- a/kernel/locking/lockdep.c
> > +++ b/kernel/locking/lockdep.c
> 
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +
> > +static LIST_HEAD(xlocks_head);
> 
> Still not explanation for what this list is for...

This is for tracking crosslocks in progress so that crossrelase can
decide gen_id_done. Is there other ways?

Actually every thing becomes simple if ring buffer was not used. But
I think I should use ring buffer for plocks. Any alternatives?

> 
> > +
> > +/*
> > + * Whenever a crosslock is held, cross_gen_id will be increased.
> > + */
> > +static atomic_t cross_gen_id; /* Can be wrapped */
> > +
> > +/* Implement a circular buffer - for internal use */
> > +#define cir_p(n, i)		((i) ? (i) - 1 : (n) - 1)
> 
> This is broken, I think you'll want something like: (((i)-1) % (n))

This is not broken because 0 <= i < MAX_PLOCKS_NR. And the result must be
MAX_PLOCKS_NR - 1 when i = 0. What you recommand provides wrong result.

> 
> > +#define cir_n(n, i)		((i) == (n) - 1 ? 0 : (i) + 1)
> 
> Idem

I can change this as you recommand.

> 
> > +/*
> > + * Crossrelease needs to distinguish each hardirq context.
> > + */
> > +static DEFINE_PER_CPU(unsigned int, hardirq_id);
> > +void crossrelease_hardirq_start(void)
> > +{
> > +	per_cpu(hardirq_id, smp_processor_id())++;
> > +}
> > +
> > +/*
> > + * Crossrelease needs to distinguish each softirq context.
> > + */
> > +static DEFINE_PER_CPU(unsigned int, softirq_id);
> > +void crossrelease_softirq_start(void)
> > +{
> > +	per_cpu(softirq_id, smp_processor_id())++;
> > +}
> 
> See above, I don't think we need to retain the plock stuff once a
> context finishes, and therefore we don't need context generation numbers
> to differentiate them.

I stongly want to implement as you recommand. But it makes ring buffer
implementation difficult. Unwinding when finishing nested contexts needs
some more jobs to distinguish between wrapped case and unwinded case.
If you prefer the latter, then I will re-work to replace the former way
with the latter.

> 
> > +/*
> > + * To find the earlist crosslock among all crosslocks not released yet.
> > + */
> > +static unsigned int gen_id_begin(void)
> > +{
> > +	struct cross_lock *xlock = list_entry_rcu(xlocks_head.next,
> > +			struct cross_lock, xlock_entry);
> > +
> > +	/* If empty */
> > +	if (&xlock->xlock_entry == &xlocks_head)
> > +		return (unsigned int)atomic_read(&cross_gen_id) + 1;
> > +
> > +	return READ_ONCE(xlock->gen_id);
> > +}
> > +
> > +/*
> > + * To find the latest crosslock among all crosslocks already released.
> > + */
> > +static inline unsigned int gen_id_done(void)
> > +{
> > +	return gen_id_begin() - 1;
> > +}
> 
> I'm not sure about these... if you increment the generation count on any
> cross action (both acquire and release) and tag all hlocks with the
> current reading, you have all the ordering required, no?

This is for implementing ring buffer to distinguish between plock entries,
whether it is in progress or finished. This might be removed if we just
overwrite plocks when overflowing the ring. It seems to be better. I will
change it so that crossrelease just overwrite old ones when overflowing.

And I will remove gen_id_begin() and gen_id_done(). Let me check it.

> 
> > +/*
> > + * No contention. Irq disable is only required.
> > + */
> > +static void add_plock(struct held_lock *hlock, unsigned int prev_gen_id,
> > +		unsigned int gen_id_done)
> > +{
> > +	struct task_struct *curr = current;
> > +	int cpu = smp_processor_id();
> > +	struct pend_lock *plock;
> > +	/*
> > +	 *	CONTEXT 1		CONTEXT 2
> > +	 *	---------		---------
> > +	 *	acquire A (cross)
> > +	 *	X = atomic_inc_return()
> > +	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ serialize
> > +	 *				Y = atomic_read_acquire()
> > +	 *				acquire B
> > +	 *				acquire C
> > +	 *
> > +	 * For ordering between this and all following LOCKs.
> > +	 * This way we ensure the order A -> B -> C when CONTEXT 2
> > +	 * can see Y is equal to or greater than X.
> > +	 *
> > +	 * Pairs with atomic_inc_return() in add_xlock().
> > +	 */
> > +	unsigned int gen_id = (unsigned int)atomic_read_acquire(&cross_gen_id);
> 
> fails to explain why this is important.

It's important if context 2 can see acquire A when acquiring B, because it
has a dependency only in that case. So I needed to prove it via
RELEASE-ACQUIRE of cross_gen_id. Wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
