Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id A48CA6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 23:09:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 15DE83EE0BC
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:09:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB8DA45DEB4
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:09:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C478645DE7E
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:09:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B84B31DB8040
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:09:53 +0900 (JST)
Received: from g01jpexchyt04.g01.fujitsu.local (g01jpexchyt04.g01.fujitsu.local [10.128.194.43])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A6F41DB803B
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:09:53 +0900 (JST)
Message-ID: <4FED1C65.7010902@jp.fujitsu.com>
Date: Fri, 29 Jun 2012 12:09:25 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/12] memory-hotplug : remove /sys/firmware/memmap/X
 sysfs
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9E5F.4070205@jp.fujitsu.com> <4FEBFA8D.5040607@cn.fujitsu.com> <4FEC10CB.3060403@jp.fujitsu.com> <4FEC17F8.1000405@cn.fujitsu.com>
In-Reply-To: <4FEC17F8.1000405@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/06/28 17:38, Wen Congyang wrote:
> At 06/28/2012 04:07 PM, Yasuaki Ishimatsu Wrote:
>> Hi Wen,
>>
>> 2012/06/28 15:32, Wen Congyang wrote:
>>> At 06/27/2012 01:47 PM, Yasuaki Ishimatsu Wrote:
>>>> When (hot)adding memory into system, /sys/firmware/memmap/X/{end,
>>>> start, type}
>>>> sysfs files are created. But there is no code to remove these files.
>>>> The patch
>>>> implements the function to remove them.
>>>>
>>>> Note : The code does not free firmware_map_entry since there is no
>>>> way to free
>>>>          memory which is allocated by bootmem.
>>>>
>>>> CC: Len Brown <len.brown@intel.com>
>>>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>>>> CC: Paul Mackerras <paulus@samba.org>
>>>> CC: Christoph Lameter <cl@linux.com>
>>>> Cc: Minchan Kim <minchan.kim@gmail.com>
>>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>> CC: Wen Congyang <wency@cn.fujitsu.com>
>>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>
>>>> ---
>>>>    drivers/firmware/memmap.c    |   71
>>>> +++++++++++++++++++++++++++++++++++++++++++
>>>>    include/linux/firmware-map.h |    6 +++
>>>>    mm/memory_hotplug.c          |    6 +++
>>>>    3 files changed, 82 insertions(+), 1 deletion(-)
>>>>
>>>> Index: linux-3.5-rc4/mm/memory_hotplug.c
>>>> ===================================================================
>>>> --- linux-3.5-rc4.orig/mm/memory_hotplug.c    2012-06-26
>>>> 13:37:30.546288901 +0900
>>>> +++ linux-3.5-rc4/mm/memory_hotplug.c    2012-06-26
>>>> 13:44:37.069955820 +0900
>>>> @@ -661,7 +661,11 @@ EXPORT_SYMBOL_GPL(add_memory);
>>>>
>>>>    int remove_memory(int nid, u64 start, u64 size)
>>>>    {
>>>> -    return -EBUSY;
>>>> +    lock_memory_hotplug();
>>>> +    /* remove memmap entry */
>>>> +    firmware_map_remove(start, start + size, "System RAM");
>>>> +    unlock_memory_hotplug();
>>>> +    return 0;
>>>>
>>>>    }
>>>>    EXPORT_SYMBOL_GPL(remove_memory);
>>>> Index: linux-3.5-rc4/include/linux/firmware-map.h
>>>> ===================================================================
>>>> --- linux-3.5-rc4.orig/include/linux/firmware-map.h    2012-06-25
>>>> 04:53:04.000000000 +0900
>>>> +++ linux-3.5-rc4/include/linux/firmware-map.h    2012-06-26
>>>> 13:44:37.070955807 +0900
>>>> @@ -25,6 +25,7 @@
>>>>
>>>>    int firmware_map_add_early(u64 start, u64 end, const char *type);
>>>>    int firmware_map_add_hotplug(u64 start, u64 end, const char *type);
>>>> +int firmware_map_remove(u64 start, u64 end, const char *type);
>>>>
>>>>    #else /* CONFIG_FIRMWARE_MEMMAP */
>>>>
>>>> @@ -38,6 +39,11 @@ static inline int firmware_map_add_hotpl
>>>>        return 0;
>>>>    }
>>>>
>>>> +static inline int firmware_map_remove(u64 start, u64 end, const char
>>>> *type)
>>>> +{
>>>> +    return 0;
>>>> +}
>>>> +
>>>>    #endif /* CONFIG_FIRMWARE_MEMMAP */
>>>>
>>>>    #endif /* _LINUX_FIRMWARE_MAP_H */
>>>> Index: linux-3.5-rc4/drivers/firmware/memmap.c
>>>> ===================================================================
>>>> --- linux-3.5-rc4.orig/drivers/firmware/memmap.c    2012-06-25
>>>> 04:53:04.000000000 +0900
>>>> +++ linux-3.5-rc4/drivers/firmware/memmap.c    2012-06-26
>>>> 13:47:17.606948898 +0900
>>>> @@ -123,6 +123,16 @@ static int firmware_map_add_entry(u64 st
>>>>        return 0;
>>>>    }
>>>>
>>>> +/**
>>>> + * firmware_map_remove_entry() - Does the real work to remove a
>>>> firmware
>>>> + * memmap entry.
>>>> + * @entry: removed entry.
>>>> + **/
>>>> +static inline void firmware_map_remove_entry(struct
>>>> firmware_map_entry *entry)
>>>> +{
>>>> +    list_del(&entry->list);
>>>> +}
>>>> +
>>>>    /*
>>>>     * Add memmap entry on sysfs
>>>>     */
>>>> @@ -144,6 +154,31 @@ static int add_sysfs_fw_map_entry(struct
>>>>        return 0;
>>>>    }
>>>>
>>>> +/*
>>>> + * Remove memmap entry on sysfs
>>>> + */
>>>> +static inline void remove_sysfs_fw_map_entry(struct
>>>> firmware_map_entry *entry)
>>>> +{
>>>> +    kobject_del(&entry->kobj);
>>>> +}
>>>> +
>>>> +/*
>>>> + * Search memmap entry
>>>> + */
>>>> +
>>>> +struct firmware_map_entry * __meminit
>>>> +find_firmware_map_entry(u64 start, u64 end, const char *type)
>>>> +{
>>>> +    struct firmware_map_entry *entry;
>>>> +
>>>> +    list_for_each_entry(entry, &map_entries, list)
>>>> +        if ((entry->start == start) && (entry->end == end) &&
>>>> +            (!strcmp(entry->type, type)))
>>>> +            return entry;
>>>> +
>>>> +    return NULL;
>>>> +}
>>>> +
>>>>    /**
>>>>     * firmware_map_add_hotplug() - Adds a firmware mapping entry when
>>>> we do
>>>>     * memory hotplug.
>>>> @@ -196,6 +231,42 @@ int __init firmware_map_add_early(u64 st
>>>>        return firmware_map_add_entry(start, end, type, entry);
>>>>    }
>>>>
>>>> +void release_firmware_map_entry(struct firmware_map_entry *entry)
>>>> +{
>>>> +    /*
>>>> +     * FIXME : There is no idea.
>>>> +     *         How to free the entry which allocated bootmem?
>>>> +     */
>>>> +}
>>>> +
>>>> +/**
>>>> + * firmware_map_remove() - remove a firmware mapping entry
>>>> + * @start: Start of the memory range.
>>>> + * @end:   End of the memory range (inclusive).
>>>> + * @type:  Type of the memory range.
>>>> + *
>>>> + * removes a firmware mapping entry.
>>>> + *
>>>> + * Returns 0 on success, or -EINVAL if no entry.
>>>> + **/
>>>> +int __meminit firmware_map_remove(u64 start, u64 end, const char *type)
>>>> +{
>>>> +    struct firmware_map_entry *entry;
>>>> +
>>>> +    entry = find_firmware_map_entry(start, end, type);
>>>
>>> Hmm, we cannot find the entry easily, because the end can be:
>>> 1. start + size
>>> 2. start + size - 1
>>>
>>> So, We should fix this bug first.
>>
>> This is not a bug.
>>
>> start and size arguments of firmware_map_remove() include
>> acpi_memory_info->{start_addr, length}. And when creating a
>> firmware_map_entry,
>> the entry is created by acpi_memory_info->{start_addr, length}. So I don't
>> think that we need care your comment.
>
> If the memory device is hotpluged before the os starts, and the memory
> map is included in e820 map, the entry will be created by firmware_map_add_early().
>
> The function firmware_map_add_early() is called by e820_reserve_resources():
> =====================
> 	for (i = 0; i < e820_saved.nr_map; i++) {
> 		struct e820entry *entry = &e820_saved.map[i];
> 		firmware_map_add_early(entry->addr,
> 			entry->addr + entry->size - 1,
> 			e820_type_to_string(entry->type));
> 	}
> =====================
>
> Note: the end is addr + size - 1, not addr + size.
>
> In such case, you cannot find the entry.

Thank you for your explanation. I understood it.
end argument of firmware_map_add_hotplug() has always "addr + size",
not "addr + size - 1". I think that changing argument of
firmware_map_add_early() is high risk since the function has been used
since early times. So, I will unify to "addr + size - 1".

Thanks,
Yasuaki Ishimatsu

> Thanks
> Wen Congyang
>
>>
>>>
>>>> +    if (!entry)
>>>> +        return -EINVAL;
>>>> +
>>>> +    /* remove the memmap entry */
>>>> +    remove_sysfs_fw_map_entry(entry);
>>>> +
>>>> +    firmware_map_remove_entry(entry);
>>>> +
>>>> +    release_firmware_map_entry(entry);
>>>
>>> I guess you want to free the memory in the above function. But I think
>>> it is
>>> not a good idea to free it here. We should free it when the
>>> entry->kobj's kref
>>> is decreased to 0.
>>
>> Thanks.
>> I'll update your comment at next version.
>>
>> Thanks,
>> Yasuaki Ishimatsu
>>
>>>
>>> Thanks
>>> Wen Congyang
>>>
>>>> +
>>>> +    return 0;
>>>> +}
>>>> +
>>>>    /*
>>>>     * Sysfs functions
>>>> -------------------------------------------------------------
>>>>     */
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe
>>>> linux-kernel" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>>
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>
>>
>>
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
