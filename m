Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E81D6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 19:32:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a8so12119078pfc.6
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 16:32:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d190si1415345pfg.504.2017.10.20.16.32.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 16:32:11 -0700 (PDT)
Date: Fri, 20 Oct 2017 16:32:09 -0700
From: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Subject: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <ad310dfbfb86ef4f1f9a173cad1a030e879d572e.1508536900.git.sharath.k.bhat@linux.intel.com>
Reply-To: sharath.k.bhat@linux.intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

Currently when booted with the 'movable_node' kernel command-line the user
can not have both the functionality of 'movable_node' and at the same time
specify more movable memory than the total size of hotpluggable memories.

This is a problem because it limits the total amount of movable memory in
the system to the total size of hotpluggable memories and in a system the
total size of hotpluggable memories can be very small or all hotpluggable
memories could have been offlined. The 'movable_node' parameter was aimed
to provide the entire memory of hotpluggable NUMA nodes to applications
without any kernel allocations in them. The 'movable_node' option will be
useful if those hotpluggable nodes have special memory like MCDRAM as in
KNL which is a high bandwidth memory and the user would like to use all of
it for applications. But in doing so the 'movable_node' command-line poses
this limitation and does not allow the user to specify more movable memory
in addition to the hotpluggable memories.

With this change the existing 'movablecore=' and 'kernelcore=' command-line
parameters can be specified in addition to the 'movable_node' kernel
parameter. This allows the user to boot the kernel with an increased amount
of movable memory in the system and still have only movable memory in
hotpluggable NUMA nodes.

Ex:

Hardware  : Intel(R) Xeon Phi(TM) CPU 7250, SNC4 flat (cluster mode)
NUMA Nodes: 8
            0-3 DDR Memory (Non-hotpluggable)
            4-7 High Bandwidth Memory (Hotpluggable)

Kernel command-line parameters: kernelcore=16G movable_node

Before this patch,
----------------------------------
NUMA Node Zone    #Pages
----------------------------------
Node 0    DMA        3999
Node 0    DMA32    756023
Node 0    Normal  5505024
Node 1    Normal  6291456
Node 2    Normal  6291456
Node 3    Normal  6291456
Node 4    Movable 1048576
Node 5    Movable 1048576
Node 6    Movable 1048576
Node 7    Movable 1048576
----------------------------------
Total non-movable pages: 95.9 GB
Total movable pages    : 16.0 GB
----------------------------------

After this patch,
----------------------------------
NUMA Node Zone    #Pages
----------------------------------
Node 0    DMA        3999
Node 0    DMA32    756023
Node 0    Normal   288768
Node 0    Movable 5216256
Node 1    Normal  1048576
Node 1    Movable 5242880
Node 2    Normal  1048576
Node 2    Movable 5242880
Node 3    Normal  1048576
Node 3    Movable 5242880
Node 4    Movable 1048576
Node 5    Movable 1048576
Node 6    Movable 1048576
Node 7    Movable 1048576
----------------------------------
Total non-movable pages: 16.0 GB
Total movable pages    : 95.9 GB
----------------------------------

Signed-off-by: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 13 +++++++++++-
 mm/page_alloc.c                                 | 28 ++++++++++++++++++++++++-
 2 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 0549662..81957e8 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1807,6 +1807,11 @@
 			so you can NOT specify nn[KMGTPE] and "mirror" at the same
 			time.
 
+			When nn[KMGTPE] is specified along with movable_node
+			kernel parameter then only non-movable nodes are
+			considered for spreading the requested size while the
+			movable nodes have all movable memory.
+
 	kgdbdbgp=	[KGDB,HW] kgdb over EHCI usb debug port.
 			Format: <Controller#>[,poll interval]
 			The controller # is the number of the ehci usb debug
@@ -2324,7 +2329,13 @@
 			value but may be more. If movablecore on its own
 			is specified, the administrator must be careful
 			that the amount of memory usable for all allocations
-			is not too small.
+			is not too small. If movablecore is specified along
+			with movable_node then movablecore indicates the total
+			movable memory requested in the system that includes
+			movable memory in both movable and non-movable nodes.
+			When movable_node is specified, the minimum movable
+			memory allocated will be at least the total size of
+			movable nodes memory.
 
 	movable_node	[KNL] Boot-time switch to make hotplugable memory
 			NUMA nodes to be movable. This means that the memory
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..4a3579e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6338,20 +6338,28 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	unsigned long totalpages = early_calculate_totalpages();
 	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
 	struct memblock_region *r;
+	nodemask_t movable_nodes;
+	unsigned long movable_node_pages = 0;
 
 	/* Need to find movable_zone earlier when movable_node is specified. */
 	find_usable_zone_for_movable();
 
 	/*
 	 * If movable_node is specified, ignore kernelcore and movablecore
-	 * options.
+	 * options on hotpluggable nodes.
 	 */
+	nodes_clear(movable_nodes);
 	if (movable_node_is_enabled()) {
 		for_each_memblock(memory, r) {
 			if (!memblock_is_hotpluggable(r))
 				continue;
+			if (PFN_UP(r->base) >= PFN_DOWN(r->base + r->size))
+				continue;
 
 			nid = r->nid;
+			node_set(nid, movable_nodes);
+			movable_node_pages += PFN_DOWN(r->base + r->size) -
+						PFN_UP(r->base);
 
 			usable_startpfn = PFN_DOWN(r->base);
 			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
@@ -6359,6 +6367,14 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 				usable_startpfn;
 		}
 
+		if (required_kernelcore || required_movablecore) {
+			usable_nodes -= nodes_weight(movable_nodes);
+			if (usable_nodes > 0 &&
+			    totalpages > movable_node_pages) {
+				totalpages -= movable_node_pages;
+				goto core_options;
+			}
+		}
 		goto out2;
 	}
 
@@ -6392,6 +6408,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		goto out2;
 	}
 
+core_options:
 	/*
 	 * If movablecore=nn[KMG] was specified, calculate what size of
 	 * kernelcore that corresponds so that memory usable for
@@ -6403,6 +6420,12 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	if (required_movablecore) {
 		unsigned long corepages;
 
+		if (movable_node_is_enabled()) {
+			if (required_movablecore > movable_node_pages)
+				required_movablecore -= movable_node_pages;
+			else
+				goto out2;
+		}
 		/*
 		 * Round-up so that ZONE_MOVABLE is at least as large as what
 		 * was requested by the user
@@ -6431,6 +6454,9 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	for_each_node_state(nid, N_MEMORY) {
 		unsigned long start_pfn, end_pfn;
 
+		/* Skip movable nodes if any */
+		if (node_isset(nid, movable_nodes))
+			continue;
 		/*
 		 * Recalculate kernelcore_node if the division per node
 		 * now exceeds what is necessary to satisfy the requested
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
