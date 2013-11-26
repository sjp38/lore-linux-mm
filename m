Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id CE44E6B0095
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:20:11 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id ii20so7996865qab.8
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 11:20:11 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id a1si12050918qar.50.2013.11.26.11.20.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 11:20:11 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 26 Nov 2013 12:20:09 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 9B9B01FF001C
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 12:19:47 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAQHIIV914352546
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 18:18:18 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAQJN1EH011320
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 12:23:03 -0700
Date: Tue, 26 Nov 2013 11:20:03 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131126192003.GA4137@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131121221859.GH4138@linux.vnet.ibm.com>
 <20131122155835.GR3866@twins.programming.kicks-ass.net>
 <20131122182632.GW4138@linux.vnet.ibm.com>
 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
 <20131125173540.GK3694@twins.programming.kicks-ass.net>
 <20131125180250.GR4138@linux.vnet.ibm.com>
 <20131125182715.GG10022@twins.programming.kicks-ass.net>
 <20131125235252.GA4138@linux.vnet.ibm.com>
 <20131126095945.GI10022@twins.programming.kicks-ass.net>
 <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 11:00:50AM -0800, Linus Torvalds wrote:
> On Tue, Nov 26, 2013 at 1:59 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > If you now want to weaken this definition, then that needs consideration
> > because we actually rely on things like
> >
> > spin_unlock(l1);
> > spin_lock(l2);
> >
> > being full barriers.
> 
> Btw, maybe we should just stop that assumption. The complexity of this
> discussion makes me go "maybe we should stop with subtle assumptions
> that happen to be obviously true on x86 due to historical
> implementations, but aren't obviously true even *there* any more with
> the MCS lock".

>From an RCU viewpoint, I am OK with that approach.  From the viewpoint
of documenting our assumptions, I really really like that approach.

> We already have a concept of
> 
>         smp_mb__before_spinlock();
>         spin_lock():
> 
> for sequences where we *know* we need to make getting a spin-lock be a
> full memory barrier. It's free on x86 (and remains so even with the
> MCS lock, regardless of any subtle issues, if only because even the
> MCS lock starts out with a locked atomic, never mind the contention
> slow-case). Of course, that macro is only used inside the scheduler,
> and is actually documented to not really be a full memory barrier, but
> it handles the case we actually care about.

This would work well if we made it be smp_mb__after_spinlock(), used
as follows:

	spin_lock();
	smp_mb__after_spinlock();

The reason that it must go after rather than before is to handle the
MCS-style low-overhead handoffs.  During the handoff, you can count
on code at the beginning of the critical section being executed, but
things before the lock cannot possibly help you.

We should also have something for lock releases, for example:

	smp_mb__before_spinunlock();
	spin_unlock();

This allows architectures to choose where to put the overhead, and
also very clearly documents which unlock+lock pairs need the full
barriers.

Heh.  Must smp_mb__after_spinlock() and smp_mb__before_spinunlock()
provide a full barrier when used separately, or only when used together?
The unlock+lock guarantee requires that they provide a full barrier
only when used together.  However, I believe that the scheduler's use
of smp_mb__before_spinlock() needs a full barrier without pairing.

I have no idea whether or not we should have a separate API for each
flavor of lock.

> IOW, where do we really care about the "unlock+lock" is a memory
> barrier? And could we make those places explicit, and then do
> something similar to the above to them?

There are several places in RCU that assume unlock+lock is a full
memory barrier, but I would be more than happy to fix them up given
an smp_mb__after_spinlock() and an smp_mb__before_spinunlock(), or
something similar.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
