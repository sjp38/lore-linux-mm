Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id EB0B56B0068
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:55 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so1681809eek.16
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42si40598713eel.92.2014.04.18.07.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:49 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/16] mm: page_alloc: Reduce number of times page_to_pfn is called
Date: Fri, 18 Apr 2014 15:50:38 +0100
Message-Id: <1397832643-14275-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

In the free path we calculate page_to_pfn multiple times. Reduce that.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h          |  9 +++++++--
 include/linux/pageblock-flags.h | 15 ++++++---------
 mm/page_alloc.c                 | 26 +++++++++++++++-----------
 3 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c97b4bc..14ed8d1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -78,10 +78,15 @@ extern int page_group_by_mobility_disabled;
 #define NR_MIGRATETYPE_BITS 3
 #define MIGRATETYPE_MASK ((1UL << NR_MIGRATETYPE_BITS) - 1)
 
-static inline int get_pageblock_migratetype(struct page *page)
+#define get_pageblock_migratetype(page)					\
+	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
+				NR_MIGRATETYPE_BITS, MIGRATETYPE_MASK)
+
+static inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
 {
 	BUILD_BUG_ON(PB_migrate_end - PB_migrate != 2);
-	return get_pageblock_flags_mask(page, NR_MIGRATETYPE_BITS, MIGRATETYPE_MASK);
+	return get_pfnblock_flags_mask(page, pfn,
+					NR_MIGRATETYPE_BITS, MIGRATETYPE_MASK);
 }
 
 struct free_area {
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index c89ac75..6a9dd5b 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -65,19 +65,16 @@ extern int pageblock_order;
 /* Forward declaration */
 struct page;
 
-unsigned long get_pageblock_flags_mask(struct page *page,
+unsigned long get_pfnblock_flags_mask(struct page *page,
+				unsigned long pfn,
 				unsigned long nr_flag_bits,
 				unsigned long mask);
 
 /* Declarations for getting and setting flags. See mm/page_alloc.c */
-static inline unsigned long get_pageblock_flags_group(struct page *page,
-					int start_bitidx, int end_bitidx)
-{
-	unsigned long nr_flag_bits = end_bitidx - start_bitidx + 1;
-	unsigned long mask = (1 << nr_flag_bits) - 1;
-
-	return get_pageblock_flags_mask(page, nr_flag_bits, mask);
-}
+#define get_pageblock_flags_group(page, start_bitidx, end_bitidx) \
+	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
+			end_bitidx - start_bitidx + 1,			\
+			(1 << (end_bitidx - start_bitidx + 1)) - 1)
 void set_pageblock_flags_group(struct page *page, unsigned long flags,
 					int start_bitidx, int end_bitidx);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6047866..377e58a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -559,6 +559,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  */
 
 static inline void __free_one_page(struct page *page,
+		unsigned long pfn,
 		struct zone *zone, unsigned int order,
 		int migratetype)
 {
@@ -575,7 +576,7 @@ static inline void __free_one_page(struct page *page,
 
 	VM_BUG_ON(migratetype == -1);
 
-	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
+	page_idx = pfn & ((1 << MAX_ORDER) - 1);
 
 	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
@@ -710,7 +711,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			list_del(&page->lru);
 			mt = get_freepage_migratetype(page);
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
-			__free_one_page(page, zone, 0, mt);
+			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
 			if (likely(!is_migrate_isolate_page(page))) {
 				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
@@ -722,13 +723,15 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	spin_unlock(&zone->lock);
 }
 
-static void free_one_page(struct zone *zone, struct page *page, int order,
+static void free_one_page(struct zone *zone,
+				struct page *page, unsigned long pfn,
+				int order,
 				int migratetype)
 {
 	spin_lock(&zone->lock);
 	zone->pages_scanned = 0;
 
-	__free_one_page(page, zone, order, migratetype);
+	__free_one_page(page, pfn, zone, order, migratetype);
 	if (unlikely(!is_migrate_isolate(migratetype)))
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 	spin_unlock(&zone->lock);
@@ -765,15 +768,16 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
 	int migratetype;
+	unsigned long pfn = page_to_pfn(page);
 
 	if (!free_pages_prepare(page, order))
 		return;
 
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
-	migratetype = get_pageblock_migratetype(page);
+	migratetype = get_pfnblock_migratetype(page, pfn);
 	set_freepage_migratetype(page, migratetype);
-	free_one_page(page_zone(page), page, order, migratetype);
+	free_one_page(page_zone(page), page, pfn, order, migratetype);
 	local_irq_restore(flags);
 }
 
@@ -1376,12 +1380,13 @@ void free_hot_cold_page(struct page *page, int cold)
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
+	unsigned long pfn = page_to_pfn(page);
 	int migratetype;
 
 	if (!free_pages_prepare(page, 0))
 		return;
 
-	migratetype = get_pageblock_migratetype(page);
+	migratetype = get_pfnblock_migratetype(page, pfn);
 	set_freepage_migratetype(page, migratetype);
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
@@ -1395,7 +1400,7 @@ void free_hot_cold_page(struct page *page, int cold)
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
 		if (unlikely(is_migrate_isolate(migratetype))) {
-			free_one_page(zone, page, 0, migratetype);
+			free_one_page(zone, page, pfn, 0, migratetype);
 			goto out;
 		}
 		migratetype = MIGRATE_MOVABLE;
@@ -6012,17 +6017,16 @@ static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
  * @end_bitidx: The last bit of interest
  * returns pageblock_bits flags
  */
-unsigned long get_pageblock_flags_mask(struct page *page,
+unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
 					unsigned long nr_flag_bits,
 					unsigned long mask)
 {
 	struct zone *zone;
 	unsigned long *bitmap;
-	unsigned long pfn, bitidx, word_bitidx;
+	unsigned long bitidx, word_bitidx;
 	unsigned long word;
 
 	zone = page_zone(page);
-	pfn = page_to_pfn(page);
 	bitmap = get_pageblock_bitmap(zone, pfn);
 	bitidx = pfn_to_bitidx(zone, pfn);
 	word_bitidx = bitidx / BITS_PER_LONG;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
