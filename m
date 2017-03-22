Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0316B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 13:07:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c87so302878016pfl.6
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:07:34 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id h127si1760594pfg.163.2017.03.22.10.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 10:07:33 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id g2so110179568pge.3
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:07:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cbb22acb-1228-0f7b-c7a0-5822ea721b3f@virtuozzo.com>
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
 <CAAeHK+zt9U+_8o4-k1mTvHsNTVGnKbzy7jVz2jn=TkNFf2neHQ@mail.gmail.com> <cbb22acb-1228-0f7b-c7a0-5822ea721b3f@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 22 Mar 2017 18:07:32 +0100
Message-ID: <CAAeHK+zAt=iim4SoU5U8cD8i_yYoC_HGVKSvBGBgEO15KdZEPg@mail.gmail.com>
Subject: Re: [PATCH] kasan: report only the first error
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 22, 2017 at 5:54 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 03/22/2017 07:34 PM, Andrey Konovalov wrote:
>> On Wed, Mar 22, 2017 at 5:06 PM, Andrey Ryabinin
>> <aryabinin@virtuozzo.com> wrote:
>>> Disable kasan after the first report. There are several reasons for this:
>>>  * Single bug quite often has multiple invalid memory accesses causing
>>>     storm in the dmesg.
>>>  * Write OOB access might corrupt metadata so the next report will print
>>>     bogus alloc/free stacktraces.
>>>  * Reports after the first easily could be not bugs by itself but just side
>>>     effects of the first one.
>>>
>>> Given that multiple reports only do harm, it makes sense to disable
>>> kasan after the first one. Except for the tests in lib/test_kasan.c
>>> as we obviously want to see all reports from test.
>>
>> Hi Andrey,
>>
>> Could you make it configurable via CONFIG_KASAN_SOMETHING (which can
>> default to showing only the first report)?
>
> I'd rather make this boot time configurable, but wouldn't want to without
> a good reason.

That would work for me.

>
>
>> I sometimes use KASAN to see what bad accesses a particular bug
>> causes, and seeing all of them (even knowing that they may be
>> corrupt/induced) helps a lot.
>
> I'm wondering why you need to see all reports?

To get a better picture of what are the consequences of a bug. For
example whether it leads to some bad or controllable memory
corruption. Sometimes it's easier to let KASAN track the memory
accesses then do that manually.

>
>>
>> Thanks!
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
