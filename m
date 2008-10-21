Date: Tue, 21 Oct 2008 09:25:55 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: dont mark_page_accessed in fault path
Message-ID: <20081021072555.GA3237@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@saeurebad.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Doing a mark_page_accessed at fault-time, then doing SetPageReferenced at
unmap-time if the pte is young has a number of problems.

mark_page_accessed is supposed to be roughly the equivalent of a young pte
for unmapped references. Unfortunately it doesn't come with any context:
after being called, reclaim doesn't know who or why the page was touched.

So calling mark_page_accessed not only adds extra lru or PG_referenced
manipulations for pages that are already going to have pte_young ptes anyway,
but it also adds these references which are difficult to work with from the
context of vma specific references (eg. MADV_SEQUENTIAL pte_young may not
wish to contribute to the page being referenced).

Then, simply doing SetPageReferenced when zapping a pte and finding it is
young, is not a really good solution either. SetPageReferenced does not
correctly promote the page to the active list for example. So after removing
mark_page_accessed from the fault path, several mmap()+touch+munmap() would
have a very different result from several read(2) calls for example, which
is not really desirable.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -758,7 +758,7 @@ static unsigned long zap_pte_range(struc
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent))
-					SetPageReferenced(page);
+					mark_page_accessed(page);
 				file_rss--;
 			}
 			page_remove_rmap(page, vma);
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1530,7 +1530,6 @@ retry_find:
 	/*
 	 * Found the page and have a reference on it.
 	 */
-	mark_page_accessed(page);
 	ra->prev_pos = (loff_t)page->index << PAGE_CACHE_SHIFT;
 	vmf->page = page;
 	return ret | VM_FAULT_LOCKED;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
