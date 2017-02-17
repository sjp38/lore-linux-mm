Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 724D9681021
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y6so45453065pgy.5
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 03:26:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u79si10061628pfa.27.2017.02.17.03.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 03:26:12 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1HBNuJD120496
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:11 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28nrgkrd24-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:11 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 17 Feb 2017 21:26:09 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 24D722BB0055
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:07 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1HBPxCO32112852
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:07 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1HBPYK8025372
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:25:35 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 2/6] mm/migrate: Make migrate_mode types non-exclusive
Date: Fri, 17 Feb 2017 16:54:49 +0530
In-Reply-To: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170217112453.307-3-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

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
index b3b9acb..89c1700 100644
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
index 949198d..1a481af 100644
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
index 13fa938..63c3682 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -352,7 +352,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	struct buffer_head *bh = head;
 
 	/* Simple case, sync compaction */
-	if (mode != MIGRATE_ASYNC) {
+	if (!(mode & MIGRATE_ASYNC)) {
 		do {
 			get_bh(bh);
 			lock_buffer(bh);
@@ -453,7 +453,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * the mapping back due to an elevated page count, we would have to
 	 * block waiting on other references to be dropped.
 	 */
-	if (mode == MIGRATE_ASYNC && head &&
+	if ((mode & MIGRATE_ASYNC) && head &&
 			!buffer_migrate_lock_buffers(head, mode)) {
 		page_ref_unfreeze(page, expected_count);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -739,7 +739,7 @@ int buffer_migrate_page(struct address_space *mapping,
 	 * with an IRQ-safe spinlock held. In the sync case, the buffers
 	 * need to be locked now
 	 */
-	if (mode != MIGRATE_ASYNC)
+	if (!(mode & MIGRATE_ASYNC))
 		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
 
 	ClearPagePrivate(page);
@@ -821,7 +821,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
-		if (mode != MIGRATE_SYNC)
+		if (!(mode & MIGRATE_SYNC))
 			return -EBUSY;
 		return writeout(mapping, page);
 	}
@@ -930,7 +930,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	bool is_lru = !__PageMovable(page);
 
 	if (!trylock_page(page)) {
-		if (!force || mode == MIGRATE_ASYNC)
+		if (!force || (mode & MIGRATE_ASYNC))
 			goto out;
 
 		/*
@@ -959,7 +959,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
 		 */
-		if (mode != MIGRATE_SYNC) {
+		if (!(mode & MIGRATE_SYNC)) {
 			rc = -EBUSY;
 			goto out_unlock;
 		}
@@ -1229,7 +1229,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		return -ENOMEM;
 
 	if (!trylock_page(hpage)) {
-		if (!force || mode != MIGRATE_SYNC)
+		if (!force || !(mode & MIGRATE_SYNC))
 			goto out;
 		lock_page(hpage);
 	}
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
