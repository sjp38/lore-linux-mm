Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id CCE486B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 23:53:42 -0500 (EST)
Received: by mail-oa0-f48.google.com with SMTP id l6so1802761oag.35
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 20:53:42 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id ns8si18416026obc.152.2013.11.20.20.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 20:53:41 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 20 Nov 2013 21:53:41 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id BFFDEC40001
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 21:53:18 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAL2pcIk5832974
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 03:51:38 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAL4uTHU022757
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 21:56:31 -0700
Date: Wed, 20 Nov 2013 20:53:33 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131121045333.GO4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
 <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <1384973026.11046.465.camel@schen9-DESK>
 <20131120190616.GL4138@linux.vnet.ibm.com>
 <1384979767.11046.489.camel@schen9-DESK>
 <20131120214402.GM4138@linux.vnet.ibm.com>
 <1384991514.11046.504.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384991514.11046.504.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, Nov 20, 2013 at 03:51:54PM -0800, Tim Chen wrote:
> On Wed, 2013-11-20 at 13:44 -0800, Paul E. McKenney wrote:
> > On Wed, Nov 20, 2013 at 12:36:07PM -0800, Tim Chen wrote:
> > > On Wed, 2013-11-20 at 11:06 -0800, Paul E. McKenney wrote:
> > > > On Wed, Nov 20, 2013 at 10:43:46AM -0800, Tim Chen wrote:
> > > > > On Wed, 2013-11-20 at 09:14 -0800, Paul E. McKenney wrote:
> > > > > > On Wed, Nov 20, 2013 at 03:46:43PM +0000, Will Deacon wrote:
> > > > > > > Hi Paul,
> > > > > > > 
> > > > > > > On Wed, Nov 20, 2013 at 03:31:23PM +0000, Paul E. McKenney wrote:
> > > > > > > > On Tue, Nov 19, 2013 at 05:37:43PM -0800, Tim Chen wrote:
> > > > > > > > > @@ -68,7 +72,12 @@ void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > > > > > > > >  		while (!(next = ACCESS_ONCE(node->next)))
> > > > > > > > >  			arch_mutex_cpu_relax();
> > > > > > > > >  	}
> > > > > > > > > -	ACCESS_ONCE(next->locked) = 1;
> > > > > > > > > -	smp_wmb();
> > > > > > > > > +	/*
> > > > > > > > > +	 * Pass lock to next waiter.
> > > > > > > > > +	 * smp_store_release() provides a memory barrier to ensure
> > > > > > > > > +	 * all operations in the critical section has been completed
> > > > > > > > > +	 * before unlocking.
> > > > > > > > > +	 */
> > > > > > > > > +	smp_store_release(&next->locked, 1);
> > > > > > > > 
> > > > > > > > However, there is one problem with this that I missed yesterday.
> > > > > > > > 
> > > > > > > > Documentation/memory-barriers.txt requires that an unlock-lock pair
> > > > > > > > provide a full barrier, but this is not guaranteed if we use
> > > > > > > > smp_store_release() for unlock and smp_load_acquire() for lock.
> > > > > > > > At least one of these needs a full memory barrier.
> > > > > > > 
> > > > > > > Hmm, so in the following case:
> > > > > > > 
> > > > > > >   Access A
> > > > > > >   unlock()	/* release semantics */
> > > > > > >   lock()	/* acquire semantics */
> > > > > > >   Access B
> > > > > > > 
> > > > > > > A cannot pass beyond the unlock() and B cannot pass the before the lock().
> > > > > > > 
> > > > > > > I agree that accesses between the unlock and the lock can be move across both
> > > > > > > A and B, but that doesn't seem to matter by my reading of the above.
> > > > > > > 
> > > > > > > What is the problematic scenario you have in mind? Are you thinking of the
> > > > > > > lock() moving before the unlock()? That's only permitted by RCpc afaiu,
> > > > > > > which I don't think any architectures supported by Linux implement...
> > > > > > > (ARMv8 acquire/release is RCsc).
> > > > > > 
> > > > > > If smp_load_acquire() and smp_store_release() are both implemented using
> > > > > > lwsync on powerpc, and if Access A is a store and Access B is a load,
> > > > > > then Access A and Access B can be reordered.
> > > > > > 
> > > > > > Of course, if every other architecture will be providing RCsc implementations
> > > > > > for smp_load_acquire() and smp_store_release(), which would not be a bad
> > > > > > thing, then another approach is for powerpc to use sync rather than lwsync
> > > > > > for one or the other of smp_load_acquire() or smp_store_release().
> > > > > 
> > > > > Can we count on the xchg function in the beginning of mcs_lock to
> > > > > provide a memory barrier? It should provide an implicit memory
> > > > > barrier according to the memory-barriers document.
> > > > 
> > > > The problem with the implicit full barrier associated with the xchg()
> > > > function is that it is in the wrong place if the lock is contended.
> > > > We need to ensure that the previous lock holder's critical section
> > > > is seen by everyone to precede that of the next lock holder, and
> > > > we need transitivity.  The only operations that are in the right place
> > > > to force the needed ordering in the contended case are those involved
> > > > in the lock handoff.  :-(
> > > > 
> > > 
> > > Paul,
> > > 
> > > I'm still scratching my head on how ACCESS A 
> > > and ACCESS B could get reordered.
> > > 
> > > The smp_store_release instruction in unlock should guarantee that
> > > all memory operations in the previous lock holder's critical section has
> > > been completed and seen by everyone, before the store operation 
> > > to set the lock for the next holder is seen. And the 
> > > smp_load_acquire should guarantee that all memory operations 
> > > for next lock holder happen after checking that it has got lock.  
> > > So it seems like the two critical sections should not overlap.
> > > 
> > > Does using lwsync means that these smp_load_acquire 
> > > and smp_store_release guarantees are no longer true?
> > 
> 
> Thanks for the detailed explanation.
> 
> > Suppose that CPU 0 stores to a variable, then releases a lock,
> > CPU 1 acquires that same lock and reads a second variable,
> > and that CPU 2 writes the second variable, does smp_mb(), and
> > then reads the first variable.  Like this, where we replace the
> > spinloop by a check in the assertion:
> > 
> > 	CPU 0		CPU 1			CPU 2
> > 	-----		-----			-----
> > 	x = 1;		r1 = SLA(lock);		y = 1;
> > 	SSR(lock, 1);	r2 = y;			smp_mb();
> > 						r3 = x;
> > 
> > The SSR() is an abbreviation for smp_store_release() and the SLA()
> > is an abbreviation for smp_load_acquire().
> > 
> > Now, if an unlock and following lock act as a full memory barrier, and
> > given lock, x, and y all initially zero, it should not be possible to
> > see the following situation:
> > 
> > 	r1 == 1 && r2 == 0 && r3 == 0
> > 
> > The "r1 == 1" means that the lock was released, the "r2 == 1" means that
> 
> You mean "r2 == 0"?

I do, good catch!

> > CPU 1's load from y happened before CPU 2's assignment to y, and the
> > "r3 == 0" means that CPU 2's load from x happened before CPU 0's store
> > to x.  If the unlock/lock combination was acting like a full barrier,
> > this would be impossible.  But if you implement both SSR() and SLA() with
> > lwsync on powerpc, this condition can in fact happen.  See scenario W+RWC
> > on page 2 of: http://www.cl.cam.ac.uk/~pes20/ppc-supplemental/test6.pdf.
> > 
> > This may seem strange, but when you say "lwsync" you are saying "don't
> > bother flushing the store buffer", which in turn allows this outcome.
> 
> Yes, this outcome is certainly not expected.  I find the behavior
> somewhat at odds with the memory barrier documentation:
>    
> "The use of ACQUIRE and RELEASE operations generally precludes the need
> for other sorts of memory barrier (but note the exceptions mentioned in
> the subsection "MMIO write barrier")."

Well, ACQUIRE and RELEASE can do a great number of things, just not
everything.

> > So if we require that smp_load_acquire() and smp_store_release() have
> > RCsc semantics, which we might well want to do, then your use becomes
> > legal and powerpc needs smp_store_release() to have a sync instruction
> > rather than the lighter-weight lwsync instruction.  Otherwise, you need
> > an smp_mb() in the lock-release handoff path.
> > 
> > Thoughts?
> 
> If we intend to use smp_load_acquire and smp_store_release extensively
> for locks, making RCsc semantics the default will simply things a lot.

The other option is to weaken lock semantics so that unlock-lock no
longer implies a full barrier, but I believe that we would regret taking
that path.  (It would be OK by me, I would just add a few smp_mb()
calls on various slowpaths in RCU.  But...)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
