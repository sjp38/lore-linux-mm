Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6806B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 16:52:17 -0500 (EST)
Received: by mail-oa0-f45.google.com with SMTP id o6so2049171oag.32
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 13:52:17 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id ds9si22798937obc.8.2013.11.22.13.52.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 13:52:16 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 22 Nov 2013 14:52:15 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 1780B3E40044
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 14:52:12 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAMJoCjo7471372
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 20:50:12 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAMLt4aG022602
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 14:55:06 -0700
Date: Fri, 22 Nov 2013 13:52:08 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131122215208.GD4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131122040856.GK4138@linux.vnet.ibm.com>
 <CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
 <20131122062314.GN4138@linux.vnet.ibm.com>
 <20131122151600.GA14988@gmail.com>
 <20131122184937.GX4138@linux.vnet.ibm.com>
 <CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
 <20131122200620.GA4138@linux.vnet.ibm.com>
 <CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
 <20131122203738.GC4138@linux.vnet.ibm.com>
 <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 01:01:14PM -0800, Linus Torvalds wrote:
> On Fri, Nov 22, 2013 at 12:37 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Fri, Nov 22, 2013 at 12:09:31PM -0800, Linus Torvalds wrote:
> >>
> >> So? In order to get *into* that contention code, you will have to go
> >> through the fast-case code. Which will contain a locked instruction.
> >
> > So you must also maintain ordering against the critical section that just
> > ended on some other CPU.
> 
> But that's completely irrelevant to what you yourself have been saying
> in this thread.
> 
> Your stated concern in this thread been whether the "unlock+lock"
> sequence implies an ordering that is at least equivalent to a memory
> barrier. And it clearly does, because the lock clearly contains a
> memory barrier inside of it.

You seem to be assuming that the unlock+lock rule applies only when the
unlock and the lock are executed by the same CPU.  This is not always
the case.  For example, when the unlock and lock are operating on the
same lock variable, the critical sections must appear to be ordered from
the perspective of some other CPU, even when that CPU is not holding
any lock.  Please see the last example in "LOCKS VS MEMORY ACCESSES"
in Documentation/memory-barriers.txt, which was added in March 2006:

------------------------------------------------------------------------

	CPU 1				CPU 2
	===============================	===============================
	*A = a;
	LOCK M		[1]
	*B = b;
	*C = c;
	UNLOCK M	[1]
	*D = d;				*E = e;
					LOCK M		[2]
					*F = f;
					*G = g;
					UNLOCK M	[2]
					*H = h;

CPU 3 might see:

	*E, LOCK M [1], *C, *B, *A, UNLOCK M [1],
		LOCK M [2], *H, *F, *G, UNLOCK M [2], *D

But assuming CPU 1 gets the lock first, CPU 3 won't see any of:

	*B, *C, *D, *F, *G or *H preceding LOCK M [1]
	*A, *B or *C following UNLOCK M [1]
	*F, *G or *H preceding LOCK M [2]
	*A, *B, *C, *E, *F or *G following UNLOCK M [2]

------------------------------------------------------------------------

The code that CPU 2 executes after acquiring lock M must be seen by some
other CPU not holding any lock as following CPU 1's release of lock M.
And the other three sets of ordering constraints must hold as well.

Admittedly, this example only shows stores, but then again so do the
earlier examples that illustrate single-CPU unlock-lock acting as a full
memory barrier.  The intent was that unlock and a subsequent lock of a
given lock variable act as a full memory barrier regardless of whether
or not the unlock and lock were executed by the same CPU.

> The fact that the locking sequence contains *other* things too is
> irrelevant for that question. Those other things are at most relevant
> then for *other* questions, ie from the standpoint of somebody wanting
> to convince himself that the locking actually works as a lock, but
> that wasn't what we were actually talking about earlier.

Also from the standpoint of somebody wanting to convince himself
that an unlock on one CPU and a lock of that same lock on another
CPU provides ordering for some other CPU not holding that lock.
Which in fact was the case I was worried about.

> The x86 memory ordering doesn't follow the traditional theoretical
> operations, no. Tough. It's generally superior than the alternatives
> because of its somewhat unorthodox rules (in that it then makes the
> many other common barriers generally be no-ops). If you try to
> describe the x86 ops in terms of the theory, you will have pain. So
> just don't do it. Think of them in the context of their own rules, not
> somehow trying to translate them to non-x86 rules.
> 
> I think you can try to approximate the x86 rules as "every load is a
> RCpc acquire, every store is a RCpc release", and then to make
> yourself happier you can say that the lock sequence always starts out
> with a serializing operation (which is obviously the actual locked
> r-m-w op) so that on a lock/unlock level (as opposed to an individual
> memory op level) you get the RCsc behavior of the acquire/releases not
> re-ordering across separate locking events.
> 
> I'm not actually convinced that that is really a full and true
> description of the x86 semantics, but it may _approximate_ being true
> to the degree that you might translate it to some of the academic
> papers that talk about these things.

This approach is fine most of the time.  But when faced with something
as strange as "got a full barrier despite having no atomic instructions
and no memory-barrier instructions", I feel the need to look at it from
multiple viewpoints.  The multiple viewpoints I have used thus far do
seem to agree with each other, which does give me some confidence in
the result.

> (Side note: this is also true when the locked r-m-w instruction has
> been replaced with a xbegin/xend. Intel documents that an RTM region
> has the "same ordering semantics as a LOCK prefixed instruction": see
> section 15.3.6 in the intel x86 architecture sw manual)

Understood.  So, yes, it would be possible to implement locking with RTM,
as long as you had a non-RTM fallback path.  The fallback path would be
very rarely used, but I suspecct that you could exercise it by putting
it in userspace and attempting to single-step through the transaction.

But in the handoff case, there are no locked r-m-w instructions, so I
think I lost the thread somewhere in your side note.  Unless you are
simply saying that hardware transactional memory can be a good thing,
in which case I agree, at least for transactions that are small enough
to fit in the cache and to not need to be debugged via single-stepping.
I don't buy the infinite-composition argument of some transactional
memory academics, though.  Too many corner cases, such as having a remote
procedure call between the two transactions to be composed.  In fact,
one can argue that transactions are composable only to about the same
degree as are locks.  Not popular among those who want to believe that
transactions are infinitely composable and locks are not, but I never
have been popular among those people anyway.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
