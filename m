Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4EAD6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 17:50:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so17298989pfg.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:50:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ot14si8385603pab.13.2016.07.27.14.49.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 14:49:59 -0700 (PDT)
Date: Wed, 27 Jul 2016 14:49:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] kexec: add restriction on kexec_load() segment sizes
Message-Id: <20160727144959.1738ad345ba6827d9bbca85d@linux-foundation.org>
In-Reply-To: <1469625474-53904-1-git-send-email-zhongjiang@huawei.com>
References: <1469625474-53904-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: ebiederm@xmission.com, linux-mm@kvack.org

On Wed, 27 Jul 2016 21:17:54 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -140,6 +140,7 @@ int kexec_should_crash(struct task_struct *p)
>   * allocating pages whose destination address we do not care about.
>   */
>  #define KIMAGE_NO_DEST (-1UL)
> +#define PAGE_COUNT(x) (((x) + PAGE_SIZE - 1) >> PAGE_SHIFT)
>  
>  static struct page *kimage_alloc_page(struct kimage *image,
>  				       gfp_t gfp_mask,
> @@ -149,6 +150,7 @@ int sanity_check_segment_list(struct kimage *image)
>  {
>  	int result, i;
>  	unsigned long nr_segments = image->nr_segments;
> +	unsigned long total_pages = 0;
>  
>  	/*
>  	 * Verify we have good destination addresses.  The caller is
> @@ -210,6 +212,22 @@ int sanity_check_segment_list(struct kimage *image)
>  	}
>  
> +	/*
> +	 * Verify that no segment is larger than half of memory.
> +	 * If a segment from userspace is too large, a large amount
> +	 * of time will be wasted allocating pages, which can cause
> +	 * * a soft lockup.
> +	 */
> +	for (i = 0; i < nr_segments; i++) {
> +		if (PAGE_COUNT(image->segment[i].memsz) > totalram_pages / 2)
> +			return result;
> +
> +		total_pages += PAGE_COUNT(image->segment[i].memsz);
> +	}
> +
> +	if (total_pages > totalram_pages / 2)
> +		return result;
> +

eh, that'll do ;)

Updates:

--- a/kernel/kexec_core.c~kexec-add-restriction-on-kexec_load-segment-sizes-fix
+++ a/kernel/kexec_core.c
@@ -217,20 +217,19 @@ int sanity_check_segment_list(struct kim
 	}
 
 	/*
-	 * Verify that no segment is larger than half of memory.
-	 * If a segment from userspace is too large, a large amount
-	 * of time will be wasted allocating pages, which can cause
-	 * * a soft lockup.
+	 * Verify that no more than half of memory will be consumed. If the
+	 * request from userspace is too large, a large amount of time will be
+	 * wasted allocating pages, which can cause a soft lockup.
 	 */
 	for (i = 0; i < nr_segments; i++) {
 		if (PAGE_COUNT(image->segment[i].memsz) > totalram_pages / 2)
-			return result;
+			return -EINVAL;
 
 		total_pages += PAGE_COUNT(image->segment[i].memsz);
 	}
 
 	if (total_pages > totalram_pages / 2)
-		return result;
+		return -EINVAL;
 
 	/*
 	 * Verify we have good destination addresses.  Normally
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
