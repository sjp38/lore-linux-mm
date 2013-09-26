Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 640626B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 16:41:07 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so1644188pdj.40
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 13:41:07 -0700 (PDT)
Message-ID: <1380228059.2170.10.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 26 Sep 2013 13:40:59 -0700
In-Reply-To: <1380226997.2602.11.camel@j-VirtualBox>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
	 <1380147049.3467.67.camel@schen9-DESK>
	 <CAGQ1y=7Ehkr+ot3tDZtHv6FR6RQ9fXBVY0=LOyWjmGH_UjH7xA@mail.gmail.com>
	 <1380226007.2170.2.camel@buesod1.americas.hpqcorp.net>
	 <1380226997.2602.11.camel@j-VirtualBox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu, 2013-09-26 at 13:23 -0700, Jason Low wrote:
> On Thu, 2013-09-26 at 13:06 -0700, Davidlohr Bueso wrote:
> > On Thu, 2013-09-26 at 12:27 -0700, Jason Low wrote:
> > > On Wed, Sep 25, 2013 at 3:10 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
> > > > We will need the MCS lock code for doing optimistic spinning for rwsem.
> > > > Extracting the MCS code from mutex.c and put into its own file allow us
> > > > to reuse this code easily for rwsem.
> > > >
> > > > Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> > > > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > > > ---
> > > >  include/linux/mcslock.h |   58 +++++++++++++++++++++++++++++++++++++++++++++++
> > > >  kernel/mutex.c          |   58 +++++-----------------------------------------
> > > >  2 files changed, 65 insertions(+), 51 deletions(-)
> > > >  create mode 100644 include/linux/mcslock.h
> > > >
> > > > diff --git a/include/linux/mcslock.h b/include/linux/mcslock.h
> > > > new file mode 100644
> > > > index 0000000..20fd3f0
> > > > --- /dev/null
> > > > +++ b/include/linux/mcslock.h
> > > > @@ -0,0 +1,58 @@
> > > > +/*
> > > > + * MCS lock defines
> > > > + *
> > > > + * This file contains the main data structure and API definitions of MCS lock.
> > > > + */
> > > > +#ifndef __LINUX_MCSLOCK_H
> > > > +#define __LINUX_MCSLOCK_H
> > > > +
> > > > +struct mcs_spin_node {
> > > > +       struct mcs_spin_node *next;
> > > > +       int               locked;       /* 1 if lock acquired */
> > > > +};
> > > > +
> > > > +/*
> > > > + * We don't inline mcs_spin_lock() so that perf can correctly account for the
> > > > + * time spent in this lock function.
> > > > + */
> > > > +static noinline
> > > > +void mcs_spin_lock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
> > > > +{
> > > > +       struct mcs_spin_node *prev;
> > > > +
> > > > +       /* Init node */
> > > > +       node->locked = 0;
> > > > +       node->next   = NULL;
> > > > +
> > > > +       prev = xchg(lock, node);
> > > > +       if (likely(prev == NULL)) {
> > > > +               /* Lock acquired */
> > > > +               node->locked = 1;
> > > 
> > > If we don't spin on the local node, is it necessary to set this variable?
> > 
> > I don't follow, the whole idea is to spin on the local variable.
> 
> If prev == NULL, doesn't that mean it won't proceed to spin on the
> variable because the lock is already free and we call return? In that
> case where we directly acquire the lock, I was wondering if it is
> necessary to set node->locked = 1.

Yes, that's true, but we need to flag the lock as acquired (the node's
lock is initially set to unlocked), otherwise others trying to acquire
the lock can spin forever:

	/* Wait until the lock holder passes the lock down */
	while (!ACCESS_ONCE(node->locked))
		arch_mutex_cpu_relax();

The ->locked variable in this implementation refers to if the lock is
acquired, and *not* to if busy-waiting is necessary.

Thanks,
Davidlohr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
