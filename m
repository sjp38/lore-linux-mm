Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15DF62806D2
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 04:25:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 18so4824748wrz.4
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 01:25:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i16si688553wra.111.2017.04.20.01.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 01:25:30 -0700 (PDT)
Subject: Re: [PATCH v3 6/9] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-7-mhocko@kernel.org>
 <20170410162547.GM4618@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <49b6c3e2-0e68-b77e-31d6-f589d3b4822e@suse.cz>
Date: Thu, 20 Apr 2017 10:25:27 +0200
MIME-Version: 1.0
In-Reply-To: <20170410162547.GM4618@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 04/10/2017 06:25 PM, Michal Hocko wrote:
> This contains two minor fixes spotted based on testing by Igor Mammedov.
> ---
> From d829579cc7061255f818f9aeaa3aa2cd82fec75a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 29 Mar 2017 16:07:00 +0200
> Subject: [PATCH] mm, memory_hotplug: do not associate hotadded memory to zones
>  until online
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> The current memory hotplug implementation relies on having all the
> struct pages associate with a zone/node during the physical hotplug phase
> (arch_add_memory->__add_pages->__add_section->__add_zone). In the vast
> majority of cases this means that they are added to ZONE_NORMAL. This
> has been so since 9d99aaa31f59 ("[PATCH] x86_64: Support memory hotadd
> without sparsemem") and it wasn't a big deal back then because movable
> onlining didn't exist yet.
> 
> Much later memory hotplug wanted to (ab)use ZONE_MOVABLE for movable
> onlining 511c2aba8f07 ("mm, memory-hotplug: dynamic configure movable
> memory and portion memory") and then things got more complicated. Rather
> than reconsidering the zone association which was no longer needed
> (because the memory hotplug already depended on SPARSEMEM) a convoluted
> semantic of zone shifting has been developed. Only the currently last
> memblock or the one adjacent to the zone_movable can be onlined movable.
> This essentially means that the online type changes as the new memblocks
> are added.
> 
> Let's simulate memory hot online manually
> Normal Movable
> 
> /sys/devices/system/memory/memory32/valid_zones:Normal
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> 
> /sys/devices/system/memory/memory32/valid_zones:Normal
> /sys/devices/system/memory/memory33/valid_zones:Normal
> /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> 
> /sys/devices/system/memory/memory32/valid_zones:Normal
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> /sys/devices/system/memory/memory34/valid_zones:Movable Normal

Commands seem to be missing above?

> This is an awkward semantic because an udev event is sent as soon as the
> block is onlined and an udev handler might want to online it based on
> some policy (e.g. association with a node) but it will inherently race
> with new blocks showing up.
> 
> This patch changes the physical online phase to not associate pages
> with any zone at all. All the pages are just marked reserved and wait
> for the onlining phase to be associated with the zone as per the online
> request. There are only two requirements
> 	- existing ZONE_NORMAL and ZONE_MOVABLE cannot overlap
> 	- ZONE_NORMAL precedes ZONE_MOVABLE in physical addresses
> the later on is not an inherent requirement and can be changed in the
> future. It preserves the current behavior and made the code slightly
> simpler. This is subject to change in future.
> 
> This means that the same physical online steps as above will lead to the
> following state:
> Normal Movable
> 
> /sys/devices/system/memory/memory32/valid_zones:Normal Movable
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> 
> /sys/devices/system/memory/memory32/valid_zones:Normal Movable
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> 
> /sys/devices/system/memory/memory32/valid_zones:Normal Movable
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> /sys/devices/system/memory/memory34/valid_zones:Movable

Ditto.

> Implementation:
> The current move_pfn_range is reimplemented to check the above
> requirements (allow_online_pfn_range) and then updates the respective
> zone (move_pfn_range_to_zone), the pgdat and links all the pages in the
> pfn range with the zone/node. __add_pages is updated to not require the
> zone and only initializes sections in the range. This allowed to
> simplify the arch_add_memory code (s390 could get rid of quite some
> of code).
> 
> devm_memremap_pages is the only user of arch_add_memory which relies
> on the zone association because it only hooks into the memory hotplug
> only half way. It uses it to associate the new memory with ZONE_DEVICE
> but doesn't allow it to be {on,off}lined via sysfs. This means that this
> particular code path has to call move_pfn_range_to_zone explicitly.
> 
> The original zone shifting code is kept in place and will be removed in
> the follow up patch for an easier review.
> 
> Changes since v1
> - we have to associate the page with the node early (in __add_section),
>   because pfn_to_node depends on struct page containing this
>   information - based on testing by Reza Arbab
> - resize_{zone,pgdat}_range has to check whether they are popoulated -
>   Reza Arbab
> - fix devm_memremap_pages to use pfn rather than physical address -
>   Jerome Glisse
> - move_pfn_range has to check for intersection with zone_movable rather
>   than to rely on allow_online_pfn_range(MMOP_ONLINE_MOVABLE) for
>   MMOP_ONLINE_KEEP
> 
> Changes since v2
> - fix show_valid_zones nr_pages calculation
> - allow_online_pfn_range has to check managed pages rather than present
> 
> Cc: Dan Williams <dan.j.williams@gmail.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: linux-arch@vger.kernel.org
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # For s390 bits
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/ia64/mm/init.c            |   9 +-
>  arch/powerpc/mm/mem.c          |  10 +-
>  arch/s390/mm/init.c            |  30 +-----
>  arch/sh/mm/init.c              |   8 +-
>  arch/x86/mm/init_32.c          |   5 +-
>  arch/x86/mm/init_64.c          |   9 +-
>  drivers/base/memory.c          |  52 ++++++-----
>  include/linux/memory_hotplug.h |  13 +--
>  include/linux/mmzone.h         |  14 +++
>  kernel/memremap.c              |   4 +
>  mm/memory_hotplug.c            | 201 +++++++++++++++++++++++++----------------
>  mm/sparse.c                    |   3 +-
>  12 files changed, 186 insertions(+), 172 deletions(-)

...

> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -533,6 +533,20 @@ static inline bool zone_is_empty(struct zone *zone)
>  }
>  
>  /*
> + * Return true if [start_pfn, start_pfn + nr_pages) range has a non-mpty


							       non-empty

> + * intersection with the given zone
> + */
> +static inline bool zone_intersects(struct zone *zone,
> +		unsigned long start_pfn, unsigned long nr_pages)
> +{

I'm looking at your current mmotm tree branch, which looks like this:

+ * Return true if [start_pfn, start_pfn + nr_pages) range has a non-mpty
+ * intersection with the given zone
+ */
+static inline bool zone_intersects(struct zone *zone,
+               unsigned long start_pfn, unsigned long nr_pages)
+{
+       if (zone_is_empty(zone))
+               return false;
+       if (zone->zone_start_pfn <= start_pfn && start_pfn < zone_end_pfn(zone))
+               return true;
+       if (start_pfn + nr_pages > zone->zone_start_pfn)
+               return true;

A false positive is possible here, when start_pfn >= zone_end_pfn(zone)?

+       return false;
+}
+
+/*

...

> @@ -1029,39 +1018,114 @@ static void node_states_set_node(int node, struct memory_notify *arg)
>  	node_set_state(node, N_MEMORY);
>  }
>  
> -bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
> -		   enum zone_type target, int *zone_shift)
> +bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages, int online_type)
>  {
> -	struct zone *zone = page_zone(pfn_to_page(pfn));
> -	enum zone_type idx = zone_idx(zone);
> -	int i;
> +	struct pglist_data *pgdat = NODE_DATA(nid);
> +	struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
> +	struct zone *normal_zone =  &pgdat->node_zones[ZONE_NORMAL];
>  
> -	*zone_shift = 0;
> +	/*
> +	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
> +	 * physically before ZONE_MOVABLE. All we need is they do not
> +	 * overlap. Historically we didn't allow ZONE_NORMAL after ZONE_MOVABLE
> +	 * though so let's stick with it for simplicity for now.
> +	 * TODO make sure we do not overlap with ZONE_DEVICE

Is this last TODO a blocker, unlike the others?

...

@ -1074,29 +1138,16 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	int nid;
>  	int ret;
>  	struct memory_notify arg;
> -	int zone_shift = 0;
>  
> -	/*
> -	 * This doesn't need a lock to do pfn_to_page().
> -	 * The section can't be removed here because of the
> -	 * memory_block->state_mutex.
> -	 */
> -	zone = page_zone(pfn_to_page(pfn));
> -
> -	if ((zone_idx(zone) > ZONE_NORMAL ||
> -	    online_type == MMOP_ONLINE_MOVABLE) &&
> -	    !can_online_high_movable(pfn_to_nid(pfn)))
> +	nid = pfn_to_nid(pfn);
> +	if (!allow_online_pfn_range(nid, pfn, nr_pages, online_type))
>  		return -EINVAL;
>  
> -	if (online_type == MMOP_ONLINE_KERNEL) {
> -		if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))
> -			return -EINVAL;
> -	} else if (online_type == MMOP_ONLINE_MOVABLE) {
> -		if (!zone_can_shift(pfn, nr_pages, ZONE_MOVABLE, &zone_shift))
> -			return -EINVAL;
> -	}
> +	if (online_type == MMOP_ONLINE_MOVABLE && !can_online_high_movable(nid))
> +		return -EINVAL;
>  
> -	zone = move_pfn_range(zone_shift, pfn, pfn + nr_pages);
> +	/* associate pfn range with the zone */
> +	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
>  	if (!zone)
>  		return -EINVAL;

Nit: This !zone currently cannot happen.

>  
> @@ -1104,8 +1155,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	arg.nr_pages = nr_pages;
>  	node_states_check_changes_online(nr_pages, zone, &arg);
>  
> -	nid = zone_to_nid(zone);
> -
>  	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>  	ret = notifier_to_errno(ret);
>  	if (ret)
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 6903c8fc3085..d75407882598 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -686,10 +686,9 @@ static void free_map_bootmem(struct page *memmap)
>   * set.  If this is <=0, then that means that the passed-in
>   * map was not consumed and must be freed.
>   */
> -int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
> +int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn)
>  {
>  	unsigned long section_nr = pfn_to_section_nr(start_pfn);
> -	struct pglist_data *pgdat = zone->zone_pgdat;
>  	struct mem_section *ms;
>  	struct page *memmap;
>  	unsigned long *usemap;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
