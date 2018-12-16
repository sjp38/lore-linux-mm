Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F04868E0001
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 07:56:37 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l22so8881441pfb.2
        for <linux-mm@kvack.org>; Sun, 16 Dec 2018 04:56:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l185sor16632667pge.32.2018.12.16.04.56.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Dec 2018 04:56:36 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, page_alloc: clear zone_movable_pfn if the node doesn't have ZONE_MOVABLE
Date: Sun, 16 Dec 2018 20:56:24 +0800
Message-Id: <20181216125624.3416-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, osalvador@suse.de, Wei Yang <richard.weiyang@gmail.com>

A non-zero zone_movable_pfn indicates this node has ZONE_MOVABLE, while
current implementation doesn't comply with this rule when kernel
parameter "kernelcore=" is used.

Current implementation doesn't harm the system, since the value in
zone_movable_pfn is out of the range of current zone. While user would
see this message during bootup, even that node doesn't has ZONE_MOVABLE.

    Movable zone start for each node
      Node 0: 0x0000000080000000

This fix takes advantage of the highest bit of a pfn to indicate it is
used for the calculation instead of the final result. And clear those
pfn whose highest bit is set after entire calculation.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/mm.h |  1 +
 mm/page_alloc.c    | 15 +++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..c3d8a3346dd1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2141,6 +2141,7 @@ static inline unsigned long get_num_physpages(void)
  * See mm/page_alloc.c for more information on each function exposed by
  * CONFIG_HAVE_MEMBLOCK_NODE_MAP.
  */
+#define zone_movable_pfn_highestbit (1UL << (BITS_PER_LONG - 1))
 extern void free_area_init_nodes(unsigned long *max_zone_pfn);
 unsigned long node_map_pfn_alignment(void);
 unsigned long __absent_pages_in_range(int nid, unsigned long start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eb4df3f63f5e..cd3a77b9cb95 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6841,6 +6841,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, NULL) {
 			unsigned long size_pages;
 
+			zone_movable_pfn[nid] &= ~zone_movable_pfn_highestbit;
 			start_pfn = max(start_pfn, zone_movable_pfn[nid]);
 			if (start_pfn >= end_pfn)
 				continue;
@@ -6866,6 +6867,13 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 					 * not double account here
 					 */
 					zone_movable_pfn[nid] = end_pfn;
+
+					/*
+					 * Set highest bit to indicate it is
+					 * used for calculation.
+					 */
+					zone_movable_pfn[nid] |=
+						zone_movable_pfn_highestbit;
 					continue;
 				}
 				start_pfn = usable_startpfn;
@@ -6904,6 +6912,13 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	if (usable_nodes && required_kernelcore > usable_nodes)
 		goto restart;
 
+	/*
+	 * clear zone_movable_pfn if its highest bit is set
+	 */
+	for_each_node_state(nid, N_MEMORY)
+		if (zone_movable_pfn[nid] & zone_movable_pfn_highestbit)
+			zone_movable_pfn[nid] = 0;
+
 out2:
 	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
 	for (nid = 0; nid < MAX_NUMNODES; nid++)
-- 
2.15.1
