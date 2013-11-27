Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 942F56B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 16:26:43 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id j5so6279972qaq.14
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 13:26:43 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id a4si1174917qar.12.2013.11.27.13.26.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 13:26:42 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 27 Nov 2013 14:26:41 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6FD6D1FF0021
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 14:26:18 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rARJOmeg4456878
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 20:24:48 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rARLTXC3019224
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 14:29:35 -0700
Date: Wed, 27 Nov 2013 09:11:43 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131127171143.GN4137@linux.vnet.ibm.com>
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
 <20131127101613.GC9032@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131127101613.GC9032@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, Nov 27, 2013 at 10:16:13AM +0000, Will Deacon wrote:
> On Tue, Nov 26, 2013 at 10:51:36PM +0000, Paul E. McKenney wrote:
> > On Tue, Nov 26, 2013 at 11:32:25AM -0800, Linus Torvalds wrote:
> > > On Tue, Nov 26, 2013 at 11:20 AM, Paul E. McKenney
> > > <paulmck@linux.vnet.ibm.com> wrote:
> > > >
> > > > There are several places in RCU that assume unlock+lock is a full
> > > > memory barrier, but I would be more than happy to fix them up given
> > > > an smp_mb__after_spinlock() and an smp_mb__before_spinunlock(), or
> > > > something similar.
> > > 
> > > A "before_spinunlock" would actually be expensive on x86.
> > 
> > Good point, on x86 the typical non-queued spin-lock acquisition path
> > has an atomic operation with full memory barrier in any case.  I believe
> > that this is the case for the other TSO architectures.  For the non-TSO
> > architectures:
> > 
> > o	ARM has an smp_mb() during lock acquisition, so after_spinlock()
> > 	can be a no-op for them.
> 
> Ok, but what about arm64? We use acquire for lock() and release for
> unlock(), so in Linus' example:

Right, I did forget the arm vs. arm64 split!

>     write A;
>     spin_lock()
>     mb__after_spinlock();
>     read B
> 
> Then A could very well be reordered after B if mb__after_spinlock() is a nop.
> Making that a full barrier kind of defeats the point of using acquire in the
> first place...

The trick is that you don't have mb__after_spinlock() unless you need the
ordering, which we expect in a small minority of the lock acquisitions.
So you would normally get the benefit of acquire/release efficiency.

> It's one thing ordering unlock -> lock, but another getting those two to
> behave as full barriers for any arbitrary memory accesses.

And in fact the unlock+lock barrier is all that RCU needs.  I guess the
question is whether it is worth having two flavors of __after_spinlock(),
one that is a full barrier with just the lock, and another that is
only guaranteed to be a full barrier with unlock+lock.

								Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
