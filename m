Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l0JF7TcR195438
	for <linux-mm@kvack.org>; Sat, 20 Jan 2007 02:07:29 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0JEufRC123292
	for <linux-mm@kvack.org>; Sat, 20 Jan 2007 01:56:41 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0JErCah018404
	for <linux-mm@kvack.org>; Sat, 20 Jan 2007 01:53:12 +1100
Message-ID: <45B0DB45.4070004@linux.vnet.ibm.com>
Date: Fri, 19 Jan 2007 20:22:53 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>
In-Reply-To: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>
List-ID: <linux-mm.kvack.org>


Aubrey Li wrote:
> Here is the newest patch against 2.6.20-rc5.
> ======================================================
> From ad9ca9a32bdcaddce9988afbf0187bfd04685a0c Mon Sep 17 00:00:00 2001
> From: Aubrey.Li <aubreylee@gmail.com>
> Date: Thu, 18 Jan 2007 11:08:31 +0800
> Subject: [PATCH] Add an interface to limit total vfs page cache.
> The default percent is using 90% memory for page cache.
> 
> Signed-off-by: Aubrey.Li <aubreylee@gmail.com>
> ---
>  include/linux/gfp.h     |    1 +
>  include/linux/pagemap.h |    2 +-
>  include/linux/sysctl.h  |    2 ++
>  kernel/sysctl.c         |   11 +++++++++++
>  mm/page_alloc.c         |   17 +++++++++++++++--
>  5 files changed, 30 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 00c314a..531360e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -46,6 +46,7 @@ struct vm_area_struct;
>  #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use
> emergency reserves */
>  #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce
> hardwall cpuset memory allocs */
>  #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
> +#define __GFP_PAGECACHE	((__force gfp_t)0x80000u) /* Is page cache
> allocation ? */
> 
>  #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index c3e255b..890bb23 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -62,7 +62,7 @@ static inline struct page *__page_cache_
> 
>  static inline struct page *page_cache_alloc(struct address_space *x)
>  {
> -	return __page_cache_alloc(mapping_gfp_mask(x));
> +	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_PAGECACHE);
>  }
> 
>  static inline struct page *page_cache_alloc_cold(struct address_space *x)
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 81480e6..d3c9174 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -202,6 +202,7 @@ enum
>  	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
>  	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
>  	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
> +	VM_PAGECACHE_RATIO=36,	/* percent of RAM to use as page cache */
>  };
> 
> 
> @@ -955,6 +956,7 @@ extern ctl_handler sysctl_string;
>  extern ctl_handler sysctl_intvec;
>  extern ctl_handler sysctl_jiffies;
>  extern ctl_handler sysctl_ms_jiffies;
> +extern int sysctl_pagecache_ratio;
> 
> 
>  /*
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 600b333..92db115 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1035,6 +1035,17 @@ static ctl_table vm_table[] = {
>  		.extra1		= &zero,
>  	},
>  #endif
> +	{
> +		.ctl_name	= VM_PAGECACHE_RATIO,
> +		.procname	= "pagecache_ratio",
> +		.data		= &sysctl_pagecache_ratio,
> +		.maxlen		= sizeof(sysctl_pagecache_ratio),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec_minmax,
> +		.strategy	= &sysctl_intvec,
> +		.extra1         = &zero,
> +                .extra2         = &one_hundred,
> +	},
>  	{ .ctl_name = 0 }
>  };
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fc5b544..5802b39 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -82,6 +82,8 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
>  #endif
>  };
> 
> +int sysctl_pagecache_ratio = 10;
> +
>  EXPORT_SYMBOL(totalram_pages);
> 
>  static char * const zone_names[MAX_NR_ZONES] = {
> @@ -895,6 +897,7 @@ failed:
>  #define ALLOC_HARDER		0x10 /* try to alloc harder */
>  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
>  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> +#define ALLOC_PAGECACHE		0x80 /* __GFP_PAGECACHE set */
> 
>  #ifdef CONFIG_FAIL_PAGE_ALLOC
> 
> @@ -998,6 +1001,9 @@ int zone_watermark_ok(struct zone *z, in
>  	if (alloc_flags & ALLOC_HARDER)
>  		min -= min / 4;
> 
> +	if (alloc_flags & ALLOC_PAGECACHE)
> +		min = min + (sysctl_pagecache_ratio * z->present_pages) / 100;
> +
>  	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
>  		return 0;

Hi Aubrey,

The idea of creating separate flag for pagecache in page_alloc is
interesting.  The good part is that you flag watermark low and the
zone reclaimer will do the rest of the job.

However when the zone reclaimer starts to reclaim pages, it will
remove all cold pages and not specifically pagecache pages.  This
may affect performance of applications.

One possible solution to this reclaim is to use scan control fields
and ask the shrink_page_list() and shrink_active_list() routines to
target only pagecache pages.  Pagecache pages are not mapped and
they are easy to find on the LRU list.

Please review my patch at http://lkml.org/lkml/2007/01/17/96

--Vaidy

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
