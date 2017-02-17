Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 597674405F6
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:09 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id g49so38654781qta.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:09 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id m189si7666079qkc.38.2017.02.17.07.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:08 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 02/14] mm/migrate: Make migrate_mode types non-exclussive
Date: Fri, 17 Feb 2017 10:05:39 -0500
Message-Id: <20170217150551.117028-3-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

It basically changes the enum declaration from numbers to bit positions
so that they can be used in combination which was not the case earlier.
No functionality has been changed.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/migrate_mode.h |  8 ++++----
 mm/compaction.c              | 20 ++++++++++----------
 mm/migrate.c                 | 14 +++++++-------
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index b3b9acbff444..89c170060e5b 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -8,10 +8,10 @@
  * MIGRATE_SYNC will block when migrating pages
  */
 enum migrate_mode {
-	MIGRATE_ASYNC,
-	MIGRATE_SYNC_LIGHT,
-	MIGRATE_SYNC,
-	MIGRATE_ST
+	MIGRATE_ASYNC		= 1<<0,
+	MIGRATE_SYNC_LIGHT	= 1<<1,
+	MIGRATE_SYNC		= 1<<2,
+	MIGRATE_ST		= 1<<3,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/compaction.c b/mm/compaction.c
index 5657a75ea6a8..de4634c60cca 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -296,7 +296,7 @@ static void update_pageblock_skip(struct compact_control *cc,
 	if (migrate_scanner) {
 		if (pfn > zone->compact_cached_migrate_pfn[0])
 			zone->compact_cached_migrate_pfn[0] = pfn;
-		if (cc->mode != MIGRATE_ASYNC &&
+		if (!(cc->mode & MIGRATE_ASYNC) &&
 		    pfn > zone->compact_cached_migrate_pfn[1])
 			zone->compact_cached_migrate_pfn[1] = pfn;
 	} else {
@@ -329,7 +329,7 @@ static void update_pageblock_skip(struct compact_control *cc,
 static bool compact_trylock_irqsave(spinlock_t *lock, unsigned long *flags,
 						struct compact_control *cc)
 {
-	if (cc->mode == MIGRATE_ASYNC) {
+	if (cc->mode & MIGRATE_ASYNC) {
 		if (!spin_trylock_irqsave(lock, *flags)) {
 			cc->contended = true;
 			return false;
@@ -370,7 +370,7 @@ static bool compact_unlock_should_abort(spinlock_t *lock,
 	}
 
 	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC) {
+		if (cc->mode & MIGRATE_ASYNC) {
 			cc->contended = true;
 			return true;
 		}
@@ -393,7 +393,7 @@ static inline bool compact_should_abort(struct compact_control *cc)
 {
 	/* async compaction aborts if contended */
 	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC) {
+		if (cc->mode & MIGRATE_ASYNC) {
 			cc->contended = true;
 			return true;
 		}
@@ -688,7 +688,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	 */
 	while (unlikely(too_many_isolated(zone))) {
 		/* async migration should just abort */
-		if (cc->mode == MIGRATE_ASYNC)
+		if (cc->mode & MIGRATE_ASYNC)
 			return 0;
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -700,7 +700,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	if (compact_should_abort(cc))
 		return 0;
 
-	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
+	if (cc->direct_compaction && (cc->mode & MIGRATE_ASYNC)) {
 		skip_on_failure = true;
 		next_skip_pfn = block_end_pfn(low_pfn, cc->order);
 	}
@@ -1195,7 +1195,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
-		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
+		(!(cc->mode & MIGRATE_SYNC) ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
 	 * Start at where we last stopped, or beginning of the zone as
@@ -1241,7 +1241,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		 * Async compaction is optimistic to see if the minimum amount
 		 * of work satisfies the allocation.
 		 */
-		if (cc->mode == MIGRATE_ASYNC &&
+		if ((cc->mode & MIGRATE_ASYNC) &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page)))
 			continue;
 
@@ -1481,7 +1481,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
 	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
-	const bool sync = cc->mode != MIGRATE_ASYNC;
+	const bool sync = !(cc->mode & MIGRATE_ASYNC);
 
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
@@ -1577,7 +1577,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 			 * order-aligned block, so skip the rest of it.
 			 */
 			if (cc->direct_compaction &&
-						(cc->mode == MIGRATE_ASYNC)) {
+						(cc->mode & MIGRATE_ASYNC)) {
 				cc->migrate_pfn = block_end_pfn(
 						cc->migrate_pfn - 1, cc->order);
 				/* Draining pcplists is useless in this case */
diff --git a/mm/migrate.c b/mm/migrate.c
index 5913f5b54832..87253cb9b50a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -359,7 +359,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	struct buffer_head *bh = head;
 
 	/* Simple case, sync compaction */
-	if (mode != MIGRATE_ASYNC) {
+	if (!(mode & MIGRATE_ASYNC)) {
 		do {
 			get_bh(bh);
 			lock_buffer(bh);
@@ -460,7 +460,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * the mapping back due to an elevated page count, we would have to
 	 * block waiting on other references to be dropped.
 	 */
-	if (mode == MIGRATE_ASYNC && head &&
+	if ((mode & MIGRATE_ASYNC) && head &&
 			!buffer_migrate_lock_buffers(head, mode)) {
 		page_ref_unfreeze(page, expected_count);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -746,7 +746,7 @@ int buffer_migrate_page(struct address_space *mapping,
 	 * with an IRQ-safe spinlock held. In the sync case, the buffers
 	 * need to be locked now
 	 */
-	if (mode != MIGRATE_ASYNC)
+	if (!(mode & MIGRATE_ASYNC))
 		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
 
 	ClearPagePrivate(page);
@@ -828,7 +828,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
-		if (mode != MIGRATE_SYNC)
+		if (!(mode & MIGRATE_SYNC))
 			return -EBUSY;
 		return writeout(mapping, page);
 	}
@@ -937,7 +937,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	bool is_lru = !__PageMovable(page);
 
 	if (!trylock_page(page)) {
-		if (!force || mode == MIGRATE_ASYNC)
+		if (!force || (mode & MIGRATE_ASYNC))
 			goto out;
 
 		/*
@@ -966,7 +966,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
 		 */
-		if (mode != MIGRATE_SYNC) {
+		if (!(mode & MIGRATE_SYNC)) {
 			rc = -EBUSY;
 			goto out_unlock;
 		}
@@ -1236,7 +1236,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		return -ENOMEM;
 
 	if (!trylock_page(hpage)) {
-		if (!force || mode != MIGRATE_SYNC)
+		if (!force || !(mode & MIGRATE_SYNC))
 			goto out;
 		lock_page(hpage);
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
