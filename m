Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA7526B6735
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 05:40:32 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l7-v6so25576099qte.2
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 02:40:32 -0700 (PDT)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80093.outbound.protection.outlook.com. [40.107.8.93])
        by mx.google.com with ESMTPS id r10-v6si37970qvi.112.2018.09.03.02.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 03 Sep 2018 02:40:31 -0700 (PDT)
Subject: Re: [PATCH v2] arm64: kasan: add interceptors for strcmp/strncmp
 functions
References: <1535014606-176525-1-git-send-email-kyeongdon.kim@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <dff9a2f3-7db5-9e60-072a-312b6cfbe0f0@virtuozzo.com>
Date: Mon, 3 Sep 2018 12:40:44 +0300
MIME-Version: 1.0
In-Reply-To: <1535014606-176525-1-git-send-email-kyeongdon.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyeongdon Kim <kyeongdon.kim@lge.com>, catalin.marinas@arm.com, will.deacon@arm.com, glider@google.com, dvyukov@google.com
Cc: Jason@zx2c4.com, robh@kernel.org, ard.biesheuvel@linaro.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org



On 08/23/2018 11:56 AM, Kyeongdon Kim wrote:

> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index c3bd520..61ad7f1 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -304,6 +304,29 @@ void *memcpy(void *dest, const void *src, size_t len)
>  
>  	return __memcpy(dest, src, len);
>  }
> +#ifdef CONFIG_ARM64
> +/*
> + * Arch arm64 use assembly variant for strcmp/strncmp,
> + * xtensa use inline asm operations and x86_64 use c one,
> + * so now this interceptors only for arm64 kasan.
> + */
> +#undef strcmp
> +int strcmp(const char *cs, const char *ct)
> +{
> +	check_memory_region((unsigned long)cs, 1, false, _RET_IP_);
> +	check_memory_region((unsigned long)ct, 1, false, _RET_IP_);
> +

Well this is definitely wrong. strcmp() often accesses far more than one byte.

> +	return __strcmp(cs, ct);
> +}
> +#undef strncmp
> +int strncmp(const char *cs, const char *ct, size_t len)
> +{
> +	check_memory_region((unsigned long)cs, len, false, _RET_IP_);
> +	check_memory_region((unsigned long)ct, len, false, _RET_IP_);

This will cause false positives. Both 'cs', and 'ct' could be less than len bytes.

There is no need in these interceptors, just use the C implementations from lib/string.c
like you did in your first patch.
The only thing that was wrong in the first patch is that assembly implementations
were compiled out instead of being declared week.


> +
> +	return __strncmp(cs, ct, len);
> +}
> +#endif
>  
>  void kasan_alloc_pages(struct page *page, unsigned int order)
>  {
> 
