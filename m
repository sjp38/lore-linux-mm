Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id EEFD06B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 20:39:00 -0400 (EDT)
Message-ID: <1378255041.10300.931.camel@misato.fc.hp.com>
Subject: Re: [PATCH 07/11] x86, memblock: Set lowest limit for
 memblock_alloc_base_nid().
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 03 Sep 2013 18:37:21 -0600
In-Reply-To: <1377596268-31552-8-git-send-email-tangchen@cn.fujitsu.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1377596268-31552-8-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Tue, 2013-08-27 at 17:37 +0800, Tang Chen wrote:
> memblock_alloc_base_nid() is a common API of memblock. And it calls
> memblock_find_in_range_node() with %start = 0, which means it has no
> limit for the lowest address by default.
> 
> 	memblock_find_in_range_node(0, max_addr, size, align, nid);
> 
> Since we introduced current_limit_low to memblock, if we have no limit
> for the lowest address or we are not sure, we should pass
> MEMBLOCK_ALLOC_ACCESSIBLE to %start so that it will be limited by the
> default low limit.
> 
> dma_contiguous_reserve() and setup_log_buf() will eventually call
> memblock_alloc_base_nid() to allocate memory. So if the allocation order
> is from low to high, they will allocate memory from the lowest limit
> to higher memory.

This requires the callers to use MEMBLOCK_ALLOC_ACCESSIBLE instead of 0.
Is there a good way to make sure that all callers will follow this rule
going forward?  Perhaps, memblock_find_in_range_node() should emit some
message if 0 is passed when current_order is low to high and the boot
option is specified?

Similarly, I wonder if we should have a check to the allocation size to
make sure that all allocations will stay small in this case.

Thanks,
-Toshi


> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  mm/memblock.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 961d4a5..be8c4d1 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -851,7 +851,8 @@ static phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
>  	/* align @size to avoid excessive fragmentation on reserved array */
>  	size = round_up(size, align);
>  
> -	found = memblock_find_in_range_node(0, max_addr, size, align, nid);
> +	found = memblock_find_in_range_node(MEMBLOCK_ALLOC_ACCESSIBLE,
> +					    max_addr, size, align, nid);
>  	if (found && !memblock_reserve(found, size))
>  		return found;
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
