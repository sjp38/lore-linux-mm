Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6DEC6B0261
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:15:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b22so102949958pfd.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:17 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id x68si11811072pfa.269.2017.01.12.23.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 23:15:16 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id b22so7077772pfd.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:16 -0800 (PST)
From: js1304@gmail.com
Subject: [RFC PATCH 3/5] mm: introduce exponential moving average to unusable free index
Date: Fri, 13 Jan 2017 16:14:31 +0900
Message-Id: <1484291673-2239-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We have a statistic about memory fragmentation but it would be fluctuated
a lot within very short term so it's hard to accurately measure
system's fragmentation state while workload is actively running. Without
stable statistic, it's not possible to determine if the system is
fragmented or not.

Meanwhile, recently, there were a lot of reports about fragmentation
problem and we tried some changes. However, since there is no way
to measure fragmentation ratio stably, we cannot make sure how these
changes help the fragmentation.

There are some methods to measure fragmentation but I think that they
have some problems.

1. buddyinfo: it fluctuated a lot within very short term
2. tracepoint: it shows how steal happens between buddylists of different
migratetype. It means fragmentation indirectly but would not be accurate.
3. pageowner: it shows the number of mixed pageblocks but it is not
suitable for production system since it requires some additional memory.

Therefore, this patch try to calculate exponential moving average to
unusable free index. Since it is a moving average, it is quite stable
even if fragmentation state of memory fluctuate a lot.

I made this patch 3 month ago and implementation detail looks not
good to me now. Maybe, it's better to rule out update code in allocation
path and make it timer based. Anyway, this patch is just for RFC.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |  2 ++
 mm/internal.h          | 21 +++++++++++++++++++++
 mm/page_alloc.c        | 32 ++++++++++++++++++++++++++++++++
 mm/vmstat.c            | 16 ++++------------
 4 files changed, 59 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 36d9896..94bb4fd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -90,6 +90,7 @@ enum {
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
+	unsigned long		unusable_free_avg;
 };
 
 struct pglist_data;
@@ -447,6 +448,7 @@ struct zone {
 
 	/* free areas of different sizes */
 	struct free_area	free_area[MAX_ORDER];
+	unsigned long		unusable_free_index_updated;
 
 	/* zone flags, see below */
 	unsigned long		flags;
diff --git a/mm/internal.h b/mm/internal.h
index bfad3b5..912df14 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -113,6 +113,12 @@ struct alloc_context {
 	bool spread_dirty_pages;
 };
 
+struct contig_page_info {
+	unsigned long free_pages;
+	unsigned long free_blocks_total;
+	unsigned long free_blocks_order[MAX_ORDER];
+};
+
 #define ac_classzone_idx(ac) zonelist_zone_idx(ac->preferred_zoneref)
 
 /*
@@ -158,6 +164,21 @@ extern void post_alloc_hook(struct page *page, unsigned int order,
 					gfp_t gfp_flags);
 extern int user_min_free_kbytes;
 
+#define ewma_add(ewma, val, weight, factor)				\
+({									\
+	(ewma) *= (weight) - 1;						\
+	(ewma) += (val) << factor;					\
+	(ewma) /= (weight);						\
+	(ewma) >> factor;						\
+})
+
+#define UNUSABLE_INDEX_FACTOR (10)
+
+extern void fill_contig_page_info(struct zone *zone,
+				struct contig_page_info *info);
+extern int unusable_free_index(unsigned int order,
+				struct contig_page_info *info);
+
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 46ad035..5a22708 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -754,6 +754,32 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
+static void update_unusable_free_index(struct zone *zone)
+{
+	struct contig_page_info info;
+	unsigned long val;
+	unsigned int order;
+	struct free_area *free_area;
+
+	do {
+		if (unlikely(time_before(jiffies,
+			zone->unusable_free_index_updated + HZ / 10)))
+			return;
+
+		fill_contig_page_info(zone, &info);
+		for (order = 0; order < MAX_ORDER; order++) {
+			free_area = &zone->free_area[order];
+
+			val = unusable_free_index(order, &info);
+			/* decay value contribution by 99% in 1 min */
+			ewma_add(free_area->unusable_free_avg, val,
+					128, UNUSABLE_INDEX_FACTOR);
+		}
+
+		zone->unusable_free_index_updated = jiffies + HZ / 10;
+	} while (1);
+}
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -878,6 +904,8 @@ static inline void __free_one_page(struct page *page,
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
 out:
 	zone->free_area[order].nr_free++;
+
+	update_unusable_free_index(zone);
 }
 
 /*
@@ -1802,6 +1830,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
 		set_pcppage_migratetype(page, migratetype);
+		update_unusable_free_index(zone);
 		return page;
 	}
 
@@ -2174,6 +2203,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 		 * fallback only via special __rmqueue_cma_fallback() function
 		 */
 		set_pcppage_migratetype(page, start_migratetype);
+		update_unusable_free_index(zone);
 
 		trace_mm_page_alloc_extfrag(page, order, current_order,
 			start_migratetype, fallback_mt);
@@ -5127,7 +5157,9 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
+		zone->free_area[order].unusable_free_avg = 0;
 	}
+	zone->unusable_free_index_updated = jiffies;
 }
 
 #ifndef __HAVE_ARCH_MEMMAP_INIT
diff --git a/mm/vmstat.c b/mm/vmstat.c
index cd0c331..0b218d9 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -816,14 +816,6 @@ unsigned long node_page_state(struct pglist_data *pgdat,
 }
 #endif
 
-#ifdef CONFIG_COMPACTION
-
-struct contig_page_info {
-	unsigned long free_pages;
-	unsigned long free_blocks_total;
-	unsigned long free_blocks_order[MAX_ORDER];
-};
-
 /*
  * Calculate the number of free pages in a zone, how many contiguous
  * pages are free and how many are large enough to satisfy an allocation of
@@ -832,7 +824,7 @@ struct contig_page_info {
  * migrated. Calculating that is possible, but expensive and can be
  * figured out from userspace
  */
-static void fill_contig_page_info(struct zone *zone,
+void fill_contig_page_info(struct zone *zone,
 				struct contig_page_info *info)
 {
 	unsigned int order;
@@ -858,6 +850,7 @@ static void fill_contig_page_info(struct zone *zone,
 	}
 }
 
+#ifdef CONFIG_COMPACTION
 /*
  * A fragmentation index only makes sense if an allocation of a requested
  * size would fail. If that is true, the fragmentation index indicates
@@ -1790,13 +1783,11 @@ static int __init setup_vmstat(void)
 }
 module_init(setup_vmstat)
 
-#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
-
 /*
  * Return an index indicating how much of the available free memory is
  * unusable for an allocation of the requested size.
  */
-static int unusable_free_index(unsigned int order,
+int unusable_free_index(unsigned int order,
 				struct contig_page_info *info)
 {
 	/* No free memory is interpreted as all free memory is unusable */
@@ -1814,6 +1805,7 @@ static int unusable_free_index(unsigned int order,
 
 }
 
+#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
 static void unusable_show_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
