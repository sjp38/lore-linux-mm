Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB516B0387
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 02:21:01 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id l19so182985162ywc.5
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 23:21:01 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id t25si12244309pgo.353.2017.02.13.23.20.59
        for <linux-mm@kvack.org>;
        Mon, 13 Feb 2017 23:21:00 -0800 (PST)
Subject: Re: [PATCH] mm: free reserved area's memmap if possiable
References: <1486987349-58711-1-git-send-email-zhouxianrong@huawei.com>
 <1487055180-128750-1-git-send-email-zhouxianrong@huawei.com>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <7c560d70-ac7f-dbb2-2ff2-7daa32c85c3a@huawei.com>
Date: Tue, 14 Feb 2017 15:18:44 +0800
MIME-Version: 1.0
In-Reply-To: <1487055180-128750-1-git-send-email-zhouxianrong@huawei.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, wangkefeng.wang@huawei.com, jszhang@marvell.com, gkulkarni@caviumnetworks.com, steve.capper@arm.com, chengang@emindsoft.com.cn, dennis.chen@arm.com, srikar@linux.vnet.ibm.com, kuleshovmail@gmail.com, zijun_hu@htc.com, tj@kernel.org, joe@perches.com, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

if the reserved area by user were so big which caused the memmap big,
and the reserved area's memamp did not be used by kernel, then user
could free the the reserved area's memamp by memblock_mark_raw_pfn
interface which is added by me.

On 2017/2/14 14:53, zhouxianrong@huawei.com wrote:
> From: zhouxianrong <zhouxianrong@huawei.com>
>
> just like freeing no-map area's memmap (gaps of memblock.memory)
> we could free reserved area's memmap (areas of memblock.reserved)
> as well only when user of reserved area indicate that we can do
> this in drivers. that is, user of reserved area know how to
> use the reserved area who could not memblock_free or free_reserved_xxx
> the reserved area and regard the area as raw pfn usage by kernel.
> the patch supply a way to users who want to utilize the memmap
> memory corresponding to raw pfn reserved areas as many as possible.
> users can do this by memblock_mark_raw_pfn interface which mark the
> reserved area as raw pfn and tell free_unused_memmap that this area's
> memmap could be freeed.
>
> Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
> ---
>  arch/arm64/mm/init.c     |   14 +++++++++++++-
>  include/linux/memblock.h |    3 +++
>  mm/memblock.c            |   24 ++++++++++++++++++++++++
>  3 files changed, 40 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 380ebe7..7e62ef8 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -358,7 +358,7 @@ static inline void free_memmap(unsigned long start_pfn, unsigned long end_pfn)
>   */
>  static void __init free_unused_memmap(void)
>  {
> -	unsigned long start, prev_end = 0;
> +	unsigned long start, end, prev_end = 0;
>  	struct memblock_region *reg;
>
>  	for_each_memblock(memory, reg) {
> @@ -391,6 +391,18 @@ static void __init free_unused_memmap(void)
>  	if (!IS_ALIGNED(prev_end, PAGES_PER_SECTION))
>  		free_memmap(prev_end, ALIGN(prev_end, PAGES_PER_SECTION));
>  #endif
> +
> +	for_each_memblock(reserved, reg) {
> +		if (!(reg->flags & MEMBLOCK_RAW_PFN))
> +			continue;
> +
> +		start = memblock_region_memory_base_pfn(reg);
> +		end = round_down(memblock_region_memory_end_pfn(reg),
> +				 MAX_ORDER_NR_PAGES);
> +
> +		if (start < end)
> +			free_memmap(start, end);
> +	}
>  }
>  #endif	/* !CONFIG_SPARSEMEM_VMEMMAP */
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 5b759c9..9f8d277 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -26,6 +26,7 @@ enum {
>  	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
>  	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
>  	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
> +	MEMBLOCK_RAW_PFN	= 0x8,	/* region whose memmap never be used */
>  };
>
>  struct memblock_region {
> @@ -92,6 +93,8 @@ bool memblock_overlaps_region(struct memblock_type *type,
>  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
> +int memblock_mark_raw_pfn(phys_addr_t base, phys_addr_t size);
> +int memblock_clear_raw_pfn(phys_addr_t base, phys_addr_t size);
>  ulong choose_memblock_flags(void);
>
>  /* Low level functions */
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7608bc3..c103b94 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -814,6 +814,30 @@ int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
>  }
>
>  /**
> + * memblock_mark_raw_pfn - Mark raw pfn memory with flag MEMBLOCK_RAW_PFN.
> + * @base: the base phys addr of the region
> + * @size: the size of the region
> + *
> + * Return 0 on succees, -errno on failure.
> + */
> +int __init_memblock memblock_mark_raw_pfn(phys_addr_t base, phys_addr_t size)
> +{
> +	return memblock_setclr_flag(base, size, 1, MEMBLOCK_RAW_PFN);
> +}
> +
> +/**
> + * memblock_clear_raw_pfn - Clear flag MEMBLOCK_RAW_PFN for a specified region.
> + * @base: the base phys addr of the region
> + * @size: the size of the region
> + *
> + * Return 0 on succees, -errno on failure.
> + */
> +int __init_memblock memblock_clear_raw_pfn(phys_addr_t base, phys_addr_t size)
> +{
> +	return memblock_setclr_flag(base, size, 0, MEMBLOCK_RAW_PFN);
> +}
> +
> +/**
>   * __next_reserved_mem_region - next function for for_each_reserved_region()
>   * @idx: pointer to u64 loop variable
>   * @out_start: ptr to phys_addr_t for start address of the region, can be %NULL
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
