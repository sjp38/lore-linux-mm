Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id B898D6B0035
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 17:24:32 -0500 (EST)
Received: by mail-vc0-f181.google.com with SMTP id ks9so1794144vcb.40
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 14:24:32 -0800 (PST)
Received: from mail-vb0-x233.google.com (mail-vb0-x233.google.com [2607:f8b0:400c:c02::233])
        by mx.google.com with ESMTPS id sw5si14999478veb.137.2013.11.23.14.24.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Nov 2013 14:24:31 -0800 (PST)
Received: by mail-vb0-f51.google.com with SMTP id m10so1877050vbh.10
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 14:24:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131123212929.GP4971@laptop.programming.kicks-ass.net>
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
	<20131123212929.GP4971@laptop.programming.kicks-ass.net>
Date: Sat, 23 Nov 2013 14:24:31 -0800
Message-ID: <CA+55aFx9SPdG87xY67P-kbtUT6YKbnwF8Mdn-SKBWd_K_A2-CQ@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Sat, Nov 23, 2013 at 1:29 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> I haven't read your email in full detail yet, but one thing I did miss
> was cache-snoops.
>
> One of the reasons for failing transitive / multi-copy atomicity is that
> CPUs might have different views of the memory state depending on from
> which caches they can get snoops.

My argument doesn't depend on that or care about that.

My argument depends purely on:

 - barriers have a certain sane local meaning (because I don't think
they can work without that)

 - a cache coherenct implies that actually changing the cacheline
requires exclusive access to that cacheline at some point (where the
actual time of that "at some point" is not actually all that important
and you can hold on to the exclusive access for some arbitrary time,
but the particular points where the exclusive state changes matters
for the barrier semantics in order for barriers to work).

Nothing else matters for my argument. So cache snooping details are
irrelevant. Or rather, it is relevant only in the sense that the CPU's
that participate in the cache coherency protocol then have to have
barriers that work properly in the presence of said snooping. You
can't allow snooping to "break" the barriers.

Now, as I said in my follow-up, I think one "explanation" might be
that "everyting happens at the same time" approach, and while that
actually may work for "lwsync" and the sequence in question, I'm not
convinced that kind of lock really is a proper lock.

Because if you accept the "everything happens at once" model to
explain why the unlock+lock sequence doesn't act as a memory barrier,
than I actually think that you can build up an argument where multiple
concurrent spinlock'ed accesses (ie you make one of 'X'/'Y' be the
queue entry for the *next* MCS lock waiter trying to acquire it) can
get insane results that aren't consistent with actual exclusion.

Because if you accept that "a unlock and getting that lock on another
CPU can happen at the same time" argument (so that you can have that
circular chain of mutual dependencies), then you can extend the chain
further, since all the lock/unlock operations in question apparently
have zero latency and can thus see previous values for the same reason
CPU2 can see the original zero value of "X".

So I think anything that allows that

  A <= B <= C <= D <=E <= F <= A

situation is not necessarily a valid locking model (because you could
basically add a "lwsync + ACCESS_ONCE(lock-chain)=0" to the work CPU1
does, and since we've already established that there are zero
latencies in all this, CPU2 could have gotten *that* lock that we now
released "at the same time" as reading X as zero, even though CPU0 set
X to one in its "critical region".

So locks don't just imply "you can't let anything out of the critical
region". They also imply exclusion, and that "everything happens all
at once" model would seem to literally allow *EVERYTHING* to happen at
once, breaking the *exclusion* requirement.

But I dunno. My gut feel is that the "everything happens at once"
explanation is not actually then a valid model for locking, which in
turn would mean that using "lwsync" in both unlock and lock is not
sufficient.

Stated another way, let's say that you have multiple CPU's doing this:

   lock
   if (x == 0)
     x = 1;
   unlock

then we had *better* have only one of the CPU's actually set "x=1".
Otherwise the lock isn't a lock. Agreed?

Paul argued that "lwsync" is valid in both lock and unlock becuse it
doesn't allow anything to leak out of the locked region, but I'm
arguing that if it means that we allow that "everything happens at
once" model, then *every* CPU can do that "if (x == 0) x = 1" logic
all at the same time, *all* of them decide to set x to 1, and *none*
of them "leak" their accesses outside their locked region (they'd all
set 'x' to 1 at the same time), but the end result is still wrong.

So locking is not just "accesses inside of the lock cannot leak
outside the lock". It also implies "accesses inside of it have to be
_ordered_ wrt the lock", and that in turn disallows the "A <= .. <= F
<= A" model.  One of the "<=" has to be a "<" for the lock to be a
lock, methinks.

But hey, maybe somebody can point to where I screwed up. I just do not
think "snooping" is it.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
