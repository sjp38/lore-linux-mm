Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2F756B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 04:58:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g36so21517532wrg.4
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 01:58:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a104si9361814wrc.132.2017.06.12.01.58.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 01:58:57 -0700 (PDT)
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
References: <20170608122318.31598-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <40d41b19-607f-fbe4-d133-f1aecd548d7e@suse.cz>
Date: Mon, 12 Jun 2017 10:58:53 +0200
MIME-Version: 1.0
In-Reply-To: <20170608122318.31598-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/08/2017 02:23 PM, Michal Hocko wrote:
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

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
