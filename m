Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id CACC06B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 04:30:47 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so145189444wic.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 01:30:47 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id fz6si3229655wic.116.2015.09.09.01.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 01:30:46 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so106596739wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 01:30:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55EFD46A.20309@huawei.com>
References: <55EED09E.3010107@huawei.com>
	<55EFD46A.20309@huawei.com>
Date: Wed, 9 Sep 2015 11:30:45 +0300
Message-ID: <CAPAsAGzErusErnpSThhCbZ2GeirSpH+tqw+mCqbveWVJnPRcmw@mail.gmail.com>
Subject: Re: [PATCH V2] kasan: fix last shadow judgement in memory_is_poisoned_16()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "long.wanglong" <long.wanglong@huawei.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-09-09 9:40 GMT+03:00 long.wanglong <long.wanglong@huawei.com>:
> On 2015/9/8 20:12, Xishi Qiu wrote:
>> The shadow which correspond 16 bytes memory may span 2 or 3 bytes. If the
>> memory is aligned on 8, then the shadow takes only 2 bytes. So we check
>> "shadow_first_bytes" is enough, and need not to call "memory_is_poisoned_1(addr + 15);".
>> But the code "if (likely(!last_byte))" is wrong judgement.
>>
>> e.g. addr=0, so last_byte = 15 & KASAN_SHADOW_MASK = 7, then the code will
>> continue to call "memory_is_poisoned_1(addr + 15);"
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  mm/kasan/kasan.c |    3 +--
>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index 7b28e9c..8da2114 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -135,12 +135,11 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>>
>>       if (unlikely(*shadow_addr)) {
>>               u16 shadow_first_bytes = *(u16 *)shadow_addr;
>> -             s8 last_byte = (addr + 15) & KASAN_SHADOW_MASK;
>>
>>               if (unlikely(shadow_first_bytes))
>>                       return true;
>>
>> -             if (likely(!last_byte))
>> +             if (likely(IS_ALIGNED(addr, 8)))
>>                       return false;
>>
>>               return memory_is_poisoned_1(addr + 15);
>>
>
> Hi,
> I also notice this problem, how about another method to fix it:
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 5d65d06..6a20dda 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -140,7 +140,7 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>                 if (unlikely(shadow_first_bytes))
>                         return true;
>
> -               if (likely(!last_byte))
> +               if (likely(last_byte >= 7))

I suggested to use IS_ALIGNED instead of this because it generates
less code and it also more readable.

./scripts/bloat-o-meter kasan_aligned.o kasan_last_byte.o
add/remove: 0/0 grow/shrink: 4/0 up/down: 20/0 (20)
function                                     old     new   delta
__asan_store16_noabort                       106     111      +5
__asan_store16                               106     111      +5
__asan_load16_noabort                        103     108      +5
__asan_load16                                103     108      +5


>         }
>
>         return false;
> }
>
> Otherwise, we also should use IS_ALIGNED macro in memory_is_poisoned_8!
>

I believe this would be a beneficial micro optimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
