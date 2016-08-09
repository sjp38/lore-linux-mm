Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77DDD6B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 08:30:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so21779341pfd.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 05:30:24 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id tf1si42567053pab.230.2016.08.09.05.30.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 05:30:23 -0700 (PDT)
Message-ID: <57A9CB06.5010201@huawei.com>
Date: Tue, 9 Aug 2016 20:22:30 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: optimize find_zone_movable_pfns_for_nodes to avoid
 unnecessary loop.
References: <1470405847-53322-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1470405847-53322-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, mgorman@techsingularity.net, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 2016/8/5 22:04, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> when required_kernelcore decrease to zero, we should exit the loop in time.
> because It will waste time to scan the remainder node.
>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/page_alloc.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ea759b9..be7df17 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6093,7 +6093,7 @@ static unsigned long __init early_calculate_totalpages(void)
>  		unsigned long pages = end_pfn - start_pfn;
>  
>  		totalpages += pages;
> -		if (pages)
> +		if (!node_isset(nid, node_states[N_MEMORY]) && pages)
>  			node_set_state(nid, N_MEMORY);
>  	}
>  	return totalpages;
> @@ -6115,6 +6115,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  	unsigned long totalpages = early_calculate_totalpages();
>  	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
>  	struct memblock_region *r;
> +	bool avoid_loop = false;
>  
>  	/* Need to find movable_zone earlier when movable_node is specified. */
>  	find_usable_zone_for_movable();
> @@ -6275,6 +6276,8 @@ restart:
>  			required_kernelcore -= min(required_kernelcore,
>  								size_pages);
>  			kernelcore_remaining -= size_pages;
> +			if (!required_kernelcore && avoid_loop)
> +				goto out2;
>  			if (!kernelcore_remaining)
>  				break;
>  		}
> @@ -6287,9 +6290,10 @@ restart:
>  	 * satisfied
>  	 */
>  	usable_nodes--;
> -	if (usable_nodes && required_kernelcore > usable_nodes)
> +	if (usable_nodes && required_kernelcore > usable_nodes) {
> +		avoid_loop = true;
>  		goto restart;
> -
> +	}
>  out2:
>  	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
>  	for (nid = 0; nid < MAX_NUMNODES; nid++)
  Any one have any objection about above patch ? please let me know.
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
