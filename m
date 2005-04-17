From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16994.40677.105697.817303@gargle.gargle.HOWL>
Date: Sun, 17 Apr 2005 21:37:41 +0400
Subject: [PATCH]: VM 6/8 page_referenced(): move dirty
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

transfer dirtiness from pte to the struct page in page_referenced(). This
makes pages dirtied through mmap "visible" to the file system, that can write
them out through ->writepages() (otherwise pages are written from
->writepage() from tail of the inactive list).

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 mm/rmap.c   |    9 +++++++++
 mm/vmscan.c |    4 ----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff -puN mm/rmap.c~page_referenced-move-dirty mm/rmap.c
--- bk-linux/mm/rmap.c~page_referenced-move-dirty	2005-04-17 17:52:51.000000000 +0400
+++ bk-linux-nikita/mm/rmap.c	2005-04-17 17:52:51.000000000 +0400
@@ -298,15 +298,24 @@ static int page_referenced_one(struct pa
 
 	pte = page_check_address(page, mm, address);
 	if (!IS_ERR(pte)) {
+		int dirty;
+
 		if (ptep_clear_flush_young(vma, address, pte))
 			referenced++;
 
 		if (mm != current->mm && !ignore_token && has_swap_token(mm))
 			referenced++;
 
+		/*
+		 * transfer dirtiness from pte to the page, while we are here
+		 */
+		dirty = ptep_test_and_clear_dirty(vma, address, pte);
+
 		(*mapcount)--;
 		pte_unmap(pte);
 		spin_unlock(&mm->page_table_lock);
+		if (dirty)
+			set_page_dirty(page);
 	}
 out:
 	return referenced;
diff -puN mm/vmscan.c~page_referenced-move-dirty mm/vmscan.c
--- bk-linux/mm/vmscan.c~page_referenced-move-dirty	2005-04-17 17:52:51.000000000 +0400
+++ bk-linux-nikita/mm/vmscan.c	2005-04-17 17:52:51.000000000 +0400
@@ -936,10 +936,6 @@ refill_inactive_zone(struct zone *zone, 
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
-		/*
-		 * probably it would be useful to transfer dirty bit from pte
-		 * to the @page here.
-		 */
 		if (page_mapped(page)) {
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
