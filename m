Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECB06B00F4
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 13:22:19 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so30644pab.28
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 10:22:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.142])
        by mx.google.com with SMTP id qj1si12319745pbc.24.2013.11.06.10.22.16
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 10:22:17 -0800 (PST)
Subject: Re: [PATCH v2 3/4] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20131106144520.GK18245@linux.vnet.ibm.com>
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>
	 <1383673356.11046.279.camel@schen9-DESK>
	 <20131105183744.GJ26895@mudshark.cambridge.arm.com>
	 <1383679317.11046.293.camel@schen9-DESK>
	 <20131105211803.GS28601@twins.programming.kicks-ass.net>
	 <20131106144520.GK18245@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Nov 2013 10:22:13 -0800
Message-ID: <1383762133.11046.339.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

On Wed, 2013-11-06 at 06:45 -0800, Paul E. McKenney wrote:
> On Tue, Nov 05, 2013 at 10:18:03PM +0100, Peter Zijlstra wrote:
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
> > PaulMck completely confused me a few days ago with control dependencies
> > etc.. Pretty much saying that C/C++ doesn't do those.
> 
> I remember that there was a subtlety here, but don't remember what it was...
> 
> And while I do remember reviewing this code, I don't find any evidence
> that I gave my "Reviewed-by".  Tim/Jason, if I fat-fingered this, please
> forward that email back to me.

Yes Paul, you didn't explicitly gave the Reviewed-by. 
I put it in there because you have given valuable
comments on the potential critical section bleeding when 
reviewing initial version of the code.

I'll take it out now till you have explicitly given it.
Appreciate if you can provide your feedback on the current
version of code.

Thanks.

Tim

> 
> 							Thanx, Paul
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
