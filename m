Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 651C06B0002
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 18:45:39 -0400 (EDT)
Received: by mail-da0-f43.google.com with SMTP id u36so3893220dak.16
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 15:45:38 -0700 (PDT)
Date: Tue, 26 Mar 2013 15:45:36 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: Fix link error on ARM
Message-ID: <20130326224536.GA29952@kroah.com>
References: <1364337232-3513-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364337232-3513-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 26, 2013 at 11:33:52PM +0100, Joerg Roedel wrote:
> Testing the arm chromebook config against the upstream
> kernel produces a linker error for the zsmalloc module from
> staging. The symbol flush_tlb_kernel_range is not available
> there. Fix this by removing the reimplementation of
> unmap_kernel_range in the zsmalloc module and using the
> function directly.
> 
> Signed-off-by: Joerg Roedel <joro@8bytes.org>

Why is this not an error for any other architecture?  Why is arm
special?

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

I _really_ don't like adding core exports for a staging driver, there is
no guarantee that the staging driver will not just be deleted tomorrow.

So, if at all possible, I don't want to do this.

Perhaps, just make it so the staging code can't be a module?

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
