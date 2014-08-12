Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 522A76B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 23:41:35 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so11821577pdb.19
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 20:41:34 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id tm8si15017223pab.54.2014.08.11.20.41.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 20:41:34 -0700 (PDT)
Message-ID: <53E98C91.1080605@huawei.com>
Date: Tue, 12 Aug 2014 11:40:01 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: add sysfs zone_to_online attribute
References: <1407741519-15042-1-git-send-email-zhenzhang.zhang@huawei.com> <53E86E4A.5070405@huawei.com> <53E8DF0B.9070309@intel.com>
In-Reply-To: <53E8DF0B.9070309@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>

On 2014/8/11 23:19, Dave Hansen wrote:
> On 08/11/2014 12:18 AM, Zhang Zhen wrote:
>> +What:           /sys/devices/system/memory/memoryX/zone_to_online
>> +Date:           July 2014
>> +Contact:	Zhang Zhen <zhenzhang.zhang@huawei.com>
>> +Description:
>> +		The file /sys/devices/system/memory/memoryX/zone_to_online
>> +		is read-only and is designed to show which zone this memory block can
>> +		be onlined to.
>> +Users:		hotplug memory remove tools
>> +		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils			
> 
> I went and looked there.  It redirects immediately to:
> 
> 	https://www.ibm.com/developerworks/community/wikis/home?lang=en
> 
> Where a search for "hotplug memory remove tools" finds nothing.
> 
> What hardware and hypervisor are you looking at this for?
> 
I tested this patch on a X86_64 machine.

Sorry, i copied this url from the description of /sys/devices/system/memory/memoryX/state.
Anyone try to online a memory block want to know which zone the block can be onlined to.
I will delete the Users.

>>  What:		/sys/devices/system/memoryX/nodeY
>>  Date:		October 2009
>>  Contact:	Linux Memory Management list <linux-mm@kvack.org>
>> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
>> index 45134dc..09e3d37 100644
>> --- a/Documentation/memory-hotplug.txt
>> +++ b/Documentation/memory-hotplug.txt
>> @@ -155,6 +155,7 @@ Under each memory block, you can see 4 files:
>>  /sys/devices/system/memory/memoryXXX/phys_device
>>  /sys/devices/system/memory/memoryXXX/state
>>  /sys/devices/system/memory/memoryXXX/removable
>> +/sys/devices/system/memory/memoryXXX/zone_to_online
>>
>>  'phys_index'      : read-only and contains memory block id, same as XXX.
>>  'state'           : read-write
>> @@ -170,6 +171,8 @@ Under each memory block, you can see 4 files:
>>                      block is removable and a value of 0 indicates that
>>                      it is not removable. A memory block is removable only if
>>                      every section in the block is removable.
>> +'zone_to_online'  : read-only: designed to show which zone this memory block
>> +		    can be onlined to.
> 
> Zone to online makes it sound like this is the zone that is about to be
> onlined, not the section.  "zone_online_to" would be a bit more
> appropriate, or maybe "online_zones_possible".
> 
> Isn't it possible to have more than a single zone show up?
> 
Thanks for your suggestion, i think "zones_online_to" is appropriate.
Yeah, it is possible.
The sample as follows:
bash-4.2# echo 0x20000000 > probe
[ 1241.991476] init_memory_mapping: [mem 0x20000000-0x27ffffff]
bash-4.2# echo online > memory4/state
bash-4.2# echo 0x28000000 > probe
[ 1262.539036] init_memory_mapping: [mem 0x28000000-0x2fffffff]
bash-4.2# echo online_movable > memory5/state
bash-4.2# echo 0x30000000 > probe
[ 1278.999325] init_memory_mapping: [mem 0x30000000-0x37ffffff]
bash-4.2# cat memory*/zone_to_online
NULL
DMA32
DMA32
DMA32
Normal Movable
Movable Normal
Movable

