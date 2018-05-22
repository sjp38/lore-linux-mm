Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 352BF6B000C
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:36:58 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b62-v6so13853119qkj.6
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:36:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p10-v6si949664qvn.220.2018.05.22.09.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 09:36:57 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] kasan: fix memory hotplug during boot
References: <20180522100756.18478-1-david@redhat.com>
 <20180522100756.18478-3-david@redhat.com>
 <f4378c56-acc2-a5cf-724c-76cffee28235@virtuozzo.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <ff21c6e7-cb32-60d8-abd3-dfc6be3d05f7@redhat.com>
Date: Tue, 22 May 2018 18:36:49 +0200
MIME-Version: 1.0
In-Reply-To: <f4378c56-acc2-a5cf-724c-76cffee28235@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>

On 22.05.2018 18:26, Andrey Ryabinin wrote:
> 
> 
> On 05/22/2018 01:07 PM, David Hildenbrand wrote:
>> Using module_init() is wrong. E.g. ACPI adds and onlines memory before
>> our memory notifier gets registered.
>>
>> This makes sure that ACPI memory detected during boot up will not
>> result in a kernel crash.
>>
>> Easily reproducable with QEMU, just specify a DIMM when starting up.
> 
>          reproducible
>>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
> 
> Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: <stable@vger.kernel.org>

Think this even dates back to:

786a8959912e ("kasan: disable memory hotplug")


> 
>>  mm/kasan/kasan.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index 53564229674b..a8b85706e2d6 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -892,5 +892,5 @@ static int __init kasan_memhotplug_init(void)
>>  	return 0;
>>  }
>>  
>> -module_init(kasan_memhotplug_init);
>> +core_initcall(kasan_memhotplug_init);
>>  #endif
>>


-- 

Thanks,

David / dhildenb
