Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5FD6B02C1
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 01:12:13 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g66so58820095ite.0
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 22:12:13 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 90si17616950pla.275.2017.04.23.22.12.11
        for <linux-mm@kvack.org>;
        Sun, 23 Apr 2017 22:12:12 -0700 (PDT)
Date: Mon, 24 Apr 2017 14:11:02 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170424051102.GJ21430@X58A-UD3R>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419142503.rqsrgjlc7ump7ijb@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419142503.rqsrgjlc7ump7ijb@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Apr 19, 2017 at 04:25:03PM +0200, Peter Zijlstra wrote:
> On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> > +struct hist_lock {
> > +	/*
> > +	 * Each work of workqueue might run in a different context,
> > +	 * thanks to concurrency support of workqueue. So we have to
> > +	 * distinguish each work to avoid false positive.
> > +	 */
> > +	unsigned int		work_id;
> >  };
> 
> > @@ -1749,6 +1749,14 @@ struct task_struct {
> >  	struct held_lock held_locks[MAX_LOCK_DEPTH];
> >  	gfp_t lockdep_reclaim_gfp;
> >  #endif
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +#define MAX_XHLOCKS_NR 64UL
> > +	struct hist_lock *xhlocks; /* Crossrelease history locks */
> > +	unsigned int xhlock_idx;
> > +	unsigned int xhlock_idx_soft; /* For backing up at softirq entry */
> > +	unsigned int xhlock_idx_hard; /* For backing up at hardirq entry */
> > +	unsigned int work_id;
> > +#endif
> >  #ifdef CONFIG_UBSAN
> >  	unsigned int in_ubsan;
> >  #endif
> 
> > +/*
> > + * Crossrelease needs to distinguish each work of workqueues.
> > + * Caller is supposed to be a worker.
> > + */
> > +void crossrelease_work_start(void)
> > +{
> > +	if (current->xhlocks)
> > +		current->work_id++;
> > +}
> 
> > +/*
> > + * Only access local task's data, so irq disable is only required.
> > + */
> > +static int same_context_xhlock(struct hist_lock *xhlock)
> > +{
> > +	struct task_struct *curr = current;
> > +
> > +	/* In the case of hardirq context */
> > +	if (curr->hardirq_context) {
> > +		if (xhlock->hlock.irq_context & 2) /* 2: bitmask for hardirq */
> > +			return 1;
> > +	/* In the case of softriq context */
> > +	} else if (curr->softirq_context) {
> > +		if (xhlock->hlock.irq_context & 1) /* 1: bitmask for softirq */
> > +			return 1;
> > +	/* In the case of process context */
> > +	} else {
> > +		if (xhlock->work_id == curr->work_id)
> > +			return 1;
> > +	}
> > +	return 0;
> > +}
> 
> I still don't like work_id; it doesn't have anything to do with
> workqueues per se, other than the fact that they end up using it.
> 
> It's a history generation id; touching it completely invalidates our
> history. Workqueues need this because they run independent work from the
> same context.
> 
> But the same is true for other sites. Last time I suggested
> lockdep_assert_empty() to denote all suck places (and note we already
> have lockdep_sys_exit() that hooks into the return to user path).

I'm sorry but I don't understand what you intend. It would be appriciated
if you explain more.

You might know why I introduced the 'work_id'.. Is there any alternative?

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
