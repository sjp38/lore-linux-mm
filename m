Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 776616B004A
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 00:25:31 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/4] hugetlb, rmap: fix confusing page locking in hugetlb_cow()
Date: Fri, 10 Sep 2010 13:23:05 +0900
Message-Id: <1284092586-1179-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

if(!trylock_page) block in avoidcopy path of hugetlb_cow() looks confusing
and is buggy.  Originally this trylock_page() is intended to make sure
that old_page is locked even when old_page != pagecache_page, because then
only pagecache_page is locked.
This patch fixes it by moving page locking into hugetlb_fault().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git v2.6.36-rc3/mm/hugetlb.c v2.6.36-rc3/mm/hugetlb.c
index 9519f3f..2e17e0e 100644
--- v2.6.36-rc3/mm/hugetlb.c
+++ v2.6.36-rc3/mm/hugetlb.c
@@ -2324,11 +2324,8 @@ retry_avoidcopy:
 	 * and just make the page writable */
 	avoidcopy = (page_mapcount(old_page) == 1);
 	if (avoidcopy) {
-		if (!trylock_page(old_page)) {
-			if (PageAnon(old_page))
-				page_move_anon_rmap(old_page, vma, address);
-		} else
-			unlock_page(old_page);
+		if (PageAnon(old_page))
+			page_move_anon_rmap(old_page, vma, address);
 		set_huge_ptep_writable(vma, address, ptep);
 		return 0;
 	}
@@ -2631,10 +2628,14 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 								vma, address);
 	}
 
-	if (!pagecache_page) {
-		page = pte_page(entry);
+	/*
+	 * hugetlb_cow() requires page locks of pte_page(entry) and
+	 * pagecache_page, so here we need take the former one
+	 * when page != pagecache_page or !pagecache_page.
+	 */
+	page = pte_page(entry);
+	if (page != pagecache_page)
 		lock_page(page);
-	}
 
 	spin_lock(&mm->page_table_lock);
 	/* Check for a racing update before calling hugetlb_cow */
@@ -2661,9 +2662,8 @@ out_page_table_lock:
 	if (pagecache_page) {
 		unlock_page(pagecache_page);
 		put_page(pagecache_page);
-	} else {
-		unlock_page(page);
 	}
+	unlock_page(page);
 
 out_mutex:
 	mutex_unlock(&hugetlb_instantiation_mutex);
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
