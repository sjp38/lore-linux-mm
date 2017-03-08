Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34881831ED
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:46:20 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id f54so52882336uaa.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:46:20 -0800 (PST)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id p25si1607166uac.210.2017.03.08.07.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:46:19 -0800 (PST)
Received: by mail-ua0-x22f.google.com with SMTP id u30so44157058uau.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:46:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170308154357.GB13133@leverpostej>
References: <20170306124254.77615-1-dvyukov@google.com> <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net> <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej> <20170306203500.GR6500@twins.programming.kicks-ass.net>
 <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com>
 <20170308152027.GA13133@leverpostej> <CACT4Y+bZqiE9Mxq1y4vdyT6=DCq0L+y_HjBH1=RJf5C9134CwQ@mail.gmail.com>
 <20170308154357.GB13133@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 8 Mar 2017 16:45:58 +0100
Message-ID: <CACT4Y+ahGRxn7j8ZX=rTbwGm_eie-Wy81nKg9RGwjHzodFCK8g@mail.gmail.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Wed, Mar 8, 2017 at 4:43 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Wed, Mar 08, 2017 at 04:27:11PM +0100, Dmitry Vyukov wrote:
>> On Wed, Mar 8, 2017 at 4:20 PM, Mark Rutland <mark.rutland@arm.com> wrote:
>> > As in my other reply, I'd prefer that we wrapped the (arch-specific)
>> > atomic implementations such that we can instrument them explicitly in a
>> > core header. That means that the implementation and semantics of the
>> > atomics don't change at all.
>> >
>> > Note that we could initially do this just for x86 and arm64), e.g. by
>> > having those explicitly include an <asm-generic/atomic-instrumented.h>
>> > at the end of their <asm/atomic.h>.
>>
>> How exactly do you want to do this incrementally?
>> I don't feel ready to shuffle all archs, but doing x86 in one patch
>> and then arm64 in another looks tractable.
>
> I guess we'd have three patches: one adding the header and any core
> infrastructure, followed by separate patches migrating arm64 and x86
> over.

But if we add e.g. atomic_read() which forwards to arch_atomic_read()
to <linux/atomic.h>, it will break all archs that don't rename its
atomic_read() to arch_atomic_read().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
