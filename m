Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1566B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 06:05:35 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so113850991wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 03:05:35 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id tc5si5847821wic.21.2015.09.08.03.05.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 03:05:34 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so71536371wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 03:05:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55EEAFD7.8010409@huawei.com>
References: <55EE3D03.8000502@huawei.com>
	<CAPAsAGwo73yh9p0GVN9Rt+U-UonJ-V7y4ZU+LfE17MDSrQpjDA@mail.gmail.com>
	<55EEAF37.5050402@huawei.com>
	<55EEAFD7.8010409@huawei.com>
Date: Tue, 8 Sep 2015 13:05:34 +0300
Message-ID: <CAPAsAGzeRz5hrvJiO94vFy3SEjcHW2vvPdA0DM3LF0HOtfLhyA@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix last shadow judgement in memory_is_poisoned_16()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhongjiang@huawei.com

2015-09-08 12:52 GMT+03:00 Xishi Qiu <qiuxishi@huawei.com>:
> On 2015/9/8 17:49, Xishi Qiu wrote:
>
>> On 2015/9/8 17:36, Andrey Ryabinin wrote:
>>
>>> 2015-09-08 4:42 GMT+03:00 Xishi Qiu <qiuxishi@huawei.com>:
>>>> The shadow which correspond 16 bytes may span 2 or 3 bytes. If shadow
>>>> only take 2 bytes, we can return in "if (likely(!last_byte)) ...", but
>>>> it calculates wrong, so fix it.
>>>>
>>>
>>> Please, be more specific. Describe what is wrong with the current code and why,
>>> what's the effect of this bug and how you fixed it.
>>>
>>>
>>
>> If the 16 bytes memory is aligned on 8, then the shadow takes only 2 bytes.
>> So we check "shadow_first_bytes" is enough, and need not to call "memory_is_poisoned_1(addr + 15);".
>> The code "if (likely(IS_ALIGNED(addr, 8)))" is wrong judgement.
>
> Sorry, a mistake, The code "if (likely(!last_byte))" is wrong judgement.
>
>> e.g. addr=0, so last_byte = 15 & KASAN_SHADOW_MASK = 7, then the code will
>> continue to call "return memory_is_poisoned_1(addr + 15);"
>>

Right, put this into changelog please.

>> Thanks,
>> Xishi Qiu
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
