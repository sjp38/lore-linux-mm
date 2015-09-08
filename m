Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id E9F476B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 05:56:56 -0400 (EDT)
Received: by iofh134 with SMTP id h134so111824263iof.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 02:56:56 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 17si4620982pdg.139.2015.09.08.02.56.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 02:56:56 -0700 (PDT)
Message-ID: <55EEAFD7.8010409@huawei.com>
Date: Tue, 8 Sep 2015 17:52:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kasan: fix last shadow judgement in memory_is_poisoned_16()
References: <55EE3D03.8000502@huawei.com> <CAPAsAGwo73yh9p0GVN9Rt+U-UonJ-V7y4ZU+LfE17MDSrQpjDA@mail.gmail.com> <55EEAF37.5050402@huawei.com>
In-Reply-To: <55EEAF37.5050402@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhongjiang@huawei.com

On 2015/9/8 17:49, Xishi Qiu wrote:

> On 2015/9/8 17:36, Andrey Ryabinin wrote:
> 
>> 2015-09-08 4:42 GMT+03:00 Xishi Qiu <qiuxishi@huawei.com>:
>>> The shadow which correspond 16 bytes may span 2 or 3 bytes. If shadow
>>> only take 2 bytes, we can return in "if (likely(!last_byte)) ...", but
>>> it calculates wrong, so fix it.
>>>
>>
>> Please, be more specific. Describe what is wrong with the current code and why,
>> what's the effect of this bug and how you fixed it.
>>
>>
> 
> If the 16 bytes memory is aligned on 8, then the shadow takes only 2 bytes.
> So we check "shadow_first_bytes" is enough, and need not to call "memory_is_poisoned_1(addr + 15);".
> The code "if (likely(IS_ALIGNED(addr, 8)))" is wrong judgement.

Sorry, a mistake, The code "if (likely(!last_byte))" is wrong judgement.

> e.g. addr=0, so last_byte = 15 & KASAN_SHADOW_MASK = 7, then the code will
> continue to call "return memory_is_poisoned_1(addr + 15);"
> 
> Thanks,
> Xishi Qiu
> 
>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>>> ---
>>>  mm/kasan/kasan.c |    3 +--
>>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>>> index 7b28e9c..8da2114 100644
>>> --- a/mm/kasan/kasan.c
>>> +++ b/mm/kasan/kasan.c
>>> @@ -135,12 +135,11 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>>>
>>>         if (unlikely(*shadow_addr)) {
>>>                 u16 shadow_first_bytes = *(u16 *)shadow_addr;
>>> -               s8 last_byte = (addr + 15) & KASAN_SHADOW_MASK;
>>>
>>>                 if (unlikely(shadow_first_bytes))
>>>                         return true;
>>>
>>> -               if (likely(!last_byte))
>>> +               if (likely(IS_ALIGNED(addr, 8)))
>>>                         return false;
>>>
>>>                 return memory_is_poisoned_1(addr + 15);
>>> --
>>> 1.7.1
>>>
>>>
>>
>> .
>>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
