Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3E7E6B0297
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 23:05:25 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e132so56084079ite.19
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 20:05:25 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g8si17348168pfj.239.2017.04.23.20.05.23
        for <linux-mm@kvack.org>;
        Sun, 23 Apr 2017 20:05:24 -0700 (PDT)
Date: Mon, 24 Apr 2017 12:04:12 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170424030412.GG21430@X58A-UD3R>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419171954.tqp5tkxlsg4jp2xz@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
In-Reply-To: <20170419171954.tqp5tkxlsg4jp2xz@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Apr 19, 2017 at 07:19:54PM +0200, Peter Zijlstra wrote:
> On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> > +/*
> > + * Only access local task's data, so irq disable is only required.
> 
> A comment describing what it does; record a hist_lock entry; would be
> more useful.

Right. I will add it.

> > + */
> > +static void add_xhlock(struct held_lock *hlock)
> > +{
> > +	unsigned int idx = current->xhlock_idx++;
> > +	struct hist_lock *xhlock = &xhlock(idx);
> > +
> > +	/* Initialize hist_lock's members */
> > +	xhlock->hlock = *hlock;
> > +	xhlock->work_id = current->work_id;
> > +
> > +	xhlock->trace.nr_entries = 0;
> > +	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
> > +	xhlock->trace.entries = xhlock->trace_entries;
> > +	xhlock->trace.skip = 3;
> > +	save_stack_trace(&xhlock->trace);
> > +}
> 
> > +/*
> > + * This should be lockless as far as possible because this would be
> > + * called very frequently.
> 
> idem; explain why depend_before().

Right. I will add a comment on the following 'if' statement.

> > + */
> > +static void check_add_xhlock(struct held_lock *hlock)
> > +{
> 
> The other thing could be done like:
> 
> #ifdef CONFIG_DEBUG_LOCKDEP
> 	/*
> 	 * This can be done locklessly because its all task-local state,
> 	 * we must however ensure IRQs are disabled.
> 	 */
> 	WARN_ON_ONCE(!irqs_disabled());
> #endif

Yes. Much better.

> > +	if (!current->xhlocks || !depend_before(hlock))
> > +		return;
> > +
> > +	add_xhlock(hlock);
> > +}
> 
> 
> > +
> > +/*
> > + * For crosslock.
> > + */
> > +static int add_xlock(struct held_lock *hlock)
> > +{
> > +	struct cross_lock *xlock;
> > +	unsigned int gen_id;
> > +
> > +	if (!graph_lock())
> > +		return 0;
> > +
> > +	xlock = &((struct lockdep_map_cross *)hlock->instance)->xlock;
> > +
> > +	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
> > +	xlock->hlock = *hlock;
> > +	xlock->hlock.gen_id = gen_id;
> > +	graph_unlock();
> 
> What does graph_lock protect here?

Modifying xlock(not xhlock) instance should be protected with graph_lock.
Don't you think so?

> > +
> > +	return 1;
> > +}
> > +
> > +/*
> > + * return 0: Stop. Failed to acquire graph_lock.
> > + * return 1: Done. No more acquire ops is needed.
> > + * return 2: Need to do normal acquire operation.
> > + */
> > +static int lock_acquire_crosslock(struct held_lock *hlock)
> > +{
> > +	/*
> > +	 *	CONTEXT 1		CONTEXT 2
> > +	 *	---------		---------
> > +	 *	lock A (cross)
> > +	 *	X = atomic_inc_return(&cross_gen_id)
> > +	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > +	 *				Y = atomic_read_acquire(&cross_gen_id)
> > +	 *				lock B
> > +	 *
> > +	 * atomic_read_acquire() is for ordering between A and B,
> > +	 * IOW, A happens before B, when CONTEXT 2 see Y >= X.
> > +	 *
> > +	 * Pairs with atomic_inc_return() in add_xlock().
> > +	 */
> > +	hlock->gen_id = (unsigned int)atomic_read_acquire(&cross_gen_id);
> > +
> > +	if (cross_lock(hlock->instance))
> > +		return add_xlock(hlock);
> > +
> > +	check_add_xhlock(hlock);
> > +	return 2;
> > +}
> 
> So I was wondering WTH we'd call into this with a !xlock to begin with.
> 
> Maybe something like:
> 
> /*
>  * Called for both normal and crosslock acquires. Normal locks will be
>  * pushed on the hist_lock queue. Cross locks will record state and
>  * stop regular lock_acquire() to avoid being placed on the held_lock
>  * stack.
>  *
>  * Returns: 0 - failure;
>  *          1 - cross-lock, done;
>  *          2 - normal lock, continue to held_lock[].
>  */

