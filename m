Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D78536B0039
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 03:32:14 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id r10so12153477pdi.25
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 00:32:14 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id cf1si7593856pdb.231.2014.09.26.00.32.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 26 Sep 2014 00:32:13 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NCH00E6RZQCRO80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 26 Sep 2014 08:35:00 +0100 (BST)
Message-id: <542514DD.5080402@samsung.com>
Date: Fri, 26 Sep 2014 11:25:17 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v3 09/13] mm: slub: add kernel address sanitizer support
 for slub allocator
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-10-git-send-email-a.ryabinin@samsung.com>
 <CACT4Y+a0DMk8vyCcesrsKt7rXVDD2LZsfnGemJAgeRiVbMxxxw@mail.gmail.com>
In-reply-to: 
 <CACT4Y+a0DMk8vyCcesrsKt7rXVDD2LZsfnGemJAgeRiVbMxxxw@mail.gmail.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 09/26/2014 08:48 AM, Dmitry Vyukov wrote:
> On Wed, Sep 24, 2014 at 5:44 AM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>> --- a/lib/Kconfig.kasan
>> +++ b/lib/Kconfig.kasan
>> @@ -6,6 +6,7 @@ if HAVE_ARCH_KASAN
>>  config KASAN
>>         bool "AddressSanitizer: runtime memory debugger"
>>         depends on !MEMORY_HOTPLUG
>> +       depends on SLUB_DEBUG
> 
> 
> What does SLUB_DEBUG do? I think that generally we don't want any
> other *heavy* debug checks to be required for kasan.
> 

SLUB_DEBUG enables support for different debugging features.
It doesn't enables this debugging features by default, it only allows
you to switch them on/off in runtime.
Generally SLUB_DEBUG option is enabled in most kernels. SLUB_DEBUG disabled
only with intention to get minimal kernel.

Without SLUB_DEBUG there will be no redzones, no user tracking info (allocation/free stacktraces).
KASAN won't be so usefull without SLUB_DEBUG.


[...]

>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -30,6 +30,7 @@
>>  #include <linux/kasan.h>
>>
>>  #include "kasan.h"
>> +#include "../slab.h"
>>
>>  /*
>>   * Poisons the shadow memory for 'size' bytes starting from 'addr'.
>> @@ -265,6 +266,102 @@ void kasan_free_pages(struct page *page, unsigned int order)
>>                                 KASAN_FREE_PAGE);
>>  }
>>
>> +void kasan_free_slab_pages(struct page *page, int order)
> 
> Doesn't this callback followed by actually freeing the pages, and so
> kasan_free_pages callback that will poison the range? If so, I would
> prefer to not double poison.
> 

Yes, this could be removed.

> 
>> +{
>> +       kasan_poison_shadow(page_address(page),
>> +                       PAGE_SIZE << order, KASAN_SLAB_FREE);
>> +}
>> +
>> +void kasan_mark_slab_padding(struct kmem_cache *s, void *object)
>> +{
>> +       unsigned long object_end = (unsigned long)object + s->size;
>> +       unsigned long padding_end = round_up(object_end, PAGE_SIZE);
>> +       unsigned long padding_start = round_up(object_end,
>> +                                       KASAN_SHADOW_SCALE_SIZE);
>> +       size_t size = padding_end - padding_start;
>> +
>> +       if (size)
>> +               kasan_poison_shadow((void *)padding_start,
>> +                               size, KASAN_SLAB_PADDING);
>> +}
>> +
>> +void kasan_slab_alloc(struct kmem_cache *cache, void *object)
>> +{
>> +       kasan_kmalloc(cache, object, cache->object_size);
>> +}
>> +
>> +void kasan_slab_free(struct kmem_cache *cache, void *object)
>> +{
>> +       unsigned long size = cache->size;
>> +       unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
>> +
> 
> Add a comment saying that SLAB_DESTROY_BY_RCU objects can be "legally"
> used after free.
> 

Ok.

>> +       if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>> +               return;
>> +
>> +       kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
>> +}
>> +
>> +void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
>> +{
>> +       unsigned long redzone_start;
>> +       unsigned long redzone_end;
>> +
>> +       if (unlikely(object == NULL))
>> +               return;
>> +
>> +       redzone_start = round_up((unsigned long)(object + size),
>> +                               KASAN_SHADOW_SCALE_SIZE);
>> +       redzone_end = (unsigned long)object + cache->size;
>> +
>> +       kasan_unpoison_shadow(object, size);
>> +       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>> +               KASAN_KMALLOC_REDZONE);
>> +
>> +}
>> +EXPORT_SYMBOL(kasan_kmalloc);
>> +
>> +void kasan_kmalloc_large(const void *ptr, size_t size)
>> +{
>> +       struct page *page;
>> +       unsigned long redzone_start;
>> +       unsigned long redzone_end;
>> +
>> +       if (unlikely(ptr == NULL))
>> +               return;
>> +
>> +       page = virt_to_page(ptr);
>> +       redzone_start = round_up((unsigned long)(ptr + size),
>> +                               KASAN_SHADOW_SCALE_SIZE);
>> +       redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
> 
> If size == N*PAGE_SIZE - KASAN_SHADOW_SCALE_SIZE - 1, the object does
> not receive any redzone at all. 

If size == N*PAGE_SIZE - KASAN_SHADOW_SCALE_SIZE - 1, there will be redzone
KASAN_SHADOW_SCALE_SIZE + 1 bytes. There will be no readzone if and only if
(size == PAGE_SIZE << compound_order(page))

> Can we pass full memory block size
> from above to fix it? Will compound_order(page) do?
> 

What is full memory block size?
PAGE_SIZE << compound_order(page) is how much was really allocated.


[..]

>>
>>  static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>> @@ -1416,8 +1426,10 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>>                 setup_object(s, page, p);
>>                 if (likely(idx < page->objects))
>>                         set_freepointer(s, p, p + s->size);
> 
> Sorry, I don't fully follow this code, so I will just ask some questions.
> Can we have some slab padding after last object in this case as well?
> 
This case is for not the last object. Padding is the place after the last object.
The last object initialized bellow in else case.

>> -               else
>> +               else {
>>                         set_freepointer(s, p, NULL);
>> +                       kasan_mark_slab_padding(s, p);
> 
> kasan_mark_slab_padding poisons only up to end of the page. Can there
> be multiple pages that we need to poison?
> 
Yep, that's a good catch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
