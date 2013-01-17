Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 347D36B0008
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:54:11 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 17 Jan 2013 15:54:10 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B63093E40039
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:54:01 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0HMs63S028354
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:54:07 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0HMs6T7024657
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:54:06 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 2/9] mm: add & use zone_end_pfn() and zone_spans_pfn()
Date: Thu, 17 Jan 2013 14:52:54 -0800
Message-Id: <1358463181-17956-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Add 2 helpers (zone_end_pfn() and zone_spans_pfn()) to reduce code
duplication.

This also switches to using them in compaction (where an additional
variable needed to be renamed), page_alloc, vmstat, memory_hotplug,
and kmemleak.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---

Note that in compaction.c I avoid calling zone_end_pfn() repeatedly because I
expect at some point the sycronization issues with start_pfn & spanned_pages
will need fixing, either by actually using the seqlock or clever memory barrier
usage.

 include/linux/mmzone.h | 10 ++++++++++
 mm/compaction.c        | 10 +++++-----
 mm/kmemleak.c          |  5 ++---
 mm/memory_hotplug.c    | 10 +++++-----
 mm/page_alloc.c        | 22 +++++++++-------------
 mm/vmstat.c            |  2 +-
 6 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 73b64a3..d91d964 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -543,6 +543,16 @@ static inline int zone_is_oom_locked(const struct zone *zone)
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
 }
 
+static inline unsigned zone_end_pfn(const struct zone *zone)
+{
+	return zone->zone_start_pfn + zone->spanned_pages;
+}
+
+static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
+{
+	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
+}
+
 /*
  * The "priority" of VM scanning is how much of the queues we will scan in one
  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
diff --git a/mm/compaction.c b/mm/compaction.c
index c62bd06..ea66be3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -85,7 +85,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
 static void __reset_isolation_suitable(struct zone *zone)
 {
 	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long pfn;
 
 	zone->compact_cached_migrate_pfn = start_pfn;
@@ -644,7 +644,7 @@ static void isolate_freepages(struct zone *zone,
 				struct compact_control *cc)
 {
 	struct page *page;
-	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
+	unsigned long high_pfn, low_pfn, pfn, z_end_pfn, end_pfn;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -663,7 +663,7 @@ static void isolate_freepages(struct zone *zone,
 	 */
 	high_pfn = min(low_pfn, pfn);
 
