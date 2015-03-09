Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 67FD36B0073
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 16:48:54 -0400 (EDT)
Received: by pabrd3 with SMTP id rd3so41840693pab.6
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 13:48:54 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id pw7si5277747pdb.132.2015.03.09.13.48.52
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 13:48:53 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V3] Allow compaction of unevictable pages
Date: Mon,  9 Mar 2015 16:48:43 -0400
Message-Id: <1425934123-30591-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, pages which are marked as unevictable are protected from
compaction, but not from other types of migration.  The mlock
desctription does not promise that all page faults will be avoided, only
major ones so this protection is not necessary.  This extra protection
can cause problems for applications that are using mlock to avoid
swapping pages out, but require order > 0 allocations to continue to
succeed in a fragmented environment.  This patch removes the
ISOLATE_UNEVICTABLE mode and the check for it in __isolate_lru_page().
Removing this check allows the removal of the isolate_mode argument from
isolate_migratepages_block() because it can compute the required mode
from the compact_control structure.

To illustrate this problem I wrote a quick test program that mmaps a
large number of 1MB files filled with random data.  These maps are
created locked and read only.  Then every other mmap is unmapped and I
attempt to allocate huge pages to the static huge page pool.  Without
this patch I am unable to allocate any huge pages after  fragmenting
memory.  With it, I can allocate almost all the space freed by unmapping
as huge pages.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/mmzone.h |    2 --
 mm/compaction.c        |   13 +++++--------
 mm/vmscan.c            |    4 ----
 3 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f279d9c..599fb01 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -232,8 +232,6 @@ struct lruvec {
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
 /* Isolate for asynchronous migration */
 #define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x4)
-/* Isolate unevictable pages */
-#define ISOLATE_UNEVICTABLE	((__force isolate_mode_t)0x8)
 
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..9bdf1d7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -650,7 +650,6 @@ static bool too_many_isolated(struct zone *zone)
  * @cc:		Compaction control structure.
  * @low_pfn:	The first PFN to isolate
  * @end_pfn:	The one-past-the-last PFN to isolate, within same pageblock
- * @isolate_mode: Isolation mode to be used.
  *
  * Isolate all pages that can be migrated from the range specified by
  * [low_pfn, end_pfn). The range is expected to be within same pageblock.
@@ -664,7 +663,7 @@ static bool too_many_isolated(struct zone *zone)
  */
 static unsigned long
 isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
-			unsigned long end_pfn, isolate_mode_t isolate_mode)
+			unsigned long end_pfn)
 {
 	struct zone *zone = cc->zone;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
@@ -674,6 +673,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
 	unsigned long start_pfn = low_pfn;
+	const isolate_mode_t isolate_mode =
+		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -872,8 +873,7 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
 			continue;
 
-		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
-							ISOLATE_UNEVICTABLE);
+		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn);
 
 		/*
 		 * In case of fatal failure, release everything that might
@@ -1056,8 +1056,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 {
 	unsigned long low_pfn, end_pfn;
 	struct page *page;
-	const isolate_mode_t isolate_mode =
-		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
 	 * Start at where we last stopped, or beginning of the zone as
@@ -1102,8 +1100,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 
 		/* Perform the isolation */
-		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
-								isolate_mode);
+		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn);
 
 		if (!low_pfn || cc->contended) {
 			acct_isolated(zone, cc);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..3b2a444 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1234,10 +1234,6 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 	if (!PageLRU(page))
 		return ret;
 
-	/* Compaction should not handle unevictable pages but CMA can do so */
-	if (PageUnevictable(page) && !(mode & ISOLATE_UNEVICTABLE))
-		return ret;
-
 	ret = -EBUSY;
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
