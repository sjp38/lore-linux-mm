Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6B3F6B6E65
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 12:24:24 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d10-v6so4131755wrw.6
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 09:24:24 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0108.outbound.protection.outlook.com. [104.47.2.108])
        by mx.google.com with ESMTPS id n17-v6si19414484wra.263.2018.09.04.09.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Sep 2018 09:24:23 -0700 (PDT)
Subject: Re: [PATCH v2] arm64: kasan: add interceptors for strcmp/strncmp
 functions
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
References: <1535014606-176525-1-git-send-email-kyeongdon.kim@lge.com>
 <dff9a2f3-7db5-9e60-072a-312b6cfbe0f0@virtuozzo.com>
 <ad334e64-28d1-4b91-aeba-8352934a9c46@lge.com>
 <6954711c-6441-04df-62a9-a83c867e06ad@virtuozzo.com>
Message-ID: <12d4e435-e229-b4af-4286-a53fa77cb09d@virtuozzo.com>
Date: Tue, 4 Sep 2018 19:24:33 +0300
MIME-Version: 1.0
In-Reply-To: <6954711c-6441-04df-62a9-a83c867e06ad@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyeongdon Kim <kyeongdon.kim@lge.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, glider@google.com, dvyukov@google.com, Jason@zx2c4.com, robh@kernel.org, ard.biesheuvel@linaro.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org



On 09/04/2018 01:10 PM, Andrey Ryabinin wrote:
> 
> 
> On 09/04/2018 09:59 AM, Kyeongdon Kim wrote:
> 
>>>> +#undef strncmp
>>>> +int strncmp(const char *cs, const char *ct, size_t len)
>>>> +{
>>>> + check_memory_region((unsigned long)cs, len, false, _RET_IP_);
>>>> + check_memory_region((unsigned long)ct, len, false, _RET_IP_);
>>>
>>> This will cause false positives. Both 'cs', and 'ct' could be less than len bytes.
>>>
>>> There is no need in these interceptors, just use the C implementations from lib/string.c
>>> like you did in your first patch.
>>> The only thing that was wrong in the first patch is that assembly implementations
>>> were compiled out instead of being declared week.
>>>
>> Well, at first I thought so..
>> I would remove diff code in /mm/kasan/kasan.c then use C implementations in lib/string.c
>> w/ assem implementations as weak :
>>
>> diff --git a/lib/string.c b/lib/string.c
>> index 2c0900a..a18b18f 100644
>> --- a/lib/string.c
>> +++ b/lib/string.c
>> @@ -312,7 +312,7 @@ size_t strlcat(char *dest, const char *src, size_t count)
>> A EXPORT_SYMBOL(strlcat);
>> A #endif
>>
>> -#ifndef __HAVE_ARCH_STRCMP
>> +#if (defined(CONFIG_ARM64) && defined(CONFIG_KASAN)) || !defined(__HAVE_ARCH_STRCMP)
> 
> No. What part of "like you did in your first patch" is unclear to you?

Just to be absolutely clear, I meant #ifdef out __HAVE_ARCH_* defines like it has been done in this patch
http://lkml.kernel.org/r/<1534233322-106271-1-git-send-email-kyeongdon.kim@lge.com>
