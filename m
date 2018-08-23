Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DED926B2798
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 22:29:05 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 90-v6so1790520pla.18
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 19:29:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4-v6sor955661pgh.210.2018.08.22.19.29.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 19:29:03 -0700 (PDT)
Subject: [RFC PATCH] mm: Streamline deferred_init_pages and
 deferred_free_pages
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 22 Aug 2018 19:29:02 -0700
Message-ID: <20180823022116.4536.6104.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, pasha.tatashin@oracle.com, vbabka@suse.cz, mhocko@kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

>From what I could tell the deferred_init_pages and deferred_free_pages were
running less than optimally as there were a number of checks that seemed
like they only needed to be run once per page block instead of being run
per page.

For example there is the pfn_valid check which either needs to be run for
every page if the architecture supports holes, or once per page block if it
doesn't. We can get around needing to perform these checks by just using
pfn_valid_within within the loop and running pfn_valid only on the first
access to any given page.

Also in the case of either a node ID mismatch or the pfn_valid check
failing on an architecture that doesn't support holes it doesn't make sense
to initialize pages for an invalid page block. So to skip over those pages
I have opted to OR in the page block mask to allow us to skip to the end of
a given page block.

With this patch I am seeing a modest improvement in boot time as shown
below on a system with 64GB on each node:
-- before --
[    2.945572] node 0 initialised, 15432905 pages in 636ms
[    2.968575] node 1 initialised, 15957078 pages in 659ms

-- after --
[    2.770127] node 0 initialised, 15432905 pages in 457ms
[    2.785129] node 1 initialised, 15957078 pages in 472ms

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

I'm putting this out as an RFC in order to determine if the assumptions I
have made are valid. I wasn't certain if they were correct but the
definition and usage of deferred_pfn_valid just didn't seem right to me
since it would result in us possibly skipping a head page, and then still
initializing and freeing all of the tail pages.

 mm/page_alloc.c |  152 +++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 101 insertions(+), 51 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 15ea511fb41c..0aca48b377fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1410,27 +1410,17 @@ void clear_zone_contiguous(struct zone *zone)
 static void __init deferred_free_range(unsigned long pfn,
 				       unsigned long nr_pages)
 {
-	struct page *page;
-	unsigned long i;
+	struct page *page, *last_page;
 
 	if (!nr_pages)
 		return;
 
 	page = pfn_to_page(pfn);
+	last_page = page + nr_pages;
 
-	/* Free a large naturally-aligned chunk if possible */
-	if (nr_pages == pageblock_nr_pages &&
-	    (pfn & (pageblock_nr_pages - 1)) == 0) {
-		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-		__free_pages_boot_core(page, pageblock_order);
-		return;
-	}
-
-	for (i = 0; i < nr_pages; i++, page++, pfn++) {
-		if ((pfn & (pageblock_nr_pages - 1)) == 0)
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+	do {
 		__free_pages_boot_core(page, 0);
-	}
+	} while (++page < last_page);
 }
 
 /* Completion tracking for deferred_init_memmap() threads */
@@ -1446,14 +1436,10 @@ static inline void __init pgdat_init_report_one_done(void)
 /*
  * Returns true if page needs to be initialized or freed to buddy allocator.
  *
- * First we check if pfn is valid on architectures where it is possible to have
- * holes within pageblock_nr_pages. On systems where it is not possible, this
- * function is optimized out.
+ * First we check if a current large page is valid by only checking the validity
+ * of the first pfn we have access to in the page.
  *
- * Then, we check if a current large page is valid by only checking the validity
- * of the head pfn.
- *
- * Finally, meminit_pfn_in_nid is checked on systems where pfns can interleave
+ * Then, meminit_pfn_in_nid is checked on systems where pfns can interleave
  * within a node: a pfn is between start and end of a node, but does not belong
  * to this memory node.
  */
