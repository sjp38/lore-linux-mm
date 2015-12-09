Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9310D6B0255
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 21:40:22 -0500 (EST)
Received: by wmww144 with SMTP id w144so53991848wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 18:40:22 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id b14si8396523wjs.44.2015.12.08.18.40.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 18:40:21 -0800 (PST)
Message-ID: <56679480.2050106@huawei.com>
Date: Wed, 9 Dec 2015 10:40:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] mm: Introduce kernelcore=reliable option
References: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com> <1448636696-16044-1-git-send-email-izumi.taku@jp.fujitsu.com> <56679124.2050501@huawei.com>
In-Reply-To: <56679124.2050501@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, akpm@linux-foundation.org, dave.hansen@intel.com, matt@codeblueprint.co.uk

On 2015/12/9 10:25, Xishi Qiu wrote:

> On 2015/11/27 23:04, Taku Izumi wrote:
> 
>> This patch extends existing "kernelcore" option and
>> introduces kernelcore=reliable option. By specifying
>> "reliable" instead of specifying the amount of memory,
>> non-reliable region will be arranged into ZONE_MOVABLE.
>>
>> v1 -> v2:
>>  - Refine so that the following case also can be
>>    handled properly:
>>
>>  Node X:  |MMMMMM------MMMMMM--------|
>>    (legend) M: mirrored  -: not mirrrored
>>
>>  In this case, ZONE_NORMAL and ZONE_MOVABLE are
>>  arranged like bellow:
>>
>>  Node X:  |--------------------------|
>>           |ooooooxxxxxxooooooxxxxxxxx| ZONE_NORMAL
>>                 |ooooooxxxxxxoooooooo| ZONE_MOVABLE
>>    (legend) o: present  x: absent
>>
>> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
>> ---
>>  Documentation/kernel-parameters.txt |   9 ++-
>>  mm/page_alloc.c                     | 110 ++++++++++++++++++++++++++++++++++--
>>  2 files changed, 112 insertions(+), 7 deletions(-)
>>
>> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
>> index f8aae63..ed44c2c8 100644
>> --- a/Documentation/kernel-parameters.txt
>> +++ b/Documentation/kernel-parameters.txt
>> @@ -1695,7 +1695,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>>  
>>  	keepinitrd	[HW,ARM]
>>  
>> -	kernelcore=nn[KMG]	[KNL,X86,IA-64,PPC] This parameter
>> +	kernelcore=	Format: nn[KMG] | "reliable"
>> +			[KNL,X86,IA-64,PPC] This parameter
>>  			specifies the amount of memory usable by the kernel
>>  			for non-movable allocations.  The requested amount is
>>  			spread evenly throughout all nodes in the system. The
>> @@ -1711,6 +1712,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>>  			use the HighMem zone if it exists, and the Normal
>>  			zone if it does not.
>>  
>> +			Instead of specifying the amount of memory (nn[KMS]),
>> +			you can specify "reliable" option. In case "reliable"
>> +			option is specified, reliable memory is used for
>> +			non-movable allocations and remaining memory is used
>> +			for Movable pages.
>> +
>>  	kgdbdbgp=	[KGDB,HW] kgdb over EHCI usb debug port.
>>  			Format: <Controller#>[,poll interval]
>>  			The controller # is the number of the ehci usb debug
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index acb0b4e..006a3d8 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -251,6 +251,7 @@ static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
>>  static unsigned long __initdata required_kernelcore;
>>  static unsigned long __initdata required_movablecore;
>>  static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
>> +static bool reliable_kernelcore;
>>  
>>  /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
>>  int movable_zone;
>> @@ -4472,6 +4473,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>  	unsigned long pfn;
>>  	struct zone *z;
>>  	unsigned long nr_initialised = 0;
>> +	struct memblock_region *r = NULL, *tmp;
>>  
>>  	if (highest_memmap_pfn < end_pfn - 1)
>>  		highest_memmap_pfn = end_pfn - 1;
>> @@ -4491,6 +4493,38 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>  			if (!update_defer_init(pgdat, pfn, end_pfn,
>>  						&nr_initialised))
>>  				break;
>> +
>> +			/*
>> +			 * if not reliable_kernelcore and ZONE_MOVABLE exists,
>> +			 * range from zone_movable_pfn[nid] to end of each node
>> +			 * should be ZONE_MOVABLE not ZONE_NORMAL. skip it.
>> +			 */
>> +			if (!reliable_kernelcore && zone_movable_pfn[nid])
>> +				if (zone == ZONE_NORMAL &&
>> +				    pfn >= zone_movable_pfn[nid])
>> +					continue;
>> +
>> +			/*
>> +			 * check given memblock attribute by firmware which
>> +			 * can affect kernel memory layout.
>> +			 * if zone==ZONE_MOVABLE but memory is mirrored,
>> +			 * it's an overlapped memmap init. skip it.
>> +			 */
>> +			if (reliable_kernelcore && zone == ZONE_MOVABLE) {
>> +				if (!r ||
>> +				    pfn >= memblock_region_memory_end_pfn(r)) {
>> +					for_each_memblock(memory, tmp)
>> +						if (pfn < memblock_region_memory_end_pfn(tmp))
>> +							break;
>> +					r = tmp;
>> +				}
>> +				if (pfn >= memblock_region_memory_base_pfn(r) &&
>> +				    memblock_is_mirror(r)) {
>> +					/* already initialized as NORMAL */
>> +					pfn = memblock_region_memory_end_pfn(r);
>> +					continue;
>> +				}
>> +			}
> 
> Hi Taku,
> 
> It has checked this case: zone==ZONE_MOVABLE but memory is mirrored,
> but how about another case: zone==ZONE_NORMAL but memory is not mirrored?
> 
>   Node X:  |--------------------------|
>            |ooooooxxxxxxooooooxxxxxxxx| ZONE_NORMAL
>                  |ooooooxxxxxxoooooooo| ZONE_MOVABLE
>     (legend) o: present  x: absent
> 
> Thanks,
> Xishi Qiu
> 

Hi Taku,

memmap_init_zone() will init normal zone first, then init the movable
zone, and it will change the page initialization which has already inited
in normal zone, so it need not to check the other case, right?

I think this is a little confusion and waste time.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
