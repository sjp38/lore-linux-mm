Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 48B2E6B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 20:02:41 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so3260052pdi.28
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 17:02:40 -0700 (PDT)
Message-ID: <1380326552.12518.10.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 27 Sep 2013 17:02:32 -0700
In-Reply-To: <CAGQ1y=7YbB_BouYZVJwAZ9crkSMLVCxg8hoqcO_7sXHRrZ90_A@mail.gmail.com>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
	 <1380147049.3467.67.camel@schen9-DESK>
	 <20130927152953.GA4464@linux.vnet.ibm.com>
	 <1380310733.3467.118.camel@schen9-DESK>
	 <20130927203858.GB9093@linux.vnet.ibm.com>
	 <1380322005.3467.186.camel@schen9-DESK>
	 <20130927230137.GE9093@linux.vnet.ibm.com>
	 <CAGQ1y=7YbB_BouYZVJwAZ9crkSMLVCxg8hoqcO_7sXHRrZ90_A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <Waiman.Long@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-09-27 at 16:54 -0700, Jason Low wrote:
> On Fri, Sep 27, 2013 at 4:01 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > Yep.  The previous lock holder's smp_wmb() won't keep either the compiler
> > or the CPU from reordering things for the new lock holder.  They could for
> > example reorder the critical section to precede the node->locked check,
> > which would be very bad.
> 
> Paul, Tim, Longman,
> 
> How would you like the proposed changes below?
> 
> ---
> Subject: [PATCH] MCS: optimizations and barrier corrections

We *really* need to comment those barriers - explicitly that is :)

> 
> Delete the node->locked = 1 assignment if the lock is free as it won't be used.
> 
> Delete the smp_wmb() in mcs_spin_lock() and add a full memory barrier at the
> end of the mcs_spin_lock() function. As Paul McKenney suggested, "you do need a
> full memory barrier here in order to ensure that you see the effects of the
> previous lock holder's critical section." And in the mcs_spin_unlock(), move the
> memory barrier so that it is before the "ACCESS_ONCE(next->locked) = 1;".
> 
> Signed-off-by: Jason Low <jason.low2@hp.com>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>  include/linux/mcslock.h |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/mcslock.h b/include/linux/mcslock.h
> index 20fd3f0..edd57d2 100644
> --- a/include/linux/mcslock.h
> +++ b/include/linux/mcslock.h
> @@ -26,15 +26,14 @@ void mcs_spin_lock(struct mcs_spin_node **lock,
> struct mcs_spin_node *node)
> 
>         prev = xchg(lock, node);
>         if (likely(prev == NULL)) {
> -               /* Lock acquired */
> -               node->locked = 1;
> +               /* Lock acquired. No need to set node->locked since it
> won't be used */

Then, we need to explain/comment then the relationship between this
situation and the locked being set in mspin_unlock(), passing the lock
holder down the list.

>                 return;
>         }
>         ACCESS_ONCE(prev->next) = node;
> -       smp_wmb();
>         /* Wait until the lock holder passes the lock down */
>         while (!ACCESS_ONCE(node->locked))
>                 arch_mutex_cpu_relax();
> +       smp_mb();
>  }
> 
>  static void mcs_spin_unlock(struct mcs_spin_node **lock, struct
> mcs_spin_node *node)
> @@ -51,8 +50,8 @@ static void mcs_spin_unlock(struct mcs_spin_node
> **lock, struct mcs_spin_node *n
>                 while (!(next = ACCESS_ONCE(node->next)))
>                         arch_mutex_cpu_relax();
>         }
> -       ACCESS_ONCE(next->locked) = 1;
>         smp_wmb();
> +       ACCESS_ONCE(next->locked) = 1;
>  }
> 
>  #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