>>  NOTE:
>>    These directories/files appear after physical memory hotplug phase.
>> @@ -408,7 +411,6 @@ node if necessary.
>>    - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
>>      sysctl or new control file.
>>    - showing memory block and physical device relationship.
>> -  - showing memory block is under ZONE_MOVABLE or not
>>    - test and make it better memory offlining.
>>    - support HugeTLB page migration and offlining.
>>    - memmap removing at memory offline.
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index a2e13e2..044353c 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -373,11 +373,70 @@ static ssize_t show_phys_device(struct device *dev,
>>  	return sprintf(buf, "%d\n", mem->phys_device);
>>  }
>>
>> +static ssize_t show_zone_to_online(struct device *dev,
>> +				struct device_attribute *attr, char *buf)
>> +{
>> +	struct memory_block *mem = to_memory_block(dev);
>> +	unsigned long start_pfn, end_pfn;
>> +	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>> +	struct page *first_page;
>> +	struct zone *zone, *zone_prev, *zone_next;
>> +
>> +	first_page = pfn_to_page(mem->start_section_nr << PFN_SECTION_SHIFT);
> 
> Is there something wrong with section_nr_to_pfn()?

OK, i will use section_nr_to_pfn() in next version.
> 
>> +	start_pfn = page_to_pfn(first_page);
> 
> Nit: Why do pfn_to_page() then page_to_pfn() immediately?
> 
>> +	end_pfn = start_pfn + nr_pages;
>> +
>> +	/*The block contains more than one zone can not be offlined.*/
> 
> Do you mean onlined?

Yes.
As in the example above, the memory0 contains DMA and DMA32 zones, so it can not be offlined.
Another case, for a x86_64 machine booted with "mem=400M", the last block memory3 cantains DMA32
and NORMAL zones, it can not be offlined too.
> 
>> +	if (!test_pages_in_a_zone(start_pfn, end_pfn))
>> +		return sprintf(buf, "NULL\n");
> 
> "(none)" is a bit more normal nomenclature in sysfs.
> 
Ok, thanks!

>> +	zone = page_zone(first_page);
>> +
>> +	/*The mem block is the last block of memory.*/
>> +	if (!pfn_valid(end_pfn + 1)) {
> 
> This check only looks for a *hole* in the page after this block ends.
> It does not check all of the other pages *above* end_pfn+1, which would
> be needed to guarantee that this is "the last block of memory".
> 
The purpose here is to guarantee that this is "the last block of memory".
Maybe this is not the best way.
I would like to follow your better suggestion.

>> +#ifdef CONFIG_HIGHMEM
>> +		if (zone_idx(zone) == ZONE_HIGHMEM)
>> +			return sprintf(buf, "%s %s\n", zone->name, (zone + 1)->name);
>> +#else
>> +		if (zone_idx(zone) == ZONE_NORMAL)
>> +			return sprintf(buf, "%s %s\n", zone->name, (zone + 1)->name);
>> +#endif
>> +		if (zone_idx(zone) == ZONE_MOVABLE) {
>> +			if (pfn_valid(start_pfn - nr_pages)) {
>> +				zone_prev = page_zone(first_page - nr_pages);
>> +				if (zone_idx(zone_prev) != ZONE_MOVABLE)
>> +					return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
>> +			} else
>> +				return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
>> +		}
>> +		return sprintf(buf, "%s\n", zone->name);
>> +		
>> +	}
>> +
>> +	zone_next = page_zone(first_page + nr_pages + 1);
> 
> Is the +1 necessary?  It doesn't matter in practice since we don't have
> single-page zones, but it is a bit confusing.  Seems to me like this
> will get page[1] instead of page[0].
> 
You are right, +1 here is not necessary.

> Furthermore, this might cross a section boundary where 'struct page'
> arithmetic is not guaranteed not work.  That makes it _definitely_ broken.
> 
>> +#ifdef CONFIG_HIGHMEM
>> +	if (zone_idx(zone) == ZONE_HIGHMEM && zone_idx(zone_next) == ZONE_MOVABLE)
>> +		return sprintf(buf, "%s %s\n", zone->name, zone_next->name);
>> +#else
>> +	if (zone_idx(zone) == ZONE_NORMAL && zone_idx(zone_next) == ZONE_MOVABLE)
>> +		return sprintf(buf, "%s %s\n", zone->name, zone_next->name);
>> +#endif
>> +	if (zone_idx(zone) == ZONE_MOVABLE) {
>> +		if (pfn_valid(start_pfn - nr_pages)) {
>> +			zone_prev = page_zone(first_page - nr_pages);
>> +			if (zone_idx(zone_prev) != ZONE_MOVABLE)
>> +				return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
>> +		} else
>> +			return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
>> +	}
>> +	return sprintf(buf, "%s\n", zone->name);
>> +}
> 
> Can you please work to clean this up a bit.  I think it's quite a mess.
>  I see two #ifdefs in a .c file, and a fairly large block of (virtually)
> uncommented and copy-n-pasted code.

Sorry, it is really ugly, i will implement it in a separate function and call it here.

> 
> The two copies of this:
> 
>>> +	if (zone_idx(zone) == ZONE_MOVABLE) {
>>> +		if (pfn_valid(start_pfn - nr_pages)) {
>>> +			zone_prev = page_zone(first_page - nr_pages);
>>> +			if (zone_idx(zone_prev) != ZONE_MOVABLE)
>>> +				return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
>>> +		} else
>>> +			return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
>>> +	}
>>> +	return sprintf(buf, "%s\n", zone->name);
> 
> are identical except for the indentation.
> 
> This is also supposed to be enumerating rules that are enforced by some
> other bit of code.  There are, as far as I can see, no calls in to that
> other code, or comments about what code it depends on.  To me, this
> looks like an invitation for the two copies to diverge.
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
