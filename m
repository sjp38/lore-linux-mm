Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 700926B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 07:27:43 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 6so47204477pfd.6
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 04:27:43 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g70si4498575pfc.188.2017.03.01.04.27.40
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 04:27:42 -0800 (PST)
Date: Wed, 1 Mar 2017 21:27:23 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301122723.GK11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228181547.GM5680@worktop>
 <20170301072128.GH11663@X58A-UD3R>
 <20170301104328.GD6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
In-Reply-To: <20170301104328.GD6515@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Mar 01, 2017 at 11:43:28AM +0100, Peter Zijlstra wrote:
> On Wed, Mar 01, 2017 at 04:21:28PM +0900, Byungchul Park wrote:
> > On Tue, Feb 28, 2017 at 07:15:47PM +0100, Peter Zijlstra wrote:
> > > On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > > > +	/*
> > > > +	 * Each work of workqueue might run in a different context,
> > > > +	 * thanks to concurrency support of workqueue. So we have to
> > > > +	 * distinguish each work to avoid false positive.
> > > > +	 *
> > > > +	 * TODO: We can also add dependencies between two acquisitions
> > > > +	 * of different work_id, if they don't cause a sleep so make
> > > > +	 * the worker stalled.
> > > > +	 */
> > > > +	unsigned int		work_id;
> > > 
> > > > +/*
> > > > + * Crossrelease needs to distinguish each work of workqueues.
> > > > + * Caller is supposed to be a worker.
> > > > + */
> > > > +void crossrelease_work_start(void)
> > > > +{
> > > > +	if (current->xhlocks)
> > > > +		current->work_id++;
> > > > +}
> > > 
> > > So what you're trying to do with that 'work_id' thing is basically wipe
> > > the entire history when we're at the bottom of a context.
> > 
> > Sorry, but I do not understand what you are trying to say.
> > 
> > What I was trying to do with the 'work_id' is to distinguish between
> > different works, which will be used to check if history locks were held
> > in the same context as a release one.
> 
> The effect of changing work_id is that history disappears, yes? That is,
> by changing it, all our hist_locks don't match the context anymore and
> therefore we have no history.

Right. Now I understood your words.

> This is a useful operation.
> 
> You would want to do this at points where you know there will not be any
> dependencies on prior action, and typically at the same points we want
> to not be holding any locks.
> 
> Hence my term: 'bottom of a context', referring to an empty (held) lock
> stack.

Right.

> I would say this needs to be done for all 'work-queue' like things, and

Of course.

> there are quite a few outside of the obvious ones, smpboot threads and
> many other kthreads fall into this category.

Where can I check those?

> Similarly the return to userspace point that I already mentioned.
> 
> I would propose something like:
> 
> 	lockdep_assert_empty();
> 
> Or something similar, which would verify the lock stack is indeed empty
> and wipe our entire hist_lock buffer when cross-release is enabled.

Right. I should do that.

> > > Which is a useful operation, but should arguably also be done on the
> > > return to userspace path. Any historical lock from before the current
> > > syscall is irrelevant.

Let me think more. It looks not a simple problem.

> > 
> > Sorry. Could you explain it more?
> 
> Does the above make things clear?

Perfect. Thank you very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
