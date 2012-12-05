Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 4580A6B0070
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 10:43:38 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2417867dak.14
        for <linux-mm@kvack.org>; Wed, 05 Dec 2012 07:43:37 -0800 (PST)
Message-ID: <50BF6BA0.8060505@gmail.com>
Date: Wed, 05 Dec 2012 23:43:28 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/5] page_alloc: Make movablecore_map has higher priority
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1353667445-7593-5-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

If we make "movablecore_map" take precedence over "movablecore/kernelcore",
the logic could be simplified. I think it's not so attractive to support
both "movablecore_map" and "movablecore/kernelcore" at the same time.

On 11/23/2012 06:44 PM, Tang Chen wrote:
> If kernelcore or movablecore is specified at the same time
> with movablecore_map, movablecore_map will have higher
> priority to be satisfied.
> This patch will make find_zone_movable_pfns_for_nodes()
> calculate zone_movable_pfn[] with the limit from
> zone_movable_limit[].
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
> Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  mm/page_alloc.c |   35 +++++++++++++++++++++++++++++++----
>  1 files changed, 31 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f23d76a..05bafbb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4800,12 +4800,25 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  		required_kernelcore = max(required_kernelcore, corepages);
>  	}
>  
> -	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
> -	if (!required_kernelcore)
> +	/*
> +	 * No matter kernelcore/movablecore was limited or not, movable_zone
> +	 * should always be set to a usable zone index.
> +	 */
> +	find_usable_zone_for_movable();
> +
> +	/*
> +	 * If neither kernelcore/movablecore nor movablecore_map is specified,
> +	 * there is no ZONE_MOVABLE. But if movablecore_map is specified, the
> +	 * start pfn of ZONE_MOVABLE has been stored in zone_movable_limit[].
> +	 */
> +	if (!required_kernelcore) {
> +		if (movablecore_map.nr_map)
> +			memcpy(zone_movable_pfn, zone_movable_limit,
> +				sizeof(zone_movable_pfn));
>  		goto out;
> +	}
>  
>  	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
> -	find_usable_zone_for_movable();
>  	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
>  
>  restart:
> @@ -4833,10 +4846,24 @@ restart:
>  		for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, NULL) {
>  			unsigned long size_pages;
>  
> +			/*
> +			 * Find more memory for kernelcore in
> +			 * [zone_movable_pfn[nid], zone_movable_limit[nid]).
> +			 */
>  			start_pfn = max(start_pfn, zone_movable_pfn[nid]);
>  			if (start_pfn >= end_pfn)
>  				continue;
>  
> +			if (zone_movable_limit[nid]) {
> +				end_pfn = min(end_pfn, zone_movable_limit[nid]);
> +				/* No range left for kernelcore in this node */
> +				if (start_pfn >= end_pfn) {
> +					zone_movable_pfn[nid] =
> +							zone_movable_limit[nid];
> +					break;
> +				}
> +			}
> +
>  			/* Account for what is only usable for kernelcore */
>  			if (start_pfn < usable_startpfn) {
>  				unsigned long kernel_pages;
> @@ -4896,12 +4923,12 @@ restart:
>  	if (usable_nodes && required_kernelcore > usable_nodes)
>  		goto restart;
>  
> +out:
>  	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
>  	for (nid = 0; nid < MAX_NUMNODES; nid++)
>  		zone_movable_pfn[nid] =
>  			roundup(zone_movable_pfn[nid], MAX_ORDER_NR_PAGES);
>  
> -out:
>  	/* restore the node_state */
>  	node_states[N_HIGH_MEMORY] = saved_node_state;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
