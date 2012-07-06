Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 32AEC6B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 05:16:03 -0400 (EDT)
Message-ID: <4FF6ADD9.7040600@cn.fujitsu.com>
Date: Fri, 06 Jul 2012 17:20:25 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 4/13] memory-hotplug : remove /sys/firmware/memmap/X
 sysfs
References: <4FF287C3.4030901@jp.fujitsu.com> <4FF28996.10702@jp.fujitsu.com> <4FF2929B.7030004@cn.fujitsu.com> <4FF3CA65.1020300@jp.fujitsu.com> <4FF3CFDC.50802@cn.fujitsu.com> <4FF3DA1E.9060505@jp.fujitsu.com> <4FF41484.3070806@cn.fujitsu.com> <4FF6A17C.6000808@jp.fujitsu.com>
In-Reply-To: <4FF6A17C.6000808@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 07/06/2012 04:27 PM, Yasuaki Ishimatsu Wrote:
> Hi Wen,
> 
> 2012/07/04 19:01, Wen Congyang wrote:
>> At 07/04/2012 01:52 PM, Yasuaki Ishimatsu Wrote:
>>> Hi Wen,
>>>
>>> 2012/07/04 14:08, Wen Congyang wrote:
>>>> At 07/04/2012 12:45 PM, Yasuaki Ishimatsu Wrote:
>>>>> Hi Wen,
>>>>>
>>>>> 2012/07/03 15:35, Wen Congyang wrote:
>>>>>> At 07/03/2012 01:56 PM, Yasuaki Ishimatsu Wrote:
>>>>>>> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
>>>>>>> sysfs files are created. But there is no code to remove these files. The patch
>>>>>>> implements the function to remove them.
>>>>>>>
>>>>>>> Note : The code does not free firmware_map_entry since there is no way to free
>>>>>>>           memory which is allocated by bootmem.
>>>>>>>
>>>>>>> CC: David Rientjes <rientjes@google.com>
>>>>>>> CC: Jiang Liu <liuj97@gmail.com>
>>>>>>> CC: Len Brown <len.brown@intel.com>
>>>>>>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>>>>>>> CC: Paul Mackerras <paulus@samba.org>
>>>>>>> CC: Christoph Lameter <cl@linux.com>
>>>>>>> Cc: Minchan Kim <minchan.kim@gmail.com>
>>>>>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>>>>>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>>>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>>>>
>>>>>>> ---
>>>>>>>     drivers/firmware/memmap.c    |   70 +++++++++++++++++++++++++++++++++++++++++++
>>>>>>>     include/linux/firmware-map.h |    6 +++
>>>>>>>     mm/memory_hotplug.c          |    6 +++
>>>>>>>     3 files changed, 81 insertions(+), 1 deletion(-)
>>>>>>>
>>>>>>> Index: linux-3.5-rc4/mm/memory_hotplug.c
>>>>>>> ===================================================================
>>>>>>> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:00.190240794 +0900
>>>>>>> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:03.549198802 +0900
>>>>>>> @@ -661,7 +661,11 @@ EXPORT_SYMBOL_GPL(add_memory);
>>>>>>>
>>>>>>>     int remove_memory(int nid, u64 start, u64 size)
>>>>>>>     {
>>>>>>> -	return -EBUSY;
>>>>>>> +	lock_memory_hotplug();
>>>>>>> +	/* remove memmap entry */
>>>>>>> +	firmware_map_remove(start, start + size - 1, "System RAM");
>>>>>>> +	unlock_memory_hotplug();
>>>>>>> +	return 0;
>>>>>>>
>>>>>>>     }
>>>>>>>     EXPORT_SYMBOL_GPL(remove_memory);
>>>>>>> Index: linux-3.5-rc4/include/linux/firmware-map.h
>>>>>>> ===================================================================
>>>>>>> --- linux-3.5-rc4.orig/include/linux/firmware-map.h	2012-07-03 14:21:45.766421116 +0900
>>>>>>> +++ linux-3.5-rc4/include/linux/firmware-map.h	2012-07-03 14:22:03.550198789 +0900
>>>>>>> @@ -25,6 +25,7 @@
>>>>>>>
>>>>>>>     int firmware_map_add_early(u64 start, u64 end, const char *type);
>>>>>>>     int firmware_map_add_hotplug(u64 start, u64 end, const char *type);
>>>>>>> +int firmware_map_remove(u64 start, u64 end, const char *type);
>>>>>>>
>>>>>>>     #else /* CONFIG_FIRMWARE_MEMMAP */
>>>>>>>
>>>>>>> @@ -38,6 +39,11 @@ static inline int firmware_map_add_hotpl
>>>>>>>     	return 0;
>>>>>>>     }
>>>>>>>
>>>>>>> +static inline int firmware_map_remove(u64 start, u64 end, const char *type)
>>>>>>> +{
>>>>>>> +	return 0;
>>>>>>> +}
>>>>>>> +
>>>>>>>     #endif /* CONFIG_FIRMWARE_MEMMAP */
>>>>>>>
>>>>>>>     #endif /* _LINUX_FIRMWARE_MAP_H */
>>>>>>> Index: linux-3.5-rc4/drivers/firmware/memmap.c
>>>>>>> ===================================================================
>>>>>>> --- linux-3.5-rc4.orig/drivers/firmware/memmap.c	2012-07-03 14:21:45.761421180 +0900
>>>>>>> +++ linux-3.5-rc4/drivers/firmware/memmap.c	2012-07-03 14:22:03.569198549 +0900
>>>>>>> @@ -79,7 +79,16 @@ static const struct sysfs_ops memmap_att
>>>>>>>     	.show = memmap_attr_show,
>>>>>>>     };
>>>>>>>
>>>>>>> +static void release_firmware_map_entry(struct kobject *kobj)
>>>>>>> +{
>>>>>>> +	/*
>>>>>>> +	 * FIXME : There is no idea.
>>>>>>> +	 *         How to free the entry which allocated bootmem?
>>>>>>> +	 */
>>>>>>
>>>>>> I find a function free_bootmem(), but I am not sure whether it can work here.
>>>>>
>>>>> It cannot work here.
>>>>>
>>>>>> Another problem: how to check whether the entry uses bootmem?
>>>>>
>>>>> When firmware_map_entry is allocated by kzalloc(), the page has PG_slab.
>>>>
>>>> This is not true. In my test, I find the page does not have PG_slab sometimes.
>>>
>>> I think that it depends on the allocated size. firmware_map_entry size is
>>> smaller than PAGE_SIZE. So the page has PG_Slab.
>>
>> In my test, I add printk in the function firmware_map_add_hotplug() to display
>> page's flags. And sometimes the page is not allocated by slab(I use PageSlab()
>> to verify it).
> 
> How did you check it? Could you send your debug patch?

When the memory is not allocated from slab, the flags is 0x10000000008000.
