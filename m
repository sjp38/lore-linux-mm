Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B6D706B00D0
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 06:32:12 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so10329571pab.5
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 03:32:12 -0800 (PST)
Received: from psmtp.com ([74.125.245.173])
        by mx.google.com with SMTP id sj5si17078778pab.110.2013.11.06.03.32.09
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 03:32:11 -0800 (PST)
Date: Wed, 6 Nov 2013 11:30:18 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 3/4] MCS Lock: Barrier corrections
Message-ID: <20131106113018.GF21074@mudshark.cambridge.arm.com>
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>
 <1383673356.11046.279.camel@schen9-DESK>
 <20131105183744.GJ26895@mudshark.cambridge.arm.com>
 <1383679317.11046.293.camel@schen9-DESK>
 <20131105211803.GS28601@twins.programming.kicks-ass.net>
 <1383701153.11046.332.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383701153.11046.332.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

On Wed, Nov 06, 2013 at 01:25:53AM +0000, Tim Chen wrote:
> On Tue, 2013-11-05 at 22:18 +0100, Peter Zijlstra wrote:
> > On Tue, Nov 05, 2013 at 11:21:57AM -0800, Tim Chen wrote:
> > > On Tue, 2013-11-05 at 18:37 +0000, Will Deacon wrote:
> > > > On Tue, Nov 05, 2013 at 05:42:36PM +0000, Tim Chen wrote:
> > > > > This patch corrects the way memory barriers are used in the MCS lock
> > > > > and removes ones that are not needed. Also add comments on all barriers.
> > > > 
> > > > Hmm, I see that you're fixing up the barriers, but I still don't completely
> > > > understand how what you have is correct. Hopefully you can help me out :)
> > > > 
> > > > > Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > > > Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
> > > > > Signed-off-by: Jason Low <jason.low2@hp.com>
> > > > > ---
> > > > >  include/linux/mcs_spinlock.h |   13 +++++++++++--
> > > > >  1 files changed, 11 insertions(+), 2 deletions(-)
> > > > > 
> > > > > diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> > > > > index 96f14299..93d445d 100644
> > > > > --- a/include/linux/mcs_spinlock.h
> > > > > +++ b/include/linux/mcs_spinlock.h
> > > > > @@ -36,16 +36,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > > > >  	node->locked = 0;
> > > > >  	node->next   = NULL;
> > > > >  
> > > > > +	/* xchg() provides a memory barrier */
> > > > >  	prev = xchg(lock, node);
> > > > >  	if (likely(prev == NULL)) {
> > > > >  		/* Lock acquired */
> > > > >  		return;
> > > > >  	}
> > > > >  	ACCESS_ONCE(prev->next) = node;
> > > > > -	smp_wmb();
> > > > >  	/* Wait until the lock holder passes the lock down */
> > > > >  	while (!ACCESS_ONCE(node->locked))
> > > > >  		arch_mutex_cpu_relax();
> > > > > +
> > > > > +	/* Make sure subsequent operations happen after the lock is acquired */
> > > > > +	smp_rmb();
> > > > 
> > > > Ok, so this is an smp_rmb() because we assume that stores aren't speculated,
> > > > right? (i.e. the control dependency above is enough for stores to be ordered
> > > > with respect to taking the lock)...
> > 
> 
> The smp_rmb was put in to make sure that the lock
> is indeed set before we start doing speculative reads in next critical
> section.
> 
> Wonder if your concern is about the possibility of write in next 
> critical section bleeding into read in previous critical section?

Correct. You want to ensure that all accesses (reads and writes) that occur in
program order after taking the lock occur inside the critical section.

> If reads and writes are re-ordered in previous critical section before mcs_spin_unlock, 
> it may be possible that the previous critical section is still
> reading when it set the lock for the next mcs in mcs_spin_unlock.  
> This allows the next critical section to start writing prematurely, before 
> previous critical section finished all reads.  
> 
> If this concern is valid, we should change the smp_wmb() to smp_mb()
> in the unlock function, to make sure previous critical section has
> completed all operations before next section starts.

smp_rmb() is defined only to order reads against reads, so relying on the
control dependency feels fragile. (On arm64, an smp_rmb() actually orders
reads against reads/writes).

> > PaulMck completely confused me a few days ago with control dependencies
> > etc.. Pretty much saying that C/C++ doesn't do those.
> 
> Will appreciate feedback getting the barriers right.

I'm not up to speed with C11, but an smp_mb() is certainly clearer to me,
especially if you change the smb_wmb() in the unlock code into an smp_mb
too.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