-	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	z_end_pfn = zone_end_pfn(zone);
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -706,7 +706,7 @@ static void isolate_freepages(struct zone *zone,
 		 * only scans within a pageblock
 		 */
 		end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
-		end_pfn = min(end_pfn, zone_end_pfn);
+		end_pfn = min(end_pfn, z_end_pfn);
 		isolated = isolate_freepages_block(cc, pfn, end_pfn,
 						   freelist, false);
 		nr_freepages += isolated;
@@ -920,7 +920,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
 	int ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	unsigned long end_pfn = zone_end_pfn(zone);
 
 	ret = compaction_suitable(zone, cc->order);
 	switch (ret) {
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 752a705..83dd5fb 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1300,9 +1300,8 @@ static void kmemleak_scan(void)
 	 */
 	lock_memory_hotplug();
 	for_each_online_node(i) {
-		pg_data_t *pgdat = NODE_DATA(i);
-		unsigned long start_pfn = pgdat->node_start_pfn;
-		unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
+		unsigned long start_pfn = node_start_pfn(i);
+		unsigned long end_pfn = node_end_pfn(i);
 		unsigned long pfn;
 
 		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d04ed87..c62bcca 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -270,7 +270,7 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 	pgdat_resize_lock(z1->zone_pgdat, &flags);
 
 	/* can't move pfns which are higher than @z2 */
-	if (end_pfn > z2->zone_start_pfn + z2->spanned_pages)
+	if (end_pfn > zone_end_pfn(z2))
 		goto out_fail;
 	/* the move out part mast at the left most of @z2 */
 	if (start_pfn > z2->zone_start_pfn)
@@ -286,7 +286,7 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 		z1_start_pfn = start_pfn;
 
 	resize_zone(z1, z1_start_pfn, end_pfn);
-	resize_zone(z2, end_pfn, z2->zone_start_pfn + z2->spanned_pages);
+	resize_zone(z2, end_pfn, zone_end_pfn(z2));
 
 	pgdat_resize_unlock(z1->zone_pgdat, &flags);
 
@@ -318,15 +318,15 @@ static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
 	if (z1->zone_start_pfn > start_pfn)
 		goto out_fail;
 	/* the move out part mast at the right most of @z1 */
-	if (z1->zone_start_pfn + z1->spanned_pages >  end_pfn)
+	if (zone_end_pfn(z1) >  end_pfn)
 		goto out_fail;
 	/* must included/overlap */
-	if (start_pfn >= z1->zone_start_pfn + z1->spanned_pages)
+	if (start_pfn >= zone_end_pfn(z1))
 		goto out_fail;
 
 	/* use end_pfn for z2's end_pfn if z2 is empty */
 	if (z2->spanned_pages)
-		z2_end_pfn = z2->zone_start_pfn + z2->spanned_pages;
+		z2_end_pfn = zone_end_pfn(z2);
 	else
 		z2_end_pfn = end_pfn;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df2022f..e2574ea 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -242,9 +242,7 @@ static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 
 	do {
 		seq = zone_span_seqbegin(zone);
-		if (pfn >= zone->zone_start_pfn + zone->spanned_pages)
-			ret = 1;
-		else if (pfn < zone->zone_start_pfn)
+		if (!zone_spans_pfn(zone, pfn))
 			ret = 1;
 	} while (zone_span_seqretry(zone, seq));
 
@@ -976,9 +974,9 @@ int move_freepages_block(struct zone *zone, struct page *page,
 	end_pfn = start_pfn + pageblock_nr_pages - 1;
 
 	/* Do not cross zone boundaries */
-	if (start_pfn < zone->zone_start_pfn)
+	if (!zone_spans_pfn(zone, start_pfn))
 		start_page = page;
-	if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages)
+	if (!zone_spans_pfn(zone, end_pfn))
 		return 0;
 
 	return move_freepages(zone, start_page, end_page, migratetype);
@@ -1272,7 +1270,7 @@ void mark_free_pages(struct zone *zone)
 
 	spin_lock_irqsave(&zone->lock, flags);
 
-	max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	max_zone_pfn = zone_end_pfn(zone);
 	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 		if (pfn_valid(pfn)) {
 			struct page *page = pfn_to_page(pfn);
@@ -3775,7 +3773,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	 * the block.
 	 */
 	start_pfn = zone->zone_start_pfn;
-	end_pfn = start_pfn + zone->spanned_pages;
+	end_pfn = zone_end_pfn(zone);
 	start_pfn = roundup(start_pfn, pageblock_nr_pages);
 	reserve = roundup(min_wmark_pages(zone), pageblock_nr_pages) >>
 							pageblock_order;
@@ -3889,7 +3887,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * pfn out of zone.
 		 */
 		if ((z->zone_start_pfn <= pfn)
-		    && (pfn < z->zone_start_pfn + z->spanned_pages)
+		    && (pfn < zone_end_pfn(z))
 		    && !(pfn & (pageblock_nr_pages - 1)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
@@ -4617,7 +4615,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 		 * for the buddy allocator to function correctly.
 		 */
 		start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
-		end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
+		end = pgdat_end_pfn(pgdat);
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
 		map = alloc_remap(pgdat->node_id, size);
@@ -5637,8 +5635,7 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
 	pfn = page_to_pfn(page);
 	bitmap = get_pageblock_bitmap(zone, pfn);
 	bitidx = pfn_to_bitidx(zone, pfn);
-	VM_BUG_ON(pfn < zone->zone_start_pfn);
-	VM_BUG_ON(pfn >= zone->zone_start_pfn + zone->spanned_pages);
+	VM_BUG_ON(!zone_spans_pfn(zone, pfn));
 
 	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
 		if (flags & value)
@@ -5736,8 +5733,7 @@ bool is_pageblock_removable_nolock(struct page *page)
 
 	zone = page_zone(page);
 	pfn = page_to_pfn(page);
-	if (zone->zone_start_pfn > pfn ||
-			zone->zone_start_pfn + zone->spanned_pages <= pfn)
+	if (!zone_spans_pfn(zone, pfn))
 		return false;
 
 	return !has_unmovable_pages(zone, page, 0, true);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9800306..ca99641 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -890,7 +890,7 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 	int mtype;
 	unsigned long pfn;
 	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long end_pfn = start_pfn + zone->spanned_pages;
+	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long count[MIGRATE_TYPES] = { 0, };
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
