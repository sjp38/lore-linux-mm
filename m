Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 502FE6B0036
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 18:26:04 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so3333754pab.38
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 15:26:03 -0700 (PDT)
Message-ID: <1380320637.14046.44.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 1/6] memblock: Factor out of top-down allocation
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 27 Sep 2013 16:23:57 -0600
In-Reply-To: <5241D90D.6030203@gmail.com>
References: <5241D897.1090905@gmail.com> <5241D90D.6030203@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, 2013-09-25 at 02:25 +0800, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> This patch creates a new function __memblock_find_range_rev
> to factor out of top-down allocation from memblock_find_in_range_node.
> This is a preparation because we will introduce a new bottom-up
> allocation mode in the following patch.
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Acked-by: Toshi Kani <toshi.kani@hp.com>

A minor comment below...

> ---
>  mm/memblock.c |   47 ++++++++++++++++++++++++++++++++++-------------
>  1 files changed, 34 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 0ac412a..3d80c74 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -83,33 +83,25 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
>  }
>  
>  /**
> - * memblock_find_in_range_node - find free area in given range and node
> + * __memblock_find_range_rev - find free area utility, in reverse order
>   * @start: start of candidate range
>   * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
>   * @size: size of free area to find
>   * @align: alignment of free area to find
>   * @nid: nid of the free area to find, %MAX_NUMNODES for any node
>   *
> - * Find @size free area aligned to @align in the specified range and node.
> + * Utility called from memblock_find_in_range_node(), find free area top-down.
>   *
>   * RETURNS:
>   * Found address on success, %0 on failure.
>   */
> -phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
> -					phys_addr_t end, phys_addr_t size,
> -					phys_addr_t align, int nid)
> +static phys_addr_t __init_memblock
> +__memblock_find_range_rev(phys_addr_t start, phys_addr_t end,

Since we are now using the terms "top down" and "bottom up"
consistently, how about name this function as
__memblock_find_range_top_down()? 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
