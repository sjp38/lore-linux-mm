Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 094906B0389
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 13:19:27 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w185so156612248ita.5
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:19:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i2si11490494iob.94.2017.02.13.10.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 10:19:26 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1DIJOKB010974
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 13:19:25 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28kfdsy4u8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 13:19:25 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 13 Feb 2017 11:19:11 -0700
Date: Mon, 13 Feb 2017 10:19:09 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC v2 tip/core/rcu] Maintain special bits at bottom of
 ->dynticks counter
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170209235103.GA1368@linux.vnet.ibm.com>
 <20170213122115.GO6515@twins.programming.kicks-ass.net>
 <20170213170104.GC30506@linux.vnet.ibm.com>
 <20170213175750.GJ6500@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170213175750.GJ6500@twins.programming.kicks-ass.net>
Message-Id: <20170213181909.GF30506@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, tglx@linutronix.de, fweisbec@gmail.com, cmetcalf@mellanox.com, mingo@kernel.org

On Mon, Feb 13, 2017 at 06:57:50PM +0100, Peter Zijlstra wrote:
> On Mon, Feb 13, 2017 at 09:01:04AM -0800, Paul E. McKenney wrote:
> > > I think I've asked this before, but why does this live in the guts of
> > > RCU?
> > > 
> > > Should we lift this state tracking stuff out and make RCU and
> > > NOHZ(_FULL) users of it, or doesn't that make sense (reason)?
> > 
> > The dyntick-idle stuff is pretty specific to RCU.  And what precisely
> > would be helped by moving it?
> 
> Maybe untangle the inter-dependencies somewhat. It just seems a wee bit
> odd to have arch TLB invalidate depend on RCU implementation details
> like this.

I don't know about that.  After all, my lazy TLB invalidation work in
DYNIX/ptx was a key stepping-stone to my first RCU implementation.  ;-)

More seriously, I don't believe moving it out would make it less odd.

> > But that was an excellent question, as it reminded me of RCU's
> > dyntick-idle's NMI handling, and I never did ask Andy if it was OK for
> > rcu_eqs_special_exit() to be invoked when exiting NMI handler, which would
> > currently happen.  It would be easy for me to pass in a flag indicating
> > whether or not the call is in NMI context, if that is needed.
> > 
> > It is of course not possible to detect this at rcu_eqs_special_set()
> > time, because rcu_eqs_special_set() has no way of knowing that the next
> > event that pulls the remote CPU out of idle will be an NMI.
> > 
> > > In any case, small nit below:
> > > 
> > > 
> > > > +	seq = atomic_add_return(RCU_DYNTICK_CTRL_CTR, &rdtp->dynticks);
> > > > +	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) &&
> > > > +		     !(seq & RCU_DYNTICK_CTRL_CTR));
> > > > +	if (seq & RCU_DYNTICK_CTRL_MASK) {
> > > > +		atomic_and(~RCU_DYNTICK_CTRL_MASK, &rdtp->dynticks);
> > > > +		smp_mb__after_atomic(); /* _exit after clearing mask. */
> > > > +		/* Prefer duplicate flushes to losing a flush. */
> > > > +		rcu_eqs_special_exit();
> > > > +	}
> > > 
> > > we have atomic_andnot() for just these occasions :-)
> > 
> > I suppose that that could generate more efficient code on some
> > architectures.  I have changed this.
> 
> Right, saves 1 instruction on a number of archs. Not the end of the
> world of course, but since we have the thing might as well use it.

Understood -- could be worth the extra two characters of source code.
I have made this change locally, and will push it to -rcu.

> > > > +/*
> > > > + * Set the special (bottom) bit of the specified CPU so that it
> > > > + * will take special action (such as flushing its TLB) on the
> > > > + * next exit from an extended quiescent state.  Returns true if
> > > > + * the bit was successfully set, or false if the CPU was not in
> > > > + * an extended quiescent state.
> > > > + */
> > > > +bool rcu_eqs_special_set(int cpu)
> > > > +{
> > > > +	int old;
> > > > +	int new;
> > > > +	struct rcu_dynticks *rdtp = &per_cpu(rcu_dynticks, cpu);
> > > > +
> > > > +	do {
> > > > +		old = atomic_read(&rdtp->dynticks);
> > > > +		if (old & RCU_DYNTICK_CTRL_CTR)
> > > > +			return false;
> > > > +		new = old | RCU_DYNTICK_CTRL_MASK;
> > > > +	} while (atomic_cmpxchg(&rdtp->dynticks, old, new) != old);
> > > > +	return true;
> > > 
> > > Is that what we call atomic_fetch_or() ?
> > 
> > I don't think so.  The above code takes an early exit if the next bit
> > up is set, which atomic_fetch_or() does not.  If the CPU is not in
> > an extended quiescent state (old & RCU_DYNTICK_CTRL_CTR), then this
> > code returns false to indicate that TLB shootdown cannot wait.
> 
> Oh duh yes, reading be hard.

I know that feeling!

> > So it is more like a very specific form of atomic_fetch_or_unless().
> 
> Right, I actually have a similar construct in set_nr_if_polling().

I was going to suggest combining them, but set_nr_if_polling() needs two
different exit checks, and with two different return values.  Not sure
it is worth it, but of course if someone does come up with an appropriate
primitive, I can always switch to it.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
