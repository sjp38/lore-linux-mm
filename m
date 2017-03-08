Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3E0C831ED
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:27:33 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id g43so54164229uah.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:27:33 -0800 (PST)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id j39si1582374uaf.89.2017.03.08.07.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:27:32 -0800 (PST)
Received: by mail-ua0-x22f.google.com with SMTP id f54so39481043uaa.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:27:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170308152027.GA13133@leverpostej>
References: <20170306124254.77615-1-dvyukov@google.com> <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net> <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej> <20170306203500.GR6500@twins.programming.kicks-ass.net>
 <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com> <20170308152027.GA13133@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 8 Mar 2017 16:27:11 +0100
Message-ID: <CACT4Y+bZqiE9Mxq1y4vdyT6=DCq0L+y_HjBH1=RJf5C9134CwQ@mail.gmail.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Wed, Mar 8, 2017 at 4:20 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> Hi,
>
> On Wed, Mar 08, 2017 at 02:42:10PM +0100, Dmitry Vyukov wrote:
>> I think if we scope compiler atomic builtins to KASAN/KTSAN/KMSAN (and
>> consequently x86/arm64) initially, it becomes more realistic. For the
>> tools we don't care about absolute efficiency and this gets rid of
>> Will's points (2), (4) and (6) here https://lwn.net/Articles/691295/.
>> Re (3) I think rmb/wmb can be reasonably replaced with
>> atomic_thread_fence(acquire/release). Re (5) situation with
>> correctness becomes better very quickly as more people use them in
>> user-space. Since KASAN is not intended to be used in production (or
>> at least such build is expected to crash), we can afford to shake out
>> any remaining correctness issues in such build. (1) I don't fully
>> understand, what exactly is the problem with seq_cst?
>
> I'll have to leave it to Will to have the final word on these; I'm
> certainly not familiar enough with the C11 memory model to comment on
> (1).
>
> However, w.r.t. (3), I don't think we can substitute rmb() and wmb()
> with atomic_thread_fence_acquire() and atomic_thread_fence_release()
> respectively on arm64.
>
> The former use barriers with full system scope, whereas the latter may
> be limited to the inner shareable domain. While I'm not sure of the
> precise intended semantics of wmb() and rmb(), I believe this
> substitution would break some cases (e.g. communicating with a
> non-coherent master).
>
> Note that regardless, we'd have to special-case __iowmb() to use a full
> system barrier.
>
> Also, w.r.t. (5), modulo the lack of atomic instrumentation, people use
> KASAN today, with compilers that are known to have bugs in their atomics
> (e.g. GCC bug 69875). Thus, we cannot rely on the compiler's
> implementation of atomics without introducing a functional regression.
>
>> i'Ve sketched a patch that does it, and did some testing with/without
>> KASAN on x86_64.
>>
>> In short, it adds include/linux/atomic_compiler.h which is included
>> from include/linux/atomic.h when CONFIG_COMPILER_ATOMIC is defined;
>> and <asm/atomic.h> is not included when CONFIG_COMPILER_ATOMIC is
>> defined.
>> For bitops it is similar except that only parts of asm/bitops.h are
>> selectively disabled when CONFIG_COMPILER_ATOMIC, because it also
>> defines other stuff.
>> asm/barriers.h is left intact for now. We don't need it for KASAN. But
>> for KTSAN we can do similar thing -- selectively disable some of the
>> barriers in asm/barriers.h (e.g. leaving dma_rmb/wmb per arch).
>>
>> Such change would allow us to support atomic ops for multiple arches
>> for all of KASAN/KTSAN/KMSAN.
>>
>> Thoughts?
>
> As in my other reply, I'd prefer that we wrapped the (arch-specific)
> atomic implementations such that we can instrument them explicitly in a
> core header. That means that the implementation and semantics of the
> atomics don't change at all.
>
> Note that we could initially do this just for x86 and arm64), e.g. by
> having those explicitly include an <asm-generic/atomic-instrumented.h>
> at the end of their <asm/atomic.h>.

How exactly do you want to do this incrementally?
I don't feel ready to shuffle all archs, but doing x86 in one patch
and then arm64 in another looks tractable.


> For architectures which can use the compiler's atomics, we can allow
> them to do so, skipping the redundant explicit instrumentation.
>
> Other than being potentially slower (which we've established we don't
> care too much about above), is there a problem with that approach?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
