Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB4B76B038B
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 03:39:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f21so359900709pgi.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 00:39:28 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 2si2988220plb.41.2017.03.14.00.39.24
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 00:39:25 -0700 (PDT)
Date: Tue, 14 Mar 2017 16:36:30 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170314073630.GG11100@X58A-UD3R>
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
> 
> Which is a useful operation, but should arguably also be done on the
> return to userspace path. Any historical lock from before the current
> syscall is irrelevant.

Yes. I agree with that each syscall is irrelevant to others. But should
we do that? Is it a problem if we don't distinguish between each syscall
context in crossrelease check? IMHO, it's ok to perform commit if the
target crosslock can be seen when releasing it. No? (As you know, in case
of work queue, each work should be distinguished. See the comment in code.)

If we have to do it.. do you mean to modify architecture code for syscall
entry? Or is there architecture independent code where we can be aware of
the entry? It would be appriciated if you answer them.

> 
> (And we should not be returning to userspace with locks held anyway --
> lockdep already has a check for that).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
