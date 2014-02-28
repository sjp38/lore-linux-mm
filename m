Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 578666B006C
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 09:15:35 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id x48so600384wes.35
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:15:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bo10si1764523wjb.127.2014.02.28.06.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 06:15:33 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/6] mm: call get_pageblock_migratetype() under zone->lock where possible
Date: Fri, 28 Feb 2014 15:14:59 +0100
Message-Id: <1393596904-16537-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

Joonsoo Kim has found a theoretical race between get/set_pageblock_migratetype
which can result in wrong values being read, including values higher than
MIGRATE_TYPES, thanks to the non-synchronized get/set operations which read or
update individual bits in a loop.

My own testing with a debug patch showed that the race occurs once per mmtests'
stress-highalloc benchmark (although not necessarily in the same pageblock).
However during a development of unrelated compaction patches, I have observed
that with frequent calls to {start,undo}_isolate_page_range() the race occurs
several thousands of times and has resulted in NULL pointer dereferences in
move_freepages() and free_one_page() in places where free_list[migratetype] is
manipulated by e.g. list_move(). Further debugging confirmed that migratetype
had invalid value of 6, causing out of bounds access to the free_list array.

This shows that the race exist and while it may be extremely rare and harmless
unless page isolation is performed frequently (lower migratetypes do not
set the highest-order bit which can result in invalid value), it could get worse
if e.g. new migratetypes are added.

We want to close this race while avoiding extra overhead as much as possible,
as pageblock operations occur in fast paths and should be cheap. We observe
that all (non-init) set_pageblock_migratetype() calls are done under zone->lock
and most get_pageblock_migratetype() calls can be moved under the lock as well
since it's taken in those paths anyway.

Therefore, this patch makes get_pageblock_migratetype() safe where possible:

 - in __free_pages_ok() by moving it to free_one_page() which already locks
 - in buffered_rmqueue() by moving it inside the locked section
 - in undo_isolate_page_range() by removing the call, as the call to
   unset_migratetype_isolate() locks and calls it again anyway
 - in test_pages_isolated() by extending the locked section

The remaining unsafe calls to get_pageblock_migratetype() are dealt with in
the next patch.

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Suggested-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c     | 20 +++++++++++---------
 mm/page_isolation.c | 23 +++++++++++++----------
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d6892c..0cb41ec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -714,12 +714,16 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	spin_unlock(&zone->lock);
 }
 
-static void free_one_page(struct zone *zone, struct page *page, int order,
-				int migratetype)
+static void free_one_page(struct zone *zone, struct page *page, int order)
 {
+	int migratetype;
+
 	spin_lock(&zone->lock);
 	zone->pages_scanned = 0;
 
+	migratetype = get_pageblock_migratetype(page);
+	set_freepage_migratetype(page, migratetype);
+
 	__free_one_page(page, zone, order, migratetype);
 	if (unlikely(!is_migrate_isolate(migratetype)))
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
@@ -756,16 +760,13 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
-	int migratetype;
 
 	if (!free_pages_prepare(page, order))
 		return;
 
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
-	migratetype = get_pageblock_migratetype(page);
-	set_freepage_migratetype(page, migratetype);
-	free_one_page(page_zone(page), page, order, migratetype);
+	free_one_page(page_zone(page), page, order);
 	local_irq_restore(flags);
 }
 
@@ -1387,7 +1388,7 @@ void free_hot_cold_page(struct page *page, int cold)
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
 		if (unlikely(is_migrate_isolate(migratetype))) {
-			free_one_page(zone, page, 0, migratetype);
+			free_one_page(zone, page, 0);
 			goto out;
 		}
 		migratetype = MIGRATE_MOVABLE;
@@ -1570,11 +1571,12 @@ again:
 		}
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);
+		if (page)
+			__mod_zone_freepage_state(zone, -(1 << order),
+					  get_pageblock_migratetype(page));
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
-		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_pageblock_migratetype(page));
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index d1473b2..d66f8ce 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -157,9 +157,8 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (!page || get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
-			continue;
-		unset_migratetype_isolate(page, migratetype);
+		if (page)
+			unset_migratetype_isolate(page, migratetype);
 	}
 	return 0;
 }
@@ -223,9 +222,16 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 {
 	unsigned long pfn, flags;
 	struct page *page;
+	struct page *first_page;
 	struct zone *zone;
-	int ret;
+	int ret = 0;
+
+	first_page = __first_valid_page(start_pfn, end_pfn - start_pfn);
+	if (!first_page)
+		return -EBUSY;
 
+	zone = page_zone(first_page);
+	spin_lock_irqsave(&zone->lock, flags);
 	/*
 	 * Note: pageblock_nr_pages != MAX_ORDER. Then, chunks of free pages
 	 * are not aligned to pageblock_nr_pages.
@@ -234,16 +240,13 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
 		if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
-			break;
+			goto unlock_out;
 	}
-	page = __first_valid_page(start_pfn, end_pfn - start_pfn);
-	if ((pfn < end_pfn) || !page)
-		return -EBUSY;
+
 	/* Check all pages are free or marked as ISOLATED */
-	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lock, flags);
 	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
 						skip_hwpoisoned_pages);
+unlock_out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
 }
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
