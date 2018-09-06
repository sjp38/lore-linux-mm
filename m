Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61A276B79C3
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 13:06:37 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y130-v6so8432476qka.1
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 10:06:37 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00096.outbound.protection.outlook.com. [40.107.0.96])
        by mx.google.com with ESMTPS id l67-v6si2398588qkb.61.2018.09.06.10.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Sep 2018 10:06:36 -0700 (PDT)
Subject: Re: [PATCH v2] arm64: kasan: add interceptors for strcmp/strncmp
 functions
References: <1535014606-176525-1-git-send-email-kyeongdon.kim@lge.com>
 <12d4e435-e229-b4af-4286-a53fa77cb09d@virtuozzo.com>
 <0bde837e-2804-c6d6-4bda-8b166bdcfc6b@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4301317d-74a1-963c-e423-781808de215a@virtuozzo.com>
Date: Thu, 6 Sep 2018 20:06:48 +0300
MIME-Version: 1.0
In-Reply-To: <0bde837e-2804-c6d6-4bda-8b166bdcfc6b@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyeongdon Kim <kyeongdon.kim@lge.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, glider@google.com, dvyukov@google.com, Jason@zx2c4.com, robh@kernel.org, ard.biesheuvel@linaro.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org

On 09/05/2018 10:44 AM, Kyeongdon Kim wrote:
> 
> 
> On 2018-09-05 i??i ? 1:24, Andrey Ryabinin wrote:
>>
>>
>> On 09/04/2018 01:10 PM, Andrey Ryabinin wrote:
>> >
>> >
>> > On 09/04/2018 09:59 AM, Kyeongdon Kim wrote:
>> >
>> >>>> +#undef strncmp
>> >>>> +int strncmp(const char *cs, const char *ct, size_t len)
>> >>>> +{
>> >>>> + check_memory_region((unsigned long)cs, len, false, _RET_IP_);
>> >>>> + check_memory_region((unsigned long)ct, len, false, _RET_IP_);
>> >>>
>> >>> This will cause false positives. Both 'cs', and 'ct' could be less than len bytes.
>> >>>
>> >>> There is no need in these interceptors, just use the C implementations from lib/string.c
>> >>> like you did in your first patch.
>> >>> The only thing that was wrong in the first patch is that assembly implementations
>> >>> were compiled out instead of being declared week.
>> >>>
>> >> Well, at first I thought so..
>> >> I would remove diff code in /mm/kasan/kasan.c then use C implementations in lib/string.c
>> >> w/ assem implementations as weak :
>> >>
>> >> diff --git a/lib/string.c b/lib/string.c
>> >> index 2c0900a..a18b18f 100644
>> >> --- a/lib/string.c
>> >> +++ b/lib/string.c
>> >> @@ -312,7 +312,7 @@ size_t strlcat(char *dest, const char *src, size_t count)
>> >> A EXPORT_SYMBOL(strlcat);
>> >> A #endif
>> >>
>> >> -#ifndef __HAVE_ARCH_STRCMP
>> >> +#if (defined(CONFIG_ARM64) && defined(CONFIG_KASAN)) || !defined(__HAVE_ARCH_STRCMP)
>> >
>> > No. What part of "like you did in your first patch" is unclear to you?
>>
>> Just to be absolutely clear, I meant #ifdef out __HAVE_ARCH_* defines like it has been done in this patch
>> http://lkml.kernel.org/r/<1534233322-106271-1-git-send-email-kyeongdon.kim@lge.com>
> I understood what you're saying, but I might think the wrong patch.
> 
> So, thinking about the other way as below:
> can pick up assem variant or c one, declare them as weak.


It's was much easier for me to explain with patch how this should be done in my opinion.
So I just sent the patches, take a look.
