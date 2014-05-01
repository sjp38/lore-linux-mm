Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0619D6B004D
	for <linux-mm@kvack.org>; Thu,  1 May 2014 04:45:00 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so2040576eek.31
        for <linux-mm@kvack.org>; Thu, 01 May 2014 01:45:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g45si33522845eev.40.2014.05.01.01.44.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 01:44:59 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/17] mm: page_alloc: Reduce number of times page_to_pfn is called
Date: Thu,  1 May 2014 09:44:40 +0100
Message-Id: <1398933888-4940-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-1-git-send-email-mgorman@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>

In the free path we calculate page_to_pfn multiple times. Reduce that.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h          |  9 +++++++--
 include/linux/pageblock-flags.h | 35 +++++++++++++++--------------------
 mm/page_alloc.c                 | 32 ++++++++++++++++++--------------
 3 files changed, 40 insertions(+), 36 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c84703d..2c3037a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -78,10 +78,15 @@ extern int page_group_by_mobility_disabled;
 #define NR_MIGRATETYPE_BITS (PB_migrate_end - PB_migrate + 1)
 #define MIGRATETYPE_MASK ((1UL << NR_MIGRATETYPE_BITS) - 1)
 
-static inline int get_pageblock_migratetype(struct page *page)
+#define get_pageblock_migratetype(page)					\
+	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
+			PB_migrate_end, NR_MIGRATETYPE_BITS,		\
+			MIGRATETYPE_MASK)
+
+static inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
 {
 	BUILD_BUG_ON(PB_migrate_end - PB_migrate != 2);
-	return get_pageblock_flags_mask(page, PB_migrate_end,
+	return get_pfnblock_flags_mask(page, pfn, PB_migrate_end,
 					NR_MIGRATETYPE_BITS, MIGRATETYPE_MASK);
 }
 
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index bc37036..2900b42 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -65,35 +65,30 @@ extern int pageblock_order;
 /* Forward declaration */
 struct page;
 
-unsigned long get_pageblock_flags_mask(struct page *page,
+unsigned long get_pfnblock_flags_mask(struct page *page,
+				unsigned long pfn,
 				unsigned long end_bitidx,
 				unsigned long nr_flag_bits,
 				unsigned long mask);
-void set_pageblock_flags_mask(struct page *page,
+
+void set_pfnblock_flags_mask(struct page *page,
 				unsigned long flags,
+				unsigned long pfn,
 				unsigned long end_bitidx,
 				unsigned long nr_flag_bits,
 				unsigned long mask);
 
 /* Declarations for getting and setting flags. See mm/page_alloc.c */
-static inline unsigned long get_pageblock_flags_group(struct page *page,
-					int start_bitidx, int end_bitidx)
-{
-	unsigned long nr_flag_bits = end_bitidx - start_bitidx + 1;
-	unsigned long mask = (1 << nr_flag_bits) - 1;
-
-	return get_pageblock_flags_mask(page, end_bitidx, nr_flag_bits, mask);
-}
-
-static inline void set_pageblock_flags_group(struct page *page,
-					unsigned long flags,
-					int start_bitidx, int end_bitidx)
-{
-	unsigned long nr_flag_bits = end_bitidx - start_bitidx + 1;
-	unsigned long mask = (1 << nr_flag_bits) - 1;
-
-	set_pageblock_flags_mask(page, flags, end_bitidx, nr_flag_bits, mask);
-}
+#define get_pageblock_flags_group(page, start_bitidx, end_bitidx) \
+	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
+			end_bitidx,					\
+			end_bitidx - start_bitidx + 1,			\
+			(1 << (end_bitidx - start_bitidx + 1)) - 1)
+#define set_pageblock_flags_group(page, flags, start_bitidx, end_bitidx) \
+	set_pfnblock_flags_mask(page, flags, page_to_pfn(page),		\
+			end_bitidx,					\
+			end_bitidx - start_bitidx + 1,			\
+			(1 << (end_bitidx - start_bitidx + 1)) - 1)
 
 #ifdef CONFIG_COMPACTION
 #define get_pageblock_skip(page) \
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2cf1558..61d45fd 100644
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
@@ -6032,18 +6037,17 @@ static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
  * @end_bitidx: The last bit of interest
  * returns pageblock_bits flags
  */
-unsigned long get_pageblock_flags_mask(struct page *page,
+unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
 					unsigned long end_bitidx,
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
@@ -6061,20 +6065,20 @@ unsigned long get_pageblock_flags_mask(struct page *page,
  * @end_bitidx: The last bit of interest
  * @flags: The flags to set
  */
-void set_pfnblock_flags_group(struct page *page, unsigned long flags,
+void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
+					unsigned long pfn,
 					unsigned long end_bitidx,
 					unsigned long nr_flag_bits,
 					unsigned long mask)
 {
 	struct zone *zone;
 	unsigned long *bitmap;
-	unsigned long pfn, bitidx, word_bitidx;
+	unsigned long bitidx, word_bitidx;
 	unsigned long old_word, new_word;
 
 	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
 
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
