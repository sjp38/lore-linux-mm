Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id BD6AC6B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 14:50:48 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j5so1110391qaq.5
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 11:50:48 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id gg10si9379240qeb.21.2013.11.28.11.50.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 11:50:47 -0800 (PST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 28 Nov 2013 12:50:46 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 6B6143E40055
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 12:50:45 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rASHmh6u4915656
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 18:48:43 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rASJre0c024960
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 12:53:42 -0700
Date: Thu, 28 Nov 2013 11:50:40 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131128195039.GX4137@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131126192003.GA4137@linux.vnet.ibm.com>
 <CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
 <20131126225136.GG4137@linux.vnet.ibm.com>
 <20131127101613.GC9032@mudshark.cambridge.arm.com>
 <20131127171143.GN4137@linux.vnet.ibm.com>
 <20131128114058.GC21354@mudshark.cambridge.arm.com>
 <20131128173853.GV4137@linux.vnet.ibm.com>
 <20131128180318.GE16203@mudshark.cambridge.arm.com>
 <20131128182712.GW4137@linux.vnet.ibm.com>
 <20131128185341.GG16203@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131128185341.GG16203@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 28, 2013 at 06:53:41PM +0000, Will Deacon wrote:
> On Thu, Nov 28, 2013 at 06:27:12PM +0000, Paul E. McKenney wrote:
> > On Thu, Nov 28, 2013 at 06:03:18PM +0000, Will Deacon wrote:
> > > Hmm, without horrible hacks to keep track of whether we've done an
> > > mb__before_spinlock() without a matching spinlock(), that's going to end up
> > > with full-barrier + pointless half-barrier (similarly on the release path).
> > 
> > We should be able to detect mb__before_spinlock() without a matching
> > spinlock via static analysis, right?
> > 
> > Or am I missing your point?
> 
> See below...
> 
> > > > Yes, we might need better names, but I believe that this approach does
> > > > what you need.
> > > > 
> > > > Thoughts?
> > > 
> > > I still think we need to draw the distinction between ordering all accesses
> > > against a lock and ordering an unlock against a lock. The latter is free for
> > > arm64 (STLR => LDAR is ordered) but the former requires a DMB.
> > > 
> > > Not sure I completely got your drift...
> > 
> > Here is what I am suggesting:
> > 
> > o	mb__before_spinlock():
> > 
> > 	o	Must appear immediately before a lock acquisition.
> > 	o	Upgrades a lock acquisition to a full barrier.
> > 	o	Emits DMB on ARM64.
> 
> Ok, so that then means that:
> 
> 	mb__before_spinlock();
> 	spin_lock();
> 
> on ARM64 expands to:
> 
> 	dmb	ish
> 	ldaxr	...
> 
> so there's a redundant half-barrier there. If we want to get rid of that, we
> need mb__before_spinlock() to set a flag, then we could conditionalise
> ldaxr/ldxr but it's really horrible and you have to deal with interrupts
> etc. so in reality we just end up having extra barriers.

Given that there was just a dmb, how much does the ish &c really hurt?
Would the performance difference be measurable at the system level?

> Or we have separate a spin_lock_mb() function.

And mutex_lock_mb().  And spin_lock_irqsave_mb().  And spin_lock_irq_mb().
And...

Admittedly this is not yet a problem given the current very low usage
of smp_mb__before_spinlock(), but the potential for API explosion is
non-trivial.

That said, if the effect on ARM64 is measurable at the system level, I
won't stand in the way of the additional APIs.

> > o	mb_after_spinlock():
> > 
> > 	o	Must appear immediatly after a lock acquisition.
> > 	o	Upgrades an unlock+lock pair to a full barrier.
> > 	o	Emits a no-op on ARM64, as in "do { } while (0)".
> > 	o	Might need a separate flavor for queued locks on
> > 		some platforms, but no sign of that yet.
> 
> Ok, so mb__after_spinlock() doesn't imply a full barrier but
> mb__before_spinlock() does? I think people will get that wrong :)

As I said earlier in the thread, I am open to better names.

How about smp_mb__after_spin_unlock_lock_pair()?  That said, I am sure that
I could come up with something longer given enough time.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
