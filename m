Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7606B028B
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 04:42:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so234541350pfb.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 01:42:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id q66si23630723pfi.216.2016.06.14.01.42.44
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 01:42:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] Revert "mm: make faultaround produce old ptes"
Date: Tue, 14 Jun 2016 11:42:29 +0300
Message-Id: <1465893750-44080-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465893750-44080-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465893750-44080-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This reverts commit 5c0a85fad949212b3e059692deecdeed74ae7ec7.

The commit causes ~6% regression in unixbench.

Let's revert it for now and consider other solution for reclaim problem
later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/mm.h |  2 +-
 mm/filemap.c       |  2 +-
 mm/memory.c        | 23 +++++------------------
 3 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5df5feb49575..ece042dfe23c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -602,7 +602,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 }
 
 void do_set_pte(struct vm_area_struct *vma, unsigned long address,
-		struct page *page, pte_t *pte, bool write, bool anon, bool old);
+		struct page *page, pte_t *pte, bool write, bool anon);
 #endif
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index 00ae878b2a38..20f3b1f33f0e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2186,7 +2186,7 @@ repeat:
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
-		do_set_pte(vma, addr, page, pte, false, false, true);
+		do_set_pte(vma, addr, page, pte, false, false);
 		unlock_page(page);
 		goto next;
 unlock:
diff --git a/mm/memory.c b/mm/memory.c
index 15322b73636b..61fe7e7b56bf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2877,7 +2877,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
  * vm_ops->map_pages.
  */
 void do_set_pte(struct vm_area_struct *vma, unsigned long address,
-		struct page *page, pte_t *pte, bool write, bool anon, bool old)
+		struct page *page, pte_t *pte, bool write, bool anon)
 {
 	pte_t entry;
 
@@ -2885,8 +2885,6 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	if (old)
-		entry = pte_mkold(entry);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address, false);
@@ -3032,20 +3030,9 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-		if (!pte_same(*pte, orig_pte))
-			goto unlock_out;
 		do_fault_around(vma, address, pte, pgoff, flags);
-		/* Check if the fault is handled by faultaround */
-		if (!pte_same(*pte, orig_pte)) {
-			/*
-			 * Faultaround produce old pte, but the pte we've
-			 * handler fault for should be young.
-			 */
-			pte_t entry = pte_mkyoung(*pte);
-			if (ptep_set_access_flags(vma, address, pte, entry, 0))
-				update_mmu_cache(vma, address, pte);
+		if (!pte_same(*pte, orig_pte))
 			goto unlock_out;
-		}
 		pte_unmap_unlock(pte, ptl);
 	}
 
@@ -3060,7 +3047,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, false, false, false);
+	do_set_pte(vma, address, fault_page, pte, false, false);
 	unlock_page(fault_page);
 unlock_out:
 	pte_unmap_unlock(pte, ptl);
@@ -3111,7 +3098,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		goto uncharge_out;
 	}
-	do_set_pte(vma, address, new_page, pte, true, true, false);
+	do_set_pte(vma, address, new_page, pte, true, true);
 	mem_cgroup_commit_charge(new_page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
@@ -3164,7 +3151,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, true, false, false);
+	do_set_pte(vma, address, fault_page, pte, true, false);
 	pte_unmap_unlock(pte, ptl);
 
 	if (set_page_dirty(fault_page))
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
