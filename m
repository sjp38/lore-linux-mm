Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0E906B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 12:25:25 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id w189so167783989pfb.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 09:25:25 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 1si19608766pgw.325.2017.03.06.09.25.24
        for <linux-mm@kvack.org>;
        Mon, 06 Mar 2017 09:25:24 -0800 (PST)
Date: Mon, 6 Mar 2017 17:25:12 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170306172508.GG18519@leverpostej>
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej>
 <CACT4Y+ZFzhSrdevqRXWx-q5fgr0a7J6fX0fdwJ-uqU0zCgdjjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZFzhSrdevqRXWx-q5fgr0a7J6fX0fdwJ-uqU0zCgdjjg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Will Deacon <will.deacon@arm.com>

On Mon, Mar 06, 2017 at 05:27:44PM +0100, Dmitry Vyukov wrote:
> On Mon, Mar 6, 2017 at 5:20 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Mon, Mar 06, 2017 at 03:24:23PM +0100, Dmitry Vyukov wrote:
> >> On Mon, Mar 6, 2017 at 2:01 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> >> > On Mon, Mar 06, 2017 at 01:58:51PM +0100, Peter Zijlstra wrote:
> >> >> On Mon, Mar 06, 2017 at 01:50:47PM +0100, Dmitry Vyukov wrote:
> >> >> > On Mon, Mar 6, 2017 at 1:42 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> >> >> > > KASAN uses compiler instrumentation to intercept all memory accesses.
> >> >> > > But it does not see memory accesses done in assembly code.
> >> >> > > One notable user of assembly code is atomic operations. Frequently,
> >> >> > > for example, an atomic reference decrement is the last access to an
> >> >> > > object and a good candidate for a racy use-after-free.
> >> >> > >
> >> >> > > Add manual KASAN checks to atomic operations.
> >> >> > > Note: we need checks only before asm blocks and don't need them
> >> >> > > in atomic functions composed of other atomic functions
> >> >> > > (e.g. load-cmpxchg loops).
> >> >> >
> >> >> > Peter, also pointed me at arch/x86/include/asm/bitops.h. Will add them in v2.
> >> >> >
> >> >>
> >> >> > >  static __always_inline void atomic_add(int i, atomic_t *v)
> >> >> > >  {
> >> >> > > +       kasan_check_write(v, sizeof(*v));
> >> >> > >         asm volatile(LOCK_PREFIX "addl %1,%0"
> >> >> > >                      : "+m" (v->counter)
> >> >> > >                      : "ir" (i));

> >> Bottom line:
> >> 1. Involving compiler looks quite complex, hard to deploy, and it's
> >> unclear if it will actually make things easier.
> >> 2. This patch is the simplest short-term option (I am leaning towards
> >> adding bitops to this patch and leaving percpu out for now).
> >> 3. Providing an implementation of atomic ops based on compiler
> >> builtins looks like a nice option for other archs and tools, but is
> >> more work. If you consider this as a good solution, we can move
> >> straight to this option.
> >
> > Having *only* seen the assembly snippet at the top of this mail, I can't
> > say whether this is the simplest implementation.
> >
> > However, I do think that annotation of this sort is the only reasonable
> > way to handle this.
> 
> Here is the whole patch:
> https://groups.google.com/d/msg/kasan-dev/3sNHjjb4GCI/X76pwg_tAwAJ

I see.

Given we'd have to instrument each architecture's atomics in an
identical fashion, maybe we should follow the example of spinlocks, and
add an arch_ prefix to the arch-specific implementation, and place the
instrumentation in a common wrapper.

i.e. have something like:

static __always_inline void atomic_inc(atomic_t *v)
{
	kasan_check_write(v, sizeof(*v)); 
	arch_atomic_inc(v);
}

... in asm-generic somewhere.

It's more churn initially, but it should bea saving overall, and I
imagine for KMSAN or other things we may want more instrumentation
anyway...

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
