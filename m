Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 11A8F6B0083
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 12:11:42 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so4123332yhz.41
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 09:11:41 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id a9si24700751yhm.287.2013.11.26.09.11.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 09:11:41 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 26 Nov 2013 10:11:40 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 4A38F3E40040
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 10:11:37 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAQF9ZMG44040206
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:09:35 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAQHEVDw012167
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 10:14:33 -0700
Date: Tue, 26 Nov 2013 09:11:06 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131126171106.GJ4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
 <20131121221859.GH4138@linux.vnet.ibm.com>
 <20131122155835.GR3866@twins.programming.kicks-ass.net>
 <20131122182632.GW4138@linux.vnet.ibm.com>
 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
 <20131125173540.GK3694@twins.programming.kicks-ass.net>
 <20131125180250.GR4138@linux.vnet.ibm.com>
 <20131125182715.GG10022@twins.programming.kicks-ass.net>
 <20131125235252.GA4138@linux.vnet.ibm.com>
 <20131126095945.GI10022@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131126095945.GI10022@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 10:59:45AM +0100, Peter Zijlstra wrote:
> On Mon, Nov 25, 2013 at 03:52:52PM -0800, Paul E. McKenney wrote:
> > On Mon, Nov 25, 2013 at 07:27:15PM +0100, Peter Zijlstra wrote:
> > > On Mon, Nov 25, 2013 at 10:02:50AM -0800, Paul E. McKenney wrote:
> > > > And if the two locks are different, then the guarantee applies only
> > > > when the unlock and lock are on the same CPU, in which case, as Linus
> > > > noted, the xchg() on entry to the slow path does the job for use.
> > > 
> > > But in that case we rely on the fact that the thing is part of a
> > > composite and we should no longer call it load_acquire, because frankly
> > > it doesn't have acquire semantics anymore because the read can escape
> > > out.
> > 
> > Actually, load-acquire and store-release are only required to provide
> > ordering in the threads/CPUs doing the load-acquire/store-release
> > operations.  It is just that we require something stronger than minimal
> > load-acquire/store-release to make a Linux-kernel lock.
> 
> I suspect we're talking past one another here; but our Document
> describes ACQUIRE/RELEASE semantics such that
> 
>   RELEASE
>   ACQUIRE
> 
> matches a full barrier, regardless on whether it is the same lock or
> not.

Ah, got it!

> If you now want to weaken this definition, then that needs consideration
> because we actually rely on things like
> 
> spin_unlock(l1);
> spin_lock(l2);
> 
> being full barriers.
> 
> Now granted, for lock operations we have actual atomic ops in between
> which would cure x86, but it would leave us confused with the barrier
> semantics.
> 
> So please; either: 
> 
> A) we have the strong ACQUIRE/RELEASE semantics as currently described;
>    and therefore any RELEASE+ACQUIRE pair must form a full barrier; and
>    our propose primitives are non-compliant and needs strengthening.
> 
> B) we go fudge about with the definitions.

Another approach would be to have local and global variants, so that
the local variants have acquire/release semantics that are guaranteed
to be visible only in the involved threads (sufficient for circular
buffers) while the global ones are visible globally, thus sufficient
for queued locks.

> But given the current description of our ACQUIRE barrier, we simply
> cannot claim the proposed primitives are good on x86 IMO.
> 
> Also, instead of the smp_store_release() I would argue that
> smp_load_acquire() is the one that needs the full buffer, even on PPC.
> 
> Because our ACQUIRE dis-allows loads/stores leaking out upwards, and
> both TSO and PPC lwsync allow just that, so the smp_load_acquire() is
> the one that needs the full barrier.

You lost me on this one.  Here is x86 ACQUIRE for X:

	r1 = ACCESS_ONCE(X);
	<loads and stores>

Since x86 does not reorder loads with later loads or stores, this should
be sufficience.

For powerpc:

	r1 = ACCESS_ONCE(X);
	lwsync;
	<loads and stores>

And lwsync does not allow prior loads to be reordered with later loads or
stores, so this should also be sufficient.

In both cases, a RELEASE+ACQUIRE provides a full barrier as long as
RELEASE has the right stuff in it.

So what am I missing?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
