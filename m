Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 013FC6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 07:35:47 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id x130so412712369vkc.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:35:46 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id o10si7926433qtb.120.2016.08.04.04.35.44
        for <linux-mm@kvack.org>;
        Thu, 04 Aug 2016 04:35:46 -0700 (PDT)
Message-ID: <57A325E8.6070100@huawei.com>
Date: Thu, 4 Aug 2016 19:24:24 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] mem-hotplug: fix node spanned pages when we have a movable
 node
References: <57A325CA.9050707@huawei.com>
In-Reply-To: <57A325CA.9050707@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

commit 342332e6a925e9ed015e5465062c38d2b86ec8f9 rewrite the calculate of
node spanned pages. But when we have a movable node, the size of node spanned
pages is double added. That's because we have an empty normal zone, the present
pages is zero, but its spanned pages is not zero.

e.g.
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x0000007c7fffffff]
[    0.000000] Movable zone start for each node
[    0.000000]   Node 1: 0x0000001080000000
[    0.000000]   Node 2: 0x0000002080000000
[    0.000000]   Node 3: 0x0000003080000000
[    0.000000]   Node 4: 0x0000003c80000000
[    0.000000]   Node 5: 0x0000004c80000000
[    0.000000]   Node 6: 0x0000005c80000000
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009ffff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007552afff]
[    0.000000]   node   0: [mem 0x000000007bd46000-0x000000007bd46fff]
[    0.000000]   node   0: [mem 0x000000007bdcd000-0x000000007bffffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000107fffffff]
[    0.000000]   node   1: [mem 0x0000001080000000-0x000000207fffffff]
[    0.000000]   node   2: [mem 0x0000002080000000-0x000000307fffffff]
[    0.000000]   node   3: [mem 0x0000003080000000-0x0000003c7fffffff]
[    0.000000]   node   4: [mem 0x0000003c80000000-0x0000004c7fffffff]
[    0.000000]   node   5: [mem 0x0000004c80000000-0x0000005c7fffffff]
[    0.000000]   node   6: [mem 0x0000005c80000000-0x0000006c7fffffff]
[    0.000000]   node   7: [mem 0x0000006c80000000-0x0000007c7fffffff]

node1:
[  760.227767] Normal, start=0x1080000, present=0x0, spanned=0x1000000
[  760.234024] Movable, start=0x1080000, present=0x1000000, spanned=0x1000000
[  760.240883] pgdat, start=0x1080000, present=0x1000000, spanned=0x2000000

After apply this patch, the problem is fixed.
node1:
[  289.770922] Normal, start=0x0, present=0x0, spanned=0x0
[  289.776153] Movable, start=0x1080000, present=0x1000000, spanned=0x1000000
[  289.783019] pgdat, start=0x1080000, present=0x1000000, spanned=0x1000000

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 54 +++++++++++++++++++++++-------------------------------
 1 file changed, 23 insertions(+), 31 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b69..2b258ec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5173,15 +5173,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 		/*
-		 * If not mirrored_kernelcore and ZONE_MOVABLE exists, range
-		 * from zone_movable_pfn[nid] to end of each node should be
-		 * ZONE_MOVABLE not ZONE_NORMAL. skip it.
-		 */
-		if (!mirrored_kernelcore && zone_movable_pfn[nid])
-			if (zone == ZONE_NORMAL && pfn >= zone_movable_pfn[nid])
-				continue;
-
-		/*
 		 * Check given memblock attribute by firmware which can affect
 		 * kernel memory layout.  If zone==ZONE_MOVABLE but memory is
 		 * mirrored, it's an overlapped memmap init. skip it.
@@ -5619,6 +5610,12 @@ static void __meminit adjust_zone_range_for_zone_movable(int nid,
 			*zone_end_pfn = min(node_end_pfn,
 				arch_zone_highest_possible_pfn[movable_zone]);
 
+		/* Adjust for ZONE_MOVABLE starting within this range */
+		} else if (!mirrored_kernelcore &&
+			*zone_start_pfn < zone_movable_pfn[nid] &&
+			*zone_end_pfn > zone_movable_pfn[nid]) {
+			*zone_end_pfn = zone_movable_pfn[nid];
+
 		/* Check if this whole range is within ZONE_MOVABLE */
 		} else if (*zone_start_pfn >= zone_movable_pfn[nid])
 			*zone_start_pfn = *zone_end_pfn;
@@ -5722,28 +5719,23 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 	 * Treat pages to be ZONE_MOVABLE in ZONE_NORMAL as absent pages
 	 * and vice versa.
 	 */
-	if (zone_movable_pfn[nid]) {
-		if (mirrored_kernelcore) {
-			unsigned long start_pfn, end_pfn;
-			struct memblock_region *r;
-
-			for_each_memblock(memory, r) {
-				start_pfn = clamp(memblock_region_memory_base_pfn(r),
-						  zone_start_pfn, zone_end_pfn);
-				end_pfn = clamp(memblock_region_memory_end_pfn(r),
-						zone_start_pfn, zone_end_pfn);
-
-				if (zone_type == ZONE_MOVABLE &&
-				    memblock_is_mirror(r))
-					nr_absent += end_pfn - start_pfn;
-
-				if (zone_type == ZONE_NORMAL &&
-				    !memblock_is_mirror(r))
-					nr_absent += end_pfn - start_pfn;
-			}
-		} else {
-			if (zone_type == ZONE_NORMAL)
-				nr_absent += node_end_pfn - zone_movable_pfn[nid];
+	if (mirrored_kernelcore && zone_movable_pfn[nid]) {
+		unsigned long start_pfn, end_pfn;
+		struct memblock_region *r;
+
+		for_each_memblock(memory, r) {
+			start_pfn = clamp(memblock_region_memory_base_pfn(r),
+					  zone_start_pfn, zone_end_pfn);
+			end_pfn = clamp(memblock_region_memory_end_pfn(r),
+					zone_start_pfn, zone_end_pfn);
+
+			if (zone_type == ZONE_MOVABLE &&
+			    memblock_is_mirror(r))
+				nr_absent += end_pfn - start_pfn;
+
+			if (zone_type == ZONE_NORMAL &&
+			    !memblock_is_mirror(r))
+				nr_absent += end_pfn - start_pfn;
 		}
 	}
 
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
