Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 503436B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:21:55 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id n12so10942863wgh.21
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:21:54 -0700 (PDT)
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
        by mx.google.com with ESMTPS id m9si2335905wib.84.2014.08.13.05.21.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:21:54 -0700 (PDT)
Received: by mail-we0-f178.google.com with SMTP id w61so11125634wes.23
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:21:53 -0700 (PDT)
Message-ID: <53EB585F.3000005@plexistor.com>
Date: Wed, 13 Aug 2014 15:21:51 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 8/9] mm: export sparse_add/remove_one_section
References: <53EB5536.8020702@gmail.com>
In-Reply-To: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Yigal Korman <yigal@plexistor.com>

Export sparse_add_one_section & sparse_remove_one_section for use
in modules that want private memory mappings (prd for example).

Also refactored the arguments to use node id instead of
struct zone * - sparse memory has no direct connection to zones,
all that was needed from zone was the node id.

Signed-off-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 include/linux/memory_hotplug.h |  4 ++--
 mm/memory_hotplug.c            |  4 ++--
 mm/sparse.c                    | 11 +++++++----
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 010d125..91e0474 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -262,8 +262,8 @@ extern int arch_add_memory(int nid, u64 start, u64 size);
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
index 469bbf5..0c87570 100644
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
index d1b48b6..d97facd3 100644
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
@@ -738,6 +738,7 @@ out:
 	}
 	return ret;
 }
+EXPORT_SYMBOL_GPL(sparse_add_one_section);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 #ifdef CONFIG_MEMORY_FAILURE
@@ -788,11 +789,11 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
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
@@ -807,5 +808,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
 	free_section_usemap(memmap, usemap);
 }
+EXPORT_SYMBOL_GPL(sparse_remove_one_section);
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
