Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9216B003B
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 05:26:37 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id q58so1968775wes.30
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:26:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o11si29411631wjw.72.2014.06.09.02.26.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 02:26:34 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 06/10] mm, compaction: skip buddy pages by their order in the migrate scanner
Date: Mon,  9 Jun 2014 11:26:18 +0200
Message-Id: <1402305982-6928-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

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

Preliminary results with stress-highalloc from mmtests show a 10% reduction in
number of pages scanned by migration scanner. This change is also important to
later allow detecting when a cc->order block of pages cannot be compacted, and
the scanner should skip to the next block instead of wasting time.

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
V2: fix low_pfn > end_pfn check; comments
    kept page_order_unsafe() approach for now

 mm/compaction.c | 25 ++++++++++++++++++++++---
 mm/internal.h   | 20 +++++++++++++++++++-
 2 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 58dfaaa..11c0926 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -626,11 +626,23 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		}
 
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
@@ -718,6 +730,13 @@ next_pageblock:
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
index 4659e8e..584d04f 100644
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
@@ -179,6 +180,23 @@ static inline unsigned long page_order(struct page *page)
 	return page_private(page);
 }
 
+/*
+ * Like page_order(), but for callers who cannot afford to hold the zone lock,
+ * and handle invalid values gracefully. ACCESS_ONCE is used so that if the
+ * caller assigns the result into a local variable and e.g. tests it for valid
+ * range  before using, the compiler cannot decide to remove the variable and
+ * inline the function multiple times, potentially observing different values
+ * in the tests and the actual use of the result.
+ */
+static inline unsigned long page_order_unsafe(struct page *page)
+{
+	/*
+	 * PageBuddy() should be checked by the caller to minimize race window,
+	 * and invalid values must be handled gracefully.
+	 */
+	return ACCESS_ONCE(page_private(page));
+}
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
