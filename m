Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 74B9D4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 01:19:48 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so33783732pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:19:48 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id n79si14492183pfj.101.2016.02.03.22.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 22:19:47 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id w123so33905619pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:19:47 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page() when zone is contiguous
Date: Thu,  4 Feb 2016 15:19:35 +0900
Message-Id: <1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a performance drop report due to hugepage allocation and in there
half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
In that workload, compaction is triggered to make hugepage but most of
pageblocks are un-available for compaction due to pageblock type and
skip bit so compaction usually fails. Most costly operations in this case
is to find valid pageblock while scanning whole zone range. To check
if pageblock is valid to compact, valid pfn within pageblock is required
and we can obtain it by calling pageblock_pfn_to_page(). This function
checks whether pageblock is in a single zone and return valid pfn
if possible. Problem is that we need to check it every time before
scanning pageblock even if we re-visit it and this turns out to
be very expensive in this workload.

Although we have no way to skip this pageblock check in the system
where hole exists at arbitrary position, we can use cached value for
zone continuity and just do pfn_to_page() in the system where hole doesn't
exist. This optimization considerably speeds up in above workload.

Before vs After
Max: 1096 MB/s vs 1325 MB/s
Min: 635 MB/s 1015 MB/s
Avg: 899 MB/s 1194 MB/s

Avg is improved by roughly 30% [2].

[1]: http://www.spinics.net/lists/linux-mm/msg97378.html
[2]: https://lkml.org/lkml/2015/12/9/23

v3
o remove pfn_valid_within() check for all pages in the pageblock
because pageblock_pfn_to_page() is only called with pageblock aligned pfn.

v2
o checking zone continuity after initialization
o handle memory-hotplug case

Reported and Tested-by: Aaron Lu <aaron.lu@intel.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/gfp.h            |  6 ----
 include/linux/memory_hotplug.h |  3 ++
 include/linux/mmzone.h         |  2 ++
 mm/compaction.c                | 43 -----------------------
 mm/internal.h                  | 12 +++++++
 mm/memory_hotplug.c            |  9 +++++
 mm/page_alloc.c                | 79 +++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 104 insertions(+), 50 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 28ad5f6..bd7fccc 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -515,13 +515,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 void drain_all_pages(struct zone *zone);
 void drain_local_pages(struct zone *zone);
 
-#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 void page_alloc_init_late(void);
-#else
-static inline void page_alloc_init_late(void)
-{
-}
-#endif
 
 /*
  * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 4340599..e960b78 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -196,6 +196,9 @@ void put_online_mems(void);
 void mem_hotplug_begin(void);
 void mem_hotplug_done(void);
 
+extern void set_zone_contiguous(struct zone *zone);
+extern void clear_zone_contiguous(struct zone *zone);
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7b6c2cf..f12b950 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -520,6 +520,8 @@ struct zone {
 	bool			compact_blockskip_flush;
 #endif
 
+	bool			contiguous;
+
 	ZONE_PADDING(_pad3_)
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
diff --git a/mm/compaction.c b/mm/compaction.c
index 8ce36eb..93f71d9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -71,49 +71,6 @@ static inline bool migrate_async_suitable(int migratetype)
 	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
 }
 
-/*
- * Check that the whole (or subset of) a pageblock given by the interval of
- * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
- * with the migration of free compaction scanner. The scanners then need to
- * use only pfn_valid_within() check for arches that allow holes within
- * pageblocks.
- *
- * Return struct page pointer of start_pfn, or NULL if checks were not passed.
- *
- * It's possible on some configurations to have a setup like node0 node1 node0
- * i.e. it's possible that all pages within a zones range of pages do not
- * belong to a single zone. We assume that a border between node0 and node1
- * can occur within a single pageblock, but not a node0 node1 node0
- * interleaving within a single pageblock. It is therefore sufficient to check
- * the first and last page of a pageblock and avoid checking each individual
- * page in a pageblock.
- */
-static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
-				unsigned long end_pfn, struct zone *zone)
-{
-	struct page *start_page;
-	struct page *end_page;
-
-	/* end_pfn is one past the range we are checking */
-	end_pfn--;
-
-	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
-		return NULL;
-
-	start_page = pfn_to_page(start_pfn);
-
-	if (page_zone(start_page) != zone)
-		return NULL;
-
-	end_page = pfn_to_page(end_pfn);
-
-	/* This gives a shorter code than deriving page_zone(end_page) */
-	if (page_zone_id(start_page) != page_zone_id(end_page))
-		return NULL;
-
-	return start_page;
-}
-
 #ifdef CONFIG_COMPACTION
 
 /* Do not skip compaction more than 64 times */
