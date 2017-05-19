Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D20B831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 04:56:49 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w50so3777847wrc.4
        for <linux-mm@kvack.org>; Fri, 19 May 2017 01:56:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si8320091edj.302.2017.05.19.01.56.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 01:56:48 -0700 (PDT)
Subject: Re: [PATCH 11/14] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-12-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <08c6179d-a5ff-2e14-d360-28f57d2763db@suse.cz>
Date: Fri, 19 May 2017 10:56:46 +0200
MIME-Version: 1.0
In-Reply-To: <20170515085827.16474-12-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 05/15/2017 10:58 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
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
> $ echo 0x100000000 > /sys/devices/system/memory/probe
> $ grep . /sys/devices/system/memory/memory32/valid_zones
> Normal Movable
> 
> $ echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
> $ grep . /sys/devices/system/memory/memory3?/valid_zones
> /sys/devices/system/memory/memory32/valid_zones:Normal
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> 
> $ echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
> $ grep . /sys/devices/system/memory/memory3?/valid_zones
> /sys/devices/system/memory/memory32/valid_zones:Normal
> /sys/devices/system/memory/memory33/valid_zones:Normal
> /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> 
> $ echo online_movable > /sys/devices/system/memory/memory34/state
> $ grep . /sys/devices/system/memory/memory3?/valid_zones
> /sys/devices/system/memory/memory32/valid_zones:Normal
> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> /sys/devices/system/memory/memory34/valid_zones:Movable Normal
> 
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
> 
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
> Please note that this patch also changes the original behavior when
> offlining a memory block adjacent to another zone (Normal vs. Movable)
> used to allow to change its movable type. This will be handled later.
> 
> Changes since v1
> - we have to associate the page with the node early (in __add_section),
>   because pfn_to_node depends on struct page containing this
>   information - based on testing by Reza Arbab
> - resize_{zone,pgdat}_range has to check whether they are popoulated -
>   Reza Arbab
> - fix devm_memremap_pages to use pfn rather than physical address -
>   JA(C)rA'me Glisse
> - move_pfn_range has to check for intersection with zone_movable rather
>   than to rely on allow_online_pfn_range(MMOP_ONLINE_MOVABLE) for
>   MMOP_ONLINE_KEEP
> 
> Changes since v2
> - fix show_valid_zones nr_pages calculation
> - allow_online_pfn_range has to check managed pages rather than present
> - zone_intersects fix bogus check
> - fix zone_intersects + few nits as per Vlastimil
> 
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: linux-arch@vger.kernel.org
> Tested-by: Dan Williams <dan.j.williams@intel.com>
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # For s390 bits
> Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
