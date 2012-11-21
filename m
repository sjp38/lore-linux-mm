Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id E6DCC6B0072
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 00:45:03 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BC42F3EE0BD
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:45:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 92EFF45DE5D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:45:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A1DD45DE54
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:45:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 15131E38003
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:45:01 +0900 (JST)
Received: from g01jpexchyt26.g01.fujitsu.local (g01jpexchyt26.g01.fujitsu.local [10.128.193.109])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ADCD11DB8047
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:45:00 +0900 (JST)
Message-ID: <50AC6A33.3050408@jp.fujitsu.com>
Date: Wed, 21 Nov 2012 14:44:19 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] page_alloc: Add movablecore_map boot option.
References: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com> <1353335246-9127-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1353335246-9127-3-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, rob@landley.net, akpm@linux-foundation.org, laijs@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, yinghai@kernel.org, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Tang,

The patch has two extra whitespaces.

2012/11/19 23:27, Tang Chen wrote:
> This patch adds functions to parse movablecore_map boot option. Since the
> option could be specified more then once, all the maps will be stored in
> the global variable movablecore_map.map array.
> 
> And also, we keep the array in monotonic increasing order by start_pfn.
> And merge all overlapped ranges.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
> Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>   Documentation/kernel-parameters.txt |   17 ++++
>   include/linux/mm.h                  |   11 +++
>   mm/page_alloc.c                     |  146 +++++++++++++++++++++++++++++++++++
>   3 files changed, 174 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 9776f06..0718976 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1620,6 +1620,23 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>   			that the amount of memory usable for all allocations
>   			is not too small.
>   
> +	movablecore_map=nn[KMG]@ss[KMG]
> +			[KNL,X86,IA-64,PPC] This parameter is similar to
> +			memmap except it specifies the memory map of
> +			ZONE_MOVABLE.
> +			If more areas are all within one node, then from
> +			lowest ss to the end of the node will be ZONE_MOVABLE.
> +			If an area covers two or more nodes, the area from
> +			ss to the end of the 1st node will be ZONE_MOVABLE,
> +			and all the rest nodes will only have ZONE_MOVABLE.
                                                                           ^ here
