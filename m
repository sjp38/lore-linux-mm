Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB156B0265
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 08:18:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n2so26480649wma.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 05:18:42 -0700 (PDT)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id f28si138863lfi.289.2016.06.02.05.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 05:18:41 -0700 (PDT)
Received: by mail-lf0-x22a.google.com with SMTP id w16so32624848lfd.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 05:18:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <575023EC.9090007@virtuozzo.com>
References: <1464691466-59010-1-git-send-email-glider@google.com>
 <574D7B11.8090709@virtuozzo.com> <CAG_fn=UuSs=aUst5Ww3RGF-SvOprUYPs2Y3-dD=w1b80-D_R-A@mail.gmail.com>
 <574EFE0F.2000404@virtuozzo.com> <CAG_fn=Xt1EuNwkHRJ5C=D-R=7SppUERWKRzih1rDzX3=+AXcsA@mail.gmail.com>
 <CAG_fn=WfuYimaz6M9WWn+vPd=GsGN=kybbHZCL8PNBXOwFtqWA@mail.gmail.com> <575023EC.9090007@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 2 Jun 2016 14:18:40 +0200
Message-ID: <CAG_fn=WG-WucdPkjmK0fcThCLF6e2FzthLpvJdzNOeqEEQ1xuQ@mail.gmail.com>
Subject: Re: [PATCH] mm, kasan: introduce a special shadow value for allocator metadata
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 2, 2016 at 2:17 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
> On 06/02/2016 03:02 PM, Alexander Potapenko wrote:
>> On Wed, Jun 1, 2016 at 6:31 PM, Alexander Potapenko <glider@google.com> =
wrote:
>>> On Wed, Jun 1, 2016 at 5:23 PM, Andrey Ryabinin <aryabinin@virtuozzo.co=
m> wrote:
>>>> On 05/31/2016 08:49 PM, Alexander Potapenko wrote:
>>>>> On Tue, May 31, 2016 at 1:52 PM, Andrey Ryabinin
>>>>> <aryabinin@virtuozzo.com> wrote:
>>>>>>
>>>>>>
>>>>>> On 05/31/2016 01:44 PM, Alexander Potapenko wrote:
>>>>>>> Add a special shadow value to distinguish accesses to KASAN-specifi=
c
>>>>>>> allocator metadata.
>>>>>>>
>>>>>>> Unlike AddressSanitizer in the userspace, KASAN lets the kernel pro=
ceed
>>>>>>> after a memory error. However a write to the kmalloc metadata may c=
ause
>>>>>>> memory corruptions that will make the tool itself unreliable and in=
duce
>>>>>>> crashes later on. Warning about such corruptions will ease the
>>>>>>> debugging.
>>>>>>
>>>>>> It will not. Whether out-of-bounds hits metadata or not is absolutel=
y irrelevant
>>>>>> to the bug itself. This information doesn't help to understand, anal=
yze or fix the bug.
>>>>>>
>>>>> Here's the example that made me think the opposite.
>>>>>
>>>>> I've been reworking KASAN hooks for mempool and added a test that did
>>>>> a write-after-free to an object allocated from a mempool.
>>>>> This resulted in flaky kernel crashes somewhere in quarantine
>>>>> shrinking after several attempts to `insmod test_kasan.ko`.
>>>>> Because there already were numerous KASAN errors in the test, it
>>>>> wasn't evident that the crashes were related to the new test, so I
>>>>> thought the problem was in the buggy quarantine implementation.
>>>>> However the problem was indeed in the new test, which corrupted the
>>>>> quarantine pointer in the object and caused a crash while traversing
>>>>> the quarantine list.
>>>>>
>>>>> My previous experience with userspace ASan shows that crashes in the
>>>>> tool code itself puzzle the developers.
>>>>> As a result, the users think that the tool is broken and don't believ=
e
>>>>> its reports.
>>>>>
>>>>> I first thought about hardening the quarantine list by checksumming
>>>>> the pointers and validating them on each traversal.
>>>>> This prevents the crashes, but doesn't give the users any idea about
>>>>> what went wrong.
>>>>> On the other hand, reporting the pointer corruption right when it hap=
pens does.
>>>>> Distinguishing between a regular UAF and a quarantine corruption
>>>>> (which is what the patch in question is about) helps to prioritize th=
e
>>>>> KASAN reports and give the developers better understanding of the
>>>>> consequences.
>>>>>
>>>>
>>>> After the first report we have memory in a corrupted state, so we are =
done here.
>>> This is theoretically true, that's why we crash after the first report
>>> in the userspace ASan.
>>> But since the kernel proceeds after the first KASAN report, it's
>>> possible that we see several different reports, and they are sometimes
>>> worth looking at.
>>>
>>>> Anything that happens after the first report can't be trusted since it=
 can be an after-effect,
>>>> just like in your case. Such crashes are not worthy to look at.
>>>> Out-of-bounds that doesn't hit metadata as any other memory corruption=
 also can lead to after-effects crashes,
>>>> thus distinguishing such bugs doesn't make a lot of sense.
>>> Unlike the crashes in the kernel itself, crashes with KASAN functions
>>> in the stack trace may make the developer think the tool is broken.
>>>>
>>>> test_kasan module is just a quick hack, made only to make sure that KA=
SAN works.
>>>> It does some crappy thing, and may lead to crash as well. So I would r=
ecommend an immediate
>>>> reboot even after single attempt to load it.
>>> Agreed. However a plain write into the first byte of the freed object
>>> will cause similar problems.
>>
>> On a second thought, we could do without the additional shadow byte
>> value, by just comparing the address to the metadata offset.
>>
>
> We could. But still, there is no point in doing anything like that.
Ok, got it.


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
