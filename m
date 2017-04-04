Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58E986B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 08:24:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z36so28300231wrc.14
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 05:24:13 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id u66si24301204wrb.292.2017.04.04.05.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 05:24:11 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id k6so40428387wre.3
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 05:24:11 -0700 (PDT)
Date: Tue, 4 Apr 2017 14:21:19 +0200
From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: Re: [PATCH 5/6] mm, memory_hotplug: do not associate hotadded memory
 to zones until online
Message-ID: <20170404122119.qsj3bhqse2qp46fi@builder>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-6-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330115454.32154-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 30.03.17, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> The current memory hotplug implementation relies on having all the
> struct pages associate with a zone during the physical hotplug phase
> (arch_add_memory->__add_pages->__add_section->__add_zone). In the vast
> majority of cases this means that they are added to ZONE_NORMAL. This
> has been so since 9d99aaa31f59 ("[PATCH] x86_64: Support memory hotadd
> without sparsemem") and it wasn't a big deal back then.
> 
> Much later memory hotplug wanted to (ab)use ZONE_MOVABLE for movable
> onlining 511c2aba8f07 ("mm, memory-hotplug: dynamic configure movable
> memory and portion memory") and then things got more complicated. Rather
> than reconsidering the zone association which was no longer needed
> (because the memory hotplug already depended on SPARSEMEM) a convoluted
> semantic of zone shifting has been developed. Only the currently last
> memblock or the one adjacent to the zone_movable can be onlined movable.
> This essentially means that the online time changes as the new memblocks
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
> the later on is not inherent and can be changed in the future. It
> preserves the current behavior and made the code slightly simpler. This
> is subject to change in future.
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
> Cc: Lai Jiangshan <laijs@cn.fujitsu.com>
> Cc: Dan Williams <dan.j.williams@gmail.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: linux-arch@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/ia64/mm/init.c            |   8 +-
>  arch/powerpc/mm/mem.c          |  10 +--
>  arch/s390/mm/init.c            |  30 +------
>  arch/sh/mm/init.c              |   7 +-
>  arch/x86/mm/init_32.c          |   5 +-
>  arch/x86/mm/init_64.c          |   9 +-
>  drivers/base/memory.c          |  52 ++++++-----
>  include/linux/memory_hotplug.h |  13 +--
>  kernel/memremap.c              |   3 +
>  mm/memory_hotplug.c            | 195 +++++++++++++++++++++++++----------------
>  mm/sparse.c                    |   3 +-
>  11 files changed, 165 insertions(+), 170 deletions(-
> 

Hi Michal,

building an x86 allmodconfig with next-20170404 results in the following 
section mismatch warnings probably caused by this patch:

WARNING: mm/built-in.o(.text+0x5a1c2): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:memmap_init_zone()
The function move_pfn_range_to_zone() references
the function __meminit memmap_init_zone().
This is often because move_pfn_range_to_zone lacks a __meminit 
annotation or the annotation of memmap_init_zone is wrong.

WARNING: mm/built-in.o(.text+0x5a25b): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:init_currently_empty_zone()
The function move_pfn_range_to_zone() references
the function __meminit init_currently_empty_zone().
This is often because move_pfn_range_to_zone lacks a __meminit 
annotation or the annotation of init_currently_empty_zone is wrong.

WARNING: vmlinux.o(.text+0x188aa2): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:memmap_init_zone()
The function move_pfn_range_to_zone() references
the function __meminit memmap_init_zone().
This is often because move_pfn_range_to_zone lacks a __meminit 
annotation or the annotation of memmap_init_zone is wrong.

WARNING: vmlinux.o(.text+0x188b3b): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:init_currently_empty_zone()
The function move_pfn_range_to_zone() references
the function __meminit init_currently_empty_zone().
This is often because move_pfn_range_to_zone lacks a __meminit 
annotation or the annotation of init_currently_empty_zone is wrong.

--
Tobias

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
