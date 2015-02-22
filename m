Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDA96B0070
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 07:47:53 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id a1so20955390wgh.5
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 04:47:53 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id kr5si56317168wjc.81.2015.02.22.04.47.51
        for <linux-mm@kvack.org>;
        Sun, 22 Feb 2015 04:47:52 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH V4 4/4] mm: Refactor do_wp_page handling of shared vma into a function
Date: Sun, 22 Feb 2015 14:47:21 +0200
Message-Id: <1424609241-20106-5-git-send-email-raindel@mellanox.com>
In-Reply-To: <1424609241-20106-1-git-send-email-raindel@mellanox.com>
References: <1424609241-20106-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, raindel@mellanox.com, Dave Hansen <dave.hansen@intel.com>

The do_wp_page function is extremely long. Extract the logic for
handling a page belonging to a shared vma into a function of its own.

This helps the readability of the code, without doing any functional
change in it.

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
 mm/memory.c | 84 ++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 47 insertions(+), 37 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 370aeec..3bf05a0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2182,6 +2182,51 @@ oom:
 	return VM_FAULT_OOM;
 }
 
+static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
+			  unsigned long address, pte_t *page_table,
+			  pmd_t *pmd, spinlock_t *ptl, pte_t orig_pte,
+			  struct page *old_page)
+	__releases(ptl)
+{
+	int page_mkwrite = 0;
+	page_cache_get(old_page);
+
+	/*
+	 * Only catch write-faults on shared writable pages,
+	 * read-only shared pages can get COWed by
+	 * get_user_pages(.write=1, .force=1).
+	 */
+	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+		int tmp;
+
+		pte_unmap_unlock(page_table, ptl);
+		tmp = do_page_mkwrite(vma, old_page, address);
+		if (unlikely(!tmp || (tmp &
+				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+			page_cache_release(old_page);
+			return tmp;
+		}
+		/*
+		 * Since we dropped the lock we need to revalidate
+		 * the PTE as someone else may have changed it.  If
+		 * they did, we just return, as we can count on the
+		 * MMU to tell us if they didn't also make it writable.
+		 */
+		page_table = pte_offset_map_lock(mm, pmd, address,
+						 &ptl);
+		if (!pte_same(*page_table, orig_pte)) {
+			unlock_page(old_page);
+			pte_unmap_unlock(page_table, ptl);
+			page_cache_release(old_page);
+			return 0;
+		}
+		page_mkwrite = 1;
+	}
+
+	return wp_page_reuse(mm, vma, address, page_table, ptl,
+			     orig_pte, old_page, 1, page_mkwrite, 1);
+}
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -2260,43 +2305,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
-		int page_mkwrite = 0;
-		page_cache_get(old_page);
-
-		/*
-		 * Only catch write-faults on shared writable pages,
-		 * read-only shared pages can get COWed by
-		 * get_user_pages(.write=1, .force=1).
-		 */
-		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
-			int tmp;
-
-			pte_unmap_unlock(page_table, ptl);
-			tmp = do_page_mkwrite(vma, old_page, address);
-			if (unlikely(!tmp || (tmp &
-					(VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
-				page_cache_release(old_page);
-				return tmp;
-			}
-			/*
-			 * Since we dropped the lock we need to revalidate
-			 * the PTE as someone else may have changed it.  If
-			 * they did, we just return, as we can count on the
-			 * MMU to tell us if they didn't also make it writable.
-			 */
-			page_table = pte_offset_map_lock(mm, pmd, address,
-							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
-				unlock_page(old_page);
-				pte_unmap_unlock(page_table, ptl);
-				page_cache_release(old_page);
-				return 0;
-			}
-			page_mkwrite = 1;
-		}
-
-		return wp_page_reuse(mm, vma, address, page_table, ptl,
-				     orig_pte, old_page, 1, page_mkwrite, 1);
+		return wp_page_shared(mm, vma, address, page_table, pmd,
+				      ptl, orig_pte, old_page);
 	}
 
 	/*
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
