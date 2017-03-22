Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08E8C6B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 13:33:56 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n141so178806463qke.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:33:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 124sor2069950qkh.11.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Mar 2017 10:33:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAeHK+zAt=iim4SoU5U8cD8i_yYoC_HGVKSvBGBgEO15KdZEPg@mail.gmail.com>
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
 <CAAeHK+zt9U+_8o4-k1mTvHsNTVGnKbzy7jVz2jn=TkNFf2neHQ@mail.gmail.com>
 <cbb22acb-1228-0f7b-c7a0-5822ea721b3f@virtuozzo.com> <CAAeHK+zAt=iim4SoU5U8cD8i_yYoC_HGVKSvBGBgEO15KdZEPg@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 22 Mar 2017 18:33:53 +0100
Message-ID: <CAG_fn=WpeCq70LGqt+GiYDSO72uvNWYndG+rGyMJzVuaFUcNQw@mail.gmail.com>
Subject: Re: [PATCH] kasan: report only the first error
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 22, 2017 at 6:07 PM, Andrey Konovalov <andreyknvl@google.com> w=
rote:
> On Wed, Mar 22, 2017 at 5:54 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> On 03/22/2017 07:34 PM, Andrey Konovalov wrote:
>>> On Wed, Mar 22, 2017 at 5:06 PM, Andrey Ryabinin
>>> <aryabinin@virtuozzo.com> wrote:
>>>> Disable kasan after the first report. There are several reasons for th=
is:
>>>>  * Single bug quite often has multiple invalid memory accesses causing
>>>>     storm in the dmesg.
>>>>  * Write OOB access might corrupt metadata so the next report will pri=
nt
>>>>     bogus alloc/free stacktraces.
>>>>  * Reports after the first easily could be not bugs by itself but just=
 side
>>>>     effects of the first one.
>>>>
>>>> Given that multiple reports only do harm, it makes sense to disable
>>>> kasan after the first one. Except for the tests in lib/test_kasan.c
>>>> as we obviously want to see all reports from test.
>>>
>>> Hi Andrey,
>>>
>>> Could you make it configurable via CONFIG_KASAN_SOMETHING (which can
>>> default to showing only the first report)?
>>
>> I'd rather make this boot time configurable, but wouldn't want to withou=
t
>> a good reason.
>
> That would work for me.
>
>>
>>
>>> I sometimes use KASAN to see what bad accesses a particular bug
>>> causes, and seeing all of them (even knowing that they may be
>>> corrupt/induced) helps a lot.
>>
>> I'm wondering why you need to see all reports?
>
> To get a better picture of what are the consequences of a bug. For
> example whether it leads to some bad or controllable memory
> corruption. Sometimes it's easier to let KASAN track the memory
> accesses then do that manually.
Another case is when you're seeing an OOB read at boot time, which has
limited impact, and you don't want to wait for the code owner to fix
it to move forward.
>>
>>>
>>> Thanks!
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
