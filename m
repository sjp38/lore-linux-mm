Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7866A6B0289
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 10:37:10 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so7532499wms.7
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 07:37:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o76si3066056wmi.60.2016.11.23.07.37.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 07:37:09 -0800 (PST)
Subject: Re: [RFC PATCH] mm: page_alloc: High-order per-cpu page allocator
References: <20161121155540.5327-1-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4a9cdec4-b514-e414-de86-fc99681889d8@suse.cz>
Date: Wed, 23 Nov 2016 16:37:06 +0100
MIME-Version: 1.0
In-Reply-To: <20161121155540.5327-1-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On 11/21/2016 04:55 PM, Mel Gorman wrote:

...

> hackbench was also tested with both socket and pipes and both processes
> and threads and the results are interesting in terms of how variability
> is imapcted
>
> 1-socket machine -- pipes and processes
>                         4.9.0-rc5             4.9.0-rc5
>                           vanilla        highmark-v1r12
> Amean    1      12.9637 (  0.00%)     12.9570 (  0.05%)
> Amean    3      13.4770 (  0.00%)     13.4447 (  0.24%)
> Amean    5      18.5333 (  0.00%)     19.0917 ( -3.01%)
> Amean    7      24.5690 (  0.00%)     26.1010 ( -6.24%)
> Amean    12     39.7990 (  0.00%)     40.6763 ( -2.20%)
> Amean    16     56.0520 (  0.00%)     58.2530 ( -3.93%)

Here, higher values are better or worse?

> Stddev   1       0.3847 (  0.00%)      0.3137 ( 18.45%)
> Stddev   3       0.2652 (  0.00%)      0.3697 (-39.41%)
> Stddev   5       0.5589 (  0.00%)      0.9438 (-68.88%)
> Stddev   7       0.5310 (  0.00%)      0.2699 ( 49.18%)
> Stddev   12      1.0780 (  0.00%)      0.3421 ( 68.26%)
> Stddev   16      2.1138 (  0.00%)      1.5677 ( 25.84%)
>
> It's not a universal win but the differences are within the noise. What
> is interesting is that for high thread counts that variability is much
> reduced -- the time when contention would be expected to be high. This
> is not consistent across all machines but it mostly applies.
>
> While pipes, sockets and threads were tested, they did not show anything
> else interesting.
>
> fsmark was tested with zero-sized files to continually allocate slab objects
> but didn't show any differences. This can be explained by the fact that the
> workload is only allocating and does not have mix of allocs/frees that would
> benefit from the caching. It was tested to ensure no major harm was done.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  include/linux/mmzone.h |  20 ++++++++-
>  mm/page_alloc.c        | 120 +++++++++++++++++++++++++++++--------------------
>  2 files changed, 90 insertions(+), 50 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 0f088f3a2fed..02eb24d90d70 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -255,6 +255,24 @@ enum zone_watermarks {
>  	NR_WMARK
>  };
>
> +/*
> + * One per migratetype for order-0 pages and one per high-order up to
> + * and including PAGE_ALLOC_COSTLY_ORDER. This may allow unmovable
> + * allocations to contaminate reclaimable pageblocks if high-order
> + * pages are heavily used.
> + */
> +#define NR_PCP_LISTS (MIGRATE_PCPTYPES + PAGE_ALLOC_COSTLY_ORDER + 1)

Should it be "- 1" instead of "+ 1"?

> +
> +static inline unsigned int pindex_to_order(unsigned int pindex)
> +{
> +	return pindex < MIGRATE_PCPTYPES ? 0 : pindex - MIGRATE_PCPTYPES + 1;
> +}
> +
> +static inline unsigned int order_to_pindex(int migratetype, unsigned int order)
> +{
> +	return (order == 0) ? migratetype : MIGRATE_PCPTYPES - 1 + order;

HereI think that "MIGRATE_PCPTYPES + order - 1" would be easier to 
understand as the array is for all migratetypes, but the order is shifted?

> @@ -1083,10 +1083,12 @@ static bool bulkfree_pcp_prepare(struct page *page)
>   * pinned" detection logic.
>   */
>  static void free_pcppages_bulk(struct zone *zone, int count,
> -					struct per_cpu_pages *pcp)
> +					struct per_cpu_pages *pcp,
> +					int migratetype)
>  {
> -	int migratetype = 0;
> -	int batch_free = 0;
> +	unsigned int pindex = 0;

Should pindex be initialized to migratetype to match the list below?

> +	struct list_head *list = &pcp->lists[migratetype];
> +	unsigned int nr_freed = 0;
>  	unsigned long nr_scanned;
>  	bool isolated_pageblocks;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
