Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2B676B6E63
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 06:15:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w15so8058962edl.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 03:15:51 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id u23-v6si4716884ejt.9.2018.12.04.03.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 03:15:50 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [PATCH] mm, page_alloc: Drop uneeded __meminit and __meminitdata
Date: Tue,  4 Dec 2018 12:15:07 +0100
Message-Id: <20181204111507.4808-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, pavel.tatashin@microsoft.com, vbabka@suse.cz, alexander.h.duyck@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

Since commit 03e85f9d5f1 ("mm/page_alloc: Introduce free_area_init_core_hotplug"),
some functions changed to only be called during system initialization.
In concret, free_area_init_node and and the functions that hang from it.

Also, some variables are no longer used after the system has gone
through initialization.
So this could be considered as a late clean-up for that patch.

This patch changes the functions from __meminit to __init, and
the variables from __meminitdata to __initdata.

In return, we get some KBs back:

Before:
Freeing unused kernel image memory: 2472K

After:
Freeing unused kernel image memory: 2480K

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fee5e9bad0dd..94e16eba162c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -266,18 +266,18 @@ int watermark_boost_factor __read_mostly = 15000;
 int watermark_scale_factor = 10;
 int fragment_stall_order __read_mostly = (PAGE_ALLOC_COSTLY_ORDER + 1);
 
-static unsigned long nr_kernel_pages __meminitdata;
-static unsigned long nr_all_pages __meminitdata;
-static unsigned long dma_reserve __meminitdata;
+static unsigned long nr_kernel_pages __initdata;
+static unsigned long nr_all_pages __initdata;
+static unsigned long dma_reserve __initdata;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-static unsigned long arch_zone_lowest_possible_pfn[MAX_NR_ZONES] __meminitdata;
-static unsigned long arch_zone_highest_possible_pfn[MAX_NR_ZONES] __meminitdata;
+static unsigned long arch_zone_lowest_possible_pfn[MAX_NR_ZONES] __initdata;
+static unsigned long arch_zone_highest_possible_pfn[MAX_NR_ZONES] __initdata;
 static unsigned long required_kernelcore __initdata;
 static unsigned long required_kernelcore_percent __initdata;
 static unsigned long required_movablecore __initdata;
 static unsigned long required_movablecore_percent __initdata;
-static unsigned long zone_movable_pfn[MAX_NUMNODES] __meminitdata;
+static unsigned long zone_movable_pfn[MAX_NUMNODES] __initdata;
 static bool mirrored_kernelcore __meminitdata;
 
 /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
@@ -6211,7 +6211,7 @@ void __init sparse_memory_present_with_active_regions(int nid)
  * with no available memory, a warning is printed and the start and end
  * PFNs will be 0.
  */
-void __meminit get_pfn_range_for_nid(unsigned int nid,
+void __init get_pfn_range_for_nid(unsigned int nid,
 			unsigned long *start_pfn, unsigned long *end_pfn)
 {
 	unsigned long this_start_pfn, this_end_pfn;
@@ -6260,7 +6260,7 @@ static void __init find_usable_zone_for_movable(void)
  * highest usable zone for ZONE_MOVABLE. This preserves the assumption that
  * zones within a node are in order of monotonic increases memory addresses
  */
-static void __meminit adjust_zone_range_for_zone_movable(int nid,
+static void __init adjust_zone_range_for_zone_movable(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
 					unsigned long node_end_pfn,
@@ -6291,7 +6291,7 @@ static void __meminit adjust_zone_range_for_zone_movable(int nid,
  * Return the number of pages a zone spans in a node, including holes
  * present_pages = zone_spanned_pages_in_node() - zone_absent_pages_in_node()
  */
-static unsigned long __meminit zone_spanned_pages_in_node(int nid,
+static unsigned long __init zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
 					unsigned long node_end_pfn,
@@ -6326,7 +6326,7 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
  * Return the number of holes in a range on a node. If nid is MAX_NUMNODES,
  * then all holes in the requested range will be accounted for.
  */
-unsigned long __meminit __absent_pages_in_range(int nid,
+unsigned long __init __absent_pages_in_range(int nid,
 				unsigned long range_start_pfn,
 				unsigned long range_end_pfn)
 {
@@ -6356,7 +6356,7 @@ unsigned long __init absent_pages_in_range(unsigned long start_pfn,
 }
 
 /* Return the number of page frames in holes in a zone on a node */
-static unsigned long __meminit zone_absent_pages_in_node(int nid,
+static unsigned long __init zone_absent_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
 					unsigned long node_end_pfn,
@@ -6408,7 +6408,7 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 }
 
 #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
-static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
+static inline unsigned long __init zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
 					unsigned long node_end_pfn,
@@ -6427,7 +6427,7 @@ static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
 	return zones_size[zone_type];
 }
 
-static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
+static inline unsigned long __init zone_absent_pages_in_node(int nid,
 						unsigned long zone_type,
 						unsigned long node_start_pfn,
 						unsigned long node_end_pfn,
@@ -6441,7 +6441,7 @@ static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
-static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
+static void __init calculate_node_totalpages(struct pglist_data *pgdat,
 						unsigned long node_start_pfn,
 						unsigned long node_end_pfn,
 						unsigned long *zones_size,
-- 
2.13.7
