Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0C89C6B003C
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:43:34 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so1957932pab.13
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:43:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b1si9625690pdn.227.2014.09.12.12.43.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 12:43:33 -0700 (PDT)
Date: Fri, 12 Sep 2014 15:42:58 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH v2 3/6] x86, mm, asm-gen: Add ioremap_wt() for WT
Message-ID: <20140912194258.GJ15656@laptop.dumpdata.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
 <1410367910-6026-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410367910-6026-4-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com

On Wed, Sep 10, 2014 at 10:51:47AM -0600, Toshi Kani wrote:
> This patch adds ioremap_wt() for creating WT mapping on x86.
> It follows the same model as ioremap_wc() for multi-architecture
> support.  ARCH_HAS_IOREMAP_WT is defined in the x86 version of
> io.h to indicate that ioremap_wt() is implemented on x86.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

> ---
>  arch/x86/include/asm/io.h   |    2 ++
>  arch/x86/mm/ioremap.c       |   24 ++++++++++++++++++++++++
>  include/asm-generic/io.h    |    4 ++++
>  include/asm-generic/iomap.h |    4 ++++
>  4 files changed, 34 insertions(+)
> 
> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
> index 71b9e65..c813c86 100644
> --- a/arch/x86/include/asm/io.h
> +++ b/arch/x86/include/asm/io.h
> @@ -35,6 +35,7 @@
>    */
>  
>  #define ARCH_HAS_IOREMAP_WC
> +#define ARCH_HAS_IOREMAP_WT
>  
>  #include <linux/string.h>
>  #include <linux/compiler.h>
> @@ -316,6 +317,7 @@ extern void unxlate_dev_mem_ptr(unsigned long phys, void *addr);
>  extern int ioremap_change_attr(unsigned long vaddr, unsigned long size,
>  				enum page_cache_mode pcm);
>  extern void __iomem *ioremap_wc(resource_size_t offset, unsigned long size);
> +extern void __iomem *ioremap_wt(resource_size_t offset, unsigned long size);
>  
>  extern bool is_early_ioremap_ptep(pte_t *ptep);
>  
> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
> index 885fe44..952f4b4 100644
> --- a/arch/x86/mm/ioremap.c
> +++ b/arch/x86/mm/ioremap.c
> @@ -155,6 +155,10 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
>  		prot = __pgprot(pgprot_val(prot) |
>  				cachemode2protval(_PAGE_CACHE_MODE_WC));
>  		break;
> +	case _PAGE_CACHE_MODE_WT:
> +		prot = __pgprot(pgprot_val(prot) |
> +				cachemode2protval(_PAGE_CACHE_MODE_WT));
> +		break;
>  	case _PAGE_CACHE_MODE_WB:
>  		break;
>  	}
> @@ -249,6 +253,26 @@ void __iomem *ioremap_wc(resource_size_t phys_addr, unsigned long size)
>  }
>  EXPORT_SYMBOL(ioremap_wc);
>  
> +/**
> + * ioremap_wt	-	map memory into CPU space write through
> + * @phys_addr:	bus address of the memory
> + * @size:	size of the resource to map
> + *
> + * This version of ioremap ensures that the memory is marked write through.
> + * Write through writes data into memory while keeping the cache up-to-date.
> + *
> + * Must be freed with iounmap.
> + */
> +void __iomem *ioremap_wt(resource_size_t phys_addr, unsigned long size)
> +{
> +	if (pat_enabled)
> +		return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WT,
> +					__builtin_return_address(0));
> +	else
> +		return ioremap_nocache(phys_addr, size);
> +}
> +EXPORT_SYMBOL(ioremap_wt);
> +
>  void __iomem *ioremap_cache(resource_size_t phys_addr, unsigned long size)
>  {
>  	return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WB,
> diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
> index 975e1cc..405d418 100644
> --- a/include/asm-generic/io.h
> +++ b/include/asm-generic/io.h
> @@ -322,6 +322,10 @@ static inline void __iomem *ioremap(phys_addr_t offset, unsigned long size)
>  #define ioremap_wc ioremap_nocache
>  #endif
>  
> +#ifndef ioremap_wt
> +#define ioremap_wt ioremap_nocache
> +#endif
> +
>  static inline void iounmap(void __iomem *addr)
>  {
>  }
> diff --git a/include/asm-generic/iomap.h b/include/asm-generic/iomap.h
> index 1b41011..d8f8622 100644
> --- a/include/asm-generic/iomap.h
> +++ b/include/asm-generic/iomap.h
> @@ -66,6 +66,10 @@ extern void ioport_unmap(void __iomem *);
>  #define ioremap_wc ioremap_nocache
>  #endif
>  
> +#ifndef ARCH_HAS_IOREMAP_WT
> +#define ioremap_wt ioremap_nocache
> +#endif
> +
>  #ifdef CONFIG_PCI
>  /* Destroy a virtual mapping cookie for a PCI BAR (memory or IO) */
>  struct pci_dev;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
