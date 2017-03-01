Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 493136B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 00:17:26 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b2so42077178pgc.6
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 21:17:26 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b35si3644530plh.80.2017.02.28.21.17.24
        for <linux-mm@kvack.org>;
        Tue, 28 Feb 2017 21:17:25 -0800 (PST)
Date: Wed, 1 Mar 2017 14:17:07 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301051706.GD11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228154900.GL5680@worktop>
MIME-Version: 1.0
In-Reply-To: <20170228154900.GL5680@worktop>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Feb 28, 2017 at 04:49:00PM +0100, Peter Zijlstra wrote:
> On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> 
> > +struct cross_lock {
> > +	/*
> > +	 * When more than one acquisition of crosslocks are overlapped,
> > +	 * we do actual commit only when ref == 0.
> > +	 */
> > +	atomic_t ref;
> 
> That comment doesn't seem right, should that be: ref != 0 ?
> Also; would it not be much clearer to call this: nr_blocked, or waiters
> or something along those lines, because that is what it appears to be.
> 
> > +	/*
> > +	 * Seperate hlock instance. This will be used at commit step.
> > +	 *
> > +	 * TODO: Use a smaller data structure containing only necessary
> > +	 * data. However, we should make lockdep code able to handle the
> > +	 * smaller one first.
> > +	 */
> > +	struct held_lock	hlock;
> > +};
> 
> > +static int add_xlock(struct held_lock *hlock)
> > +{
> > +	struct cross_lock *xlock;
> > +	unsigned int gen_id;
> > +
> > +	if (!depend_after(hlock))
> > +		return 1;
> > +
> > +	if (!graph_lock())
> > +		return 0;
> > +
> > +	xlock = &((struct lockdep_map_cross *)hlock->instance)->xlock;
> > +
> > +	/*
> > +	 * When acquisitions for a xlock are overlapped, we use
> > +	 * a reference counter to handle it.
> 
> Handle what!? That comment is near empty.

I will add more comment so that it can fully descibe.

> 
> > +	 */
> > +	if (atomic_inc_return(&xlock->ref) > 1)
> > +		goto unlock;
> 
> So you set the xlock's generation only once, to the oldest blocking-on
> relation, which makes sense, you want to be able to related to all
> historical locks since.
> 
> > +
> > +	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
> > +	xlock->hlock = *hlock;
> > +	xlock->hlock.gen_id = gen_id;
> > +unlock:
> > +	graph_unlock();
> > +	return 1;
> > +}
> 
> > +void lock_commit_crosslock(struct lockdep_map *lock)
> > +{
> > +	struct cross_lock *xlock;
> > +	unsigned long flags;
> > +
> > +	if (!current->xhlocks)
> > +		return;
> > +
> > +	if (unlikely(current->lockdep_recursion))
> > +		return;
> > +
> > +	raw_local_irq_save(flags);
> > +	check_flags(flags);
> > +	current->lockdep_recursion = 1;
> > +
> > +	if (unlikely(!debug_locks))
> > +		return;
> > +
> > +	if (!graph_lock())
> > +		return;
> > +
> > +	xlock = &((struct lockdep_map_cross *)lock)->xlock;
> > +	if (atomic_read(&xlock->ref) > 0 && !commit_xhlocks(xlock))
> 
> You terminate with graph_lock() held.

Oops. What did I do? I'll fix it.

> 
> Also, I think you can do the atomic_read() outside of graph lock, to
> avoid taking graph_lock when its 0.

I'll do that if possible after thinking more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
