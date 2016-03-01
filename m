Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7BEC76B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 06:57:14 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id of3so97449862lbc.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 03:57:14 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id wa5si14223607lbb.156.2016.03.01.03.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 03:57:13 -0800 (PST)
Received: by mail-lb0-x231.google.com with SMTP id ed16so19531566lbb.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 03:57:12 -0800 (PST)
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
References: <cover.1456504662.git.glider@google.com>
 <00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
 <56D471F5.3010202@gmail.com>
 <CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56D58398.2010708@gmail.com>
Date: Tue, 1 Mar 2016 14:57:12 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 02/29/2016 08:12 PM, Dmitry Vyukov wrote:

>>> diff --git a/lib/Makefile b/lib/Makefile
>>> index a7c26a4..10a4ae3 100644
>>> --- a/lib/Makefile
>>> +++ b/lib/Makefile
>>> @@ -167,6 +167,13 @@ obj-$(CONFIG_SG_SPLIT) += sg_split.o
>>>  obj-$(CONFIG_STMP_DEVICE) += stmp_device.o
>>>  obj-$(CONFIG_IRQ_POLL) += irq_poll.o
>>>
>>> +ifeq ($(CONFIG_KASAN),y)
>>> +ifeq ($(CONFIG_SLAB),y)
>>
>> Just try to imagine that another subsystem wants to use stackdepot. How this gonna look like?
>>
>> We have Kconfig to describe dependencies. So, this should be under CONFIG_STACKDEPOT.
>> So any user of this feature can just do 'select STACKDEPOT' in Kconfig.
>>
>>> +     obj-y   += stackdepot.o
>>> +     KASAN_SANITIZE_slub.o := n
	                _stackdepot.o


>>
>>> +
>>> +     stack->hash = hash;
>>> +     stack->size = size;
>>> +     stack->handle.slabindex = depot_index;
>>> +     stack->handle.offset = depot_offset >> STACK_ALLOC_ALIGN;
>>> +     __memcpy(stack->entries, entries, size * sizeof(unsigned long));
>>
>> s/__memcpy/memcpy/
> 
> memcpy should be instrumented by asan/tsan, and we would like to avoid
> that instrumentation here.

KASAN_SANITIZE_* := n already takes care about this.
__memcpy() is a special thing solely for kasan internals and some assembly code.
And it's not available generally.


>>> +     if (unlikely(!smp_load_acquire(&next_slab_inited))) {
>>> +             if (!preempt_count() && !in_irq()) {
>>
>> If you trying to detect atomic context here, than this doesn't work. E.g. you can't know
>> about held spinlocks in non-preemptible kernel.
>> And I'm not sure why need this. You know gfp flags here, so allocation in atomic context shouldn't be problem.
> 
> 
> We don't have gfp flags for kfree.
> I wonder how CONFIG_DEBUG_ATOMIC_SLEEP handles this. Maybe it has the answer.

It hasn't. It doesn't guarantee that atomic context always will be detected.

> Alternatively, we can always assume that we are in atomic context in kfree.
> 

Or do this allocation in separate context, put in work queue.

> 
> 
>>> +                     alloc_flags &= (__GFP_RECLAIM | __GFP_IO | __GFP_FS |
>>> +                             __GFP_NOWARN | __GFP_NORETRY |
>>> +                             __GFP_NOMEMALLOC | __GFP_DIRECT_RECLAIM);
>>
>> I think blacklist approach would be better here.
>>
>>> +                     page = alloc_pages(alloc_flags, STACK_ALLOC_ORDER);
>>
>> STACK_ALLOC_ORDER = 4 - that's a lot. Do you really need that much?
> 
> Part of the issue the atomic context above. When we can't allocate
> memory we still want to save the stack trace. When we have less than
> STACK_ALLOC_ORDER memory, we try to preallocate another
> STACK_ALLOC_ORDER in advance. So in the worst case, we have
> STACK_ALLOC_ORDER memory and that should be enough to handle all
> kmalloc/kfree in the atomic context. 1 page does not look enough. I
> think Alex did some measuring of the failure race (when we are out of
> memory and can't allocate more).
> 

A lot of 4-order pages will lead to high fragmentation. You don't need physically contiguous memory here,
so try to use vmalloc(). It is slower, but fragmentation won't be problem.

And one more thing. Take a look at mempool, because it's generally used to solve the problem you have here
(guaranteed allocation in atomic context).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
