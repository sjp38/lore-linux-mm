Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 9F1096B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 22:46:08 -0400 (EDT)
Message-ID: <5233CD2A.3010504@huawei.com>
Date: Sat, 14 Sep 2013 10:42:50 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/5] memblock: Introduce allocation direction to memblock.
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com> <1379064655-20874-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1379064655-20874-2-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Tang,

On 2013/9/13 17:30, Tang Chen wrote:

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
> The current memblock can only allocate memory from high address to low.
> So this patch introduces the allocation direct to memblock. It could be
> used to tell memblock to allocate memory from high to low or from low
> to high.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  include/linux/memblock.h |   22 ++++++++++++++++++++++
>  mm/memblock.c            |   13 +++++++++++++
>  2 files changed, 35 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 31e95ac..a7d3436 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -19,6 +19,11 @@
>  
>  #define INIT_MEMBLOCK_REGIONS	128
>  
> +/* Allocation order. */

s/order/direction/

> +#define MEMBLOCK_DIRECTION_HIGH_TO_LOW	0
> +#define MEMBLOCK_DIRECTION_LOW_TO_HIGH	1
> +#define MEMBLOCK_DIRECTION_DEFAULT	MEMBLOCK_DIRECTION_HIGH_TO_LOW
> +
>  struct memblock_region {
>  	phys_addr_t base;
>  	phys_addr_t size;
> @@ -35,6 +40,7 @@ struct memblock_type {
>  };
>  
>  struct memblock {
> +	int current_direction;      /* allocate from higher or lower address */
>  	phys_addr_t current_limit;
>  	struct memblock_type memory;
>  	struct memblock_type reserved;
> @@ -148,6 +154,12 @@ phys_addr_t memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
>  
>  phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align);
>  
> +static inline bool memblock_direction_bottom_up(void)
> +{
> +	return memblock.current_direction == MEMBLOCK_DIRECTION_LOW_TO_HIGH;
> +}
> +
> +
>  /* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
>  #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
>  #define MEMBLOCK_ALLOC_ACCESSIBLE	0
> @@ -175,6 +187,16 @@ static inline void memblock_dump_all(void)
>  }
>  
>  /**
> + * memblock_set_current_direction - Set current allocation direction to allow
> + *                                  allocating memory from higher to lower
> + *                                  address or from lower to higher address
> + *
> + * @direction: In which order to allocate memory. Could be

s/order/direction/

> + *             MEMBLOCK_DIRECTION_{HIGH_TO_LOW|LOW_TO_HIGH}
> + */
> +void memblock_set_current_direction(int direction);
> +
> +/**
>   * memblock_set_current_limit - Set the current allocation limit to allow
>   *                         limiting allocations to what is currently
>   *                         accessible during boot
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 0ac412a..f24ca2e 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -32,6 +32,7 @@ struct memblock memblock __initdata_memblock = {
>  	.reserved.cnt		= 1,	/* empty dummy entry */
>  	.reserved.max		= INIT_MEMBLOCK_REGIONS,
>  
> +	.current_direction	= MEMBLOCK_DIRECTION_DEFAULT,
>  	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
>  };
>  
> @@ -995,6 +996,18 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
>  	}
>  }
>  
> +void __init_memblock memblock_set_current_direction(int direction)
> +{
> +	if (direction != MEMBLOCK_DIRECTION_HIGH_TO_LOW &&
> +	    direction != MEMBLOCK_DIRECTION_LOW_TO_HIGH) {
> +		pr_warn("memblock: Failed to set allocation order. "
> +			"Invalid order type: %d\n", direction);

s/order/direction/

> +		return;
> +	}
> +
> +	memblock.current_direction = direction;
> +}
> +
>  void __init_memblock memblock_set_current_limit(phys_addr_t limit)
>  {
>  	memblock.current_limit = limit;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
