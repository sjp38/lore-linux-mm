Message-Id: <20081009174822.516911376@suse.de>
References: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:43 +1100
From: npiggin@suse.de
Subject: [patch 4/8] mm: write_cache_pages type overflow fix
Content-Disposition: inline; filename=mm-wcp-type-overflow-fix.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In the range_cont case, range_start is set to index << PAGE_CACHE_SHIFT, but
index is a pgoff_t and range_start is loff_t, so we can get truncation of the
value on 32-bit platforms. Fix this by adding the standard loff_t cast.

This is a data interity bug (depending on how range_cont is used).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -976,7 +976,7 @@ again:
 		mapping->writeback_index = index;
 
 	if (wbc->range_cont)
-		wbc->range_start = index << PAGE_CACHE_SHIFT;
+		wbc->range_start = (loff_t)index << PAGE_CACHE_SHIFT;
 	return ret;
 }
 EXPORT_SYMBOL(write_cache_pages);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
