Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26C1B6B0253
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 11:23:23 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id i11so40526345igh.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:23:23 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0112.outbound.protection.outlook.com. [157.56.112.112])
        by mx.google.com with ESMTPS id 68si27718371otp.125.2016.06.01.08.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 08:23:21 -0700 (PDT)
Subject: Re: [PATCH] mm, kasan: introduce a special shadow value for allocator
 metadata
References: <1464691466-59010-1-git-send-email-glider@google.com>
 <574D7B11.8090709@virtuozzo.com>
 <CAG_fn=UuSs=aUst5Ww3RGF-SvOprUYPs2Y3-dD=w1b80-D_R-A@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <574EFE0F.2000404@virtuozzo.com>
Date: Wed, 1 Jun 2016 18:23:59 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UuSs=aUst5Ww3RGF-SvOprUYPs2Y3-dD=w1b80-D_R-A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/31/2016 08:49 PM, Alexander Potapenko wrote:
> On Tue, May 31, 2016 at 1:52 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 05/31/2016 01:44 PM, Alexander Potapenko wrote:
>>> Add a special shadow value to distinguish accesses to KASAN-specific
>>> allocator metadata.
>>>
>>> Unlike AddressSanitizer in the userspace, KASAN lets the kernel proceed
>>> after a memory error. However a write to the kmalloc metadata may cause
>>> memory corruptions that will make the tool itself unreliable and induce
>>> crashes later on. Warning about such corruptions will ease the
>>> debugging.
>>
>> It will not. Whether out-of-bounds hits metadata or not is absolutely irrelevant
>> to the bug itself. This information doesn't help to understand, analyze or fix the bug.
>>
> Here's the example that made me think the opposite.
> 
> I've been reworking KASAN hooks for mempool and added a test that did
> a write-after-free to an object allocated from a mempool.
> This resulted in flaky kernel crashes somewhere in quarantine
> shrinking after several attempts to `insmod test_kasan.ko`.
> Because there already were numerous KASAN errors in the test, it
> wasn't evident that the crashes were related to the new test, so I
> thought the problem was in the buggy quarantine implementation.
> However the problem was indeed in the new test, which corrupted the
> quarantine pointer in the object and caused a crash while traversing
> the quarantine list.
> 
> My previous experience with userspace ASan shows that crashes in the
> tool code itself puzzle the developers.
> As a result, the users think that the tool is broken and don't believe
> its reports.
> 
> I first thought about hardening the quarantine list by checksumming
> the pointers and validating them on each traversal.
> This prevents the crashes, but doesn't give the users any idea about
> what went wrong.
> On the other hand, reporting the pointer corruption right when it happens does.
> Distinguishing between a regular UAF and a quarantine corruption
> (which is what the patch in question is about) helps to prioritize the
> KASAN reports and give the developers better understanding of the
> consequences.
> 

After the first report we have memory in a corrupted state, so we are done here.
Anything that happens after the first report can't be trusted since it can be an after-effect,
just like in your case. Such crashes are not worthy to look at.
Out-of-bounds that doesn't hit metadata as any other memory corruption also can lead to after-effects crashes,
thus distinguishing such bugs doesn't make a lot of sense.

test_kasan module is just a quick hack, made only to make sure that KASAN works.
It does some crappy thing, and may lead to crash as well. So I would recommend an immediate
reboot even after single attempt to load it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
