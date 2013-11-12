Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id C1CE46B00DB
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 11:10:19 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr4so7094905pbb.39
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 08:10:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.175])
        by mx.google.com with SMTP id cx4si20014388pbc.329.2013.11.12.08.10.17
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 08:10:18 -0800 (PST)
Date: Tue, 12 Nov 2013 16:08:27 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v5 4/4] MCS Lock: Barrier corrections
Message-ID: <20131112160827.GB25953@mudshark.cambridge.arm.com>
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940358.11046.417.camel@schen9-DESK>
 <20131111181049.GL28302@mudshark.cambridge.arm.com>
 <1384204673.10046.6.camel@schen9-mobl3>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384204673.10046.6.camel@schen9-mobl3>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Nov 11, 2013 at 09:17:52PM +0000, Tim Chen wrote:
> On Mon, 2013-11-11 at 18:10 +0000, Will Deacon wrote:
> > On Fri, Nov 08, 2013 at 07:52:38PM +0000, Tim Chen wrote:
> > > diff --git a/kernel/locking/mcs_spinlock.c b/kernel/locking/mcs_spinlock.c
> > > index b6f27f8..df5c167 100644
> > > --- a/kernel/locking/mcs_spinlock.c
> > > +++ b/kernel/locking/mcs_spinlock.c
> > > @@ -23,6 +23,31 @@
> > >  #endif
> > >  
> > >  /*
> > > + * Fall back to use the regular atomic operations and memory barrier if
> > > + * the acquire/release versions are not defined.
> > > + */
> > > +#ifndef	xchg_acquire
> > > +# define xchg_acquire(p, v)		xchg(p, v)
> > > +#endif
> > > +
> > > +#ifndef	smp_load_acquire
> > > +# define smp_load_acquire(p)				\
> > > +	({						\
> > > +		typeof(*p) __v = ACCESS_ONCE(*(p));	\
> > > +		smp_mb();				\
> > > +		__v;					\
> > > +	})
> > > +#endif
> > > +
> > > +#ifndef smp_store_release
> > > +# define smp_store_release(p, v)		\
> > > +	do {					\
> > > +		smp_mb();			\
> > > +		ACCESS_ONCE(*(p)) = v;		\
> > > +	} while (0)
> > > +#endif
> > 
> > PeterZ already has a series implementing acquire/release accessors, so you
> > should probably take a look at that rather than rolling your own here.
> 
> Yes, we are using Peter Z's implementation here.  The above is for anything
> where smp_load_acquire and smp_store_release are *not* defined.  We can
> remove this once all architectures implement the acquire and release 
> functions as mentioned in the comments of the patch.

Right, so you can use barrier.h and asm-generic will define generic versions
(identical to the above) for you if the architecture doesn't have an
optimised variant. You don't need to reproduce that in your .c file.

> > > +	/*
> > > +	 * Wait until the lock holder passes the lock down.
> > > +	 * Using smp_load_acquire() provides a memory barrier that
> > > +	 * ensures subsequent operations happen after the lock is acquired.
> > > +	 */
> > > +	while (!(smp_load_acquire(&node->locked)))
> > >  		arch_mutex_cpu_relax();
> > 
> > After a chat with some micro-architects, I'm going to have to disagree with
> > Paul here. For architectures where acquire/release are implemented with
> > explicit barriers (similarly for simple microarchitectures), emitting
> > barriers in a loop *is* going to have an affect on overall performance,
> > since those barriers may well result in traffic outside of the core (at
> > least, on ARM).
> > 
> > Thinking more about that, the real issue here is that arch_mutex_cpu_relax()
> > doesn't have a corresponding hook on the unlock side. On ARM, for example,
> > we can enter a low-power state using the wfe instruction, but that requires
> > the unlocker to wake up the core when the lock is released.
> 
> An alternate implementation is
> 	while (!ACCESS_ONCE(node->locked))
> 		arch_mutex_cpu_relax();
> 	smp_load_acquire(&node->locked);
> 
> Leaving the smp_load_acquire at the end to provide appropriate barrier.
> Will that be acceptable?

It still doesn't solve my problem though: I want a way to avoid that busy
loop by some architecture-specific manner. The arch_mutex_cpu_relax() hook
is a start, but there is no corresponding hook on the unlock side to issue a
wakeup. Given a sensible relax implementation, I don't have an issue with
putting a load-acquire in a loop, since it shouldn't be aggresively spinning
anymore.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
