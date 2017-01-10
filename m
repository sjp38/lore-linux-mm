Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35B896B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 23:00:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id z128so251726887pfb.4
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 20:00:35 -0800 (PST)
Received: from out0-135.mail.aliyun.com (out0-135.mail.aliyun.com. [140.205.0.135])
        by mx.google.com with ESMTP id z43si667709plh.253.2017.01.09.20.00.32
        for <linux-mm@kvack.org>;
        Mon, 09 Jan 2017 20:00:32 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170109163518.6001-1-mgorman@techsingularity.net> <20170109163518.6001-5-mgorman@techsingularity.net>
In-Reply-To: <20170109163518.6001-5-mgorman@techsingularity.net>
Subject: Re: [PATCH 4/4] mm, page_alloc: Add a bulk page allocator
Date: Tue, 10 Jan 2017 12:00:27 +0800
Message-ID: <01e001d26af6$146295f0$3d27c1d0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Jesper Dangaard Brouer' <brouer@redhat.com>
Cc: 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Tuesday, January 10, 2017 12:35 AM Mel Gorman wrote: 
> 
> This patch adds a new page allocator interface via alloc_pages_bulk,
> __alloc_pages_bulk and __alloc_pages_bulk_nodemask. A caller requests a
> number of pages to be allocated and added to a list. They can be freed in
> bulk using free_pages_bulk(). Note that it would theoretically be possible
> to use free_hot_cold_page_list for faster frees if the symbol was exported,
> the refcounts were 0 and the caller guaranteed it was not in an interrupt.
> This would be significantly faster in the free path but also more unsafer
> and a harder API to use.
> 
> The API is not guaranteed to return the requested number of pages and
> may fail if the preferred allocation zone has limited free memory, the
> cpuset changes during the allocation or page debugging decides to fail
> an allocation. It's up to the caller to request more pages in batch if
> necessary.
> 
> The following compares the allocation cost per page for different batch
> sizes. The baseline is allocating them one at a time and it compares with
> the performance when using the new allocation interface.
> 
> pagealloc
>                                           4.10.0-rc2                 4.10.0-rc2
>                                        one-at-a-time                    bulk-v2
> Amean    alloc-odr0-1               259.54 (  0.00%)           106.62 ( 58.92%)
> Amean    alloc-odr0-2               193.38 (  0.00%)            76.38 ( 60.50%)
> Amean    alloc-odr0-4               162.38 (  0.00%)            57.23 ( 64.76%)
> Amean    alloc-odr0-8               144.31 (  0.00%)            48.77 ( 66.20%)
> Amean    alloc-odr0-16              134.08 (  0.00%)            45.38 ( 66.15%)
> Amean    alloc-odr0-32              128.62 (  0.00%)            42.77 ( 66.75%)
> Amean    alloc-odr0-64              126.00 (  0.00%)            41.00 ( 67.46%)
> Amean    alloc-odr0-128             125.00 (  0.00%)            40.08 ( 67.94%)
> Amean    alloc-odr0-256             136.62 (  0.00%)            56.00 ( 59.01%)
> Amean    alloc-odr0-512             152.00 (  0.00%)            69.00 ( 54.61%)
> Amean    alloc-odr0-1024            158.00 (  0.00%)            76.23 ( 51.75%)
> Amean    alloc-odr0-2048            163.00 (  0.00%)            81.15 ( 50.21%)
> Amean    alloc-odr0-4096            169.77 (  0.00%)            85.92 ( 49.39%)
> Amean    alloc-odr0-8192            170.00 (  0.00%)            88.00 ( 48.24%)
> Amean    alloc-odr0-16384           170.00 (  0.00%)            89.00 ( 47.65%)
> Amean    free-odr0-1                 88.69 (  0.00%)            55.69 ( 37.21%)
> Amean    free-odr0-2                 66.00 (  0.00%)            49.38 ( 25.17%)
> Amean    free-odr0-4                 54.23 (  0.00%)            45.38 ( 16.31%)
> Amean    free-odr0-8                 48.23 (  0.00%)            44.23 (  8.29%)
> Amean    free-odr0-16                47.00 (  0.00%)            45.00 (  4.26%)
> Amean    free-odr0-32                44.77 (  0.00%)            43.92 (  1.89%)
> Amean    free-odr0-64                44.00 (  0.00%)            43.00 (  2.27%)
> Amean    free-odr0-128               43.00 (  0.00%)            43.00 (  0.00%)
> Amean    free-odr0-256               60.69 (  0.00%)            60.46 (  0.38%)
> Amean    free-odr0-512               79.23 (  0.00%)            76.00 (  4.08%)
> Amean    free-odr0-1024              86.00 (  0.00%)            85.38 (  0.72%)
> Amean    free-odr0-2048              91.00 (  0.00%)            91.23 ( -0.25%)
> Amean    free-odr0-4096              94.85 (  0.00%)            95.62 ( -0.81%)
> Amean    free-odr0-8192              97.00 (  0.00%)            97.00 (  0.00%)
> Amean    free-odr0-16384             98.00 (  0.00%)            97.46 (  0.55%)
> Amean    total-odr0-1               348.23 (  0.00%)           162.31 ( 53.39%)
> Amean    total-odr0-2               259.38 (  0.00%)           125.77 ( 51.51%)
> Amean    total-odr0-4               216.62 (  0.00%)           102.62 ( 52.63%)
> Amean    total-odr0-8               192.54 (  0.00%)            93.00 ( 51.70%)
> Amean    total-odr0-16              181.08 (  0.00%)            90.38 ( 50.08%)
> Amean    total-odr0-32              173.38 (  0.00%)            86.69 ( 50.00%)
> Amean    total-odr0-64              170.00 (  0.00%)            84.00 ( 50.59%)
> Amean    total-odr0-128             168.00 (  0.00%)            83.08 ( 50.55%)
> Amean    total-odr0-256             197.31 (  0.00%)           116.46 ( 40.97%)
> Amean    total-odr0-512             231.23 (  0.00%)           145.00 ( 37.29%)
> Amean    total-odr0-1024            244.00 (  0.00%)           161.62 ( 33.76%)
> Amean    total-odr0-2048            254.00 (  0.00%)           172.38 ( 32.13%)
> Amean    total-odr0-4096            264.62 (  0.00%)           181.54 ( 31.40%)
> Amean    total-odr0-8192            267.00 (  0.00%)           185.00 ( 30.71%)
> Amean    total-odr0-16384           268.00 (  0.00%)           186.46 ( 30.42%)
> 
> It shows a roughly 50-60% reduction in the cost of allocating pages.
> The free paths are not improved as much but relatively little can be batched
> there. It's not quite as fast as it could be but taking further shortcuts
> would require making a lot of assumptions about the state of the page and
> the context of the caller.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  include/linux/gfp.h |  24 +++++++++++
>  mm/page_alloc.c     | 116 +++++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 139 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4175dca4ac39..b2fe171ee1c4 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -433,6 +433,29 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
>  }
> 
> +unsigned long
> +__alloc_pages_bulk_nodemask(gfp_t gfp_mask, unsigned int order,
> +			struct zonelist *zonelist, nodemask_t *nodemask,
> +			unsigned long nr_pages, struct list_head *alloc_list);
> +
> +static inline unsigned long
> +__alloc_pages_bulk(gfp_t gfp_mask, unsigned int order,
> +		struct zonelist *zonelist, unsigned long nr_pages,
> +		struct list_head *list)
> +{
> +	return __alloc_pages_bulk_nodemask(gfp_mask, order, zonelist, NULL,
> +						nr_pages, list);
> +}
> +
> +static inline unsigned long
> +alloc_pages_bulk(gfp_t gfp_mask, unsigned int order,
> +		unsigned long nr_pages, struct list_head *list)
> +{
> +	int nid = numa_mem_id();
> +	return __alloc_pages_bulk(gfp_mask, order,
> +			node_zonelist(nid, gfp_mask), nr_pages, list);
> +}
> +
>  /*
>   * Allocate pages, preferring the node given as nid. The node must be valid and
>   * online. For more general interface, see alloc_pages_node().
> @@ -504,6 +527,7 @@ extern void __free_pages(struct page *page, unsigned int order);
>  extern void free_pages(unsigned long addr, unsigned int order);
>  extern void free_hot_cold_page(struct page *page, bool cold);
>  extern void free_hot_cold_page_list(struct list_head *list, bool cold);
> +extern void free_pages_bulk(struct list_head *list);
> 
>  struct page_frag_cache;
>  extern void __page_frag_drain(struct page *page, unsigned int order,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 232cadbe9231..4f142270fbf0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2485,7 +2485,7 @@ void free_hot_cold_page(struct page *page, bool cold)
>  }
> 
>  /*
> - * Free a list of 0-order pages
> + * Free a list of 0-order pages whose reference count is already zero.
>   */
>  void free_hot_cold_page_list(struct list_head *list, bool cold)
>  {
> @@ -2495,7 +2495,28 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
>  		trace_mm_page_free_batched(page, cold);
>  		free_hot_cold_page(page, cold);
>  	}
> +
> +	INIT_LIST_HEAD(list);

