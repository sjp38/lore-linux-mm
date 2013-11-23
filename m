Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id C5D346B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 20:37:01 -0500 (EST)
Received: by mail-oa0-f48.google.com with SMTP id l6so2210243oag.35
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 17:37:01 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id r7si23066002oem.84.2013.11.22.17.37.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 17:37:00 -0800 (PST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 22 Nov 2013 18:36:59 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 646ED3E4003F
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:36:57 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAMNZ9of42467422
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 00:35:09 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAN1doqV029592
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:39:52 -0700
Date: Fri, 22 Nov 2013 17:36:54 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131123013654.GG4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131122184937.GX4138@linux.vnet.ibm.com>
 <CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
 <20131122200620.GA4138@linux.vnet.ibm.com>
 <CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
 <20131122203738.GC4138@linux.vnet.ibm.com>
 <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
 <20131122215208.GD4138@linux.vnet.ibm.com>
 <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
 <20131123002542.GF4138@linux.vnet.ibm.com>
 <CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 04:42:37PM -0800, Linus Torvalds wrote:
> On Fri, Nov 22, 2013 at 4:25 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > Start with Tim Chen's most recent patches for MCS locking, the ones that
> > do the lock handoff using smp_store_release() and smp_load_acquire().
> > Add to that Peter Zijlstra's patch that uses PowerPC lwsync for both
> > smp_store_release() and smp_load_acquire().  Run the resulting lock
> > at high contention, so that all lock handoffs are done via the queue.
> > Then you will have something that acts like a lock from the viewpoint
> > of CPU holding that lock, but which does -not- guarantee that an
> > unlock+lock acts like a full memory barrier if the unlock and lock run
> > on two different CPUs, and if the observer is running on a third CPU.
> 
> Umm. If the unlock and the lock run on different CPU's, then the lock
> handoff cannot be done through the queue (I assume that what you mean
> by "queue" is the write buffer).

No, I mean by the MCS lock's queue of waiters.  Software, not hardware.

You know, this really isn't all -that- difficult.

Here is how Tim's MCS lock hands off to the next requester on the queue:

+       smp_store_release(&next->locked, 1);                            \

Given Peter's powerpc implementation, this is an lwsync followed by
a store.

Here is how Tim's MCS lock has the next requester take the handoff:

+       while (!(smp_load_acquire(&node->locked)))                      \
+               arch_mutex_cpu_relax();                                 \

Given Peter's powerpc implementation, this is a load followed by an
lwsync.

So a lock handoff looks like this, where the variable lock is initially 1
(held by CPU 0):

	CPU 0 (releasing)	CPU 1 (acquiring)
	-----			-----
	CS0			while (ACCESS_ONCE(lock) == 1)
	lwsync				continue;
	ACCESS_ONCE(lock) = 0;	lwsync
				CS1

Because lwsync orders both loads and stores before stores, CPU 0's
lwsync does the ordering required to keep CS0 from bleeding out.
Because lwsync orders loads before both loads and stores, CPU 1's lwsync
does the ordering required to keep CS1 from bleeding out.  It even works
transitively because we use the same lock variable throughout, all
from the perspective of a CPU holding "lock".

Therefore, Tim's MCS lock combined with Peter's powerpc implementations
of smp_load_acquire() and smp_store_release() really does act like a
lock from the viewpoint of whoever is holding the lock.

But this does -not- guarantee that some other non-lock-holding CPU 2 will
see CS0 and CS1 in order.  To see this, let's fill in the two critical
sections, where variables X and Y are both initially zero:

	CPU 0 (releasing)	CPU 1 (acquiring)
	-----			-----
	ACCESS_ONCE(X) = 1;	while (ACCESS_ONCE(lock) == 1)
	lwsync				continue;
	ACCESS_ONCE(lock) = 0;	lwsync
				r1 = ACCESS_ONCE(Y);

Then let's add in the observer CPU 2:

	CPU 2
	-----
	ACCESS_ONCE(Y) = 1;
	sync
	r2 = ACCESS_ONCE(X);

If unlock+lock act as a full memory barrier, it would be impossible to
end up with (r1 == 0 && r2 == 0).  After all, (r1 == 0) implies that
CPU 2's store to Y happened after CPU 1's load from Y, and (r2 == 0)
implies that CPU 0's load from X happened after CPU 2's store to X.
If CPU 0's unlock combined with CPU 1's lock really acted like a full
memory barrier, we end up with CPU 0's load happening before CPU 1's
store happening before CPU 2's store happening before CPU 2's load
happening before CPU 0's load.

However, the outcome (r1 == 0 && r2 == 0) really does happen both
in theory and on real hardware.  Therefore, although this acts as
a lock from the viewpoint of a CPU holding the lock, the unlock+lock
combination does -not- act as a full memory barrier.

So there is your example.  It really can and does happen.

Again, easy fix.  Just change powerpc's smp_store_release() from lwsync
to smp_mb().  That fixes the problem and doesn't hurt anyone but powerpc.

OK?

							Thanx, Paul

> And yes, the write buffer is why running unlock+lock on the *same* CPU
> is a special case and can generate more re-ordering than is visible
> externally (and I generally do agree that we should strive for
> serialization at that point), but even it does not actually violate
> the rules mentioned in Documentation/memory-barriers.txt wrt an
> external CPU because the write that releases the lock isn't actually
> visible at that point in the cache, and if the same CPU re-aquires it
> by doing a read that bypasses the write and hits in the write buffer
> or the unlock, the unlocked state in between won't even be seen
> outside of that CPU.
> 
> See? The local write buffer is special. It very much bypasses the
> cache, but the thing about it is that it's local to that CPU.
> 
> Now, I do have to admit that cache coherency protocols are really
> subtle, and there may be something else I'm missing, but the thing you
> brought up is not one of those things, afaik.
> 
>               Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
