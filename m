Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93BFF6B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:59:10 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hb4so137400925pac.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:59:10 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0148.outbound.protection.outlook.com. [157.55.234.148])
        by mx.google.com with ESMTPS id z127si3078395pfz.158.2016.04.15.08.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 08:59:09 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] mm, kasan: add a ksize() test
References: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
 <562d43518232cf7d26297ee004255a083b084071.1460545373.git.glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57110FDD.4070900@virtuozzo.com>
Date: Fri, 15 Apr 2016 18:59:25 +0300
MIME-Version: 1.0
In-Reply-To: <562d43518232cf7d26297ee004255a083b084071.1460545373.git.glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, dvyukov@google.com, cl@linux.com, akpm@linux-foundation.org, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 04/13/2016 02:20 PM, Alexander Potapenko wrote:
> Add a test that makes sure ksize() unpoisons the whole chunk.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
> v2: - splitted v1 into two patches
> ---
>  lib/test_kasan.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index 82169fb..48e5a0b 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -344,6 +344,25 @@ static noinline void __init kasan_stack_oob(void)
>  	*(volatile char *)p;
>  }
>  
> +static noinline void __init ksize_unpoisons_memory(void)
> +{
> +	char *ptr;
> +	size_t size = 123, real_size = size;
> +
> +	pr_info("ksize() unpoisons the whole allocated chunk\n");
> +	ptr = kmalloc(size, GFP_KERNEL);
> +	if (!ptr) {
> +		pr_err("Allocation failed\n");
> +		return;
> +	}
> +	real_size = ksize(ptr);
> +	/* This access doesn't trigger an error. */
> +	ptr[size] = 'x';
> +	/* This one does. */
> +	ptr[real_size] = 'y';
> +	kfree(ptr);
> +}
> +
>  static int __init kmalloc_tests_init(void)
>  {
>  	kmalloc_oob_right();
> @@ -367,6 +386,7 @@ static int __init kmalloc_tests_init(void)
>  	kmem_cache_oob();
>  	kasan_stack_oob();
>  	kasan_global_oob();
> +	ksize_unpoisons_memory();
>  	return -EAGAIN;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