Nit: can we cut this overhead off?
> +}
> +
> +/* Drop reference counts and free pages from a list */
> +void free_pages_bulk(struct list_head *list)
> +{
> +	struct page *page, *next;
> +	bool free_percpu = !in_interrupt();
> +
> +	list_for_each_entry_safe(page, next, list, lru) {
> +		trace_mm_page_free_batched(page, 0);
> +		if (put_page_testzero(page)) {
> +			list_del(&page->lru);
> +			if (free_percpu)
> +				free_hot_cold_page(page, false);
> +			else
> +				__free_pages_ok(page, 0);
> +		}
> +	}
>  }
> +EXPORT_SYMBOL_GPL(free_pages_bulk);
> 
>  /*
>   * split_page takes a non-compound higher-order page, and splits it into
> @@ -3887,6 +3908,99 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  EXPORT_SYMBOL(__alloc_pages_nodemask);
> 
>  /*
> + * This is a batched version of the page allocator that attempts to
> + * allocate nr_pages quickly from the preferred zone and add them to list.
> + * Note that there is no guarantee that nr_pages will be allocated although
> + * every effort will be made to allocate at least one. Unlike the core
> + * allocator, no special effort is made to recover from transient
> + * failures caused by changes in cpusets. It should only be used from !IRQ
> + * context. An attempt to allocate a batch of patches from an interrupt
> + * will allocate a single page.
> + */
> +unsigned long
> +__alloc_pages_bulk_nodemask(gfp_t gfp_mask, unsigned int order,
> +			struct zonelist *zonelist, nodemask_t *nodemask,
> +			unsigned long nr_pages, struct list_head *alloc_list)
> +{
> +	struct page *page;
> +	unsigned long alloced = 0;
> +	unsigned int alloc_flags = ALLOC_WMARK_LOW;
> +	struct zone *zone;
> +	struct per_cpu_pages *pcp;
> +	struct list_head *pcp_list;
> +	int migratetype;
> +	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
> +	struct alloc_context ac = { };
> +	bool cold = ((gfp_mask & __GFP_COLD) != 0);
> +
> +	/* If there are already pages on the list, don't bother */
> +	if (!list_empty(alloc_list))
> +		return 0;

Nit: can we move the check to the call site?
> +
> +	/* Only handle bulk allocation of order-0 */
> +	if (order || in_interrupt())
> +		goto failed;

Ditto

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
