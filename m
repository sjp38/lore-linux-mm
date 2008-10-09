Message-Id: <20081009174822.621353840@suse.de>
References: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:44 +1100
From: npiggin@suse.de
Subject: [patch 5/8] mm: write_cache_pages integrity fix
Content-Disposition: inline; filename=mm-wcp-integrity-fix.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In write_cache_pages, nr_to_write is heeded even for data-integrity syncs, so
the function will return success after writing out nr_to_write pages, even if
that was not sufficient to guarantee data integrity.

The callers tend to set it to values that could break data interity semantics
easily in practice. For example, nr_to_write can be set to mapping->nr_pages *
2, however if a file has a single, dirty page, then fsync is called, subsequent
pages might be concurrently added and dirtied, then write_cache_pages might
writeout two of these newly dirty pages, while not writing out the old page
that should have been written out.

Fix this by ignoring nr_to_write if it is a data integrity sync.

This is a data interity bug.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
The reason this has been done in the past is to avoid stalling sync operations
behind page dirtiers.

 "If a file has one dirty page at offset 1000000000000000 then someone
  does an fsync() and someone else gets in first and starts madly writing
  pages at offset 0, we want to write that page at 1000000000000000. 
  Somehow."

What we to today is return success after an arbitrary amount of pages are
written, whether or not we have provided the data-integrity semantics that
the caller has asked for. Even this doesn't actually fix all stall cases
completely: in the above situation, if the file has a huge number of pages
in pagecache (but not dirty), then mapping->nrpages is going to be huge,
even if pages are being dirtied.

This change does indeed make the possibility of long stalls lager, and that's
not a good thing, but lying about data integrity is even worse. We have to
either perform the sync, or return -ELINUXISLAME so at least the caller knows
what has happened.

There are subsequent competing approaches in the works to solve the stall
problems properly, without compromising data integrity.

Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -951,8 +951,10 @@ again:
 				done = 1;
 				break;
 			}
-			if (--(wbc->nr_to_write) <= 0)
-				done = 1;
+			if (wbc->sync_mode == WB_SYNC_NONE) {
+				if (--(wbc->nr_to_write) <= 0)
+					done = 1;
+			}
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {
 				wbc->encountered_congestion = 1;
 				done = 1;
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -209,7 +209,7 @@ int __filemap_fdatawrite_range(struct ad
 	int ret;
 	struct writeback_control wbc = {
 		.sync_mode = sync_mode,
-		.nr_to_write = mapping->nrpages * 2,
+		.nr_to_write = LONG_MAX,
 		.range_start = start,
 		.range_end = end,
 	};

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
