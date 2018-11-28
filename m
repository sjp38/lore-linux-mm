Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC8C26B4D59
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:15:07 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c18so12205230edt.23
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 06:15:07 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e10-v6si2015911eji.18.2018.11.28.06.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 06:15:06 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Nov 2018 15:15:04 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v2 3/5] mm, memory_hotplug: Move zone/pages handling to
 offline stage
In-Reply-To: <20181127162005.15833-4-osalvador@suse.de>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-4-osalvador@suse.de>
Message-ID: <31fede3e3aa0c866b8d52d016a14689d@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>

On 2018-11-27 17:20, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.com>
> 
> The current implementation accesses pages during hot-remove
> stage in order to get the zone linked to this memory-range.
> We use that zone for a) check if the zone is ZONE_DEVICE and
> b) to shrink the zone's spanned pages.
> 
> Accessing pages during this stage is problematic, as we might be
> accessing pages that were not initialized if we did not get to
> online the memory before removing it.
> 
> The only reason to check for ZONE_DEVICE in __remove_pages
> is to bypass the call to release_mem_region_adjustable(),
> since these regions are removed with devm_release_mem_region.
> 
> With patch#2, this is no longer a problem so we can safely
> call release_mem_region_adjustable().
> release_mem_region_adjustable() will spot that the region
> we are trying to remove was acquired by means of
> devm_request_mem_region, and will back off safely.
> 
> This allows us to remove all zone-related operations from
> hot-remove stage.
> 
> Because of this, zone's spanned pages are shrinked during
> the offlining stage in shrink_zone_pgdat().
> It would have been great to decrease also the spanned page
> for the node there, but we need them in try_offline_node().
> So we still decrease spanned pages for the node in the hot-remove
> stage.
> 
> The only particularity is that now
> find_smallest_section_pfn/find_biggest_section_pfn, when called from
> shrink_zone_span, will now check for online sections and not
> valid sections instead.
> To make this work with devm/HMM code, we need to call 
> offline_mem_sections
> and online_mem_sections in that code path when we are adding memory.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

I did not really like the idea of having to online/offline sections from 
DEVM code, so I think
this should be better:

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 66cbf334203b..dfdb11f58cd1 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -105,7 +105,6 @@ static void devm_memremap_pages_release(void *data)

  	pfn = align_start >> PAGE_SHIFT;
  	nr_pages = align_size >> PAGE_SHIFT;
-	offline_mem_sections(pfn, pfn + nr_pages);
  	shrink_zone(page_zone(pfn_to_page(pfn)), pfn, pfn + nr_pages, 
nr_pages);

  	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
@@ -229,10 +228,7 @@ void *devm_memremap_pages(struct device *dev, 
struct dev_pagemap *pgmap)

  	if (!error) {
  		struct zone *zone;
-		unsigned long pfn = align_start >> PAGE_SHIFT;
-		unsigned long nr_pages = align_size >> PAGE_SHIFT;

-		online_mem_sections(pfn, pfn + nr_pages);
  		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
  		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
  				align_size >> PAGE_SHIFT, altmap);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4fe42ccb0be4..653d2bc9affe 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -314,13 +314,17 @@ int __ref __add_pages(int nid, unsigned long 
phys_start_pfn,
  }

  #ifdef CONFIG_MEMORY_HOTREMOVE
-static bool is_section_ok(struct mem_section *ms, bool zone)
+static bool is_section_ok(struct mem_section *ms, struct zone *z)
  {
  	/*
-	 * We cannot shrink pgdat's spanned because we use them
-	 * in try_offline_node to check if all sections were removed.
+	 * In case we are shrinking pgdat's pages or the zone is
+	 * ZONE_DEVICE, we check for valid sections instead.
+	 * We cannot shrink pgdat's spanned pages until hot-remove
+	 * operation because we use them in try_offline_node to check
+	 * if all sections were removed.
+	 * ZONE_DEVICE's sections do not get onlined either.
  	 */
-	if (zone)
+	if (z && !is_dev_zone(z))
  		return online_section(ms);
  	else
  		return valid_section(ms);
@@ -335,7 +339,7 @@ static unsigned long find_smallest_section_pfn(int 
nid, struct zone *zone,
  	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
  		ms = __pfn_to_section(start_pfn);

-		if (!is_section_ok(ms, !!zone))
+		if (!is_section_ok(ms, zone))
  			continue;

  		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -425,7 +429,7 @@ static void shrink_zone_span(struct zone *zone, 
unsigned long start_pfn,
  	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
  		ms = __pfn_to_section(pfn);

-		if (unlikely(!online_section(ms)))
+		if (unlikely(!is_section_ok(ms, zone)))
  			continue;

  		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -517,11 +521,24 @@ void shrink_zone(struct zone *zone, unsigned long 
start_pfn,
  {
  	int nr_pages = PAGES_PER_SECTION;
  	unsigned long pfn;
+	unsigned long flags;
+	struct pglist_data *pgdat = zone->zone_pgdat;
+
+	pgdat_resize_lock(pgdat, &flags);
+	/*
+	 * Handling for ZONE_DEVICE does not account
+	 * present pages.
+	 */
+	if (!is_dev_zone(zone))
+		pgdat->node_present_pages -= offlined_pages;
+

  	clear_zone_contiguous(zone);
  	for (pfn = start_pfn; pfn < end_pfn; pfn += nr_pages)
  		shrink_zone_span(zone, pfn, pfn + nr_pages);
  	set_zone_contiguous(zone);
+
+	pgdat_resize_unlock(pgdat, &flags);
  }

  static void shrink_pgdat(int nid, unsigned long sect_nr)
@@ -555,8 +572,8 @@ static int __remove_section(int nid, struct 
mem_section *ms,
  }

  /**
- * __remove_pages() - remove sections of pages from a nid
- * @nid: nid from which pages belong to
+ * remove_sections() - remove sections of pages from a nid
+ * @nid: node from which pages need to be removed to
   * @phys_start_pfn: starting pageframe (must be aligned to start of a 
section)
   * @nr_pages: number of pages to remove (must be multiple of section 
size)
   * @altmap: alternative device page map or %NULL if default memmap is 
used
@@ -1581,7 +1598,6 @@ static int __ref __offline_pages(unsigned long 
start_pfn,
  	unsigned long pfn, nr_pages;
  	long offlined_pages;
  	int ret, node;
-	unsigned long flags;
  	unsigned long valid_start, valid_end;
  	struct zone *zone;
  	struct memory_notify arg;
@@ -1663,14 +1679,12 @@ static int __ref __offline_pages(unsigned long 
start_pfn,
  	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
  	/* removal success */

-	/* Shrink zone's managed,spanned and zone/pgdat's present pages */
+	/* Shrink zone's managed and present pages */
  	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
  	zone->present_pages -= offlined_pages;

-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	zone->zone_pgdat->node_present_pages -= offlined_pages;
+	/* Shrink zone's spanned pages and node's present pages */
  	shrink_zone(zone, valid_start, valid_end, offlined_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);

  	init_per_zone_wmark_min();

Although there is an ongoing discussion for getting rid of the shrink 
code.
If that is the case, this will be a lot simpler.
