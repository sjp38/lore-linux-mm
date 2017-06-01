Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9B96B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 13:39:18 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id c185so13934188vkd.13
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 10:39:18 -0700 (PDT)
Received: from mail-ua0-x230.google.com (mail-ua0-x230.google.com. [2607:f8b0:400c:c08::230])
        by mx.google.com with ESMTPS id i6si10025556vkb.112.2017.06.01.10.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 10:39:17 -0700 (PDT)
Received: by mail-ua0-x230.google.com with SMTP id u10so31831019uaf.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 10:39:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Z02Un5DEjmhow4bSLOBygoC2mg7t_KKGn64WnWXQw0qw@mail.gmail.com>
References: <20170601162338.23540-1-aryabinin@virtuozzo.com>
 <20170601162338.23540-3-aryabinin@virtuozzo.com> <20170601163442.GC17711@leverpostej>
 <CACT4Y+aCKDF95mK2-nuiV0+XineHha3y+6PCW0-EorOaY=TFng@mail.gmail.com>
 <20170601165205.GA8191@leverpostej> <75ea368f-9268-44fd-f3f6-2a48dc8d2fe8@virtuozzo.com>
 <31a41822-35e1-1b4a-09f7-0a99571ee89a@virtuozzo.com> <CACT4Y+Z02Un5DEjmhow4bSLOBygoC2mg7t_KKGn64WnWXQw0qw@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 1 Jun 2017 19:38:56 +0200
Message-ID: <CACT4Y+a7BE25V=dyPCaaO3Tg2kwD04Fq2=U8qgFWDuQGvo_kcw@mail.gmail.com>
Subject: Re: [PATCH 3/4] arm64/kasan: don't allocate extra shadow memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, linux-arm-kernel@lists.infradead.org, Yuri Gribov <tetra2005@gmail.com>

On Thu, Jun 1, 2017 at 7:05 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>>>>> We used to read several bytes of the shadow memory in advance.
>>>>>>> Therefore additional shadow memory mapped to prevent crash if
>>>>>>> speculative load would happen near the end of the mapped shadow memory.
>>>>>>>
>>>>>>> Now we don't have such speculative loads, so we no longer need to map
>>>>>>> additional shadow memory.
>>>>>>
>>>>>> I see that patch 1 fixed up the Linux helpers for outline
>>>>>> instrumentation.
>>>>>>
>>>>>> Just to check, is it also true that the inline instrumentation never
>>>>>> performs unaligned accesses to the shadow memory?
>>>>>
>>>
>>> Correct, inline instrumentation assumes that all accesses are properly aligned as it
>>> required by C standard. I knew that the kernel violates this rule in many places,
>>> therefore I decided to add checks for unaligned accesses in outline case.
>>>
>>>
>>>>> Inline instrumentation generally accesses only a single byte.
>>>>
>>>> Sorry to be a little pedantic, but does that mean we'll never access the
>>>> additional shadow, or does that mean it's very unlikely that we will?
>>>>
>>>> I'm guessing/hoping it's the former!
>>>>
>>>
>>> Outline will never access additional shadow byte: https://github.com/google/sanitizers/wiki/AddressSanitizerAlgorithm#unaligned-accesses
>>
>> s/Outline/inline  of course.
>
>
> I suspect that actual implementations have diverged from that
> description. Trying to follow asan_expand_check_ifn in:
> https://gcc.gnu.org/viewcvs/gcc/trunk/gcc/asan.c?revision=246703&view=markup
> but it's not trivial.
>
> +Yuri, maybe you know off the top of your head if asan instrumentation
> in gcc ever accesses off-by-one shadow byte (i.e. 1 byte after actual
> object end)?

Thinking of this more. There is at least 1 case in user-space asan
where off-by-one shadow access would lead to similar crashes: for
mmap-ed regions we don't have redzones and map shadow only for the
region itself, so any off-by-one access would lead to crashes. So I
guess we are safe here. Or at least any crash would be gcc bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
