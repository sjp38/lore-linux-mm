Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A16C16B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 05:47:09 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4C9a3op019689
	for <linux-mm@kvack.org>; Thu, 12 May 2011 05:36:03 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4C9l74K122226
	for <linux-mm@kvack.org>; Thu, 12 May 2011 05:47:07 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4C9l6fV022016
	for <linux-mm@kvack.org>; Thu, 12 May 2011 05:47:07 -0400
Date: Thu, 12 May 2011 02:47:05 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc6-mmotm0506 - lockdep splat in RCU code on page fault
Message-ID: <20110512094704.GL2258@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <6921.1304989476@localhost>
 <20110510082029.GF2258@linux.vnet.ibm.com>
 <34783.1305155494@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <34783.1305155494@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 11, 2011 at 07:11:34PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 10 May 2011 01:20:29 PDT, "Paul E. McKenney" said:
> 
> Would test, but it doesn't apply cleanly to my -mmotm0506 tree:
> 
> > diff --git a/kernel/rcutree.c b/kernel/rcutree.c
> > index 5616b17..20c22c5 100644
> > --- a/kernel/rcutree.c
> > +++ b/kernel/rcutree.c
> > @@ -1525,13 +1525,15 @@ static void rcu_cpu_kthread_setrt(int cpu, int to_rt)
> >   */
> >  static void rcu_cpu_kthread_timer(unsigned long arg)
> >  {
> > -	unsigned long flags;
> > +	unsigned long old;
> > +	unsigned long new;
> >  	struct rcu_data *rdp = per_cpu_ptr(rcu_state->rda, arg);
> >  	struct rcu_node *rnp = rdp->mynode;
> >  
> > -	raw_spin_lock_irqsave(&rnp->lock, flags);
> > -	rnp->wakemask |= rdp->grpmask;
> > -	raw_spin_unlock_irqrestore(&rnp->lock, flags);
> > +	do {
> > +		old = rnp->wakemask;
> > +		new = old | rdp->grpmask;
> > +	} while (cmpxchg(&rnp->wakemask, old, new) != old);
> >  	invoke_rcu_node_kthread(rnp);
> >  }
> 
> My source has this:
> 
>         raw_spin_lock_irqsave(&rnp->lock, flags);
>         rnp->wakemask |= rdp->grpmask;
>         invoke_rcu_node_kthread(rnp);
>         raw_spin_unlock_irqrestore(&rnp->lock, flags);
> 
> the last 2 lines swapped from what you diffed against.  I can easily work around
> that, except it's unclear what the implications of the invoke_rcu moving outside
> of the irq save/restore pair (or if it being inside is the actual root cause)...

Odd...

This looks to me like a recent -next -- I do not believe that straight
mmotm has rcu_cpu_kthread_timer() in it.  The patch should apply to the
last few days' -next kernels.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
