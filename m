Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71E5C6B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 02:45:06 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g36so20890869wrg.4
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 23:45:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b43si8143615wra.97.2017.06.11.23.45.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Jun 2017 23:45:05 -0700 (PDT)
Date: Mon, 12 Jun 2017 08:45:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170612064502.GD4145@dhcp22.suse.cz>
References: <20170608122318.31598-1-mhocko@kernel.org>
 <20170612042832.GA7429@WeideMBP.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170612042832.GA7429@WeideMBP.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Mon 12-06-17 12:28:32, Wei Yang wrote:
> On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >movable_node kernel parameter allows to make hotplugable NUMA
> >nodes to put all the hotplugable memory into movable zone which
> >allows more or less reliable memory hotremove.  At least this
> >is the case for the NUMA nodes present during the boot (see
> >find_zone_movable_pfns_for_nodes).
> >
> 
> When movable_node is enabled, we would have overlapped zones, right?

It won't based on this patch. See movable_pfn_range

> To be specific, only ZONE_MOVABLE could have memory ranges belongs to other
> zones.
> 
> This looks a little different in the whole ZONE design.
> 
> >This is not the case for the memory hotplug, though.
> >
> >	echo online > /sys/devices/system/memory/memoryXYZ/status
> >
> >will default to a kernel zone (usually ZONE_NORMAL) unless the
> >particular memblock is already in the movable zone range which is not
>             ^^^
> 
> Here is memblock or a memory_block?

yes

> 
> >the case normally when onlining the memory from the udev rule context
> >for a freshly hotadded NUMA node. The only option currently is to have a
> 
> So the semantic you want to change here is to make the memory_block in
> ZONE_MOVABLE when movable_node is enabled.

Yes, by default when there the specific range is not associated with any
other zone.

> Besides this, movable_node is enabled, what other requirements? Like, this
> memory_block should next to current ZONE_MOVABLE ? or something else?

no other requirements. 

> >special udev rule to echo online_movable to all memblocks belonging to
> >such a node which is rather clumsy. Not the mention this is inconsistent
>                                          ^^^
> 
> Hmm... "Not to mentions" looks more understandable.

yes this is a typo

> BTW, I am not a native speaker. If this usage is correct, just ignore this
> comment.
> 
> >as well because what ended up in the movable zone during the boot will
> >end up in a kernel zone after hotremove & hotadd without special care.
> >
> >It would be nice to reuse memblock_is_hotpluggable but the runtime
> >hotplug doesn't have that information available because the boot and
> >hotplug paths are not shared and it would be really non trivial to
> >make them use the same code path because the runtime hotplug doesn't
> >play with the memblock allocator at all.
> >
> >Teach move_pfn_range that MMOP_ONLINE_KEEP can use the movable zone if
> >movable_node is enabled and the range doesn't overlap with the existing
> >normal zone. This should provide a reasonable default onlining strategy.
> >
> >Strictly speaking the semantic is not identical with the boot time
> >initialization because find_zone_movable_pfns_for_nodes covers only the
> >hotplugable range as described by the BIOS/FW. From my experience this
> >is usually a full node though (except for Node0 which is special and
> >never goes away completely). If this turns out to be a problem in the
> >real life we can tweak the code to store hotplug flag into memblocks
> >but let's keep this simple now.
> >
> 
> Let me try to understand your purpose of this change.
> 
> If a memblock has MEMBLOCK_HOTPLU set, it would be in ZONE_MOVABLE during
> bootup. While a hotplugged memory_block would be in ZONE_NORMAL without
> special care.
> 
> So you want to make sure when movable_node is enabled, the hotplugged
> memory_block would be in ZONE_MOVABLE. Is this correct?

yes

> One more thing is do we have MEMBLOCK_HOTPLU for a hotplugged memory_block?

No, we do not, as the changelog mentions. This flag is set in the
memblock allocator (do not confuse that with the memory_block hotplug
works with - yeah quite confusing) and that is a boot only thing. We do
not use it during runtime memory hotplug.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
