Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0806B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:17:33 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so4540711pdi.33
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 05:17:32 -0700 (PDT)
Received: by mail-qa0-f43.google.com with SMTP id k15so2372067qaq.16
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 05:17:29 -0700 (PDT)
Date: Tue, 24 Sep 2013 08:17:25 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/6] memblock: Introduce bottom-up allocation mode
Message-ID: <20130924121725.GC2366@htj.dyndns.org>
References: <524162DA.30004@cn.fujitsu.com>
 <524163CF.3010303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524163CF.3010303@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On Tue, Sep 24, 2013 at 06:05:03PM +0800, Zhang Yanfei wrote:
> +/* Allocation direction */
> +enum {
> +	MEMBLOCK_DIRECTION_TOP_DOWN,
> +	MEMBLOCK_DIRECTION_BOTTOM_UP,
> +	NR_MEMLBOCK_DIRECTIONS
> +};
> +
>  struct memblock_region {
>  	phys_addr_t base;
>  	phys_addr_t size;
> @@ -35,6 +42,7 @@ struct memblock_type {
>  };
>  
>  struct memblock {
> +	int current_direction;  /* current allocation direction */

Just use boolean bottom_up here too?  No need for the constants.

> @@ -20,6 +20,8 @@
>  #include <linux/seq_file.h>
>  #include <linux/memblock.h>
>  
> +#include <asm-generic/sections.h>
> +

Why is the above added by this patch?

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
> + * Found address on success, %0 on failure.

I don't think we prefix numeric literals with %.

...
> @@ -127,6 +162,10 @@ __memblock_find_range_rev(phys_addr_t start, phys_addr_t end,
>   *
>   * Find @size free area aligned to @align in the specified range and node.
>   *
> + * When allocation direction is bottom-up, the @start should be greater
> + * than the end of the kernel image. Otherwise, it will be trimmed. And also,
> + * if bottom-up allocation failed, will try to allocate memory top-down.

It'd be nice to explain that bottom-up allocation is limited to above
kernel image and what it's used for here.

> + *
>   * RETURNS:
>   * Found address on success, %0 on failure.
>   */
> @@ -134,6 +173,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  					phys_addr_t end, phys_addr_t size,
>  					phys_addr_t align, int nid)
>  {
> +	int ret;
> +
>  	/* pump up @end */
>  	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
>  		end = memblock.current_limit;
> @@ -142,6 +183,28 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  	start = max_t(phys_addr_t, start, PAGE_SIZE);
>  	end = max(start, end);
>  
> +	if (memblock_bottom_up()) {
> +		phys_addr_t bottom_up_start;
> +
> +		/* make sure we will allocate above the kernel */
> +		bottom_up_start = max_t(phys_addr_t, start, __pa_symbol(_end));
> +
> +		/* ok, try bottom-up allocation first */
> +		ret = __memblock_find_range(bottom_up_start, end,
> +					    size, align, nid);
> +		if (ret)
> +			return ret;
> +
> +		/*
> +		 * we always limit bottom-up allocation above the kernel,
> +		 * but top-down allocation doesn't have the limit, so
> +		 * retrying top-down allocation may succeed when bottom-up
> +		 * allocation failed.
> +		 */
> +		pr_warn("memblock: Failed to allocate memory in bottom up "
> +			"direction. Now try top down direction.\n");

Maybe just print warning only on the first failure?

Otherwise, looks good to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
