Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 248ED6B00C1
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 07:03:26 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id q1so19616578lam.5
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 04:03:25 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id df8si65707162lac.23.2015.01.06.04.03.24
        for <linux-mm@kvack.org>;
        Tue, 06 Jan 2015 04:03:25 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH v3 2/4] mm: Refactor do_wp_page - rewrite the unlock flow
Date: Tue,  6 Jan 2015 14:00:42 +0200
Message-Id: <1420545644-27226-3-git-send-email-raindel@mellanox.com>
In-Reply-To: <1420545644-27226-1-git-send-email-raindel@mellanox.com>
References: <1420545644-27226-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, raindel@mellanox.com, Dave Hansen <dave.hansen@intel.com>

When do_wp_page is ending, in several cases it needs to unlock the
pages and ptls it was accessing.

Currently, this logic was "called" by using a goto jump. This makes
following the control flow of the function harder. Readability was
further hampered by the unlock case containing large amount of logic
needed only in one of the 3 cases.

Using goto for cleanup is generally allowed. However, moving the
trivial unlocking flows to the relevant call sites allow deeper
refactoring in the next patch.

Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Haggai Eran <haggaie@mellanox.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Feiner <pfeiner@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
---
 mm/memory.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index cd913eb..aa15662 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2099,7 +2099,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *old_page, *new_page = NULL;
 	pte_t entry;
-	int ret = 0;
+	int page_copied = 0;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
@@ -2134,7 +2134,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 							 &ptl);
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
-				goto unlock;
+				pte_unmap_unlock(page_table, ptl);
+				page_cache_release(old_page);
+				return 0;
 			}
 			page_cache_release(old_page);
 		}
@@ -2179,7 +2181,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 							 &ptl);
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
-				goto unlock;
+				pte_unmap_unlock(page_table, ptl);
+				page_cache_release(old_page);
+				return 0;
 			}
 
 			page_mkwrite = 1;
@@ -2279,29 +2283,28 @@ gotten:
 
 		/* Free the old page.. */
 		new_page = old_page;
-		ret |= VM_FAULT_WRITE;
+		page_copied = 1;
 	} else
 		mem_cgroup_cancel_charge(new_page, memcg);
 
 	if (new_page)
 		page_cache_release(new_page);
-unlock:
+
 	pte_unmap_unlock(page_table, ptl);
-	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
 		 */
-		if ((ret & VM_FAULT_WRITE) && (vma->vm_flags & VM_LOCKED)) {
+		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
 			lock_page(old_page);	/* LRU manipulation */
 			munlock_vma_page(old_page);
 			unlock_page(old_page);
 		}
 		page_cache_release(old_page);
 	}
-	return ret;
+	return page_copied ? VM_FAULT_WRITE : 0;
 oom_free_new:
 	page_cache_release(new_page);
 oom:
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
