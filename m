Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id BD1296B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 11:06:55 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on s390
Date: Mon, 22 Oct 2012 17:06:46 +0200
Message-Id: <1350918406-11369-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org, Hugh Dickins <hughd@google.com>

On s390 any write to a page (even from kernel itself) sets architecture
specific page dirty bit. Thus when a page is written to via buffered write, HW
dirty bit gets set and when we later map and unmap the page, page_remove_rmap()
finds the dirty bit and calls set_page_dirty().

Dirtying of a page which shouldn't be dirty can cause all sorts of problems to
filesystems. The bug we observed in practice is that buffers from the page get
freed, so when the page gets later marked as dirty and writeback writes it, XFS
crashes due to an assertion BUG_ON(!PagePrivate(page)) in page_buffers() called
from xfs_count_page_state().

Similar problem can also happen when zero_user_segment() call from
xfs_vm_writepage() (or block_write_full_page() for that matter) set the
hardware dirty bit during writeback, later buffers get freed, and then page
unmapped.

Fix the issue by ignoring s390 HW dirty bit for page cache pages of mappings
with mapping_cap_account_dirty(). This is safe because for such mappings when a
page gets marked as writeable in PTE it is also marked dirty in do_wp_page() or
do_page_fault(). When the dirty bit is cleared by clear_page_dirty_for_io(),
the page gets writeprotected in page_mkclean(). So pagecache page is writeable
if and only if it is dirty.

Thanks to Hugh Dickins <hughd@google.com> for pointing out mapping has to have
mapping_cap_account_dirty() for things to work and proposing a cleaned up
variant of the patch.

The patch has survived about two hours of running fsx-linux on tmpfs while
heavily swapping and several days of running on out build machines where the
original problem was triggered.

CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
CC: Mel Gorman <mgorman@suse.de>
CC: linux-s390@vger.kernel.org
CC: Hugh Dickins <hughd@google.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/rmap.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 7df7984..2ee1ef0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -56,6 +56,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
 #include <linux/hugetlb.h>
+#include <linux/backing-dev.h>
 
 #include <asm/tlbflush.h>
 
@@ -926,11 +927,8 @@ int page_mkclean(struct page *page)
 
 	if (page_mapped(page)) {
 		struct address_space *mapping = page_mapping(page);
-		if (mapping) {
+		if (mapping)
 			ret = page_mkclean_file(mapping, page);
-			if (page_test_and_clear_dirty(page_to_pfn(page), 1))
-				ret = 1;
-		}
 	}
 
 	return ret;
@@ -1116,6 +1114,7 @@ void page_add_file_rmap(struct page *page)
  */
 void page_remove_rmap(struct page *page)
 {
+	struct address_space *mapping = page_mapping(page);
 	bool anon = PageAnon(page);
 	bool locked;
 	unsigned long flags;
@@ -1138,8 +1137,19 @@ void page_remove_rmap(struct page *page)
 	 * this if the page is anon, so about to be freed; but perhaps
 	 * not if it's in swapcache - there might be another pte slot
 	 * containing the swap entry, but page not yet written to swap.
+	 *
+	 * And we can skip it on file pages, so long as the filesystem
+	 * participates in dirty tracking; but need to catch shm and tmpfs
+	 * and ramfs pages which have been modified since creation by read
+	 * fault.
+	 *
+	 * Note that mapping must be decided above, before decrementing
+	 * mapcount (which luckily provides a barrier): once page is unmapped,
+	 * it could be truncated and page->mapping reset to NULL at any moment.
+	 * Note also that we are relying on page_mapping(page) to set mapping
+	 * to &swapper_space when PageSwapCache(page).
 	 */
-	if ((!anon || PageSwapCache(page)) &&
+	if (mapping && !mapping_cap_account_dirty(mapping) &&
 	    page_test_and_clear_dirty(page_to_pfn(page), 1))
 		set_page_dirty(page);
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
