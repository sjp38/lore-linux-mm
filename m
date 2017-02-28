Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A00756B0387
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:49:10 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x66so17591243pfb.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:49:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v18si2092475pge.225.2017.02.28.07.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 07:49:09 -0800 (PST)
Date: Tue, 28 Feb 2017 16:49:00 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228154900.GL5680@worktop>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:

> +struct cross_lock {
> +	/*
> +	 * When more than one acquisition of crosslocks are overlapped,
> +	 * we do actual commit only when ref == 0.
> +	 */
> +	atomic_t ref;

That comment doesn't seem right, should that be: ref != 0 ?

Also; would it not be much clearer to call this: nr_blocked, or waiters
or something along those lines, because that is what it appears to be.

> +	/*
> +	 * Seperate hlock instance. This will be used at commit step.
> +	 *
> +	 * TODO: Use a smaller data structure containing only necessary
> +	 * data. However, we should make lockdep code able to handle the
> +	 * smaller one first.
> +	 */
> +	struct held_lock	hlock;
> +};

> +static int add_xlock(struct held_lock *hlock)
> +{
> +	struct cross_lock *xlock;
> +	unsigned int gen_id;
> +
> +	if (!depend_after(hlock))
> +		return 1;
> +
> +	if (!graph_lock())
> +		return 0;
> +
> +	xlock = &((struct lockdep_map_cross *)hlock->instance)->xlock;
> +
> +	/*
> +	 * When acquisitions for a xlock are overlapped, we use
> +	 * a reference counter to handle it.

Handle what!? That comment is near empty.

> +	 */
> +	if (atomic_inc_return(&xlock->ref) > 1)
> +		goto unlock;

So you set the xlock's generation only once, to the oldest blocking-on
relation, which makes sense, you want to be able to related to all
historical locks since.

> +
> +	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
> +	xlock->hlock = *hlock;
> +	xlock->hlock.gen_id = gen_id;
> +unlock:
> +	graph_unlock();
> +	return 1;
> +}

> +void lock_commit_crosslock(struct lockdep_map *lock)
> +{
> +	struct cross_lock *xlock;
> +	unsigned long flags;
> +
> +	if (!current->xhlocks)
> +		return;
> +
> +	if (unlikely(current->lockdep_recursion))
> +		return;
> +
> +	raw_local_irq_save(flags);
> +	check_flags(flags);
> +	current->lockdep_recursion = 1;
> +
> +	if (unlikely(!debug_locks))
> +		return;
> +
> +	if (!graph_lock())
> +		return;
> +
> +	xlock = &((struct lockdep_map_cross *)lock)->xlock;
> +	if (atomic_read(&xlock->ref) > 0 && !commit_xhlocks(xlock))

You terminate with graph_lock() held.

Also, I think you can do the atomic_read() outside of graph lock, to
avoid taking graph_lock when its 0.

> +		return;
> +
> +	graph_unlock();
> +	current->lockdep_recursion = 0;
> +	raw_local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL_GPL(lock_commit_crosslock);
> +
> +/*
> + * return 0: Need to do normal release operation.
> + * return 1: Done. No more release ops is needed.
> + */
> +static int lock_release_crosslock(struct lockdep_map *lock)
> +{
> +	if (cross_lock(lock)) {
> +		atomic_dec(&((struct lockdep_map_cross *)lock)->xlock.ref);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static void cross_init(struct lockdep_map *lock, int cross)
> +{
> +	if (cross)
> +		atomic_set(&((struct lockdep_map_cross *)lock)->xlock.ref, 0);
> +
> +	lock->cross = cross;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
