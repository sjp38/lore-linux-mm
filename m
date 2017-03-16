Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 73DD36B0392
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:12:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e129so70024717pfh.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 23:12:53 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 21si3026728pfs.216.2017.03.15.23.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 23:12:52 -0700 (PDT)
Subject: [PATCH v4 10/13] mm: prepare for hot-{add,
 remove} of sub-section ranges
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 15 Mar 2017 23:07:41 -0700
Message-ID: <148964446151.19438.9450441862708278040.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

Prepare the memory hot-{add,remove} paths for handling sub-section
ranges by plumbing the starting page frame and number of pages being
handled through arch_{add,remove}_memory() to
sparse_{add,remove}_one_section().

This is simply plumbing, small cleanups, and some identifier renames. No
intended functional changes.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init_64.c          |   11 +++++
 include/linux/memory_hotplug.h |    6 ++-
 mm/memory_hotplug.c            |   85 ++++++++++++++++++++++------------------
 mm/sparse.c                    |    6 ++-
 4 files changed, 65 insertions(+), 43 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 0dbae2469a40..ed860558735f 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -650,6 +650,17 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
+	/*
+	 * Only allow partial section hotplug for ZONE_DEVICE ranges,
+	 * since register_new_memory() requires section alignment, and
+	 * CONFIG_SPARSEMEM_VMEMMAP=n requires sections to be fully
+	 * populated.
+	 */
+	if ((!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP) || !for_device)
+			&& ((start & ~PA_SECTION_MASK)
+				|| (size & ~PA_SECTION_MASK)))
+		return -EINVAL;
+
 	init_memory_mapping(start, start + size);
 
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 134a2f69c21a..2f2c0d1290a1 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -280,8 +280,10 @@ extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
-extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+extern int sparse_add_section(struct zone *zone, unsigned long pfn,
+		unsigned long nr_pages);
+extern void sparse_remove_section(struct zone *zone, struct mem_section *ms,
+		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index dc6f815c2d37..50fd94871c65 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -474,10 +474,10 @@ static void __meminit grow_pgdat_span(struct pglist_data *pgdat, unsigned long s
 					pgdat->node_start_pfn;
 }
 
-static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
+static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn,
+		unsigned long nr_pages)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
-	int nr_pages = PAGES_PER_SECTION;
 	int nid = pgdat->node_id;
 	int zone_type;
 	unsigned long flags, pfn;
@@ -507,24 +507,21 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 }
 
 static int __meminit __add_section(int nid, struct zone *zone,
-					unsigned long phys_start_pfn)
+		unsigned long pfn, unsigned long nr_pages)
 {
 	int ret;
 
-	if (pfn_valid(phys_start_pfn))
-		return -EEXIST;
-
-	ret = sparse_add_one_section(zone, phys_start_pfn);
+	ret = sparse_add_section(zone, pfn, nr_pages);
 
 	if (ret < 0)
 		return ret;
 
-	ret = __add_zone(zone, phys_start_pfn);
+	ret = __add_zone(zone, pfn, nr_pages);
 
 	if (ret < 0)
 		return ret;
 
-	return register_new_memory(zone, nid, __pfn_to_section(phys_start_pfn));
+	return register_new_memory(zone, nid, __pfn_to_section(pfn));
 }
 
 /*
@@ -533,7 +530,7 @@ static int __meminit __add_section(int nid, struct zone *zone,
  * call this function after deciding the zone to which to
  * add the new pages.
  */
-int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
+int __ref __add_pages(int nid, struct zone *zone, unsigned long pfn,
 			unsigned long nr_pages)
 {
 	int err = 0, i, start_sec, end_sec;
@@ -541,16 +538,12 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 
 	clear_zone_contiguous(zone);
 
-	/* during initialize mem_map, align hot-added range to section */
-	start_sec = pfn_to_section_nr(phys_start_pfn);
-	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
-
-	altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
+	altmap = to_vmem_altmap((unsigned long) pfn_to_page(pfn));
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
 		 */
-		if (altmap->base_pfn != phys_start_pfn
+		if (altmap->base_pfn != pfn
 				|| vmem_altmap_offset(altmap) > nr_pages) {
 			pr_warn_once("memory add fail, invalid altmap\n");
 			err = -EINVAL;
@@ -559,8 +552,16 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 		altmap->alloc = 0;
 	}
 
+	start_sec = pfn_to_section_nr(pfn);
+	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, zone, section_nr_to_pfn(i));
+		unsigned long pfns;
+
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
+		err = __add_section(nid, zone, pfn, pfns);
+		pfn += pfns;
+		nr_pages -= pfns;
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -766,10 +767,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	pgdat->node_spanned_pages = 0;
 }
 
