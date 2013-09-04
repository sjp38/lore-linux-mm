Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 0C4A76B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 20:25:57 -0400 (EDT)
Message-ID: <1378254257.10300.921.camel@misato.fc.hp.com>
Subject: Re: [PATCH 06/11] memblock: Improve memblock to support allocation
 from lower address.
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 03 Sep 2013 18:24:17 -0600
In-Reply-To: <1377596268-31552-7-git-send-email-tangchen@cn.fujitsu.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1377596268-31552-7-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Tue, 2013-08-27 at 17:37 +0800, Tang Chen wrote:
> This patch modifies the memblock_find_in_range_node() to support two
> different allocation orders. After this patch, memblock will check
> memblock.current_order, and decide in which order to allocate memory.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  mm/memblock.c |   90 +++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 75 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 8f1e2d4..961d4a5 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -85,6 +85,77 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
>  }
>  
>  /**
> + * __memblock_find_range - find free area utility
> + * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
> + * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
> + * @size: size of free area to find
> + * @align: alignment of free area to find
> + * @nid: nid of the free area to find, %MAX_NUMNODES for any node
> + *
> + * Utility called from memblock_find_in_range_node(), find free area from
> + * lower address to higher address.
> + *
> + * RETURNS:
> + * Found address on success, %0 on failure.
> + */
> +phys_addr_t __init_memblock
> +__memblock_find_range(phys_addr_t start, phys_addr_t end,
> +		      phys_addr_t size, phys_addr_t align, int nid)

This func should be static as it must be an internal func.

> +{
> +	phys_addr_t this_start, this_end, cand;
> +	u64 i;
> +
> +	for_each_free_mem_range(i, nid, &this_start, &this_end, NULL) {
> +		this_start = clamp(this_start, start, end);
> +		this_end = clamp(this_end, start, end);
> +
> +		cand = round_up(this_start, align);
> +		if (cand < this_end && this_end - cand >= size)
> +			return cand;
> +	}
> +	return 0;
> +}
> +
> +/**
> + * __memblock_find_range_rev - find free area utility, in reverse order
> + * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
> + * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
> + * @size: size of free area to find
> + * @align: alignment of free area to find
> + * @nid: nid of the free area to find, %MAX_NUMNODES for any node
> + *
> + * Utility called from memblock_find_in_range_node(), find free area from
> + * higher address to lower address.
> + *
> + * RETURNS:
> + * Found address on success, %0 on failure.
> + */
> +phys_addr_t __init_memblock
> +__memblock_find_range_rev(phys_addr_t start, phys_addr_t end,
> +			  phys_addr_t size, phys_addr_t align, int nid)

Ditto.

> +{
> +	phys_addr_t this_start, this_end, cand;
> +	u64 i;
> +
> +	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
> +		this_start = clamp(this_start, start, end);
> +		this_end = clamp(this_end, start, end);
> +
> +		/*
> +		 * Just in case that (this_end - size) underflows and cause
> +		 * (cand >= this_start) to be true incorrectly.
> +		 */
> +		if (this_end < size)
> +			break;
> +
> +		cand = round_down(this_end - size, align);
> +		if (cand >= this_start)
> +			return cand;
> +	}
> +	return 0;
> +}
> +
> +/**
>   * memblock_find_in_range_node - find free area in given range and node
>   * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
>   * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
> @@ -110,9 +181,6 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  					phys_addr_t end, phys_addr_t size,
>  					phys_addr_t align, int nid)
>  {
> -	phys_addr_t this_start, this_end, cand;
> -	u64 i;
> -
>  	/* pump up @start and @end */
>  	if (start == MEMBLOCK_ALLOC_ACCESSIBLE)
>  		start = memblock.current_limit_low;
> @@ -123,18 +191,10 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  	start = max_t(phys_addr_t, start, PAGE_SIZE);
>  	end = max(start, end);
>  
> -	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
> -		this_start = clamp(this_start, start, end);
> -		this_end = clamp(this_end, start, end);
> -
> -		if (this_end < size)
> -			continue;
> -
> -		cand = round_down(this_end - size, align);
> -		if (cand >= this_start)
> -			return cand;
> -	}
> -	return 0;
> +	if (memblock.current_order == MEMBLOCK_ORDER_DEFAULT)

This needs to use MEMBLOCK_ORDER_HIGH_TO_LOW since the code should be
independent from the value of MEMBLOCK_ORDER_DEFAULT.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
