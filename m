Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id 957E26B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 03:37:48 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id n16so4971912oag.27
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 00:37:48 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id q2si25363726obf.53.2014.08.19.00.37.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 19 Aug 2014 00:37:47 -0700 (PDT)
Message-ID: <53F2FE4C.7020700@huawei.com>
Date: Tue, 19 Aug 2014 15:35:40 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory-hotplug: add sysfs zones_online_to attribute
References: <1407902811-4873-1-git-send-email-zhenzhang.zhang@huawei.com> <53EAE534.8030303@huawei.com> <53F19919.1070908@jp.fujitsu.com>
In-Reply-To: <53F19919.1070908@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, toshi.kani@hp.com, n-horiguchi@ah.jp.nec.com, wangnan0@huawei.com, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 2014/8/18 14:11, Yasuaki Ishimatsu wrote:
> (2014/08/13 13:10), Zhang Zhen wrote:
>> Currently memory-hotplug has two limits:
>> 1. If the memory block is in ZONE_NORMAL, you can change it to
>> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
>> 2. If the memory block is in ZONE_MOVABLE, you can change it to
>> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
>>
>> With this patch, we can easy to know a memory block can be onlined to
>> which zone, and don't need to know the above two limits.
>>
>> Updated the related Documentation.
>>
>> Change v1 -> v2:
>> - optimize the implementation following Dave Hansen's suggestion
>>
>> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
>> ---
>>   Documentation/ABI/testing/sysfs-devices-memory |  8 ++++
>>   Documentation/memory-hotplug.txt               |  4 +-
>>   drivers/base/memory.c                          | 62 ++++++++++++++++++++++++++
>>   include/linux/memory_hotplug.h                 |  1 +
>>   mm/memory_hotplug.c                            |  2 +-
>>   5 files changed, 75 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
>> index 7405de2..2b2a1d7 100644
>> --- a/Documentation/ABI/testing/sysfs-devices-memory
>> +++ b/Documentation/ABI/testing/sysfs-devices-memory
>> @@ -61,6 +61,14 @@ Users:        hotplug memory remove tools
>>           http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils
>>
>>
>> +What:           /sys/devices/system/memory/memoryX/zones_online_to
>> +Date:           July 2014
>> +Contact:    Zhang Zhen <zhenzhang.zhang@huawei.com>
>> +Description:
>> +        The file /sys/devices/system/memory/memoryX/zones_online_to
>> +        is read-only and is designed to show which zone this memory block can
>> +        be onlined to.
>> +
>>   What:        /sys/devices/system/memoryX/nodeY
>>   Date:        October 2009
>>   Contact:    Linux Memory Management list <linux-mm@kvack.org>
>> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
>> index 45134dc..5b34e33 100644
>> --- a/Documentation/memory-hotplug.txt
>> +++ b/Documentation/memory-hotplug.txt
>> @@ -155,6 +155,7 @@ Under each memory block, you can see 4 files:
>>   /sys/devices/system/memory/memoryXXX/phys_device
>>   /sys/devices/system/memory/memoryXXX/state
>>   /sys/devices/system/memory/memoryXXX/removable
>> +/sys/devices/system/memory/memoryXXX/zones_online_to
>>
>>   'phys_index'      : read-only and contains memory block id, same as XXX.
>>   'state'           : read-write
>> @@ -170,6 +171,8 @@ Under each memory block, you can see 4 files:
>>                       block is removable and a value of 0 indicates that
>>                       it is not removable. A memory block is removable only if
>>                       every section in the block is removable.
>> +'zones_online_to' : read-only: designed to show which zone this memory block
>> +            can be onlined to.
>>
>>   NOTE:
>>     These directories/files appear after physical memory hotplug phase.
>> @@ -408,7 +411,6 @@ node if necessary.
>>     - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
>>       sysctl or new control file.
>>     - showing memory block and physical device relationship.
>> -  - showing memory block is under ZONE_MOVABLE or not
>>     - test and make it better memory offlining.
>>     - support HugeTLB page migration and offlining.
>>     - memmap removing at memory offline.
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index a2e13e2..b5d693f 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -373,10 +373,71 @@ static ssize_t show_phys_device(struct device *dev,
>>       return sprintf(buf, "%d\n", mem->phys_device);
>>   }
>>
>> +static int __zones_online_to(unsigned long end_pfn,
>> +                struct page *first_page, unsigned long nr_pages)
>> +{
>> +    struct zone *zone_next;
>> +
> 
>> +    /*The mem block is the last block of memory.*/
>> +    if (!pfn_valid(end_pfn + 1))
>> +        return 1;
> 
> The check is not enough if memory has hole as follows:
> 
> PFN       0x00          0xd0          0xe0          0xf0
>             +-------------+-------------+-------------+
> zone type   |   Normal    |     hole    |   Normal    |
>             +-------------+-------------+-------------+
> 
> In this case, 0xd1 is invalid pfn. But __zones_online_to should return 0
> since 0xe0-0xf0 is Normal zone.
> 
> Thanks,
> Yasuaki Ishimatsu
> 
You are right, it is not enough.

Here we should make a check as follows.
if ((end_pfn + 1) > zone_end_pfn(page_zone(first_page)))
	return 1;
I will send a patch to fix it.

Thanks !
> 
>> +    zone_next = page_zone(first_page + nr_pages);
>> +    if (zone_idx(zone_next) == ZONE_MOVABLE)
>> +        return 1;
>> +    return 0;
>> +}
>> +
>> +static ssize_t show_zones_online_to(struct device *dev,
>> +                struct device_attribute *attr, char *buf)
>> +{
>> +    struct memory_block *mem = to_memory_block(dev);
>> +    unsigned long start_pfn, end_pfn;
>> +    unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>> +    struct page *first_page;
>> +    struct zone *zone, *zone_prev;
>> +
>> +    start_pfn = section_nr_to_pfn(mem->start_section_nr);
>> +    end_pfn = start_pfn + nr_pages;
>> +    first_page = pfn_to_page(start_pfn);
>> +
>> +    /*The block contains more than one zone can not be offlined.*/
>> +    if (!test_pages_in_a_zone(start_pfn, end_pfn))
>> +        return sprintf(buf, "none\n");
>> +
>> +    zone = page_zone(first_page);
>> +
>> +#ifdef CONFIG_HIGHMEM
>> +    if (zone_idx(zone) == ZONE_HIGHMEM) {
>> +        if (__zones_online_to(end_pfn, first_page, nr_pages))
>> +            return sprintf(buf, "%s %s\n",
>> +                    zone->name, (zone + 1)->name);
>> +    }
>> +#else
>> +    if (zone_idx(zone) == ZONE_NORMAL) {
>> +        if (__zones_online_to(end_pfn, first_page, nr_pages))
>> +            return sprintf(buf, "%s %s\n",
>> +                    zone->name, (zone + 1)->name);
>> +    }
>> +#endif
>> +
>> +    if (zone_idx(zone) == ZONE_MOVABLE) {
>> +        if (!pfn_valid(start_pfn - nr_pages))
>> +            return sprintf(buf, "%s %s\n",
>> +                        zone->name, (zone - 1)->name);
>> +        zone_prev = page_zone(first_page - nr_pages);
>> +        if (zone_idx(zone_prev) != ZONE_MOVABLE)
>> +            return sprintf(buf, "%s %s\n",
>> +                        zone->name, (zone - 1)->name);
>> +    }
>> +
>> +    return sprintf(buf, "%s\n", zone->name);
>> +}
>> +
>>   static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
>>   static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
>>   static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
>>   static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
>> +static DEVICE_ATTR(zones_online_to, 0444, show_zones_online_to, NULL);
>>
>>   /*
>>    * Block size attribute stuff
>> @@ -523,6 +584,7 @@ static struct attribute *memory_memblk_attrs[] = {
>>       &dev_attr_state.attr,
>>       &dev_attr_phys_device.attr,
>>       &dev_attr_removable.attr,
>> +    &dev_attr_zones_online_to.attr,
>>       NULL
>>   };
>>
>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>> index d9524c4..8f1a419 100644
>> --- a/include/linux/memory_hotplug.h
>> +++ b/include/linux/memory_hotplug.h
>> @@ -84,6 +84,7 @@ extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
>>   extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
>>   /* VM interface that may be used by firmware interface */
>>   extern int online_pages(unsigned long, unsigned long, int);
>> +extern int test_pages_in_a_zone(unsigned long, unsigned long);
>>   extern void __offline_isolated_pages(unsigned long, unsigned long);
>>
>>   typedef void (*online_page_callback_t)(struct page *page);
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 2ff8c23..29d8693 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1307,7 +1307,7 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>>   /*
>>    * Confirm all pages in a range [start, end) is belongs to the same zone.
>>    */
>> -static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>> +int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>>   {
>>       unsigned long pfn;
>>       struct zone *zone = NULL;
>>
> 
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
