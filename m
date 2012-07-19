Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C94436B005C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 03:18:33 -0400 (EDT)
Message-ID: <5007B5E4.1010602@cn.fujitsu.com>
Date: Thu, 19 Jul 2012 15:23:16 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v4 2/13] memory-hotplug : add physical memory hotplug
 code to acpi_memory_device_remove
References: <50068974.1070409@jp.fujitsu.com> <50068AB9.20005@jp.fujitsu.com>
In-Reply-To: <50068AB9.20005@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 07/18/2012 06:06 PM, Yasuaki Ishimatsu Wrote:
> acpi_memory_device_remove() has been prepared to remove physical memory.
> But, the function only frees acpi_memory_device currentlry. 
> 
> The patch adds following functions into acpi_memory_device_remove():
>   - offline memory
>   - remove physical memory. It only check whether memory is online or not.
>   - free acpi_memory_device
> 
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org> 
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> 
> CC: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> ---
>  drivers/acpi/acpi_memhotplug.c |   27 ++++++++++++++++++++++++++-
>  drivers/base/memory.c          |   39 +++++++++++++++++++++++++++++++++++++++
>  include/linux/memory.h         |    5 +++++
>  include/linux/memory_hotplug.h |    5 +++++
>  mm/memory_hotplug.c            |   22 ++++++++++++++++++++++
>  5 files changed, 97 insertions(+), 1 deletion(-)
> 
> Index: linux-3.5-rc6/drivers/acpi/acpi_memhotplug.c
> ===================================================================
> --- linux-3.5-rc6.orig/drivers/acpi/acpi_memhotplug.c	2012-07-17 11:20:15.117796971 +0900
> +++ linux-3.5-rc6/drivers/acpi/acpi_memhotplug.c	2012-07-17 13:36:30.325594022 +0900
> @@ -29,6 +29,7 @@
>  #include <linux/module.h>
>  #include <linux/init.h>
>  #include <linux/types.h>
> +#include <linux/memory.h>
>  #include <linux/memory_hotplug.h>
>  #include <linux/slab.h>
>  #include <acpi/acpi_drivers.h>
> @@ -452,12 +453,36 @@ static int acpi_memory_device_add(struct
>  static int acpi_memory_device_remove(struct acpi_device *device, int type)
>  {
>  	struct acpi_memory_device *mem_device = NULL;
> -
> +	struct acpi_memory_info *info, *tmp;
> +	int result;
> +	int node;
>  
>  	if (!device || !acpi_driver_data(device))
>  		return -EINVAL;
>  
>  	mem_device = acpi_driver_data(device);
> +
> +	node = acpi_get_node(mem_device->device->handle);
> +	list_for_each_entry_safe(info, tmp, &mem_device->res_list, list) {
> +		if (!info->enabled)
> +			continue;
> +
> +		if (!is_memblk_offline(info->start_addr, info->length)) {
> +			result = offline_memory(info->start_addr, info->length);
> +			if (result)
> +				return result;
> +		}
> +		if (node < 0)
> +			node = memory_add_physaddr_to_nid(info->start_addr);
> +
> +		result = remove_memory(node, info->start_addr, info->length);
> +		if (result)
> +			return result;
> +
> +		list_del(&info->list);
> +		kfree(info);
> +	}
> +
>  	kfree(mem_device);
>  
>  	return 0;
> Index: linux-3.5-rc6/include/linux/memory_hotplug.h
> ===================================================================
> --- linux-3.5-rc6.orig/include/linux/memory_hotplug.h	2012-07-17 11:20:15.133796772 +0900
> +++ linux-3.5-rc6/include/linux/memory_hotplug.h	2012-07-17 11:29:41.490716352 +0900
> @@ -221,6 +221,7 @@ static inline void unlock_memory_hotplug
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  
>  extern int is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
> +extern int remove_memory(int nid, u64 start, u64 size);
>  
>  #else
>  static inline int is_mem_section_removable(unsigned long pfn,
> @@ -228,6 +229,10 @@ static inline int is_mem_section_removab
>  {
>  	return 0;
>  }
> +static inline int remove_memory(int nid, u64 start, u64 size)
> +{
> +	return -EBUSY;
> +}
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
>  extern int mem_online_node(int nid);
> Index: linux-3.5-rc6/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.5-rc6.orig/mm/memory_hotplug.c	2012-07-17 11:20:15.129796821 +0900
> +++ linux-3.5-rc6/mm/memory_hotplug.c	2012-07-17 13:25:18.952986069 +0900
> @@ -998,6 +998,28 @@ int offline_memory(u64 start, u64 size)
>  	end_pfn = start_pfn + PFN_DOWN(size);
>  	return offline_pages(start_pfn, end_pfn, 120 * HZ);
>  }
> +
> +int remove_memory(int nid, u64 start, u64 size)
> +{
> +	int ret = -EBUSY;
> +	lock_memory_hotplug();
> +	/*
> +	 * The memory might become online by other task, even if you offine it.
> +	 * So we check whether the cpu has been onlined or not.
> +	 */
> +	if (!is_memblk_offline(start, size)) {
> +		pr_warn("memory removing [mem %#010llx-%#010llx] failed, "
> +			"because the memmory range is online\n",
> +			start, start + size);
> +		ret = -EAGAIN;
> +	}
> +
> +	unlock_memory_hotplug();
> +	return ret;
> +
> +}
> +EXPORT_SYMBOL_GPL(remove_memory);
> +
>  #else
>  int offline_memory(u64 start, u64 size)
>  {
> Index: linux-3.5-rc6/drivers/base/memory.c
> ===================================================================
> --- linux-3.5-rc6.orig/drivers/base/memory.c	2012-07-17 11:20:15.120796934 +0900
> +++ linux-3.5-rc6/drivers/base/memory.c	2012-07-17 11:20:54.626302995 +0900
> @@ -70,6 +70,45 @@ void unregister_memory_isolate_notifier(
>  }
>  EXPORT_SYMBOL(unregister_memory_isolate_notifier);
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

This line is wrong. I think you want this:
end_pfn = start_pfn + PFN_UP(size);

> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		section_nr = pfn_to_section_nr(pfn);
> +		if (!present_section_nr(section_nr));

The ';' should be removed. Otherwise, this function always return true...

Thanks
Wen Congyang

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
> +
>  /*
>   * register_memory - Setup a sysfs device for a memory block
>   */
> Index: linux-3.5-rc6/include/linux/memory.h
> ===================================================================
> --- linux-3.5-rc6.orig/include/linux/memory.h	2012-07-17 11:18:00.693477455 +0900
> +++ linux-3.5-rc6/include/linux/memory.h	2012-07-17 11:20:54.632302919 +0900
> @@ -106,6 +106,10 @@ static inline int memory_isolate_notify(
>  {
>  	return 0;
>  }
> +static inline bool is_memblk_offline(unsigned long start, unsigned long size)
> +{
> +	return false;
> +}
>  #else
>  extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
> @@ -120,6 +124,7 @@ extern int memory_isolate_notify(unsigne
>  extern struct memory_block *find_memory_block_hinted(struct mem_section *,
>  							struct memory_block *);
>  extern struct memory_block *find_memory_block(struct mem_section *);
> +extern bool is_memblk_offline(unsigned long start, unsigned long size);
>  #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>  enum mem_add_context { BOOT, HOTPLUG };
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
