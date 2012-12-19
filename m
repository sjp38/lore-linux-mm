Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 4B28D6B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 04:18:39 -0500 (EST)
Message-ID: <50D18631.5050707@cn.fujitsu.com>
Date: Wed, 19 Dec 2012 17:17:37 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] page_alloc: Bootmem limit with movablecore_map
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-6-git-send-email-tangchen@cn.fujitsu.com> <50B36354.7040501@gmail.com>
In-Reply-To: <50B36354.7040501@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wujianguo <wujianguo106@gmail.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, wujianguo@huawei.com, qiuxishi@huawei.com

Hi Wu,

Sorry for such a long delay.

On 11/26/2012 08:40 PM, wujianguo wrote:
> Hi Tang,
> 	I tested this patchset in x86_64, and I found that this patch didn't
> work as expected.
> 	For example, if node2's memory pfn range is [0x680000-0x980000),
> I boot kernel with movablecore_map=4G@0x680000000, all memory in node2 will be
> in ZONE_MOVABLE, but bootmem still can be allocated from [0x780000000-0x980000000),
> that means bootmem *is allocated* from ZONE_MOVABLE. This because movablecore_map
> only contains [0x680000000-0x780000000). I think we can fixup movablecore_map, how
> about this:
>
> Signed-off-by: Jianguo Wu<wujianguo@huawei.com>
> Signed-off-by: Jiang Liu<jiang.liu@huawei.com>
> ---
>   arch/x86/mm/srat.c |   15 +++++++++++++++
>   include/linux/mm.h |    3 +++
>   mm/page_alloc.c    |    2 +-
>   3 files changed, 19 insertions(+), 1 deletions(-)
>
> diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
> index 4ddf497..f1aac08 100644
> --- a/arch/x86/mm/srat.c
> +++ b/arch/x86/mm/srat.c
> @@ -147,6 +147,8 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>   {
>   	u64 start, end;
>   	int node, pxm;
> +	int i;
> +	unsigned long start_pfn, end_pfn;
>
>   	if (srat_disabled())
>   		return -1;
> @@ -181,6 +183,19 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>   	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]\n",
>   	       node, pxm,
>   	       (unsigned long long) start, (unsigned long long) end - 1);
> +
> +	start_pfn = PFN_DOWN(start);
> +	end_pfn = PFN_UP(end);

I think the logic here has some problems.

Let's assume the range here is [3G, 5G), and
movablecore_map.map[] is like: [1G, 2G), [3G, 4G), [7G,8G).

> +	for (i = 0; i<  movablecore_map.nr_map; i++) {
> +		if (end_pfn<= movablecore_map.map[i].start)
> +			break;

When i = 0, 5G > 1G, no break.

> +
> +		if (movablecore_map.map[i].end<  end_pfn) {
> +			insert_movablecore_map(movablecore_map.map[i].end,
> +						end_pfn);

2G < 5G, so insert [2G, 5G). It's incorrect.
We should insert [4G, 5G).

I got your idea, and I also add SRAT support. So I made a new patch to
do this. Please have a look if you like. :)

Thanks. :)

> +		}
> +	}
> +
>   	return 0;
>   }
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5a65251..7a23403 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1356,6 +1356,9 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn);
>   #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
>   #endif
>
> +extern void insert_movablecore_map(unsigned long start_pfn,
> +					  unsigned long end_pfn);
> +
>   extern void set_dma_reserve(unsigned long new_dma_reserve);
>   extern void memmap_init_zone(unsigned long, int, unsigned long,
>   				unsigned long, enum memmap_context);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 544c829..e6b5090 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5089,7 +5089,7 @@ early_param("movablecore", cmdline_parse_movablecore);
>    * This function will also merge the overlapped ranges, and sort the array
>    * by start_pfn in monotonic increasing order.
>    */
> -static void __init insert_movablecore_map(unsigned long start_pfn,
> +void __init insert_movablecore_map(unsigned long start_pfn,
>   					  unsigned long end_pfn)
>   {
>   	int pos, overlap;
> -- 1.7.6.1
> .
>
> Thanks,
> Jianguo Wu
>
> On 2012-11-23 18:44, Tang Chen wrote:
>> This patch make sure bootmem will not allocate memory from areas that
>> may be ZONE_MOVABLE. The map info is from movablecore_map boot option.
>>
>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>> Signed-off-by: Lai Jiangshan<laijs@cn.fujitsu.com>
>> Reviewed-by: Wen Congyang<wency@cn.fujitsu.com>
>> Tested-by: Lin Feng<linfeng@cn.fujitsu.com>
>> ---
>>   include/linux/memblock.h |    1 +
>>   mm/memblock.c            |   15 ++++++++++++++-
>>   2 files changed, 15 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>> index d452ee1..6e25597 100644
>> --- a/include/linux/memblock.h
>> +++ b/include/linux/memblock.h
>> @@ -42,6 +42,7 @@ struct memblock {
>>
>>   extern struct memblock memblock;
>>   extern int memblock_debug;
>> +extern struct movablecore_map movablecore_map;
>>
>>   #define memblock_dbg(fmt, ...) \
>>   	if (memblock_debug) printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 6259055..33b3b4d 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -101,6 +101,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>>   {
>>   	phys_addr_t this_start, this_end, cand;
>>   	u64 i;
>> +	int curr = movablecore_map.nr_map - 1;
>>
>>   	/* pump up @end */
>>   	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
>> @@ -114,13 +115,25 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>>   		this_start = clamp(this_start, start, end);
>>   		this_end = clamp(this_end, start, end);
>>
>> -		if (this_end<  size)
>> +restart:
>> +		if (this_end<= this_start || this_end<  size)
>>   			continue;
>>
>> +		for (; curr>= 0; curr--) {
>> +			if (movablecore_map.map[curr].start<  this_end)
>> +				break;
>> +		}
>> +
>>   		cand = round_down(this_end - size, align);
>> +		if (curr>= 0&&  cand<  movablecore_map.map[curr].end) {
>> +			this_end = movablecore_map.map[curr].start;
>> +			goto restart;
>> +		}
>> +
>>   		if (cand>= this_start)
>>   			return cand;
>>   	}
>> +
>>   	return 0;
>>   }
>>
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
