Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id BBF976B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 12:57:53 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id u8so152537147ywu.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 09:57:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b26si10649828pgf.332.2017.02.13.09.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 09:57:52 -0800 (PST)
Date: Mon, 13 Feb 2017 18:57:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH RFC v2 tip/core/rcu] Maintain special bits at bottom of
 ->dynticks counter
Message-ID: <20170213175750.GJ6500@twins.programming.kicks-ass.net>
References: <20170209235103.GA1368@linux.vnet.ibm.com>
 <20170213122115.GO6515@twins.programming.kicks-ass.net>
 <20170213170104.GC30506@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170213170104.GC30506@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, tglx@linutronix.de, fweisbec@gmail.com, cmetcalf@mellanox.com, mingo@kernel.org

On Mon, Feb 13, 2017 at 09:01:04AM -0800, Paul E. McKenney wrote:
> > I think I've asked this before, but why does this live in the guts of
> > RCU?
> > 
> > Should we lift this state tracking stuff out and make RCU and
> > NOHZ(_FULL) users of it, or doesn't that make sense (reason)?
> 
> The dyntick-idle stuff is pretty specific to RCU.  And what precisely
> would be helped by moving it?

Maybe untangle the inter-dependencies somewhat. It just seems a wee bit
odd to have arch TLB invalidate depend on RCU implementation details
like this.

> But that was an excellent question, as it reminded me of RCU's
> dyntick-idle's NMI handling, and I never did ask Andy if it was OK for
> rcu_eqs_special_exit() to be invoked when exiting NMI handler, which would
> currently happen.  It would be easy for me to pass in a flag indicating
> whether or not the call is in NMI context, if that is needed.
> 
> It is of course not possible to detect this at rcu_eqs_special_set()
> time, because rcu_eqs_special_set() has no way of knowing that the next
> event that pulls the remote CPU out of idle will be an NMI.
> 
> > In any case, small nit below:
> > 
> > 
> > > +	seq = atomic_add_return(RCU_DYNTICK_CTRL_CTR, &rdtp->dynticks);
> > > +	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) &&
> > > +		     !(seq & RCU_DYNTICK_CTRL_CTR));
> > > +	if (seq & RCU_DYNTICK_CTRL_MASK) {
> > > +		atomic_and(~RCU_DYNTICK_CTRL_MASK, &rdtp->dynticks);
> > > +		smp_mb__after_atomic(); /* _exit after clearing mask. */
> > > +		/* Prefer duplicate flushes to losing a flush. */
> > > +		rcu_eqs_special_exit();
> > > +	}
> > 
> > we have atomic_andnot() for just these occasions :-)
> 
> I suppose that that could generate more efficient code on some
> architectures.  I have changed this.

Right, saves 1 instruction on a number of archs. Not the end of the
world of course, but since we have the thing might as well use it.

> > > +/*
> > > + * Set the special (bottom) bit of the specified CPU so that it
> > > + * will take special action (such as flushing its TLB) on the
> > > + * next exit from an extended quiescent state.  Returns true if
> > > + * the bit was successfully set, or false if the CPU was not in
> > > + * an extended quiescent state.
> > > + */
> > > +bool rcu_eqs_special_set(int cpu)
> > > +{
> > > +	int old;
> > > +	int new;
> > > +	struct rcu_dynticks *rdtp = &per_cpu(rcu_dynticks, cpu);
> > > +
> > > +	do {
> > > +		old = atomic_read(&rdtp->dynticks);
> > > +		if (old & RCU_DYNTICK_CTRL_CTR)
> > > +			return false;
> > > +		new = old | RCU_DYNTICK_CTRL_MASK;
> > > +	} while (atomic_cmpxchg(&rdtp->dynticks, old, new) != old);
> > > +	return true;
> > 
> > Is that what we call atomic_fetch_or() ?
> 
> I don't think so.  The above code takes an early exit if the next bit
> up is set, which atomic_fetch_or() does not.  If the CPU is not in
> an extended quiescent state (old & RCU_DYNTICK_CTRL_CTR), then this
> code returns false to indicate that TLB shootdown cannot wait.

Oh duh yes, reading be hard.

> So it is more like a very specific form of atomic_fetch_or_unless().

Right, I actually have a similar construct in set_nr_if_polling().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
