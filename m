Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6046B0253
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 04:54:35 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w2so11313035pfi.20
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 01:54:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z8sor4797851plk.79.2017.11.21.01.54.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 01:54:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <de1e0f95-4daa-0b00-a7bf-0ce2e9a3371b@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE> <CACT4Y+Zi9bNdnei_kXWu_3BHOobbhOgRKJ6Vk9QGs3c6NCdqXw@mail.gmail.com>
 <37111d5b-7042-dfff-9ac7-8733b77930e8@oracle.com> <CACT4Y+ZEvLJbM_b6nWqLPvVJgWjAp-eYsmbO5vT2qQ3_zH-2+A@mail.gmail.com>
 <de1e0f95-4daa-0b00-a7bf-0ce2e9a3371b@oracle.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 21 Nov 2017 10:54:12 +0100
Message-ID: <CACT4Y+aOOkm6aqPKaNmi-aBU4-F8SQTZe=-UkAQry-eQWxsS8w@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wengang <wen.gang.wang@oracle.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>

On Mon, Nov 20, 2017 at 9:29 PM, Wengang <wen.gang.wang@oracle.com> wrote:
>
>
> On 11/20/2017 12:20 PM, Dmitry Vyukov wrote:
>>
>> On Mon, Nov 20, 2017 at 9:05 PM, Wengang <wen.gang.wang@oracle.com> wrote:
>>>
>>>
>>> On 11/20/2017 12:41 AM, Dmitry Vyukov wrote:
>>>>
>>>>
>>>>> The reason I didn't submit the vchecker to mainline is that I didn't
>>>>> find
>>>>> the case that this tool is useful in real life. Most of the system
>>>>> broken
>>>>> case
>>>>> can be debugged by other ways. Do you see the real case that this tool
>>>>> is
>>>>> helpful?
>>>>
>>>> Hi,
>>>>
>>>> Yes, this is the main question here.
>>>> How is it going to be used in real life? How widely?
>>>>
>>> I think the owner check can be enabled in the cases where KASAN is used.
>>> --
>>> That is that we found there is memory issue, but don't know how it
>>> happened.
>>
>>
>> But KASAN generally pinpoints the corruption as it happens. Why do we
>> need something else?
>
>
> Currently (without this patch set) kasan can't detect the overwritten issues
> that happen on allocated memory.
>
> Say, A allocated a 128 bytes memory and B write to that memory at offset 0
> with length 100 unexpectedly.  Currently kasan won't report error for any
> writing to the offset 0 with len <= 128 including the B writting.  This
> patch lets kasan report the B writing to offset 0 with length 100.


So this will be used for manual debugging and you don't have plans to
annotate kernel code with additional tags, right?

If this meant to be used by kernel developers during debugging, this
feature needs to be documented in Documentation/dev-tools/kasan.rst
including an example. It's hard to spread knowledge about such
features especially if there are no mentions in docs. Documentation
can then be quickly referenced e.g. as a suggestion of how to tackle a
particular bug.

General comments:

1. The check must not affect fast-path. I think we need to move it
into kasan_report (and then rename kasan_report to something else).
Closer to what Joonsoo did in his version, but move then check even
further. This will also make inline instrumentation work because it
calls kasan_report, then kasan_report will do the additional check and
potentially return without actually reporting a bug.
The idea is that the check reserves some range of bad values in shadow
and poison the object with that special value. Then all accesses to
the protected memory will be detected as bad and go into kasan_report.
Then kasan_report will do the additional check and potentially return
without reporting.
This has 0 overhead when the feature is not used, enables inline
instrumentation and is less intrusive.

2. Moving this to a separate .c/.h files sounds like a good idea.
kasan.c is a bit of a mess already. If we do (1), changes to kasan.c
will be minimal. Again closer to what Joonsoo did.

3. We need to rename it from "advanced" to something else (owner
check?). Features must be named based on what they do, rather then how
advanced they are. If we add other complex checks, how should we name
them? even_more_advanced?

I am fine with adding such feature provided that it does not affect
performance/memory consumption if not used, works with inline
instrumentation and is separated into separate files. But it also
needs to be advertised somehow among kernel developers, otherwise only
you guys will use it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
