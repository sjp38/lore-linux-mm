Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 0EC186B006C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 03:44:54 -0400 (EDT)
Message-ID: <4FF2A3FC.5070904@cn.fujitsu.com>
Date: Tue, 03 Jul 2012 15:49:16 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 2/13] memory-hotplug : add physical memory hotplug
 code to acpi_memory_device_remove
References: <4FF287C3.4030901@jp.fujitsu.com> <4FF288FC.8030609@jp.fujitsu.com> <4FF28F6F.1000006@cn.fujitsu.com> <4FF2A1F1.7000901@jp.fujitsu.com>
In-Reply-To: <4FF2A1F1.7000901@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 07/03/2012 03:40 PM, Yasuaki Ishimatsu Wrote:
> Hi Wen,
> 
> 2012/07/03 15:21, Wen Congyang wrote:
>> At 07/03/2012 01:54 PM, Yasuaki Ishimatsu Wrote:
>>> acpi_memory_device_remove() has been prepared to remove physical memory.
>>> But, the function only frees acpi_memory_device currentlry.
>>>
>>> The patch adds following functions into acpi_memory_device_remove():
>>>    - offline memory
>>>    - remove physical memory (only return -EBUSY)
>>>    - free acpi_memory_device
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
>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>
>>> ---
>>>   drivers/acpi/acpi_memhotplug.c |   26 +++++++++++++++++++++++++-
>>>   drivers/base/memory.c          |   38 ++++++++++++++++++++++++++++++++++++++
>>>   include/linux/memory.h         |    5 +++++
>>>   include/linux/memory_hotplug.h |    1 +
>>>   mm/memory_hotplug.c            |    8 ++++++++
>>>   5 files changed, 77 insertions(+), 1 deletion(-)
>>>
>>> Index: linux-3.5-rc4/drivers/acpi/acpi_memhotplug.c
>>> ===================================================================
>>> --- linux-3.5-rc4.orig/drivers/acpi/acpi_memhotplug.c	2012-07-03 14:21:49.458374960 +0900
>>> +++ linux-3.5-rc4/drivers/acpi/acpi_memhotplug.c	2012-07-03 14:21:58.329264059 +0900
>>> @@ -29,6 +29,7 @@
>>>   #include <linux/module.h>
>>>   #include <linux/init.h>
>>>   #include <linux/types.h>
>>> +#include <linux/memory.h>
>>>   #include <linux/memory_hotplug.h>
>>>   #include <linux/slab.h>
>>>   #include <acpi/acpi_drivers.h>
>>> @@ -452,12 +453,35 @@ static int acpi_memory_device_add(struct
>>>   static int acpi_memory_device_remove(struct acpi_device *device, int type)
>>>   {
>>>   	struct acpi_memory_device *mem_device = NULL;
>>> -
>>> +	struct acpi_memory_info *info, *tmp;
>>> +	int result;
>>> +	int node;
>>>
>>>   	if (!device || !acpi_driver_data(device))
>>>   		return -EINVAL;
>>>
>>>   	mem_device = acpi_driver_data(device);
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
>>> +		if (result)
>>> +			return result;
>>> +
>>> +		list_del(&info->list);
>>> +		kfree(info);
>>> +	}
>>> +
>>>   	kfree(mem_device);
>>
>> The caller does not care the return value, and after this function returns, the
>> memory device will be unbound from this driver, so we should free all memory
>> allocated for driver data.
> 
> We can ignore return value of remove_memory() because I think that it should
> return 0. But we cannot ignore return value of offline_memory() because
> kernel panic will occurs if kernel removes online memory. How do we deal with
> online memory?

Yes, We can not remove online memory, so just free the memory if offline_memory()
or remove_memory() fails.

> 
>>>
>>>   	return 0;
>>> Index: linux-3.5-rc4/include/linux/memory_hotplug.h
>>> ===================================================================
>>> --- linux-3.5-rc4.orig/include/linux/memory_hotplug.h	2012-07-03 14:21:49.471374796 +0900
>>> +++ linux-3.5-rc4/include/linux/memory_hotplug.h	2012-07-03 14:21:58.330264047 +0900
>>> @@ -233,6 +233,7 @@ static inline int is_mem_section_removab
>>>   extern int mem_online_node(int nid);
>>>   extern int add_memory(int nid, u64 start, u64 size);
>>>   extern int arch_add_memory(int nid, u64 start, u64 size);
>>> +extern int remove_memory(int nid, u64 start, u64 size);
>>>   extern int offline_memory(u64 start, u64 size);
>>>   extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>>>   								int nr_pages);
>>> Index: linux-3.5-rc4/mm/memory_hotplug.c
>>> ===================================================================
>>> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:21:49.466374860 +0900
>>> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:21:58.332264022 +0900
>>> @@ -659,6 +659,14 @@ out:
>>>   }
>>>   EXPORT_SYMBOL_GPL(add_memory);
>>>
>>> +int remove_memory(int nid, u64 start, u64 size)
>>> +{
>>> +	return -EBUSY;
>>> +
>>> +}
>>> +EXPORT_SYMBOL_GPL(remove_memory);
>>> +
>>> +
>>>   #ifdef CONFIG_MEMORY_HOTREMOVE
>>>   /*
>>>    * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
>>> Index: linux-3.5-rc4/drivers/base/memory.c
>>> ===================================================================
>>> --- linux-3.5-rc4.orig/drivers/base/memory.c	2012-07-03 14:21:49.459374948 +0900
>>> +++ linux-3.5-rc4/drivers/base/memory.c	2012-07-03 14:21:58.335263984 +0900
>>> @@ -70,6 +70,44 @@ void unregister_memory_isolate_notifier(
>>>   }
>>>   EXPORT_SYMBOL(unregister_memory_isolate_notifier);
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
>>
>> The second parameter should be NULL. Otherwise, the mem->dev.kobj will
>> be put twice:
>> 1. we put it when mem->state is MEM_OFFLINE
>> 2. we put it in find_memory_block_hinted().
> 
> Ah, O.K.
> How about it?

This version looks fine to me.

Thanks
Wen Congyang

> 
> +bool is_memblk_offline(unsigned long start, unsigned long size)
> +{
> +	struct memory_block *mem = NULL;
> +	struct mem_section *section;
> +	unsigned long start_pfn, end_pfn;
> +	unsigned long pfn, section_nr;
> +
> +	start_pfn = PFN_DOWN(start);
> +	end_pfn = start_pfn + PFN_DOWN(start);
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		section_nr = pfn_to_section_nr(pfn);
> +		if (!present_section_nr(section_nr));
> +			continue;
> +
> +		section = __nr_to_section(section_nr);
> +		/* same memblock? */
> +		if (mem)
> +			if((section_nr >= mem->start_section_nr) &&
> +			   (section_nr <= mem->end_section_nr))
> +				continue;
> +
> +		mem = find_memory_block_hinted(section, mem);
> +		if (!mem)
> +			continue;
> +		if (mem->state == MEM_OFFLINE)
> +			continue;
> +
> +		kobject_put(&mem->dev.kobj);
> +		return false;
> +	}
> +
> +	if (mem)
> +		kobject_put(&mem->dev.kobj);
> +
> +	return true;
> +}
> +EXPORT_SYMBOL(is_memblk_offline);
> 
> Thanks,
> Yasuaki Ishimatsu
> 
>>
>> Thanks
>> Wen Congyang
>>
>>> +		if (!mem)
>>> +			continue;
>>> +		if (mem->state == MEM_OFFLINE) {
>>> +			kobject_put(&mem->dev.kobj);
>>> +			continue;
>>> +		}
>>> +
>>> +		kobject_put(&mem->dev.kobj);
>>> +		return false;
>>> +	}
>>> +
>>> +	return true;
>>> +}
>>> +EXPORT_SYMBOL(is_memblk_offline);
>>> +
>>>   /*
>>>    * register_memory - Setup a sysfs device for a memory block
>>>    */
>>> Index: linux-3.5-rc4/include/linux/memory.h
>>> ===================================================================
>>> --- linux-3.5-rc4.orig/include/linux/memory.h	2012-07-03 14:21:45.998418215 +0900
>>> +++ linux-3.5-rc4/include/linux/memory.h	2012-07-03 14:21:58.340263922 +0900
>>> @@ -106,6 +106,10 @@ static inline int memory_isolate_notify(
>>>   {
>>>   	return 0;
>>>   }
>>> +static inline bool is_memblk_offline(unsigned long start, unsigned long size)
>>> +{
>>> +	return false;
>>> +}
>>>   #else
>>>   extern int register_memory_notifier(struct notifier_block *nb);
>>>   extern void unregister_memory_notifier(struct notifier_block *nb);
>>> @@ -120,6 +124,7 @@ extern int memory_isolate_notify(unsigne
>>>   extern struct memory_block *find_memory_block_hinted(struct mem_section *,
>>>   							struct memory_block *);
>>>   extern struct memory_block *find_memory_block(struct mem_section *);
>>> +extern bool is_memblk_offline(unsigned long start, unsigned long size);
>>>   #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>>>   enum mem_add_context { BOOT, HOTPLUG };
>>>   #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>
>>
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
