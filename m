Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD3126B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 01:41:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id m89so22885584pfi.14
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 22:41:58 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r83si21054972pfj.27.2017.04.24.22.41.56
        for <linux-mm@kvack.org>;
        Mon, 24 Apr 2017 22:41:57 -0700 (PDT)
Date: Tue, 25 Apr 2017 14:40:44 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170425054044.GK21430@X58A-UD3R>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419142503.rqsrgjlc7ump7ijb@hirez.programming.kicks-ass.net>
 <20170424051102.GJ21430@X58A-UD3R>
 <20170424101747.iirvjjoq66x25w7n@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
In-Reply-To: <20170424101747.iirvjjoq66x25w7n@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Apr 24, 2017 at 12:17:47PM +0200, Peter Zijlstra wrote:
> On Mon, Apr 24, 2017 at 02:11:02PM +0900, Byungchul Park wrote:
> > On Wed, Apr 19, 2017 at 04:25:03PM +0200, Peter Zijlstra wrote:
> 
> > > I still don't like work_id; it doesn't have anything to do with
> > > workqueues per se, other than the fact that they end up using it.
> > > 
> > > It's a history generation id; touching it completely invalidates our
> > > history. Workqueues need this because they run independent work from the
> > > same context.
> > > 
> > > But the same is true for other sites. Last time I suggested
> > > lockdep_assert_empty() to denote all suck places (and note we already
> > > have lockdep_sys_exit() that hooks into the return to user path).
> > 
> > I'm sorry but I don't understand what you intend. It would be appriciated
> > if you explain more.
> > 
> > You might know why I introduced the 'work_id'.. Is there any alternative?
> 
> My complaint is mostly about naming.. and "hist_gen_id" might be a
> better name.

Ah, I also think the name, 'work_id', is not good... and frankly I am
not sure if 'hist_gen_id' is good, either. What about to apply 'rollback',
which I did for locks in irq, into works of workqueues? If you say yes,
I will try to do it.

> But let me explain.
> 
> 
> The reason workqueues need this is because the lock history for each
> 'work' are independent. The locks of Work-B do not depend on the locks
> of the preceding Work-A, because the completion of Work-B is not
> dependent on those locks.
> 
> But this is true for many things; pretty much all kthreads fall in this
> pattern, where they have an 'idle' state and future completions do not
> depend on past completions. Its just that since they all have the 'same'
> form -- the kthread does the same over and over -- it doesn't matter
> much.
> 
> The same is true for system-calls, once a system call is complete (we've
> returned to userspace) the next system call does not depend on the lock
> history of the previous one.

Yes. I agree. As you said, actually two independent job e.g. syscalls,
works.. should not depend on each other.

Frankly speaking, nevertheless, if they depend on each other, then I
think it would be better to detect the cases, too. But for now, since
it's more important to avoid false positive detections, I will do it as
conservatively as possible, as my current implementation.

And thank you for additional explanation!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
