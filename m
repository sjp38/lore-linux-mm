Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4036B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 14:21:25 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id na2so2935066lbb.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:21:25 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id j1si16562175lbp.108.2016.06.17.11.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 11:21:24 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id h129so2709654lfh.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:21:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57641364.5000001@virtuozzo.com>
References: <1466004364-57279-1-git-send-email-glider@google.com>
 <5761873A.2020104@virtuozzo.com> <CAG_fn=X8szV17tk+TBGXbKy881aNBeA=7F48_wD62LHYhjpvnw@mail.gmail.com>
 <57641364.5000001@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 Jun 2016 20:21:22 +0200
Message-ID: <CAG_fn=V+dpYJXjgdMJqxwOUk2+n5+m3pNxAGtGOA=EYr54tqOQ@mail.gmail.com>
Subject: Re: [PATCH v3] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 17, 2016 at 5:12 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 06/17/2016 05:27 PM, Alexander Potapenko wrote:
>> On Wed, Jun 15, 2016 at 6:50 PM, Andrey Ryabinin
>> <aryabinin@virtuozzo.com> wrote:
>>>
>>>
>>> On 06/15/2016 06:26 PM, Alexander Potapenko wrote:
>>>> For KASAN builds:
>>>>  - switch SLUB allocator to using stackdepot instead of storing the
>>>>    allocation/deallocation stacks in the objects;
>>>>  - define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to zero,
>>>>    effectively disabling these debug features, as they're redundant in
>>>>    the presence of KASAN;
>>>
>>> So, why we forbid these? If user wants to set these, why not? If you do=
n't want it, just don't turn them on, that's it.
>> SLAB_RED_ZONE simply doesn't work with KASAN.
>
> Why? This sounds like a bug.
I'm looking now. There are some issues with the left redzone being
added, which messes up the offsets.
I'd say it's no surprise that different debugging tools do not work
together, like e.g. KASAN and kmemcheck are not expected to.
>> With additional efforts it may work, but I don't think we really need
>> that. Extra red zones will just bloat the heap, and won't give any
>> interesting signal except "someone corrupted this object from
>> non-instrumented code".
>> SLAB_POISON doesn't crash on simple tests, but I am not sure there are
>> no corner cases which I haven't checked, so I thought it's safer to
>> disable it.
>> As I said before, we can make SLAB_STORE_USER use stackdepot in a
>> later CL, thus we disable it now.
>>
>
> This doesn't explain why we need this. What's the problem you are trying =
to solve by this? And why it is ok to silently ignore user requests?
Agreed, there's no point in redefining the flag constants.
> You think that these options are redundant, I get it. Well, then just don=
't turn them on.
> But, when a user requests for something, he expects that such request wil=
l be fulfilled, not just ignored.
Yes, I'd better just document the incompatibility between the
different operation modes (if I don't solve the problem).
>>> And sometimes POISON/REDZONE might be actually useful. KASAN doesn't ca=
tch everything,
>>> e.g. corruption may happen in assembly code, or DMA by  some device.
>>>
>>>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
