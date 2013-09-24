Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 82FF46B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:21:14 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so4976213pad.14
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:21:14 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so4564903pbc.3
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:21:12 -0700 (PDT)
Message-ID: <52419198.1010906@gmail.com>
Date: Tue, 24 Sep 2013 21:20:24 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] x86/mm: Factor out of top-down direct mapping setup
References: <524162DA.30004@cn.fujitsu.com> <52416431.1090107@cn.fujitsu.com> <20130924122712.GD2366@htj.dyndns.org>
In-Reply-To: <20130924122712.GD2366@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

Hello tejun,

On 09/24/2013 08:27 PM, Tejun Heo wrote:
> On Tue, Sep 24, 2013 at 06:06:41PM +0800, Zhang Yanfei wrote:
>> +/**
>> + * memory_map_top_down - Map [map_start, map_end) top down
>> + * @map_start: start address of the target memory range
>> + * @map_end: end address of the target memory range
>> + *
>> + * This function will setup direct mapping for memory range [map_start, map_end)
>> + * in a heuristic way. In the beginning, step_size is small. The more memory we
>> + * map memory in the next loop.
>> + */
> 
> The comment reads a bit weird to me.  The step size is increased
> gradually but that really isn't really a heuristic and it doesn't
> mention mapping direction.

Ok, will change the words and add the comment of direction.

> 
> ...
>> @@ -430,19 +430,13 @@ void __init init_mem_mapping(void)
>>  	min_pfn_mapped = real_end >> PAGE_SHIFT;
>>  	last_start = start = real_end;
>>  
>> -	/*
>> -	 * We start from the top (end of memory) and go to the bottom.
>> -	 * The memblock_find_in_range() gets us a block of RAM from the
>> -	 * end of RAM in [min_pfn_mapped, max_pfn_mapped) used as new pages
>> -	 * for page table.
>> -	 */
> 
> I think this comment should stay here with the variable names
> updated.

OK, agreed

> 
>> -	while (last_start > ISA_END_ADDRESS) {
>> +	while (last_start > map_start) {
>>  		if (last_start > step_size) {
>>  			start = round_down(last_start - 1, step_size);
>> -			if (start < ISA_END_ADDRESS)
>> -				start = ISA_END_ADDRESS;
>> +			if (start < map_start)
>> +				start = map_start;
>>  		} else
>> -			start = ISA_END_ADDRESS;
>> +			start = map_start;
>>  		new_mapped_ram_size = init_range_memory_mapping(start,
>>  							last_start);
>>  		last_start = start;
>> @@ -453,8 +447,32 @@ void __init init_mem_mapping(void)
>>  		mapped_ram_size += new_mapped_ram_size;
>>  	}
>>  
>> -	if (real_end < end)
>> -		init_range_memory_mapping(real_end, end);
>> +	if (real_end < map_end)
>> +		init_range_memory_mapping(real_end, map_end);
>> +}
>> +
>> +void __init init_mem_mapping(void)
>> +{
>> +	unsigned long end;
>> +
>> +	probe_page_size_mask();
>> +
>> +#ifdef CONFIG_X86_64
>> +	end = max_pfn << PAGE_SHIFT;
>> +#else
>> +	end = max_low_pfn << PAGE_SHIFT;
>> +#endif
>> +
>> +	/* the ISA range is always mapped regardless of memory holes */
>> +	init_memory_mapping(0, ISA_END_ADDRESS);
>> +
>> +	/*
>> +	 * We start from the top (end of memory) and go to the bottom.
>> +	 * The memblock_find_in_range() gets us a block of RAM from the
>> +	 * end of RAM in [min_pfn_mapped, max_pfn_mapped) used as new pages
>> +	 * for page table.
>> +	 */
> 
> And just mention the range and direction in the comment here?

OK, agreed.

Thanks

> 
>> +	memory_map_top_down(ISA_END_ADDRESS, end);
> 
> Thanks.
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
