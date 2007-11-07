Date: Wed, 7 Nov 2007 19:11:02 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [patch 1/2] x86_64: Clean up stack allocation and free
Message-ID: <20071107191102.GB5080@shadowen.org>
References: <20071107004357.233417373@sgi.com> <20071107004710.642423857@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107004710.642423857@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 06, 2007 at 04:43:58PM -0800, clameter@sgi.com wrote:
> Cleanup the allocation and freeing of stacks a bit by using a __GFP_ZERO
> flag instead of memset.
> 
> Cc: ak@suse.de
> Cc: travis@sgi.com
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/asm-x86/thread_info_64.h |   16 +++++-----------
>  1 file changed, 5 insertions(+), 11 deletions(-)
> 
> Index: linux-2.6/include/asm-x86/thread_info_64.h
> ===================================================================
> --- linux-2.6.orig/include/asm-x86/thread_info_64.h	2007-10-12 12:41:32.000000000 -0700
> +++ linux-2.6/include/asm-x86/thread_info_64.h	2007-11-06 15:38:22.000000000 -0800
> @@ -74,20 +74,14 @@ static inline struct thread_info *stack_
>  
>  /* thread information allocation */
>  #ifdef CONFIG_DEBUG_STACK_USAGE
> -#define alloc_thread_info(tsk)					\
> -    ({								\
> -	struct thread_info *ret;				\
> -								\
> -	ret = ((struct thread_info *) __get_free_pages(GFP_KERNEL,THREAD_ORDER)); \
> -	if (ret)						\
> -		memset(ret, 0, THREAD_SIZE);			\
> -	ret;							\
> -    })
> +#define THREAD_FLAGS (GFP_KERNEL | __GFP_ZERO)
>  #else
> -#define alloc_thread_info(tsk) \
> -	((struct thread_info *) __get_free_pages(GFP_KERNEL,THREAD_ORDER))
> +#define THREAD_FLAGS GFP_KERNEL
>  #endif
>  
> +#define alloc_thread_info(tsk) \
> +	((struct thread_info *) __get_free_pages(THREAD_FLAGS, THREAD_ORDER))
> +
>  #define free_thread_info(ti) free_pages((unsigned long) (ti), THREAD_ORDER)
>  
>  #else /* !__ASSEMBLY__ */

This seems wholy reasonable.  And brings the code much closer to the x86
32bit version.

Reviewed-by: Andy Whitcroft <apw@shadowen.org>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