> +			If memmap is specified at the same time, the
> +			movablecore_map will be limited within the memmap
> +			areas. If kernelcore or movablecore is also specified,
> +			movablecore_map will have higher priority to be
> +			satisfied. So the administrator should be careful that
> +			the amount of movablecore_map areas are not too large.
> +			Otherwise kernel won't have enough memory to start.
> +
>   	MTD_Partition=	[MTD]
>   			Format: <name>,<region-number>,<size>,<offset>
>   
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index fa06804..e4541b4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1328,6 +1328,17 @@ extern void free_bootmem_with_active_regions(int nid,
>   						unsigned long max_low_pfn);
>   extern void sparse_memory_present_with_active_regions(int nid);
>   
> +#define MOVABLECORE_MAP_MAX MAX_NUMNODES
> +struct movablecore_entry {
> +	unsigned long start;    /* start pfn of memory segment */
> +	unsigned long end;      /* end pfn of memory segment */
> +};
> +
> +struct movablecore_map {
> +	__u32 nr_map;
> +	struct movablecore_entry map[MOVABLECORE_MAP_MAX];
> +};
> +
>   #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>   
>   #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b74de6..198106f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -198,6 +198,9 @@ static unsigned long __meminitdata nr_all_pages;
>   static unsigned long __meminitdata dma_reserve;
>   
>   #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +/* Movable memory segments, will also be used by memblock subsystem. */
> +struct movablecore_map movablecore_map;
> +
>   static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
>   static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
>   static unsigned long __initdata required_kernelcore;
> @@ -4986,6 +4989,149 @@ static int __init cmdline_parse_movablecore(char *p)
>   early_param("kernelcore", cmdline_parse_kernelcore);
>   early_param("movablecore", cmdline_parse_movablecore);
>   
> +/**
> + * insert_movablecore_map - Insert a memory range in to movablecore_map.map.
> + * @start_pfn: start pfn of the range
> + * @end_pfn: end pfn of the range
> + *
> + * This function will also merge the overlapped ranges, and sort the array
> + * by start_pfn in monotonic increasing order.
> + */
> +static void __init insert_movablecore_map(unsigned long start_pfn,
> +					  unsigned long end_pfn)
> +{
> +	int i, pos_start, pos_end, remove;
> +	bool merge = true;
> +
> +	if (!movablecore_map.nr_map) {
> +		movablecore_map.map[0].start = start_pfn;
> +		movablecore_map.map[0].end = end_pfn;
> +		movablecore_map.nr_map++;
> +		return;
> +	}
> +
> +	/*
> +	 * pos_start at the 1st overlapped segment if merge_start is true,
> +	 * or at the next unoverlapped segment if merge_start is false.
> +	 */
> +	for (pos_start = 0; pos_start < movablecore_map.nr_map; pos_start++)
> +		if (start_pfn <= movablecore_map.map[pos_start].end) {
> +			if (end_pfn < movablecore_map.map[pos_start].start)
> +				merge = false;
> +			break;
> +		}
> +
> +	/*
> +	 * pos_end at the last overlapped segment if merge_end is true,
> +	 * or at the next unoverlapped segment if merge_start is false.
> +	 */
> +	for (pos_end = pos_start; pos_end < movablecore_map.nr_map; pos_end++) {
> +		if (end_pfn < movablecore_map.map[pos_end].start) {
> +			if (pos_end > 0 && start_pfn > movablecore_map.map[pos_end-1].end)
> +				merge = false;
> +			else
> +				pos_end--;
> +			break;
> +		}
> +	}
> +	if (pos_end == movablecore_map.nr_map && merge)
> +		pos_end--;
> +
> +	if (pos_start == movablecore_map.nr_map)
> +		merge = false;
> +
> +	if (merge) {
> +		remove = pos_end - pos_start;
> +
> +		movablecore_map.map[pos_start].start =
> +			min(start_pfn, movablecore_map.map[pos_start].start);
> +		movablecore_map.map[pos_start].end =
                                                    ^ here

Thanks,
Yasuaki Ishimatsu

> +			max(end_pfn, movablecore_map.map[pos_end].end);
> +
> +		if (remove == 0)
> +			goto out;
> +
> +		for (i = pos_start+1; i < movablecore_map.nr_map; i++) {
> +			movablecore_map.map[i].start =
> +					movablecore_map.map[i+remove].start;
> +			movablecore_map.map[i].end =
> +					movablecore_map.map[i+remove].end;
> +		}
> +
> +		movablecore_map.nr_map -= remove;
> +	} else {
> +		for (i = movablecore_map.nr_map; i > pos_start; i--) {
> +			movablecore_map.map[i].start =
> +					movablecore_map.map[i-1].start;
> +			movablecore_map.map[i].end =
> +					movablecore_map.map[i-1].end;
> +		}
> +
> +		movablecore_map.map[pos_start].start = start_pfn;
> +		movablecore_map.map[pos_start].end = end_pfn;
> +		movablecore_map.nr_map++;
> +	}
> +}
> +
> +/**
> + * movablecore_map_add_region - Add a memory range into movablecore_map.
> + * @start: physical start address of range
> + * @end: physical end address of range
> + *
> + * This function transform the physical address into pfn, and then add the
> + * range into movablecore_map by calling insert_movablecore_map().
> + */
> +static void __init movablecore_map_add_region(u64 start, u64 size)
> +{
> +	unsigned long start_pfn, end_pfn;
> +
> +	if (start + size <= start)
> +		return;
> +
> +	if (movablecore_map.nr_map >= ARRAY_SIZE(movablecore_map.map)) {
> +		pr_err("movable_memory_map: too many entries;"
> +			" ignoring [mem %#010llx-%#010llx]\n",
> +			(unsigned long long) start,
> +			(unsigned long long) (start + size - 1));
> +		return;
> +	}
> +
> +	start_pfn = PFN_DOWN(start);
> +	end_pfn = PFN_UP(start + size);
> +	insert_movablecore_map(start_pfn, end_pfn);
> +}
> +
> +/*
> + * movablecore_map=nn[KMG]@ss[KMG] sets the region of memory to be used as
> + * movable memory.
> + */
> +static int __init cmdline_parse_movablecore_map(char *p)
> +{
> +	char *oldp;
> +	u64 start_at, mem_size;
> +
> +	if (!p)
> +		goto err;
> +
> +	oldp = p;
> +	mem_size = memparse(p, &p);
> +	if (p == oldp)
> +		goto err;
> +
> +	if (*p == '@') {
> +		oldp = p + 1;
> +		start_at = memparse(p+1, &p);
> +		if (p == oldp || *p != '\0')
> +			goto err;
> +
> +		movablecore_map_add_region(start_at, mem_size);
> +		return 0;
> +	}
> +err:
> +	return -EINVAL;
> +}
> +early_param("movablecore_map", cmdline_parse_movablecore_map);
> +
>   #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>   
>   /**
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
