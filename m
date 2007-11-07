Date: Wed, 7 Nov 2007 19:14:53 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [patch 2/2] x86_64: Configure stack size
Message-ID: <20071107191453.GC5080@shadowen.org>
References: <20071107004357.233417373@sgi.com> <20071107004710.862876902@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107004710.862876902@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 06, 2007 at 04:43:59PM -0800, clameter@sgi.com wrote:
> Make the stack size configurable necessary. SGI NUMA configurations may need
> more stack because cpumasks and nodemasks are at times kept on the stack.
> This patch allows to run with 16k or 32k kernel stacks.
> 
> Cc: ak@suse.de
> Cc: travis@sgi.com
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  arch/x86/Kconfig.x86_64          |    6 ++++++
>  include/asm-x86/page_64.h        |    3 +--
>  include/asm-x86/thread_info_64.h |    4 ++--
>  3 files changed, 9 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/arch/x86/Kconfig.x86_64
> ===================================================================
> --- linux-2.6.orig/arch/x86/Kconfig.x86_64	2007-11-06 12:34:13.000000000 -0800
> +++ linux-2.6/arch/x86/Kconfig.x86_64	2007-11-06 15:44:36.000000000 -0800
> @@ -378,6 +378,12 @@ config NODES_SHIFT
>  	default "6"
>  	depends on NEED_MULTIPLE_NODES
>  
> +config THREAD_ORDER
> +	int "Kernel stack size (in page order)"
> +	default "1"
> +	help
> +	  Page order for the thread stack.
> +
>  # Dummy CONFIG option to select ACPI_NUMA from drivers/acpi/Kconfig.
>  
>  config X86_64_ACPI_NUMA
> Index: linux-2.6/include/asm-x86/page_64.h
> ===================================================================
> --- linux-2.6.orig/include/asm-x86/page_64.h	2007-10-17 13:35:53.000000000 -0700
> +++ linux-2.6/include/asm-x86/page_64.h	2007-11-06 15:44:36.000000000 -0800
> @@ -9,8 +9,7 @@
>  #define PAGE_MASK	(~(PAGE_SIZE-1))
>  #define PHYSICAL_PAGE_MASK	(~(PAGE_SIZE-1) & __PHYSICAL_MASK)
>  
> -#define THREAD_ORDER 1 
> -#define THREAD_SIZE  (PAGE_SIZE << THREAD_ORDER)
> +#define THREAD_SIZE  (PAGE_SIZE << CONFIG_THREAD_ORDER)
>  #define CURRENT_MASK (~(THREAD_SIZE-1))
>  
>  #define EXCEPTION_STACK_ORDER 0
> Index: linux-2.6/include/asm-x86/thread_info_64.h
> ===================================================================
> --- linux-2.6.orig/include/asm-x86/thread_info_64.h	2007-11-06 15:44:31.000000000 -0800
> +++ linux-2.6/include/asm-x86/thread_info_64.h	2007-11-06 15:44:36.000000000 -0800
> @@ -80,9 +80,9 @@ static inline struct thread_info *stack_
>  #endif
>  
>  #define alloc_thread_info(tsk) \
> -	((struct thread_info *) __get_free_pages(THREAD_FLAGS, THREAD_ORDER))
> +	((struct thread_info *) __get_free_pages(THREAD_FLAGS, CONFIG_THREAD_ORDER))
>  
> -#define free_thread_info(ti) free_pages((unsigned long) (ti), THREAD_ORDER)
> +#define free_thread_info(ti) free_pages((unsigned long) (ti), CONFIG_THREAD_ORDER)
>  
>  #else /* !__ASSEMBLY__ */

We seem to be growing two different mechanisms here for 32bit and 64bit.
This does seem a better option than that in 32bit CONFIG_4KSTACKS etc.
IMO when these two merge we should consolidate on this version.

Reviewed-by: Andy Whitcroft <apw@shadowen.org>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
