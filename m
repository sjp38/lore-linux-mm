Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 131C86B6CEF
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 06:10:14 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b5-v6so3502860qtk.4
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 03:10:14 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0133.outbound.protection.outlook.com. [104.47.0.133])
        by mx.google.com with ESMTPS id m62-v6si6332154qkd.345.2018.09.04.03.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Sep 2018 03:10:12 -0700 (PDT)
Subject: Re: [PATCH v2] arm64: kasan: add interceptors for strcmp/strncmp
 functions
References: <1535014606-176525-1-git-send-email-kyeongdon.kim@lge.com>
 <dff9a2f3-7db5-9e60-072a-312b6cfbe0f0@virtuozzo.com>
 <ad334e64-28d1-4b91-aeba-8352934a9c46@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <6954711c-6441-04df-62a9-a83c867e06ad@virtuozzo.com>
Date: Tue, 4 Sep 2018 13:10:23 +0300
MIME-Version: 1.0
In-Reply-To: <ad334e64-28d1-4b91-aeba-8352934a9c46@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyeongdon Kim <kyeongdon.kim@lge.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, glider@google.com, dvyukov@google.com, Jason@zx2c4.com, robh@kernel.org, ard.biesheuvel@linaro.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org



On 09/04/2018 09:59 AM, Kyeongdon Kim wrote:

>> > +#undef strncmp
>> > +int strncmp(const char *cs, const char *ct, size_t len)
>> > +{
>> > + check_memory_region((unsigned long)cs, len, false, _RET_IP_);
>> > + check_memory_region((unsigned long)ct, len, false, _RET_IP_);
>>
>> This will cause false positives. Both 'cs', and 'ct' could be less than len bytes.
>>
>> There is no need in these interceptors, just use the C implementations from lib/string.c
>> like you did in your first patch.
>> The only thing that was wrong in the first patch is that assembly implementations
>> were compiled out instead of being declared week.
>>
> Well, at first I thought so..
> I would remove diff code in /mm/kasan/kasan.c then use C implementations in lib/string.c
> w/ assem implementations as weak :
> 
> diff --git a/lib/string.c b/lib/string.c
> index 2c0900a..a18b18f 100644
> --- a/lib/string.c
> +++ b/lib/string.c
> @@ -312,7 +312,7 @@ size_t strlcat(char *dest, const char *src, size_t count)
> A EXPORT_SYMBOL(strlcat);
> A #endif
> 
> -#ifndef __HAVE_ARCH_STRCMP
> +#if (defined(CONFIG_ARM64) && defined(CONFIG_KASAN)) || !defined(__HAVE_ARCH_STRCMP)

No. What part of "like you did in your first patch" is unclear to you?

> A /**
> A  * strcmp - Compare two strings
> A  * @cs: One string
> @@ -336,7 +336,7 @@ int strcmp(const char *cs, const char *ct)
> A EXPORT_SYMBOL(strcmp);
> A #endif
> 
> -#ifndef __HAVE_ARCH_STRNCMP
> +#if (defined(CONFIG_ARM64) && defined(CONFIG_KASAN)) || !defined(__HAVE_ARCH_STRNCMP)
> A /**
> A  * strncmp - Compare two length-limited strings
> 
> Can I get your opinion wrt this ?
> 
> Thanks,
> 
