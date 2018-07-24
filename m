Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75E7F6B0007
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 19:55:45 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id m10-v6so1840020uao.9
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:55:45 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 11-v6si6259254uaf.51.2018.07.24.16.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 16:55:44 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH 3/3] mm: move mirrored memory specific code outside of memmap_init_zone
Date: Tue, 24 Jul 2018 19:55:20 -0400
Message-Id: <20180724235520.10200-4-pasha.tatashin@oracle.com>
In-Reply-To: <20180724235520.10200-1-pasha.tatashin@oracle.com>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

memmap_init_zone, is getting complex, because it is called from different
contexts: hotplug, and during boot, and also because it must handle some
architecture quirks. One of them is mirroed memory.

Move the code that decides whether to skip mirrored memory outside of
memmap_init_zone, into a separate function.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 70 ++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 38 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 86c678cec6bd..d7dce4ccefd5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5454,6 +5454,29 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
 #endif
 }
 
+/* If zone is ZONE_MOVABLE but memory is mirrored, it is an overlapped init */
+static inline bool overlap_memmap_init(unsigned long zone, unsigned long *pfn)
+{
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+	static struct memblock_region *r;
+
+	if (mirrored_kernelcore && zone == ZONE_MOVABLE) {
+		if (!r || *pfn >= memblock_region_memory_end_pfn(r)) {
+			for_each_memblock(memory, r) {
+				if (*pfn < memblock_region_memory_end_pfn(r))
+					break;
+			}
+		}
+		if (*pfn >= memblock_region_memory_base_pfn(r) &&
+		    memblock_is_mirror(r)) {
+			*pfn = memblock_region_memory_end_pfn(r);
+			return true;
+		}
+	}
+#endif
+	return false;
+}
+
 /*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is
@@ -5463,12 +5486,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		unsigned long start_pfn, enum memmap_context context,
 		struct vmem_altmap *altmap)
 {
-	unsigned long end_pfn = start_pfn + size;
-	unsigned long pfn;
+	unsigned long pfn, end_pfn = start_pfn + size;
 	struct page *page;
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-	struct memblock_region *r = NULL, *tmp;
-#endif
 
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
@@ -5485,39 +5504,17 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * There can be holes in boot-time mem_map[]s handed to this
 		 * function.  They do not exist on hotplugged memory.
 		 */
-		if (context != MEMMAP_EARLY)
-			goto not_early;
-
-		if (!early_pfn_valid(pfn))
-			continue;
-		if (!early_pfn_in_nid(pfn, nid))
-			continue;
-
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-		/*
-		 * Check given memblock attribute by firmware which can affect
-		 * kernel memory layout.  If zone==ZONE_MOVABLE but memory is
-		 * mirrored, it's an overlapped memmap init. skip it.
-		 */
-		if (mirrored_kernelcore && zone == ZONE_MOVABLE) {
-			if (!r || pfn >= memblock_region_memory_end_pfn(r)) {
-				for_each_memblock(memory, tmp)
-					if (pfn < memblock_region_memory_end_pfn(tmp))
-						break;
-				r = tmp;
-			}
-			if (pfn >= memblock_region_memory_base_pfn(r) &&
-			    memblock_is_mirror(r)) {
-				/* already initialized as NORMAL */
-				pfn = memblock_region_memory_end_pfn(r);
+		if (context == MEMMAP_EARLY) {
+			if (!early_pfn_valid(pfn))
 				continue;
-			}
+			if (!early_pfn_in_nid(pfn, nid))
+				continue;
+			if (overlap_memmap_init(zone, &pfn))
+				continue;
+			if (defer_init(nid, pfn, end_pfn))
+				break;
 		}
-#endif
-		if (defer_init(nid, pfn, end_pfn))
-			break;
 
-not_early:
 		page = pfn_to_page(pfn);
 		__init_single_page(page, pfn, zone, nid);
 		if (context == MEMMAP_HOTPLUG)
@@ -5534,9 +5531,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * can be created for invalid pages (for alignment)
 		 * check here not to call set_pageblock_migratetype() against
 		 * pfn out of zone.
-		 *
-		 * Please note that MEMMAP_HOTPLUG path doesn't clear memmap
-		 * because this is done early in sparse_add_one_section
 		 */
 		if (!(pfn & (pageblock_nr_pages - 1))) {
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-- 
2.18.0
