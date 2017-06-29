Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 651E2280300
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 03:35:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v88so35273766wrb.1
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 00:35:23 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id r15si3214352wrr.99.2017.06.29.00.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 00:35:21 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id u23so843158wma.2
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 00:35:21 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Date: Thu, 29 Jun 2017 09:35:09 +0200
Message-Id: <20170629073509.623-3-mhocko@kernel.org>
In-Reply-To: <20170629073509.623-1-mhocko@kernel.org>
References: <20170629073509.623-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Historically we have enforced that any kernel zone (e.g ZONE_NORMAL) has
to precede the Movable zone in the physical memory range. The purpose of
the movable zone is, however, not bound to any physical memory restriction.
It merely defines a class of migrateable and reclaimable memory.

There are users (e.g. CMA) who might want to reserve specific physical
memory ranges for their own purpose. Moreover our pfn walkers have to be
prepared for zones overlapping in the physical range already because we
do support interleaving NUMA nodes and therefore zones can interleave as
well. This means we can allow each memory block to be associated with a
different zone.

Loosen the current onlining semantic and allow explicit onlining type on
any memblock. That means that online_{kernel,movable} will be allowed
regardless of the physical address of the memblock as long as it is
offline of course. This might result in moveble zone overlapping with
other kernel zones. Default onlining then becomes a bit tricky but still
sensible. echo online > memoryXY/state will online the given block to
	1) the default zone if the given range is outside of any zone
	2) the enclosing zone if such a zone doesn't interleave with
	   any other zone
        3) the default zone if more zones interleave for this range
where default zone is movable zone only if movable_node is enabled
otherwise it is a kernel zone.

Here is an example of the semantic with (movable_node is not present but
it work in an analogous way). We start with following memblocks, all of
them offline
memory34/valid_zones:Normal Movable
memory35/valid_zones:Normal Movable
memory36/valid_zones:Normal Movable
memory37/valid_zones:Normal Movable
memory38/valid_zones:Normal Movable
memory39/valid_zones:Normal Movable
memory40/valid_zones:Normal Movable
memory41/valid_zones:Normal Movable

Now, we online block 34 in default mode and block 37 as movable
root@test1:/sys/devices/system/node/node1# echo online > memory34/state
root@test1:/sys/devices/system/node/node1# echo online_movable > memory37/state
memory34/valid_zones:Normal
memory35/valid_zones:Normal Movable
memory36/valid_zones:Normal Movable
memory37/valid_zones:Movable
memory38/valid_zones:Normal Movable
memory39/valid_zones:Normal Movable
memory40/valid_zones:Normal Movable
memory41/valid_zones:Normal Movable

As we can see all other blocks can still be onlined both into Normal and
Movable zones and the Normal is default because the Movable zone spans
only block37 now.
root@test1:/sys/devices/system/node/node1# echo online_movable > memory41/state
memory34/valid_zones:Normal
memory35/valid_zones:Normal Movable
memory36/valid_zones:Normal Movable
memory37/valid_zones:Movable
memory38/valid_zones:Movable Normal
memory39/valid_zones:Movable Normal
memory40/valid_zones:Movable Normal
memory41/valid_zones:Movable

Now the default zone for blocks 37-41 has changed because movable zone
spans that range.
root@test1:/sys/devices/system/node/node1# echo online_kernel > memory39/state
memory34/valid_zones:Normal
memory35/valid_zones:Normal Movable
memory36/valid_zones:Normal Movable
memory37/valid_zones:Movable
memory38/valid_zones:Normal Movable
memory39/valid_zones:Normal
memory40/valid_zones:Movable Normal
memory41/valid_zones:Movable

Note that the block 39 now belongs to the zone Normal and so block38
falls into Normal by default as well.

For completness
root@test1:/sys/devices/system/node/node1# for i in memory[34]?
do
	echo online > $i/state 2>/dev/null
done

memory34/valid_zones:Normal
memory35/valid_zones:Normal
memory36/valid_zones:Normal
memory37/valid_zones:Movable
memory38/valid_zones:Normal
memory39/valid_zones:Normal
memory40/valid_zones:Movable
memory41/valid_zones:Movable

