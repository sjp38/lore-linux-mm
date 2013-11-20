Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id ACC176B0036
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:14:10 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so5673933pbb.22
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:14:10 -0800 (PST)
Received: from psmtp.com ([74.125.245.155])
        by mx.google.com with SMTP id am2si14691268pad.212.2013.11.20.09.14.08
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:14:09 -0800 (PST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 20 Nov 2013 10:14:07 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id BC6323E4003F
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 10:14:03 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAKFCGmY25886842
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 16:12:16 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAKHGtKt010430
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 10:16:57 -0700
Date: Wed, 20 Nov 2013 09:14:00 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131120171400.GI4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
 <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131120154643.GG19352@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, Nov 20, 2013 at 03:46:43PM +0000, Will Deacon wrote:
> Hi Paul,
> 
> On Wed, Nov 20, 2013 at 03:31:23PM +0000, Paul E. McKenney wrote:
> > On Tue, Nov 19, 2013 at 05:37:43PM -0800, Tim Chen wrote:
> > > @@ -68,7 +72,12 @@ void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > >  		while (!(next = ACCESS_ONCE(node->next)))
> > >  			arch_mutex_cpu_relax();
> > >  	}
> > > -	ACCESS_ONCE(next->locked) = 1;
> > > -	smp_wmb();
> > > +	/*
> > > +	 * Pass lock to next waiter.
> > > +	 * smp_store_release() provides a memory barrier to ensure
> > > +	 * all operations in the critical section has been completed
> > > +	 * before unlocking.
> > > +	 */
> > > +	smp_store_release(&next->locked, 1);
> > 
> > However, there is one problem with this that I missed yesterday.
> > 
> > Documentation/memory-barriers.txt requires that an unlock-lock pair
> > provide a full barrier, but this is not guaranteed if we use
> > smp_store_release() for unlock and smp_load_acquire() for lock.
> > At least one of these needs a full memory barrier.
> 
> Hmm, so in the following case:
> 
>   Access A
>   unlock()	/* release semantics */
>   lock()	/* acquire semantics */
>   Access B
> 
> A cannot pass beyond the unlock() and B cannot pass the before the lock().
> 
> I agree that accesses between the unlock and the lock can be move across both
> A and B, but that doesn't seem to matter by my reading of the above.
> 
> What is the problematic scenario you have in mind? Are you thinking of the
> lock() moving before the unlock()? That's only permitted by RCpc afaiu,
> which I don't think any architectures supported by Linux implement...
> (ARMv8 acquire/release is RCsc).

If smp_load_acquire() and smp_store_release() are both implemented using
lwsync on powerpc, and if Access A is a store and Access B is a load,
then Access A and Access B can be reordered.

Of course, if every other architecture will be providing RCsc implementations
for smp_load_acquire() and smp_store_release(), which would not be a bad
thing, then another approach is for powerpc to use sync rather than lwsync
for one or the other of smp_load_acquire() or smp_store_release().

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
