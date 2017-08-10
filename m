Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4E56B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 21:25:46 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u199so81932136pgb.13
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 18:25:46 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q12si3363128pfc.34.2017.08.09.18.25.44
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 18:25:45 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:24:31 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 09/14] lockdep: Apply crossrelease to completions
Message-ID: <20170810012430.GV20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
 <20170809095107.2nzb4m4wq2p77ppb@hirez.programming.kicks-ass.net>
 <20170809102439.7ze32yrua4ieyswe@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809102439.7ze32yrua4ieyswe@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 09, 2017 at 12:24:39PM +0200, Peter Zijlstra wrote:
> On Wed, Aug 09, 2017 at 11:51:07AM +0200, Peter Zijlstra wrote:
> > On Mon, Aug 07, 2017 at 04:12:56PM +0900, Byungchul Park wrote:
> > > +static inline void wait_for_completion(struct completion *x)
> > > +{
> > > +	complete_acquire(x);
> > > +	__wait_for_completion(x);
> > > +	complete_release(x);
> > > +}
> > > +
> > > +static inline void wait_for_completion_io(struct completion *x)
> > > +{
> > > +	complete_acquire(x);
> > > +	__wait_for_completion_io(x);
> > > +	complete_release(x);
> > > +}
> > > +
> > > +static inline int wait_for_completion_interruptible(struct completion *x)
> > > +{
> > > +	int ret;
> > > +	complete_acquire(x);
> > > +	ret = __wait_for_completion_interruptible(x);
> > > +	complete_release(x);
> > > +	return ret;
> > > +}
> > > +
> > > +static inline int wait_for_completion_killable(struct completion *x)
> > > +{
> > > +	int ret;
> > > +	complete_acquire(x);
> > > +	ret = __wait_for_completion_killable(x);
> > > +	complete_release(x);
> > > +	return ret;
> > > +}
> > 
> > I don't understand, why not change __wait_for_common() ?
> 
> That is what is wrong with the below?
> 
> Yes, it adds acquire/release to the timeout variants too, but I don't

Yes, I didn't want to involve them in lockdep play which reports _deadlock_
warning since it's not a dependency causing a deadlock.

> see why we should exclude those, and even if we'd want to do that, it
> would be trivial:
> 
> 	bool timo = (timeout == MAX_SCHEDULE_TIMEOUT);
> 
> 	if (!timo)
> 		complete_acquire(x);
> 
> 	/* ... */
> 
> 	if (!timo)
> 		complete_release(x);

Yes, frankly I wanted to use this.. but skip it.

> But like said, I think we very much want to annotate waits with timeouts
> too. Hitting the max timo doesn't necessarily mean we'll make fwd
> progress, we could be stuck in a loop doing something else again before
> returning to wait.

In that case, it should be detected by other dependencies which makes
problems, not the dependency by wait_for_complete().

> Also, even if we'd make fwd progress, hitting that max timo is still not
> desirable.

It's not desirable but it's not a dependency causing a deadlock, so I did
not want to _deadlock_ warning in that cases.. I didn't want to abuse
lockdep reports..

However, it's OK if you think it's worth warning even in that cases.

Thank you very much,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
