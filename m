Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7716B0081
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 11:45:51 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id w61so2440247wes.28
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:45:50 -0700 (PDT)
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
        by mx.google.com with ESMTPS id ep1si17616766wjd.166.2014.09.09.08.45.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 08:45:49 -0700 (PDT)
Received: by mail-we0-f180.google.com with SMTP id t60so2863484wes.25
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:45:49 -0700 (PDT)
Message-ID: <540F20AB.4000404@plexistor.com>
Date: Tue, 09 Sep 2014 18:45:47 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 5/9] mm: Let sparse_{add,remove}_one_section receive a node_id
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com>
In-Reply-To: <540F1EC6.4000504@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

From: Yigal Korman <yigal@plexistor.com>

Refactored the arguments of sparse_add_one_section / sparse_remove_one_section
to use node id instead of struct zone * - A memory section has no direct
connection to zones, all that was needed from zone was the node id.

This is for add_persistent_memory that will want a section of pages
allocated but without any zone associated. This is because belonging
to a zone will give the memory to the page allocators, but
persistent_memory belongs to a block device, and is not available for
regular volatile usage.

Signed-off-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 include/linux/memory_hotplug.h | 4 ++--
 mm/memory_hotplug.c            | 4 ++--
 mm/sparse.c                    | 9 +++++----
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index d9524c4..35ca1bb 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -264,8 +264,8 @@ extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
-extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
+extern int sparse_add_one_section(int nid, unsigned long start_pfn);
+extern void sparse_remove_one_section(int nid, struct mem_section *ms);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2ff8c23..e556a90 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -471,7 +471,7 @@ static int __meminit __add_section(int nid, struct zone *zone,
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(zone, phys_start_pfn);
+	ret = sparse_add_one_section(zone->zone_pgdat->node_id, phys_start_pfn);
 
 	if (ret < 0)
 		return ret;
@@ -737,7 +737,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	start_pfn = section_nr_to_pfn(scn_nr);
 	__remove_zone(zone, start_pfn);
 
-	sparse_remove_one_section(zone, ms);
+	sparse_remove_one_section(zone->zone_pgdat->node_id, ms);
 	return 0;
 }
 
diff --git a/mm/sparse.c b/mm/sparse.c
index d1b48b6..12a10ab 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -690,10 +690,10 @@ static void free_map_bootmem(struct page *memmap)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
+int __meminit sparse_add_one_section(int nid, unsigned long start_pfn)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
-	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct mem_section *ms;
 	struct page *memmap;
 	unsigned long *usemap;
@@ -788,11 +788,11 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
+void sparse_remove_one_section(int nid, struct mem_section *ms)
 {
 	struct page *memmap = NULL;
 	unsigned long *usemap = NULL, flags;
-	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct pglist_data *pgdat = NODE_DATA(nid);
 
 	pgdat_resize_lock(pgdat, &flags);
 	if (ms->section_mem_map) {
@@ -807,5 +807,6 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
 	free_section_usemap(memmap, usemap);
 }
+
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
