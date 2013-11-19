Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BC87A6B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 18:30:46 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so4467728pdj.1
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 15:30:46 -0800 (PST)
Received: from psmtp.com ([74.125.245.179])
        by mx.google.com with SMTP id sg3si12669681pbb.343.2013.11.19.15.30.44
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 15:30:45 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Nov 2013 16:30:43 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0A5B23E40045
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 16:30:41 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAJLSsXq20775116
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 22:28:54 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAJNXXM2032008
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 16:33:34 -0700
Date: Tue, 19 Nov 2013 15:30:38 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 4/4] MCS Lock: Barrier corrections
Message-ID: <20131119233037.GX4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940358.11046.417.camel@schen9-DESK>
 <20131111181049.GL28302@mudshark.cambridge.arm.com>
 <1384204673.10046.6.camel@schen9-mobl3>
 <52818B07.70000@hp.com>
 <20131119193224.GT4138@linux.vnet.ibm.com>
 <1384897503.11046.445.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384897503.11046.445.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Waiman Long <waiman.long@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 19, 2013 at 01:45:03PM -0800, Tim Chen wrote:
> On Tue, 2013-11-19 at 11:32 -0800, Paul E. McKenney wrote:
> > On Mon, Nov 11, 2013 at 08:57:27PM -0500, Waiman Long wrote:
> > > On 11/11/2013 04:17 PM, Tim Chen wrote:
> > > >>You could then augment that with [cmp]xchg_{acquire,release} as
> > > >>appropriate.
> > > >>
> > > >>>+/*
> > > >>>   * In order to acquire the lock, the caller should declare a local node and
> > > >>>   * pass a reference of the node to this function in addition to the lock.
> > > >>>   * If the lock has already been acquired, then this will proceed to spin
> > > >>>@@ -37,15 +62,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > > >>>  	node->locked = 0;
> > > >>>  	node->next   = NULL;
> > > >>>
> > > >>>-	prev = xchg(lock, node);
> > > >>>+	/* xchg() provides a memory barrier */
> > > >>>+	prev = xchg_acquire(lock, node);
> > > >>>  	if (likely(prev == NULL)) {
> > > >>>  		/* Lock acquired */
> > > >>>  		return;
> > > >>>  	}
> > > >>>  	ACCESS_ONCE(prev->next) = node;
> > > >>>-	smp_wmb();
> > > >>>-	/* Wait until the lock holder passes the lock down */
> > > >>>-	while (!ACCESS_ONCE(node->locked))
> > > >>>+	/*
> > > >>>+	 * Wait until the lock holder passes the lock down.
> > > >>>+	 * Using smp_load_acquire() provides a memory barrier that
> > > >>>+	 * ensures subsequent operations happen after the lock is acquired.
> > > >>>+	 */
> > > >>>+	while (!(smp_load_acquire(&node->locked)))
> > > >>>  		arch_mutex_cpu_relax();
> > > >An alternate implementation is
> > > >	while (!ACCESS_ONCE(node->locked))
> > > >		arch_mutex_cpu_relax();
> > > >	smp_load_acquire(&node->locked);
> > > >
> > > >Leaving the smp_load_acquire at the end to provide appropriate barrier.
> > > >Will that be acceptable?
> > > >
> > > >Tim
> > > 
> > > I second Tim's opinion. It will be help to have a
> > > smp_mb_load_acquire() function that provide a memory barrier with
> > > load-acquire semantic. I don't think we need one for store-release
> > > as that will not be in a loop.
> > 
> > Hmmm...  I guess the ACCESS_ONCE() in the smp_load_acquire() should
> > prevent it from being optimized away.  But yes, you then end up with
> > an extra load on the critical lock hand-off patch.  And something
> > like an smp_mb_acquire() could then be useful, although I believe
> > that on all current hardware smp_mb_acquire() emits the same code
> > as would an smp_mb_release():
> > 
> > o	barrier() on TSO systems such as x86 and s390.
> > 
> > o	lwsync instruction on powerpc.  (Really old systems would
> > 	want a different instruction for smp_mb_acquire(), but let's
> > 	not optimize for really old systems.)
> > 
> > o	dmb instruction on ARM.
> > 
> > o	mf instruction on ia64.
> > 
> > So how about an smp_mb_acquire_release() to cover both use cases?
> 
> I guess we haven't addressed Will's preference to use wfe for ARM
> instead of doing a spin loop.  I'll like some suggestions on how to
> proceed here.  Should we do arch_mcs_lock and arch_mcs_unlock, which
> defaults to the existing mcs_lock and mcs_unlock code, but allow
> architecture specific implementation?

It would be nice to confine the architecture-specific pieces if at all
possible.  For example, can the architecture-specific piece be confined
to the actual high-contention lock handoff?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
