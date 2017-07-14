Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B36264408E5
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 02:13:55 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r74so6049413oie.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 23:13:55 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id a22si5632099oib.276.2017.07.13.23.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 23:13:54 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id x187so63944430oig.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 23:13:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <c7160aca-a203-e3d8-eb49-b051aff78f0e@google.com>
References: <20170706220114.142438-1-ghackmann@google.com> <20170706220114.142438-2-ghackmann@google.com>
 <CACT4Y+YWLc3n-PBcD1Cmu_FLGSDd+vyTTyeBamk2bBZhdWJSoA@mail.gmail.com> <c7160aca-a203-e3d8-eb49-b051aff78f0e@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 14 Jul 2017 08:13:33 +0200
Message-ID: <CACT4Y+Yo1gKVJQF74kG5gZ60Qmzo65=6NLnN69ybd+QtzfAi1w@mail.gmail.com>
Subject: Re: [PATCH 1/4] kasan: support alloca() poisoning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Hackmann <ghackmann@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>

On Fri, Jul 14, 2017 at 12:40 AM, Greg Hackmann <ghackmann@google.com> wrote:
> Hi,
>
> Thanks for taking a look at this patchstack.  I apologize for the delay in
> responding.
>
> On 07/10/2017 01:44 AM, Dmitry Vyukov wrote:
>>>
>>> +
>>> +       const void *left_redzone = (const void *)(addr -
>>> +                       KASAN_ALLOCA_REDZONE_SIZE);
>>> +       const void *right_redzone = (const void *)(addr +
>>> rounded_up_size);
>>
>>
>> Please check that size is rounded to KASAN_ALLOCA_REDZONE_SIZE. That's
>> the expectation, right? That can change is clang silently.
>>
>>> +       kasan_poison_shadow(left_redzone, KASAN_ALLOCA_REDZONE_SIZE,
>>> +                       KASAN_ALLOCA_LEFT);
>>> +       kasan_poison_shadow(right_redzone,
>>> +                       padding_size + KASAN_ALLOCA_REDZONE_SIZE,
>>> +                       KASAN_ALLOCA_RIGHT);
>>
>>
>> We also need to poison the unaligned part at the end of the object
>> from size to rounded_up_size. You can see how we do it for heap
>> objects.
>
>
> The expectation is that `size' is the exact size of the alloca()ed object.
> `rounded_up_size' then adds the 0-7 bytes needed to adjust the size to the
> ASAN shadow scale.  So `addr + rounded_up_size' should be the correct place
> to start poisoning.


We need to start poisoning at addr+size exactly.
Asan shadow scheme supports this. It's not possible to poison
beginning of an aligned 8-byte block, but leave tail unpoisoned. But
it is possible to poison tail of an aligned 8-byte block and leave
beginning unpoisoned. Look at what we do for kmalloc.


> In retrospect this part of the code was pretty confusing.  How about this?
> I think its intent is clearer, plus it's a closer match for the description
> in my commit message:
>
>         unsigned long left_redzone_start;
>         unsigned long object_end;
>         unsigned long right_redzone_start, right_redzone_end;
>
>         left_redzone_start = addr - KASAN_ALLOCA_REDZONE_SIZE;
>         kasan_poison_shadow((const void *)left_redzone_start,
>                         KASAN_ALLOCA_REDZONE_SIZE,
>                         KASAN_ALLOCA_LEFT);
>
>         object_end = round_up(addr + size, KASAN_SHADOW_SCALE_SIZE);
>         right_redzone_start = round_up(object_end,
> KASAN_ALLOCA_REDZONE_SIZE);
>         right_redzone_end = right_redzone_start + KASAN_ALLOCA_REDZONE_SIZE;
>         kasan_poison_shadow((const void *)object_end,
>                         right_redzone_end - object_end,
>                         KASAN_ALLOCA_RIGHT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
