Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8DE828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 11:16:56 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id is5so87028444obc.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:16:56 -0800 (PST)
Received: from mail-ob0-x241.google.com (mail-ob0-x241.google.com. [2607:f8b0:4003:c01::241])
        by mx.google.com with ESMTPS id sc8si8243930obb.67.2016.01.14.08.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 08:16:55 -0800 (PST)
Received: by mail-ob0-x241.google.com with SMTP id x5so2300982obg.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:16:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160114130919.48254935@redhat.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1452749069-15334-5-git-send-email-iamjoonsoo.kim@lge.com>
	<20160114130919.48254935@redhat.com>
Date: Fri, 15 Jan 2016 01:16:55 +0900
Message-ID: <CAAmzW4MySUtoSEJ9Gs+hsA0bSzeN2bdg9sjnxQprxsQHLA0wQQ@mail.gmail.com>
Subject: Re: [PATCH 04/16] mm/slab: activate debug_pagealloc in SLAB when it
 is actually enabled
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-01-14 21:09 GMT+09:00 Jesper Dangaard Brouer <brouer@redhat.com>:
> On Thu, 14 Jan 2016 14:24:17 +0900
> Joonsoo Kim <js1304@gmail.com> wrote:
>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>  mm/slab.c | 15 ++++++++++-----
>>  1 file changed, 10 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index bbe4df2..4b55516 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -1838,7 +1838,8 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
>>
>>               if (cachep->flags & SLAB_POISON) {
>>  #ifdef CONFIG_DEBUG_PAGEALLOC
>> -                     if (cachep->size % PAGE_SIZE == 0 &&
>> +                     if (debug_pagealloc_enabled() &&
>> +                             cachep->size % PAGE_SIZE == 0 &&
>>                                       OFF_SLAB(cachep))
>>                               kernel_map_pages(virt_to_page(objp),
>>                                       cachep->size / PAGE_SIZE, 1);
>> @@ -2176,7 +2177,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>>        * to check size >= 256. It guarantees that all necessary small
>>        * sized slab is initialized in current slab initialization sequence.
>>        */
>> -     if (!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
>> +     if (debug_pagealloc_enabled() &&
>> +             !slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
>>               size >= 256 && cachep->object_size > cache_line_size() &&
>>               ALIGN(size, cachep->align) < PAGE_SIZE) {
>>               cachep->obj_offset += PAGE_SIZE - ALIGN(size, cachep->align);
>> @@ -2232,7 +2234,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>>                * poisoning, then it's going to smash the contents of
>>                * the redzone and userword anyhow, so switch them off.
>>                */
>> -             if (size % PAGE_SIZE == 0 && flags & SLAB_POISON)
>> +             if (debug_pagealloc_enabled() &&
>> +                     size % PAGE_SIZE == 0 && flags & SLAB_POISON)
>>                       flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
>
> Sorry, but I dislike the indention style here (when the if covers
> several lines). Same goes for other changes in this patch.  Looking,
> there are several example of this indention style in the existing
> mm/slab.c. Thus, I don't know if this is accepted in the MM area (it is
> definitely not accepted in the NET-area).

I guess it is acceptable in the MM. :)
Moreover, it is cleaned-up in the following patch.
But, I hope to know how it is handled in the NET-area.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
