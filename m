Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7C16B6B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 19:01:46 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so3152935pbc.15
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:01:46 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 27 Sep 2013 17:01:43 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 478EA1FF001B
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 17:01:33 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8RN1dqi310414
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 17:01:39 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8RN4gPb013917
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 17:04:43 -0600
Date: Fri, 27 Sep 2013 16:01:37 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20130927230137.GE9093@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
 <1380147049.3467.67.camel@schen9-DESK>
 <20130927152953.GA4464@linux.vnet.ibm.com>
 <1380310733.3467.118.camel@schen9-DESK>
 <20130927203858.GB9093@linux.vnet.ibm.com>
 <1380322005.3467.186.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380322005.3467.186.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, Sep 27, 2013 at 03:46:45PM -0700, Tim Chen wrote:
> On Fri, 2013-09-27 at 13:38 -0700, Paul E. McKenney wrote:
> > On Fri, Sep 27, 2013 at 12:38:53PM -0700, Tim Chen wrote:
> > > On Fri, 2013-09-27 at 08:29 -0700, Paul E. McKenney wrote:
> > > > On Wed, Sep 25, 2013 at 03:10:49PM -0700, Tim Chen wrote:
> > > > > We will need the MCS lock code for doing optimistic spinning for rwsem.
> > > > > Extracting the MCS code from mutex.c and put into its own file allow us
> > > > > to reuse this code easily for rwsem.
> > > > > 
> > > > > Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> > > > > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > > > > ---
> > > > >  include/linux/mcslock.h |   58 +++++++++++++++++++++++++++++++++++++++++++++++
> > > > >  kernel/mutex.c          |   58 +++++-----------------------------------------
> > > > >  2 files changed, 65 insertions(+), 51 deletions(-)
> > > > >  create mode 100644 include/linux/mcslock.h
> > > > > 
> > > > > diff --git a/include/linux/mcslock.h b/include/linux/mcslock.h
> > > > > new file mode 100644
> > > > > index 0000000..20fd3f0
> > > > > --- /dev/null
> > > > > +++ b/include/linux/mcslock.h
> > > > > @@ -0,0 +1,58 @@
> > > > > +/*
> > > > > + * MCS lock defines
> > > > > + *
> > > > > + * This file contains the main data structure and API definitions of MCS lock.
> > > > > + */
> > > > > +#ifndef __LINUX_MCSLOCK_H
> > > > > +#define __LINUX_MCSLOCK_H
> > > > > +
> > > > > +struct mcs_spin_node {
> > > > > +	struct mcs_spin_node *next;
> > > > > +	int		  locked;	/* 1 if lock acquired */
> > > > > +};
> > > > > +
> > > > > +/*
> > > > > + * We don't inline mcs_spin_lock() so that perf can correctly account for the
> > > > > + * time spent in this lock function.
> > > > > + */
> > > > > +static noinline
> > > > > +void mcs_spin_lock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
> > > > > +{
> > > > > +	struct mcs_spin_node *prev;
> > > > > +
> > > > > +	/* Init node */
> > > > > +	node->locked = 0;
> > > > > +	node->next   = NULL;
> > > > > +
> > > > > +	prev = xchg(lock, node);
> > > > > +	if (likely(prev == NULL)) {
> > > > > +		/* Lock acquired */
> > > > > +		node->locked = 1;
> > > > > +		return;
> > > > > +	}
> > > > > +	ACCESS_ONCE(prev->next) = node;
> > > > > +	smp_wmb();
> > > 
> > > BTW, is the above memory barrier necessary?  It seems like the xchg
> > > instruction already provided a memory barrier.
> > > 
> > > Now if we made the changes that Jason suggested:
> > > 
> > > 
> > >         /* Init node */
> > > -       node->locked = 0;
> > >         node->next   = NULL;
> > > 
> > >         prev = xchg(lock, node);
> > >         if (likely(prev == NULL)) {
> > >                 /* Lock acquired */
> > > -               node->locked = 1;
> > >                 return;
> > >         }
> > > +       node->locked = 0;
> > >         ACCESS_ONCE(prev->next) = node;
> > >         smp_wmb();
> > > 
> > > We are probably still okay as other cpus do not read the value of
> > > node->locked, which is a local variable.
> > 
> > I don't immediately see the need for the smp_wmb() in either case.
> 
> 
> Thinking a bit more, the following could happen in Jason's 
> initial patch proposal.  In this case variable "prev" referenced 
> by CPU1 points to "node" referenced by CPU2  
> 
> 	CPU 1 (calling lock)			CPU 2 (calling unlock)
> 	ACCESS_ONCE(prev->next) = node
> 						*next = ACCESS_ONCE(node->next);
> 						ACCESS_ONCE(next->locked) = 1;
> 	node->locked = 0;
> 
> Then we will be spinning forever on CPU1 as we overwrite the lock passed
> from CPU2 before we check it.  The original code assign 
> "node->locked = 0" before xchg does not have this issue.
> Doing the following change of moving smp_wmb immediately
> after node->locked assignment (suggested by Jason)
> 
> 	node->locked = 0;
> 	smp_wmb();
> 	ACCESS_ONCE(prev->next) = node;
> 
> could avoid the problem, but will need closer scrutiny to see if
> there are other pitfalls if wmb happen before 
> 	
> 	ACCESS_ONCE(prev->next) = node;

I could believe that an smp_wmb() might be needed before the
"ACCESS_ONCE(prev->next) = node;", just not after.

> > > > > +	/* Wait until the lock holder passes the lock down */
> > > > > +	while (!ACCESS_ONCE(node->locked))
> > > > > +		arch_mutex_cpu_relax();
> > 
> > However, you do need a full memory barrier here in order to ensure that
> > you see the effects of the previous lock holder's critical section.
> 
> Is it necessary to add a memory barrier after acquiring
> the lock if the previous lock holder execute smp_wmb before passing
> the lock?

Yep.  The previous lock holder's smp_wmb() won't keep either the compiler
or the CPU from reordering things for the new lock holder.  They could for
example reorder the critical section to precede the node->locked check,
which would be very bad.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
