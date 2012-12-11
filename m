Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A141E6B002B
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 22:08:36 -0500 (EST)
Message-ID: <50C6A36C.5030606@huawei.com>
Date: Tue, 11 Dec 2012 11:07:24 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/5] page_alloc: Introduce zone_movable_limit[] to
 keep movable limit for nodes
References: <1355193207-21797-1-git-send-email-tangchen@cn.fujitsu.com> <1355193207-21797-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1355193207-21797-4-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: jiang.liu@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 2012/12/11 10:33, Tang Chen wrote:

> This patch introduces a new array zone_movable_limit[] to store the
> ZONE_MOVABLE limit from movablecore_map boot option for all nodes.
> The function sanitize_zone_movable_limit() will find out to which
> node the ranges in movable_map.map[] belongs, and calculates the
> low boundary of ZONE_MOVABLE for each node.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
> Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  mm/page_alloc.c |   77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 77 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1c91d16..4853619 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -206,6 +206,7 @@ static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
>  static unsigned long __initdata required_kernelcore;
>  static unsigned long __initdata required_movablecore;
>  static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
> +static unsigned long __meminitdata zone_movable_limit[MAX_NUMNODES];
>  
>  /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
>  int movable_zone;
> @@ -4340,6 +4341,77 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
>  	return __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
>  }
>  
> +/**
> + * sanitize_zone_movable_limit - Sanitize the zone_movable_limit array.
> + *
> + * zone_movable_limit is initialized as 0. This function will try to get
> + * the first ZONE_MOVABLE pfn of each node from movablecore_map, and
> + * assigne them to zone_movable_limit.
> + * zone_movable_limit[nid] == 0 means no limit for the node.
> + *
> + * Note: Each range is represented as [start_pfn, end_pfn)
> + */
> +static void __meminit sanitize_zone_movable_limit(void)
> +{
> +	int map_pos = 0, i, nid;
> +	unsigned long start_pfn, end_pfn;
> +
> +	if (!movablecore_map.nr_map)
> +		return;
> +
> +	/* Iterate all ranges from minimum to maximum */
> +	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
> +		/*
> +		 * If we have found lowest pfn of ZONE_MOVABLE of the node
> +		 * specified by user, just go on to check next range.
> +		 */
> +		if (zone_movable_limit[nid])
> +			continue;
> +
> +#ifdef CONFIG_ZONE_DMA
> +		/* Skip DMA memory. */
> +		if (start_pfn < arch_zone_highest_possible_pfn[ZONE_DMA])
> +			start_pfn = arch_zone_highest_possible_pfn[ZONE_DMA];
> +#endif
> +
> +#ifdef CONFIG_ZONE_DMA32
> +		/* Skip DMA32 memory. */
> +		if (start_pfn < arch_zone_highest_possible_pfn[ZONE_DMA32])
> +			start_pfn = arch_zone_highest_possible_pfn[ZONE_DMA32];
> +#endif
> +
> +#ifdef CONFIG_HIGHMEM
> +		/* Skip lowmem if ZONE_MOVABLE is highmem. */
> +		if (zone_movable_is_highmem() &&

Hi Tang,

I think zone_movable_is_highmem() is not work correctly here.
	sanitize_zone_movable_limit
		zone_movable_is_highmem      <--using movable_zone here
	find_zone_movable_pfns_for_nodes
		find_usable_zone_for_movable <--movable_zone is specified here

I think Jiang Liu's patch works fine for highmem, please refer to:
http://marc.info/?l=linux-mm&m=135476085816087&w=2

Thanks,
Jianguo Wu

> +		    start_pfn < arch_zone_lowest_possible_pfn[ZONE_HIGHMEM])
> +			start_pfn = arch_zone_lowest_possible_pfn[ZONE_HIGHMEM];
> +#endif
> +
> +		if (start_pfn >= end_pfn)
> +			continue;
> +
> +		while (map_pos < movablecore_map.nr_map) {
> +			if (end_pfn <= movablecore_map.map[map_pos].start_pfn)
> +				break;
> +
> +			if (start_pfn >= movablecore_map.map[map_pos].end_pfn) {
> +				map_pos++;
> +				continue;
> +			}
> +
> +			/*
> +			 * The start_pfn of ZONE_MOVABLE is either the minimum
> +			 * pfn specified by movablecore_map, or 0, which means
> +			 * the node has no ZONE_MOVABLE.
> +			 */
> +			zone_movable_limit[nid] = max(start_pfn,
> +					movablecore_map.map[map_pos].start_pfn);
> +
> +			break;
> +		}
> +	}
> +}
> +
>  #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>  static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
>  					unsigned long zone_type,
> @@ -4358,6 +4430,10 @@ static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
>  	return zholes_size[zone_type];
>  }
>  
> +static void __meminit sanitize_zone_movable_limit(void)
> +{
> +}
> +
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>  
>  static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
> @@ -4923,6 +4999,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  
>  	/* Find the PFNs that ZONE_MOVABLE begins at in each node */
>  	memset(zone_movable_pfn, 0, sizeof(zone_movable_pfn));
> +	sanitize_zone_movable_limit();
>  	find_zone_movable_pfns_for_nodes();
>  
>  	/* Print out the zone ranges */



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
