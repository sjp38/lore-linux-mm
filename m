Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9226B0085
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 14:22:03 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id p10so8956154pdj.39
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 11:22:02 -0800 (PST)
Received: from psmtp.com ([74.125.245.151])
        by mx.google.com with SMTP id ei3si14436019pbc.290.2013.11.05.11.22.01
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 11:22:02 -0800 (PST)
Subject: Re: [PATCH v2 3/4] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20131105183744.GJ26895@mudshark.cambridge.arm.com>
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>
	 <1383673356.11046.279.camel@schen9-DESK>
	 <20131105183744.GJ26895@mudshark.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Nov 2013 11:21:57 -0800
Message-ID: <1383679317.11046.293.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

On Tue, 2013-11-05 at 18:37 +0000, Will Deacon wrote:
> On Tue, Nov 05, 2013 at 05:42:36PM +0000, Tim Chen wrote:
> > This patch corrects the way memory barriers are used in the MCS lock
> > and removes ones that are not needed. Also add comments on all barriers.
> 
> Hmm, I see that you're fixing up the barriers, but I still don't completely
> understand how what you have is correct. Hopefully you can help me out :)
> 
> > Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
> > Signed-off-by: Jason Low <jason.low2@hp.com>
> > ---
> >  include/linux/mcs_spinlock.h |   13 +++++++++++--
> >  1 files changed, 11 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> > index 96f14299..93d445d 100644
> > --- a/include/linux/mcs_spinlock.h
> > +++ b/include/linux/mcs_spinlock.h
> > @@ -36,16 +36,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> >  	node->locked = 0;
> >  	node->next   = NULL;
> >  
> > +	/* xchg() provides a memory barrier */
> >  	prev = xchg(lock, node);
> >  	if (likely(prev == NULL)) {
> >  		/* Lock acquired */
> >  		return;
> >  	}
> >  	ACCESS_ONCE(prev->next) = node;
> > -	smp_wmb();
> >  	/* Wait until the lock holder passes the lock down */
> >  	while (!ACCESS_ONCE(node->locked))
> >  		arch_mutex_cpu_relax();
> > +
> > +	/* Make sure subsequent operations happen after the lock is acquired */
> > +	smp_rmb();
> 
> Ok, so this is an smp_rmb() because we assume that stores aren't speculated,
> right? (i.e. the control dependency above is enough for stores to be ordered
> with respect to taking the lock)...
> 
> >  }
> >  
> >  /*
> > @@ -58,6 +61,7 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
> >  
> >  	if (likely(!next)) {
> >  		/*
> > +		 * cmpxchg() provides a memory barrier.
> >  		 * Release the lock by setting it to NULL
> >  		 */
> >  		if (likely(cmpxchg(lock, node, NULL) == node))
> > @@ -65,9 +69,14 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
> >  		/* Wait until the next pointer is set */
> >  		while (!(next = ACCESS_ONCE(node->next)))
> >  			arch_mutex_cpu_relax();
> > +	} else {
> > +		/*
> > +		 * Make sure all operations within the critical section
> > +		 * happen before the lock is released.
> > +		 */
> > +		smp_wmb();
> 
> ...but I don't see what prevents reads inside the critical section from
> moving across the smp_wmb() here.

This is to prevent any read in next critical section from
creeping up before write in the previous critical section
has completed

e.g.
CPU 1 execute
        mcs_lock
        x = 1;
        ...
        x = 2;
        mcs_unlock

and CPU 2 execute

        mcs_lock
        y = x;
        ...
        mcs_unlock

We expect y to be 2 after the "y = x" assignment. Without the proper 
rmb in lock and wmb in unlock, y could be 1 for CPU 2 with 
speculative read (i.e. before the x=2 assignment is completed).

Tim

> 
> What am I missing?
> 
> Will


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
