Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 784736B03DA
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:20:58 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id w189so60669923pfb.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:20:58 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q64si3536696pga.342.2017.03.08.07.20.57
        for <linux-mm@kvack.org>;
        Wed, 08 Mar 2017 07:20:57 -0800 (PST)
Date: Wed, 8 Mar 2017 15:20:41 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170308152027.GA13133@leverpostej>
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej>
 <20170306203500.GR6500@twins.programming.kicks-ass.net>
 <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

Hi,

On Wed, Mar 08, 2017 at 02:42:10PM +0100, Dmitry Vyukov wrote:
> I think if we scope compiler atomic builtins to KASAN/KTSAN/KMSAN (and
> consequently x86/arm64) initially, it becomes more realistic. For the
> tools we don't care about absolute efficiency and this gets rid of
> Will's points (2), (4) and (6) here https://lwn.net/Articles/691295/.
> Re (3) I think rmb/wmb can be reasonably replaced with
> atomic_thread_fence(acquire/release). Re (5) situation with
> correctness becomes better very quickly as more people use them in
> user-space. Since KASAN is not intended to be used in production (or
> at least such build is expected to crash), we can afford to shake out
> any remaining correctness issues in such build. (1) I don't fully
> understand, what exactly is the problem with seq_cst?

I'll have to leave it to Will to have the final word on these; I'm
certainly not familiar enough with the C11 memory model to comment on
(1).

However, w.r.t. (3), I don't think we can substitute rmb() and wmb()
with atomic_thread_fence_acquire() and atomic_thread_fence_release()
respectively on arm64.

The former use barriers with full system scope, whereas the latter may
be limited to the inner shareable domain. While I'm not sure of the
precise intended semantics of wmb() and rmb(), I believe this
substitution would break some cases (e.g. communicating with a
non-coherent master).

Note that regardless, we'd have to special-case __iowmb() to use a full
system barrier.

Also, w.r.t. (5), modulo the lack of atomic instrumentation, people use
KASAN today, with compilers that are known to have bugs in their atomics
(e.g. GCC bug 69875). Thus, we cannot rely on the compiler's
implementation of atomics without introducing a functional regression.

> i'Ve sketched a patch that does it, and did some testing with/without
> KASAN on x86_64.
> 
> In short, it adds include/linux/atomic_compiler.h which is included
> from include/linux/atomic.h when CONFIG_COMPILER_ATOMIC is defined;
> and <asm/atomic.h> is not included when CONFIG_COMPILER_ATOMIC is
> defined.
> For bitops it is similar except that only parts of asm/bitops.h are
> selectively disabled when CONFIG_COMPILER_ATOMIC, because it also
> defines other stuff.
> asm/barriers.h is left intact for now. We don't need it for KASAN. But
> for KTSAN we can do similar thing -- selectively disable some of the
> barriers in asm/barriers.h (e.g. leaving dma_rmb/wmb per arch).
> 
> Such change would allow us to support atomic ops for multiple arches
> for all of KASAN/KTSAN/KMSAN.
> 
> Thoughts?

As in my other reply, I'd prefer that we wrapped the (arch-specific)
atomic implementations such that we can instrument them explicitly in a
core header. That means that the implementation and semantics of the
atomics don't change at all.

Note that we could initially do this just for x86 and arm64), e.g. by
having those explicitly include an <asm-generic/atomic-instrumented.h>
at the end of their <asm/atomic.h>.

For architectures which can use the compiler's atomics, we can allow
them to do so, skipping the redundant explicit instrumentation.

Other than being potentially slower (which we've established we don't
care too much about above), is there a problem with that approach?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
