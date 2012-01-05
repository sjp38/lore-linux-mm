Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id BFF826B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 02:01:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 581733EE0C0
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:01:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 32B4445DEF3
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:01:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0531F45DEEE
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:01:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E003F1DB8044
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:01:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 89DA71DB803C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:01:10 +0900 (JST)
Date: Thu, 5 Jan 2012 15:59:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3.2.0-rc1 2/3] MM hook for page allocation and release
Message-Id: <20120105155950.9e49651b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
	<e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Wed,  4 Jan 2012 19:21:55 +0200
Leonid Moiseichuk <leonid.moiseichuk@nokia.com> wrote:

> That is required by Used Memory Meter (UMM) pseudo-device
> to track memory utilization in system. It is expected that
> hook MUST be very light to prevent performance impact
> on the hot allocation path. Accuracy of number managed pages
> does not expected to be absolute but fact of allocation or
> deallocation must be registered.
> 
> Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

I never like arbitrary hooks to alloc_pages().
Could you find another way ?

Hmm. memcg uses per-cpu counters for counting event of alloc/free and
trigger threashold check per 128 event on a cpu.


Thanks,
-Kame


> ---
>  include/linux/mm.h |   15 +++++++++++++++
>  mm/Kconfig         |    8 ++++++++
>  mm/page_alloc.c    |   31 +++++++++++++++++++++++++++++++
>  3 files changed, 54 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 3dc3a8c..d133f73 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1618,6 +1618,21 @@ extern int soft_offline_page(struct page *page, int flags);
>  
>  extern void dump_page(struct page *page);
>  
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +/*
> + * Hook function type which called when some pages allocated or released.
> + * Value of nr_pages is positive for post-allocation calls and negative
> + * after free.
> + */
> +typedef void (*mm_alloc_free_hook_t)(int nr_pages);
> +
> +/*
> + * Setups specified hook function for tracking pages allocation.
> + * Returns value of old hook to organize chains of calls if necessary.
> + */
> +mm_alloc_free_hook_t set_mm_alloc_free_hook(mm_alloc_free_hook_t hook);
> +#endif
> +
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
>  extern void clear_huge_page(struct page *page,
>  			    unsigned long addr,
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 011b110..2aaa1e9 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -373,3 +373,11 @@ config CLEANCACHE
>  	  in a negligible performance hit.
>  
>  	  If unsure, say Y to enable cleancache
> +
> +config MM_ALLOC_FREE_HOOK
> +	bool "Enable callback support for pages allocation and releasing"
> +	default n
> +	help
> +	  Required for some features like used memory meter.
> +	  If unsure, say N to disable alloc/free hook.
> +
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..9307800 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -236,6 +236,30 @@ static void set_pageblock_migratetype(struct page *page, int migratetype)
>  
>  bool oom_killer_disabled __read_mostly;
>  
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +static atomic_long_t alloc_free_hook __read_mostly = ATOMIC_LONG_INIT(0);
> +
> +mm_alloc_free_hook_t set_mm_alloc_free_hook(mm_alloc_free_hook_t hook)
> +{
> +	const mm_alloc_free_hook_t old_hook =
> +		(mm_alloc_free_hook_t)atomic_long_read(&alloc_free_hook);
> +
> +	atomic_long_set(&alloc_free_hook, (long)hook);
> +	pr_info("MM alloc/free hook set to 0x%p (was 0x%p)\n", hook, old_hook);
> +
> +	return old_hook;
> +}
> +EXPORT_SYMBOL(set_mm_alloc_free_hook);
> +
> +static inline void call_alloc_free_hook(int pages)
> +{
> +	const mm_alloc_free_hook_t hook =
> +		(mm_alloc_free_hook_t)atomic_long_read(&alloc_free_hook);
> +	if (hook)
> +		hook(pages);
> +}
> +#endif
> +
>  #ifdef CONFIG_DEBUG_VM
>  static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
>  {
> @@ -2298,6 +2322,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	put_mems_allowed();
>  
>  	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +	call_alloc_free_hook(1 << order);
> +#endif
> +
>  	return page;
>  }
>  EXPORT_SYMBOL(__alloc_pages_nodemask);
> @@ -2345,6 +2373,9 @@ void __free_pages(struct page *page, unsigned int order)
>  			free_hot_cold_page(page, 0);
>  		else
>  			__free_pages_ok(page, order);
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +		call_alloc_free_hook(-(1 << order));
> +#endif
>  	}
>  }
>  
> -- 
> 1.7.7.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
