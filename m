Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 952386B0031
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 19:22:24 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so2909939bkb.16
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:22:23 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id rl9si11452662bkb.155.2013.11.26.16.22.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 16:22:23 -0800 (PST)
Date: Wed, 27 Nov 2013 01:21:58 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
In-Reply-To: <CA+55aFw58i3X67exR39M4OwUt5j+9BF4VU03FayRY0xGrnQvrg@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1311270111230.30673@ionos.tec.linutronix.de>
References: <20131122182632.GW4138@linux.vnet.ibm.com> <20131122185107.GJ4971@laptop.programming.kicks-ass.net> <20131125173540.GK3694@twins.programming.kicks-ass.net> <20131125180250.GR4138@linux.vnet.ibm.com> <20131125182715.GG10022@twins.programming.kicks-ass.net>
 <20131125235252.GA4138@linux.vnet.ibm.com> <20131126095945.GI10022@twins.programming.kicks-ass.net> <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com> <20131126192003.GA4137@linux.vnet.ibm.com> <CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
 <20131126225136.GG4137@linux.vnet.ibm.com> <CA+55aFw58i3X67exR39M4OwUt5j+9BF4VU03FayRY0xGrnQvrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

Linus,

On Tue, 26 Nov 2013, Linus Torvalds wrote:

> On Tue, Nov 26, 2013 at 2:51 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > Good points, and after_spinlock() works for me from an RCU perspective.
> 
> Note that there's still a semantic question about exactly what that
> "after_spinlock()" is: would it be a memory barrier *only* for the CPU
> that actually does the spinlock? Or is it that "third CPU" order?
> 
> IOW, it would stil not necessarily make your "unlock+lock" (on
> different CPU's) be an actual barrier as far as a third CPU was
> concerned, because you could still have the "unlock happened after
> contention was going on, so the final unlock only released the MCS
> waiter, and there was no barrier".
> 
> See what I'm saying? We could guarantee that if somebody does
> 
>     write A;
>     spin_lock()
>     mb__after_spinlock();
>     read B
> 
> then the "write A" -> "read B" would be ordered. That's one thing.
> 
> But your
> 
>  -  CPU 1:
> 
>     write A
>     spin_unlock()
> 
>  - CPU 2
> 
>     spin_lock()
>     mb__after_spinlock();
>     read B
> 
> ordering as far as a *third* CPU is concerned is a whole different
> thing again, and wouldn't be at all the same thing.
> 
> Is it really that cross-CPU ordering you care about?

Depends on the use case. In the futex case we discussed in parallel we
very much care about that

     w[A]      |     w[B]
     mb	       |     mb
     r[B]      |     r[A]

provides the correct ordering. Until today the spinlock semantics
provided that.

I bet that more code than the cursed futexes is relying on that
assumption.

RCU being one example I'm aware of. Though RCU is one of the simple
cases where the maintainer is actually aware of the problem and
indicated that he is willing to adjust it.

Though I doubt that other places which silently rely on that ordering,
have the faintest clue why the heck it works at all.

I'm all for the change, but we need to be painfully aware of the
lurking (hard to decode) wreckage ahead.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
