Date: Tue, 29 Aug 2006 11:46:18 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
Message-ID: <20060829024618.GA8660@localhost.hsdv.com>
References: <20060828154413.E05721BD@localhost.localdomain> <20060828154417.D9D3FB1F@localhost.localdomain> <20060828154413.E05721BD@localhost.localdomain> <20060828154416.09E64946@localhost.localdomain> <20060828154413.E05721BD@localhost.localdomain> <20060828154414.38AEDAA2@localhost.localdomain> <20060828154413.E05721BD@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060828154417.D9D3FB1F@localhost.localdomain> <20060828154416.09E64946@localhost.localdomain> <20060828154414.38AEDAA2@localhost.localdomain> <20060828154413.E05721BD@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 28, 2006 at 08:44:13AM -0700, Dave Hansen wrote:
> diff -puN include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure include/asm-generic/page.h
> --- threadalloc/include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure	2006-08-25 11:34:22.000000000 -0700
> +++ threadalloc-dave/include/asm-generic/page.h	2006-08-25 11:34:22.000000000 -0700
[snip]
> + */
> +#define PAGE_MASK      (~((1 << PAGE_SHIFT) - 1))
> +#endif /* CONFIG_ARCH_GENERIC_PAGE_SIZE */
>  
>  /* Pure 2^n version of get_order */
>  static __inline__ __attribute_const__ int get_order(unsigned long size)
> @@ -20,7 +48,6 @@ static __inline__ __attribute_const__ in
>  	return order;
>  }
>  
You've not handled the case for platforms that have their own
get_order().

On Mon, Aug 28, 2006 at 08:44:14AM -0700, Dave Hansen wrote:
> diff -puN include/asm-ia64/page.h~ia64 include/asm-ia64/page.h
> --- threadalloc/include/asm-ia64/page.h~ia64	2006-08-25 11:34:21.000000000 -0700
> +++ threadalloc-dave/include/asm-ia64/page.h	2006-08-25 11:34:23.000000000 -0700
> @@ -7,7 +7,7 @@
>   *	David Mosberger-Tang <davidm@hpl.hp.com>
>   */
>  
> -
> +#include <asm-generic/page.h>
>  #include <asm/intrinsics.h>
>  #include <asm/types.h>
>  
Which will break here..

On Mon, Aug 28, 2006 at 08:44:16AM -0700, Dave Hansen wrote:
> diff -puN include/asm-ppc/page.h~powerpc include/asm-ppc/page.h
> --- threadalloc/include/asm-ppc/page.h~powerpc	2006-08-25 11:34:21.000000000 -0700
> +++ threadalloc-dave/include/asm-ppc/page.h	2006-08-25 11:34:26.000000000 -0700
> @@ -2,16 +2,7 @@
>  #define _PPC_PAGE_H
>  
>  #include <asm/asm-compat.h>
> -
> -/* PAGE_SHIFT determines the page size */
> -#define PAGE_SHIFT	12
> -#define PAGE_SIZE	(ASM_CONST(1) << PAGE_SHIFT)
> -
> -/*
> - * Subtle: this is an int (not an unsigned long) and so it
> - * gets extended to 64 bits the way want (i.e. with 1s).  -- paulus
> - */
> -#define PAGE_MASK	(~((1 << PAGE_SHIFT) - 1))
> +#include <asm-generic/page.h>
>  
>  #ifdef __KERNEL__
>  
here..

On Mon, Aug 28, 2006 at 08:44:17AM -0700, Dave Hansen wrote:
> diff -puN include/asm-xtensa/page.h~arch-generic-PAGE_SIZE-give-every-arch-PAGE_SHIFT include/asm-xtensa/page.h
> --- threadalloc/include/asm-xtensa/page.h~arch-generic-PAGE_SIZE-give-every-arch-PAGE_SHIFT	2006-08-25 11:34:20.000000000 -0700
> +++ threadalloc-dave/include/asm-xtensa/page.h	2006-08-25 11:34:27.000000000 -0700
> @@ -14,16 +14,7 @@
>  #ifdef __KERNEL__
>  
>  #include <asm/processor.h>
> -
> -/*
> - * PAGE_SHIFT determines the page size
> - * PAGE_ALIGN(x) aligns the pointer to the (next) page boundary
> - */
> -
> -#define PAGE_SHIFT		XCHAL_MMU_MIN_PTE_PAGE_SIZE
> -#define PAGE_SIZE		(1 << PAGE_SHIFT)
> -#define PAGE_MASK		(~(PAGE_SIZE-1))
> -#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE - 1) & PAGE_MASK)
> +#include <asm-generic/page.h>
>  
>  #define DCACHE_WAY_SIZE		(XCHAL_DCACHE_SIZE / XCHAL_DCACHE_WAYS)
>  #define PAGE_OFFSET		XCHAL_KSEG_CACHED_VADDR

and here.

You may wish to consider the HAVE_ARCH_GET_ORDER patch I sent to
linux-arch, it was intended to handle this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
