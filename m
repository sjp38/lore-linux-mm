Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB7B6B002D
	for <linux-mm@kvack.org>; Sat, 29 Oct 2011 09:09:36 -0400 (EDT)
Received: by wyg34 with SMTP id 34so6319620wyg.14
        for <linux-mm@kvack.org>; Sat, 29 Oct 2011 06:09:33 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 29 Oct 2011 21:09:33 +0800
Message-ID: <CAJd=RBBRQjo_RHjoGBGQX9TUWkgdGGgh-KNpDX2sEUwwVy-89w@mail.gmail.com>
Subject: [PATCH] mm/hugetlb: Release pages in the error path of COW
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

If anon_vma is prepared unsuccessfully, new_page and old_page should be freed.

And due to that page_table_lock is re-acquired, race in updating page table
should also be check. If race does happen, our job is done.

All comments and ideas welcome.

Thanks

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Sat Aug 13 11:45:14 2011
+++ b/mm/hugetlb.c	Sat Oct 29 20:44:09 2011
@@ -2406,8 +2406,7 @@ retry_avoidcopy:
 			if (unmap_ref_private(mm, vma, old_page, address)) {
 				BUG_ON(page_count(old_page) != 1);
 				BUG_ON(huge_pte_none(pte));
-				spin_lock(&mm->page_table_lock);
-				goto retry_avoidcopy;
+				goto lock_and_check;
 			}
 			WARN_ON_ONCE(1);
 		}
@@ -2422,6 +2421,8 @@ retry_avoidcopy:
 	 * anon_vma prepared.
 	 */
 	if (unlikely(anon_vma_prepare(vma))) {
+		page_cache_release(new_page);
+		page_cache_release(old_page);
 		/* Caller expects lock to be held */
 		spin_lock(&mm->page_table_lock);
 		return VM_FAULT_OOM;
@@ -2455,6 +2456,14 @@ retry_avoidcopy:
 	}
 	page_cache_release(new_page);
 	page_cache_release(old_page);
+	return 0;
+
+lock_and_check:
+	spin_lock(&mm->page_table_lock);
+	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
+	if (likely(pte_same(huge_ptep_get(ptep), pte)))
+		goto retry_avoidcopy;
+	/* else changes occured while taking page_table_lock, our job done */
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
