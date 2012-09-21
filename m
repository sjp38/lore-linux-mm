Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 7BD856B0069
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 06:46:38 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 8/9] mm: compaction: Cache if a pageblock was scanned and no pages were isolated
Date: Fri, 21 Sep 2012 11:46:22 +0100
Message-Id: <1348224383-1499-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1348224383-1499-1-git-send-email-mgorman@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When compaction was implemented it was known that scanning could potentially
be excessive. The ideal was that a counter be maintained for each pageblock
but maintaining this information would incur a severe penalty due to a
shared writable cache line. It has reached the point where the scanning
costs are an serious problem, particularly on long-lived systems where a
large process starts and allocates a large number of THPs at the same time.

Instead of using a shared counter, this patch adds another bit to the
pageblock flags called PG_migrate_skip. If a pageblock is scanned by
either migrate or free scanner and 0 pages were isolated, the pageblock
is marked to be skipped in the future. When scanning, this bit is checked
before any scanning takes place and the block skipped if set.

The main difficulty with a patch like this is "when to ignore the cached
information?" If it's ignored too often, the scanning rates will still
be excessive. If the information is too stale then allocations will fail
that might have otherwise succeeded. In this patch

o CMA always ignores the information
o If the migrate and free scanner meet then the cached information will
  be discarded if it's at least 5 seconds since the last time the cache
  was discarded
o If there are a large number of allocation failures, discard the cache.

The time-based heuristic is very clumsy but there are few choices for a
better event. Depending solely on multiple allocation failures still allows
excessive scanning when THP allocations are failing in quick succession
due to memory pressure. Waiting until memory pressure is relieved would
cause compaction to continually fail instead of using reclaim/compaction
to try allocate the page. The time-based mechanism is clumsy but a better
option is not obvious.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mmzone.h          |    3 ++
 include/linux/pageblock-flags.h |   19 +++++++-
 mm/compaction.c                 |   93 +++++++++++++++++++++++++++++++++++++--
 mm/internal.h                   |    1 +
 mm/page_alloc.c                 |    1 +
 5 files changed, 111 insertions(+), 6 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 603d0b5..a456361 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -368,6 +368,9 @@ struct zone {
 	 */
 	spinlock_t		lock;
 	int                     all_unreclaimable; /* All pages pinned */
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+	unsigned long		compact_blockskip_expire;
+#endif
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
 	seqlock_t		span_seqlock;
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index 19ef95d..eed27f4 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -30,6 +30,9 @@ enum pageblock_bits {
 	PB_migrate,
 	PB_migrate_end = PB_migrate + 3 - 1,
 			/* 3 bits required for migrate types */
+#ifdef CONFIG_COMPACTION
+	PB_migrate_skip,/* If set the block is skipped by compaction */
+#endif /* CONFIG_COMPACTION */
 	NR_PAGEBLOCK_BITS
 };
 
@@ -65,10 +68,22 @@ unsigned long get_pageblock_flags_group(struct page *page,
 void set_pageblock_flags_group(struct page *page, unsigned long flags,
 					int start_bitidx, int end_bitidx);
 
+#ifdef CONFIG_COMPACTION
+#define get_pageblock_skip(page) \
+			get_pageblock_flags_group(page, PB_migrate_skip,     \
+							PB_migrate_skip + 1)
+#define clear_pageblock_skip(page) \
+			set_pageblock_flags_group(page, 0, PB_migrate_skip,  \
+							PB_migrate_skip + 1)
+#define set_pageblock_skip(page) \
+			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
+							PB_migrate_skip + 1)
+#endif /* CONFIG_COMPACTION */
+
 #define get_pageblock_flags(page) \
-			get_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
+			get_pageblock_flags_group(page, 0, PB_migrate_end)
 #define set_pageblock_flags(page, flags) \
 			set_pageblock_flags_group(page, flags,	\
-						  0, NR_PAGEBLOCK_BITS-1)
+						  0, PB_migrate_end)
 
 #endif	/* PAGEBLOCK_FLAGS_H */
diff --git a/mm/compaction.c b/mm/compaction.c
index 9fc1b61..9276bc8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -50,6 +50,64 @@ static inline bool migrate_async_suitable(int migratetype)
 	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
 }
 
