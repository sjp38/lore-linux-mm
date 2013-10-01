Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6876B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 17:16:34 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so7800253pdi.19
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 14:16:34 -0700 (PDT)
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <524B2A01.4080403@hp.com>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
	 <1380147049.3467.67.camel@schen9-DESK>
	 <20130927152953.GA4464@linux.vnet.ibm.com>
	 <1380310733.3467.118.camel@schen9-DESK>
	 <20130927203858.GB9093@linux.vnet.ibm.com>
	 <1380322005.3467.186.camel@schen9-DESK>
	 <20130927230137.GE9093@linux.vnet.ibm.com>
	 <CAGQ1y=7YbB_BouYZVJwAZ9crkSMLVCxg8hoqcO_7sXHRrZ90_A@mail.gmail.com>
	 <20130928021947.GF9093@linux.vnet.ibm.com>
	 <CAGQ1y=5RnRsWdOe5CX6WYEJ2vUCFtHpj+PNC85NuEDH4bMdb0w@mail.gmail.com>
	 <52499E13.8050109@hp.com> <1380557440.14213.6.camel@j-VirtualBox>
	 <5249A8A4.9060400@hp.com> <1380646092.11046.6.camel@schen9-DESK>
	 <524B2A01.4080403@hp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Oct 2013 14:16:28 -0700
Message-ID: <1380662188.11046.37.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Jason Low <jason.low2@hp.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, 2013-10-01 at 16:01 -0400, Waiman Long wrote:
> On 10/01/2013 12:48 PM, Tim Chen wrote:
> > On Mon, 2013-09-30 at 12:36 -0400, Waiman Long wrote:
> >> On 09/30/2013 12:10 PM, Jason Low wrote:
> >>> On Mon, 2013-09-30 at 11:51 -0400, Waiman Long wrote:
> >>>> On 09/28/2013 12:34 AM, Jason Low wrote:
> >>>>>> Also, below is what the mcs_spin_lock() and mcs_spin_unlock()
> >>>>>> functions would look like after applying the proposed changes.
> >>>>>>
> >>>>>> static noinline
> >>>>>> void mcs_spin_lock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
> >>>>>> {
> >>>>>>            struct mcs_spin_node *prev;
> >>>>>>
> >>>>>>            /* Init node */
> >>>>>>            node->locked = 0;
> >>>>>>            node->next   = NULL;
> >>>>>>
> >>>>>>            prev = xchg(lock, node);
> >>>>>>            if (likely(prev == NULL)) {
> >>>>>>                    /* Lock acquired. No need to set node->locked since it
> >>>>>> won't be used */
> >>>>>>                    return;
> >>>>>>            }
> >>>>>>            ACCESS_ONCE(prev->next) = node;
> >>>>>>            /* Wait until the lock holder passes the lock down */
> >>>>>>            while (!ACCESS_ONCE(node->locked))
> >>>>>>                    arch_mutex_cpu_relax();
> >>>>>>            smp_mb();
> >>>> I wonder if a memory barrier is really needed here.
> >>> If the compiler can reorder the while (!ACCESS_ONCE(node->locked)) check
> >>> so that the check occurs after an instruction in the critical section,
> >>> then the barrier may be necessary.
> >>>
> >> In that case, just a barrier() call should be enough.
> > The cpu could still be executing out of order load instruction from the
> > critical section before checking node->locked?  Probably smp_mb() is
> > still needed.
> >
> > Tim
> 
> But this is the lock function, a barrier() call should be enough to 
> prevent the critical section from creeping up there. We certainly need 
> some kind of memory barrier at the end of the unlock function.

I may be missing something.  My understanding is that barrier only
prevents the compiler from rearranging instructions, but not for cpu out
of order execution (as in smp_mb). So cpu could read memory in the next
critical section, before node->locked is true, (i.e. unlock has been
completed).  If we only have a simple barrier at end of mcs_lock, then
say the code on CPU1 is

	mcs_lock
	x = 1;
	...
	x = 2;
	mcs_unlock

and CPU 2 is

	mcs_lock
	y = x;
	...
	mcs_unlock

We expect y to be 2 after the "y = x" assignment.  But we
we may execute the code as

	CPU1		CPU2
		
	x = 1;
	...		y = x;  ( y=1, out of order load)
	x = 2
	mcs_unlock
			Check node->locked==true
			continue executing critical section (y=1 when we expect y=2)

So we get y to be 1 when we expect that it should be 2.  Adding smp_mb
after the node->locked check in lock code

           ACCESS_ONCE(prev->next) = node;
           /* Wait until the lock holder passes the lock down */
           while (!ACCESS_ONCE(node->locked))
                    arch_mutex_cpu_relax();
           smp_mb();

should prevent this scenario.  

Thanks.
Tim
			
> 
> -Longman
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
