Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3746B0073
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 09:15:35 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id q59so581967wes.23
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:15:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ep15si1799306wjd.3.2014.02.28.06.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 06:15:33 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/6] mm: add get_pageblock_migratetype_nolock() for cases where locking is undesirable
Date: Fri, 28 Feb 2014 15:15:00 +0100
Message-Id: <1393596904-16537-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

In order to prevent race with set_pageblock_migratetype, most of calls to
get_pageblock_migratetype have been moved under zone->lock. For the remaining
call sites, the extra locking is undesirable, notably in free_hot_cold_page().

This patch introduces a _nolock version to be used on these call sites, where
a wrong value does not affect correctness. The function makes sure that the
value does not exceed valid migratetype numbers. Such too-high values are
assumed to be a result of race and caller-supplied fallback value is returned
instead.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h | 24 ++++++++++++++++++++++++
 mm/compaction.c        | 14 +++++++++++---
 mm/memory-failure.c    |  3 ++-
 mm/page_alloc.c        | 22 +++++++++++++++++-----
 mm/vmstat.c            |  2 +-
 5 files changed, 55 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fac5509..7c3f678 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -75,6 +75,30 @@ enum {
 
 extern int page_group_by_mobility_disabled;
 
+/*
+ * When called without zone->lock held, a race with set_pageblock_migratetype
+ * may result in bogus values. Use this variant only when this does not affect
+ * correctness, and taking zone->lock would be costly. Values >= MIGRATE_TYPES
+ * are considered to be a result of this race and the value of race_fallback
+ * argument is returned instead.
+ */
+static inline int get_pageblock_migratetype_nolock(struct page *page,
+	int race_fallback)
+{
+	int ret = get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
+
+	if (unlikely(ret >= MIGRATE_TYPES))
+		ret = race_fallback;
+
+	return ret;
+}
+
+/*
+ * Should be called only with zone->lock held. In cases where locking overhead
+ * is undesirable, consider the _nolock version.
+ * Note that VM_BUG_ON(locked) here would require e.g. moving the function to a
+ * .c file to be able to include page_zone() definition.
+ */
 static inline int get_pageblock_migratetype(struct page *page)
 {
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
diff --git a/mm/compaction.c b/mm/compaction.c
index 5142920..f0db73b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -217,12 +217,17 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
 /* Returns true if the page is within a block suitable for migration to */
 static bool suitable_migration_target(struct page *page)
 {
+	int migratetype;
+
 	/* If the page is a large free page, then disallow migration */
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
 		return false;
 
+	/* If someone races on the pageblock, just assume it's not suitable */
+	migratetype = get_pageblock_migratetype_nolock(page, MIGRATE_RESERVE);
+
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(get_pageblock_migratetype(page)))
+	if (migrate_async_suitable(migratetype))
 		return true;
 
 	/* Otherwise skip the block */
@@ -530,9 +535,12 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			/*
 			 * For async migration, also only scan in MOVABLE
 			 * blocks. Async migration is optimistic to see if
-			 * the minimum amount of work satisfies the allocation
+			 * the minimum amount of work satisfies the allocation.
+			 * If we race on the migratetype, just assume it's an
+			 * unsuitable one.
 			 */
-			mt = get_pageblock_migratetype(page);
+			mt = get_pageblock_migratetype_nolock(page,
+					MIGRATE_RESERVE);
 			if (!cc->sync && !migrate_async_suitable(mt)) {
 				cc->finished_update_migrate = true;
 				skipped_async_unsuitable = true;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 35ef28a..d0625f6 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1672,7 +1672,8 @@ int soft_offline_page(struct page *page, int flags)
 	 * was free. This flag should be kept set until the source page
 	 * is freed and PG_hwpoison on it is set.
 	 */
-	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+	if (get_pageblock_migratetype_nolock(page, MIGRATE_RESERVE)
+			!= MIGRATE_ISOLATE)
 		set_migratetype_isolate(page, true);
 
 	ret = get_any_page(page, pfn, flags);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0cb41ec..de5b419 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1374,7 +1374,16 @@ void free_hot_cold_page(struct page *page, int cold)
 	if (!free_pages_prepare(page, 0))
 		return;
 
-	migratetype = get_pageblock_migratetype(page);
+	/*
+	 * We don't want to take zone->lock here just to determine pageblock
+	 * migratetype safely. So we allow a race, which will be detected if
+	 * the migratetype appears to be >= MIGRATE_TYPES.
+	 * In case of a detected race, defer to free_one_page() below, which
+	 * will re-read the pageblock migratetype under zone->lock and re-set
+	 * freepage migratetype accordingly.
+	 * We use MIGRATE_TYPES as MIGRATE_ISOLATE may not be enabled.
+	 */
+	migratetype = get_pageblock_migratetype_nolock(page, MIGRATE_TYPES);
 	set_freepage_migratetype(page, migratetype);
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
@@ -1387,7 +1396,8 @@ void free_hot_cold_page(struct page *page, int cold)
 	 * excessively into the page allocator
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
-		if (unlikely(is_migrate_isolate(migratetype))) {
+		if (unlikely(is_migrate_isolate(migratetype)
+			|| migratetype == MIGRATE_TYPES)) {
 			free_one_page(zone, page, 0);
 			goto out;
 		}
@@ -6080,8 +6090,9 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
  * If @count is not zero, it is okay to include less @count unmovable pages
  *
  * PageLRU check without isolation or lru_lock could race so that
- * MIGRATE_MOVABLE block might include unmovable pages. It means you can't
- * expect this function should be exact.
+ * MIGRATE_MOVABLE block might include unmovable pages. The detection of
+ * pageblock migratetype can race as well. It means you can't expect this
+ * function to be exact.
  */
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			 bool skip_hwpoisoned_pages)
@@ -6095,7 +6106,8 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	 */
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return false;
-	mt = get_pageblock_migratetype(page);
+	/* In case of a detected race, try to reduce false positives */
+	mt = get_pageblock_migratetype_nolock(page, MIGRATE_UNMOVABLE);
 	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
 		return false;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2592010..1f08bf6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -956,7 +956,7 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 		if (!memmap_valid_within(pfn, page, zone))
 			continue;
 
-		mtype = get_pageblock_migratetype(page);
+		mtype = get_pageblock_migratetype_nolock(page, MIGRATE_TYPES);
 
 		if (mtype < MIGRATE_TYPES)
 			count[mtype]++;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
