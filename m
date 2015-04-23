Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id B79236B006E
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 07:15:43 -0400 (EDT)
Received: by lbbuc2 with SMTP id uc2so10554836lbb.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 04:15:43 -0700 (PDT)
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com. [209.85.217.180])
        by mx.google.com with ESMTPS id ol5si5769972lbb.79.2015.04.23.04.15.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 04:15:42 -0700 (PDT)
Received: by lbbqq2 with SMTP id qq2so10542510lbb.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 04:15:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87egnbmamr.fsf@rasmusvillemoes.dk>
References: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
	<87egnbmamr.fsf@rasmusvillemoes.dk>
Date: Thu, 23 Apr 2015 19:15:41 +0800
Message-ID: <CA+eFSM3gv6XdKoyoVPqjp5XvRUGDVQuPOcm4_TJvAnM_ayhD3g@mail.gmail.com>
Subject: Re: [PATCH v2] mm/slab_common: Support the slub_debug boot option on
 specific object size
From: Gavin Guo <gavin.guo@canonical.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Christoph Lameter <cl@linux.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

Hi Rasmus,

On Thu, Apr 23, 2015 at 5:55 PM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> On Wed, Apr 22 2015, Gavin Guo <gavin.guo@canonical.com> wrote:
>
>>       /*
>> +      * The kmalloc_names is for temporary usage to make
>> +      * slub_debug=,kmalloc-xx option work in the boot time. The
>> +      * kmalloc_index() support to 2^26=64MB. So, the final entry of the
>> +      * table is kmalloc-67108864.
>> +      */
>> +     static const char *kmalloc_names[] = {
>
> The array itself could be const, but more importantly it should be
> marked __initconst so that the 27*sizeof(char*) bytes can be released after init.
>
>> +             "0",                    "kmalloc-96",           "kmalloc-192",
>> +             "kmalloc-8",            "kmalloc-16",           "kmalloc-32",
>> +             "kmalloc-64",           "kmalloc-128",          "kmalloc-256",
>> +             "kmalloc-512",          "kmalloc-1024",         "kmalloc-2048",
>> +             "kmalloc-4196",         "kmalloc-8192",         "kmalloc-16384",
>
> "kmalloc-4096"

Good catch!!

>
>> +             "kmalloc-32768",        "kmalloc-65536",
>> +             "kmalloc-131072",       "kmalloc-262144",
>> +             "kmalloc-524288",       "kmalloc-1048576",
>> +             "kmalloc-2097152",      "kmalloc-4194304",
>> +             "kmalloc-8388608",      "kmalloc-16777216",
>> +             "kmalloc-33554432",     "kmalloc-67108864"
>> +     };
>
> On Wed, Apr 22 2015, Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> You could do something like
>>
>>               kmalloc_caches[i] = create_kmalloc_cache(
>>                                       kmalloc_names[i],
>>                                       kstrtoul(kmalloc_names[i] + 8),
>>                                       flags);
>>
>> here, and remove those weird "96" and "192" cases.
>
> Eww. At least spell 8 as strlen("kmalloc-").
>
>> Or if that's considered too messy, make it
>>
>>       static const struct {
>>               const char *name;
>>               unsigned size;
>>       } kmalloc_cache_info[] = {
>>               { NULL, 0 },
>>               { "kmalloc-96", 96 },
>>               ...
>>       };
>
> I'd vote for this color for the bikeshed :-)
>
> Rasmus

Thanks for the review! I'll come out another version soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
