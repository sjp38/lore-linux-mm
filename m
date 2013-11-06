Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id E53A86B00B2
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 20:26:01 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rq13so4185456pbb.34
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 17:26:01 -0800 (PST)
Received: from psmtp.com ([74.125.245.191])
        by mx.google.com with SMTP id yh6si15603096pab.121.2013.11.05.17.25.59
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 17:26:00 -0800 (PST)
Subject: Re: [PATCH v2 3/4] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20131105211803.GS28601@twins.programming.kicks-ass.net>
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>
	 <1383673356.11046.279.camel@schen9-DESK>
	 <20131105183744.GJ26895@mudshark.cambridge.arm.com>
	 <1383679317.11046.293.camel@schen9-DESK>
	 <20131105211803.GS28601@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Nov 2013 17:25:53 -0800
Message-ID: <1383701153.11046.332.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

On Tue, 2013-11-05 at 22:18 +0100, Peter Zijlstra wrote:
> On Tue, Nov 05, 2013 at 11:21:57AM -0800, Tim Chen wrote:
> > On Tue, 2013-11-05 at 18:37 +0000, Will Deacon wrote:
> > > On Tue, Nov 05, 2013 at 05:42:36PM +0000, Tim Chen wrote:
> > > > This patch corrects the way memory barriers are used in the MCS lock
> > > > and removes ones that are not needed. Also add comments on all barriers.
> > > 
> > > Hmm, I see that you're fixing up the barriers, but I still don't completely
> > > understand how what you have is correct. Hopefully you can help me out :)
> > > 
> > > > Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > > Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
> > > > Signed-off-by: Jason Low <jason.low2@hp.com>
> > > > ---
> > > >  include/linux/mcs_spinlock.h |   13 +++++++++++--
> > > >  1 files changed, 11 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> > > > index 96f14299..93d445d 100644
> > > > --- a/include/linux/mcs_spinlock.h
> > > > +++ b/include/linux/mcs_spinlock.h
> > > > @@ -36,16 +36,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > > >  	node->locked = 0;
> > > >  	node->next   = NULL;
> > > >  
> > > > +	/* xchg() provides a memory barrier */
> > > >  	prev = xchg(lock, node);
> > > >  	if (likely(prev == NULL)) {
> > > >  		/* Lock acquired */
> > > >  		return;
> > > >  	}
> > > >  	ACCESS_ONCE(prev->next) = node;
> > > > -	smp_wmb();
> > > >  	/* Wait until the lock holder passes the lock down */
> > > >  	while (!ACCESS_ONCE(node->locked))
> > > >  		arch_mutex_cpu_relax();
> > > > +
> > > > +	/* Make sure subsequent operations happen after the lock is acquired */
> > > > +	smp_rmb();
> > > 
> > > Ok, so this is an smp_rmb() because we assume that stores aren't speculated,
> > > right? (i.e. the control dependency above is enough for stores to be ordered
> > > with respect to taking the lock)...
> 

The smp_rmb was put in to make sure that the lock
is indeed set before we start doing speculative reads in next critical
section.

Wonder if your concern is about the possibility of write in next 
critical section bleeding into read in previous critical section?

If reads and writes are re-ordered in previous critical section before mcs_spin_unlock, 
it may be possible that the previous critical section is still
reading when it set the lock for the next mcs in mcs_spin_unlock.  
This allows the next critical section to start writing prematurely, before 
previous critical section finished all reads.  

If this concern is valid, we should change the smp_wmb() to smp_mb()
in the unlock function, to make sure previous critical section has
completed all operations before next section starts.


> PaulMck completely confused me a few days ago with control dependencies
> etc.. Pretty much saying that C/C++ doesn't do those.

Will appreciate feedback getting the barriers right.

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
