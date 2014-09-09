Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1386B003A
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 10:46:36 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id w7so4181244lbi.3
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 07:46:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x7si18079012lbi.116.2014.09.09.07.46.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 07:46:35 -0700 (PDT)
Date: Tue, 9 Sep 2014 15:46:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page_alloc: Default node-ordering on 64-bit NUMA,
 zone-ordering on 32-bit v2
Message-ID: <20140909144630.GA12309@suse.de>
References: <20140901125551.GI12424@suse.de>
 <20140902135120.GC29501@cmpxchg.org>
 <20140902152143.GL12424@suse.de>
 <20140904152915.GB10794@cmpxchg.org>
 <20140905103041.GH17501@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140905103041.GH17501@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linuxfoundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changelog since v1
o Default to zone-ordering on 32-bit and remove heuristics
o Expand changelog

Zones are allocated by the page allocator in either node or zone order.
Node ordering is preferred in terms of locality and is applied automatically
in one of three cases.

  1. If a node has only low memory

  2. If DMA/DMA32 is a high percentage of memory

  3. If low memory on a single node is greater than 70% of the node size

Otherwise zone ordering is used to preserve low memory for devices that
require it. Unfortunately a consequence of this is that a machine with
balanced NUMA nodes will experience different performance characteristics
depending on which node they happen to start from.

The point of zone ordering is to protect lower nodes for devices that
require DMA/DMA32 memory. When NUMA was first introduced, this was critical
as 32-bit NUMA machines existed and exhausting low memory triggered OOMs
easily as so many allocations required low memory. On 64-bit machines the
primary concern is devices that are 32-bit only which is less severe than
the low memory exhaustion problem on 32-bit NUMA. It seems there are really
few devices that depends on it.

AGP -- I assume this is getting more rare but even then I think the allocations
	happen early in boot time where lowmem pressure is less of a problem

DRM -- If the device is 32-bit only then there may be low pressure. I didn't
	evaluate these in detail but it looks like some of these are mobile
	graphics card. Not many NUMA laptops out there. DRM folk should know
	better though.

Some TV cards -- Much demand for 32-bit capable TV cards on NUMA machines?

B43 wireless card -- again not really a NUMA thing.

I cannot find a good reason to incur a performance penalty on all 64-bit NUMA
machines in case someone throws a brain damanged TV or graphics card in there.
This patch defaults to node-ordering on 64-bit NUMA machines. I was tempted
to make it default everywhere but I understand that some embedded arches may
be using 32-bit NUMA where I cannot predict the consequences.

The performance impact depends on the workload and the characteristics of the
machine and the machine I tested on had a large Normal zone on node 0 so the
impact is within the noise for the majority of tests. The allocation stats
show more allocation requests were from DMA32 and local node. Running SpecJBB
with multiple JVMs and automatic NUMA balancing disabled the results were

specjbb
                     3.17.0-rc2            3.17.0-rc2
                        vanilla        nodeorder-v1r1
Min    1      29534.00 (  0.00%)     30020.00 (  1.65%)
Min    10    115717.00 (  0.00%)    134038.00 ( 15.83%)
Min    19    109718.00 (  0.00%)    114186.00 (  4.07%)
Min    28    104459.00 (  0.00%)    103639.00 ( -0.78%)
Min    37     98245.00 (  0.00%)    103756.00 (  5.61%)
Min    46     97198.00 (  0.00%)     96197.00 ( -1.03%)
Mean   1      30953.25 (  0.00%)     31917.75 (  3.12%)
Mean   10    124432.50 (  0.00%)    140904.00 ( 13.24%)
Mean   19    116033.50 (  0.00%)    119294.75 (  2.81%)
Mean   28    108365.25 (  0.00%)    106879.50 ( -1.37%)
Mean   37    102984.75 (  0.00%)    106924.25 (  3.83%)
Mean   46    100783.25 (  0.00%)    105368.50 (  4.55%)
Stddev 1       1260.38 (  0.00%)      1109.66 ( 11.96%)
Stddev 10      7434.03 (  0.00%)      5171.91 ( 30.43%)
Stddev 19      8453.84 (  0.00%)      5309.59 ( 37.19%)
Stddev 28      4184.55 (  0.00%)      2906.63 ( 30.54%)
Stddev 37      5409.49 (  0.00%)      3192.12 ( 40.99%)
Stddev 46      4521.95 (  0.00%)      7392.52 (-63.48%)
Max    1      32738.00 (  0.00%)     32719.00 ( -0.06%)
Max    10    136039.00 (  0.00%)    148614.00 (  9.24%)
Max    19    130566.00 (  0.00%)    127418.00 ( -2.41%)
Max    28    115404.00 (  0.00%)    111254.00 ( -3.60%)
Max    37    112118.00 (  0.00%)    111732.00 ( -0.34%)
Max    46    108541.00 (  0.00%)    116849.00 (  7.65%)
TPut   1     123813.00 (  0.00%)    127671.00 (  3.12%)
TPut   10    497730.00 (  0.00%)    563616.00 ( 13.24%)
TPut   19    464134.00 (  0.00%)    477179.00 (  2.81%)
TPut   28    433461.00 (  0.00%)    427518.00 ( -1.37%)
TPut   37    411939.00 (  0.00%)    427697.00 (  3.83%)
TPut   46    403133.00 (  0.00%)    421474.00 (  4.55%)

                            3.17.0-rc2  3.17.0-rc2
                               vanillanodeorder-v1r1
