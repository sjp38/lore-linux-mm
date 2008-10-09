Message-Id: <20081009174822.298327659@suse.de>
References: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:41 +1100
From: npiggin@suse.de
Subject: [patch 2/8] mm: write_cache_pages AOP_WRITEPAGE_ACTIVATE fix
Content-Disposition: inline; filename=mm-wcp-writepage-activate-fix.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In write_cache_pages, if AOP_WRITEPAGE_ACTIVATE is returned, the filesystem is
calling on us to drop the page lock and retry, however the existing code would
just skip that page regardless of whether or not it was a data interity
operation. Change this to always retry such a result.

This is a data interity bug.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -916,6 +916,7 @@ retry:
 			 * swizzled back from swapper_space to tmpfs file
 			 * mapping
 			 */
+again:
 			lock_page(page);
 
 			if (unlikely(page->mapping != mapping)) {
@@ -940,10 +941,11 @@ retry:
 			}
 
 			ret = (*writepage)(page, wbc, data);
-
 			if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE)) {
+				/* Must retry the write */
 				unlock_page(page);
 				ret = 0;
+				goto again;
 			}
 			if (ret || (--(wbc->nr_to_write) <= 0))
 				done = 1;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
