Date: Wed, 15 Oct 2008 16:22:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-more-likely-reclaim-madv_sequential-mappings.patch
Message-Id: <20081015162232.f673fa59.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

I have a note here that this patch needs better justification.  But the
changelog looks good and there are pretty graphs, so maybe my note is stale.

Can people please check it?

Thanks.




From: Johannes Weiner <hannes@saeurebad.de>

File pages accessed only once through sequential-read mappings between
fault and scan time are perfect candidates for reclaim.

This patch makes page_referenced() ignore these singular references and
the pages stay on the inactive list where they likely fall victim to the
next reclaim phase.

Already activated pages are still treated normally.  If they were accessed
multiple times and therefor promoted to the active list, we probably want
to keep them.

Benchmarks show that big (relative to the system's memory) MADV_SEQUENTIAL
mappings read sequentially cause much less kernel activity.  Especially
less LRU moving-around because we never activate read-once pages in the
first place just to demote them again.

And leaving these perfect reclaim candidates on the inactive list makes
it more likely for the real working set to survive the next reclaim
scan.

Benchmark graphs and the test-application can be found here:

	http://hannes.saeurebad.de/madvseq/

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
Cc: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/rmap.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff -puN mm/rmap.c~mm-more-likely-reclaim-madv_sequential-mappings mm/rmap.c
--- a/mm/rmap.c~mm-more-likely-reclaim-madv_sequential-mappings
+++ a/mm/rmap.c
@@ -327,8 +327,18 @@ static int page_referenced_one(struct pa
 		goto out_unmap;
 	}
 
-	if (ptep_clear_flush_young_notify(vma, address, pte))
-		referenced++;
+	if (ptep_clear_flush_young_notify(vma, address, pte)) {
+		/*
+		 * If there was just one sequential access to the
+		 * page, ignore it.  Otherwise, mark_page_accessed()
+		 * will have promoted the page to the active list and
+		 * it should be kept.
+		 */
+		if (VM_SequentialReadHint(vma) && !PageActive(page))
+			ClearPageReferenced(page);
+		else
+			referenced++;
+	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
@@ -449,9 +459,6 @@ int page_referenced(struct page *page, i
 {
 	int referenced = 0;
 
-	if (TestClearPageReferenced(page))
-		referenced++;
-
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
 			referenced += page_referenced_anon(page, mem_cont);
@@ -467,6 +474,9 @@ int page_referenced(struct page *page, i
 		}
 	}
 
+	if (TestClearPageReferenced(page))
+		referenced++;
+
 	if (page_test_and_clear_young(page))
 		referenced++;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
