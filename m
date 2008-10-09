Message-Id: <20081009174822.192685322@suse.de>
References: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:40 +1100
From: npiggin@suse.de
Subject: [patch 1/8] mm: write_cache_pages cyclic fix
Content-Disposition: inline; filename=mm-wcp-cyclic-fix.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In write_cache_pages, scanned == 1 is supposed to mean that cyclic writeback
has circled through zero, thus we should not circle again. However it gets set
to 1 after the first successful pagevec lookup. This leads to cases where not
enough data gets written.

Counterexample: file with first 10 pages dirty, writeback_index == 5,
nr_to_write == 10. Then the 5 last pages will be found, and scanned will be set
to 1, after writing those out, we will not cycle back to get the first 5.

Rework this logic, now we'll always cycle unless we started off from index 0.
When cycling, only write out as far as 1 page before the start page from the
first cycle (so we don't write parts of the file twice).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -872,9 +872,10 @@ int write_cache_pages(struct address_spa
 	int done = 0;
 	struct pagevec pvec;
 	int nr_pages;
+	pgoff_t writeback_index;
 	pgoff_t index;
 	pgoff_t end;		/* Inclusive */
-	int scanned = 0;
+	int cycled;
 	int range_whole = 0;
 
 	if (wbc->nonblocking && bdi_write_congested(bdi)) {
@@ -884,14 +885,19 @@ int write_cache_pages(struct address_spa
 
 	pagevec_init(&pvec, 0);
 	if (wbc->range_cyclic) {
-		index = mapping->writeback_index; /* Start from prev offset */
+		writeback_index = mapping->writeback_index; /* prev offset */
+		index = writeback_index;
+		if (index == 0)
+			cycled = 1;
+		else
+			cycled = 0;
 		end = -1;
 	} else {
 		index = wbc->range_start >> PAGE_CACHE_SHIFT;
 		end = wbc->range_end >> PAGE_CACHE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
-		scanned = 1;
+		cycled = 1; /* ignore range_cyclic tests */
 	}
 retry:
 	while (!done && (index <= end) &&
@@ -900,7 +906,6 @@ retry:
 					      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1))) {
 		unsigned i;
 
-		scanned = 1;
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
@@ -918,7 +923,8 @@ retry:
 				continue;
 			}
 
-			if (!wbc->range_cyclic && page->index > end) {
+			if (page->index > end) {
+				/* Can't be range_cyclic: end == -1 there */
 				done = 1;
 				unlock_page(page);
 				continue;
@@ -949,13 +955,15 @@ retry:
 		pagevec_release(&pvec);
 		cond_resched();
 	}
-	if (!scanned && !done) {
+	if (!cycled) {
 		/*
+		 * range_cyclic:
 		 * We hit the last page and there is more work to be done: wrap
 		 * back to the start of the file
 		 */
-		scanned = 1;
+		cycled = 1;
 		index = 0;
+		end = writeback_index - 1;
 		goto retry;
 	}
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
