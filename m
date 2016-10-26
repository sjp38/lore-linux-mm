Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 840AF6B027E
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:22:14 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id 205so17319579ybz.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 12:22:14 -0700 (PDT)
Received: from mail-yb0-x231.google.com (mail-yb0-x231.google.com. [2607:f8b0:4002:c09::231])
        by mx.google.com with ESMTPS id p206si1244887ywb.477.2016.10.26.12.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 12:22:13 -0700 (PDT)
Received: by mail-yb0-x231.google.com with SMTP id f97so6352509ybi.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 12:22:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1610261400270.31096@east.gentwo.org>
References: <1477503688-69191-1-git-send-email-thgarnie@google.com> <alpine.DEB.2.20.1610261400270.31096@east.gentwo.org>
From: Thomas Garnier <thgarnie@google.com>
Date: Wed, 26 Oct 2016 12:22:12 -0700
Message-ID: <CAJcbSZHZdiMpd4Nhr+UjBk5=5EmUb7xT-8VvCch2NHkm95415g@mail.gmail.com>
Subject: Re: [PATCH v1] memcg: Prevent caches to be both OFF_SLAB & OBJFREELIST_SLAB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>

On Wed, Oct 26, 2016 at 12:08 PM, Christoph Lameter <cl@linux.com> wrote:
> Hmmm...Doesnt this belong into memcg_create_kmem_cache() or into
> kmem_cache_create() in mm/slab_common.h? Definitely not in an allocator
> specific function since this is an issue for all allocators.
>
> memcg_create_kmem_cache() simply assumes that it can pass flags from the
> kmem_cache structure to kmem_cache_create(). However, those flags may
> contain slab specific options.
>
> kmem_cache_create() could filter out flags that cannot be specified.

That make sense.

>
> Maybe create SLAB_FLAGS_PERMITTED in linux/mm/slab.h and mask other bits
> out in kmem_cache_create()?
>
> Slub also has internal flags and those also should not be passed to
> kmem_cache_create(). If we define the valid ones we can mask them out.
>
> The cleanest approach would be if kmem_cache_create() would reject invalid
> flags and fail and if memcg_create_kmem_cache() would mask out the invalid
> flags using SLAB_FLAGS_PERMITTED or so.

Okay, I think for SLAB we can allow everything except the two flags
mentioned here.

Should I deny certain flags for SLUB? I can allow everything for now.

>
>
>
> On Wed, 26 Oct 2016, Thomas Garnier wrote:
>
>> While testing OBJFREELIST_SLAB integration with pagealloc, we found a
>> bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
>> CFLGS_OBJFREELIST_SLAB.
>>
>> The original kmem_cache is created early making OFF_SLAB not possible.
>> When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
>> is enabled it will try to enable it first under certain conditions.
>> Given kmem_cache(sys) reuses the original flag, you can have both flags
>> at the same time resulting in allocation failures and odd behaviors.
>>
>> The proposed fix removes these flags by default at the entrance of
>> __kmem_cache_create. This way the function will define which way the
>> freelist should be handled at this stage for the new cache.
>>
>> Fixes: b03a017bebc4 ("mm/slab: introduce new slab management type, OBJFREELIST_SLAB")
>> Signed-off-by: Thomas Garnier <thgarnie@google.com>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> ---
>> Based on next-20161025
>> ---
>>  mm/slab.c | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 3c83c29..efe280a 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -2027,6 +2027,14 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>>       int err;
>>       size_t size = cachep->size;
>>
>> +     /*
>> +      * memcg re-creates caches with the flags of the originals. Remove
>> +      * the freelist related flags to ensure they are re-defined at this
>> +      * stage. Prevent having both flags on edge cases like with pagealloc
>> +      * if the original cache was created too early to be OFF_SLAB.
>> +      */
>> +     flags &= ~(CFLGS_OBJFREELIST_SLAB|CFLGS_OFF_SLAB);
>> +
>>  #if DEBUG
>>  #if FORCED_DEBUG
>>       /*
>>



-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
