Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A00AF6B007B
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 04:42:51 -0400 (EDT)
Message-ID: <4FEAC891.7030808@cn.fujitsu.com>
Date: Wed, 27 Jun 2012 16:47:13 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/12] memory-hotplug : rename remove_memory to offline_memory
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9D5C.1080508@jp.fujitsu.com> <4FEAB2E1.3090200@cn.fujitsu.com>
In-Reply-To: <4FEAB2E1.3090200@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 06/27/2012 03:14 PM, Wen Congyang Wrote:
> At 06/27/2012 01:42 PM, Yasuaki Ishimatsu Wrote:
>> remove_memory() does not remove memory but just offlines memory. The patch
>> changes name of it to offline_memory().
> 
> There are 3 functions in the kernel:
> 1. add_memory()
> 2. online_pages()
> 3. remove_memory()
> 
> So I think offline_pages() is better than offline_memory().

There is already a function named offline_pages(). So we
should call offline_pages() instead of remove_memory() in
memory_block_action(), and there is no need to rename
remove_memory().

Thanks
Wen Congyang

> 
> Thanks
> Wen Congyang
>>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: Paul Mackerras <paulus@samba.org>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> CC: Wen Congyang <wency@cn.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> ---
>>  drivers/acpi/acpi_memhotplug.c |    2 +-
>>  drivers/base/memory.c          |    4 ++--
>>  include/linux/memory_hotplug.h |    2 +-
>>  mm/memory_hotplug.c            |    6 +++---
>>  4 files changed, 7 insertions(+), 7 deletions(-)
>>
>> Index: linux-3.5-rc4/drivers/acpi/acpi_memhotplug.c
>> ===================================================================
>> --- linux-3.5-rc4.orig/drivers/acpi/acpi_memhotplug.c	2012-06-25 04:53:04.000000000 +0900
>> +++ linux-3.5-rc4/drivers/acpi/acpi_memhotplug.c	2012-06-26 13:48:38.263940481 +0900
>> @@ -318,7 +318,7 @@ static int acpi_memory_disable_device(st
>>  	 */
>>  	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
>>  		if (info->enabled) {
>> -			result = remove_memory(info->start_addr, info->length);
>> +			result = offline_memory(info->start_addr, info->length);
>>  			if (result)
>>  				return result;
>>  		}
>> Index: linux-3.5-rc4/drivers/base/memory.c
>> ===================================================================
>> --- linux-3.5-rc4.orig/drivers/base/memory.c	2012-06-25 04:53:04.000000000 +0900
>> +++ linux-3.5-rc4/drivers/base/memory.c	2012-06-26 13:48:46.072842803 +0900
>> @@ -266,8 +266,8 @@ memory_block_action(unsigned long phys_i
>>  			break;
>>  		case MEM_OFFLINE:
>>  			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
>> -			ret = remove_memory(start_paddr,
>> -					    nr_pages << PAGE_SHIFT);
>> +			ret = offline_memory(start_paddr,
>> +					     nr_pages << PAGE_SHIFT);
>>  			break;
>>  		default:
>>  			WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
>> Index: linux-3.5-rc4/mm/memory_hotplug.c
>> ===================================================================
>> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-06-25 04:53:04.000000000 +0900
>> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-06-26 13:48:46.072842803 +0900
>> @@ -990,7 +990,7 @@ out:
>>  	return ret;
>>  }
>>
>> -int remove_memory(u64 start, u64 size)
>> +int offline_memory(u64 start, u64 size)
>>  {
>>  	unsigned long start_pfn, end_pfn;
>>
>> @@ -999,9 +999,9 @@ int remove_memory(u64 start, u64 size)
>>  	return offline_pages(start_pfn, end_pfn, 120 * HZ);
>>  }
>>  #else
>> -int remove_memory(u64 start, u64 size)
>> +int offline_memory(u64 start, u64 size)
>>  {
>>  	return -EINVAL;
>>  }
>>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>> -EXPORT_SYMBOL_GPL(remove_memory);
>> +EXPORT_SYMBOL_GPL(offline_memory);
>> Index: linux-3.5-rc4/include/linux/memory_hotplug.h
>> ===================================================================
>> --- linux-3.5-rc4.orig/include/linux/memory_hotplug.h	2012-06-25 04:53:04.000000000 +0900
>> +++ linux-3.5-rc4/include/linux/memory_hotplug.h	2012-06-26 13:48:38.264940468 +0900
>> @@ -233,7 +233,7 @@ static inline int is_mem_section_removab
>>  extern int mem_online_node(int nid);
>>  extern int add_memory(int nid, u64 start, u64 size);
>>  extern int arch_add_memory(int nid, u64 start, u64 size);
>> -extern int remove_memory(u64 start, u64 size);
>> +extern int offline_memory(u64 start, u64 size);
>>  extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>>  								int nr_pages);
>>  extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
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
