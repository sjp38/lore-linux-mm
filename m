Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 36D946B005A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 21:55:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 55FF13EE0AE
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:55:10 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 09B7545DE62
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:55:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B8FB745DE5E
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:55:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B87DE08005
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:55:09 +0900 (JST)
Received: from g01jpexchyt03.g01.fujitsu.local (g01jpexchyt03.g01.fujitsu.local [10.128.194.42])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C79CE38003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:55:09 +0900 (JST)
Message-ID: <5004C5E2.1050906@jp.fujitsu.com>
Date: Tue, 17 Jul 2012 10:54:42 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 2/13] memory-hotplug : add physical memory hotplug
 code to acpi_memory_device_remove
References: <4FFAB0A2.8070304@jp.fujitsu.com> <4FFAB148.9000803@jp.fujitsu.com> <4FFF9771.5080307@cn.fujitsu.com> <5004C39B.1060204@jp.fujitsu.com>
In-Reply-To: <5004C39B.1060204@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/07/17 10:44, Yasuaki Ishimatsu wrote:
> Hi Wen,
> 
> 2012/07/13 12:35, Wen Congyang wrote:
>> At 07/09/2012 06:24 PM, Yasuaki Ishimatsu Wrote:
>>> acpi_memory_device_remove() has been prepared to remove physical memory.
>>> But, the function only frees acpi_memory_device currentlry.
>>>
>>> The patch adds following functions into acpi_memory_device_remove():
>>>     - offline memory
>>>     - remove physical memory (only return -EBUSY)
>>>     - free acpi_memory_device
>>>
>>> CC: David Rientjes <rientjes@google.com>
>>> CC: Jiang Liu <liuj97@gmail.com>
>>> CC: Len Brown <len.brown@intel.com>
>>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>>> CC: Paul Mackerras <paulus@samba.org>
>>> CC: Christoph Lameter <cl@linux.com>
>>> Cc: Minchan Kim <minchan.kim@gmail.com>
>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>> CC: Wen Congyang <wency@cn.fujitsu.com>
>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>
>>> ---
>>>    drivers/acpi/acpi_memhotplug.c |   26 +++++++++++++++++++++++++-
>>>    drivers/base/memory.c          |   39 +++++++++++++++++++++++++++++++++++++++
>>>    include/linux/memory.h         |    5 +++++
>>>    include/linux/memory_hotplug.h |    1 +
>>>    mm/memory_hotplug.c            |    8 ++++++++
>>>    5 files changed, 78 insertions(+), 1 deletion(-)
>>>
>>> Index: linux-3.5-rc6/drivers/acpi/acpi_memhotplug.c
>>> ===================================================================
>>> --- linux-3.5-rc6.orig/drivers/acpi/acpi_memhotplug.c	2012-07-09 18:08:29.946888653 +0900
>>> +++ linux-3.5-rc6/drivers/acpi/acpi_memhotplug.c	2012-07-09 18:08:43.470719531 +0900
>>> @@ -29,6 +29,7 @@
>>>    #include <linux/module.h>
>>>    #include <linux/init.h>
>>>    #include <linux/types.h>
>>> +#include <linux/memory.h>
>>>    #include <linux/memory_hotplug.h>
>>>    #include <linux/slab.h>
>>>    #include <acpi/acpi_drivers.h>
>>> @@ -452,12 +453,35 @@ static int acpi_memory_device_add(struct
>>>    static int acpi_memory_device_remove(struct acpi_device *device, int type)
>>>    {
>>>    	struct acpi_memory_device *mem_device = NULL;
>>> -
>>> +	struct acpi_memory_info *info, *tmp;
>>> +	int result;
>>> +	int node;
>>>
>>>    	if (!device || !acpi_driver_data(device))
>>>    		return -EINVAL;
>>>
>>>    	mem_device = acpi_driver_data(device);
>>> +
>>> +	node = acpi_get_node(mem_device->device->handle);
>>> +
>>> +	list_for_each_entry_safe(info, tmp, &mem_device->res_list, list) {
>>> +		if (!info->enabled)
>>> +			continue;
>>> +
>>> +		if (!is_memblk_offline(info->start_addr, info->length)) {
>>> +			result = offline_memory(info->start_addr, info->length);
>>> +			if (result)
>>> +				return result;
>>> +		}
>>> +
>>> +		result = remove_memory(node, info->start_addr, info->length);
>>
>> The user may online the memory between offline_memory() and remove_memory().
>> So I think we should lock memory hotplug before check the memory's status
>> and release it after remove_memory().
> 
> How about get "mem_block->state_mutex" of removed memory? When offlining
> memory, we need to change "memory_block->state" into "MEM_OFFLINE".
> In this case, we get mem_block->state_mutex. So I think the mutex lock
> is beneficial.

It is not good idea since remove_memory frees mem_block structure...
Do you have any ideas?

Thanks,
Yasuaki Ishimatsu

> Thanks,
> Yasuaki Ishimatsu
> 
>>
>> Thanks
>> Wen Congyang
>>
>>> +		if (result)
>>> +			return result;
>>> +
>>> +		list_del(&info->list);
>>> +		kfree(info);
>>> +	}
>>> +
>>>    	kfree(mem_device);
>>>
>>>    	return 0;
>>> Index: linux-3.5-rc6/include/linux/memory_hotplug.h
>>> ===================================================================
>>> --- linux-3.5-rc6.orig/include/linux/memory_hotplug.h	2012-07-09 18:08:29.955888542 +0900
>>> +++ linux-3.5-rc6/include/linux/memory_hotplug.h	2012-07-09 18:08:43.471719518 +0900
>>> @@ -233,6 +233,7 @@ static inline int is_mem_section_removab
>>>    extern int mem_online_node(int nid);
>>>    extern int add_memory(int nid, u64 start, u64 size);
>>>    extern int arch_add_memory(int nid, u64 start, u64 size);
>>> +extern int remove_memory(int nid, u64 start, u64 size);
>>>    extern int offline_memory(u64 start, u64 size);
>>>    extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>>>    								int nr_pages);
>>> Index: linux-3.5-rc6/mm/memory_hotplug.c
>>> ===================================================================
>>> --- linux-3.5-rc6.orig/mm/memory_hotplug.c	2012-07-09 18:08:29.953888567 +0900
>>> +++ linux-3.5-rc6/mm/memory_hotplug.c	2012-07-09 18:08:43.476719455 +0900
>>> @@ -659,6 +659,14 @@ out:
>>>    }
>>>    EXPORT_SYMBOL_GPL(add_memory);
>>>
>>> +int remove_memory(int nid, u64 start, u64 size)
>>> +{
>>> +	return -EBUSY;
>>> +
>>> +}
>>> +EXPORT_SYMBOL_GPL(remove_memory);
>>> +
>>> +
>>>    #ifdef CONFIG_MEMORY_HOTREMOVE
>>>    /*
>>>     * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
>>> Index: linux-3.5-rc6/drivers/base/memory.c
>>> ===================================================================
>>> --- linux-3.5-rc6.orig/drivers/base/memory.c	2012-07-09 18:08:29.947888640 +0900
>>> +++ linux-3.5-rc6/drivers/base/memory.c	2012-07-09 18:10:54.880076739 +0900
>>> @@ -70,6 +70,45 @@ void unregister_memory_isolate_notifier(
>>>    }
>>>    EXPORT_SYMBOL(unregister_memory_isolate_notifier);
>>>
>>> +bool is_memblk_offline(unsigned long start, unsigned long size)
>>> +{
>>> +	struct memory_block *mem = NULL;
>>> +	struct mem_section *section;
>>> +	unsigned long start_pfn, end_pfn;
>>> +	unsigned long pfn, section_nr;
>>> +
>>> +	start_pfn = PFN_DOWN(start);
>>> +	end_pfn = start_pfn + PFN_DOWN(start);
>>> +
>>> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>>> +		section_nr = pfn_to_section_nr(pfn);
>>> +		if (!present_section_nr(section_nr));
>>> +			continue;
>>> +
>>> +		section = __nr_to_section(section_nr);
>>> +		/* same memblock? */
>>> +		if (mem)
>>> +			if((section_nr >= mem->start_section_nr) &&
>>> +			   (section_nr <= mem->end_section_nr))
>>> +				continue;
>>> +
>>> +		mem = find_memory_block_hinted(section, mem);
>>> +		if (!mem)
>>> +			continue;
>>> +		if (mem->state == MEM_OFFLINE)
>>> +			continue;
>>> +
>>> +		kobject_put(&mem->dev.kobj);
>>> +		return false;
>>> +	}
>>> +
>>> +	if (mem)
>>> +		kobject_put(&mem->dev.kobj);
>>> +
>>> +	return true;
>>> +}
>>> +EXPORT_SYMBOL(is_memblk_offline);
>>> +
>>>    /*
>>>     * register_memory - Setup a sysfs device for a memory block
>>>     */
>>> Index: linux-3.5-rc6/include/linux/memory.h
>>> ===================================================================
>>> --- linux-3.5-rc6.orig/include/linux/memory.h	2012-07-08 09:23:56.000000000 +0900
>>> +++ linux-3.5-rc6/include/linux/memory.h	2012-07-09 18:08:43.484719355 +0900
>>> @@ -106,6 +106,10 @@ static inline int memory_isolate_notify(
>>>    {
>>>    	return 0;
>>>    }
>>> +static inline bool is_memblk_offline(unsigned long start, unsigned long size)
>>> +{
>>> +	return false;
>>> +}
>>>    #else
>>>    extern int register_memory_notifier(struct notifier_block *nb);
>>>    extern void unregister_memory_notifier(struct notifier_block *nb);
>>> @@ -120,6 +124,7 @@ extern int memory_isolate_notify(unsigne
>>>    extern struct memory_block *find_memory_block_hinted(struct mem_section *,
>>>    							struct memory_block *);
>>>    extern struct memory_block *find_memory_block(struct mem_section *);
>>> +extern bool is_memblk_offline(unsigned long start, unsigned long size);
>>>    #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>>>    enum mem_add_context { BOOT, HOTPLUG };
>>>    #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>>>
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
