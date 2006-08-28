Date: Mon, 28 Aug 2006 10:01:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
In-Reply-To: <20060828154413.E05721BD@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0608280954100.27677@schroedinger.engr.sgi.com>
References: <20060828154413.E05721BD@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Aug 2006, Dave Hansen wrote:

> +/* align addr on a size boundary - adjust address up/down if needed */
> +#define _ALIGN_UP(addr,size)    (((addr)+((size)-1))&(~((size)-1)))
> +#define _ALIGN_DOWN(addr,size)  ((addr)&(~((size)-1)))
> +
> +/* align addr on a size boundary - adjust address up if needed */
> +#define _ALIGN(addr,size)     _ALIGN_UP(addr,size)

Note that there is a generic ALIGN macro in include/linux/kernel.h plus
__ALIGNs in linux/linkage.h. Could you use that and get to some sane 
conventin for all these ALIGN functions?

> +#
> +# On PPC32 page size is 4K. For PPC64 we support either 4K or 64K software
> +# page size. When using 64K pages however, whether we are really supporting
> +# 64K pages in HW or not is irrelevant to those definitions.
> +#

I guess this is an oversight. This has nothing to do with generic and does 
not belong into mm/Kconfig

> +choice
> +	prompt "Kernel Page Size"
> +	depends on ARCH_GENERIC_PAGE_SIZE
> +config PAGE_SIZE_4KB
> +	bool "4KB"
> +	help
> +	  This lets you select the page size of the kernel.  For best 64-bit
> +	  performance, a page size of larger than 4k is recommended.  For best
> +	  32-bit compatibility on 64-bit architectures, a page size of 4KB
> +	  should be selected (although most binaries work perfectly fine with
> +	  a larger page size).
> +
> +	  4KB                For best 32-bit compatibility
> +	  8KB and up         For best performance
> +	  above 64k	     For kernel hackers only
> +
> +	  If you don't know what to do, choose 8KB (if available).
> +	  Otherwise, choose 4KB.

The above also would need to be genericized.

> +config PAGE_SIZE_8KB
> +	bool "8KB"
> +config PAGE_SIZE_16KB
> +	bool "16KB"
> +config PAGE_SIZE_64KB
> +	bool "64KB"
> +config PAGE_SIZE_512KB
> +	bool "512KB"
> +config PAGE_SIZE_4MB
> +	bool "4MB"
> +endchoice

But not all arches support this. Choices need to be restricted to what the 
arch supports. What about support for other pagesizes in the future. IA64 
could f.e.  support 128k and 256K pages sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
