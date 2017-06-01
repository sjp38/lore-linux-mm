Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3F16B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 10:12:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x184so10411054wmf.14
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:12:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si20079373edd.72.2017.06.01.07.12.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 07:12:00 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, memory_hotplug: support movable_node for
 hotplugable nodes
References: <20170601122004.32732-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <820164f3-8bef-7761-0695-88db9e0ce7a7@suse.cz>
Date: Thu, 1 Jun 2017 16:11:55 +0200
MIME-Version: 1.0
In-Reply-To: <20170601122004.32732-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/01/2017 02:20 PM, Michal Hocko wrote:
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

Yeah, it would be better if movable_node worked consistently for both
boot and runtime hotplug.

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

Simple should work, hopefully.
- if memory is hotplugged, it's obviously hotplugable, so we don't have
to rely on BIOS description.
- there shouldn't be a reason to offline a non-removable (part of) node
and online it back (which would move it from Normal to Movable after
your patch?), right?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
