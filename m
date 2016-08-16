Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A68D6B0253
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 13:34:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so184199410pfx.0
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 10:34:50 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r4si33008176pfd.242.2016.08.16.10.34.49
        for <linux-mm@kvack.org>;
        Tue, 16 Aug 2016 10:34:49 -0700 (PDT)
Date: Tue, 16 Aug 2016 18:34:46 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Avoid using __va() on addresses that don't
 have a lowmem mapping
Message-ID: <20160816173445.GD7609@e104818-lin.cambridge.arm.com>
References: <1471360856-16916-1-git-send-email-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471360856-16916-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vignesh R <vigneshr@ti.com>

On Tue, Aug 16, 2016 at 04:20:56PM +0100, Catalin Marinas wrote:
> diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
> index 4894c6888bc6..380f72bc3657 100644
> --- a/include/linux/kmemleak.h
> +++ b/include/linux/kmemleak.h
> @@ -21,6 +21,7 @@
>  #ifndef __KMEMLEAK_H
>  #define __KMEMLEAK_H
>  
> +#include <linux/mm.h>

Given the kbuild-robot reports, this #include doesn't go well on some
architectures.

>  #include <linux/slab.h>
>  
>  #ifdef CONFIG_DEBUG_KMEMLEAK
> @@ -109,4 +110,29 @@ static inline void kmemleak_no_scan(const void *ptr)
>  
>  #endif	/* CONFIG_DEBUG_KMEMLEAK */
>  
> +static inline void kmemleak_alloc_phys(phys_addr_t phys, size_t size,
> +				       int min_count, gfp_t gfp)
> +{
> +	if (!IS_ENABLED(CONFIG_HIGHMEM) || phys < __pa(high_memory))
> +		kmemleak_alloc(__va(phys), size, min_count, gfp);
> +}
> +
> +static inline void kmemleak_free_part_phys(phys_addr_t phys, size_t size)
> +{
> +	if (!IS_ENABLED(CONFIG_HIGHMEM) || phys < __pa(high_memory))
> +		kmemleak_free_part(__va(phys), size);
> +}
> +
> +static inline void kmemleak_not_leak_phys(phys_addr_t phys)
> +{
> +	if (!IS_ENABLED(CONFIG_HIGHMEM) || phys < __pa(high_memory))
> +		kmemleak_not_leak(__va(phys));
> +}
> +
> +static inline void kmemleak_ignore_phys(phys_addr_t phys)
> +{
> +	if (!IS_ENABLED(CONFIG_HIGHMEM) || phys < __pa(high_memory))
> +		kmemleak_ignore(__va(phys));
> +}

I'll move these functions out of line and re-post the patch.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
