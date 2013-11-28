Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id 234C26B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 13:27:22 -0500 (EST)
Received: by mail-oa0-f42.google.com with SMTP id i4so9538646oah.29
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 10:27:21 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id pp9si37871952obc.128.2013.11.28.10.27.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 10:27:20 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 28 Nov 2013 11:27:20 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 8334D1FF001C
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 11:26:57 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rASGPFbM7864824
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 17:25:15 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rASIUCWL018964
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 11:30:14 -0700
Date: Thu, 28 Nov 2013 10:27:12 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131128182712.GW4137@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131126095945.GI10022@twins.programming.kicks-ass.net>
 <CA+55aFxXEbHuaKuxBDH=7a2-n_z849CdfeDtdL=_nFxu_Tx9_g@mail.gmail.com>
 <20131126192003.GA4137@linux.vnet.ibm.com>
 <CA+55aFyjisiM1eC53STpcKLky84n8JRz3Aagp-CQd_+3AOJhow@mail.gmail.com>
 <20131126225136.GG4137@linux.vnet.ibm.com>
 <20131127101613.GC9032@mudshark.cambridge.arm.com>
 <20131127171143.GN4137@linux.vnet.ibm.com>
 <20131128114058.GC21354@mudshark.cambridge.arm.com>
 <20131128173853.GV4137@linux.vnet.ibm.com>
 <20131128180318.GE16203@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131128180318.GE16203@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 28, 2013 at 06:03:18PM +0000, Will Deacon wrote:
> On Thu, Nov 28, 2013 at 05:38:53PM +0000, Paul E. McKenney wrote:
> > On Thu, Nov 28, 2013 at 11:40:59AM +0000, Will Deacon wrote:
> > > On Wed, Nov 27, 2013 at 05:11:43PM +0000, Paul E. McKenney wrote:
> > > > And in fact the unlock+lock barrier is all that RCU needs.  I guess the
> > > > question is whether it is worth having two flavors of __after_spinlock(),
> > > > one that is a full barrier with just the lock, and another that is
> > > > only guaranteed to be a full barrier with unlock+lock.
> > > 
> > > I think it's worth distinguishing those cases because, in my mind, one is
> > > potentially a lot heavier than the other. The risk is that we end up
> > > producing a set of strangely named barrier abstractions that nobody can
> > > figure out how to use properly:
> > > 
> > > 
> > > 	/*
> > > 	 * Prevent re-ordering of arbitrary accesses across spin_lock and
> > > 	 * spin_unlock.
> > > 	 */
> > > 	mb__after_spin_lock()
> > > 	mb__after_spin_unlock()
> > > 
> > > 	/*
> > > 	 * Order spin_lock() vs spin_unlock()
> > > 	 */
> > > 	mb__between_spin_unlock_lock() /* Horrible name! */
> > > 
> > > 
> > > We could potentially replace the first set of barriers with spin_lock_mb()
> > > and spin_unlock_mb() variants (which would be more efficient than half
> > > barrier + full barrier), then we only end up with strangely named barrier
> > > which applies to the non _mb() spinlock routines.
> > 
> > How about the current mb__before_spinlock() making the acquisition be
> > a full barrier, and an mb_after_spinlock() making a prior release plus
> > this acquisition be a full barrier?
> 
> Hmm, without horrible hacks to keep track of whether we've done an
> mb__before_spinlock() without a matching spinlock(), that's going to end up
> with full-barrier + pointless half-barrier (similarly on the release path).

We should be able to detect mb__before_spinlock() without a matching
spinlock via static analysis, right?

Or am I missing your point?

> > Yes, we might need better names, but I believe that this approach does
> > what you need.
> > 
> > Thoughts?
> 
> I still think we need to draw the distinction between ordering all accesses
> against a lock and ordering an unlock against a lock. The latter is free for
> arm64 (STLR => LDAR is ordered) but the former requires a DMB.
> 
> Not sure I completely got your drift...

Here is what I am suggesting:

o	mb__before_spinlock():

	o	Must appear immediately before a lock acquisition.
	o	Upgrades a lock acquisition to a full barrier.
	o	Emits DMB on ARM64.
	
o	mb_after_spinlock():

	o	Must appear immediatly after a lock acquisition.
	o	Upgrades an unlock+lock pair to a full barrier.
	o	Emits a no-op on ARM64, as in "do { } while (0)".
	o	Might need a separate flavor for queued locks on
		some platforms, but no sign of that yet.

Does that make sense?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
