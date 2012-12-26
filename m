Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id F315E6B002B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 03:33:46 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4A1DB3EE0BD
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 17:33:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 313AD45DE83
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 17:33:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1458945DE69
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 17:33:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 07D75E08003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 17:33:45 +0900 (JST)
Received: from G01JPEXCHKW21.g01.fujitsu.local (G01JPEXCHKW21.g01.fujitsu.local [10.0.193.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B66C01DB8037
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 17:33:44 +0900 (JST)
Message-ID: <50DAB640.8000800@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 17:33:04 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3/6] ACPI: Restructure movablecore_map with memory
 info from SRAT.
References: <1355904903-22699-4-git-send-email-tangchen@cn.fujitsu.com> <1355908308-24744-1-git-send-email-tangchen@cn.fujitsu.com> <50DA9ED5.4000501@jp.fujitsu.com> <50DAA9C4.1040804@cn.fujitsu.com>
In-Reply-To: <50DAA9C4.1040804@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Tang,

2012/12/26 16:39, Tang Chen wrote:
> On 12/26/2012 02:53 PM, Yasuaki Ishimatsu wrote:
>> Hi Tang,
>>
>> I don't think it can work well.
>> The patch gets memory range of hotpluggable memory by
>> acpi_numa_memory_affinity_init(). But it too late.
>> For example, if we use log_buf_len boot options, memblock allocator
>> runs before getting SRAT information. In this case, this movablecore_map
>> boot option does not work well.
>>
> 
> Hi Ishimatsu-san,
> 
> Yes, you are right. After finish_e820_parsing() in setup_arch(),
> memblock allocator could start to work. So we need to reserve
> the hotpluggable memory before it. But SRAT parsing is far behind.
> So for now, I didn't work out a suitable way to do this.
> 
> I think we need to move ACPI table parsing logic before memblock is
> ready. But we need to solve how to allocate memory for ACPI table
> parsing logic.
> 
> I'll try to figure out a way and start a discussion soon.

There are two discussion parts:
 - interface
   Interface part is how to specify memory range.
 - core
   Core part is how to allocate movable memory.

I think using SRAT information is long term development. So at first,
we should develop boot option. In this case, core part should be
implemented to usable from both ways, boot option  and firmware information.

Fortunately, I think that current implementation of core part can deal
with both ways.

Thanks,
Yasuaki Ishimatsu




> 
> Thanks. :)
> 
>> Thanks,
>> Yasuaki Ishimatsu
>>
>> 2012/12/19 18:11, Tang Chen wrote:
>>> The Hot Plugable bit in SRAT flags specifys if the memory range
>>> could be hotplugged.
>>>
>>> If user specified movablecore_map=nn[KMG]@ss[KMG], reset
>>> movablecore_map.map to the intersection of hotpluggable ranges from
>>> SRAT and old movablecore_map.map.
>>> Else if user specified movablecore_map=acpi, just use the hotpluggable
>>> ranges from SRAT.
>>> Otherwise, do nothing. The kernel will use all the memory in all nodes
>>> evenly.
>>>
>>> The idea "getting info from SRAT" was from Liu Jiang<jiang.liu@huawei.com>.
>>> And the idea "do more limit for memblock" was from Wu Jianguo<wujianguo@huawei.com>
>>>
>>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>>> Tested-by: Gu Zheng<guz.fnst@cn.fujitsu.com>
>>> ---
>>>     arch/x86/mm/srat.c |   55 +++++++++++++++++++++++++++++++++++++++++++++++++--
>>>     1 files changed, 52 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
>>> index 4ddf497..a8856d2 100644
>>> --- a/arch/x86/mm/srat.c
>>> +++ b/arch/x86/mm/srat.c
>>> @@ -146,7 +146,12 @@ int __init
>>>     acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>>>     {
>>>     	u64 start, end;
>>> +	u32 hotpluggable;
>>>     	int node, pxm;
>>> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>>> +	int overlap;
>>> +	unsigned long start_pfn, end_pfn;
>>> +#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>>
>>>     	if (srat_disabled())
>>>     		return -1;
>>> @@ -157,8 +162,10 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>>>     	if ((ma->flags&  ACPI_SRAT_MEM_ENABLED) == 0)
>>>     		return -1;
>>>
>>> -	if ((ma->flags&  ACPI_SRAT_MEM_HOT_PLUGGABLE)&&  !save_add_info())
>>> +	hotpluggable = ma->flags&  ACPI_SRAT_MEM_HOT_PLUGGABLE;
>>> +	if (hotpluggable&&  !save_add_info())
>>>     		return -1;
>>> +
>>>     	start = ma->base_address;
>>>     	end = start + ma->length;
>>>     	pxm = ma->proximity_domain;
>>> @@ -178,9 +185,51 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>>>
>>>     	node_set(node, numa_nodes_parsed);
>>>
>>> -	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]\n",
>>> +	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
>>>     	       node, pxm,
>>> -	       (unsigned long long) start, (unsigned long long) end - 1);
>>> +	       (unsigned long long) start, (unsigned long long) end - 1,
>>> +	       hotpluggable ? "Hot Pluggable": "");
>>> +
>>> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>>> +	start_pfn = PFN_DOWN(start);
>>> +	end_pfn = PFN_UP(end);
>>> +
>>> +	if (!hotpluggable) {
>>> +		/* Clear the range overlapped in movablecore_map.map */
>>> +		remove_movablecore_map(start_pfn, end_pfn);
>>> +		goto out;
>>> +	}
>>> +
>>> +	if (!movablecore_map.acpi) {
>>> +		for (overlap = 0; overlap<  movablecore_map.nr_map; overlap++) {
>>> +			if (start_pfn<  movablecore_map.map[overlap].end_pfn)
>>> +				break;
>>> +		}
>>> +
>>> +		/*
>>> +		 * If there is no overlapped range, or the end of the overlapped
>>> +		 * range is higher than end_pfn, then insert nothing.
>>> +		 */
>>> +		if (end_pfn<= movablecore_map.map[overlap].end_pfn)
>>> +			goto out;
>>> +
>>> +		/*
>>> +		 * Otherwise, insert the rest of this range to prevent memblock
>>> +		 * from allocating memory in it.
>>> +		 */
>>> +		start_pfn = movablecore_map.map[overlap].end_pfn;
>>> +		start = start_pfn>>  PAGE_SHIFT;
>>> +	}
>>> +
>>> +	/* If user chose to use SRAT info, insert the range anyway. */
>>> +	if (insert_movablecore_map(start_pfn, end_pfn))
>>> +		pr_err("movablecore_map: too many entries;"
>>> +			" ignoring [mem %#010llx-%#010llx]\n",
>>> +			(unsigned long long) start,
>>> +			(unsigned long long) (end - 1));
>>> +
>>> +out:
>>> +#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>>     	return 0;
>>>     }
>>>
>>>
>>
>>
>>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
