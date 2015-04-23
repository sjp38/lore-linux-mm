Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 236186B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 23:10:43 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so3513815lab.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 20:10:42 -0700 (PDT)
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com. [209.85.215.46])
        by mx.google.com with ESMTPS id lb6si5054738lab.70.2015.04.22.20.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 20:10:41 -0700 (PDT)
Received: by laat2 with SMTP id t2so3540964laa.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 20:10:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150422140039.19812721dff3fec674dc5134@linux-foundation.org>
References: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
	<20150422140039.19812721dff3fec674dc5134@linux-foundation.org>
Date: Thu, 23 Apr 2015 11:10:40 +0800
Message-ID: <CA+eFSM38C+P5_2GRXxNR=LtGBHFo-gDyPMvembw75XV+0OkGCQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/slab_common: Support the slub_debug boot option on
 specific object size
From: Gavin Guo <gavin.guo@canonical.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Apr 23, 2015 at 5:00 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 22 Apr 2015 16:33:38 +0800 Gavin Guo <gavin.guo@canonical.com> wrote:
>
>> The slub_debug=PU,kmalloc-xx cannot work because in the
>> create_kmalloc_caches() the s->name is created after the
>> create_kmalloc_cache() is called. The name is NULL in the
>> create_kmalloc_cache() so the kmem_cache_flags() would not set the
>> slub_debug flags to the s->flags. The fix here set up a kmalloc_names
>> string array for the initialization purpose and delete the dynamic
>> name creation of kmalloc_caches.
>>
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -793,6 +793,26 @@ void __init create_kmalloc_caches(unsigned long flags)
>>       int i;
>>
>>       /*
>> +      * The kmalloc_names is for temporary usage to make
>> +      * slub_debug=,kmalloc-xx option work in the boot time. The
>> +      * kmalloc_index() support to 2^26=64MB. So, the final entry of the
>> +      * table is kmalloc-67108864.
>> +      */
>> +     static const char *kmalloc_names[] = {
>> +             "0",                    "kmalloc-96",           "kmalloc-192",
>> +             "kmalloc-8",            "kmalloc-16",           "kmalloc-32",
>> +             "kmalloc-64",           "kmalloc-128",          "kmalloc-256",
>> +             "kmalloc-512",          "kmalloc-1024",         "kmalloc-2048",
>> +             "kmalloc-4196",         "kmalloc-8192",         "kmalloc-16384",
>> +             "kmalloc-32768",        "kmalloc-65536",
>> +             "kmalloc-131072",       "kmalloc-262144",
>> +             "kmalloc-524288",       "kmalloc-1048576",
>> +             "kmalloc-2097152",      "kmalloc-4194304",
>> +             "kmalloc-8388608",      "kmalloc-16777216",
>> +             "kmalloc-33554432",     "kmalloc-67108864"
>> +     };
>> +
>> +     /*
>>        * Patch up the size_index table if we have strange large alignment
>>        * requirements for the kmalloc array. This is only the case for
>>        * MIPS it seems. The standard arches will not generate any code here.
>> @@ -835,7 +855,8 @@ void __init create_kmalloc_caches(unsigned long flags)
>>       }
>>       for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
>>               if (!kmalloc_caches[i]) {
>> -                     kmalloc_caches[i] = create_kmalloc_cache(NULL,
>> +                     kmalloc_caches[i] = create_kmalloc_cache(
>> +                                                     kmalloc_names[i],
>>                                                       1 << i, flags);
>>               }
>
> You could do something like
>
>                 kmalloc_caches[i] = create_kmalloc_cache(
>                                         kmalloc_names[i],
>                                         kstrtoul(kmalloc_names[i] + 8),
>                                         flags);
>
> here, and remove those weird "96" and "192" cases.

Thanks for your reply. I'm not sure if I am following your idea. Would you
mean to simply replace the string like:

                kmalloc_caches[1] = create_kmalloc_cache(
                                        kmalloc_names[1], 96, flags);
as follows:

                kmalloc_caches[1] = create_kmalloc_cache(
                                        kmalloc_names[1],
                                        kstrtoul(kmalloc_names[i] + 8),
                                        flags);

or if you like to merge the last 2 if conditions for 96 and 192 cases to
the first if condition check:

                if (!kmalloc_caches[i]) {
                        kmalloc_caches[i] = create_kmalloc_cache(NULL,
                                                        1 << i, flags);
                }


>
> Or if that's considered too messy, make it
>
>         static const struct {
>                 const char *name;
>                 unsigned size;
>         } kmalloc_cache_info[] = {
>                 { NULL, 0 },
>                 { "kmalloc-96", 96 },
>                 ...
>         };
>
> but I'm thinking the kstrtoul() trick will be OK.
>
>> -     for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
>> -             struct kmem_cache *s = kmalloc_caches[i];
>> -             char *n;
>> -
>> -             if (s) {
>> -                     n = kasprintf(GFP_NOWAIT, "kmalloc-%d", kmalloc_size(i));
>> -
>> -                     BUG_ON(!n);
>> -                     s->name = n;
>> -             }
>> -     }
>> -
>
> slab_kmem_cache_release() still does kfree_const(s->name).  It will
> crash?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
