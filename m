Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95B9B6B0340
	for <linux-mm@kvack.org>; Wed, 16 May 2018 12:45:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3-v6so843890pfe.15
        for <linux-mm@kvack.org>; Wed, 16 May 2018 09:45:56 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0098.outbound.protection.outlook.com. [104.47.2.98])
        by mx.google.com with ESMTPS id t7-v6si3169509pfa.170.2018.05.16.09.45.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 16 May 2018 09:45:55 -0700 (PDT)
Subject: Re: [PATCH] lib/stackdepot.c: use a non-instrumented version of
 memcpy()
References: <20180516153434.24479-1-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f8a737c1-8cb9-15e1-2d98-454a4cafc1ed@virtuozzo.com>
Date: Wed, 16 May 2018 19:47:03 +0300
MIME-Version: 1.0
In-Reply-To: <20180516153434.24479-1-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org, dvyukov@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/16/2018 06:34 PM, Alexander Potapenko wrote:
> stackdepot used to call memcpy(), which compiler tools normally
> instrument, therefore every lookup used to unnecessarily call instrumented
> code.  This is somewhat ok in the case of KASAN, but under KMSAN a lot of
> time was spent in the instrumentation.
> 
> (A similar change has been previously committed for memcmp())
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> ---
>  lib/stackdepot.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
> index e513459a5601..d48c744fa750 100644
> --- a/lib/stackdepot.c
> +++ b/lib/stackdepot.c
> @@ -140,7 +140,7 @@ static struct stack_record *depot_alloc_stack(unsigned long *entries, int size,
>  	stack->handle.slabindex = depot_index;
>  	stack->handle.offset = depot_offset >> STACK_ALLOC_ALIGN;
>  	stack->handle.valid = 1;
> -	memcpy(stack->entries, entries, size * sizeof(unsigned long));
> +	__memcpy(stack->entries, entries, size * sizeof(unsigned long));

This has no effect. Since the whole file is not instrumented memcpy automagically replaced with __memcpy.
