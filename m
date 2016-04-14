Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 28CA66B028B
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:25:36 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so95780968pab.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:25:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id vy4si9029505pab.124.2016.04.14.08.25.35
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 08:25:35 -0700 (PDT)
Date: Thu, 14 Apr 2016 16:25:32 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 9/9] mm: replace open coded page to virt conversion
 with page_to_virt()
Message-ID: <20160414152532.GD4584@arm.com>
References: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
 <1459349164-27175-10-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459349164-27175-10-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, mark.rutland@arm.com, steve.capper@linaro.org

On Wed, Mar 30, 2016 at 04:46:04PM +0200, Ard Biesheuvel wrote:
> The open coded conversion from struct page address to virtual address in
> lowmem_page_address() involves an intermediate conversion step to pfn
> number/physical address. Since the placement of the struct page array
> relative to the linear mapping may be completely independent from the
> placement of physical RAM (as is that case for arm64 after commit
> dfd55ad85e 'arm64: vmemmap: use virtual projection of linear region'),
> the conversion to physical address and back again should factor out of
> the equation, but unfortunately, the shifting and pointer arithmetic
> involved prevent this from happening, and the resulting calculation
> essentially subtracts the address of the start of physical memory and
> adds it back again, in a way that prevents the compiler from optimizing
> it away.
> 
> Since the start of physical memory is not a build time constant on arm64,
> the resulting conversion involves an unnecessary memory access, which
> we would like to get rid of. So replace the open coded conversion with
> a call to page_to_virt(), and use the open coded conversion as its
> default definition, to be overriden by the architecture, if desired.
> The existing arch specific definitions of page_to_virt are all equivalent
> to this default definition, so by itself this patch is a no-op.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Acked-by: Will Deacon <will.deacon@arm.com>

I assume you'll post this patch (and the nios2/openrisc) patches as
individual patches targetting the relevant trees?

Will

> ---
>  include/linux/mm.h | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ed6407d1b7b5..474c4625756e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -72,6 +72,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
>  #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
>  #endif
>  
> +#ifndef page_to_virt
> +#define page_to_virt(x)	__va(PFN_PHYS(page_to_pfn(x)))
> +#endif
> +
>  /*
>   * To prevent common memory management code establishing
>   * a zero page mapping on a read fault.
> @@ -948,7 +952,7 @@ static inline struct mem_cgroup *page_memcg(struct page *page)
>  
>  static __always_inline void *lowmem_page_address(const struct page *page)
>  {
> -	return __va(PFN_PHYS(page_to_pfn(page)));
> +	return page_to_virt(page);
>  }
>  
>  #if defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL)
> -- 
> 2.5.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
