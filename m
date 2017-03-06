Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B05E6B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:20:31 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 77so72401825pgc.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:20:31 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p8si13983248pgd.208.2017.03.06.08.20.30
        for <linux-mm@kvack.org>;
        Mon, 06 Mar 2017 08:20:30 -0800 (PST)
Date: Mon, 6 Mar 2017 16:20:18 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170306162018.GC18519@leverpostej>
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, will.deacon@arm.com

Hi,

[roping in Will, since he loves atomics]

On Mon, Mar 06, 2017 at 03:24:23PM +0100, Dmitry Vyukov wrote:
> On Mon, Mar 6, 2017 at 2:01 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Mon, Mar 06, 2017 at 01:58:51PM +0100, Peter Zijlstra wrote:
> >> On Mon, Mar 06, 2017 at 01:50:47PM +0100, Dmitry Vyukov wrote:
> >> > On Mon, Mar 6, 2017 at 1:42 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> >> > > KASAN uses compiler instrumentation to intercept all memory accesses.
> >> > > But it does not see memory accesses done in assembly code.
> >> > > One notable user of assembly code is atomic operations. Frequently,
> >> > > for example, an atomic reference decrement is the last access to an
> >> > > object and a good candidate for a racy use-after-free.
> >> > >
> >> > > Add manual KASAN checks to atomic operations.
> >> > > Note: we need checks only before asm blocks and don't need them
> >> > > in atomic functions composed of other atomic functions
> >> > > (e.g. load-cmpxchg loops).
> >> >
> >> > Peter, also pointed me at arch/x86/include/asm/bitops.h. Will add them in v2.
> >> >
> >>
> >> > >  static __always_inline void atomic_add(int i, atomic_t *v)
> >> > >  {
> >> > > +       kasan_check_write(v, sizeof(*v));
> >> > >         asm volatile(LOCK_PREFIX "addl %1,%0"
> >> > >                      : "+m" (v->counter)
> >> > >                      : "ir" (i));
> >>
> >>
> >> So the problem is doing load/stores from asm bits, and GCC
> >> (traditionally) doesn't try and interpret APP asm bits.
> >>
> >> However, could we not write a GCC plugin that does exactly that?
> >> Something that interprets the APP asm bits and generates these KASAN
> >> bits that go with it?
> >
> > Another suspect is the per-cpu stuff, that's all asm foo as well.

Unfortunately, I think that manual annotation is the only way to handle
these (as we already do for kernel part of the uaccess sequences), since
we hide things from the compiler or otherwise trick it into doing what
we want.

> +x86, Mark
> 
> Let me provide more context and design alternatives.
> 
> There are also other archs, at least arm64 for now.
> There are also other tools. For KTSAN (race detector) we will
> absolutely need to hook into atomic ops. For KMSAN (uses of unit
> values) we also need to understand atomic ops at least to some degree.
> Both of them will require different instrumentation.
> For KASAN we are also more interested in cases where it's more likely
> that an object is touched only by an asm, but not by normal memory
> accesses (otherwise we would report the bug on the normal access,
> which is fine, this makes atomic ops stand out in my opinion).
> 
> We could involve compiler (and by compiler I mean clang, because we
> are not going to touch gcc, any volunteers?).

I don't think there's much you'll be able to do within the compiler,
assuming you mean to derive this from the asm block inputs and outputs.

Those can hide address-generation (e.g. with per-cpu stuff), which the
compiler may erroneously be detected as racing.

Those may also take fake inputs (e.g. the sp input to arm64's
__my_cpu_offset()) which may confuse matters.

Parsing the assembly itself will be *extremely* painful due to the way
that's set up for run-time patching.

> However, it's unclear if it will be simpler or not. There will
> definitely will be a problem with uaccess asm blocks. Currently KASAN
> relies of the fact that it does not see uaccess accesses and the user
> addresses are considered bad by KASAN. There can also be a problem
> with offsets/sizes, it's not possible to figure out what exactly an
> asm block touches, we can only assume that it directly dereferences
> the passed pointer. However, for example, bitops touch the pointer
> with offset. Looking at the current x86 impl, we should be able to
> handle it because the offset is computed outside of asm blocks. But
> it's unclear if we hit this problem in other places.

As above, I think you'd see more fun for the percpu stuff, since the
pointer passed into those is "fake", with a percpu pointer accessing
different addresses dependent on the CPU it is executed on.

> I also see that arm64 bitops are implemented in .S files. And we won't
> be able to instrument them in compiler.
> There can also be other problems. Is it possible that some asm blocks
> accept e.g. physical addresses? KASAN would consider them as bad.

I'm not sure I follow what you mean here.

I can imagine physical addresses being passed into asm statements that
don't access memory (e.g. for setting up the base registers for page
tables).

> We could also provide a parallel implementation of atomic ops based on
> the new compiler builtins (__atomic_load_n and friends):
> https://gcc.gnu.org/onlinedocs/gcc/_005f_005fatomic-Builtins.html
> and enable it under KSAN. The nice thing about it is that it will
> automatically support arm64 and KMSAN and KTSAN.
> But it's more work.

These don't permit runtime patching, and there are some differences
between the C11 and Linux kernel memory models, so at least in the near
term, I don't imagine we'd be likely to use this.

> Re per-cpu asm. I would say that it's less critical than atomic ops.
> Static per-cpu slots are not subject to use-after-free. Dynamic slots
> can be subject to use-after-free and it would be nice to catch bugs
> there. However, I think we will need to add manual
> poisoning/unpoisoning of dynamic slots as well.
> 
> Bottom line:
> 1. Involving compiler looks quite complex, hard to deploy, and it's
> unclear if it will actually make things easier.
> 2. This patch is the simplest short-term option (I am leaning towards
> adding bitops to this patch and leaving percpu out for now).
> 3. Providing an implementation of atomic ops based on compiler
> builtins looks like a nice option for other archs and tools, but is
> more work. If you consider this as a good solution, we can move
> straight to this option.

Having *only* seen the assembly snippet at the top of this mail, I can't
say whether this is the simplest implementation.

However, I do think that annotation of this sort is the only reasonable
way to handle this.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
