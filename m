Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6131D6B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 02:21:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j5so39488520pfb.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 23:21:44 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r15si3874788pli.158.2017.02.28.23.21.42
        for <linux-mm@kvack.org>;
        Tue, 28 Feb 2017 23:21:43 -0800 (PST)
Date: Wed, 1 Mar 2017 16:21:28 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301072128.GH11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228181547.GM5680@worktop>
MIME-Version: 1.0
In-Reply-To: <20170228181547.GM5680@worktop>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Feb 28, 2017 at 07:15:47PM +0100, Peter Zijlstra wrote:
> On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > +	/*
> > +	 * Each work of workqueue might run in a different context,
> > +	 * thanks to concurrency support of workqueue. So we have to
> > +	 * distinguish each work to avoid false positive.
> > +	 *
> > +	 * TODO: We can also add dependencies between two acquisitions
> > +	 * of different work_id, if they don't cause a sleep so make
> > +	 * the worker stalled.
> > +	 */
> > +	unsigned int		work_id;
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
> So what you're trying to do with that 'work_id' thing is basically wipe
> the entire history when we're at the bottom of a context.

Sorry, but I do not understand what you are trying to say.

What I was trying to do with the 'work_id' is to distinguish between
different works, which will be used to check if history locks were held
in the same context as a release one.

> Which is a useful operation, but should arguably also be done on the
> return to userspace path. Any historical lock from before the current
> syscall is irrelevant.

Sorry. Could you explain it more?

> 
> (And we should not be returning to userspace with locks held anyway --
> lockdep already has a check for that).

Yes right. We should not be returning to userspace without reporting it
in that case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
