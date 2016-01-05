Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC4C6B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 16:17:18 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id f206so48556589wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 13:17:18 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id b8si155015576wjx.62.2016.01.05.13.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 13:17:17 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id l65so38081791wmf.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 13:17:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160105101017.GA14545@localhost.localdomain>
References: <1451556549-8962-1-git-send-email-zhongjiang@huawei.com>
	<20160105101017.GA14545@localhost.localdomain>
Date: Wed, 6 Jan 2016 00:17:17 +0300
Message-ID: <CAPAsAGwHyVDvaoNjVxZsjtVczWh7-+OQOxpFBLS+e961DBAzeQ@mail.gmail.com>
Subject: Re: [PATCH] arm64: fix add kasan bug
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: zhongjiang <zhongjiang@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "long.wanglong@huawei.com" <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>

2016-01-05 13:10 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
> On Thu, Dec 31, 2015 at 10:09:09AM +0000, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> In general, each process have 16kb stack space to use, but
>> stack need extra space to store red_zone when kasan enable.
>> the patch fix above question.
>>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  arch/arm64/include/asm/thread_info.h | 15 +++++++++++++--
>>  1 file changed, 13 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
>> index 90c7ff2..45b5a7e 100644
>> --- a/arch/arm64/include/asm/thread_info.h
>> +++ b/arch/arm64/include/asm/thread_info.h
> [...]
>> +#ifdef CONFIG_KASAN
>> +#define THREAD_SIZE          32768
>> +#else
>>  #define THREAD_SIZE          16384
>> +#endif
>
> I'm not really keen on increasing the stack size to 32KB when KASan is
> enabled (that's 8 4K pages). Have you actually seen a real problem with
> the default size?

> How large is the red_zone?
>

Typical stack frame layout looks like this:
    | 32-byte redzone | variable-1| padding-redzone to the next
32-byte boundary| variable-2|padding |.... | 32-byte redzone|

AFAIK gcc creates redzones  only if it can't prove that all accesses
to variable are valid (e.g. reference to variable passed to external
function).
Besides redzones, stack could be increased due to additional spilling.
Although arm64 should be less affected by this since it has more
registers than x86_64.
On x86_64 I've seen few bad cases where stack frame of a single
function was bloated up to 6K.


> With 4.5 we are going for separate IRQ stack on arm64, so the typical
> stack overflow case no longer exists.
>
> --
> Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
