Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f48.google.com (mail-qe0-f48.google.com [209.85.128.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3A51B6B00B7
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 18:10:48 -0500 (EST)
Received: by mail-qe0-f48.google.com with SMTP id gc15so6454733qeb.21
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 15:10:47 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id k4si16190919qci.63.2013.11.26.15.10.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 15:10:46 -0800 (PST)
Message-ID: <1385507285.9218.73.camel@pasglop>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 27 Nov 2013 10:08:05 +1100
In-Reply-To: <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
References: <20131121172558.GA27927@linux.vnet.ibm.com>
	 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
	 <20131121221859.GH4138@linux.vnet.ibm.com>
	 <20131122155835.GR3866@twins.programming.kicks-ass.net>
	 <20131122182632.GW4138@linux.vnet.ibm.com>
	 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
	 <20131125173540.GK3694@twins.programming.kicks-ass.net>
	 <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, 2013-11-26 at 11:00 -0800, Linus Torvalds wrote:
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

I would love to get rid of that assumption because it's one of the
things that we currently violate on PowerPC and to get it completely
right we would have to upgrade at least one side to a full sync.

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
> 
> IOW, where do we really care about the "unlock+lock" is a memory
> barrier? And could we make those places explicit, and then do
> something similar to the above to them?

I personally am in favor of either that or an explicit variant of
spin_lock_mb (or unlock) that has the built in full barrier, which ever,
which could be a *little bit* more efficient since we wouldn't cumulate
both the semi permeable barrier in the lock/unlock *and* the added full
barrier.

Cheers,
Ben.

>                        Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
