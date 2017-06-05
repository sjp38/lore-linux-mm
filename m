Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04A666B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 04:13:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g13so22754669wmd.9
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 01:13:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u21si11618493wma.83.2017.06.05.01.13.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 01:13:09 -0700 (PDT)
Date: Mon, 5 Jun 2017 10:13:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memory_hotplug: support movable_node for
 hotplugable nodes
Message-ID: <20170605081306.GH9248@dhcp22.suse.cz>
References: <20170601122004.32732-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601122004.32732-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Are there any further comments? Can I post this for merging? I will
update the documentation as well.

On Thu 01-06-17 14:20:04, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> movable_node kernel parameter allows to make hotplugable NUMA
> nodes to put all the hotplugable memory into movable zone which
> allows more or less reliable memory hotremove.  At least this
> is the case for the NUMA nodes present during the boot (see
> find_zone_movable_pfns_for_nodes).
> 
> This is not the case for the memory hotplug, though.
> 
> 	echo online > /sys/devices/system/memory/memoryXYZ/status
> 
> will default to a kernel zone (usually ZONE_NORMAL) unless the
> particular memblock is already in the movable zone range which is not
> the case normally when onlining the memory from the udev rule context
> for a freshly hotadded NUMA node. The only option currently is to have a
> special udev rule to echo online_movable to all memblocks belonging to
> such a node which is rather clumsy. Not the mention this is inconsistent
> as well because what ended up in the movable zone during the boot will
> end up in a kernel zone after hotremove & hotadd without special care.
> 
> It would be nice to reuse memblock_is_hotpluggable but the runtime
> hotplug doesn't have that information available because the boot and
> hotplug paths are not shared and it would be really non trivial to
> make them use the same code path because the runtime hotplug doesn't
> play with the memblock allocator at all.
> 
> Teach move_pfn_range that MMOP_ONLINE_KEEP can use the movable zone if
> movable_node is enabled and the range doesn't overlap with the existing
> normal zone. This should provide a reasonable default onlining strategy.
> 
> Strictly speaking the semantic is not identical with the boot time
> initialization because find_zone_movable_pfns_for_nodes covers only the
> hotplugable range as described by the BIOS/FW. From my experience this
> is usually a full node though (except for Node0 which is special and
> never goes away completely). If this turns out to be a problem in the
> real life we can tweak the code to store hotplug flag into memblocks
> but let's keep this simple now.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> I am sending this as an RFC because this is a user visible change change
> of behavior, strictly speaking. I believe it is a desirable change of
> behavior, thought, and it an explicit opt-in (kernel parameter) is
> required to see the change so I do not expect any breakage. I would
> still like to hear what other people think about this shift. I have
> tested it on a memory hotplug capable HW where the whole numa node can
> be hotremove/added.
> 
> Does anybody see any problem with the proposed semantic?
> 
>  mm/memory_hotplug.c | 19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b98fb0b3ae11..74d75583736c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -943,6 +943,19 @@ struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
>  	return &pgdat->node_zones[ZONE_NORMAL];
>  }
>  
> +static inline bool movable_pfn_range(int nid, struct zone *default_zone,
> +		unsigned long start_pfn, unsigned long nr_pages)
> +{
> +	if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
> +				MMOP_ONLINE_KERNEL))
> +		return true;
> +
> +	if (!movable_node_is_enabled())
> +		return false;
> +
> +	return !zone_intersects(default_zone, start_pfn, nr_pages);
> +}
> +
>  /*
>   * Associates the given pfn range with the given node and the zone appropriate
>   * for the given online type.
> @@ -958,10 +971,10 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
>  		/*
>  		 * MMOP_ONLINE_KEEP defaults to MMOP_ONLINE_KERNEL but use
>  		 * movable zone if that is not possible (e.g. we are within
> -		 * or past the existing movable zone)
> +		 * or past the existing movable zone). movable_node overrides
> +		 * this default and defaults to movable zone
>  		 */
> -		if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
> -					MMOP_ONLINE_KERNEL))
> +		if (movable_pfn_range(nid, zone, start_pfn, nr_pages))
>  			zone = movable_zone;
>  	} else if (online_type == MMOP_ONLINE_MOVABLE) {
>  		zone = &pgdat->node_zones[ZONE_MOVABLE];
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
