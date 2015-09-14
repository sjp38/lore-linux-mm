Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAAE6B0253
	for <linux-mm@kvack.org>; Sun, 13 Sep 2015 21:22:28 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so126989638pad.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 18:22:28 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id iz6si1908311pbd.105.2015.09.13.18.22.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 13 Sep 2015 18:22:27 -0700 (PDT)
Message-ID: <55F62037.30506@huawei.com>
Date: Mon, 14 Sep 2015 09:17:43 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kasan: use IS_ALIGNED in memory_is_poisoned_8()
References: <55F23635.1010109@huawei.com> <20150911154730.3a2151a0b111fed01acdaaa1@linux-foundation.org>
In-Reply-To: <20150911154730.3a2151a0b111fed01acdaaa1@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "long.wanglong" <long.wanglong@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>

On 2015/9/12 6:47, Andrew Morton wrote:

> On Fri, 11 Sep 2015 10:02:29 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> Use IS_ALIGNED() to determine whether the shadow span two bytes.
>> It generates less code and more readable.
>>
> 
> Please cc Andrey Ryabinin on kasan patches.

Sorry, my mistake.

> 
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -120,7 +120,7 @@ static __always_inline bool memory_is_poisoned_8(unsigned long addr)
>>  		if (memory_is_poisoned_1(addr + 7))
>>  			return true;
>>  
>> -		if (likely(((addr + 7) & KASAN_SHADOW_MASK) >= 7))
>> +		if (likely(IS_ALIGNED(addr, 8)))
>>  			return false;
> 
> Wouldn't IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE) be more appropriate?
> 

OK, I'll send V2.

> But I'm not really sure what the original code is trying to do.
> 
> 	if ((addr + 7) & 7) >= 7)
> 
> can only evaluate true if ((addr + 7) & 7) equals 7, so the ">=" could
> be "==".
> 

I think it should be "==", the value will not "> 7"

> I think.  The code looks a bit weird.  A code comment would help.
> 
> And how come memory_is_poisoned_16() does IS_ALIGNED(addr, 8)?  Should
> it be 16?

No, it is to determine whether the shadow span two bytes(8 bytes, not 16).

Thanks,
Xishi Qiu

> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
