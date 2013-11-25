Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 210696B00D6
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 12:53:24 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id uy5so4464435obc.26
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:53:23 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id uq6si29089033obc.109.2013.11.25.09.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 09:53:23 -0800 (PST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 25 Nov 2013 10:53:22 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9264C19D8059
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:53:15 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAPFpWgQ40501406
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:51:32 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAPHuFtE010403
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:56:17 -0700
Date: Mon, 25 Nov 2013 09:53:15 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131125175315.GO4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131122200620.GA4138@linux.vnet.ibm.com>
 <CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
 <20131122203738.GC4138@linux.vnet.ibm.com>
 <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
 <20131122215208.GD4138@linux.vnet.ibm.com>
 <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
 <20131123002542.GF4138@linux.vnet.ibm.com>
 <CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
 <20131123013654.GG4138@linux.vnet.ibm.com>
 <CA+55aFxQy8afgf6geqJOEHmsJ=ME-6CXrrPfj=aggH7u_jEEZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxQy8afgf6geqJOEHmsJ=ME-6CXrrPfj=aggH7u_jEEZA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Sat, Nov 23, 2013 at 12:21:13PM -0800, Linus Torvalds wrote:
> On Fri, Nov 22, 2013 at 5:36 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > But this does -not- guarantee that some other non-lock-holding CPU 2 will
> > see CS0 and CS1 in order.  To see this, let's fill in the two critical
> > sections, where variables X and Y are both initially zero:
> >
> >         CPU 0 (releasing)       CPU 1 (acquiring)
> >         -----                   -----
> >         ACCESS_ONCE(X) = 1;     while (ACCESS_ONCE(lock) == 1)
> >         lwsync                          continue;
> >         ACCESS_ONCE(lock) = 0;  lwsync
> >                                 r1 = ACCESS_ONCE(Y);
> >
> > Then let's add in the observer CPU 2:
> >
> >         CPU 2
> >         -----
> >         ACCESS_ONCE(Y) = 1;
> >         sync
> >         r2 = ACCESS_ONCE(X);
> >
> > If unlock+lock act as a full memory barrier, it would be impossible to
> > end up with (r1 == 0 && r2 == 0).  After all, (r1 == 0) implies that
> > CPU 2's store to Y happened after CPU 1's load from Y, and (r2 == 0)
> > implies that CPU 0's load from X happened after CPU 2's store to X.
> > If CPU 0's unlock combined with CPU 1's lock really acted like a full
> > memory barrier, we end up with CPU 0's load happening before CPU 1's
> > store happening before CPU 2's store happening before CPU 2's load
> > happening before CPU 0's load.
> >
> > However, the outcome (r1 == 0 && r2 == 0) really does happen both
> > in theory and on real hardware.
> 
> Ok, so I have ruminated.
> 
> But even after having ruminated, the one thing I cannot find is
> support for your "(r1 == 0 && r2 == 0) really does happen on
> hardware".
> 
> Ignore theory, and assume just cache coherency,

Sorry, but that is not ignoring theory.  Ignoring theory would instead
mean confining oneself to running tests on real hardware.  And there is
real hardware that does allow the assertion to trigger.  You are instead
asking me to use your personal theory instead of a theory that has been
shown to match reality.

Let's see how that plays out.

>                                                 ie the notion that in
> order to write to a cacheline, you have to have that cacheline in some
> exclusive state. We have three cachelines, X, Y and lock (and our
> cachelines only have a single bit, starting out as 0,0,1
> respectively).
> 
> CPU0:
>    write X = 1;
>    lwsync
>    write lock = 0;
> 
> doesn't even really require any cache accesses at all per se, but it
> *does* require that the two stores be ordered in the store buffer on
> CPU0 in such a way that cacheline X gets updated (ie is in
> exclusive/dirty state in CPU0 with the value 1) before cacheline
> 'lock' gets released from its exclusive/dirty state after having
> itself been updated to 0.

So far, so good.

> So basically we know that *within* CPU0, by the time the lock actually
> makes it out of the CPU, the cacheline containing X will have been in
> dirty mode with the value "1".

You seem to be assuming that the only way for the cache line to make it
out of the CPU is via the caches.  This assumption is incorrect given
hardware multithreading, in which case the four hardware threads in a
core (in the case of Power 7) can share a store buffer, and can thus
communicate via that store buffer.

Another way of putting this is that you are assuming multi-copy atomic
behavior, which is in fact guaranteed on x86 by the the bullet in 8.2.2
of the "Intel 64 and IA-32 Architectures Software Developer's Manual"
which reads:

	"Any two stores are seen in a consistent order by processors
	other than those performing the stores."

The reality is that not all architectures guarantee multi-copy atomic
behavior.

>                                The core might actually have written
> 'lock' first, but it can't release that cacheline from exclusive state
> (so that it is visible anywhere else) until it has _also_ gotten 'X'
> into exclusive state (once both cachelines are exclusive within CPU0,
> it can do any ordering, because the ordering won't be externally
> visible).

Not always true when store buffers are shared among hardware threads!
In particular, consider the case where CPU 0 and CPU 1 share a store
buffer and CPU 2 is on some other core.  CPU 1 sees CPU 2's accesses
in order, but the lwsync instructions do not order prior stores against
later loads.  Therefore, it is legal for CPU 0's store to X be released
from the core -after- CPU 1's load from Y.  CPU 2's sync cannot help in
this case, so the assertion can trigger.

Please note that this does -not- violate cache coherence:  All three
CPUs agree on the order of accesses to each individual memory location.
(Or do you mean something else by "cache coherence"?)

> And this is all just looking at CPU0, nothing else. But if it is
> exclusive/dirty on CPU0, then it cannot be shared in any other CPU
> (although a previous stale value may obviously still be "in flight"
> somewhere else outside of the coherency domain).
> 
> So let's look at CPU2, which is similar, but now the second access is
> a read (of zero), not a write:
> 
> CPU2:
>    write Y = 1;
>    sync
>    read X as zero
> 
> So if 'sync' is a true memory barrier between the write and the read,
> then we know that the following is true: CPU2 must have gotten
> cacheline 'Y' into exclusive state and acquired (or held on to, which
> is equivalent) cacheline 'X' in shared state _after_ it got that Y
> into exclusive state. It can't rely on some "in flight" previously
> read value of 'X' until after it got Y into exclusive state. Otherwise
> it wouldn't be a ordering between the write and the read, agreed?

Again, this line of reasoning does not take into account the possibility
of store buffers being shared between hardware threads within a single
core.  The key point is that CPU 0 and CPU 1 can be sharing the new value
of X prior to its reaching the cache, in other words, before CPU 2 can
see it.

So, no, I do not agree that this holds for all real hardware.

> The pattern on CPU1, meanwhile, is somewhat different. But I'm going
> to ignore the "while" part, and just concentrate on the last iteration
> of the loop, and it turns into:
> 
> CPU1:
>    read lock as zero
>    lwsync
>    read Y as zero
> 
> It only does reads, so it is happy with a shared cacheline, but in
> order for the lwsync to actually act as an acquire, it does mean that
> the cacheline 'Y' needs to be in some shared state within the cache
> coherency domain after (or, again, across) cacheline 'lock' having
> been in a shared state with value == 0 on CPU1. No "in flight" values.

Or, if CPU 0 and CPU 1 are hardware threads in the same core, it is
happy with a shared store-buffer entry that might not yet be visible
to hardware threads in other cores.

> Agreed?

Sorry, but no.

> So the above isn't really about lwsync/sync/memory ordering any more,
> the above is basically rewriting things purely about cacheline states
> as seen by individual processors. And I know the POWER cache coherency
> is really complex (iirc cachelines can have 11+ states - we're not
> talking about MOESI any more), but even there you have to have a
> notion of "exclusive access" to be able to write in the end. So my
> states are certainly simplified, but I don't see how that basic rule
> can be violated (and still be called cache coherent).
> 
> And let's just look at the individual "events" on these CPU's:
> 
>  - A = CPU0 acquires exclusive access to cacheline X (in order to
> write 1 into it)
>  - B = CPU0 releases its exclusive access to cacheline lock (after
> having written 0 into it)
>  - C = CPU1 reads shared cacheline lock as being zero
>  - D = CPU1 reads shared cacheline Y as being zero
>  - E = CPU2 acquires exclusive access to cacheline Y (in order to
> write 1 into it)
>  - F = CPU2 reads shared cacheline X as being zero
> 
> and you cannot order these events arbitrarily, but there *ARE* certain
> orderings you can rely on:
> 
>  - within a CPU due to the barriers. This gives you
> 
>     A < B, C < D and E < F

Again, consider the case of shared store buffers.  In that case,
A < B and C < D does -not- imply A < D because the two lwsyncs will
-not- order a prior store (CPU 0's store to X) with a later load
(CPU 1's load from Y).  To get that guarantee, at least one of the
lwsync instructions needs to instead be a sync.

>  - with regards to a particular cacheline because of that cacheline
> coming exclusive (or, in the case of 'B', moving out of exclusive
> state) and the value it has at that point:
> 
>     B < C, F < A and D < E
> 
> And as far as I can tell, the above gives you: A < B < C < D < E < F <
> A. Which doesn't look possible.
> 
> So which step in my rumination here is actually wrong? Because I
> really don't see how you can get that "(r1 == 0 && r2 == 0)" on real
> hardware using cache coherency.
> 
> *SOME* assumption of mine must be wrong. But I don't see which one.

Wrong assumption 1.  Each hardware thread has its own store buffer.

Wrong assumption 2.  All architectures guarantee multi-copy atomic behavior.

							Thanx, Paul

>                    Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
