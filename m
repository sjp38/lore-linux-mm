Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7830A6B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:34:18 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id m64so58010639ybb.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:34:18 -0700 (PDT)
Received: from mail-yb0-x230.google.com (mail-yb0-x230.google.com. [2607:f8b0:4002:c09::230])
        by mx.google.com with ESMTPS id p206si2809951ywb.477.2016.10.27.07.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 07:34:17 -0700 (PDT)
Received: by mail-yb0-x230.google.com with SMTP id d128so18876157ybh.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:34:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161027072518.GC6454@dhcp22.suse.cz>
References: <1477503688-69191-1-git-send-email-thgarnie@google.com> <20161027072518.GC6454@dhcp22.suse.cz>
From: Thomas Garnier <thgarnie@google.com>
Date: Thu, 27 Oct 2016 07:34:16 -0700
Message-ID: <CAJcbSZGFBWvELojNYtufucrQ3JMWPc3QK5tigi-x3nNs5ibp1Q@mail.gmail.com>
Subject: Re: [PATCH v1] memcg: Prevent caches to be both OFF_SLAB & OBJFREELIST_SLAB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu, Oct 27, 2016 at 12:25 AM, Michal Hocko <mhocko@kernel.org> wrote:
> The patch is marked for memcg but I do not see any direct relation.
> I am not familiar with this code enough probably but if this really is
> memcg kmem related, please do not forget to CC Vladimir
>

Yes, the next iteration should be closer to memcg. I will CC Vladimir.

Thanks for the heads-up.

> On Wed 26-10-16 10:41:28, Thomas Garnier wrote:
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
>> --
>> 2.8.0.rc3.226.g39d4020
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs



-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
