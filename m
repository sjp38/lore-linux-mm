Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC976B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 08:23:26 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id t30so4742476wra.7
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 05:23:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18sor742166wmc.10.2017.06.08.05.23.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Jun 2017 05:23:24 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, memory_hotplug: support movable_node for hotplugable nodes
Date: Thu,  8 Jun 2017 14:23:18 +0200
Message-Id: <20170608122318.31598-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

movable_node kernel parameter allows to make hotplugable NUMA
nodes to put all the hotplugable memory into movable zone which
allows more or less reliable memory hotremove.  At least this
is the case for the NUMA nodes present during the boot (see
find_zone_movable_pfns_for_nodes).

This is not the case for the memory hotplug, though.

	echo online > /sys/devices/system/memory/memoryXYZ/status

will default to a kernel zone (usually ZONE_NORMAL) unless the
particular memblock is already in the movable zone range which is not
the case normally when onlining the memory from the udev rule context
for a freshly hotadded NUMA node. The only option currently is to have a
special udev rule to echo online_movable to all memblocks belonging to
such a node which is rather clumsy. Not the mention this is inconsistent
as well because what ended up in the movable zone during the boot will
end up in a kernel zone after hotremove & hotadd without special care.

It would be nice to reuse memblock_is_hotpluggable but the runtime
hotplug doesn't have that information available because the boot and
hotplug paths are not shared and it would be really non trivial to
make them use the same code path because the runtime hotplug doesn't
play with the memblock allocator at all.

Teach move_pfn_range that MMOP_ONLINE_KEEP can use the movable zone if
movable_node is enabled and the range doesn't overlap with the existing
normal zone. This should provide a reasonable default onlining strategy.

Strictly speaking the semantic is not identical with the boot time
initialization because find_zone_movable_pfns_for_nodes covers only the
hotplugable range as described by the BIOS/FW. From my experience this
is usually a full node though (except for Node0 which is special and
never goes away completely). If this turns out to be a problem in the
real life we can tweak the code to store hotplug flag into memblocks
but let's keep this simple now.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi Andrew,
I've posted this as an RFC previously [1] and there haven't been any
objections to the approach so I've dropped the RFC and sending it for
inclusion. The only change since the last time is the update of the
documentation to clarify the semantic as suggested by Reza Arbab.

[1] http://lkml.kernel.org/r/20170601122004.32732-1-mhocko@kernel.org

 Documentation/memory-hotplug.txt | 12 +++++++++---
 mm/memory_hotplug.c              | 19 ++++++++++++++++---
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 670f3ded0802..5c628e19d6cd 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -282,20 +282,26 @@ offlined it is possible to change the individual block's state by writing to the
 % echo online > /sys/devices/system/memory/memoryXXX/state
 
 This onlining will not change the ZONE type of the target memory block,
-If the memory block is in ZONE_NORMAL, you can change it to ZONE_MOVABLE:
+If the memory block doesn't belong to any zone an appropriate kernel zone
+(usually ZONE_NORMAL) will be used unless movable_node kernel command line
+option is specified when ZONE_MOVABLE will be used.
+
+You can explicitly request to associate it with ZONE_MOVABLE by
 
 % echo online_movable > /sys/devices/system/memory/memoryXXX/state
 (NOTE: current limit: this memory block must be adjacent to ZONE_MOVABLE)
 
-And if the memory block is in ZONE_MOVABLE, you can change it to ZONE_NORMAL:
+Or you can explicitly request a kernel zone (usually ZONE_NORMAL) by:
 
 % echo online_kernel > /sys/devices/system/memory/memoryXXX/state
 (NOTE: current limit: this memory block must be adjacent to ZONE_NORMAL)
 
+An explicit zone onlining can fail (e.g. when the range is already within
+and existing and incompatible zone already).
+
 After this, memory block XXX's state will be 'online' and the amount of
 available memory will be increased.
 
-Currently, newly added memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA).
 This may be changed in future.
 
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b98fb0b3ae11..74d75583736c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -943,6 +943,19 @@ struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
 	return &pgdat->node_zones[ZONE_NORMAL];
 }
 
+static inline bool movable_pfn_range(int nid, struct zone *default_zone,
+		unsigned long start_pfn, unsigned long nr_pages)
+{
+	if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
+				MMOP_ONLINE_KERNEL))
+		return true;
+
+	if (!movable_node_is_enabled())
+		return false;
+
+	return !zone_intersects(default_zone, start_pfn, nr_pages);
+}
+
 /*
  * Associates the given pfn range with the given node and the zone appropriate
  * for the given online type.
@@ -958,10 +971,10 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 		/*
 		 * MMOP_ONLINE_KEEP defaults to MMOP_ONLINE_KERNEL but use
 		 * movable zone if that is not possible (e.g. we are within
-		 * or past the existing movable zone)
+		 * or past the existing movable zone). movable_node overrides
+		 * this default and defaults to movable zone
 		 */
-		if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
-					MMOP_ONLINE_KERNEL))
+		if (movable_pfn_range(nid, zone, start_pfn, nr_pages))
 			zone = movable_zone;
 	} else if (online_type == MMOP_ONLINE_MOVABLE) {
 		zone = &pgdat->node_zones[ZONE_MOVABLE];
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
