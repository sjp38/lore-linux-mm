Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4886B0038
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 11:19:46 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so11303582pab.28
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 08:19:46 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wo9si13629978pbc.214.2014.08.11.08.19.44
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 08:19:44 -0700 (PDT)
Message-ID: <53E8DF0B.9070309@intel.com>
Date: Mon, 11 Aug 2014 08:19:39 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: add sysfs zone_to_online attribute
References: <1407741519-15042-1-git-send-email-zhenzhang.zhang@huawei.com> <53E86E4A.5070405@huawei.com>
In-Reply-To: <53E86E4A.5070405@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>

On 08/11/2014 12:18 AM, Zhang Zhen wrote:
> +What:           /sys/devices/system/memory/memoryX/zone_to_online
> +Date:           July 2014
> +Contact:	Zhang Zhen <zhenzhang.zhang@huawei.com>
> +Description:
> +		The file /sys/devices/system/memory/memoryX/zone_to_online
> +		is read-only and is designed to show which zone this memory block can
> +		be onlined to.
> +Users:		hotplug memory remove tools
> +		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils			

I went and looked there.  It redirects immediately to:

	https://www.ibm.com/developerworks/community/wikis/home?lang=en

Where a search for "hotplug memory remove tools" finds nothing.

What hardware and hypervisor are you looking at this for?

>  What:		/sys/devices/system/memoryX/nodeY
>  Date:		October 2009
>  Contact:	Linux Memory Management list <linux-mm@kvack.org>
> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
> index 45134dc..09e3d37 100644
> --- a/Documentation/memory-hotplug.txt
> +++ b/Documentation/memory-hotplug.txt
> @@ -155,6 +155,7 @@ Under each memory block, you can see 4 files:
>  /sys/devices/system/memory/memoryXXX/phys_device
>  /sys/devices/system/memory/memoryXXX/state
>  /sys/devices/system/memory/memoryXXX/removable
> +/sys/devices/system/memory/memoryXXX/zone_to_online
> 
>  'phys_index'      : read-only and contains memory block id, same as XXX.
>  'state'           : read-write
> @@ -170,6 +171,8 @@ Under each memory block, you can see 4 files:
>                      block is removable and a value of 0 indicates that
>                      it is not removable. A memory block is removable only if
>                      every section in the block is removable.
> +'zone_to_online'  : read-only: designed to show which zone this memory block
> +		    can be onlined to.

Zone to online makes it sound like this is the zone that is about to be
onlined, not the section.  "zone_online_to" would be a bit more
appropriate, or maybe "online_zones_possible".

Isn't it possible to have more than a single zone show up?

>  NOTE:
>    These directories/files appear after physical memory hotplug phase.
> @@ -408,7 +411,6 @@ node if necessary.
>    - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
>      sysctl or new control file.
>    - showing memory block and physical device relationship.
> -  - showing memory block is under ZONE_MOVABLE or not
>    - test and make it better memory offlining.
>    - support HugeTLB page migration and offlining.
>    - memmap removing at memory offline.
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index a2e13e2..044353c 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -373,11 +373,70 @@ static ssize_t show_phys_device(struct device *dev,
>  	return sprintf(buf, "%d\n", mem->phys_device);
>  }
> 
> +static ssize_t show_zone_to_online(struct device *dev,
> +				struct device_attribute *attr, char *buf)
> +{
> +	struct memory_block *mem = to_memory_block(dev);
> +	unsigned long start_pfn, end_pfn;
> +	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
> +	struct page *first_page;
> +	struct zone *zone, *zone_prev, *zone_next;
> +
> +	first_page = pfn_to_page(mem->start_section_nr << PFN_SECTION_SHIFT);

Is there something wrong with section_nr_to_pfn()?

> +	start_pfn = page_to_pfn(first_page);

Nit: Why do pfn_to_page() then page_to_pfn() immediately?

> +	end_pfn = start_pfn + nr_pages;
> +
> +	/*The block contains more than one zone can not be offlined.*/

Do you mean onlined?

> +	if (!test_pages_in_a_zone(start_pfn, end_pfn))
> +		return sprintf(buf, "NULL\n");

"(none)" is a bit more normal nomenclature in sysfs.

> +	zone = page_zone(first_page);
> +
> +	/*The mem block is the last block of memory.*/
> +	if (!pfn_valid(end_pfn + 1)) {

This check only looks for a *hole* in the page after this block ends.
It does not check all of the other pages *above* end_pfn+1, which would
be needed to guarantee that this is "the last block of memory".

> +#ifdef CONFIG_HIGHMEM
> +		if (zone_idx(zone) == ZONE_HIGHMEM)
> +			return sprintf(buf, "%s %s\n", zone->name, (zone + 1)->name);
> +#else
> +		if (zone_idx(zone) == ZONE_NORMAL)
> +			return sprintf(buf, "%s %s\n", zone->name, (zone + 1)->name);
> +#endif
> +		if (zone_idx(zone) == ZONE_MOVABLE) {
> +			if (pfn_valid(start_pfn - nr_pages)) {
> +				zone_prev = page_zone(first_page - nr_pages);
> +				if (zone_idx(zone_prev) != ZONE_MOVABLE)
> +					return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
> +			} else
> +				return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
> +		}
> +		return sprintf(buf, "%s\n", zone->name);
> +		
> +	}
> +
> +	zone_next = page_zone(first_page + nr_pages + 1);

Is the +1 necessary?  It doesn't matter in practice since we don't have
single-page zones, but it is a bit confusing.  Seems to me like this
will get page[1] instead of page[0].

Furthermore, this might cross a section boundary where 'struct page'
arithmetic is not guaranteed not work.  That makes it _definitely_ broken.

> +#ifdef CONFIG_HIGHMEM
> +	if (zone_idx(zone) == ZONE_HIGHMEM && zone_idx(zone_next) == ZONE_MOVABLE)
> +		return sprintf(buf, "%s %s\n", zone->name, zone_next->name);
> +#else
> +	if (zone_idx(zone) == ZONE_NORMAL && zone_idx(zone_next) == ZONE_MOVABLE)
> +		return sprintf(buf, "%s %s\n", zone->name, zone_next->name);
> +#endif
> +	if (zone_idx(zone) == ZONE_MOVABLE) {
> +		if (pfn_valid(start_pfn - nr_pages)) {
> +			zone_prev = page_zone(first_page - nr_pages);
> +			if (zone_idx(zone_prev) != ZONE_MOVABLE)
> +				return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
> +		} else
> +			return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
> +	}
> +	return sprintf(buf, "%s\n", zone->name);
> +}

Can you please work to clean this up a bit.  I think it's quite a mess.
 I see two #ifdefs in a .c file, and a fairly large block of (virtually)
uncommented and copy-n-pasted code.

The two copies of this:

>> +	if (zone_idx(zone) == ZONE_MOVABLE) {
>> +		if (pfn_valid(start_pfn - nr_pages)) {
>> +			zone_prev = page_zone(first_page - nr_pages);
>> +			if (zone_idx(zone_prev) != ZONE_MOVABLE)
>> +				return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
>> +		} else
>> +			return sprintf(buf, "%s %s\n", zone->name, (zone - 1)->name);
>> +	}
>> +	return sprintf(buf, "%s\n", zone->name);

are identical except for the indentation.

This is also supposed to be enumerating rules that are enforced by some
other bit of code.  There are, as far as I can see, no calls in to that
other code, or comments about what code it depends on.  To me, this
looks like an invitation for the two copies to diverge.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
