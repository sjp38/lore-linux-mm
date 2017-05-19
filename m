Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40E392803C1
	for <linux-mm@kvack.org>; Fri, 19 May 2017 06:56:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i63so56022847pgd.15
        for <linux-mm@kvack.org>; Fri, 19 May 2017 03:56:56 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m80si8238890pfa.28.2017.05.19.03.56.54
        for <linux-mm@kvack.org>;
        Fri, 19 May 2017 03:56:55 -0700 (PDT)
From: "Byungchul Park" <byungchul.park@lge.com>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com> <1489479542-27030-6-git-send-email-byungchul.park@lge.com> <20170519080708.GG28017@X58A-UD3R> <20170519103025.zb5impbsek77ahwa@hirez.programming.kicks-ass.net>
In-Reply-To: <20170519103025.zb5impbsek77ahwa@hirez.programming.kicks-ass.net>
Subject: RE: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Date: Fri, 19 May 2017 19:56:53 +0900
Message-ID: <005a01d2d08e$9fe62800$dfb27800$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Peter Zijlstra' <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

> -----Original Message-----
> From: Peter Zijlstra [mailto:peterz@infradead.org]
> Sent: Friday, May 19, 2017 7:30 PM
> To: Byungchul Park
> Cc: mingo@kernel.org; tglx@linutronix.de; walken@google.com;
> boqun.feng@gmail.com; kirill@shutemov.name; linux-kernel@vger.kernel.org;
> linux-mm@kvack.org; iamjoonsoo.kim@lge.com; akpm@linux-foundation.org;
> willy@infradead.org; npiggin@gmail.com; kernel-team@lge.com
> Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
> 
> On Fri, May 19, 2017 at 05:07:08PM +0900, Byungchul Park wrote:
> > On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> > > Lockdep is a runtime locking correctness validator that detects and
> > > reports a deadlock or its possibility by checking dependencies between
> > > locks. It's useful since it does not report just an actual deadlock
> but
> > > also the possibility of a deadlock that has not actually happened yet.
> > > That enables problems to be fixed before they affect real systems.
> > >
> > > However, this facility is only applicable to typical locks, such as
> > > spinlocks and mutexes, which are normally released within the context
> in
> > > which they were acquired. However, synchronization primitives like
> page
> > > locks or completions, which are allowed to be released in any context,
> > > also create dependencies and can cause a deadlock. So lockdep should
> > > track these locks to do a better job. The 'crossrelease'
> implementation
> > > makes these primitives also be tracked.
> >
> > Excuse me but I have a question...
> >
> > Only for maskable irq, can I assume that hardirq are prevented within
> > hardirq context? I remember that nested interrupts were allowed in the
> > past but not recommanded. But what about now? I'm curious about the
> > overall direction of kernel and current status. It would be very
> > appriciated if you answer it.
> 
> So you're right. In general enabling IRQs from hardirq context is
> discouraged but allowed. However, if you were to do that with a lock
> held that would instantly make lockdep report a deadlock, as the lock is
> then both used from IRQ context and has IRQs enabled.
> 
> So from a locking perspective you can assume no nesting, but from a
> state tracking pov we have to deal with the nesting I think (although it
> is very rare).

Got it. Thank you.

> You're asking this in relation to the rollback thing, right? I think we

Exactly. I wanted to make it clear when implementing the rollback for
irqs and works of workqueue.

> should only save the state when hardirq_context goes from 0->1 and
> restore on 1->0.

Yes, it's already done in v6, as you are saying.

Thank you very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
