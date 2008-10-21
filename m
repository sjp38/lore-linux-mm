From: Johannes Weiner <hannes@saeurebad.de>
Subject: [rfc] mm: more likely reclaim MADV_SEQUENTIAL mappings
Date: Tue, 21 Oct 2008 12:32:25 +0200
Message-ID: <87d4hugrwm.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

File pages mapped only in sequentially read mappings are perfect
reclaim canditates.

This makes MADV_SEQUENTIAL mappings behave like weak references, its
pages will be reclaimed unless they have a strong reference from a
normal mapping as well.

The patch changes the reclaim and the unmap path where they check if
the page has been referenced.  In both cases, accesses through
sequentially read mappings will be ignored.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

I'm afraid this is now quite a bit more aggressive than the earlier
version.  When the fault path did a mark_page_access(), we wouldn't
reclaim a page when it has been faulted into several MADV_SEQUENTIAL
mappings but now we ignore *every* activity through such a mapping.

What do you think?

Perhaps we should note a reference if there are two or more accesses
through sequentially read mappings?

 mm/memory.c |    3 ++-
 mm/rmap.c   |   13 +++++++++++--
 2 files changed, 13 insertions(+), 3 deletions(-)

--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -337,8 +337,17 @@ static int page_referenced_one(struct pa
 		goto out_unmap;
 	}
 
-	if (ptep_clear_flush_young_notify(vma, address, pte))
-		referenced++;
+	if (ptep_clear_flush_young_notify(vma, address, pte)) {
+		/*
+		 * Don't treat a reference through a sequentially read
+		 * mapping as such.  If the page has been used in
+		 * another mapping, we will catch it; if this other
+		 * mapping is already gone, the unmap path will have
+		 * set PG_referenced or activated the page.
+		 */
+		if (!VM_SequentialReadHint(vma))
+			referenced++;
+	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -759,7 +759,8 @@ static unsigned long zap_pte_range(struc
 			else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
-				if (pte_young(ptent))
+				if (pte_young(ptent) &&
+						!VM_SequentialReadHint(vma))
 					mark_page_accessed(page);
 				file_rss--;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
