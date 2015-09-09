Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9013F6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 06:49:03 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so7001544pad.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 03:49:03 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yv10si3033171pab.172.2015.09.09.03.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 03:49:02 -0700 (PDT)
Subject: Re: [PATCH 2/2] kasan: Fix a type conversion error
References: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com>
 <1441771180-206648-3-git-send-email-long.wanglong@huawei.com>
 <CAPAsAGyDO+bXf4zS1wxv0fCGqyC4b9MLJCFWAhpW8E8iSwz-NA@mail.gmail.com>
 <55F00861.7070306@huawei.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <55F00E91.20409@virtuozzo.com>
Date: Wed, 9 Sep 2015 13:48:49 +0300
MIME-Version: 1.0
In-Reply-To: <55F00861.7070306@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "long.wanglong" <long.wanglong@huawei.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, wanglong@laoqinren.net, peifeiyue@huawei.com, morgan.wang@huawei.com

On 09/09/2015 01:22 PM, long.wanglong wrote:
> On 2015/9/9 17:40, Andrey Ryabinin wrote:
>> 2015-09-09 6:59 GMT+03:00 Wang Long <long.wanglong@huawei.com>:
>>> The current KASAN code can find the following out-of-bounds
>>> bugs:
>>>         char *ptr;
>>>         ptr = kmalloc(8, GFP_KERNEL);
>>>         memset(ptr+7, 0, 2);
>>>
>>> the cause of the problem is the type conversion error in
>>> *memory_is_poisoned_n* function. So this patch fix that.
>>>
>>> Signed-off-by: Wang Long <long.wanglong@huawei.com>
>>> ---
>>>  mm/kasan/kasan.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>>> index 7b28e9c..5d65d06 100644
>>> --- a/mm/kasan/kasan.c
>>> +++ b/mm/kasan/kasan.c
>>> @@ -204,7 +204,7 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
>>>                 s8 *last_shadow = (s8 *)kasan_mem_to_shadow((void *)last_byte);
>>>
>>>                 if (unlikely(ret != (unsigned long)last_shadow ||
>>> -                       ((last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
>>> +                       ((long)(last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
>>
>> Is there any problem if we just define last_byte as 'long' instead of
>> 'unsigned long' ?
> 
> yes, I think it is not OK, because on my test, if we define last_byte as 'long'
> instead of 'unsigned long', the bug we talk about can not be found.
> 

Ah, right, even if we declare last_byte as signed, 'last_byte & KASAN_SHADOW_MASK' still will
be unsigned, so this won't work.

So, please, fix up changelog according to Vladimir,
and you may consider this patch

	Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
