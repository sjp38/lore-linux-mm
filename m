Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95F586B0269
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:27:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id ce7-v6so16486245plb.22
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:27:20 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 129-v6si11995227pfd.201.2018.10.15.13.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 13:27:19 -0700 (PDT)
Subject: [mm PATCH v3 4/6] mm: Move hot-plug specific memory init into
 separate functions and optimize
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 15 Oct 2018 13:27:16 -0700
Message-ID: <20181015202716.2171.7284.stgit@localhost.localdomain>
In-Reply-To: <20181015202456.2171.88406.stgit@localhost.localdomain>
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

This patch is going through and combining the bits in memmap_init_zone and
memmap_init_zone_device that are related to hotplug into a single function
called __memmap_init_hotplug.

I also took the opportunity to integrate __init_single_page's functionality
into this function. In doing so I can get rid of some of the redundancy
such as the LRU pointers versus the pgmap.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/page_alloc.c |  232 ++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 159 insertions(+), 73 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 20e9eb35d75d..92375e7867ba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1192,6 +1192,94 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 #endif
 }
 
+static void __meminit __init_pageblock(unsigned long start_pfn,
+				       unsigned long nr_pages,
+				       unsigned long zone, int nid,
+				       struct dev_pagemap *pgmap,
+				       bool is_reserved)
+{
+	unsigned long nr_pgmask = pageblock_nr_pages - 1;
+	struct page *start_page = pfn_to_page(start_pfn);
+	unsigned long pfn = start_pfn + nr_pages - 1;
+#ifdef WANT_PAGE_VIRTUAL
+	bool is_highmem = is_highmem_idx(zone);
+#endif
+	struct page *page;
+
+	/*
+	 * Enforce the following requirements:
+	 * size > 0
+	 * size < pageblock_nr_pages
+	 * start_pfn -> pfn does not cross pageblock_nr_pages boundary
+	 */
+	VM_BUG_ON(((start_pfn ^ pfn) | (nr_pages - 1)) > nr_pgmask);
+
+	/*
+	 * Work from highest page to lowest, this way we will still be
+	 * warm in the cache when we call set_pageblock_migratetype
+	 * below.
+	 *
+	 * The loop is based around the page pointer as the main index
+	 * instead of the pfn because pfn is not used inside the loop if
+	 * the section number is not in page flags and WANT_PAGE_VIRTUAL
+	 * is not defined.
+	 */
+	for (page = start_page + nr_pages; page-- != start_page; pfn--) {
+		mm_zero_struct_page(page);
+
+		/*
+		 * We use the start_pfn instead of pfn in the set_page_links
+		 * call because of the fact that the pfn number is used to
+		 * get the section_nr and this function should not be
+		 * spanning more than a single section.
+		 */
+		set_page_links(page, zone, nid, start_pfn);
+		init_page_count(page);
+		page_mapcount_reset(page);
+		page_cpupid_reset_last(page);
+
+		/*
+		 * We can use the non-atomic __set_bit operation for setting
+		 * the flag as we are still initializing the pages.
+		 */
+		if (is_reserved)
+			__SetPageReserved(page);
+
+		/*
+		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
+		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
+		 * page is ever freed or placed on a driver-private list.
+		 */
+		page->pgmap = pgmap;
+		if (!pgmap)
+			INIT_LIST_HEAD(&page->lru);
+
+#ifdef WANT_PAGE_VIRTUAL
+		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
+		if (!is_highmem)
+			set_page_address(page, __va(pfn << PAGE_SHIFT));
+#endif
+	}
+
+	/*
+	 * Mark the block movable so that blocks are reserved for
+	 * movable at startup. This will force kernel allocations
+	 * to reserve their blocks rather than leaking throughout
+	 * the address space during boot when many long-lived
+	 * kernel allocations are made.
+	 *
+	 * bitmap is created for zone's valid pfn range. but memmap
+	 * can be created for invalid pages (for alignment)
+	 * check here not to call set_pageblock_migratetype() against
+	 * pfn out of zone.
+	 *
+	 * Please note that MEMMAP_HOTPLUG path doesn't clear memmap
+	 * because this is done early in sparse_add_one_section
+	 */
+	if (!(start_pfn & nr_pgmask))
+		set_pageblock_migratetype(start_page, MIGRATE_MOVABLE);
+}
+
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static void __meminit init_reserved_page(unsigned long pfn)
 {
@@ -5513,6 +5601,36 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
 	return false;
 }
 
