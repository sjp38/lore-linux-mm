Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 533446B039F
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 05:56:54 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id j137so54752400vke.3
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:56:54 -0700 (PDT)
Received: from mail-vk0-x233.google.com (mail-vk0-x233.google.com. [2607:f8b0:400c:c05::233])
        by mx.google.com with ESMTPS id x58si1474318uax.146.2017.03.28.02.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 02:56:53 -0700 (PDT)
Received: by mail-vk0-x233.google.com with SMTP id z204so82052833vkd.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:56:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328095151.GC30567@gmail.com>
References: <cover.1489519233.git.dvyukov@google.com> <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com> <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
 <20170324105700.GB20282@gmail.com> <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
 <20170328075232.GA19590@gmail.com> <20170328092712.bk32k5iteqqm6pgh@hirez.programming.kicks-ass.net>
 <20170328095151.GC30567@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Mar 2017 11:56:32 +0200
Message-ID: <CACT4Y+Y0YGifJhw0sFpSYh=SapUv93M0QDwZFyP-9q1fnqWZug@mail.gmail.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Tue, Mar 28, 2017 at 11:51 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Peter Zijlstra <peterz@infradead.org> wrote:
>
>> On Tue, Mar 28, 2017 at 09:52:32AM +0200, Ingo Molnar wrote:
>>
>> > No, regular C code.
>> >
>> > I don't see the point of generating all this code via CPP - it's certainly not
>> > making it more readable to me. I.e. this patch I commented on is a step backwards
>> > for readability.
>>
>> Note that much of the atomic stuff we have today is all CPP already.
>
> Yeah, but there it's implementational: we pick up arch primitives depending on
> whether they are defined, such as:
>
> #ifndef atomic_read_acquire
> # define atomic_read_acquire(v)         smp_load_acquire(&(v)->counter)
> #endif
>
>> x86 is the exception because its 'weird', but most other archs are
>> almost pure CPP -- check Alpha for example, or asm-generic/atomic.h.
>
> include/asm-generic/atomic.h looks pretty clean and readable overall.
>
>> Also, look at linux/atomic.h, its a giant maze of CPP.
>
> Nah, that's OK, much of is is essentially __weak inlines implemented via CPP -
> i.e. CPP is filling in a missing compiler feature.
>
> But this patch I replied to appears to add instrumentation wrappery via CPP which
> looks like excessive and avoidable obfuscation to me.
>
> If it's much more readable and much more compact than the C version then maybe,
> but I'd like to see the C version first and see ...
>
>> The CPP help us generate functions, reduces endless copy/paste (which induces
>> random differences -- read bugs) and construct variants depending on the
>> architecture input.
>>
>> Yes, the CPP is a pain, but writing all that out explicitly is more of a
>> pain.
>
> So I'm not convinced that it's true in this case.
>
> Could we see the C version and compare? I could be wrong about it all.

Here it is (without instrumentation):
https://gist.github.com/dvyukov/e33d580f701019e0cd99429054ff1f9a

Instrumentation will add for each function:

 static __always_inline void atomic64_set(atomic64_t *v, long long i)
 {
+       kasan_check_write(v, sizeof(*v));
        arch_atomic64_set(v, i);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
