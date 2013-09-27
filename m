Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9B16B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 18:31:25 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so3186078pde.9
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 15:31:25 -0700 (PDT)
Message-ID: <1380320960.14046.48.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 2/6] memblock: Introduce bottom-up allocation mode
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 27 Sep 2013 16:29:20 -0600
In-Reply-To: <5241D9A4.4080305@gmail.com>
References: <5241D897.1090905@gmail.com> <5241D9A4.4080305@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, 2013-09-25 at 02:27 +0800, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> The Linux kernel cannot migrate pages used by the kernel. As a result, kernel
> pages cannot be hot-removed. So we cannot allocate hotpluggable memory for
> the kernel.
> 
> ACPI SRAT (System Resource Affinity Table) contains the memory hotplug info.
> But before SRAT is parsed, memblock has already started to allocate memory
> for the kernel. So we need to prevent memblock from doing this.
> 
> In a memory hotplug system, any numa node the kernel resides in should
> be unhotpluggable. And for a modern server, each node could have at least
> 16GB memory. So memory around the kernel image is highly likely unhotpluggable.
> 
> So the basic idea is: Allocate memory from the end of the kernel image and
> to the higher memory. Since memory allocation before SRAT is parsed won't
> be too much, it could highly likely be in the same node with kernel image.
> 
> The current memblock can only allocate memory top-down. So this patch introduces
> a new bottom-up allocation mode to allocate memory bottom-up. And later
> when we use this allocation direction to allocate memory, we will limit
> the start address above the kernel.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

 :

>  /**
> + * __memblock_find_range - find free area utility
> + * @start: start of candidate range
> + * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
> + * @size: size of free area to find
> + * @align: alignment of free area to find
> + * @nid: nid of the free area to find, %MAX_NUMNODES for any node
> + *
> + * Utility called from memblock_find_in_range_node(), find free area bottom-up.
> + *
> + * RETURNS:
> + * Found address on success, 0 on failure.
> + */
> +static phys_addr_t __init_memblock
> +__memblock_find_range(phys_addr_t start, phys_addr_t end, phys_addr_t size,

Similarly, how about name this function as
__memblock_find_range_bottom_up()?


> +		      phys_addr_t align, int nid)
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
> +
> +	return 0;
> +}
> +
> +/**
>   * __memblock_find_range_rev - find free area utility, in reverse order
>   * @start: start of candidate range
>   * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
> @@ -93,7 +128,7 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
>   * Utility called from memblock_find_in_range_node(), find free area top-down.
>   *
>   * RETURNS:
> - * Found address on success, %0 on failure.
> + * Found address on success, 0 on failure.
>   */
>  static phys_addr_t __init_memblock
>  __memblock_find_range_rev(phys_addr_t start, phys_addr_t end,
> @@ -127,13 +162,24 @@ __memblock_find_range_rev(phys_addr_t start, phys_addr_t end,
>   *
>   * Find @size free area aligned to @align in the specified range and node.
>   *
> + * When allocation direction is bottom-up, the @start should be greater
> + * than the end of the kernel image. Otherwise, it will be trimmed. The
> + * reason is that we want the bottom-up allocation just near the kernel
> + * image so it is highly likely that the allocated memory and the kernel
> + * will reside in the same node.
> + *
> + * If bottom-up allocation failed, will try to allocate memory top-down.
> + *
>   * RETURNS:
> - * Found address on success, %0 on failure.
> + * Found address on success, 0 on failure.
>   */
>  phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  					phys_addr_t end, phys_addr_t size,
>  					phys_addr_t align, int nid)
>  {
> +	int ret;
> +	phys_addr_t kernel_end;
> +
>  	/* pump up @end */
>  	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
>  		end = memblock.current_limit;
> @@ -141,6 +187,37 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  	/* avoid allocating the first page */
>  	start = max_t(phys_addr_t, start, PAGE_SIZE);
>  	end = max(start, end);
> +	kernel_end = __pa_symbol(_end);

Please address the issue in __pa_symbol() that Andrew pointed out.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