DMA allocs                           0           0
DMA32 allocs                        57     1491992
Normal allocs                 32543566    30026383
Movable allocs                       0           0
Direct pages scanned                 0           0
Kswapd pages scanned                 0           0
Kswapd pages reclaimed               0           0
Direct pages reclaimed               0           0
Kswapd efficiency                 100%        100%
Kswapd velocity                  0.000       0.000
Direct efficiency                 100%        100%
Direct velocity                  0.000       0.000
Percentage direct scans             0%          0%
Zone normal velocity             0.000       0.000
Zone dma32 velocity              0.000       0.000
Zone dma velocity                0.000       0.000
THP fault alloc                  55164       52987
THP collapse alloc                 139         147
THP splits                          26          21
NUMA alloc hit                 4169066     4250692
NUMA alloc miss                      0           0

Note that there were more DMA32 allocations with the patch applied.  In this
particular case there was no difference in numa_hit and numa_miss. The
expectation is that DMA32 was being used at the low watermark instead of
falling into the slow path. kswapd was not woken but it's not worken for
THP allocations.

On 32-bit, this patch defaults to zone-ordering as low memory depletion
can be a serious problem on 32-bit large memory machines. If the default
ordering was node then processes on node 0 will deplete the Normal zone
due to normal activity.  The problem is worse if CONFIG_HIGHPTE is not
set. If combined with large amounts of dirty/writeback pages in Normal
zone then there is also a high risk of OOM. The heuristics are removed
as it's not clear they were ever important on 32-bit. They were only
relevant for setting node-ordering on 64-bit.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 78 +++++++++++++++------------------------------------------
 1 file changed, 20 insertions(+), 58 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d..0a7ed33 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3579,68 +3579,30 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 	zonelist->_zonerefs[pos].zone_idx = 0;
 }
 
+#if defined(CONFIG_64BIT)
+/*
+ * Devices that require DMA32/DMA are relatively rare and do not justify a
+ * penalty to every machine in case the specialised case applies. Default
+ * to Node-ordering on 64-bit NUMA machines
+ */
+static int default_zonelist_order(void)
+{
+	return ZONELIST_ORDER_NODE;
+}
+#else
+/*
+ * On 32-bit, the Normal zone needs to be preserved for allocations accessible
+ * by the kernel. If processes running on node 0 deplete the low memory zone
+ * then reclaim will occur more frequency increasing stalls and potentially
+ * be easier to OOM if a large percentage of the zone is under writeback or
+ * dirty. The problem is significantly worse if CONFIG_HIGHPTE is not set.
+ * Hence, default to zone ordering on 32-bit.
+ */
 static int default_zonelist_order(void)
 {
-	int nid, zone_type;
-	unsigned long low_kmem_size, total_size;
-	struct zone *z;
-	int average_size;
-	/*
-	 * ZONE_DMA and ZONE_DMA32 can be very small area in the system.
-	 * If they are really small and used heavily, the system can fall
-	 * into OOM very easily.
-	 * This function detect ZONE_DMA/DMA32 size and configures zone order.
-	 */
-	/* Is there ZONE_NORMAL ? (ex. ppc has only DMA zone..) */
-	low_kmem_size = 0;
-	total_size = 0;
-	for_each_online_node(nid) {
-		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
-			z = &NODE_DATA(nid)->node_zones[zone_type];
-			if (populated_zone(z)) {
-				if (zone_type < ZONE_NORMAL)
-					low_kmem_size += z->managed_pages;
-				total_size += z->managed_pages;
-			} else if (zone_type == ZONE_NORMAL) {
-				/*
-				 * If any node has only lowmem, then node order
-				 * is preferred to allow kernel allocations
-				 * locally; otherwise, they can easily infringe
-				 * on other nodes when there is an abundance of
-				 * lowmem available to allocate from.
-				 */
-				return ZONELIST_ORDER_NODE;
-			}
-		}
-	}
-	if (!low_kmem_size ||  /* there are no DMA area. */
-	    low_kmem_size > total_size/2) /* DMA/DMA32 is big. */
-		return ZONELIST_ORDER_NODE;
-	/*
-	 * look into each node's config.
-	 * If there is a node whose DMA/DMA32 memory is very big area on
-	 * local memory, NODE_ORDER may be suitable.
-	 */
-	average_size = total_size /
-				(nodes_weight(node_states[N_MEMORY]) + 1);
-	for_each_online_node(nid) {
-		low_kmem_size = 0;
-		total_size = 0;
-		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
-			z = &NODE_DATA(nid)->node_zones[zone_type];
-			if (populated_zone(z)) {
-				if (zone_type < ZONE_NORMAL)
-					low_kmem_size += z->present_pages;
-				total_size += z->present_pages;
-			}
-		}
-		if (low_kmem_size &&
-		    total_size > average_size && /* ignore small node */
-		    low_kmem_size > total_size * 70/100)
-			return ZONELIST_ORDER_NODE;
-	}
 	return ZONELIST_ORDER_ZONE;
 }
+#endif /* CONFIG_64BIT */
 
 static void set_zonelist_order(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
