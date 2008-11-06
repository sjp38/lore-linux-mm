Date: Thu, 6 Nov 2008 10:55:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH -v2] mm: more likely reclaim MADV_SEQUENTIAL mappings
Message-ID: <20081106095513.GA4639@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

File pages mapped only in sequentially read mappings are perfect
reclaim canditates.

This patch makes these mappings behave like weak references, their
pages will be reclaimed unless they have a strong reference from a
normal mapping as well.

It changes the reclaim and the unmap path where they check if the page
has been referenced.  In both cases, accesses through sequentially
read mappings will be ignored.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Nick Piggin <npiggin@suse.de>
---

II: add likely()s to mitigate the extra branches a bit as to Nick's
    suggestion

Benchmark results from KOSAKI Motohiro:

    http://marc.info/?l=linux-mm&m=122485301925098&w=2

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
+		if (likely(!VM_SequentialReadHint(vma)))
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
+				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
 				file_rss--;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
