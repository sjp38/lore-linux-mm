Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 45491900001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 03:18:56 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4D6x6PM022794
	for <linux-mm@kvack.org>; Fri, 13 May 2011 02:59:06 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4D7IqZA084596
	for <linux-mm@kvack.org>; Fri, 13 May 2011 03:18:52 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4D7IpJs020336
	for <linux-mm@kvack.org>; Fri, 13 May 2011 03:18:52 -0400
Date: Fri, 13 May 2011 00:18:50 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc6-mmotm0506 - lockdep splat in RCU code on page fault
Message-ID: <20110513071850.GU2258@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <6921.1304989476@localhost>
 <20110510082029.GF2258@linux.vnet.ibm.com>
 <34783.1305155494@localhost>
 <20110512094704.GL2258@linux.vnet.ibm.com>
 <5817.1305216324@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5817.1305216324@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 12, 2011 at 12:05:24PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 12 May 2011 02:47:05 PDT, "Paul E. McKenney" said:
> > On Wed, May 11, 2011 at 07:11:34PM -0400, Valdis.Kletnieks@vt.edu wrote:
> > > My source has this:
> > >
> > >         raw_spin_lock_irqsave(&rnp->lock, flags);
> > >         rnp->wakemask |= rdp->grpmask;
> > >         invoke_rcu_node_kthread(rnp);
> > >         raw_spin_unlock_irqrestore(&rnp->lock, flags);
> > >
> > > the last 2 lines swapped from what you diffed against.  I can easily work around
> > > that, except it's unclear what the implications of the invoke_rcu moving outside
> > > of the irq save/restore pair (or if it being inside is the actual root cause)...
> >
> > Odd...
> >
> > This looks to me like a recent -next -- I do not believe that straight
> > mmotm has rcu_cpu_kthread_timer() in it.  The patch should apply to the
> > last few days' -next kernels.
> 
> Ah. Found it. Your tree and current linux-next include this commit:
> 
> commit	1217ed1ba5c67393293dfb0f03c353b118dadeb4
> tree	a765356c8418e134de85fd05d9fe6eda41de859c	tree | snapshot
> parent	29ce831000081dd757d3116bf774aafffc4b6b20	commit | diff
> rcu: permit rcu_read_unlock() to be called while holding runqueue locks
> 
> which includes this chunk:
> 
> @@ -1546,8 +1531,8 @@ static void rcu_cpu_kthread_timer(unsigned long arg)
> 
>         raw_spin_lock_irqsave(&rnp->lock, flags);
>         rnp->wakemask |= rdp->grpmask;
> -       invoke_rcu_node_kthread(rnp);
>         raw_spin_unlock_irqrestore(&rnp->lock, flags);
> +       invoke_rcu_node_kthread(rnp);
>  }
> 
> 
> but that was committed 4 days ago, and Andrew pulled linux-next for the -mmotm
> 6 days ago, so it's not in there.  The *rest* of your recent commits appear to
> be in there though.  So that explains the patch failure to apply.

Whew!!!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
