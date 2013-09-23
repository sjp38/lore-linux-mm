Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 776466B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:20:59 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so3766004pad.19
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:20:59 -0700 (PDT)
Received: by mail-ve0-f173.google.com with SMTP id cz12so2420986veb.18
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:50:31 -0700 (PDT)
Date: Mon, 23 Sep 2013 11:50:27 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/5] memblock: Improve memblock to support allocation
 from lower address.
Message-ID: <20130923155027.GD14547@htj.dyndns.org>
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
 <1379064655-20874-3-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1379064655-20874-3-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

Please separate out factoring out of top-down allocation.  That change
is an equivalent conversion which shouldn't involve any functional
difference.  Mixing that with introduction of new feature isn't a good
idea, so the patch split should be 1. split out top-down allocation
from memblock_find_in_range_node() 2. introduce bottom-up flag and
implement the feature.

On Fri, Sep 13, 2013 at 05:30:52PM +0800, Tang Chen wrote:
> +/**
>   * memblock_find_in_range_node - find free area in given range and node
> - * @start: start of candidate range
> + * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE

The only reason @end has special ACCESSIBLE flag is because we don't
know how high is actually accessible and it needs to be distinguished
from ANYWHERE.  We assume that the lower addresses are always mapped,
so using ACCESSIBLE for @start is weird.  I think it'd be clearer to
make the memblock interface to set the direction explicitly state what
it's doing - ie. something like set_memblock_alloc_above_kernel(bool
enable).  We clearly don't want pure bottom-up allocation and the
@start/@end params in memblock interface are used to impose extra
limitations for each allocation, not the overall allocator behavior.

> @@ -100,8 +180,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  					phys_addr_t end, phys_addr_t size,
>  					phys_addr_t align, int nid)
>  {
> -	phys_addr_t this_start, this_end, cand;
> -	u64 i;
> +	phys_addr_t ret;
>  
>  	/* pump up @end */
>  	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
> @@ -111,18 +190,22 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  	start = max_t(phys_addr_t, start, PAGE_SIZE);
>  	end = max(start, end);
>  
> -	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
> -		this_start = clamp(this_start, start, end);
> -		this_end = clamp(this_end, start, end);
> +	if (memblock_direction_bottom_up()) {
> +		/*
> +		 * MEMBLOCK_ALLOC_ACCESSIBLE is 0, which is less than the end
> +		 * of kernel image. So callers specify MEMBLOCK_ALLOC_ACCESSIBLE
> +		 * as @start is OK.
> +		 */
> +		start =	max(start, __pa_symbol(_end)); /* End of kernel image. */
>  
> -		if (this_end < size)
> -			continue;
> +		ret = __memblock_find_range(start, end, size, align, nid);
> +		if (ret)
> +			return ret;
>  
> -		cand = round_down(this_end - size, align);
> -		if (cand >= this_start)
> -			return cand;
> +		pr_warn("memblock: Failed to allocate memory in bottom up direction. Now try top down direction.\n");

You probably wanna explain why retrying top-down allocation may
succeed when bottom-up failed.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
