Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A26B56B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 04:19:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2A4363EE0C1
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:19:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0847145DD78
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:19:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E056745DE69
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:19:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C4E881DB8049
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:19:07 +0900 (JST)
Received: from g01jpexchyt04.g01.fujitsu.local (g01jpexchyt04.g01.fujitsu.local [10.128.194.43])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E62BE18005
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:19:07 +0900 (JST)
Message-ID: <4FFA93DB.6010403@jp.fujitsu.com>
Date: Mon, 9 Jul 2012 17:18:35 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 4/13] memory-hotplug : remove /sys/firmware/memmap/X
 sysfs
References: <4FF287C3.4030901@jp.fujitsu.com> <4FF28996.10702@jp.fujitsu.com> <4FF2929B.7030004@cn.fujitsu.com> <4FF3CA65.1020300@jp.fujitsu.com> <4FF3CFDC.50802@cn.fujitsu.com> <4FF3DA1E.9060505@jp.fujitsu.com> <4FF41484.3070806@cn.fujitsu.com> <4FF6A17C.6000808@jp.fujitsu.com> <4FF6ADD9.7040600@cn.fujitsu.com>
In-Reply-To: <4FF6ADD9.7040600@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/07/06 18:20, Wen Congyang wrote:
> At 07/06/2012 04:27 PM, Yasuaki Ishimatsu Wrote:
>> Hi Wen,
>>
>> 2012/07/04 19:01, Wen Congyang wrote:
>>> At 07/04/2012 01:52 PM, Yasuaki Ishimatsu Wrote:
>>>> Hi Wen,
>>>>
>>>> 2012/07/04 14:08, Wen Congyang wrote:
>>>>> At 07/04/2012 12:45 PM, Yasuaki Ishimatsu Wrote:
>>>>>> Hi Wen,
>>>>>>
>>>>>> 2012/07/03 15:35, Wen Congyang wrote:
>>>>>>> At 07/03/2012 01:56 PM, Yasuaki Ishimatsu Wrote:
>>>>>>>> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
>>>>>>>> sysfs files are created. But there is no code to remove these files. The patch
>>>>>>>> implements the function to remove them.
>>>>>>>>
>>>>>>>> Note : The code does not free firmware_map_entry since there is no way to free
>>>>>>>>            memory which is allocated by bootmem.
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
>>>>>>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>>>>>
>>>>>>>> ---
>>>>>>>>      drivers/firmware/memmap.c    |   70 +++++++++++++++++++++++++++++++++++++++++++
>>>>>>>>      include/linux/firmware-map.h |    6 +++
>>>>>>>>      mm/memory_hotplug.c          |    6 +++
>>>>>>>>      3 files changed, 81 insertions(+), 1 deletion(-)
>>>>>>>>
>>>>>>>> Index: linux-3.5-rc4/mm/memory_hotplug.c
>>>>>>>> ===================================================================
>>>>>>>> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:00.190240794 +0900
>>>>>>>> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:03.549198802 +0900
>>>>>>>> @@ -661,7 +661,11 @@ EXPORT_SYMBOL_GPL(add_memory);
>>>>>>>>
>>>>>>>>      int remove_memory(int nid, u64 start, u64 size)
>>>>>>>>      {
>>>>>>>> -	return -EBUSY;
>>>>>>>> +	lock_memory_hotplug();
>>>>>>>> +	/* remove memmap entry */
>>>>>>>> +	firmware_map_remove(start, start + size - 1, "System RAM");
>>>>>>>> +	unlock_memory_hotplug();
>>>>>>>> +	return 0;
>>>>>>>>
>>>>>>>>      }
>>>>>>>>      EXPORT_SYMBOL_GPL(remove_memory);
>>>>>>>> Index: linux-3.5-rc4/include/linux/firmware-map.h
>>>>>>>> ===================================================================
>>>>>>>> --- linux-3.5-rc4.orig/include/linux/firmware-map.h	2012-07-03 14:21:45.766421116 +0900
>>>>>>>> +++ linux-3.5-rc4/include/linux/firmware-map.h	2012-07-03 14:22:03.550198789 +0900
>>>>>>>> @@ -25,6 +25,7 @@
>>>>>>>>
>>>>>>>>      int firmware_map_add_early(u64 start, u64 end, const char *type);
>>>>>>>>      int firmware_map_add_hotplug(u64 start, u64 end, const char *type);
>>>>>>>> +int firmware_map_remove(u64 start, u64 end, const char *type);
>>>>>>>>
>>>>>>>>      #else /* CONFIG_FIRMWARE_MEMMAP */
>>>>>>>>
>>>>>>>> @@ -38,6 +39,11 @@ static inline int firmware_map_add_hotpl
>>>>>>>>      	return 0;
>>>>>>>>      }
>>>>>>>>
>>>>>>>> +static inline int firmware_map_remove(u64 start, u64 end, const char *type)
>>>>>>>> +{
>>>>>>>> +	return 0;
>>>>>>>> +}
>>>>>>>> +
>>>>>>>>      #endif /* CONFIG_FIRMWARE_MEMMAP */
>>>>>>>>
>>>>>>>>      #endif /* _LINUX_FIRMWARE_MAP_H */
>>>>>>>> Index: linux-3.5-rc4/drivers/firmware/memmap.c
>>>>>>>> ===================================================================
>>>>>>>> --- linux-3.5-rc4.orig/drivers/firmware/memmap.c	2012-07-03 14:21:45.761421180 +0900
>>>>>>>> +++ linux-3.5-rc4/drivers/firmware/memmap.c	2012-07-03 14:22:03.569198549 +0900
>>>>>>>> @@ -79,7 +79,16 @@ static const struct sysfs_ops memmap_att
>>>>>>>>      	.show = memmap_attr_show,
>>>>>>>>      };
>>>>>>>>
>>>>>>>> +static void release_firmware_map_entry(struct kobject *kobj)
>>>>>>>> +{
>>>>>>>> +	/*
>>>>>>>> +	 * FIXME : There is no idea.
>>>>>>>> +	 *         How to free the entry which allocated bootmem?
>>>>>>>> +	 */
>>>>>>>
>>>>>>> I find a function free_bootmem(), but I am not sure whether it can work here.
>>>>>>
>>>>>> It cannot work here.
>>>>>>
>>>>>>> Another problem: how to check whether the entry uses bootmem?
>>>>>>
>>>>>> When firmware_map_entry is allocated by kzalloc(), the page has PG_slab.
>>>>>
>>>>> This is not true. In my test, I find the page does not have PG_slab sometimes.
>>>>
>>>> I think that it depends on the allocated size. firmware_map_entry size is
>>>> smaller than PAGE_SIZE. So the page has PG_Slab.
>>>
>>> In my test, I add printk in the function firmware_map_add_hotplug() to display
>>> page's flags. And sometimes the page is not allocated by slab(I use PageSlab()
>>> to verify it).
>>
>> How did you check it? Could you send your debug patch?
> 
> When the memory is not allocated from slab, the flags is 0x10000000008000.

