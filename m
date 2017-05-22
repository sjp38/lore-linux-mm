Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2BA831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:58:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c10so129453254pfg.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:58:50 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0125.outbound.protection.outlook.com. [104.47.0.125])
        by mx.google.com with ESMTPS id w7si17618633pls.159.2017.05.22.06.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 May 2017 06:58:49 -0700 (PDT)
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <ebcc02d9-fa2b-30b1-2260-99cdf7434487@virtuozzo.com>
 <20170519015348.GA1763@js1304-desktop>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0c14ea7f-1ae9-5923-8c4c-4f1b2f7dad62@virtuozzo.com>
Date: Mon, 22 May 2017 17:00:29 +0300
MIME-Version: 1.0
In-Reply-To: <20170519015348.GA1763@js1304-desktop>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com



On 05/19/2017 04:53 AM, Joonsoo Kim wrote:
> On Wed, May 17, 2017 at 03:17:13PM +0300, Andrey Ryabinin wrote:
>> On 05/16/2017 04:16 AM, js1304@gmail.com wrote:
>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>
>>> Hello, all.
>>>
>>> This is an attempt to recude memory consumption of KASAN. Please see
>>> following description to get the more information.
>>>
>>> 1. What is per-page shadow memory
>>>
>>> This patch introduces infrastructure to support per-page shadow memory.
>>> Per-page shadow memory is the same with original shadow memory except
>>> the granualarity. It's one byte shows the shadow value for the page.
>>> The purpose of introducing this new shadow memory is to save memory
>>> consumption.
>>>
>>> 2. Problem of current approach
>>>
>>> Until now, KASAN needs shadow memory for all the range of the memory
>>> so the amount of statically allocated memory is so large. It causes
>>> the problem that KASAN cannot run on the system with hard memory
>>> constraint. Even if KASAN can run, large memory consumption due to
>>> KASAN changes behaviour of the workload so we cannot validate
>>> the moment that we want to check.
>>>
>>> 3. How does this patch fix the problem
>>>
>>> This patch tries to fix the problem by reducing memory consumption for
>>> the shadow memory. There are two observations.
>>>
>>
>>
>> I think that the best way to deal with your problem is to increase shadow scale size.
>>
>> You'll need to add tunable to gcc to control shadow size. I expect that gcc has some
>> places where 8-shadow scale size is hardcoded, but it should be fixable.
>>
>> The kernel also have some small amount of code written with KASAN_SHADOW_SCALE_SIZE == 8 in mind,
>> which should be easy to fix.
>>
>> Note that bigger shadow scale size requires bigger alignment of allocated memory and variables.
>> However, according to comments in gcc/asan.c gcc already aligns stack and global variables and at
>> 32-bytes boundary.
>> So we could bump shadow scale up to 32 without increasing current stack consumption.
>>
>> On a small machine (1Gb) 1/32 of shadow is just 32Mb which is comparable to yours 30Mb, but I expect it to be
>> much faster. More importantly, this will require only small amount of simple changes in code, which will be
>> a *lot* more easier to maintain.
> 
> I agree that it is also a good option to reduce memory consumption.
> Nevertheless, there are two reasons that justifies this patchset.
> 
> 1) With this patchset, memory consumption isn't increased in
> proportional to total memory size. Please consider my 4Gb system
> example on the below. With increasing shadow scale size to 32, memory
> would be consumed by 128M. However, this patchset consumed 50MB. This
> difference can be larger if we run KASAN with bigger machine.
> 

Well, yes, but I assume that bigger machine implies that we can use more memory without
causing a significant change in system's behavior.

> 2) These two optimization can be applied simulatenously. It is just an
> orthogonal feature. If shadow scale size is increased to 32, memory
> consumption will be decreased in case of my patchset, too.
> 
> Therefore, I think that this patchset is useful in any case.
 
These are valid points, but IMO it's not enough to justify this patchset.
Too much of hacky and fragile code.

If our goal is to make KASAN to eat less memory, the first step definitely would be a 1/32 shadow.
Simply because it's the best way to achieve that goal.
And only if it's not enough we could think about something else, like decreasing/turning off quarantine
and/or smaller redzones.


> Note that increasing shadow scale has it's own trade-off. It requires
> that the size of slab object is aligned to shadow scale. It will
> increase memory consumption due to slab.
> 

Yes, but I don't think that it will be significant, many objects are aligned already.
I've tried the kernel with 32 ARCH_SLAB_MINALIGN and ARCH_KMALLOC_MINALIGN and 
the difference in Slab consumption after booting 1G VM was not significant:

8-byte align:
Slab:             126516 kB
SReclaimable:      31140 kB
SUnreclaim:        95376 kB

32-byte align:
Slab:             126712 kB
SReclaimable:      30912 kB
SUnreclaim:        95800 kB


Numbers slightly vary from boot to boot.


> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
