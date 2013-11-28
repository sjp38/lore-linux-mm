Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 106B26B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 13:55:23 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id ey16so1206511wid.7
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 10:55:23 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id y6si12995132wib.78.2013.11.28.10.55.22
        for <linux-mm@kvack.org>;
        Thu, 28 Nov 2013 10:55:22 -0800 (PST)
Date: Thu, 28 Nov 2013 18:53:41 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131128185341.GG16203@mudshark.cambridge.arm.com>
References: <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
 <20131126192003.GA4137@linux.vnet.ibm.com>
 <CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
 <20131126225136.GG4137@linux.vnet.ibm.com>
 <20131127101613.GC9032@mudshark.cambridge.arm.com>
 <20131127171143.GN4137@linux.vnet.ibm.com>
 <20131128114058.GC21354@mudshark.cambridge.arm.com>
 <20131128173853.GV4137@linux.vnet.ibm.com>
 <20131128180318.GE16203@mudshark.cambridge.arm.com>
 <20131128182712.GW4137@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131128182712.GW4137@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 28, 2013 at 06:27:12PM +0000, Paul E. McKenney wrote:
> On Thu, Nov 28, 2013 at 06:03:18PM +0000, Will Deacon wrote:
> > Hmm, without horrible hacks to keep track of whether we've done an
> > mb__before_spinlock() without a matching spinlock(), that's going to end up
> > with full-barrier + pointless half-barrier (similarly on the release path).
> 
> We should be able to detect mb__before_spinlock() without a matching
> spinlock via static analysis, right?
> 
> Or am I missing your point?

See below...

> > > Yes, we might need better names, but I believe that this approach does
> > > what you need.
> > > 
> > > Thoughts?
> > 
> > I still think we need to draw the distinction between ordering all accesses
> > against a lock and ordering an unlock against a lock. The latter is free for
> > arm64 (STLR => LDAR is ordered) but the former requires a DMB.
> > 
> > Not sure I completely got your drift...
> 
> Here is what I am suggesting:
> 
> o	mb__before_spinlock():
> 
> 	o	Must appear immediately before a lock acquisition.
> 	o	Upgrades a lock acquisition to a full barrier.
> 	o	Emits DMB on ARM64.

Ok, so that then means that:

	mb__before_spinlock();
	spin_lock();

on ARM64 expands to:

	dmb	ish
	ldaxr	...

so there's a redundant half-barrier there. If we want to get rid of that, we
need mb__before_spinlock() to set a flag, then we could conditionalise
ldaxr/ldxr but it's really horrible and you have to deal with interrupts
etc. so in reality we just end up having extra barriers.

Or we have separate a spin_lock_mb() function.

> o	mb_after_spinlock():
> 
> 	o	Must appear immediatly after a lock acquisition.
> 	o	Upgrades an unlock+lock pair to a full barrier.
> 	o	Emits a no-op on ARM64, as in "do { } while (0)".
> 	o	Might need a separate flavor for queued locks on
> 		some platforms, but no sign of that yet.

Ok, so mb__after_spinlock() doesn't imply a full barrier but
mb__before_spinlock() does? I think people will get that wrong :)

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