+static void __meminit __memmap_init_hotplug(unsigned long size, int nid,
+					    unsigned long zone,
+					    unsigned long start_pfn,
+					    struct dev_pagemap *pgmap)
+{
+	unsigned long pfn = start_pfn + size;
+
+	while (pfn != start_pfn) {
+		unsigned long stride = pfn;
+
+		pfn = max(ALIGN_DOWN(pfn - 1, pageblock_nr_pages), start_pfn);
+		stride -= pfn;
+
+		/*
+		 * The last argument of __init_pageblock is a boolean
+		 * value indicating if the page will be marked as reserved.
+		 *
+		 * Mark page reserved as it will need to wait for onlining
+		 * phase for it to be fully associated with a zone.
+		 *
+		 * Under certain circumstances ZONE_DEVICE pages may not
+		 * need to be marked as reserved, however there is still
+		 * code that is depending on this being set for now.
+		 */
+		__init_pageblock(pfn, stride, zone, nid, pgmap, true);
+
+		cond_resched();
+	}
+}
+
 /*
  * Initially all pages are reserved - free ones are freed
  * up by memblock_free_all() once the early boot process is
@@ -5523,51 +5641,61 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		struct vmem_altmap *altmap)
 {
 	unsigned long pfn, end_pfn = start_pfn + size;
-	struct page *page;
 
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
 
+	if (context == MEMMAP_HOTPLUG) {
 #ifdef CONFIG_ZONE_DEVICE
-	/*
-	 * Honor reservation requested by the driver for this ZONE_DEVICE
-	 * memory. We limit the total number of pages to initialize to just
-	 * those that might contain the memory mapping. We will defer the
-	 * ZONE_DEVICE page initialization until after we have released
-	 * the hotplug lock.
-	 */
-	if (zone == ZONE_DEVICE) {
-		if (!altmap)
-			return;
+		/*
+		 * Honor reservation requested by the driver for this
+		 * ZONE_DEVICE memory. We limit the total number of pages to
+		 * initialize to just those that might contain the memory
+		 * mapping. We will defer the ZONE_DEVICE page initialization
+		 * until after we have released the hotplug lock.
+		 */
+		if (zone == ZONE_DEVICE) {
+			if (!altmap)
+				return;
+
+			if (start_pfn == altmap->base_pfn)
+				start_pfn += altmap->reserve;
+			end_pfn = altmap->base_pfn +
+				  vmem_altmap_offset(altmap);
+		}
+#endif
+		/*
+		 * For these ZONE_DEVICE pages we don't need to record the
+		 * pgmap as they should represent only those pages used to
+		 * store the memory map. The actual ZONE_DEVICE pages will
+		 * be initialized later.
+		 */
+		__memmap_init_hotplug(end_pfn - start_pfn, nid, zone,
+				      start_pfn, NULL);
 
-		if (start_pfn == altmap->base_pfn)
-			start_pfn += altmap->reserve;
-		end_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
+		return;
 	}
-#endif
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		struct page *page;
+
 		/*
 		 * There can be holes in boot-time mem_map[]s handed to this
 		 * function.  They do not exist on hotplugged memory.
 		 */
-		if (context == MEMMAP_EARLY) {
-			if (!early_pfn_valid(pfn)) {
-				pfn = next_valid_pfn(pfn) - 1;
-				continue;
-			}
-			if (!early_pfn_in_nid(pfn, nid))
-				continue;
-			if (overlap_memmap_init(zone, &pfn))
-				continue;
-			if (defer_init(nid, pfn, end_pfn))
-				break;
+		if (!early_pfn_valid(pfn)) {
+			pfn = next_valid_pfn(pfn) - 1;
+			continue;
 		}
+		if (!early_pfn_in_nid(pfn, nid))
+			continue;
+		if (overlap_memmap_init(zone, &pfn))
+			continue;
+		if (defer_init(nid, pfn, end_pfn))
+			break;
 
 		page = pfn_to_page(pfn);
 		__init_single_page(page, pfn, zone, nid);
-		if (context == MEMMAP_HOTPLUG)
-			__SetPageReserved(page);
 
 		/*
 		 * Mark the block movable so that blocks are reserved for
@@ -5594,14 +5722,12 @@ void __ref memmap_init_zone_device(struct zone *zone,
 				   unsigned long size,
 				   struct dev_pagemap *pgmap)
 {
-	unsigned long pfn, end_pfn = start_pfn + size;
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	unsigned long zone_idx = zone_idx(zone);
 	unsigned long start = jiffies;
 	int nid = pgdat->node_id;
 
-	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
-		return;
+	VM_BUG_ON(!is_dev_zone(zone));
 
 	/*
 	 * The call to memmap_init_zone should have already taken care
@@ -5610,53 +5736,13 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	 */
 	if (pgmap->altmap_valid) {
 		struct vmem_altmap *altmap = &pgmap->altmap;
+		unsigned long end_pfn = start_pfn + size;
 
 		start_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
 		size = end_pfn - start_pfn;
 	}
 
-	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-		struct page *page = pfn_to_page(pfn);
-
-		__init_single_page(page, pfn, zone_idx, nid);
-
-		/*
-		 * Mark page reserved as it will need to wait for onlining
-		 * phase for it to be fully associated with a zone.
-		 *
-		 * We can use the non-atomic __set_bit operation for setting
-		 * the flag as we are still initializing the pages.
-		 */
-		__SetPageReserved(page);
-
-		/*
-		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
-		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
-		 * page is ever freed or placed on a driver-private list.
-		 */
-		page->pgmap = pgmap;
-		page->hmm_data = 0;
-
-		/*
-		 * Mark the block movable so that blocks are reserved for
-		 * movable at startup. This will force kernel allocations
-		 * to reserve their blocks rather than leaking throughout
-		 * the address space during boot when many long-lived
-		 * kernel allocations are made.
-		 *
-		 * bitmap is created for zone's valid pfn range. but memmap
-		 * can be created for invalid pages (for alignment)
-		 * check here not to call set_pageblock_migratetype() against
-		 * pfn out of zone.
-		 *
-		 * Please note that MEMMAP_HOTPLUG path doesn't clear memmap
-		 * because this is done early in sparse_add_one_section
-		 */
-		if (!(pfn & (pageblock_nr_pages - 1))) {
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-			cond_resched();
-		}
-	}
+	__memmap_init_hotplug(size, nid, zone_idx, start_pfn, pgmap);
 
 	pr_info("%s initialised, %lu pages in %ums\n", dev_name(pgmap->dev),
 		size, jiffies_to_msecs(jiffies - start));
