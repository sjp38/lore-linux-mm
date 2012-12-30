Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8F59D6B0062
	for <linux-mm@kvack.org>; Sun, 30 Dec 2012 00:43:04 -0500 (EST)
Message-ID: <50DFD5FF.7050609@cn.fujitsu.com>
Date: Sun, 30 Dec 2012 13:49:51 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 01/14] memory-hotplug: try to offline the memory twice
 to avoid dependence
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-2-git-send-email-tangchen@cn.fujitsu.com> <50DA68A8.4060001@jp.fujitsu.com>
In-Reply-To: <50DA68A8.4060001@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

At 12/26/2012 11:02 AM, Kamezawa Hiroyuki Wrote:
> (2012/12/24 21:09), Tang Chen wrote:
>> From: Wen Congyang <wency@cn.fujitsu.com>
>>
>> memory can't be offlined when CONFIG_MEMCG is selected.
>> For example: there is a memory device on node 1. The address range
>> is [1G, 1.5G). You will find 4 new directories memory8, memory9, memory10,
>> and memory11 under the directory /sys/devices/system/memory/.
>>
>> If CONFIG_MEMCG is selected, we will allocate memory to store page cgroup
>> when we online pages. When we online memory8, the memory stored page cgroup
>> is not provided by this memory device. But when we online memory9, the memory
>> stored page cgroup may be provided by memory8. So we can't offline memory8
>> now. We should offline the memory in the reversed order.
>>
> 
> If memory8 is onlined as NORMAL memory ...right ?

Yes, memory8 is onlined as NORMAL memory. And when we online memory9, we allocate
memory from memory8 to store page cgroup information.

> 
> IIUC, vmalloc() uses __GFP_HIGHMEM but doesn't use __GFP_MOVABLE.
> 
>> When the memory device is hotremoved, we will auto offline memory provided
>> by this memory device. But we don't know which memory is onlined first, so
>> offlining memory may fail. In such case, iterate twice to offline the memory.
>> 1st iterate: offline every non primary memory block.
>> 2nd iterate: offline primary (i.e. first added) memory block.
>>
>> This idea is suggested by KOSAKI Motohiro.
>>
>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> 
> I'm not sure but the whole DIMM should be onlined as MOVABLE mem ?

If the whole DIMM is onlined as MOVABLE mem, we can offline it, and don't
retry again.

> 
> Anyway, I agree this kind of retry is required if memory is onlined as NORMAL mem.
> But retry-once is ok ?

I'am not sure, but I think in most cases the user may online the memory according first
which is hot-added first. So we may always fail in the first time, and retry-once can
success.

Thanks
Wen Congyang

> 
> Thanks,
> -Kame
> 
>> ---
>>   mm/memory_hotplug.c |   16 ++++++++++++++--
>>   1 files changed, 14 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index d04ed87..62e04c9 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1388,10 +1388,13 @@ int remove_memory(u64 start, u64 size)
>>   	unsigned long start_pfn, end_pfn;
>>   	unsigned long pfn, section_nr;
>>   	int ret;
>> +	int return_on_error = 0;
>> +	int retry = 0;
>>   
>>   	start_pfn = PFN_DOWN(start);
>>   	end_pfn = start_pfn + PFN_DOWN(size);
>>   
>> +repeat:
>>   	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>>   		section_nr = pfn_to_section_nr(pfn);
>>   		if (!present_section_nr(section_nr))
>> @@ -1410,14 +1413,23 @@ int remove_memory(u64 start, u64 size)
>>   
>>   		ret = offline_memory_block(mem);
>>   		if (ret) {
>> -			kobject_put(&mem->dev.kobj);
>> -			return ret;
>> +			if (return_on_error) {
>> +				kobject_put(&mem->dev.kobj);
>> +				return ret;
>> +			} else {
>> +				retry = 1;
>> +			}
>>   		}
>>   	}
>>   
>>   	if (mem)
>>   		kobject_put(&mem->dev.kobj);
>>   
>> +	if (retry) {
>> +		return_on_error = 1;
>> +		goto repeat;
>> +	}
>> +
>>   	return 0;
>>   }
>>   #else
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