Implementation wise the change is quite straightforward. We can get rid
of allow_online_pfn_range altogether. online_pages allows only offline
nodes already. The original default_zone_for_pfn will become
default_kernel_zone_for_pfn. New default_zone_for_pfn implements the
above semantic. zone_for_pfn_range is slightly reorganized to implement
kernel and movable online type explicitly and MMOP_ONLINE_KEEP becomes
a catch all default behavior.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/memory.c |  3 ---
 mm/memory_hotplug.c   | 74 ++++++++++++++++-----------------------------------
 2 files changed, 23 insertions(+), 54 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 26383af9900c..4e3b61cda520 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -394,9 +394,6 @@ static void print_allowed_zone(char *buf, int nid, unsigned long start_pfn,
 {
 	struct zone *zone;
 
-	if (!allow_online_pfn_range(nid, start_pfn, nr_pages, online_type))
-		return;
-
 	zone = zone_for_pfn_range(online_type, nid, start_pfn, nr_pages);
 	if (zone != default_zone) {
 		strcat(buf, " ");
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6b9a60115e37..670f7acbecf4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -894,7 +894,7 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
  * If no kernel zone covers this pfn range it will automatically go
  * to the ZONE_NORMAL.
  */
-static struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
+static struct zone *default_kernel_zone_for_pfn(int nid, unsigned long start_pfn,
 		unsigned long nr_pages)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);
@@ -910,65 +910,40 @@ static struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
 	return &pgdat->node_zones[ZONE_NORMAL];
 }
 
-bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages, int online_type)
+static inline struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
+		unsigned long nr_pages)
 {
-	struct pglist_data *pgdat = NODE_DATA(nid);
-	struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
-	struct zone *default_zone = default_zone_for_pfn(nid, pfn, nr_pages);
+	struct zone *kernel_zone = default_kernel_zone_for_pfn(nid, start_pfn,
+			nr_pages);
+	struct zone *movable_zone = &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
+	bool in_kernel = zone_intersects(kernel_zone, start_pfn, nr_pages);
+	bool in_movable = zone_intersects(movable_zone, start_pfn, nr_pages);
 
 	/*
-	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
-	 * physically before ZONE_MOVABLE. All we need is they do not
-	 * overlap. Historically we didn't allow ZONE_NORMAL after ZONE_MOVABLE
-	 * though so let's stick with it for simplicity for now.
-	 * TODO make sure we do not overlap with ZONE_DEVICE
+	 * We inherit the existing zone in a simple case where zones do not
+	 * overlap in the given range
 	 */
-	if (online_type == MMOP_ONLINE_KERNEL) {
-		if (zone_is_empty(movable_zone))
-			return true;
-		return movable_zone->zone_start_pfn >= pfn + nr_pages;
-	} else if (online_type == MMOP_ONLINE_MOVABLE) {
-		return zone_end_pfn(default_zone) <= pfn;
-	}
-
-	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
-	return online_type == MMOP_ONLINE_KEEP;
-}
-
-static inline bool movable_pfn_range(int nid, struct zone *default_zone,
-		unsigned long start_pfn, unsigned long nr_pages)
-{
-	if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
-				MMOP_ONLINE_KERNEL))
-		return true;
-
-	if (!movable_node_is_enabled())
-		return false;
+	if (in_kernel ^ in_movable)
+		return (in_kernel) ? kernel_zone : movable_zone;
 
-	return !zone_intersects(default_zone, start_pfn, nr_pages);
+	/*
+	 * If the range doesn't belong to any zone or two zones overlap in the
+	 * given range then we use movable zone only if movable_node is
+	 * enabled because we always online to a kernel zone by default.
+	 */
+	return movable_node_enabled ? movable_zone : kernel_zone;
 }
 
 struct zone * zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
 		unsigned long nr_pages)
 {
-	struct pglist_data *pgdat = NODE_DATA(nid);
-	struct zone *zone = default_zone_for_pfn(nid, start_pfn, nr_pages);
+	if (online_type == MMOP_ONLINE_KERNEL)
+		return default_kernel_zone_for_pfn(nid, start_pfn, nr_pages);
 
-	if (online_type == MMOP_ONLINE_KEEP) {
-		struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
-		/*
-		 * MMOP_ONLINE_KEEP defaults to MMOP_ONLINE_KERNEL but use
-		 * movable zone if that is not possible (e.g. we are within
-		 * or past the existing movable zone). movable_node overrides
-		 * this default and defaults to movable zone
-		 */
-		if (movable_pfn_range(nid, zone, start_pfn, nr_pages))
-			zone = movable_zone;
-	} else if (online_type == MMOP_ONLINE_MOVABLE) {
-		zone = &pgdat->node_zones[ZONE_MOVABLE];
-	}
+	if (online_type == MMOP_ONLINE_MOVABLE)
+		return &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
 
-	return zone;
+	return default_zone_for_pfn(nid, start_pfn, nr_pages);
 }
 
 /*
@@ -997,9 +972,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	struct memory_notify arg;
 
 	nid = pfn_to_nid(pfn);
-	if (!allow_online_pfn_range(nid, pfn, nr_pages, online_type))
-		return -EINVAL;
-
 	/* associate pfn range with the zone */
 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
