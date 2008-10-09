Message-Id: <20081009174822.847294148@suse.de>
References: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:46 +1100
From: npiggin@suse.de
Subject: [patch 7/8] mm: write_cache_pages optimise page cleaning
Content-Disposition: inline; filename=mm-wcp-writeback-clean-opt.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In write_cache_pages, if we get stuck behind another process that is cleaning
pages, we will be forced to wait for them to finish, then perform our own
writeout (if it was redirtied during the long wait), then wait for that.

If a page under writeout is still clean, we can skip waiting for it (if we're
part of a data integrity sync, we'll be waiting for all writeout pages
afterwards, so we'll still be waiting for the other guy's write that's cleaned
the page).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -942,11 +942,20 @@ continue_unlock:
 				goto continue_unlock;
 			}
 
-			if (wbc->sync_mode != WB_SYNC_NONE)
-				wait_on_page_writeback(page);
+			if (!PageDirty(page)) {
+				/* someone wrote it for us */
+				goto continue_unlock;
+			}
+
+			if (PageWriteback(page)) {
+				if (wbc->sync_mode != WB_SYNC_NONE)
+					wait_on_page_writeback(page);
+				else
+					goto continue_unlock;
+			}
 
-			if (PageWriteback(page) ||
-			    !clear_page_dirty_for_io(page))
+			BUG_ON(PageWriteback(page));
+			if (!clear_page_dirty_for_io(page))
 				goto continue_unlock;
 
 			ret = (*writepage)(page, wbc, data);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
