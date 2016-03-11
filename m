Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6CBD66B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:43:41 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id k15so153332554lbg.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:43:41 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id ua8si4084728lbb.138.2016.03.11.03.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 03:43:40 -0800 (PST)
Received: by mail-lb0-x231.google.com with SMTP id bc4so151807079lbc.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:43:39 -0800 (PST)
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
References: <cover.1456504662.git.glider@google.com>
 <00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
 <56D471F5.3010202@gmail.com>
 <CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
 <56D58398.2010708@gmail.com>
 <CAG_fn=Xby+PJtMQtZ68gPkSPCyxbF=RsOCVavYew7ZVDx25yow@mail.gmail.com>
 <CAPAsAGzmFWCMEHhw=+15B1RO_7r3vUOMG0cZEPzQ=YcM5YP5MQ@mail.gmail.com>
 <CAG_fn=UhykNnE7L1dHA3LFbLb9tp-x0nZ4Z7joUk_-vvHDtX5g@mail.gmail.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56E2AF71.2050800@gmail.com>
Date: Fri, 11 Mar 2016 14:43:45 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UhykNnE7L1dHA3LFbLb9tp-x0nZ4Z7joUk_-vvHDtX5g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 03/11/2016 02:18 PM, Alexander Potapenko wrote:
> On Thu, Mar 10, 2016 at 5:58 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>> 2016-03-08 14:42 GMT+03:00 Alexander Potapenko <glider@google.com>:
>>> On Tue, Mar 1, 2016 at 12:57 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>>>>>>
>>>>>>> +                     page = alloc_pages(alloc_flags, STACK_ALLOC_ORDER);
>>>>>>
>>>>>> STACK_ALLOC_ORDER = 4 - that's a lot. Do you really need that much?
>>>>>
>>>>> Part of the issue the atomic context above. When we can't allocate
>>>>> memory we still want to save the stack trace. When we have less than
>>>>> STACK_ALLOC_ORDER memory, we try to preallocate another
>>>>> STACK_ALLOC_ORDER in advance. So in the worst case, we have
>>>>> STACK_ALLOC_ORDER memory and that should be enough to handle all
>>>>> kmalloc/kfree in the atomic context. 1 page does not look enough. I
>>>>> think Alex did some measuring of the failure race (when we are out of
>>>>> memory and can't allocate more).
>>>>>
>>>>
>>>> A lot of 4-order pages will lead to high fragmentation. You don't need physically contiguous memory here,
>>>> so try to use vmalloc(). It is slower, but fragmentation won't be problem.
>>> I've tried using vmalloc(), but turned out it's calling KASAN hooks
>>> again. Dealing with reentrancy in this case sounds like an overkill.
>>
>> We'll have to deal with recursion eventually. Using stackdepot for
>> page owner will cause recursion.
>>
>>> Given that we only require 9 Mb most of the time, is allocating
>>> physical pages still a problem?
>>>
>>
>> This is not about size, this about fragmentation. vmalloc allows to
>> utilize available low-order pages,
>> hence reduce the fragmentation.
> I've attempted to add __vmalloc(STACK_ALLOC_SIZE, alloc_flags,
> PAGE_KERNEL) (also tried vmalloc(STACK_ALLOC_SIZE)) instead of
> page_alloc() and am now getting a crash in
> kmem_cache_alloc_node_trace() in mm/slab.c, because it doesn't allow
> the kmem_cache pointer to be NULL (it's dereferenced when calling
> trace_kmalloc_node()).
> 
> Steven, do you know if this because of my code violating some contract
> (e.g. I'm calling vmalloc() too early, when kmalloc_caches[] haven't
> been initialized), 

Probably. kmem_cache_init() goes before vmalloc_init().


> or is this a bug in kmem_cache_alloc_node_trace()
> itself?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
