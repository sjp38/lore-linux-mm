Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF2E6B006E
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 11:50:23 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so3965742wes.4
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 08:50:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu2si11629661wjb.71.2014.06.20.08.50.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 08:50:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 09/13] mm, compaction: skip buddy pages by their order in the migrate scanner
Date: Fri, 20 Jun 2014 17:49:39 +0200
Message-Id: <1403279383-5862-10-git-send-email-vbabka@suse.cz>
In-Reply-To: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

The migration scanner skips PageBuddy pages, but does not consider their order
as checking page_order() is generally unsafe without holding the zone->lock,
and acquiring the lock just for the check wouldn't be a good tradeoff.

Still, this could avoid some iterations over the rest of the buddy page, and
if we are careful, the race window between PageBuddy() check and page_order()
is small, and the worst thing that can happen is that we skip too much and miss
some isolation candidates. This is not that bad, as compaction can already fail
for many other reasons like parallel allocations, and those have much larger
race window.

This patch therefore makes the migration scanner obtain the buddy page order
and use it to skip the whole buddy page, if the order appears to be in the
valid range.

It's important that the page_order() is read only once, so that the value used
in the checks and in the pfn calculation is the same. But in theory the
compiler can replace the local variable by multiple inlines of page_order().
Therefore, the patch introduces page_order_unsafe() that uses ACCESS_ONCE to
prevent this.

Testing with stress-highalloc from mmtests shows a 15% reduction in number of
pages scanned by migration scanner. This change is also a prerequisite for a
later patch which is detecting when a cc->order block of pages contains
non-buddy pages that cannot be isolated, and the scanner should thus skip to
the next block immediately.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 36 +++++++++++++++++++++++++++++++-----
 mm/internal.h   | 16 +++++++++++++++-
 2 files changed, 46 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 41c7005..df0961b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -270,8 +270,15 @@ static inline bool compact_should_abort(struct compact_control *cc)
 static bool suitable_migration_target(struct page *page)
 {
 	/* If the page is a large free page, then disallow migration */
-	if (PageBuddy(page) && page_order(page) >= pageblock_order)
-		return false;
+	if (PageBuddy(page)) {
+		/*
+		 * We are checking page_order without zone->lock taken. But
+		 * the only small danger is that we skip a potentially suitable
+		 * pageblock, so it's not worth to check order for valid range.
+		 */
+		if (page_order_unsafe(page) >= pageblock_order)
+			return false;
+	}
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
 	if (migrate_async_suitable(get_pageblock_migratetype(page)))
@@ -591,11 +598,23 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			valid_page = page;
 
 		/*
-		 * Skip if free. page_order cannot be used without zone->lock
-		 * as nothing prevents parallel allocations or buddy merging.
+		 * Skip if free. We read page order here without zone lock
+		 * which is generally unsafe, but the race window is small and
+		 * the worst thing that can happen is that we skip some
+		 * potential isolation targets.
 		 */
-		if (PageBuddy(page))
+		if (PageBuddy(page)) {
+			unsigned long freepage_order = page_order_unsafe(page);
+
+			/*
+			 * Without lock, we cannot be sure that what we got is
+			 * a valid page order. Consider only values in the
+			 * valid order range to prevent low_pfn overflow.
+			 */
+			if (freepage_order > 0 && freepage_order < MAX_ORDER)
+				low_pfn += (1UL << freepage_order) - 1;
 			continue;
+		}
 
 		/*
 		 * Check may be lockless but that's ok as we recheck later.
@@ -683,6 +702,13 @@ next_pageblock:
 		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
 	}
 
+	/*
+	 * The PageBuddy() check could have potentially brought us outside
+	 * the range to be scanned.
+	 */
+	if (unlikely(low_pfn > end_pfn))
+		low_pfn = end_pfn;
+
 	acct_isolated(zone, locked, cc);
 
 	if (locked)
diff --git a/mm/internal.h b/mm/internal.h
index 2c187d2..584cd69 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -171,7 +171,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
  * general, page_zone(page)->lock must be held by the caller to prevent the
  * page from being allocated in parallel and returning garbage as the order.
  * If a caller does not hold page_zone(page)->lock, it must guarantee that the
- * page cannot be allocated or merged in parallel.
+ * page cannot be allocated or merged in parallel. Alternatively, it must
+ * handle invalid values gracefully, and use page_order_unsafe() below.
  */
 static inline unsigned long page_order(struct page *page)
 {
@@ -179,6 +180,19 @@ static inline unsigned long page_order(struct page *page)
 	return page_private(page);
 }
 
+/*
+ * Like page_order(), but for callers who cannot afford to hold the zone lock.
+ * PageBuddy() should be checked first by the caller to minimize race window,
+ * and invalid values must be handled gracefully.
+ *
+ * ACCESS_ONCE is used so that if the caller assigns the result into a local
+ * variable and e.g. tests it for valid range before using, the compiler cannot
+ * decide to remove the variable and inline the page_private(page) multiple
+ * times, potentially observing different values in the tests and the actual
+ * use of the result.
+ */
+#define page_order_unsafe(page)		ACCESS_ONCE(page_private(page))
+
 static inline bool is_cow_mapping(vm_flags_t flags)
 {
 	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
