Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43A1D6B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:54:14 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n69so309738651ion.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:54:14 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0098.outbound.protection.outlook.com. [104.47.0.98])
        by mx.google.com with ESMTPS id v73si19883329oia.111.2016.08.01.07.54.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 07:54:09 -0700 (PDT)
Subject: Re: [PATCH v8 2/3] mm, kasan: align free_meta_offset on sizeof(void*)
References: <1469719879-11761-1-git-send-email-glider@google.com>
 <1469719879-11761-3-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <579F62D3.8030605@virtuozzo.com>
Date: Mon, 1 Aug 2016 17:55:15 +0300
MIME-Version: 1.0
In-Reply-To: <1469719879-11761-3-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, dvyukov@google.com, kcc@google.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 07/28/2016 06:31 PM, Alexander Potapenko wrote:
> When free_meta_offset is not zero, it is usually aligned on 4 bytes,
> because the size of preceding kasan_alloc_meta is aligned on 4 bytes.
> As a result, accesses to kasan_free_meta fields may be misaligned.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  mm/kasan/kasan.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 6845f92..0379551 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -390,7 +390,8 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>  	/* Add free meta. */
>  	if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
>  	    cache->object_size < sizeof(struct kasan_free_meta)) {
> -		cache->kasan_info.free_meta_offset = *size;
> +		cache->kasan_info.free_meta_offset =
> +			ALIGN(*size, sizeof(void *));

This cannot work.

I slightly changed metadata layout in http://lkml.kernel.org/g/<1470062715-14077-5-git-send-email-aryabinin@virtuozzo.com>
which should also fix UBSAN's complain.

>  		*size += sizeof(struct kasan_free_meta);
>  	}
>  	redzone_adjust = optimal_redzone(cache->object_size) -
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
