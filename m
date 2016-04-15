Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6BF6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:58:25 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id vv3so138212773pab.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:58:25 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0111.outbound.protection.outlook.com. [157.56.112.111])
        by mx.google.com with ESMTPS id x72si3052249pfi.196.2016.04.15.08.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 08:58:24 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm, kasan: don't call kasan_krealloc() from
 ksize().
References: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57110FAF.8070401@virtuozzo.com>
Date: Fri, 15 Apr 2016 18:58:39 +0300
MIME-Version: 1.0
In-Reply-To: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, dvyukov@google.com, cl@linux.com, akpm@linux-foundation.org, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 04/13/2016 02:20 PM, Alexander Potapenko wrote:
> Instead of calling kasan_krealloc(), which replaces the memory allocation
> stack ID (if stack depot is used), just unpoison the whole memory chunk.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
> v2: - splitted v1 into two patches
> ---
>  mm/slab.c | 2 +-
>  mm/slub.c | 5 +++--
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 17e2848..de46319 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4324,7 +4324,7 @@ size_t ksize(const void *objp)
>  	/* We assume that ksize callers could use the whole allocated area,
>  	 * so we need to unpoison this area.
>  	 */
> -	kasan_krealloc(objp, size, GFP_NOWAIT);
> +	kasan_unpoison_shadow(objp, size);
>  
>  	return size;
>  }
> diff --git a/mm/slub.c b/mm/slub.c
> index 4dbb109e..62194e2 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3635,8 +3635,9 @@ size_t ksize(const void *object)
>  {
>  	size_t size = __ksize(object);
>  	/* We assume that ksize callers could use whole allocated area,
> -	   so we need unpoison this area. */
> -	kasan_krealloc(object, size, GFP_NOWAIT);
> +	 * so we need to unpoison this area.
> +	 */
> +	kasan_unpoison_shadow(object, size);
>  	return size;
>  }
>  EXPORT_SYMBOL(ksize);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
