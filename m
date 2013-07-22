Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6286E6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 14:51:45 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 23 Jul 2013 00:13:14 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6E300E0053
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 00:21:37 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6MIqShB29687972
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 00:22:28 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6MIpa2K016205
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 04:51:37 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm: Restructure free-page stealing code and fix a bug
Date: Tue, 23 Jul 2013 00:18:06 +0530
Message-ID: <20130722184805.9573.78514.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, minchan@kernel.org, cody@linux.vnet.ibm.com
Cc: rostedt@goodmis.org, jiang.liu@huawei.com, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The free-page stealing code in __rmqueue_fallback() is somewhat hard to
follow, and has an incredible amount of subtlety hidden inside!

First off, there is a minor bug in the reporting of change-of-ownership of
pageblocks. Under some conditions, we try to move upto 'pageblock_nr_pages'
no. of pages to the preferred allocation list. But we change the ownership
of that pageblock to the preferred type only if we manage to successfully
move atleast half of that pageblock (or if page_group_by_mobility_disabled
is set).

However, the current code ignores the latter part and sets the 'migratetype'
variable to the preferred type, irrespective of whether we actually changed
the pageblock migratetype of that block or not. So, the page_alloc_extfrag
tracepoint can end up printing incorrect info (i.e., 'change_ownership'
might be shown as 1 when it must have been 0).

So fixing this involves moving the update of the 'migratetype' variable to
the right place. But looking closer, we observe that the 'migratetype' variable
is used subsequently for checks such as "is_migrate_cma()". Obviously the
intent there is to check if the *fallback* type is MIGRATE_CMA, but since we
already set the 'migratetype' variable to start_migratetype, we end up checking
if the *preferred* type is MIGRATE_CMA!!

To make things more interesting, this actually doesn't cause a bug in practice,
because we never change *anything* if the fallback type is CMA.

So, restructure the code in such a way that it is trivial to understand what
is going on, and also fix the above mentioned bug. And while at it, also add a
comment explaining the subtlety behind the migratetype used in the call to
expand().

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   96 ++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 60 insertions(+), 36 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..027d417 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1007,6 +1007,53 @@ static void change_pageblock_range(struct page *pageblock_page,
 	}
 }
 
+/*
+ * If breaking a large block of pages, move all free pages to the preferred
+ * allocation list. If falling back for a reclaimable kernel allocation, be
+ * more aggressive about taking ownership of free pages.
+ *
+ * On the other hand, never change migration type of MIGRATE_CMA pageblocks
+ * nor move CMA pages to different free lists. We don't want unmovable pages
+ * to be allocated from MIGRATE_CMA areas.
+ *
+ * Returns the new migratetype of the pageblock (or the same old migratetype
+ * if it was unchanged).
+ */
+static inline int try_to_steal_freepages(struct zone *zone, struct page *page,
+					 int start_type, int fallback_type)
+{
+	int current_order = page_order(page);
+
+	if (is_migrate_cma(fallback_type))
+		return fallback_type;
+
+	/* Take ownership for orders >= pageblock_order */
+	if (current_order >= pageblock_order) {
+		change_pageblock_range(page, current_order, start_type);
+		return start_type;
+	}
+
+	if (current_order >= pageblock_order / 2 ||
+	    start_type == MIGRATE_RECLAIMABLE ||
+	    page_group_by_mobility_disabled) {
+
+		int pages;
+
+		pages = move_freepages_block(zone, page, start_type);
+
+		/* Claim the whole block if over half of it is free */
+		if (pages >= (1 << (pageblock_order-1)) ||
+				page_group_by_mobility_disabled) {
+
+			set_pageblock_migratetype(page, start_type);
+			return start_type;
+		}
+
+	}
+
+	return fallback_type;
+}
+
 /* Remove an element from the buddy allocator from the fallback list */
 static inline struct page *
 __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
@@ -1014,7 +1061,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 	struct free_area * area;
 	int current_order;
 	struct page *page;
-	int migratetype, i;
+	int migratetype, new_type, i;
 
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
@@ -1034,51 +1081,28 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 					struct page, lru);
 			area->nr_free--;
 
-			/*
-			 * If breaking a large block of pages, move all free
-			 * pages to the preferred allocation list. If falling
-			 * back for a reclaimable kernel allocation, be more
-			 * aggressive about taking ownership of free pages
-			 *
-			 * On the other hand, never change migration
-			 * type of MIGRATE_CMA pageblocks nor move CMA
-			 * pages on different free lists. We don't
-			 * want unmovable pages to be allocated from
-			 * MIGRATE_CMA areas.
-			 */
-			if (!is_migrate_cma(migratetype) &&
-			    (current_order >= pageblock_order / 2 ||
-			     start_migratetype == MIGRATE_RECLAIMABLE ||
-			     page_group_by_mobility_disabled)) {
-				int pages;
-				pages = move_freepages_block(zone, page,
-								start_migratetype);
-
-				/* Claim the whole block if over half of it is free */
-				if (pages >= (1 << (pageblock_order-1)) ||
-						page_group_by_mobility_disabled)
-					set_pageblock_migratetype(page,
-								start_migratetype);
-
-				migratetype = start_migratetype;
-			}
+			new_type = try_to_steal_freepages(zone, page,
+							  start_migratetype,
+							  migratetype);
 
 			/* Remove the page from the freelists */
 			list_del(&page->lru);
 			rmv_page_order(page);
 
-			/* Take ownership for orders >= pageblock_order */
-			if (current_order >= pageblock_order &&
-			    !is_migrate_cma(migratetype))
-				change_pageblock_range(page, current_order,
-							start_migratetype);
-
+			/*
+			 * Borrow the excess buddy pages as well, irrespective
+			 * of whether we stole freepages, or took ownership of
+			 * the pageblock or not.
+			 *
+			 * Exception: When borrowing from MIGRATE_CMA, release
+			 * the excess buddy pages to CMA itself.
+			 */
 			expand(zone, page, order, current_order, area,
 			       is_migrate_cma(migratetype)
 			     ? migratetype : start_migratetype);
 
 			trace_mm_page_alloc_extfrag(page, order, current_order,
-				start_migratetype, migratetype);
+				start_migratetype, new_type);
 
 			return page;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
