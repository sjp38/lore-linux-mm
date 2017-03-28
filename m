Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id F23B96B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 05:46:29 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id 71so54061038vkc.8
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:46:29 -0700 (PDT)
Received: from mail-vk0-x22d.google.com (mail-vk0-x22d.google.com. [2607:f8b0:400c:c05::22d])
        by mx.google.com with ESMTPS id 35si1468875uaz.190.2017.03.28.02.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 02:46:28 -0700 (PDT)
Received: by mail-vk0-x22d.google.com with SMTP id z204so81807698vkd.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:46:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328092712.bk32k5iteqqm6pgh@hirez.programming.kicks-ass.net>
References: <cover.1489519233.git.dvyukov@google.com> <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com> <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
 <20170324105700.GB20282@gmail.com> <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
 <20170328075232.GA19590@gmail.com> <20170328092712.bk32k5iteqqm6pgh@hirez.programming.kicks-ass.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Mar 2017 11:46:06 +0200
Message-ID: <CACT4Y+Yww1C03nEHj3UNGaffSYDhWo1b8VjDcCP88YOQdZv+=w@mail.gmail.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Tue, Mar 28, 2017 at 11:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Mar 28, 2017 at 09:52:32AM +0200, Ingo Molnar wrote:
>
>> No, regular C code.
>>
>> I don't see the point of generating all this code via CPP - it's certainly not
>> making it more readable to me. I.e. this patch I commented on is a step backwards
>> for readability.
>
> Note that much of the atomic stuff we have today is all CPP already.
>
> x86 is the exception because its 'weird', but most other archs are
> almost pure CPP -- check Alpha for example, or asm-generic/atomic.h.
>
> Also, look at linux/atomic.h, its a giant maze of CPP.
>
> The CPP help us generate functions, reduces endless copy/paste (which
> induces random differences -- read bugs) and construct variants
> depending on the architecture input.
>
> Yes, the CPP is a pain, but writing all that out explicitly is more of a
> pain.
>
>
>
> I've not yet looked too hard at these patches under consideration; and I
> really wish we could get the compiler to do the right thing here, but
> reducing the endless copy/paste that's otherwise the result of this, is
> something I've found to be very valuable.
>
> Not to mention that adding additional atomic ops got trivial (the set is
> now near complete, so that's not much of an argument anymore -- but it
> was, its what kept me sane sanitizing the atomic ops across all our 25+
> architectures).


I am almost done with Ingo's proposal, including de-macro-ifying x86
atomic ops code.
I am ready to do either of them, I think both have pros and cons and
there is no perfect solution. But please agree on something.


While we are here, one thing that I noticed is that 32-bit atomic code
uses 'long long' for 64-bit operands, while 64-bit code uses 'long'
for 64-bit operands. This sorta worked more of less before, but
ultimately it makes it impossible to write any portable code (e.g. you
don't know what format specifier to use to print return value of
atomic64_read, nor what local variable type to use to avoid compiler
warnings). With the try_cmpxchg it become worse, because 'long*' is
not convertible to 'long long*' so it is not possible to write any
portable code that uses it. If you declare 'old' variable as 'long'
32-bit code won't compile, if you declare it as 'long long' 64-bit
code won't compiler. I think we need to switch to a single type for
64-bit operands/return values, e.g. 'long long'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
