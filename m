Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 069506B0093
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 04:29:17 -0500 (EST)
Message-ID: <50AB4EE6.1080609@cn.fujitsu.com>
Date: Tue, 20 Nov 2012 17:35:34 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 11/12] memory-hotplug: remove sysfs file of node
References: <1351763083-7905-1-git-send-email-wency@cn.fujitsu.com> <1351763083-7905-12-git-send-email-wency@cn.fujitsu.com> <50AA0537.1000501@jp.fujitsu.com>
In-Reply-To: <50AA0537.1000501@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

At 11/19/2012 06:08 PM, Yasuaki Ishimatsu Wrote:
> Hi Wen,
> 
> This patch cannot be applied, if I apply latest acpi framework's patch-set:
> 
> https://lkml.org/lkml/2012/11/15/21
> 
> Because acpi_memory_disable_device() is gone by the patch-set.

The patchset is not for pm tree, so I don't apply the patchset in pm tree
before generating this patchset.

Thanks
Wen Congyang

> 
> I updated the patch and attached it on the mail.
> 
> 2012/11/01 18:44, Wen Congyang wrote:
>> This patch introduces a new function try_offline_node() to
>> remove sysfs file of node when all memory sections of this
>> node are removed. If some memory sections of this node are
>> not removed, this function does nothing.
>>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>> ---
>>   drivers/acpi/acpi_memhotplug.c |  8 +++++-
>>   include/linux/memory_hotplug.h |  2 +-
>>   mm/memory_hotplug.c            | 58 ++++++++++++++++++++++++++++++++++++++++--
>>   3 files changed, 64 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
>> index 24c807f..0780f99 100644
>> --- a/drivers/acpi/acpi_memhotplug.c
>> +++ b/drivers/acpi/acpi_memhotplug.c
>> @@ -310,7 +310,9 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
>>   {
>>   	int result;
>>   	struct acpi_memory_info *info, *n;
>> +	int node;
>>   
>> +	node = acpi_get_node(mem_device->device->handle);
>>   
>>   	/*
>>   	 * Ask the VM to offline this memory range.
>> @@ -318,7 +320,11 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
>>   	 */
>>   	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
>>   		if (info->enabled) {
>> -			result = remove_memory(info->start_addr, info->length);
>> +			if (node < 0)
>> +				node = memory_add_physaddr_to_nid(
>> +					info->start_addr);
>> +			result = remove_memory(node, info->start_addr,
>> +				info->length);
>>   			if (result)
>>   				return result;
>>   		}
>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>> index d4c4402..7b4cfe6 100644
>> --- a/include/linux/memory_hotplug.h
>> +++ b/include/linux/memory_hotplug.h
>> @@ -231,7 +231,7 @@ extern int arch_add_memory(int nid, u64 start, u64 size);
>>   extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>>   extern int offline_memory_block(struct memory_block *mem);
>>   extern bool is_memblock_offlined(struct memory_block *mem);
>> -extern int remove_memory(u64 start, u64 size);
>> +extern int remove_memory(int node, u64 start, u64 size);
>>   extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>>   								int nr_pages);
>>   extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 7bcced0..d965da3 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -29,6 +29,7 @@
>>   #include <linux/suspend.h>
>>   #include <linux/mm_inline.h>
>>   #include <linux/firmware-map.h>
>> +#include <linux/stop_machine.h>
>>   
>>   #include <asm/tlbflush.h>
>>   
>> @@ -1299,7 +1300,58 @@ static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
>>   	return ret;
>>   }
>>   
>> -int __ref remove_memory(u64 start, u64 size)
>> +static int check_cpu_on_node(void *data)
>> +{
>> +	struct pglist_data *pgdat = data;
>> +	int cpu;
>> +
>> +	for_each_present_cpu(cpu) {
>> +		if (cpu_to_node(cpu) == pgdat->node_id)
>> +			/*
>> +			 * the cpu on this node isn't removed, and we can't
>> +			 * offline this node.
>> +			 */
>> +			return -EBUSY;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +/* offline the node if all memory sections of this node are removed */
>> +static void try_offline_node(int nid)
>> +{
>> +	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
>> +	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
>> +	unsigned long pfn;
>> +
>> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>> +		unsigned long section_nr = pfn_to_section_nr(pfn);
>> +
>> +		if (!present_section_nr(section_nr))
>> +			continue;
>> +
>> +		if (pfn_to_nid(pfn) != nid)
>> +			continue;
>> +
>> +		/*
>> +		 * some memory sections of this node are not removed, and we
>> +		 * can't offline node now.
>> +		 */
>> +		return;
>> +	}
>> +
>> +	if (stop_machine(check_cpu_on_node, NODE_DATA(nid), NULL))
>> +		return;
>> +
>> +	/*
>> +	 * all memory/cpu of this node are removed, we can offline this
>> +	 * node now.
>> +	 */
>> +	node_set_offline(nid);
>> +	unregister_one_node(nid);
>> +}
>> +
>> +int __ref remove_memory(int nid, u64 start, u64 size)
>>   {
>>   	unsigned long start_pfn, end_pfn;
>>   	int ret = 0;
>> @@ -1346,6 +1398,8 @@ repeat:
>>   
>>   	arch_remove_memory(start, size);
>>   
>> +	try_offline_node(nid);
>> +
>>   	unlock_memory_hotplug();
>>   
>>   	return 0;
>> @@ -1355,7 +1409,7 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>>   {
>>   	return -EINVAL;
>>   }
>> -int remove_memory(u64 start, u64 size)
>> +int remove_memory(int nid, u64 start, u64 size)
>>   {
>>   	return -EINVAL;
>>   }
>>
> 
> ---
> This patch introduces a new function try_offline_node() to
> remove sysfs file of node when all memory sections of this
> node are removed. If some memory sections of this node are
> not removed, this function does nothing.
> 
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---
>  drivers/acpi/acpi_memhotplug.c |    9 +++++-
>  include/linux/memory_hotplug.h |    2 -
>  mm/memory_hotplug.c            |   58 +++++++++++++++++++++++++++++++++++++++--
>  3 files changed, 65 insertions(+), 4 deletions(-)
> 
> Index: linux-3.7-rc6/drivers/acpi/acpi_memhotplug.c
> ===================================================================
> --- linux-3.7-rc6.orig/drivers/acpi/acpi_memhotplug.c	2012-11-19 16:16:55.161912688 +0900
> +++ linux-3.7-rc6/drivers/acpi/acpi_memhotplug.c	2012-11-19 16:17:05.346912109 +0900
> @@ -295,6 +295,9 @@ static int acpi_memory_remove_memory(str
>  {
>  	int result = 0;
>  	struct acpi_memory_info *info, *n;
> +	int node;
> +
> +	node = acpi_get_node(mem_device->device->handle);
>  
>  	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
>  		if (info->failed)
> @@ -308,7 +311,11 @@ static int acpi_memory_remove_memory(str
>  			 */
>  			return -EBUSY;
>  
> -		result = remove_memory(info->start_addr, info->length);
> +		if (node < 0)
> +			node = memory_add_physaddr_to_nid(
> +				info->start_addr);
> +		result = remove_memory(node, info->start_addr,
> +			info->length);
>  		if (result)
>  			return result;
>  
> Index: linux-3.7-rc6/include/linux/memory_hotplug.h
> ===================================================================
> --- linux-3.7-rc6.orig/include/linux/memory_hotplug.h	2012-11-19 16:16:55.167912687 +0900
> +++ linux-3.7-rc6/include/linux/memory_hotplug.h	2012-11-19 16:17:05.348912109 +0900
> @@ -242,7 +242,7 @@ extern int arch_add_memory(int nid, u64 
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>  extern int offline_memory_block(struct memory_block *mem);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> -extern int remove_memory(u64 start, u64 size);
> +extern int remove_memory(int node, u64 start, u64 size);
>  extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>  								int nr_pages);
>  extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
> Index: linux-3.7-rc6/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.7-rc6.orig/mm/memory_hotplug.c	2012-11-19 16:16:55.164912687 +0900
> +++ linux-3.7-rc6/mm/memory_hotplug.c	2012-11-19 16:17:05.356912108 +0900
> @@ -29,6 +29,7 @@
>  #include <linux/suspend.h>
>  #include <linux/mm_inline.h>
>  #include <linux/firmware-map.h>
> +#include <linux/stop_machine.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -1652,7 +1653,58 @@ static int is_memblock_offlined_cb(struc
>  	return ret;
>  }
>  
> -int __ref remove_memory(u64 start, u64 size)
> +static int check_cpu_on_node(void *data)
> +{
> +	struct pglist_data *pgdat = data;
> +	int cpu;
> +
> +	for_each_present_cpu(cpu) {
> +		if (cpu_to_node(cpu) == pgdat->node_id)
> +			/*
> +			 * the cpu on this node isn't removed, and we can't
> +			 * offline this node.
> +			 */
> +			return -EBUSY;
> +	}
> +
> +	return 0;
> +}
> +
> +/* offline the node if all memory sections of this node are removed */
> +static void try_offline_node(int nid)
> +{
> +	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
> +	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
> +	unsigned long pfn;
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		unsigned long section_nr = pfn_to_section_nr(pfn);
> +
> +		if (!present_section_nr(section_nr))
> +			continue;
> +
> +		if (pfn_to_nid(pfn) != nid)
> +			continue;
> +
> +		/*
> +		 * some memory sections of this node are not removed, and we
> +		 * can't offline node now.
> +		 */
> +		return;
> +	}
> +
> +	if (stop_machine(check_cpu_on_node, NODE_DATA(nid), NULL))
> +		return;
> +
> +	/*
> +	 * all memory/cpu of this node are removed, we can offline this
> +	 * node now.
> +	 */
> +	node_set_offline(nid);
> +	unregister_one_node(nid);
> +}
> +
> +int __ref remove_memory(int nid, u64 start, u64 size)
>  {
>  	unsigned long start_pfn, end_pfn;
>  	int ret = 0;
> @@ -1699,6 +1751,8 @@ repeat:
>  
>  	arch_remove_memory(start, size);
>  
> +	try_offline_node(nid);
> +
>  	unlock_memory_hotplug();
>  
>  	return 0;
> @@ -1708,7 +1762,7 @@ int offline_pages(unsigned long start_pf
>  {
>  	return -EINVAL;
>  }
> -int remove_memory(u64 start, u64 size)
> +int remove_memory(int nid, u64 start, u64 size)
>  {
>  	return -EINVAL;
>  }
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