Why not? I will replace my comment with yours.

> > +static int commit_xhlock(struct cross_lock *xlock, struct hist_lock *xhlock)
> > +{
> > +	unsigned int xid, pid;
> > +	u64 chain_key;
> > +
> > +	xid = xlock_class(xlock) - lock_classes;
> > +	chain_key = iterate_chain_key((u64)0, xid);
> > +	pid = xhlock_class(xhlock) - lock_classes;
> > +	chain_key = iterate_chain_key(chain_key, pid);
> > +
> > +	if (lookup_chain_cache(chain_key))
> > +		return 1;
> > +
> > +	if (!add_chain_cache_classes(xid, pid, xhlock->hlock.irq_context,
> > +				chain_key))
> > +		return 0;
> > +
> > +	if (!check_prev_add(current, &xlock->hlock, &xhlock->hlock, 1,
> > +			    &xhlock->trace, copy_trace))
> > +		return 0;
> > +
> > +	return 1;
> > +}
> > +
> > +static int commit_xhlocks(struct cross_lock *xlock)
> > +{
> > +	unsigned int cur = current->xhlock_idx;
> > +	unsigned int i;
> > +
> > +	if (!graph_lock())
> > +		return 0;
> > +
> > +	for (i = cur - 1; !xhlock_same(i, cur); i--) {
> > +		struct hist_lock *xhlock = &xhlock(i);
> 
> *blink*, you mean this?
> 
> 	for (i = 0; i < MAX_XHLOCKS_NR; i++) {
> 		struct hist_lock *xhlock = &xhlock(cur - i);

I will change the loop to this form.

> Except you seem to skip over the most recent element (@cur), why?

Currently 'cur' points to the next *free* slot.

> > +
> > +		if (!xhlock_used(xhlock))
> > +			break;
> > +
> > +		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
> > +			break;
> > +
> > +		if (same_context_xhlock(xhlock) &&
> > +		    !commit_xhlock(xlock, xhlock))
> 
> return with graph_lock held?

No. When commit_xhlock() returns 0, the lock was already unlocked.

> > +			return 0;
> > +	}
> > +
> > +	graph_unlock();
> > +	return 1;
> > +}
> > +
> > +void lock_commit_crosslock(struct lockdep_map *lock)
> > +{
> > +	struct cross_lock *xlock;
> > +	unsigned long flags;
> > +
> > +	if (unlikely(!debug_locks || current->lockdep_recursion))
> > +		return;
> > +
> > +	if (!current->xhlocks)
> > +		return;
> > +
> > +	/*
> > +	 * We have to check this here instead of in add_xlock(), since
> > +	 * otherwise invalid cross_lock might be accessed on commit. In
> > +	 * other words, building xlock in add_xlock() should not be
> > +	 * skipped in order to access valid cross_lock on commit.
> > +	 */
> > +	if (!depend_after(&((struct lockdep_map_cross *)lock)->xlock.hlock))
> > +		return;
> > +
> > +	raw_local_irq_save(flags);
> > +	check_flags(flags);
> > +	current->lockdep_recursion = 1;
> > +	xlock = &((struct lockdep_map_cross *)lock)->xlock;
> > +	commit_xhlocks(xlock);
> 
> We don't seem to use the return value much..

I will get rid of the return type.

Thank you very much.

> > +	current->lockdep_recursion = 0;
> > +	raw_local_irq_restore(flags);
> > +}
> > +EXPORT_SYMBOL_GPL(lock_commit_crosslock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
