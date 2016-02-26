Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id B731F6B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 12:06:22 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id dm2so82739832obb.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:06:22 -0800 (PST)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id d2si11906473oem.8.2016.02.26.09.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 09:06:22 -0800 (PST)
Received: by mail-ob0-x22d.google.com with SMTP id dm2so82739616obb.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:06:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1602261017050.24939@east.gentwo.org>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1456466484-3442-17-git-send-email-iamjoonsoo.kim@lge.com>
	<alpine.DEB.2.20.1602261017050.24939@east.gentwo.org>
Date: Sat, 27 Feb 2016 02:06:21 +0900
Message-ID: <CAAmzW4Ps9T5f1EW31svFkTnr2ta+hVEmmiO5JdthN09nL3nSWw@mail.gmail.com>
Subject: Re: [PATCH v2 16/17] mm/slab: introduce new slab management type, OBJFREELIST_SLAB
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-27 1:21 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Fri, 26 Feb 2016, js1304@gmail.com wrote:
>
>> Although this idea can apply to all caches whose size is larger than
>> management array size, it isn't applied to caches which have a
>> constructor.  If such cache's object is used for management array,
>> constructor should be called for it before that object is returned to
>> user.  I guess that overhead overwhelm benefit in that case so this idea
>> doesn't applied to them at least now.
>
> Caches which have a constructor (or are used with SLAB_RCU_FREE) have a
> defined content even when they are free. Therefore they cannot be used
> for the freelist.

Yes, I know. I already handled it. I attach related hunk.

+static bool set_objfreelist_slab_cache(struct kmem_cache *cachep,
+                       size_t size, unsigned long flags)
+{
+       size_t left;
+
+       cachep->num = 0;
+
+       if (cachep->ctor || flags & SLAB_DESTROY_BY_RCU)
+               return false;

So, if there is ctor or RCU slabs, objfreelist will not be used.

>> For summary, from now on, slab management type is determined by
>> following logic.
>>
>> 1) if management array size is smaller than object size and no ctor, it
>>    becomes OBJFREELIST_SLAB.
>
> Also do not do this for RCU slabs.

Explained above.

>> 2) if management array size is smaller than leftover, it becomes
>>    NORMAL_SLAB which uses leftover as a array.
>>
>> 3) if OFF_SLAB help to save memory than way 4), it becomes OFF_SLAB.
>>    It allocate a management array from the other cache so memory waste
>>    happens.
>
> Wonder how many of these ugly off slabs are left after what you did here.

See below result.

>> TOTAL = OBJFREELIST + NORMAL(leftover) + NORMAL + OFF
>>
>> /Before/
>> 126 = 0 + 60 + 25 + 41
>>
>> /After/
>> 126 = 97 + 12 + 15 + 2

97 is the number of 1) type caches.
12 is the number of 2) type caches.
and so on...

>> Result shows that number of caches that doesn't waste memory increase
>> from 60 to 109.
>
> Great results.

Thanks. :)

>> v2: fix SLAB_DESTROTY_BY_RCU cache type handling
>
> Ok how are they handled now? Do not see that dealt with in the patch.

Explained above.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
