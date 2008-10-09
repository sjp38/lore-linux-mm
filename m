Message-Id: <20081009174822.406363946@suse.de>
References: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:42 +1100
From: npiggin@suse.de
Subject: [patch 3/8] mm: write_cache_pages writepage error fix
Content-Disposition: inline; filename=mm-wcp-writepage-error-fix.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In write_cache_pages, if ret signals a real error, but we still have some pages
left in the pagevec, done would be set to 1, but the remaining pages would
continue to be processed and ret will be overwritten in the process. It could
easily be overwritten with success, and thus success will be returned even if
there is an error. Thus the caller is told all writes succeeded, wheras in
reality some did not.

Fix this by bailing immediately if there is an error, and retaining the first
error code.

This is a data interity bug.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -941,13 +941,17 @@ again:
 			}
 
 			ret = (*writepage)(page, wbc, data);
-			if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE)) {
-				/* Must retry the write */
-				unlock_page(page);
-				ret = 0;
-				goto again;
+			if (unlikely(ret)) {
+				if (ret == AOP_WRITEPAGE_ACTIVATE) {
+					/* Must retry the write */
+					unlock_page(page);
+					ret = 0;
+					goto again;
+				}
+				done = 1;
+				break;
 			}
-			if (ret || (--(wbc->nr_to_write) <= 0))
+			if (--(wbc->nr_to_write) <= 0)
 				done = 1;
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {
 				wbc->encountered_congestion = 1;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
