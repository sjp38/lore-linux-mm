Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A1A436B0263
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:10:14 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so182580092ith.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:10:14 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0136.outbound.protection.outlook.com. [104.47.2.136])
        by mx.google.com with ESMTPS id q18si20017976otb.120.2016.08.01.08.10.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 08:10:13 -0700 (PDT)
Subject: Re: [PATCH v8 2/3] mm, kasan: align free_meta_offset on sizeof(void*)
References: <1469719879-11761-1-git-send-email-glider@google.com>
 <1469719879-11761-3-git-send-email-glider@google.com>
 <579F62D3.8030605@virtuozzo.com>
 <CAG_fn=XOa9mrE-9=0j73qMZQZXNJDOT2X7EL+xU+6zL_W1cqsw@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <579F669A.4090806@virtuozzo.com>
Date: Mon, 1 Aug 2016 18:11:22 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=XOa9mrE-9=0j73qMZQZXNJDOT2X7EL+xU+6zL_W1cqsw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>



On 08/01/2016 05:56 PM, Alexander Potapenko wrote:
> On Mon, Aug 1, 2016 at 4:55 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 07/28/2016 06:31 PM, Alexander Potapenko wrote:
>>> When free_meta_offset is not zero, it is usually aligned on 4 bytes,
>>> because the size of preceding kasan_alloc_meta is aligned on 4 bytes.
>>> As a result, accesses to kasan_free_meta fields may be misaligned.
>>>
>>> Signed-off-by: Alexander Potapenko <glider@google.com>
>>> ---
>>>  mm/kasan/kasan.c | 3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>>> index 6845f92..0379551 100644
>>> --- a/mm/kasan/kasan.c
>>> +++ b/mm/kasan/kasan.c
>>> @@ -390,7 +390,8 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>>>       /* Add free meta. */
>>>       if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
>>>           cache->object_size < sizeof(struct kasan_free_meta)) {
>>> -             cache->kasan_info.free_meta_offset = *size;
>>> +             cache->kasan_info.free_meta_offset =
>>> +                     ALIGN(*size, sizeof(void *));
>>
>> This cannot work.
> Well, it does, at least on my tests.

JFYI. You aligned only meta offset, but didn't change the size, so after the '*size += sizeof(struct kasan_free_meta);'
*size may point into the middle of free_meta struct.
Plus, alignment wasn't taken into account in kasan_metadata_size().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