-static void __remove_zone(struct zone *zone, unsigned long start_pfn)
+static void __remove_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
-	int nr_pages = PAGES_PER_SECTION;
 	int zone_type;
 	unsigned long flags;
 
@@ -781,11 +782,10 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 }
 
-static int __remove_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset)
+static int __remove_section(struct zone *zone, unsigned long pfn,
+		unsigned long nr_pages, unsigned long map_offset)
 {
-	unsigned long start_pfn;
-	int scn_nr;
+	struct mem_section *ms = __nr_to_section(pfn_to_section_nr(pfn));
 	int ret = -EINVAL;
 
 	if (!valid_section(ms))
@@ -795,11 +795,9 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 	if (ret)
 		return ret;
 
-	scn_nr = __section_nr(ms);
-	start_pfn = section_nr_to_pfn(scn_nr);
-	__remove_zone(zone, start_pfn);
+	__remove_zone(zone, pfn, nr_pages);
 
-	sparse_remove_one_section(zone, ms, map_offset);
+	sparse_remove_section(zone, ms, pfn, nr_pages, map_offset);
 	return 0;
 }
 
@@ -814,16 +812,15 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
+int __remove_pages(struct zone *zone, unsigned long pfn,
 		 unsigned long nr_pages)
 {
-	unsigned long i;
 	unsigned long map_offset = 0;
-	int sections_to_remove, ret = 0;
+	int i, start_sec, end_sec, ret = 0;
 
 	/* In the ZONE_DEVICE case device driver owns the memory region */
 	if (is_dev_zone(zone)) {
-		struct page *page = pfn_to_page(phys_start_pfn);
+		struct page *page = pfn_to_page(pfn);
 		struct vmem_altmap *altmap;
 
 		altmap = to_vmem_altmap((unsigned long) page);
@@ -832,7 +829,7 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	} else {
 		resource_size_t start, size;
 
-		start = phys_start_pfn << PAGE_SHIFT;
+		start = pfn << PAGE_SHIFT;
 		size = nr_pages * PAGE_SIZE;
 
 		ret = release_mem_region_adjustable(&iomem_resource, start,
@@ -848,16 +845,26 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	clear_zone_contiguous(zone);
 
 	/*
-	 * We can only remove entire sections
+	 * Only ZONE_DEVICE memory is enabled to remove
+	 * section-unaligned ranges. See register_new_memory() which
+	 * assumes section alignment and is skipped for ZONE_DEVICE
+	 * ranges.
 	 */
-	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
-	BUG_ON(nr_pages % PAGES_PER_SECTION);
+	if (!is_dev_zone(zone) && ((pfn | nr_pages) & ~PAGE_SECTION_MASK)) {
+		WARN(1, "section unaligned removal not supported\n");
+		return -EINVAL;
+	}
 
-	sections_to_remove = nr_pages / PAGES_PER_SECTION;
-	for (i = 0; i < sections_to_remove; i++) {
-		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
+	start_sec = pfn_to_section_nr(pfn);
+	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
+	for (i = start_sec; i <= end_sec; i++) {
+		unsigned long pfns;
 
-		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset);
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
+		ret = __remove_section(zone, pfn, pfns, map_offset);
+		pfn += pfns;
+		nr_pages -= pfns;
 		map_offset = 0;
 		if (ret)
 			break;
diff --git a/mm/sparse.c b/mm/sparse.c
index 1a51f97ae99e..edb1d2a21a2e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -753,7 +753,8 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
+int __meminit sparse_add_section(struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct pglist_data *pgdat = zone->zone_pgdat;
@@ -855,7 +856,8 @@ static void free_section_usage(struct page *memmap,
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+void sparse_remove_section(struct zone *zone, struct mem_section *ms,
+		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset)
 {
 	unsigned long flags;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
