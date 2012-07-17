Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 13CD36B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 01:12:57 -0400 (EDT)
Message-ID: <5004F570.80508@cn.fujitsu.com>
Date: Tue, 17 Jul 2012 13:17:36 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 2/13] memory-hotplug : add physical memory hotplug
 code to acpi_memory_device_remove
References: <4FFAB0A2.8070304@jp.fujitsu.com> <4FFAB148.9000803@jp.fujitsu.com> <4FFF9771.5080307@cn.fujitsu.com> <5004C39B.1060204@jp.fujitsu.com> <5004C5E2.1050906@jp.fujitsu.com> <5004CEB7.4090400@cn.fujitsu.com> <5004D745.3060303@jp.fujitsu.com> <5004DCC2.4030905@cn.fujitsu.com> <5004EF68.5050708@jp.fujitsu.com>
In-Reply-To: <5004EF68.5050708@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 07/17/2012 12:51 PM, Yasuaki Ishimatsu Wrote:
> Hi Wen,
> 
> 2012/07/17 12:32, Wen Congyang wrote:
>> At 07/17/2012 11:08 AM, Yasuaki Ishimatsu Wrote:
>>> Hi Wen,
>>>
>>> 2012/07/17 11:32, Wen Congyang wrote:
>>>> At 07/17/2012 09:54 AM, Yasuaki Ishimatsu Wrote:
>>>>> Hi Wen,
>>>>>
>>>>> 2012/07/17 10:44, Yasuaki Ishimatsu wrote:
>>>>>> Hi Wen,
>>>>>>
>>>>>> 2012/07/13 12:35, Wen Congyang wrote:
>>>>>>> At 07/09/2012 06:24 PM, Yasuaki Ishimatsu Wrote:
>>>>>>>> acpi_memory_device_remove() has been prepared to remove physical memory.
>>>>>>>> But, the function only frees acpi_memory_device currentlry.
>>>>>>>>
>>>>>>>> The patch adds following functions into acpi_memory_device_remove():
>>>>>>>>       - offline memory
>>>>>>>>       - remove physical memory (only return -EBUSY)
>>>>>>>>       - free acpi_memory_device
>>>>>>>>
>>>>>>>> CC: David Rientjes <rientjes@google.com>
>>>>>>>> CC: Jiang Liu <liuj97@gmail.com>
>>>>>>>> CC: Len Brown <len.brown@intel.com>
>>>>>>>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>>>>>>>> CC: Paul Mackerras <paulus@samba.org>
>>>>>>>> CC: Christoph Lameter <cl@linux.com>
>>>>>>>> Cc: Minchan Kim <minchan.kim@gmail.com>
>>>>>>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>>>>>>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>>>>>> CC: Wen Congyang <wency@cn.fujitsu.com>
>>>>>>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>>>>>
>>>>>>>> ---
>>>>>>>>      drivers/acpi/acpi_memhotplug.c |   26 +++++++++++++++++++++++++-
>>>>>>>>      drivers/base/memory.c          |   39 +++++++++++++++++++++++++++++++++++++++
>>>>>>>>      include/linux/memory.h         |    5 +++++
>>>>>>>>      include/linux/memory_hotplug.h |    1 +
>>>>>>>>      mm/memory_hotplug.c            |    8 ++++++++
>>>>>>>>      5 files changed, 78 insertions(+), 1 deletion(-)
>>>>>>>>
>>>>>>>> Index: linux-3.5-rc6/drivers/acpi/acpi_memhotplug.c
>>>>>>>> ===================================================================
>>>>>>>> --- linux-3.5-rc6.orig/drivers/acpi/acpi_memhotplug.c	2012-07-09 18:08:29.946888653 +0900
>>>>>>>> +++ linux-3.5-rc6/drivers/acpi/acpi_memhotplug.c	2012-07-09 18:08:43.470719531 +0900
>>>>>>>> @@ -29,6 +29,7 @@
>>>>>>>>      #include <linux/module.h>
>>>>>>>>      #include <linux/init.h>
>>>>>>>>      #include <linux/types.h>
>>>>>>>> +#include <linux/memory.h>
>>>>>>>>      #include <linux/memory_hotplug.h>
>>>>>>>>      #include <linux/slab.h>
>>>>>>>>      #include <acpi/acpi_drivers.h>
>>>>>>>> @@ -452,12 +453,35 @@ static int acpi_memory_device_add(struct
>>>>>>>>      static int acpi_memory_device_remove(struct acpi_device *device, int type)
>>>>>>>>      {
>>>>>>>>      	struct acpi_memory_device *mem_device = NULL;
>>>>>>>> -
>>>>>>>> +	struct acpi_memory_info *info, *tmp;
>>>>>>>> +	int result;
>>>>>>>> +	int node;
>>>>>>>>
>>>>>>>>      	if (!device || !acpi_driver_data(device))
>>>>>>>>      		return -EINVAL;
>>>>>>>>
>>>>>>>>      	mem_device = acpi_driver_data(device);
>>>>>>>> +
>>>>>>>> +	node = acpi_get_node(mem_device->device->handle);
>>>>>>>> +
>>>>>>>> +	list_for_each_entry_safe(info, tmp, &mem_device->res_list, list) {
>>>>>>>> +		if (!info->enabled)
>>>>>>>> +			continue;
>>>>>>>> +
>>>>>>>> +		if (!is_memblk_offline(info->start_addr, info->length)) {
>>>>>>>> +			result = offline_memory(info->start_addr, info->length);
>>>>>>>> +			if (result)
>>>>>>>> +				return result;
>>>>>>>> +		}
>>>>>>>> +
>>>>>>>> +		result = remove_memory(node, info->start_addr, info->length);
>>>>>>>
>>>>>>> The user may online the memory between offline_memory() and remove_memory().
>>>>>>> So I think we should lock memory hotplug before check the memory's status
>>>>>>> and release it after remove_memory().
>>>>>>
>>>>>> How about get "mem_block->state_mutex" of removed memory? When offlining
>>>>>> memory, we need to change "memory_block->state" into "MEM_OFFLINE".
>>>>>> In this case, we get mem_block->state_mutex. So I think the mutex lock
>>>>>> is beneficial.
>>>>>
>>>>> It is not good idea since remove_memory frees mem_block structure...
>>>>> Do you have any ideas?
>>>>
>>>> Hmm, split offline_memory() to 2 functions: offline_pages() and __offline_pages()
>>>>
>>>> offline_pages()
>>>> 	lock_memory_hotplug();
>>>> 	__offline_pages();
>>>> 	unlock_memory_hotplug();
>>>>
>>>> and implement remove_memory() like this:
>>>> remove_memory()
>>>> 	lock_memory_hotplug()
>>>> 	if (!is_memblk_offline()) {
>>>> 		__offline_pages();
>>>> 	}
>>>> 	// cleanup
>>>> 	unlock_memory_hotplug();
>>>>
>>>> What about this?
>>>
>>> I also thought about it once. But a problem remains. Current offilne_pages()
>>> cannot realize the memory has been removed by remove_memory(). So even if
>>> protecting the race by lock_memory_hotplug(), offline_pages() can offline
>>> the removed memory. offline_pages() should have the means to know the memory
>>> was removed. But I don't have good idea.
>>
>> We can not online/offline part of memory block, so what about this?
> 
> It seems you do not understand my concern.
> When memory_remove() and offline_pages() run to same memory simultaneously,
> offline_pages runs to removed memory.
> 
> memory_remove()              | offline_pages()
> -----------------------------------------------------------
> lock_memory_hotplug()        |
>                              | wait at lock_memory_hotplug()
> remove memory                |
> unlock_memory_hotplug()      |
>                              | wake up and start offline_pages()
> 			     | offline page
> 			     | => but the memory has already removed
> 			     |    by memory_remove()
> 
> In this case, offline_page() may access removed memory.

Yes, in this case, the kernel may panic.

I think we can call pfn_present() in online_pages()/offline_pages()
to check whether the memory is removed.

Thanks
Wen Congyang

> 
> Thanks,
> Yasuaki Ishimatsu
> 
>>
>> remove_memory()
>> 	lock_memory_hotplug()
>> 	for each memory block:
>> 		if (!is_memblk_offline()) {
>> 			__offline_pages();
>> 		}
>> 	// cleanup
>> 	unlock_memory_hotplug();
>>
>> Thanks
>> Wen Congyang
>>>
>>> Thanks,
>>> Yasuaki Ishimatsu
>>>
>>>>
>>>> Thanks
>>>> Wen Congyang
>>>>>
>>>>> Thanks,
>>>>> Yasuaki Ishimatsu
>>>>>
>>>>>> Thanks,
>>>>>> Yasuaki Ishimatsu
>>>>>>
>>>>>>>
>>>>>>> Thanks
>>>>>>> Wen Congyang
>>>>>>>
>>>>>>>> +		if (result)
>>>>>>>> +			return result;
>>>>>>>> +
>>>>>>>> +		list_del(&info->list);
>>>>>>>> +		kfree(info);
>>>>>>>> +	}
>>>>>>>> +
>>>>>>>>      	kfree(mem_device);
>>>>>>>>
>>>>>>>>      	return 0;
>>>>>>>> Index: linux-3.5-rc6/include/linux/memory_hotplug.h
>>>>>>>> ===================================================================
>>>>>>>> --- linux-3.5-rc6.orig/include/linux/memory_hotplug.h	2012-07-09 18:08:29.955888542 +0900
>>>>>>>> +++ linux-3.5-rc6/include/linux/memory_hotplug.h	2012-07-09 18:08:43.471719518 +0900
>>>>>>>> @@ -233,6 +233,7 @@ static inline int is_mem_section_removab
>>>>>>>>      extern int mem_online_node(int nid);
>>>>>>>>      extern int add_memory(int nid, u64 start, u64 size);
>>>>>>>>      extern int arch_add_memory(int nid, u64 start, u64 size);
>>>>>>>> +extern int remove_memory(int nid, u64 start, u64 size);
>>>>>>>>      extern int offline_memory(u64 start, u64 size);
>>>>>>>>      extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>>>>>>>>      								int nr_pages);
>>>>>>>> Index: linux-3.5-rc6/mm/memory_hotplug.c
>>>>>>>> ===================================================================
>>>>>>>> --- linux-3.5-rc6.orig/mm/memory_hotplug.c	2012-07-09 18:08:29.953888567 +0900
>>>>>>>> +++ linux-3.5-rc6/mm/memory_hotplug.c	2012-07-09 18:08:43.476719455 +0900
>>>>>>>> @@ -659,6 +659,14 @@ out:
>>>>>>>>      }
>>>>>>>>      EXPORT_SYMBOL_GPL(add_memory);
>>>>>>>>
>>>>>>>> +int remove_memory(int nid, u64 start, u64 size)
>>>>>>>> +{
>>>>>>>> +	return -EBUSY;
>>>>>>>> +
>>>>>>>> +}
>>>>>>>> +EXPORT_SYMBOL_GPL(remove_memory);
>>>>>>>> +
>>>>>>>> +
>>>>>>>>      #ifdef CONFIG_MEMORY_HOTREMOVE
>>>>>>>>      /*
>>>>>>>>       * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
>>>>>>>> Index: linux-3.5-rc6/drivers/base/memory.c
>>>>>>>> ===================================================================
>>>>>>>> --- linux-3.5-rc6.orig/drivers/base/memory.c	2012-07-09 18:08:29.947888640 +0900
>>>>>>>> +++ linux-3.5-rc6/drivers/base/memory.c	2012-07-09 18:10:54.880076739 +0900
>>>>>>>> @@ -70,6 +70,45 @@ void unregister_memory_isolate_notifier(
>>>>>>>>      }
>>>>>>>>      EXPORT_SYMBOL(unregister_memory_isolate_notifier);
>>>>>>>>
>>>>>>>> +bool is_memblk_offline(unsigned long start, unsigned long size)
>>>>>>>> +{
>>>>>>>> +	struct memory_block *mem = NULL;
>>>>>>>> +	struct mem_section *section;
>>>>>>>> +	unsigned long start_pfn, end_pfn;
>>>>>>>> +	unsigned long pfn, section_nr;
>>>>>>>> +
>>>>>>>> +	start_pfn = PFN_DOWN(start);
>>>>>>>> +	end_pfn = start_pfn + PFN_DOWN(start);
>>>>>>>> +
>>>>>>>> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>>>>>>>> +		section_nr = pfn_to_section_nr(pfn);
>>>>>>>> +		if (!present_section_nr(section_nr));
>>>>>>>> +			continue;
>>>>>>>> +
>>>>>>>> +		section = __nr_to_section(section_nr);
>>>>>>>> +		/* same memblock? */
>>>>>>>> +		if (mem)
>>>>>>>> +			if((section_nr >= mem->start_section_nr) &&
>>>>>>>> +			   (section_nr <= mem->end_section_nr))
>>>>>>>> +				continue;
>>>>>>>> +
>>>>>>>> +		mem = find_memory_block_hinted(section, mem);
>>>>>>>> +		if (!mem)
>>>>>>>> +			continue;
>>>>>>>> +		if (mem->state == MEM_OFFLINE)
>>>>>>>> +			continue;
>>>>>>>> +
>>>>>>>> +		kobject_put(&mem->dev.kobj);
>>>>>>>> +		return false;
>>>>>>>> +	}
>>>>>>>> +
>>>>>>>> +	if (mem)
>>>>>>>> +		kobject_put(&mem->dev.kobj);
>>>>>>>> +
>>>>>>>> +	return true;
>>>>>>>> +}
>>>>>>>> +EXPORT_SYMBOL(is_memblk_offline);
>>>>>>>> +
>>>>>>>>      /*
>>>>>>>>       * register_memory - Setup a sysfs device for a memory block
>>>>>>>>       */
>>>>>>>> Index: linux-3.5-rc6/include/linux/memory.h
>>>>>>>> ===================================================================
>>>>>>>> --- linux-3.5-rc6.orig/include/linux/memory.h	2012-07-08 09:23:56.000000000 +0900
>>>>>>>> +++ linux-3.5-rc6/include/linux/memory.h	2012-07-09 18:08:43.484719355 +0900
>>>>>>>> @@ -106,6 +106,10 @@ static inline int memory_isolate_notify(
>>>>>>>>      {
>>>>>>>>      	return 0;
>>>>>>>>      }
>>>>>>>> +static inline bool is_memblk_offline(unsigned long start, unsigned long size)
>>>>>>>> +{
>>>>>>>> +	return false;
>>>>>>>> +}
>>>>>>>>      #else
>>>>>>>>      extern int register_memory_notifier(struct notifier_block *nb);
>>>>>>>>      extern void unregister_memory_notifier(struct notifier_block *nb);
>>>>>>>> @@ -120,6 +124,7 @@ extern int memory_isolate_notify(unsigne
>>>>>>>>      extern struct memory_block *find_memory_block_hinted(struct mem_section *,
>>>>>>>>      							struct memory_block *);
>>>>>>>>      extern struct memory_block *find_memory_block(struct mem_section *);
>>>>>>>> +extern bool is_memblk_offline(unsigned long start, unsigned long size);
>>>>>>>>      #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>>>>>>>>      enum mem_add_context { BOOT, HOTPLUG };
>>>>>>>>      #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>>>>>>>>
>>>>>>>>
>>>>>>>
>>>>>>> --
>>>>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>>>>> see: http://www.linux-mm.org/ .
>>>>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>
>>>>>
>>>>>
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>
>>>>
>>>
>>>
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
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
