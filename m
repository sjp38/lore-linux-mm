Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9D5F06B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 02:47:18 -0400 (EDT)
Message-ID: <519B1923.6030107@cn.fujitsu.com>
Date: Tue, 21 May 2013 14:50:11 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 v2, RFC] ACPI / memhotplug: Bind removable memory
 blocks to ACPI device nodes
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <1583356.7oqZ7gBy2q@vostro.rjw.lan> <2376818.CRj1BTLk0Y@vostro.rjw.lan> <11495390.fLTYR4Utem@vostro.rjw.lan>
In-Reply-To: <11495390.fLTYR4Utem@vostro.rjw.lan>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, vasilis.liaskovitis@profitbricks.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org

Hi Rafael,

Seems OK to me.

Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>

Thanks. :)

On 05/04/2013 07:12 PM, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki<rafael.j.wysocki@intel.com>
>
> During ACPI memory hotplug configuration bind memory blocks residing
> in modules removable through the standard ACPI mechanism to struct
> acpi_device objects associated with ACPI namespace objects
> representing those modules.  Accordingly, unbind those memory blocks
> from the struct acpi_device objects when the memory modules in
> question are being removed.
>
> When "offline" operation for devices representing memory blocks is
> introduced, this will allow the ACPI core's device hot-remove code to
> use it to carry out remove_memory() for those memory blocks and check
> the results of that before it actually removes the modules holding
> them from the system.
>
> Since walk_memory_range() is used for accessing all memory blocks
> corresponding to a given ACPI namespace object, it is exported from
> memory_hotplug.c so that the code in acpi_memhotplug.c can use it.
>
> Signed-off-by: Rafael J. Wysocki<rafael.j.wysocki@intel.com>
> ---
>   drivers/acpi/acpi_memhotplug.c |   53 ++++++++++++++++++++++++++++++++++++++---
>   include/linux/memory_hotplug.h |    2 +
>   mm/memory_hotplug.c            |    4 ++-
>   3 files changed, 55 insertions(+), 4 deletions(-)
>
> Index: linux-pm/mm/memory_hotplug.c
> ===================================================================
> --- linux-pm.orig/mm/memory_hotplug.c
> +++ linux-pm/mm/memory_hotplug.c
> @@ -1618,6 +1618,7 @@ int offline_pages(unsigned long start_pf
>   {
>   	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
>   }
> +#endif /* CONFIG_MEMORY_HOTREMOVE */
>
>   /**
>    * walk_memory_range - walks through all mem sections in [start_pfn, end_pfn)
> @@ -1631,7 +1632,7 @@ int offline_pages(unsigned long start_pf
>    *
>    * Returns the return value of func.
>    */
> -static int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
> +int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
>   		void *arg, int (*func)(struct memory_block *, void *))
>   {
>   	struct memory_block *mem = NULL;
> @@ -1668,6 +1669,7 @@ static int walk_memory_range(unsigned lo
>   	return 0;
>   }
>
> +#ifdef CONFIG_MEMORY_HOTREMOVE
>   /**
>    * offline_memory_block_cb - callback function for offlining memory block
>    * @mem: the memory block to be offlined
> Index: linux-pm/include/linux/memory_hotplug.h
> ===================================================================
> --- linux-pm.orig/include/linux/memory_hotplug.h
> +++ linux-pm/include/linux/memory_hotplug.h
> @@ -245,6 +245,8 @@ static inline int is_mem_section_removab
>   static inline void try_offline_node(int nid) {}
>   #endif /* CONFIG_MEMORY_HOTREMOVE */
>
> +extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
> +		void *arg, int (*func)(struct memory_block *, void *));
>   extern int mem_online_node(int nid);
>   extern int add_memory(int nid, u64 start, u64 size);
>   extern int arch_add_memory(int nid, u64 start, u64 size);
> Index: linux-pm/drivers/acpi/acpi_memhotplug.c
> ===================================================================
> --- linux-pm.orig/drivers/acpi/acpi_memhotplug.c
> +++ linux-pm/drivers/acpi/acpi_memhotplug.c
> @@ -28,6 +28,7 @@
>    */
>
>   #include<linux/acpi.h>
> +#include<linux/memory.h>
>   #include<linux/memory_hotplug.h>
>
>   #include "internal.h"
> @@ -166,13 +167,50 @@ static int acpi_memory_check_device(stru
>   	return 0;
>   }
>
> +static unsigned long acpi_meminfo_start_pfn(struct acpi_memory_info *info)
> +{
> +	return PFN_DOWN(info->start_addr);
> +}
> +
> +static unsigned long acpi_meminfo_end_pfn(struct acpi_memory_info *info)
> +{
> +	return PFN_UP(info->start_addr + info->length-1);
> +}
> +
> +static int acpi_bind_memblk(struct memory_block *mem, void *arg)
> +{
> +	return acpi_bind_one(&mem->dev, (acpi_handle)arg);
> +}
> +
> +static int acpi_bind_memory_blocks(struct acpi_memory_info *info,
> +				   acpi_handle handle)
> +{
> +	return walk_memory_range(acpi_meminfo_start_pfn(info),
> +				 acpi_meminfo_end_pfn(info), (void *)handle,
> +				 acpi_bind_memblk);
> +}
> +
> +static int acpi_unbind_memblk(struct memory_block *mem, void *arg)
> +{
> +	acpi_unbind_one(&mem->dev);
> +	return 0;
> +}
> +
> +static void acpi_unbind_memory_blocks(struct acpi_memory_info *info,
> +				      acpi_handle handle)
> +{
> +	walk_memory_range(acpi_meminfo_start_pfn(info),
> +			  acpi_meminfo_end_pfn(info), NULL, acpi_unbind_memblk);
> +}
> +
>   static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>   {
> +	acpi_handle handle = mem_device->device->handle;
>   	int result, num_enabled = 0;
>   	struct acpi_memory_info *info;
>   	int node;
>
> -	node = acpi_get_node(mem_device->device->handle);
> +	node = acpi_get_node(handle);
>   	/*
>   	 * Tell the VM there is more memory here...
>   	 * Note: Assume that this function returns zero on success
> @@ -203,6 +241,12 @@ static int acpi_memory_enable_device(str
>   		if (result&&  result != -EEXIST)
>   			continue;
>
> +		result = acpi_bind_memory_blocks(info, handle);
> +		if (result) {
> +			acpi_unbind_memory_blocks(info, handle);
> +			return -ENODEV;
> +		}
> +
>   		info->enabled = 1;
>
>   		/*
> @@ -229,10 +273,11 @@ static int acpi_memory_enable_device(str
>
>   static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>   {
> +	acpi_handle handle = mem_device->device->handle;
>   	int result = 0, nid;
>   	struct acpi_memory_info *info, *n;
>
> -	nid = acpi_get_node(mem_device->device->handle);
> +	nid = acpi_get_node(handle);
>
>   	list_for_each_entry_safe(info, n,&mem_device->res_list, list) {
>   		if (!info->enabled)
> @@ -240,6 +285,8 @@ static int acpi_memory_remove_memory(str
>
>   		if (nid<  0)
>   			nid = memory_add_physaddr_to_nid(info->start_addr);
> +
> +		acpi_unbind_memory_blocks(info, handle);
>   		result = remove_memory(nid, info->start_addr, info->length);
>   		if (result)
>   			return result;
> @@ -300,7 +347,7 @@ static int acpi_memory_device_add(struct
>   	if (result) {
>   		dev_err(&device->dev, "acpi_memory_enable_device() error\n");
>   		acpi_memory_device_free(mem_device);
> -		return -ENODEV;
> +		return result;
>   	}
>
>   	dev_dbg(&device->dev, "Memory device configured by ACPI\n");
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
