Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 321196B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 05:43:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j5so44542901pfb.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 02:43:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v26si4285656pfa.151.2017.03.01.02.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 02:43:28 -0800 (PST)
Date: Wed, 1 Mar 2017 11:43:28 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301104328.GD6515@twins.programming.kicks-ass.net>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228181547.GM5680@worktop>
 <20170301072128.GH11663@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301072128.GH11663@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Mar 01, 2017 at 04:21:28PM +0900, Byungchul Park wrote:
> On Tue, Feb 28, 2017 at 07:15:47PM +0100, Peter Zijlstra wrote:
> > On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > > +	/*
> > > +	 * Each work of workqueue might run in a different context,
> > > +	 * thanks to concurrency support of workqueue. So we have to
> > > +	 * distinguish each work to avoid false positive.
> > > +	 *
> > > +	 * TODO: We can also add dependencies between two acquisitions
> > > +	 * of different work_id, if they don't cause a sleep so make
> > > +	 * the worker stalled.
> > > +	 */
> > > +	unsigned int		work_id;
> > 
> > > +/*
> > > + * Crossrelease needs to distinguish each work of workqueues.
> > > + * Caller is supposed to be a worker.
> > > + */
> > > +void crossrelease_work_start(void)
> > > +{
> > > +	if (current->xhlocks)
> > > +		current->work_id++;
> > > +}
> > 
> > So what you're trying to do with that 'work_id' thing is basically wipe
> > the entire history when we're at the bottom of a context.
> 
> Sorry, but I do not understand what you are trying to say.
> 
> What I was trying to do with the 'work_id' is to distinguish between
> different works, which will be used to check if history locks were held
> in the same context as a release one.

The effect of changing work_id is that history disappears, yes? That is,
by changing it, all our hist_locks don't match the context anymore and
therefore we have no history.

This is a useful operation.

You would want to do this at points where you know there will not be any
dependencies on prior action, and typically at the same points we want
to not be holding any locks.

Hence my term: 'bottom of a context', referring to an empty (held) lock
stack.

I would say this needs to be done for all 'work-queue' like things, and
there are quite a few outside of the obvious ones, smpboot threads and
many other kthreads fall into this category.

Similarly the return to userspace point that I already mentioned.

I would propose something like:

	lockdep_assert_empty();

Or something similar, which would verify the lock stack is indeed empty
and wipe our entire hist_lock buffer when cross-release is enabled.

> > Which is a useful operation, but should arguably also be done on the
> > return to userspace path. Any historical lock from before the current
> > syscall is irrelevant.
> 
> Sorry. Could you explain it more?

Does the above make things clear?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
