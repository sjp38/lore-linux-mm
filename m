Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B40F56B0012
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:44:58 -0400 (EDT)
Date: Tue, 10 May 2011 22:44:43 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.39-rc6-mmotm0506 - lockdep splat in RCU code on page fault
Message-ID: <20110510204443.GF21903@elte.hu>
References: <6921.1304989476@localhost>
 <20110510082029.GF2258@linux.vnet.ibm.com>
 <20110510085746.GG27426@elte.hu>
 <20110510162158.GK2258@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110510162158.GK2258@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Valdis.Kletnieks@vt.edu, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> On Tue, May 10, 2011 at 10:57:46AM +0200, Ingo Molnar wrote:
> > 
> > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > > -	raw_spin_lock_irqsave(&rnp->lock, flags);
> > > -	rnp->wakemask |= rdp->grpmask;
> > > -	raw_spin_unlock_irqrestore(&rnp->lock, flags);
> > > +	do {
> > > +		old = rnp->wakemask;
> > > +		new = old | rdp->grpmask;
> > > +	} while (cmpxchg(&rnp->wakemask, old, new) != old);
> > 
> > Hm, isnt this an inferior version of atomic_or_long() in essence?
> > 
> > Note that atomic_or_long() is x86 only, so a generic one would have to be 
> > offered too i suspect, atomic_cmpxchg() driven or so - which would look like 
> > the above loop.
> > 
> > Most architectures could offer atomic_or_long() i suspect.
> 
> Is the following what you had in mind?  This (untested) patch provides only 
> the generic function: if this is what you had in mind, I can put together 
> optimized versions for a couple of the architectures.

Yeah, something like this, except:

> +#ifndef CONFIG_ARCH_HAS_ATOMIC_OR_LONG
> +static inline void atomic_or_long(unsigned long *v1, unsigned long v2)
> +{
> +	unsigned long old;
> +	unsigned long new;
> +
> +	do {
> +		old = ACCESS_ONCE(*v1);
> +		new = old | v2;
> +	} while (cmpxchg(v1, old, new) != old);
> +}
> +#endif /* #ifndef CONFIG_ARCH_HAS_ATOMIC_OR_LONG */

Shouldnt that method work on atomic_t (or atomic64_t)?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
