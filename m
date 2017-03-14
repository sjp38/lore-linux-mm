Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 87D2E6B0389
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 13:15:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y17so390625819pgh.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 10:15:42 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id f35si4326191plh.40.2017.03.14.10.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 10:15:41 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id b129so93749487pgc.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 10:15:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <69679f30-e502-d2cf-8dee-4ee88f64f887@virtuozzo.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-7-andreyknvl@google.com> <db0b6605-32bc-4c7a-0c99-2e60e4bdb11f@virtuozzo.com>
 <CAG_fn=Vn1tWsRbt4ohkE0E2ijAZsBvVuPS-Ond2KHVh9WK1zkg@mail.gmail.com>
 <2bbe7bdc-8842-8ec0-4b5a-6a8dce39216d@virtuozzo.com> <CAAeHK+xnHx5fvhq158+oxMxieG7a+gG7i0MQS92DqxYGe0O=Ww@mail.gmail.com>
 <576aeb81-9408-13fa-041d-a6bd1e2cf895@virtuozzo.com> <CAAeHK+w087z_pEWN=ZBDZN=XqqQMFZ9eevX44LERFV-d=G3F8g@mail.gmail.com>
 <CAAeHK+xCo+JcFstGz+xhgX2qvkP1zpwOg9VD0N-oD4Q=YcSi7A@mail.gmail.com> <69679f30-e502-d2cf-8dee-4ee88f64f887@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 14 Mar 2017 18:15:40 +0100
Message-ID: <CAAeHK+yMCqcLW1UbJ+iEG5628wO6j=d9a7cRdPTbZTBoK-CfbQ@mail.gmail.com>
Subject: Re: [PATCH v2 6/9] kasan: improve slab object description
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 9, 2017 at 1:56 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> On 03/06/2017 08:16 PM, Andrey Konovalov wrote:
>
>>>
>>> What about
>>>
>>> Object at ffff880068388540 belongs to cache kmalloc-128 of size 128
>>> Accessed address is 123 bytes inside of [ffff880068388540, ffff8800683885c0)
>>>
>>> ?
>>
>> Another alternative:
>>
>> Accessed address is 123 bytes inside of [ffff880068388540, ffff8800683885c0)
>> Object belongs to cache kmalloc-128 of size 128
>>
>
> Is it something wrong with just printing offset at the end as I suggested earlier?
> It's more compact and also more clear IMO.

This is what you suggested:

Object at ffff880068388540, in cache kmalloc-128 size: 128 accessed at
offset 123

After minor reworking of punctuation, etc, we get:

Object at ffff880068388540, in cache kmalloc-128 of size 128, accessed
at offset 123

It's good, but I still don't like two things:

1. The line is quite long. Over 84 characters in this example, but
might be longer for different cache names. The solution would be to
split it into two lines.

2. The access might be within the object (for example use-after-free),
or outside the object (slab-out-of-bounds). In this case just saying
"accessed at offset X" might be confusing, since the offset might be
from the start of the object, or might be from the end. The solution
would be to specifically describe this.

Out of all options above this one I like the most:

>> Accessed address is 123 bytes inside of [ffff880068388540, ffff8800683885c0)
>> Object belongs to cache kmalloc-128 of size 128

as:

1. It specifies whether the offset is inside or outside the object.
2. The lines are not too long (the first one is 76 chars).
3. Accounts for larger cache names (the second line has some spare space).
4. Shows exact addresses of start and end of the object (it's possible
to calculate the end address using the start and the size, but it's
nicer to have it already calculated and shown).

Thanks!

>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/69679f30-e502-d2cf-8dee-4ee88f64f887%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
