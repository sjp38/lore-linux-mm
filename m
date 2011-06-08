Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A2F976B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 15:56:38 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p58JQCes005428
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 15:26:12 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p58JuatM050162
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 15:56:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p58JuaCk003239
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 15:56:36 -0400
Date: Wed, 8 Jun 2011 12:56:35 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Add debugging boundary check to pfn_to_page
Message-ID: <20110608195635.GI2324@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1307560734-3915-1-git-send-email-emunson@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307560734-3915-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: arnd@arndb.de, akpm@linux-foundation.org, mingo@elte.hu, randy.dunlap@oracle.com, josh@joshtriplett.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, mgorman@suse.de, linux-mm@kvack.org

On Wed, Jun 08, 2011 at 03:18:54PM -0400, Eric B Munson wrote:
> Bugzilla 36192 showed a problem where pages were being accessed outside of
> a node boundary.  It would be helpful in diagnosing this kind of problem to
> have pfn_to_page complain when a page is accessed outside of the node boundary.
> This patch adds a new debug config option which adds a WARN_ON in pfn_to_page
> that will complain when pages are accessed outside of the node boundary.
> 
> Signed-of-by: Eric B Munson <emunson@mgebm.net>
> ---
>  include/asm-generic/memory_model.h |   19 +++++++++++++++----
>  lib/Kconfig.debug                  |   10 ++++++++++
>  2 files changed, 25 insertions(+), 4 deletions(-)
> 
> diff --git a/include/asm-generic/memory_model.h b/include/asm-generic/memory_model.h
> index fb2d63f..a0f1d19 100644
> --- a/include/asm-generic/memory_model.h
> +++ b/include/asm-generic/memory_model.h
> @@ -62,11 +62,22 @@
>  	(unsigned long)(__pg - __section_mem_map_addr(__nr_to_section(__sec)));	\
>  })
> 
> -#define __pfn_to_page(pfn)				\
> -({	unsigned long __pfn = (pfn);			\
> -	struct mem_section *__sec = __pfn_to_section(__pfn);	\
> -	__section_mem_map_addr(__sec) + __pfn;		\
> +#ifdef CONFIG_DEBUG_MEMORY_MODEL
> +#define __pfn_to_page(pfn)						\
> +({	unsigned long __pfn = (pfn);					\
> +	struct mem_section *__sec = __pfn_to_section(__pfn);		\
> +	struct page *__page = __section_mem_map_addr(__sec) + __pfn;	\
> +	WARN_ON(__page->flags == 0);					\
> +	__page;								\
>  })
> +#else
> +#define __pfn_to_page(pfn)						\
> +({	unsigned long __pfn = (pfn);					\
> +	struct mem_section *__sec = __pfn_to_section(__pfn);		\
> +	__section_mem_map_addr(__sec) + __pfn;	\
> +})
> +#endif /* CONFIG_DEBUG_MEMORY_MODEL */
> +

The following variant would avoid the duplicate code, FWIW.

#define __pfn_to_page_nodebug(pfn)					\
({	unsigned long __pfn = (pfn);					\
	struct mem_section *__sec = __pfn_to_section(__pfn);		\
	__section_mem_map_addr(__sec) + __pfn;				\
})
#ifdef CONFIG_DEBUG_MEMORY_MODEL
#define __pfn_to_page(pfn)						\
({									\
	struct page *__page = __pfn_to_page_nodebug(pfn);		\
	WARN_ON(__page->flags == 0);					\
	__page;								\
})
#else
#define __pfn_to_page(pfn) __pfn_to_page_nodebug(pfn)
#endif /* CONFIG_DEBUG_MEMORY_MODEL */

							Thanx, Paul

>  #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
> 
>  #define page_to_pfn __page_to_pfn
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index dd373c8..d932cbf 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -777,6 +777,16 @@ config DEBUG_MEMORY_INIT
> 
>  	  If unsure, say Y
> 
> +config DEBUG_MEMORY_MODEL
> +	bool "Debug memory model" if SPARSEMEM || DISCONTIGMEM
> +	depends on SPARSEMEM || DISCONTIGMEM
> +	help
> +	  Enable this to check that page accesses are done within node
> +	  boundaries.  The check will warn each time a page is requested
> +	  outside node boundaries.
> +
> +	  If unsure, say N
> +
>  config DEBUG_LIST
>  	bool "Debug linked list manipulation"
>  	depends on DEBUG_KERNEL
> -- 
> 1.7.4.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
