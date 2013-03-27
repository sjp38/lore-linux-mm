Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 289AB6B0002
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 20:05:56 -0400 (EDT)
Date: Wed, 27 Mar 2013 09:05:52 +0900
From: Minchan Kim <minchan.kim@lge.com>
Subject: Re: [PATCH] staging: zsmalloc: Fix link error on ARM
Message-ID: <20130327000552.GA13283@blaptop>
References: <1364337232-3513-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364337232-3513-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 26, 2013 at 11:33:52PM +0100, Joerg Roedel wrote:
> Testing the arm chromebook config against the upstream
> kernel produces a linker error for the zsmalloc module from
> staging. The symbol flush_tlb_kernel_range is not available
> there. Fix this by removing the reimplementation of
> unmap_kernel_range in the zsmalloc module and using the
> function directly.
> 
> Signed-off-by: Joerg Roedel <joro@8bytes.org>


Oops, it was my fault. When I tested [1] on CONFIG_SMP machine on ARM,
it worked well. It means it's not always problem on every CONFIG_SMP
on ARM machine but some SMP machine define flush_tlb_kernel_range,
others don't.

At that time, Russell King already suggested same thing with your patch
and I meant to clean it up because the patch was already merged but I didn't.
Because we didn't catch up that it breaks build on some configuration
so I thought it's just clean up patch and Greg didn't want to accept
NOT-BUG patch of any z* family.

Now, it's BUG patch.

Remained problem is that Greg doesn't want to export core function for
staging driver and it's reasonable for me.
So my opinion is remove zsmalloc module build and could recover it with
making unmap_kernel_range exported function after we merged it into
mainline.

And please Cc stable.

[1] [99155188, zsmalloc: Fix TLB coherency and build problem]

> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |    5 +----
>  mm/vmalloc.c                             |    1 +
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index e78d262..324e123 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -656,11 +656,8 @@ static inline void __zs_unmap_object(struct mapping_area *area,
>  				struct page *pages[2], int off, int size)
>  {
>  	unsigned long addr = (unsigned long)area->vm_addr;
> -	unsigned long end = addr + (PAGE_SIZE * 2);
>  
> -	flush_cache_vunmap(addr, end);
> -	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
> -	flush_tlb_kernel_range(addr, end);
> +	unmap_kernel_range(addr, PAGE_SIZE * 2);
>  }
>  
>  #else /* USE_PGTABLE_MAPPING */
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0f751f2..f7cba11 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1266,6 +1266,7 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
>  	vunmap_page_range(addr, end);
>  	flush_tlb_kernel_range(addr, end);
>  }
> +EXPORT_SYMBOL_GPL(unmap_kernel_range);
>  
>  int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
>  {
> -- 
> 1.7.9.5
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
