Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 422756B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 04:03:23 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so10600476pab.19
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 01:03:22 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id gk1si12804153pbd.79.2014.08.11.01.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 01:03:22 -0700 (PDT)
Message-ID: <53E87865.1090207@huawei.com>
Date: Mon, 11 Aug 2014 16:01:41 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: add sysfs zone_to_online attribute
References: <1407741519-15042-1-git-send-email-zhenzhang.zhang@huawei.com> <53E86E4A.5070405@huawei.com>
In-Reply-To: <53E86E4A.5070405@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>
Cc: wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>

On 2014/8/11 15:18, Zhang Zhen wrote:
> Currently memory-hotplug has two limits:
> 1. If the memory block is in ZONE_NORMAL, you can change it to
> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
> 2. If the memory block is in ZONE_MOVABLE, you can change it to
> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
> 
> With this patch, we can easy to know a memory block can be added to
> which zone, and we don't need to know the above two limits.
> 
> Updated the related Documentation.
> 
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
> ---
>  Documentation/ABI/testing/sysfs-devices-memory | 10 +++++
>  Documentation/memory-hotplug.txt               |  4 +-
>  drivers/base/memory.c                          | 62 +++++++++++++++++++++++++-
>  include/linux/memory_hotplug.h                 |  1 +
>  mm/memory_hotplug.c                            |  4 +-
>  5 files changed, 77 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
> index 7405de2..0e58924 100644
> --- a/Documentation/ABI/testing/sysfs-devices-memory
> +++ b/Documentation/ABI/testing/sysfs-devices-memory
> @@ -61,6 +61,16 @@ Users:		hotplug memory remove tools
>  		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils
> 
> 
> +What:           /sys/devices/system/memory/memoryX/zone_to_online
> +Date:           July 2014
> +Contact:	Zhang Zhen <zhenzhang.zhang@huawei.com>
> +Description:
> +		The file /sys/devices/system/memory/memoryX/zone_to_online
> +		is read-only and is designed to show which zone this memory block can
> +		be onlined to.
> +Users:		hotplug memory remove tools
> +		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils			
> +
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
> 
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
> +	start_pfn = page_to_pfn(first_page);
> +	end_pfn = start_pfn + nr_pages;
> +
> +	/*The block contains more than one zone can not be offlined.*/
> +	if (!test_pages_in_a_zone(start_pfn, end_pfn))
> +		return sprintf(buf, "NULL\n");
> +
> +	zone = page_zone(first_page);
> +
> +	/*The mem block is the last block of memory.*/
> +	if (!pfn_valid(end_pfn + 1)) {
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
> +
>  static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
>  static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
>  static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
>  static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
> -
> +static DEVICE_ATTR(zone_to_online, 0444, show_zone_to_online, NULL);
>  /*
>   * Block size attribute stuff
>   */
> @@ -523,6 +582,7 @@ static struct attribute *memory_memblk_attrs[] = {
>  	&dev_attr_state.attr,
>  	&dev_attr_phys_device.attr,
>  	&dev_attr_removable.attr,
> +	&dev_attr_zone_to_online.attr,
>  	NULL
>  };
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index d9524c4..8f1a419 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -84,6 +84,7 @@ extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
>  extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
>  /* VM interface that may be used by firmware interface */
>  extern int online_pages(unsigned long, unsigned long, int);
> +extern int test_pages_in_a_zone(unsigned long, unsigned long);
>  extern void __offline_isolated_pages(unsigned long, unsigned long);
> 
>  typedef void (*online_page_callback_t)(struct page *page);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 2ff8c23..785b7e6 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1307,7 +1307,7 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>  /*
>   * Confirm all pages in a range [start, end) is belongs to the same zone.
>   */
> -static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
> +int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>  {
>  	unsigned long pfn;
>  	struct zone *zone = NULL;
> @@ -1638,7 +1638,7 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
>  		node_clear_state(node, N_MEMORY);
>  }
> 
> -static int __ref __offline_pages(unsigned long start_pfn,
> +int __ref __offline_pages(unsigned long start_pfn,
Sorry, here is needless, i will remove it in next version.
>  		  unsigned long end_pfn, unsigned long timeout)
>  {
>  	unsigned long pfn, nr_pages, expire;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