@@ -1461,9 +1447,7 @@ static inline void __init pgdat_init_report_one_done(void)
 deferred_pfn_valid(int nid, unsigned long pfn,
 		   struct mminit_pfnnid_cache *nid_init_state)
 {
-	if (!pfn_valid_within(pfn))
-		return false;
-	if (!(pfn & (pageblock_nr_pages - 1)) && !pfn_valid(pfn))
+	if (!pfn_valid(pfn))
 		return false;
 	if (!meminit_pfn_in_nid(pfn, nid, nid_init_state))
 		return false;
@@ -1477,24 +1461,53 @@ static inline void __init pgdat_init_report_one_done(void)
 static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
 				       unsigned long end_pfn)
 {
-	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
-	unsigned long nr_free = 0;
+	struct mminit_pfnnid_cache nid_init_state = { };
 
-	for (; pfn < end_pfn; pfn++) {
-		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
-			deferred_free_range(pfn - nr_free, nr_free);
-			nr_free = 0;
-		} else if (!(pfn & nr_pgmask)) {
-			deferred_free_range(pfn - nr_free, nr_free);
-			nr_free = 1;
-			touch_nmi_watchdog();
-		} else {
-			nr_free++;
+	while (pfn < end_pfn) {
+		unsigned long aligned_pfn, nr_free;
+
+		/*
+		 * Determine if our first pfn is valid, use this as a
+		 * representative value for the page block. Store the value
+		 * as either 0 or 1 to nr_free.
+		 *
+		 * If the pfn itself is valid, but this page block isn't
+		 * then we can assume the issue is the entire page block
+		 * and it can be skipped.
+		 */
+		nr_free = !!deferred_pfn_valid(nid, pfn, &nid_init_state);
+		if (!nr_free && pfn_valid_within(pfn))
+			pfn |= nr_pgmask;
+
+		/*
+		 * Move to next pfn and align the end of our next section
+		 * to process with the end of the block. If we were given
+		 * the end of a block to process we will do nothing in the
+		 * loop below.
+		 */
+		pfn++;
+		aligned_pfn = min(__ALIGN_MASK(pfn, nr_pgmask), end_pfn);
+
+		for (; pfn < aligned_pfn; pfn++) {
+			if (!pfn_valid_within(pfn)) {
+				deferred_free_range(pfn - nr_free, nr_free);
+				nr_free = 0;
+			} else {
+				nr_free++;
+			}
 		}
+
+		/* Free a large naturally-aligned chunk if possible */
+		if (nr_free == pageblock_nr_pages)
+			__free_pages_boot_core(pfn_to_page(pfn - nr_free),
+					       pageblock_order);
+		else
+			deferred_free_range(pfn - nr_free, nr_free);
+
+		/* Let the watchdog know we are still alive */
+		touch_nmi_watchdog();
 	}
-	/* Free the last block of pages to allocator */
-	deferred_free_range(pfn - nr_free, nr_free);
 }
 
 /*
@@ -1506,25 +1519,62 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 						 unsigned long pfn,
 						 unsigned long end_pfn)
 {
-	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
+	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pages = 0;
-	struct page *page = NULL;
 
-	for (; pfn < end_pfn; pfn++) {
-		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
-			page = NULL;
-			continue;
-		} else if (!page || !(pfn & nr_pgmask)) {
+	while (pfn < end_pfn) {
+		unsigned long aligned_pfn;
+		struct page *page = NULL;
+
+		/*
+		 * Determine if our first pfn is valid, use this as a
+		 * representative value for the page block.
+		 */
+		if (deferred_pfn_valid(nid, pfn, &nid_init_state)) {
 			page = pfn_to_page(pfn);
-			touch_nmi_watchdog();
-		} else {
-			page++;
+			__init_single_page(page++, pfn, zid, nid);
+			nr_pages++;
+
+			if (!(pfn & nr_pgmask))
+				set_pageblock_migratetype(page,
+							  MIGRATE_MOVABLE);
+		} else if (pfn_valid_within(pfn)) {
+			/*
+			 * If the issue is the node or is not specific to
+			 * this individual pfn we can just jump to the end
+			 * of the page block and skip the entire block.
+			 */
+			pfn |= nr_pgmask;
 		}
-		__init_single_page(page, pfn, zid, nid);
-		nr_pages++;
+
+		/*
+		 * Move to next pfn and align the end of our next section
+		 * to process with the end of the block. If we were given
+		 * the end of a block to process we will do nothing in the
+		 * loop below.
+		 */
+		pfn++;
+		aligned_pfn = min(__ALIGN_MASK(pfn, nr_pgmask), end_pfn);
+
+		for (; pfn < aligned_pfn; pfn++) {
+			if (!pfn_valid_within(pfn)) {
+				page = NULL;
+				continue;
+			}
+
+			if (!page)
+				page = pfn_to_page(pfn);
+
+			__init_single_page(page++, pfn, zid, nid);
+			nr_pages++;
+		}
+
+		/* Let the watchdog know we are still alive */
+		touch_nmi_watchdog();
 	}
-	return (nr_pages);
+
+	return nr_pages;
 }
 
 /* Initialise remaining memory on a node */
