Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 945E86B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 12:01:07 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id 78so70403495vkj.2
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 09:01:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l1si3522221plb.136.2017.02.13.09.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 09:01:06 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1DGwfal137613
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 12:01:05 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28j5xvmvv4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 12:01:05 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 13 Feb 2017 10:01:04 -0700
Date: Mon, 13 Feb 2017 09:01:04 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC v2 tip/core/rcu] Maintain special bits at bottom of
 ->dynticks counter
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170209235103.GA1368@linux.vnet.ibm.com>
 <20170213122115.GO6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170213122115.GO6515@twins.programming.kicks-ass.net>
Message-Id: <20170213170104.GC30506@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, tglx@linutronix.de, fweisbec@gmail.com, cmetcalf@mellanox.com, mingo@kernel.org

On Mon, Feb 13, 2017 at 01:21:15PM +0100, Peter Zijlstra wrote:
> On Thu, Feb 09, 2017 at 03:51:03PM -0800, Paul E. McKenney wrote:
> >     Currently, IPIs are used to force other CPUs to invalidate their TLBs
> >     in response to a kernel virtual-memory mapping change.  This works, but
> >     degrades both battery lifetime (for idle CPUs) and real-time response
> >     (for nohz_full CPUs), and in addition results in unnecessary IPIs due to
> >     the fact that CPUs executing in usermode are unaffected by stale kernel
> >     mappings.  It would be better to cause a CPU executing in usermode to
> >     wait until it is entering kernel mode to do the flush, first to avoid
> >     interrupting usemode tasks and second to handle multiple flush requests
> >     with a single flush in the case of a long-running user task.
> >     
> >     This commit therefore reserves a bit at the bottom of the ->dynticks
> >     counter, which is checked upon exit from extended quiescent states.
> >     If it is set, it is cleared and then a new rcu_eqs_special_exit() macro is
> >     invoked, which, if not supplied, is an empty single-pass do-while loop.
> >     If this bottom bit is set on -entry- to an extended quiescent state,
> >     then a WARN_ON_ONCE() triggers.
> >     
> >     This bottom bit may be set using a new rcu_eqs_special_set() function,
> >     which returns true if the bit was set, or false if the CPU turned
> >     out to not be in an extended quiescent state.  Please note that this
> >     function refuses to set the bit for a non-nohz_full CPU when that CPU
> >     is executing in usermode because usermode execution is tracked by RCU
> >     as a dyntick-idle extended quiescent state only for nohz_full CPUs.
> > 
> >     Changes since v1:  Fix ordering of atomic_and() and the call to
> >     rcu_eqs_special_exit() in rcu_dynticks_eqs_exit().
> >  
> >     Reported-by: Andy Lutomirski <luto@amacapital.net>
> >     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> I think I've asked this before, but why does this live in the guts of
> RCU?
> 
> Should we lift this state tracking stuff out and make RCU and
> NOHZ(_FULL) users of it, or doesn't that make sense (reason)?

The dyntick-idle stuff is pretty specific to RCU.  And what precisely
would be helped by moving it?

But that was an excellent question, as it reminded me of RCU's
dyntick-idle's NMI handling, and I never did ask Andy if it was OK for
rcu_eqs_special_exit() to be invoked when exiting NMI handler, which would
currently happen.  It would be easy for me to pass in a flag indicating
whether or not the call is in NMI context, if that is needed.

It is of course not possible to detect this at rcu_eqs_special_set()
time, because rcu_eqs_special_set() has no way of knowing that the next
event that pulls the remote CPU out of idle will be an NMI.

> In any case, small nit below:
> 
> 
> > +	seq = atomic_add_return(RCU_DYNTICK_CTRL_CTR, &rdtp->dynticks);
> > +	WARN_ON_ONCE(IS_ENABLED(CONFIG_RCU_EQS_DEBUG) &&
> > +		     !(seq & RCU_DYNTICK_CTRL_CTR));
> > +	if (seq & RCU_DYNTICK_CTRL_MASK) {
> > +		atomic_and(~RCU_DYNTICK_CTRL_MASK, &rdtp->dynticks);
> > +		smp_mb__after_atomic(); /* _exit after clearing mask. */
> > +		/* Prefer duplicate flushes to losing a flush. */
> > +		rcu_eqs_special_exit();
> > +	}
> 
> we have atomic_andnot() for just these occasions :-)

I suppose that that could generate more efficient code on some
architectures.  I have changed this.

> > +/*
> > + * Set the special (bottom) bit of the specified CPU so that it
> > + * will take special action (such as flushing its TLB) on the
> > + * next exit from an extended quiescent state.  Returns true if
> > + * the bit was successfully set, or false if the CPU was not in
> > + * an extended quiescent state.
> > + */
> > +bool rcu_eqs_special_set(int cpu)
> > +{
> > +	int old;
> > +	int new;
> > +	struct rcu_dynticks *rdtp = &per_cpu(rcu_dynticks, cpu);
> > +
> > +	do {
> > +		old = atomic_read(&rdtp->dynticks);
> > +		if (old & RCU_DYNTICK_CTRL_CTR)
> > +			return false;
> > +		new = old | RCU_DYNTICK_CTRL_MASK;
> > +	} while (atomic_cmpxchg(&rdtp->dynticks, old, new) != old);
> > +	return true;
> 
> Is that what we call atomic_fetch_or() ?

I don't think so.  The above code takes an early exit if the next bit
up is set, which atomic_fetch_or() does not.  If the CPU is not in
an extended quiescent state (old & RCU_DYNTICK_CTRL_CTR), then this
code returns false to indicate that TLB shootdown cannot wait.
So it is more like a very specific form of atomic_fetch_or_unless().

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
