Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B430B6B025E
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:02 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j4so955410wrg.15
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si1475710edd.13.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 5/8] mm, compaction: factor out checking if page can be isolated for migration
Date: Wed, 13 Dec 2017 09:59:12 +0100
Message-Id: <20171213085915.9278-6-vbabka@suse.cz>
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
References: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

The following patch will introduce pre-scanning in migration scanner, which
will check for pages that can be isolated, without actually isolating them. To
prepare for this, move the checking into a new function. No functional change.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 150 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 88 insertions(+), 62 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 4f93a7307fb5..1ef090aa96e6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -669,6 +669,80 @@ static bool too_many_isolated(struct zone *zone)
 	return isolated > (inactive + active) / 2;
 }
 
+enum candidate_status {
+	CANDIDATE_FAIL,
+	CANDIDATE_FREE,
+	CANDIDATE_LRU,
+	CANDIDATE_OK = CANDIDATE_LRU,
+	CANDIDATE_MOVABLE
+};
+
+static enum candidate_status
+check_isolate_candidate(struct page *page, unsigned long *pfn,
+						struct compact_control *cc)
+{
+	/*
+	 * Skip free pages. We read page order here without zone lock which is
+	 * generally unsafe, but the race window is small and the worst thing
+	 * that can happen is that we skip some potential isolation targets.
+	 */
+	if (PageBuddy(page)) {
+		unsigned long freepage_order = page_order_unsafe(page);
+
+		/*
+		 * Without lock, we cannot be sure that what we got is a valid
+		 * page order. Consider only values in the valid order range to
+		 * prevent _pfn overflow.
+		 */
+		if (freepage_order > 0 && freepage_order < MAX_ORDER)
+			*pfn += (1UL << freepage_order) - 1;
+		return CANDIDATE_FREE;
+	}
+
+	/*
+	 * Regardless of being on LRU, compound pages such as THP and hugetlbfs
+	 * are not to be compacted. We can potentially save a lot of iterations
+	 * if we skip them at once. The check is racy, but we can consider only
+	 * valid values and the only danger is skipping too much.
+	 */
+	if (PageCompound(page)) {
+		const unsigned int order = compound_order(page);
+
+		if (likely(order < MAX_ORDER))
+			*pfn += (1UL << order) - 1;
+		return CANDIDATE_FAIL;
+	}
+
+	/*
+	 * Check may be lockless but that's ok as we recheck later.  It's
+	 * possible to migrate LRU and non-lru movable pages.  Skip any other
+	 * type of page
+	 */
+	if (!PageLRU(page)) {
+		if (unlikely(__PageMovable(page)) && !PageIsolated(page))
+			return CANDIDATE_MOVABLE;
+
+		return CANDIDATE_FAIL;
+	}
+
+	/*
+	 * Migration will fail if an anonymous page is pinned in memory, so
+	 * avoid taking lru_lock and isolating it unnecessarily in an admittedly
+	 * racy check.
+	 */
+	if (!page_mapping(page) && page_count(page) > page_mapcount(page))
+		return CANDIDATE_FAIL;
+
+	/*
+	 * Only allow to migrate anonymous pages in GFP_NOFS context because
+	 * those do not depend on fs locks.
+	 */
+	if (!(cc->gfp_mask & __GFP_FS) && page_mapping(page))
+		return CANDIDATE_FAIL;
+
+	return CANDIDATE_LRU;
+}
+
 /**
  * isolate_migratepages_block() - isolate all migrate-able pages within
  *				  a single pageblock
@@ -736,6 +810,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
 
+		enum candidate_status status;
+
 		if (skip_on_failure && low_pfn >= next_skip_pfn) {
 			/*
 			 * We have isolated all migration candidates in the
@@ -777,82 +853,32 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		if (!valid_page)
 			valid_page = page;
 
-		/*
-		 * Skip if free. We read page order here without zone lock
-		 * which is generally unsafe, but the race window is small and
-		 * the worst thing that can happen is that we skip some
-		 * potential isolation targets.
-		 */
-		if (PageBuddy(page)) {
-			unsigned long freepage_order = page_order_unsafe(page);
+		status = check_isolate_candidate(page, &low_pfn, cc);
 
-			/*
-			 * Without lock, we cannot be sure that what we got is
-			 * a valid page order. Consider only values in the
-			 * valid order range to prevent low_pfn overflow.
-			 */
-			if (freepage_order > 0 && freepage_order < MAX_ORDER)
-				low_pfn += (1UL << freepage_order) - 1;
+		if (status == CANDIDATE_FREE)
 			continue;
-		}
-
-		/*
-		 * Regardless of being on LRU, compound pages such as THP and
-		 * hugetlbfs are not to be compacted. We can potentially save
-		 * a lot of iterations if we skip them at once. The check is
-		 * racy, but we can consider only valid values and the only
-		 * danger is skipping too much.
-		 */
-		if (PageCompound(page)) {
-			const unsigned int order = compound_order(page);
-
-			if (likely(order < MAX_ORDER))
-				low_pfn += (1UL << order) - 1;
+		else if (status == CANDIDATE_FAIL)
 			goto isolate_fail;
-		}
 
-		/*
-		 * Check may be lockless but that's ok as we recheck later.
-		 * It's possible to migrate LRU and non-lru movable pages.
-		 * Skip any other type of page
-		 */
-		if (!PageLRU(page)) {
+		if (unlikely(status == CANDIDATE_MOVABLE)) {
 			/*
 			 * __PageMovable can return false positive so we need
 			 * to verify it under page_lock.
 			 */
-			if (unlikely(__PageMovable(page)) &&
-					!PageIsolated(page)) {
-				if (locked) {
-					spin_unlock_irqrestore(zone_lru_lock(zone),
-									flags);
-					locked = false;
-				}
-
-				if (!isolate_movable_page(page, isolate_mode))
-					goto isolate_success;
+			if (locked) {
+				spin_unlock_irqrestore(zone_lru_lock(zone),
+								flags);
+				locked = false;
 			}
 
-			goto isolate_fail;
+			if (!isolate_movable_page(page, isolate_mode))
+				goto isolate_success;
 		}
 
 		/*
-		 * Migration will fail if an anonymous page is pinned in memory,
-		 * so avoid taking lru_lock and isolating it unnecessarily in an
-		 * admittedly racy check.
+		 * The remaining case is CANDIDATE_LRU. If we already hold the
+		 * lock, we can skip some rechecking
 		 */
-		if (!page_mapping(page) &&
-		    page_count(page) > page_mapcount(page))
-			goto isolate_fail;
-
-		/*
-		 * Only allow to migrate anonymous pages in GFP_NOFS context
-		 * because those do not depend on fs locks.
-		 */
-		if (!(cc->gfp_mask & __GFP_FS) && page_mapping(page))
-			goto isolate_fail;
-
-		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
 			locked = compact_trylock_irqsave(zone_lru_lock(zone),
 								&flags, cc);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