Thank you for sending the patch.
I think the page to not have PageSlab is a compound page. So we can check
whether the entry is allocate from bootmem or not as follow:

static void release_firmware_map_entry(struct kobject *kobj)
{
	struct firmware_map_entry *entry = to_memmap_entry(kobj);
	struct page *head_page;

	head_page = virt_to_head_page(entry);
	if (PageSlab(head_page))
		kfree(etnry);
	else
		/* the entry is allocated from bootmem */
}

Thanks,
Yasuaki Ishimatsu

> 
>  From 8dd51368d6c03edf7edc89cab17441e3741c39c7 Mon Sep 17 00:00:00 2001
> From: Wen Congyang <wency@cn.fujitsu.com>
> Date: Wed, 4 Jul 2012 16:05:26 +0800
> Subject: [PATCH] debug
> 
> ---
>   drivers/firmware/memmap.c |    7 +++++++
>   1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
> index adc0710..993ba3f 100644
> --- a/drivers/firmware/memmap.c
> +++ b/drivers/firmware/memmap.c
> @@ -21,6 +21,7 @@
>   #include <linux/types.h>
>   #include <linux/bootmem.h>
>   #include <linux/slab.h>
> +#include <linux/mm.h>
>   
>   /*
>    * Data types ------------------------------------------------------------------
> @@ -160,11 +161,17 @@ static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry)
>   int __meminit firmware_map_add_hotplug(u64 start, u64 end, const char *type)
>   {
>   	struct firmware_map_entry *entry;
> +	struct page *entry_page;
>   
>   	entry = kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
>   	if (!entry)
>   		return -ENOMEM;
>   
> +	entry_page = virt_to_page(entry);
> +	printk(KERN_WARNING "flags: %lx\n", entry_page->flags);
> +	if (PageSlab(entry_page)) {
> +		printk(KERN_WARNING "page is allocated from slab\n");
> +	}
>   	firmware_map_add_entry(start, end, type, entry);
>   	/* create the memmap entry */
>   	add_sysfs_fw_map_entry(entry);
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
