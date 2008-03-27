Date: Thu, 27 Mar 2008 09:32:01 -0500
From: Dean Nelson <dcn@sgi.com>
Subject: Re: page flags: Handle PG_uncached like all other flags
Message-ID: <20080327143201.GA854@sgi.com>
References: <Pine.LNX.4.64.0803261920130.2183@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803261920130.2183@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, Mar 26, 2008 at 07:21:40PM -0700, Christoph Lameter wrote:
> Remove the special setup for PG_uncached and simply make it part of the enum.
> The page flag will only be allocated when the kernel build includes the uncached
> allocator.
> 
> Cc: Dean Nelson <dcn@sgi.com>
> Cc: Jes Sorensen <jes@trained-monkey.org>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: Dean Nelson <dcn@sgi.com>

> ---
>  include/linux/page-flags.h |   19 ++++++++-----------
>  1 file changed, 8 insertions(+), 11 deletions(-)
> 
> Index: linux-2.6.25-rc5-mm1/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/include/linux/page-flags.h	2008-03-25 21:22:16.312931059 -0700
> +++ linux-2.6.25-rc5-mm1/include/linux/page-flags.h	2008-03-25 21:22:53.466668675 -0700
> @@ -99,16 +99,8 @@ enum pageflags {
>  	 * read ahead needs to be done.
>  	 */
>  	PG_buddy,		/* Page is free, on buddy lists */
> -
> -#if (BITS_PER_LONG > 32)
> -/*
> - * 64-bit-only flags build down from bit 31
> - *
> - * 32 bit  -------------------------------| FIELDS |       FLAGS         |
> - * 64 bit  |           FIELDS             | ??????         FLAGS         |
> - *         63                            32                              0
> - */
> -	PG_uncached = 31,		/* Page has been mapped as uncached */
> +#ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
> +	PG_uncached,		/* Page has been mapped as uncached */
>  #endif
>  	__NR_PAGEFLAGS
>  };
> @@ -205,8 +197,13 @@ static inline int PageSwapCache(struct p
>  }
>  #endif
>  
> -#if (BITS_PER_LONG > 32)
> +#ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
>  PAGEFLAG(Uncached, uncached)
> +#else
> +static inline int PageUncached(struct page *)
> +{
> +	return 0;
> +}
>  #endif
>  
>  static inline int PageUptodate(struct page *page)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
