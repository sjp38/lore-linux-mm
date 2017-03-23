Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAB7C6B0351
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 09:05:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o126so393161802pfb.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 06:05:44 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0129.outbound.protection.outlook.com. [104.47.2.129])
        by mx.google.com with ESMTPS id e65si3983024pfg.419.2017.03.23.06.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Mar 2017 06:05:43 -0700 (PDT)
Subject: Re: [PATCH v2] kasan: report only the first error by default
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
 <20170323114916.29871-1-aryabinin@virtuozzo.com>
 <20170323124154.GE9287@leverpostej>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <d9be02d7-af87-208a-c51b-c890b549434b@virtuozzo.com>
Date: Thu, 23 Mar 2017 16:06:59 +0300
MIME-Version: 1.0
In-Reply-To: <20170323124154.GE9287@leverpostej>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 03/23/2017 03:41 PM, Mark Rutland wrote:
> On Thu, Mar 23, 2017 at 02:49:16PM +0300, Andrey Ryabinin wrote:
>> +	kasan_multi_shot
>> +			[KNL] Enforce KASAN (Kernel Address Sanitizer) to print
>> +			report on every invalid memory access. Without this
>> +			parameter KASAN will print report only for the first
>> +			invalid access.
>> +
> 
> The option looks fine to me.
> 
>>  static int __init kmalloc_tests_init(void)
>>  {
>> +	/* Rise reports limit high enough to see all the following bugs */
>> +	atomic_add(100, &kasan_report_count);
> 
>> +
>> +	/*
>> +	 * kasan is unreliable now, disable reports if
>> +	 * we are in single shot mode
>> +	 */
>> +	atomic_sub(100, &kasan_report_count);
>>  	return -EAGAIN;
>>  }
> 
> ... but these magic numbers look rather messy.
> 
> [...]
> 
>> +atomic_t kasan_report_count = ATOMIC_INIT(1);
>> +EXPORT_SYMBOL_GPL(kasan_report_count);
>> +
>> +static int __init kasan_set_multi_shot(char *str)
>> +{
>> +	atomic_set(&kasan_report_count, 1000000000);
>> +	return 1;
>> +}
>> +__setup("kasan_multi_shot", kasan_set_multi_shot);
> 
> ... likewise.
> 
> Rather than trying to pick an arbitrarily large number, how about we use
> separate flags to determine whether we're in multi-shot mode, and
> whether a (oneshot) report has been made.
> 
> How about the below?
 
Yes, it deferentially looks better.
Can you send a patch with a changelog, or do you want me to care of it?

> Thanks,
> Mark.
> 

> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index f479365..f1c5892 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -13,6 +13,7 @@
>   *
>   */
>  
> +#include <linux/bitops.h>
>  #include <linux/ftrace.h>

We also need <linux/init.h> for __setup().

>  #include <linux/kernel.h>
>  #include <linux/mm.h>
> @@ -293,6 +294,40 @@ static void kasan_report_error(struct kasan_access_info *info)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
