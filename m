Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 448316B005D
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 14:11:25 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] thp: avoid VM_BUG_ON page_count(page) false positives in __collapse_huge_page_copy
Date: Tue, 25 Sep 2012 20:11:18 +0200
Message-Id: <1348596678-2768-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1348596678-2768-1-git-send-email-aarcange@redhat.com>
References: <1348596678-2768-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>

Use page_freeze_refs to prevent speculative pagecache lookups to
trigger the false positives, so we're still able to check the
page_count to be exact.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1598708..7eca652 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1704,6 +1704,9 @@ void __khugepaged_exit(struct mm_struct *mm)
 
 static void release_pte_page(struct page *page)
 {
+#ifdef CONFIG_DEBUG_VM
+	page_unfreeze_refs(page, 2);
+#endif
 	/* 0 stands for page_is_file_cache(page) == false */
 	dec_zone_page_state(page, NR_ISOLATED_ANON + 0);
 	unlock_page(page);
@@ -1784,6 +1787,20 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		VM_BUG_ON(!PageLocked(page));
 		VM_BUG_ON(PageLRU(page));
 
+#ifdef CONFIG_DEBUG_VM
+		/*
+		 * For the VM_BUG_ON check on page_count(page) in
+		 * __collapse_huge_page_copy not to trigger false
+		 * positives we've to prevent the speculative
+		 * pagecache lookups too with page_freeze_refs. We
+		 * could check for >= 2 instead but this provides for
+		 * a more strict debugging behavior.
+		 */
+		if (!page_freeze_refs(page, 2)) {
+			release_pte_pages(pte, _pte+1);
+			goto out;
+		}
+#endif
 		/* If there is no mapped pte young don't collapse the page */
 		if (pte_young(pteval) || PageReferenced(page) ||
 		    mmu_notifier_test_young(vma->vm_mm, address))
@@ -1814,7 +1831,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			src_page = pte_page(pteval);
 			copy_user_highpage(page, src_page, address, vma);
 			VM_BUG_ON(page_mapcount(src_page) != 1);
-			VM_BUG_ON(page_count(src_page) != 2);
+			VM_BUG_ON(page_count(src_page) != 0);
 			release_pte_page(src_page);
 			/*
 			 * ptl mostly unnecessary, but preempt has to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