+/* Returns true if the pageblock should be scanned for pages to isolate. */
+static inline bool isolation_suitable(struct compact_control *cc,
+					struct page *page)
+{
+	if (cc->ignore_skip_hint)
+		return true;
+
+	return !get_pageblock_skip(page);
+}
+
+/*
+ * This function is called to clear all cached information on pageblocks that
+ * should be skipped for page isolation when the migrate and free page scanner
+ * meet.
+ */
+static void reset_isolation_suitable(struct zone *zone)
+{
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	unsigned long pfn;
+
+	/*
+	 * Do not reset more than once every five seconds. If allocations are
+	 * failing sufficiently quickly to allow this to happen then continually
+	 * scanning for compaction is not going to help. The choice of five
+	 * seconds is arbitrary but will mitigate excessive scanning.
+	 */
+	if (time_before(jiffies, zone->compact_blockskip_expire))
+		return;
+	zone->compact_blockskip_expire = jiffies + (HZ * 5);
+
+	/* Walk the zone and mark every pageblock as suitable for isolation */
+	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		struct page *page;
+		if (!pfn_valid(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+		if (zone != page_zone(page))
+			continue;
+
+		clear_pageblock_skip(page);
+	}
+}
+
+/*
+ * If no pages were isolated then mark this pageblock to be skipped in the
+ * future. The information is later cleared by reset_isolation_suitable().
+ */
+static void update_pageblock_skip(struct page *page, unsigned long nr_isolated)
+{
+	if (!page)
+		return;
+
+	if (!nr_isolated)
+		set_pageblock_skip(page);
+}
+
 static inline bool should_release_lock(spinlock_t *lock)
 {
 	return need_resched() || spin_is_contended(lock);
@@ -182,7 +240,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 				bool strict)
 {
 	int nr_scanned = 0, total_isolated = 0;
-	struct page *cursor;
+	struct page *cursor, *valid_page = NULL;
 	unsigned long flags;
 	bool locked = false;
 
@@ -196,6 +254,8 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		if (!pfn_valid_within(blockpfn))
 			goto strict_check;
 		nr_scanned++;
+		if (!valid_page)
+			valid_page = page;
 
 		if (!PageBuddy(page))
 			goto strict_check;
@@ -253,6 +313,10 @@ out:
 	if (locked)
 		spin_unlock_irqrestore(&cc->zone->lock, flags);
 
+	/* Update the pageblock-skip if the whole pageblock was scanned */
+	if (blockpfn == end_pfn)
+		update_pageblock_skip(valid_page, total_isolated);
+
 	return total_isolated;
 }
 
@@ -390,6 +454,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	struct lruvec *lruvec;
 	unsigned long flags;
 	bool locked = false;
+	struct page *page = NULL, *valid_page = NULL;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -410,7 +475,6 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	/* Time to isolate some pages for migration */
 	cond_resched();
 	for (; low_pfn < end_pfn; low_pfn++) {
-		struct page *page;
 
 		/* give a chance to irqs before checking need_resched() */
 		if (locked && !((low_pfn+1) % SWAP_CLUSTER_MAX)) {
@@ -447,6 +511,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		if (page_zone(page) != zone)
 			continue;
 
+		if (!valid_page)
+			valid_page = page;
+
+		/* If isolation recently failed, do not retry */
+		pageblock_nr = low_pfn >> pageblock_order;
+		if (!isolation_suitable(cc, page))
+			goto next_pageblock;
+
 		/* Skip if free */
 		if (PageBuddy(page))
 			continue;
@@ -456,7 +528,6 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 * migration is optimistic to see if the minimum amount of work
 		 * satisfies the allocation
 		 */
-		pageblock_nr = low_pfn >> pageblock_order;
 		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
 			goto next_pageblock;
@@ -531,6 +602,10 @@ next_pageblock:
 	if (locked)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
+	/* Update the pageblock-skip if the whole pageblock was scanned */
+	if (low_pfn == end_pfn)
+		update_pageblock_skip(valid_page, nr_isolated);
+
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
 	return low_pfn;
@@ -594,6 +669,10 @@ static void isolate_freepages(struct zone *zone,
 		if (!suitable_migration_target(page))
 			continue;
 
+		/* If isolation recently failed, do not retry */
+		if (!isolation_suitable(cc, page))
+			continue;
+
 		/* Found a block suitable for isolating free pages from */
 		isolated = 0;
 		end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
@@ -710,8 +789,10 @@ static int compact_finished(struct zone *zone,
 		return COMPACT_PARTIAL;
 
 	/* Compaction run completes if the migrate and free scanner meet */
-	if (cc->free_pfn <= cc->migrate_pfn)
+	if (cc->free_pfn <= cc->migrate_pfn) {
+		reset_isolation_suitable(cc->zone);
 		return COMPACT_COMPLETE;
+	}
 
 	/*
 	 * order == -1 is expected when compacting via
@@ -819,6 +900,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
 	cc->free_pfn &= ~(pageblock_nr_pages-1);
 
+	/* Clear pageblock skip if there are numerous alloc failures */
+	if (zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT)
+		reset_isolation_suitable(zone);
+
 	migrate_prep_local();
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
diff --git a/mm/internal.h b/mm/internal.h
index f590a6e..fbf5ddc 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -121,6 +121,7 @@ struct compact_control {
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
+	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c03037e..ba34eee 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5662,6 +5662,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 		.order = -1,
 		.zone = page_zone(pfn_to_page(start)),
 		.sync = true,
+		.ignore_skip_hint = true,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
