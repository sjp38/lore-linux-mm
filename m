Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2EF46B03A1
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 13:20:00 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id u70so12816277ywe.22
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 10:20:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 63si3336473pgi.231.2017.04.19.10.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 10:19:59 -0700 (PDT)
Date: Wed, 19 Apr 2017 19:19:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170419171954.tqp5tkxlsg4jp2xz@hirez.programming.kicks-ass.net>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> +/*
> + * Only access local task's data, so irq disable is only required.

A comment describing what it does; record a hist_lock entry; would be
more useful.

> + */
> +static void add_xhlock(struct held_lock *hlock)
> +{
> +	unsigned int idx = current->xhlock_idx++;
> +	struct hist_lock *xhlock = &xhlock(idx);
> +
> +	/* Initialize hist_lock's members */
> +	xhlock->hlock = *hlock;
> +	xhlock->work_id = current->work_id;
> +
> +	xhlock->trace.nr_entries = 0;
> +	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
> +	xhlock->trace.entries = xhlock->trace_entries;
> +	xhlock->trace.skip = 3;
> +	save_stack_trace(&xhlock->trace);
> +}

> +/*
> + * This should be lockless as far as possible because this would be
> + * called very frequently.

idem; explain why depend_before().

> + */
> +static void check_add_xhlock(struct held_lock *hlock)
> +{

The other thing could be done like:

#ifdef CONFIG_DEBUG_LOCKDEP
	/*
	 * This can be done locklessly because its all task-local state,
	 * we must however ensure IRQs are disabled.
	 */
	WARN_ON_ONCE(!irqs_disabled());
#endif

> +	if (!current->xhlocks || !depend_before(hlock))
> +		return;
> +
> +	add_xhlock(hlock);
> +}


> +
> +/*
> + * For crosslock.
> + */
> +static int add_xlock(struct held_lock *hlock)
> +{
> +	struct cross_lock *xlock;
> +	unsigned int gen_id;
> +
> +	if (!graph_lock())
> +		return 0;
> +
> +	xlock = &((struct lockdep_map_cross *)hlock->instance)->xlock;
> +
> +	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
> +	xlock->hlock = *hlock;
> +	xlock->hlock.gen_id = gen_id;
> +	graph_unlock();

What does graph_lock protect here?

> +
> +	return 1;
> +}
> +
> +/*
> + * return 0: Stop. Failed to acquire graph_lock.
> + * return 1: Done. No more acquire ops is needed.
> + * return 2: Need to do normal acquire operation.
> + */
> +static int lock_acquire_crosslock(struct held_lock *hlock)
> +{
> +	/*
> +	 *	CONTEXT 1		CONTEXT 2
> +	 *	---------		---------
> +	 *	lock A (cross)
> +	 *	X = atomic_inc_return(&cross_gen_id)
> +	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> +	 *				Y = atomic_read_acquire(&cross_gen_id)
> +	 *				lock B
> +	 *
> +	 * atomic_read_acquire() is for ordering between A and B,
> +	 * IOW, A happens before B, when CONTEXT 2 see Y >= X.
> +	 *
> +	 * Pairs with atomic_inc_return() in add_xlock().
> +	 */
> +	hlock->gen_id = (unsigned int)atomic_read_acquire(&cross_gen_id);
> +
> +	if (cross_lock(hlock->instance))
> +		return add_xlock(hlock);
> +
> +	check_add_xhlock(hlock);
> +	return 2;
> +}

So I was wondering WTH we'd call into this with a !xlock to begin with.

Maybe something like:

/*
 * Called for both normal and crosslock acquires. Normal locks will be
 * pushed on the hist_lock queue. Cross locks will record state and
 * stop regular lock_acquire() to avoid being placed on the held_lock
 * stack.
 *
 * Returns: 0 - failure;
 *          1 - cross-lock, done;
 *          2 - normal lock, continue to held_lock[].
 */


> +static int commit_xhlock(struct cross_lock *xlock, struct hist_lock *xhlock)
> +{
> +	unsigned int xid, pid;
> +	u64 chain_key;
> +
> +	xid = xlock_class(xlock) - lock_classes;
> +	chain_key = iterate_chain_key((u64)0, xid);
> +	pid = xhlock_class(xhlock) - lock_classes;
> +	chain_key = iterate_chain_key(chain_key, pid);
> +
> +	if (lookup_chain_cache(chain_key))
> +		return 1;
> +
> +	if (!add_chain_cache_classes(xid, pid, xhlock->hlock.irq_context,
> +				chain_key))
> +		return 0;
> +
> +	if (!check_prev_add(current, &xlock->hlock, &xhlock->hlock, 1,
> +			    &xhlock->trace, copy_trace))
> +		return 0;
> +
> +	return 1;
> +}
> +
> +static int commit_xhlocks(struct cross_lock *xlock)
> +{
> +	unsigned int cur = current->xhlock_idx;
> +	unsigned int i;
> +
> +	if (!graph_lock())
> +		return 0;
> +
> +	for (i = cur - 1; !xhlock_same(i, cur); i--) {
> +		struct hist_lock *xhlock = &xhlock(i);

*blink*, you mean this?

	for (i = 0; i < MAX_XHLOCKS_NR; i++) {
		struct hist_lock *xhlock = &xhlock(cur - i);

Except you seem to skip over the most recent element (@cur), why?

> +
> +		if (!xhlock_used(xhlock))
> +			break;
> +
> +		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
> +			break;
> +
> +		if (same_context_xhlock(xhlock) &&
> +		    !commit_xhlock(xlock, xhlock))

return with graph_lock held?

> +			return 0;
> +	}
> +
> +	graph_unlock();
> +	return 1;
> +}
> +
> +void lock_commit_crosslock(struct lockdep_map *lock)
> +{
> +	struct cross_lock *xlock;
> +	unsigned long flags;
> +
> +	if (unlikely(!debug_locks || current->lockdep_recursion))
> +		return;
> +
> +	if (!current->xhlocks)
> +		return;
> +
> +	/*
> +	 * We have to check this here instead of in add_xlock(), since
> +	 * otherwise invalid cross_lock might be accessed on commit. In
> +	 * other words, building xlock in add_xlock() should not be
> +	 * skipped in order to access valid cross_lock on commit.
> +	 */
> +	if (!depend_after(&((struct lockdep_map_cross *)lock)->xlock.hlock))
> +		return;
> +
> +	raw_local_irq_save(flags);
> +	check_flags(flags);
> +	current->lockdep_recursion = 1;
> +	xlock = &((struct lockdep_map_cross *)lock)->xlock;
> +	commit_xhlocks(xlock);

We don't seem to use the return value much..

> +	current->lockdep_recursion = 0;
> +	raw_local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL_GPL(lock_commit_crosslock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
