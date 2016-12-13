Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id F03DB6B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 11:04:11 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id m67so110586449qkf.0
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 08:04:11 -0800 (PST)
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com. [209.85.220.173])
        by mx.google.com with ESMTPS id u16si18234554qkl.105.2016.12.13.08.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 08:04:11 -0800 (PST)
Received: by mail-qk0-f173.google.com with SMTP id n204so120716103qke.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 08:04:10 -0800 (PST)
Subject: Re: [PATCH] staging: android: ion: return -ENOMEM in ion_cma_heap
 allocation failure
References: <1481259930-4620-1-git-send-email-jaewon31.kim@samsung.com>
 <1481259930-4620-2-git-send-email-jaewon31.kim@samsung.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <db51d8ca-e95f-ad93-ff6d-c55762d484c0@redhat.com>
Date: Tue, 13 Dec 2016 08:04:06 -0800
MIME-Version: 1.0
In-Reply-To: <1481259930-4620-2-git-send-email-jaewon31.kim@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>, gregkh@linuxfoundation.org
Cc: sumit.semwal@linaro.org, tixy@linaro.org, prime.zeng@huawei.com, tranmanphong@gmail.com, fabio.estevam@freescale.com, ccross@android.com, rebecca@android.com, benjamin.gaignard@linaro.org, arve@android.com, riandrews@android.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On 12/08/2016 09:05 PM, Jaewon Kim wrote:
> Initial Commit 349c9e138551 ("gpu: ion: add CMA heap") returns -1 in allocation
> failure. The returned value is passed up to userspace through ioctl. So user can
> misunderstand error reason as -EPERM(1) rather than -ENOMEM(12).
> 
> This patch simply changed this to return -ENOMEM.
> 
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> ---
>  drivers/staging/android/ion/ion_cma_heap.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/android/ion/ion_cma_heap.c b/drivers/staging/android/ion/ion_cma_heap.c
> index 6c7de74..22b9582 100644
> --- a/drivers/staging/android/ion/ion_cma_heap.c
> +++ b/drivers/staging/android/ion/ion_cma_heap.c
> @@ -24,8 +24,6 @@
>  #include "ion.h"
>  #include "ion_priv.h"
>  
> -#define ION_CMA_ALLOCATE_FAILED -1
> -
>  struct ion_cma_heap {
>  	struct ion_heap heap;
>  	struct device *dev;
> @@ -59,7 +57,7 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
>  
>  	info = kzalloc(sizeof(struct ion_cma_buffer_info), GFP_KERNEL);
>  	if (!info)
> -		return ION_CMA_ALLOCATE_FAILED;
> +		return -ENOMEM;
>  
>  	info->cpu_addr = dma_alloc_coherent(dev, len, &(info->handle),
>  						GFP_HIGHUSER | __GFP_ZERO);
> @@ -88,7 +86,7 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
>  	dma_free_coherent(dev, len, info->cpu_addr, info->handle);
>  err:
>  	kfree(info);
> -	return ION_CMA_ALLOCATE_FAILED;
> +	return -ENOMEM;
>  }
>  
>  static void ion_cma_free(struct ion_buffer *buffer)
> 

Happy to see cleanup

Acked-by: Laura Abbott <labbott@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
