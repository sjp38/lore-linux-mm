Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAC36B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 15:36:12 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so4670707pab.4
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:36:11 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dj6si15027016pad.148.2013.11.20.12.36.10
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 12:36:10 -0800 (PST)
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20131120190616.GL4138@linux.vnet.ibm.com>
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
	 <1384911463.11046.454.camel@schen9-DESK>
	 <20131120153123.GF4138@linux.vnet.ibm.com>
	 <20131120154643.GG19352@mudshark.cambridge.arm.com>
	 <20131120171400.GI4138@linux.vnet.ibm.com>
	 <1384973026.11046.465.camel@schen9-DESK>
	 <20131120190616.GL4138@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Nov 2013 12:36:07 -0800
Message-ID: <1384979767.11046.489.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, 2013-11-20 at 11:06 -0800, Paul E. McKenney wrote:
> On Wed, Nov 20, 2013 at 10:43:46AM -0800, Tim Chen wrote:
> > On Wed, 2013-11-20 at 09:14 -0800, Paul E. McKenney wrote:
> > > On Wed, Nov 20, 2013 at 03:46:43PM +0000, Will Deacon wrote:
> > > > Hi Paul,
> > > > 
> > > > On Wed, Nov 20, 2013 at 03:31:23PM +0000, Paul E. McKenney wrote:
> > > > > On Tue, Nov 19, 2013 at 05:37:43PM -0800, Tim Chen wrote:
> > > > > > @@ -68,7 +72,12 @@ void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > > > > >  		while (!(next = ACCESS_ONCE(node->next)))
> > > > > >  			arch_mutex_cpu_relax();
> > > > > >  	}
> > > > > > -	ACCESS_ONCE(next->locked) = 1;
> > > > > > -	smp_wmb();
> > > > > > +	/*
> > > > > > +	 * Pass lock to next waiter.
> > > > > > +	 * smp_store_release() provides a memory barrier to ensure
> > > > > > +	 * all operations in the critical section has been completed
> > > > > > +	 * before unlocking.
> > > > > > +	 */
> > > > > > +	smp_store_release(&next->locked, 1);
> > > > > 
> > > > > However, there is one problem with this that I missed yesterday.
> > > > > 
> > > > > Documentation/memory-barriers.txt requires that an unlock-lock pair
> > > > > provide a full barrier, but this is not guaranteed if we use
> > > > > smp_store_release() for unlock and smp_load_acquire() for lock.
> > > > > At least one of these needs a full memory barrier.
> > > > 
> > > > Hmm, so in the following case:
> > > > 
> > > >   Access A
> > > >   unlock()	/* release semantics */
> > > >   lock()	/* acquire semantics */
> > > >   Access B
> > > > 
> > > > A cannot pass beyond the unlock() and B cannot pass the before the lock().
> > > > 
> > > > I agree that accesses between the unlock and the lock can be move across both
> > > > A and B, but that doesn't seem to matter by my reading of the above.
> > > > 
> > > > What is the problematic scenario you have in mind? Are you thinking of the
> > > > lock() moving before the unlock()? That's only permitted by RCpc afaiu,
> > > > which I don't think any architectures supported by Linux implement...
> > > > (ARMv8 acquire/release is RCsc).
> > > 
> > > If smp_load_acquire() and smp_store_release() are both implemented using
> > > lwsync on powerpc, and if Access A is a store and Access B is a load,
> > > then Access A and Access B can be reordered.
> > > 
> > > Of course, if every other architecture will be providing RCsc implementations
> > > for smp_load_acquire() and smp_store_release(), which would not be a bad
> > > thing, then another approach is for powerpc to use sync rather than lwsync
> > > for one or the other of smp_load_acquire() or smp_store_release().
> > 
> > Can we count on the xchg function in the beginning of mcs_lock to
> > provide a memory barrier? It should provide an implicit memory
> > barrier according to the memory-barriers document.
> 
> The problem with the implicit full barrier associated with the xchg()
> function is that it is in the wrong place if the lock is contended.
> We need to ensure that the previous lock holder's critical section
> is seen by everyone to precede that of the next lock holder, and
> we need transitivity.  The only operations that are in the right place
> to force the needed ordering in the contended case are those involved
> in the lock handoff.  :-(
> 

Paul,

I'm still scratching my head on how ACCESS A 
and ACCESS B could get reordered.

The smp_store_release instruction in unlock should guarantee that
all memory operations in the previous lock holder's critical section has
been completed and seen by everyone, before the store operation 
to set the lock for the next holder is seen. And the 
smp_load_acquire should guarantee that all memory operations 
for next lock holder happen after checking that it has got lock.  
So it seems like the two critical sections should not overlap.

Does using lwsync means that these smp_load_acquire 
and smp_store_release guarantees are no longer true?

Tim

> 							Thanx, Paul
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
