Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id B5A8B6B0035
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 15:21:15 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id lh4so1760524vcb.23
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:21:15 -0800 (PST)
Received: from mail-vb0-x232.google.com (mail-vb0-x232.google.com [2607:f8b0:400c:c02::232])
        by mx.google.com with ESMTPS id ks3si14903624vec.13.2013.11.23.12.21.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Nov 2013 12:21:14 -0800 (PST)
Received: by mail-vb0-f50.google.com with SMTP id 10so1780908vbe.23
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:21:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131123013654.GG4138@linux.vnet.ibm.com>
References: <20131122184937.GX4138@linux.vnet.ibm.com>
	<CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
	<20131122200620.GA4138@linux.vnet.ibm.com>
	<CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
	<20131122203738.GC4138@linux.vnet.ibm.com>
	<CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
	<20131122215208.GD4138@linux.vnet.ibm.com>
	<CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
	<20131123002542.GF4138@linux.vnet.ibm.com>
	<CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
	<20131123013654.GG4138@linux.vnet.ibm.com>
Date: Sat, 23 Nov 2013 12:21:13 -0800
Message-ID: <CA+55aFxQy8afgf6geqJOEHmsJ=ME-6CXrrPfj=aggH7u_jEEZA@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 5:36 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> But this does -not- guarantee that some other non-lock-holding CPU 2 will
> see CS0 and CS1 in order.  To see this, let's fill in the two critical
> sections, where variables X and Y are both initially zero:
>
>         CPU 0 (releasing)       CPU 1 (acquiring)
>         -----                   -----
>         ACCESS_ONCE(X) = 1;     while (ACCESS_ONCE(lock) == 1)
>         lwsync                          continue;
>         ACCESS_ONCE(lock) = 0;  lwsync
>                                 r1 = ACCESS_ONCE(Y);
>
> Then let's add in the observer CPU 2:
>
>         CPU 2
>         -----
>         ACCESS_ONCE(Y) = 1;
>         sync
>         r2 = ACCESS_ONCE(X);
>
> If unlock+lock act as a full memory barrier, it would be impossible to
> end up with (r1 == 0 && r2 == 0).  After all, (r1 == 0) implies that
> CPU 2's store to Y happened after CPU 1's load from Y, and (r2 == 0)
> implies that CPU 0's load from X happened after CPU 2's store to X.
> If CPU 0's unlock combined with CPU 1's lock really acted like a full
> memory barrier, we end up with CPU 0's load happening before CPU 1's
> store happening before CPU 2's store happening before CPU 2's load
> happening before CPU 0's load.
>
> However, the outcome (r1 == 0 && r2 == 0) really does happen both
> in theory and on real hardware.

Ok, so I have ruminated.

But even after having ruminated, the one thing I cannot find is
support for your "(r1 == 0 && r2 == 0) really does happen on
hardware".

Ignore theory, and assume just cache coherency, ie the notion that in
order to write to a cacheline, you have to have that cacheline in some
exclusive state. We have three cachelines, X, Y and lock (and our
cachelines only have a single bit, starting out as 0,0,1
respectively).

CPU0:
   write X = 1;
   lwsync
   write lock = 0;

doesn't even really require any cache accesses at all per se, but it
*does* require that the two stores be ordered in the store buffer on
CPU0 in such a way that cacheline X gets updated (ie is in
exclusive/dirty state in CPU0 with the value 1) before cacheline
'lock' gets released from its exclusive/dirty state after having
itself been updated to 0.

So basically we know that *within* CPU0, by the time the lock actually
makes it out of the CPU, the cacheline containing X will have been in
dirty mode with the value "1". The core might actually have written
'lock' first, but it can't release that cacheline from exclusive state
(so that it is visible anywhere else) until it has _also_ gotten 'X'
into exclusive state (once both cachelines are exclusive within CPU0,
it can do any ordering, because the ordering won't be externally
visible).

And this is all just looking at CPU0, nothing else. But if it is
exclusive/dirty on CPU0, then it cannot be shared in any other CPU
(although a previous stale value may obviously still be "in flight"
somewhere else outside of the coherency domain).

So let's look at CPU2, which is similar, but now the second access is
a read (of zero), not a write:

CPU2:
   write Y = 1;
   sync
   read X as zero

So if 'sync' is a true memory barrier between the write and the read,
then we know that the following is true: CPU2 must have gotten
cacheline 'Y' into exclusive state and acquired (or held on to, which
is equivalent) cacheline 'X' in shared state _after_ it got that Y
into exclusive state. It can't rely on some "in flight" previously
read value of 'X' until after it got Y into exclusive state. Otherwise
it wouldn't be a ordering between the write and the read, agreed?

The pattern on CPU1, meanwhile, is somewhat different. But I'm going
to ignore the "while" part, and just concentrate on the last iteration
of the loop, and it turns into:

CPU1:
   read lock as zero
   lwsync
   read Y as zero

It only does reads, so it is happy with a shared cacheline, but in
order for the lwsync to actually act as an acquire, it does mean that
the cacheline 'Y' needs to be in some shared state within the cache
coherency domain after (or, again, across) cacheline 'lock' having
been in a shared state with value == 0 on CPU1. No "in flight" values.

Agreed?

So the above isn't really about lwsync/sync/memory ordering any more,
the above is basically rewriting things purely about cacheline states
as seen by individual processors. And I know the POWER cache coherency
is really complex (iirc cachelines can have 11+ states - we're not
talking about MOESI any more), but even there you have to have a
notion of "exclusive access" to be able to write in the end. So my
states are certainly simplified, but I don't see how that basic rule
can be violated (and still be called cache coherent).

And let's just look at the individual "events" on these CPU's:

 - A = CPU0 acquires exclusive access to cacheline X (in order to
write 1 into it)
 - B = CPU0 releases its exclusive access to cacheline lock (after
having written 0 into it)
 - C = CPU1 reads shared cacheline lock as being zero
 - D = CPU1 reads shared cacheline Y as being zero
 - E = CPU2 acquires exclusive access to cacheline Y (in order to
write 1 into it)
 - F = CPU2 reads shared cacheline X as being zero

and you cannot order these events arbitrarily, but there *ARE* certain
orderings you can rely on:

 - within a CPU due to the barriers. This gives you

    A < B, C < D and E < F

 - with regards to a particular cacheline because of that cacheline
coming exclusive (or, in the case of 'B', moving out of exclusive
state) and the value it has at that point:

    B < C, F < A and D < E

And as far as I can tell, the above gives you: A < B < C < D < E < F <
A. Which doesn't look possible.

So which step in my rumination here is actually wrong? Because I
really don't see how you can get that "(r1 == 0 && r2 == 0)" on real
hardware using cache coherency.

*SOME* assumption of mine must be wrong. But I don't see which one.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
