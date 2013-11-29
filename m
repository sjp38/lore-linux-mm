Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 892D76B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 11:18:58 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id q58so9443131wes.19
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 08:18:57 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id nj8si14530103wic.73.2013.11.29.08.18.57
        for <linux-mm@kvack.org>;
        Fri, 29 Nov 2013 08:18:57 -0800 (PST)
Date: Fri, 29 Nov 2013 16:17:11 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131129161711.GG31000@mudshark.cambridge.arm.com>
References: <CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
 <20131126225136.GG4137@linux.vnet.ibm.com>
 <20131127101613.GC9032@mudshark.cambridge.arm.com>
 <20131127171143.GN4137@linux.vnet.ibm.com>
 <20131128114058.GC21354@mudshark.cambridge.arm.com>
 <20131128173853.GV4137@linux.vnet.ibm.com>
 <20131128180318.GE16203@mudshark.cambridge.arm.com>
 <20131128182712.GW4137@linux.vnet.ibm.com>
 <20131128185341.GG16203@mudshark.cambridge.arm.com>
 <20131128195039.GX4137@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131128195039.GX4137@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 28, 2013 at 07:50:40PM +0000, Paul E. McKenney wrote:
> On Thu, Nov 28, 2013 at 06:53:41PM +0000, Will Deacon wrote:
> > Ok, so that then means that:
> > 
> > 	mb__before_spinlock();
> > 	spin_lock();
> > 
> > on ARM64 expands to:
> > 
> > 	dmb	ish
> > 	ldaxr	...
> > 
> > so there's a redundant half-barrier there. If we want to get rid of that, we
> > need mb__before_spinlock() to set a flag, then we could conditionalise
> > ldaxr/ldxr but it's really horrible and you have to deal with interrupts
> > etc. so in reality we just end up having extra barriers.
> 
> Given that there was just a dmb, how much does the ish &c really hurt?
> Would the performance difference be measurable at the system level?

There's no definitive answer, as it depends heavily on a combination of the
microarchitecture and specific platform implementation. To get some sort of
idea, I tried adding a dmb to the start of spin_unlock on ARMv7 and I saw a
3% performance hit in hackbench on my dual-cluster board.

Whether or not that's a big deal, I'm not sure, especially given that this
should be rare.

> > Or we have separate a spin_lock_mb() function.
> 
> And mutex_lock_mb().  And spin_lock_irqsave_mb().  And spin_lock_irq_mb().
> And...

Ok, point taken.

> Admittedly this is not yet a problem given the current very low usage
> of smp_mb__before_spinlock(), but the potential for API explosion is
> non-trivial.
> 
> That said, if the effect on ARM64 is measurable at the system level, I
> won't stand in the way of the additional APIs.
> 
> > > o	mb_after_spinlock():
> > > 
> > > 	o	Must appear immediatly after a lock acquisition.
> > > 	o	Upgrades an unlock+lock pair to a full barrier.
> > > 	o	Emits a no-op on ARM64, as in "do { } while (0)".
> > > 	o	Might need a separate flavor for queued locks on
> > > 		some platforms, but no sign of that yet.
> > 
> > Ok, so mb__after_spinlock() doesn't imply a full barrier but
> > mb__before_spinlock() does? I think people will get that wrong :)
> 
> As I said earlier in the thread, I am open to better names.
> 
> How about smp_mb__after_spin_unlock_lock_pair()?  That said, I am sure that
> I could come up with something longer given enough time.  ;-)

Ha! Well, I think the principles are sound, but the naming is key to making
sure that this interface is used correctly.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
