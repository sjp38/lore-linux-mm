Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 01AB76B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:33:46 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so3645734pad.9
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 05:33:46 -0700 (PDT)
Received: by mail-yh0-f41.google.com with SMTP id f73so1923907yha.14
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 05:33:44 -0700 (PDT)
Date: Tue, 24 Sep 2013 08:33:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/6] x86/mem-hotplug: Support initialize page tables
 bottom up
Message-ID: <20130924123340.GE2366@htj.dyndns.org>
References: <524162DA.30004@cn.fujitsu.com>
 <5241649B.3090302@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5241649B.3090302@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

Hello,

On Tue, Sep 24, 2013 at 06:08:27PM +0800, Zhang Yanfei wrote:
> +#ifdef CONFIG_MOVABLE_NODE

You don't need the above ifdef.  The compiler will be able to cull the
code as long as memblock_bottom_up() is defined as constant
expression when !MOVABLE_NODE.

> +/**
> + * memory_map_bottom_up - Map [map_start, map_end) bottom up
> + * @map_start: start address of the target memory range
> + * @map_end: end address of the target memory range
> + *
> + * This function will setup direct mapping for memory range [map_start, map_end)
> + * in a heuristic way. In the beginning, step_size is small. The more memory we
> + * map memory in the next loop.

The same comment as before.  Now we have two function with the
identical comment but behaving differently, which isn't nice.

...
> +	 * If the allocation is in bottom-up direction, we start from the
> +	 * bottom and go to the top: first [kernel_end, end) and then
> +	 * [ISA_END_ADDRESS, kernel_end). Otherwise, we start from the top
> +	 * (end of memory) and go to the bottom.
> +	 *
> +	 * The memblock_find_in_range() gets us a block of RAM in
> +	 * [min_pfn_mapped, max_pfn_mapped) used as new pages for page table.
>  	 */
> -	memory_map_top_down(ISA_END_ADDRESS, end);
> +	if (memblock_bottom_up()) {
> +		unsigned long kernel_end;
> +
> +		kernel_end = round_up(__pa_symbol(_end), PMD_SIZE);
> +		memory_map_bottom_up(kernel_end, end);
> +		memory_map_bottom_up(ISA_END_ADDRESS, kernel_end);

Hmm... so, this is kinda weird.  We're doing it in two chunks and
mapping memory between ISA_END_ADDRESS and kernel_end right on top of
ISA_END_ADDRESS?  Can't you give enough information to the mapping
function so that it can map everything on top of kernel_end in single
go?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
