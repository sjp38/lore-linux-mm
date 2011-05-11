Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BAD026B0011
	for <linux-mm@kvack.org>; Wed, 11 May 2011 03:44:06 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4B7HIVN010585
	for <linux-mm@kvack.org>; Wed, 11 May 2011 03:17:18 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4B7i48o096090
	for <linux-mm@kvack.org>; Wed, 11 May 2011 03:44:04 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4B7i4uk004932
	for <linux-mm@kvack.org>; Wed, 11 May 2011 03:44:04 -0400
Date: Wed, 11 May 2011 00:44:03 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc6-mmotm0506 - lockdep splat in RCU code on page fault
Message-ID: <20110511074403.GW2258@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <6921.1304989476@localhost>
 <20110510082029.GF2258@linux.vnet.ibm.com>
 <20110510085746.GG27426@elte.hu>
 <20110510162158.GK2258@linux.vnet.ibm.com>
 <20110510204443.GF21903@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110510204443.GF21903@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Valdis.Kletnieks@vt.edu, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 10, 2011 at 10:44:43PM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Tue, May 10, 2011 at 10:57:46AM +0200, Ingo Molnar wrote:
> > > 
> > > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > 
> > > > -	raw_spin_lock_irqsave(&rnp->lock, flags);
> > > > -	rnp->wakemask |= rdp->grpmask;
> > > > -	raw_spin_unlock_irqrestore(&rnp->lock, flags);
> > > > +	do {
> > > > +		old = rnp->wakemask;
> > > > +		new = old | rdp->grpmask;
> > > > +	} while (cmpxchg(&rnp->wakemask, old, new) != old);
> > > 
> > > Hm, isnt this an inferior version of atomic_or_long() in essence?
> > > 
> > > Note that atomic_or_long() is x86 only, so a generic one would have to be 
> > > offered too i suspect, atomic_cmpxchg() driven or so - which would look like 
> > > the above loop.
> > > 
> > > Most architectures could offer atomic_or_long() i suspect.
> > 
> > Is the following what you had in mind?  This (untested) patch provides only 
> > the generic function: if this is what you had in mind, I can put together 
> > optimized versions for a couple of the architectures.
> 
> Yeah, something like this, except:
> 
> > +#ifndef CONFIG_ARCH_HAS_ATOMIC_OR_LONG
> > +static inline void atomic_or_long(unsigned long *v1, unsigned long v2)
> > +{
> > +	unsigned long old;
> > +	unsigned long new;
> > +
> > +	do {
> > +		old = ACCESS_ONCE(*v1);
> > +		new = old | v2;
> > +	} while (cmpxchg(v1, old, new) != old);
> > +}
> > +#endif /* #ifndef CONFIG_ARCH_HAS_ATOMIC_OR_LONG */
> 
> Shouldnt that method work on atomic_t (or atomic64_t)?

Works for me -- and in this case it is quite easy to change existing uses.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
