Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E07E9900086
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 20:02:26 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3H02ORo028091
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 17:02:24 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by wpaz5.hot.corp.google.com with ESMTP id p3H02Nkb000368
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 17:02:23 -0700
Received: by pvc30 with SMTP id 30so1910049pvc.20
        for <linux-mm@kvack.org>; Sat, 16 Apr 2011 17:02:22 -0700 (PDT)
Date: Sat, 16 Apr 2011 17:02:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <20110415170437.17E1AF36@kernel>
Message-ID: <alpine.DEB.2.00.1104161653220.14788@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 15 Apr 2011, Dave Hansen wrote:

> 
> This originally started as a simple patch to give vmalloc()
> some more verbose output on failure on top of the plain
> page allocator messages.  Johannes suggested that it might
> be nicer to lead with the vmalloc() info _before_ the page
> allocator messages.
> 
> But, I do think there's a lot of value in what
> __alloc_pages_slowpath() does with its filtering and so
> forth.
> 
> This patch creates a new function which other allocators
> can call instead of relying on the internal page allocator
> warnings.  It also gives this function private rate-limiting
> which separates it from other printk_ratelimit() users.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/include/linux/mm.h |    2 +
>  linux-2.6.git-dave/mm/page_alloc.c    |   63 ++++++++++++++++++++++------------
>  2 files changed, 44 insertions(+), 21 deletions(-)
> 
> diff -puN include/linux/mm.h~break-out-alloc-failure-messages include/linux/mm.h
> --- linux-2.6.git/include/linux/mm.h~break-out-alloc-failure-messages	2011-04-15 08:44:06.911445625 -0700
> +++ linux-2.6.git-dave/include/linux/mm.h	2011-04-15 08:45:10.087416551 -0700
> @@ -1365,6 +1365,8 @@ extern void si_meminfo(struct sysinfo * 
>  extern void si_meminfo_node(struct sysinfo *val, int nid);
>  extern int after_bootmem;
>  
> +extern void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
> +
>  extern void setup_per_cpu_pageset(void);
>  
>  extern void zone_pcp_update(struct zone *zone);
> diff -puN mm/page_alloc.c~break-out-alloc-failure-messages mm/page_alloc.c
> --- linux-2.6.git/mm/page_alloc.c~break-out-alloc-failure-messages	2011-04-15 08:44:06.915445623 -0700
> +++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-15 08:48:34.255321834 -0700
> @@ -54,6 +54,7 @@
>  #include <trace/events/kmem.h>
>  #include <linux/ftrace_event.h>
>  #include <linux/memcontrol.h>
> +#include <linux/ratelimit.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -1734,6 +1735,46 @@ static inline bool should_suppress_show_
>  	return ret;
>  }
>  
> +static DEFINE_RATELIMIT_STATE(nopage_rs,
> +		DEFAULT_RATELIMIT_INTERVAL,
> +		DEFAULT_RATELIMIT_BURST);
> +
> +void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
> +{
> +	va_list args;
> +	unsigned int filter = SHOW_MEM_FILTER_NODES;
> +	const gfp_t wait = gfp_mask & __GFP_WAIT;
> +

"wait" is unnecessary.  You didn't do "const gfp_t nowarn = gfp_mask & 
__GFP_NOWARN;" for the same reason.

> +	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
> +		return;
> +
> +	/*
> +	 * This documents exceptions given to allocations in certain
> +	 * contexts that are allowed to allocate outside current's set
> +	 * of allowed nodes.
> +	 */
> +	if (!(gfp_mask & __GFP_NOMEMALLOC))
> +		if (test_thread_flag(TIF_MEMDIE) ||
> +		    (current->flags & (PF_MEMALLOC | PF_EXITING)))
> +			filter &= ~SHOW_MEM_FILTER_NODES;
> +	if (in_interrupt() || !wait)
> +		filter &= ~SHOW_MEM_FILTER_NODES;
> +
> +	if (fmt) {
> +		printk(KERN_WARNING);
> +		va_start(args, fmt);
> +		vprintk(fmt, args);
> +		va_end(args);
> +	}
> +
> +	printk(KERN_WARNING "%s: page allocation failure: order:%d, mode:0x%x\n",
> +			current->comm, order, gfp_mask);

pr_warning()?

current->comm should always be printed with get_task_comm() to avoid 
racing with /proc/pid/comm.  Since this function can be called potentially 
deep in the stack, you may need to serialize this with a 
statically-allocated buffer.

> +
> +	dump_stack();
> +	if (!should_suppress_show_mem())
> +		show_mem(filter);
> +}
> +
>  static inline int
>  should_alloc_retry(gfp_t gfp_mask, unsigned int order,
>  				unsigned long pages_reclaimed)
> @@ -2176,27 +2217,7 @@ rebalance:
>  	}
>  
>  nopage:
> -	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
> -		unsigned int filter = SHOW_MEM_FILTER_NODES;
> -
> -		/*
> -		 * This documents exceptions given to allocations in certain
> -		 * contexts that are allowed to allocate outside current's set
> -		 * of allowed nodes.
> -		 */
> -		if (!(gfp_mask & __GFP_NOMEMALLOC))
> -			if (test_thread_flag(TIF_MEMDIE) ||
> -			    (current->flags & (PF_MEMALLOC | PF_EXITING)))
> -				filter &= ~SHOW_MEM_FILTER_NODES;
> -		if (in_interrupt() || !wait)
> -			filter &= ~SHOW_MEM_FILTER_NODES;
> -
> -		pr_warning("%s: page allocation failure. order:%d, mode:0x%x\n",
> -			current->comm, order, gfp_mask);
> -		dump_stack();
> -		if (!should_suppress_show_mem())
> -			show_mem(filter);
> -	}
> +	warn_alloc_failed(gfp_mask, order, NULL);
>  	return page;
>  got_pg:
>  	if (kmemcheck_enabled)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
