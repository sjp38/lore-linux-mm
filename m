Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id F2D416B0031
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 19:39:12 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so4503412yha.26
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:39:12 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id m49si25955052yha.63.2013.11.26.16.39.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 16:39:12 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 26 Nov 2013 17:39:11 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1E7AB19D8041
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:39:03 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAQMb7MK3801490
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 23:37:07 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAR0g3PH030853
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:42:05 -0700
Date: Tue, 26 Nov 2013 16:39:04 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131127003904.GI4137@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131125173540.GK3694@twins.programming.kicks-ass.net>
 <20131125180250.GR4138@linux.vnet.ibm.com>
 <20131125182715.GG10022@twins.programming.kicks-ass.net>
 <20131125235252.GA4138@linux.vnet.ibm.com>
 <20131126095945.GI10022@twins.programming.kicks-ass.net>
 <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
 <20131126192003.GA4137@linux.vnet.ibm.com>
 <CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
 <20131126225136.GG4137@linux.vnet.ibm.com>
 <CA+55aFw58i3X67exR39M4OwUt5j+9BF4VU03FayRY0xGrnQvrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw58i3X67exR39M4OwUt5j+9BF4VU03FayRY0xGrnQvrg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 03:58:11PM -0800, Linus Torvalds wrote:
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

Cross-CPU ordering.  I have to guarantee the grace period across all
CPUs, and I currently rely on a series of lock acquisitions to provide
that ordering.  On the other hand, I only rely on unlock+lock pairs,
so that I don't need any particular lock or unlock operation to be
a full barrier in and of itself.

If that turns out to be problematic, I could of course insert smp_mb()s
everywhere, but they would be redundant on most architectures.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
