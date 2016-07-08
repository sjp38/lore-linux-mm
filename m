Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 222D06B0005
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 11:30:02 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id t8so52311165obs.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 08:30:02 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0129.outbound.protection.outlook.com. [104.47.2.129])
        by mx.google.com with ESMTPS id k190si119390oib.203.2016.07.08.08.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 08:30:00 -0700 (PDT)
Subject: Re: [PATCH v5] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
References: <1466617421-58518-1-git-send-email-glider@google.com>
 <5772AAFB.1070907@virtuozzo.com>
 <CAG_fn=Xe1hd_1kZN6NxnhvfZNs4zYCYm9674UkcPVxDeTreO9A@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <577FC734.9000603@virtuozzo.com>
Date: Fri, 8 Jul 2016 18:31:00 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=Xe1hd_1kZN6NxnhvfZNs4zYCYm9674UkcPVxDeTreO9A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 07/08/2016 01:36 PM, Alexander Potapenko wrote:
> On Tue, Jun 28, 2016 at 6:51 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:

>>>       *flags |= SLAB_KASAN;
>>> +
>>>       /* Add alloc meta. */
>>>       cache->kasan_info.alloc_meta_offset = *size;
>>>       *size += sizeof(struct kasan_alloc_meta);
>>> @@ -392,17 +387,35 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>>>           cache->object_size < sizeof(struct kasan_free_meta)) {
>>>               cache->kasan_info.free_meta_offset = *size;
>>>               *size += sizeof(struct kasan_free_meta);
>>> +     } else {
>>> +             cache->kasan_info.free_meta_offset = 0;
>>
>> Why is that required now?
> Because we want to store the free metadata in the object when it's possible.

We did the before this patch. free_meta_offset is 0 by default, thus there was no need to nullify it here.
But now this patch suddenly adds reset of free_meta_offset. So I'm asking why?
Is free_meta_offset not 0 by default anymore? 



>>>
>>>  void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>>> @@ -568,6 +573,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>>>       if (unlikely(object == NULL))
>>>               return;
>>>
>>> +     if (!(cache->flags & SLAB_KASAN))
>>> +             return;
>>> +
>>
>> This hunk is superfluous and wrong.
> Can you please elaborate?
> Do you mean we don't need to check for SLAB_KASAN here, or that we
> don't need SLAB_KASAN at all?

The former, we can poison/unpoison !SLAB_KASAN caches too.



>>>  }
>>>
>>> @@ -2772,12 +2788,22 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
>>>                                     void *head, void *tail, int cnt,
>>>                                     unsigned long addr)
>>>  {
>>> +     void *free_head = head, *free_tail = tail;
>>> +
>>> +     slab_free_freelist_hook(s, &free_head, &free_tail, &cnt);
>>> +     /* slab_free_freelist_hook() could have emptied the freelist. */
>>> +     if (cnt == 0)
>>> +             return;
>>
>> I suppose that we can do something like following, instead of that mess in slab_free_freelist_hook() above
>>
>>         slab_free_freelist_hook(s, &free_head, &free_tail);
>>         if (s->flags & SLAB_KASAN && s->flags & SLAB_DESTROY_BY_RCU)
> Did you mean "&& !(s->flags & SLAB_DESTROY_BY_RCU)" ?

Sure.

>>                 return;
> Yes, my code is overly complicated given that kasan_slab_free() should
> actually return the same value for every element of the list.
> (do you think it makes sense to check that?)

IMO that's would be superfluous.

> I can safely remove those freelist manipulations.
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
