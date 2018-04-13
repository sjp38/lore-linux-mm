Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7A86B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:41:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m190so1300228pgm.4
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 01:41:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x16sor1640988pfe.2.2018.04.13.01.41.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 01:41:16 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/page_alloc: remove realsize in free_area_init_core()
Date: Fri, 13 Apr 2018 16:38:59 +0800
Message-Id: <20180413083859.65888-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Highmem's realsize always equals to freesize, so it is not necessary to
spare a variable to record this.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97fa99260822..c76eb609593f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6104,18 +6104,18 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
-		unsigned long size, realsize, freesize, memmap_pages;
+		unsigned long size, freesize, memmap_pages;
 		unsigned long zone_start_pfn = zone->zone_start_pfn;
 
 		size = zone->spanned_pages;
-		realsize = freesize = zone->present_pages;
+		freesize = zone->present_pages;
 
 		/*
 		 * Adjust freesize so that it accounts for how much memory
 		 * is used by this zone for memmap. This affects the watermark
 		 * and per-cpu initialisations
 		 */
-		memmap_pages = calc_memmap_size(size, realsize);
+		memmap_pages = calc_memmap_size(size, freesize);
 		if (!is_highmem_idx(j)) {
 			if (freesize >= memmap_pages) {
 				freesize -= memmap_pages;
@@ -6147,7 +6147,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		 * when the bootmem allocator frees pages into the buddy system.
 		 * And all highmem pages will be managed by the buddy system.
 		 */
-		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
+		zone->managed_pages = freesize;
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 #endif
-- 
2.15.1
