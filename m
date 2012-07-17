Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A22FC6B005A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 20:30:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 799AB3EE0C1
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:30:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59C1445DE55
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:30:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E1F445DE53
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:30:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E4B7E08005
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:30:33 +0900 (JST)
Received: from g01jpexchyt10.g01.fujitsu.local (g01jpexchyt10.g01.fujitsu.local [10.128.194.49])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BA2AE1DB803B
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:30:32 +0900 (JST)
Message-ID: <5004B213.8010304@jp.fujitsu.com>
Date: Tue, 17 Jul 2012 09:30:11 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 4/13] memory-hotplug : remove /sys/firmware/memmap/X
 sysfs
References: <4FFAB0A2.8070304@jp.fujitsu.com> <4FFAB1BA.9040801@jp.fujitsu.com> <50037D3A.4090309@cn.fujitsu.com>
In-Reply-To: <50037D3A.4090309@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/07/16 11:32, Wen Congyang wrote:
> At 07/09/2012 06:26 PM, Yasuaki Ishimatsu Wrote:
>> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
>> sysfs files are created. But there is no code to remove these files. The patch
>> implements the function to remove them.
>>
>> Note : The code does not free firmware_map_entry since there is no way to free
>>         memory which is allocated by bootmem.
>>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
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
>>   drivers/firmware/memmap.c    |   78 ++++++++++++++++++++++++++++++++++++++++++-
>>   include/linux/firmware-map.h |    6 +++
>>   mm/memory_hotplug.c          |    6 ++-
>>   3 files changed, 88 insertions(+), 2 deletions(-)
>>
>> Index: linux-3.5-rc6/mm/memory_hotplug.c
>> ===================================================================
>> --- linux-3.5-rc6.orig/mm/memory_hotplug.c	2012-07-09 18:23:13.323844923 +0900
>> +++ linux-3.5-rc6/mm/memory_hotplug.c	2012-07-09 18:23:19.522767424 +0900
>> @@ -661,7 +661,11 @@ EXPORT_SYMBOL_GPL(add_memory);
>>
>>   int remove_memory(int nid, u64 start, u64 size)
>>   {
>> -	return -EBUSY;
>> +	lock_memory_hotplug();
>> +	/* remove memmap entry */
>> +	firmware_map_remove(start, start + size - 1, "System RAM");
>> +	unlock_memory_hotplug();
>> +	return 0;
>>
>>   }
>>   EXPORT_SYMBOL_GPL(remove_memory);
>> Index: linux-3.5-rc6/include/linux/firmware-map.h
>> ===================================================================
>> --- linux-3.5-rc6.orig/include/linux/firmware-map.h	2012-07-09 18:23:09.532892314 +0900
>> +++ linux-3.5-rc6/include/linux/firmware-map.h	2012-07-09 18:23:19.523767412 +0900
>> @@ -25,6 +25,7 @@
>>
>>   int firmware_map_add_early(u64 start, u64 end, const char *type);
>>   int firmware_map_add_hotplug(u64 start, u64 end, const char *type);
>> +int firmware_map_remove(u64 start, u64 end, const char *type);
>>
>>   #else /* CONFIG_FIRMWARE_MEMMAP */
>>
>> @@ -38,6 +39,11 @@ static inline int firmware_map_add_hotpl
>>   	return 0;
>>   }
>>
>> +static inline int firmware_map_remove(u64 start, u64 end, const char *type)
>> +{
>> +	return 0;
>> +}
>> +
>>   #endif /* CONFIG_FIRMWARE_MEMMAP */
>>
>>   #endif /* _LINUX_FIRMWARE_MAP_H */
>> Index: linux-3.5-rc6/drivers/firmware/memmap.c
>> ===================================================================
>> --- linux-3.5-rc6.orig/drivers/firmware/memmap.c	2012-07-09 18:23:09.532892314 +0900
>> +++ linux-3.5-rc6/drivers/firmware/memmap.c	2012-07-09 18:25:46.371931554 +0900
>> @@ -21,6 +21,7 @@
>>   #include <linux/types.h>
>>   #include <linux/bootmem.h>
>>   #include <linux/slab.h>
>> +#include <linux/mm.h>
>>
>>   /*
>>    * Data types ------------------------------------------------------------------
>> @@ -79,7 +80,22 @@ static const struct sysfs_ops memmap_att
>>   	.show = memmap_attr_show,
>>   };
>>
>> +#define to_memmap_entry(obj) container_of(obj, struct firmware_map_entry, kobj)
>> +
>> +static void release_firmware_map_entry(struct kobject *kobj)
>> +{
>> +	struct firmware_map_entry *entry = to_memmap_entry(kobj);
>> +	struct page *head_page;
>> +
>> +	head_page = virt_to_head_page(entry);
>> +	if (PageSlab(head_page))
>> +		kfree(entry);
>> +
>> +	/* There is no way to free memory allocated from bootmem*/
>> +}
>> +
>>   static struct kobj_type memmap_ktype = {
>> +	.release	= release_firmware_map_entry,
>>   	.sysfs_ops	= &memmap_attr_ops,
>>   	.default_attrs	= def_attrs,
>>   };
>> @@ -123,6 +139,16 @@ static int firmware_map_add_entry(u64 st
>>   	return 0;
>>   }
>>
>> +/**
>> + * firmware_map_remove_entry() - Does the real work to remove a firmware
>> + * memmap entry.
>> + * @entry: removed entry.
>> + **/
>> +static inline void firmware_map_remove_entry(struct firmware_map_entry *entry)
>> +{
>> +	list_del(&entry->list);
>> +}
>> +
>>   /*
>>    * Add memmap entry on sysfs
>>    */
>> @@ -144,6 +170,31 @@ static int add_sysfs_fw_map_entry(struct
>>   	return 0;
>>   }
>>
>> +/*
>> + * Remove memmap entry on sysfs
>> + */
>> +static inline void remove_sysfs_fw_map_entry(struct firmware_map_entry *entry)
>> +{
>> +	kobject_put(&entry->kobj);
>> +}
>> +
>> +/*
>> + * Search memmap entry
>> + */
>> +
>> +struct firmware_map_entry * __meminit
>> +find_firmware_map_entry(u64 start, u64 end, const char *type)
>> +{
>> +	struct firmware_map_entry *entry;
>> +
>> +	list_for_each_entry(entry, &map_entries, list)
>> +		if ((entry->start == start) && (entry->end == end) &&
>> +		    (!strcmp(entry->type, type)))
>> +			return entry;
>> +
>> +	return NULL;
>> +}
>> +
>>   /**
>>    * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
>>    * memory hotplug.
>> @@ -196,6 +247,32 @@ int __init firmware_map_add_early(u64 st
>>   	return firmware_map_add_entry(start, end, type, entry);
>>   }
>>
>> +/**
>> + * firmware_map_remove() - remove a firmware mapping entry
>> + * @start: Start of the memory range.
>> + * @end:   End of the memory range (inclusive).
>> + * @type:  Type of the memory range.
>> + *
>> + * removes a firmware mapping entry.
>> + *
>> + * Returns 0 on success, or -EINVAL if no entry.
>> + **/
>> +int __meminit firmware_map_remove(u64 start, u64 end, const char *type)
>> +{
>> +	struct firmware_map_entry *entry;
>> +
>> +	entry = find_firmware_map_entry(start, end, type);
>> +	if (!entry)
>> +		return -EINVAL;
>> +
>> +	/* remove the memmap entry */
>> +	remove_sysfs_fw_map_entry(entry);
>> +
>> +	firmware_map_remove_entry(entry);
> 
> You should call firmware_map_remove_entry() before remove_sysfs_fw_map_entry(),
> otherwise it will cause kernel panicked(entry may be freed in remove_sysfs_fw_map_entry()).

You are right. I'll update it.

Thanks,
Yasuaki Ishimatsu

> 
> Thanks
> Wen Congyang
> 
>> +
>> +	return 0;
>> +}
>> +
>>   /*
>>    * Sysfs functions -------------------------------------------------------------
>>    */
>> @@ -218,7 +295,6 @@ static ssize_t type_show(struct firmware
>>   }
>>
>>   #define to_memmap_attr(_attr) container_of(_attr, struct memmap_attribute, attr)
>> -#define to_memmap_entry(obj) container_of(obj, struct firmware_map_entry, kobj)
>>
>>   static ssize_t memmap_attr_show(struct kobject *kobj,
>>   				struct attribute *attr, char *buf)
>>
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