diff --git a/mm/internal.h b/mm/internal.h
index 9006ce1..9609755 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -140,6 +140,18 @@ __find_buddy_index(unsigned long page_idx, unsigned int order)
 	return page_idx ^ (1 << order);
 }
 
+extern struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
+				unsigned long end_pfn, struct zone *zone);
+
+static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
+				unsigned long end_pfn, struct zone *zone)
+{
+	if (zone->contiguous)
+		return pfn_to_page(start_pfn);
+
+	return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
+}
+
 extern int __isolate_free_page(struct page *page, unsigned int order);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4af58a3..f06916c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -509,6 +509,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	int start_sec, end_sec;
 	struct vmem_altmap *altmap;
 
+	clear_zone_contiguous(zone);
+
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
@@ -540,6 +542,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	}
 	vmemmap_populate_print_last();
 
+	set_zone_contiguous(zone);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(__add_pages);
@@ -811,6 +815,8 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 		}
 	}
 
+	clear_zone_contiguous(zone);
+
 	/*
 	 * We can only remove entire sections
 	 */
@@ -826,6 +832,9 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 		if (ret)
 			break;
 	}
+
+	set_zone_contiguous(zone);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(__remove_pages);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d60c860..466f7ff 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1255,9 +1255,13 @@ free_range:
 	pgdat_init_report_one_done();
 	return 0;
 }
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 void __init page_alloc_init_late(void)
 {
+	struct zone *zone;
+
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 	int nid;
 
 	/* There will be num_node_state(N_MEMORY) threads */
@@ -1271,8 +1275,81 @@ void __init page_alloc_init_late(void)
 
 	/* Reinit limits that are based on free pages after the kernel is up */
 	files_maxfiles_init();
+#endif
+
+	for_each_populated_zone(zone)
+		set_zone_contiguous(zone);
+}
+
+/*
+ * Check that the whole (or subset of) a pageblock given by the interval of
+ * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
+ * with the migration of free compaction scanner. The scanners then need to
+ * use only pfn_valid_within() check for arches that allow holes within
+ * pageblocks.
+ *
+ * Return struct page pointer of start_pfn, or NULL if checks were not passed.
+ *
+ * It's possible on some configurations to have a setup like node0 node1 node0
+ * i.e. it's possible that all pages within a zones range of pages do not
+ * belong to a single zone. We assume that a border between node0 and node1
+ * can occur within a single pageblock, but not a node0 node1 node0
+ * interleaving within a single pageblock. It is therefore sufficient to check
+ * the first and last page of a pageblock and avoid checking each individual
+ * page in a pageblock.
+ */
+struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
+				unsigned long end_pfn, struct zone *zone)
+{
+	struct page *start_page;
+	struct page *end_page;
+
+	/* end_pfn is one past the range we are checking */
+	end_pfn--;
+
+	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
+		return NULL;
+
+	start_page = pfn_to_page(start_pfn);
+
+	if (page_zone(start_page) != zone)
+		return NULL;
+
+	end_page = pfn_to_page(end_pfn);
+
+	/* This gives a shorter code than deriving page_zone(end_page) */
+	if (page_zone_id(start_page) != page_zone_id(end_page))
+		return NULL;
+
+	return start_page;
+}
+
+void set_zone_contiguous(struct zone *zone)
+{
+	unsigned long block_start_pfn = zone->zone_start_pfn;
+	unsigned long block_end_pfn;
+	unsigned long pfn;
+
+	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
+	for (; block_start_pfn < zone_end_pfn(zone);
+		block_start_pfn = block_end_pfn,
+		block_end_pfn += pageblock_nr_pages) {
+
+		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
+
+		if (!__pageblock_pfn_to_page(block_start_pfn,
+					block_end_pfn, zone))
+			return;
+	}
+
+	/* We confirm that there is no hole */
+	zone->contiguous = true;
+}
+
+void clear_zone_contiguous(struct zone *zone)
+{
+	zone->contiguous = false;
 }
-#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 #ifdef CONFIG_CMA
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
