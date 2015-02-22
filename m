Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 026826B0074
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 08:42:42 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so11518436wid.5
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:42:41 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id r1si12611302wiz.11.2015.02.22.05.42.39
        for <linux-mm@kvack.org>;
        Sun, 22 Feb 2015 05:42:40 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH V5 2/4] mm: Refactor do_wp_page - rewrite the unlock flow
Date: Sun, 22 Feb 2015 15:42:16 +0200
Message-Id: <1424612538-25889-3-git-send-email-raindel@mellanox.com>
In-Reply-To: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
References: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
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
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Feiner <pfeiner@google.com>
Cc: Michel Lespinasse <walken@google.com>
---
 mm/memory.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7a04414..3afd9ce 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2066,7 +2066,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *old_page, *new_page = NULL;
 	pte_t entry;
-	int ret = 0;
+	int page_copied = 0;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
@@ -2101,7 +2101,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -2148,7 +2150,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 							 &ptl);
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
-				goto unlock;
+				pte_unmap_unlock(page_table, ptl);
+				page_cache_release(old_page);
+				return 0;
 			}
 			page_mkwrite = 1;
 		}
@@ -2246,29 +2250,28 @@ gotten:
 
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
