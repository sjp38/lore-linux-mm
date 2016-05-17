Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF646B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 08:32:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so29096768pfz.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:32:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id dx9si4399314pab.59.2016.05.17.05.32.55
        for <linux-mm@kvack.org>;
        Tue, 17 May 2016 05:32:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: make faultaround produce old ptes
Date: Tue, 17 May 2016 15:32:46 +0300
Message-Id: <1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Minchan Kim <minchan@kernel.org>

Currently, faultaround code produces young pte. This can screw up vmscan
behaviour[1], as it makes vmscan think that these pages are hot and not
push them out on first round.

Let modify faultaround to produce old pte, so they can easily be
reclaimed under memory pressure.

This can to some extend defeat purpose of faultaround on machines
without hardware accessed bit as it will not help up with reducing
number of minor page faults.

We may want to disable faultaround on such machines altogether, but
that's subject for separate patchset.

[1] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm.h |  2 +-
 mm/filemap.c       |  2 +-
 mm/memory.c        | 23 ++++++++++++++++++-----
 3 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 573dfebddcca..a0e773204be0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -591,7 +591,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 }
 
 void do_set_pte(struct vm_area_struct *vma, unsigned long address,
-		struct page *page, pte_t *pte, bool write, bool anon);
+		struct page *page, pte_t *pte, bool write, bool anon, bool old);
 #endif
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index b366a9902f1c..dd789e159a77 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2196,7 +2196,7 @@ repeat:
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
-		do_set_pte(vma, addr, page, pte, false, false);
+		do_set_pte(vma, addr, page, pte, false, false, true);
 		unlock_page(page);
 		goto next;
 unlock:
diff --git a/mm/memory.c b/mm/memory.c
index d79c6db41502..67c03b2fe20c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2855,7 +2855,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
  * vm_ops->map_pages.
  */
 void do_set_pte(struct vm_area_struct *vma, unsigned long address,
-		struct page *page, pte_t *pte, bool write, bool anon)
+		struct page *page, pte_t *pte, bool write, bool anon, bool old)
 {
 	pte_t entry;
 
@@ -2863,6 +2863,8 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	if (old)
+		entry = pte_mkold(entry);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address, false);
@@ -3000,9 +3002,20 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-		do_fault_around(vma, address, pte, pgoff, flags);
 		if (!pte_same(*pte, orig_pte))
 			goto unlock_out;
+		do_fault_around(vma, address, pte, pgoff, flags);
+		/* Check if the fault is handled by faultaround */
+		if (!pte_same(*pte, orig_pte)) {
+			/*
+			 * Faultaround produce old pte, but the pte we've
+			 * handler fault for should be young.
+			 */
+			pte_t entry = pte_mkyoung(*pte);
+			if (ptep_set_access_flags(vma, address, pte, entry, 0))
+				update_mmu_cache(vma, address, pte);
+			goto unlock_out;
+		}
 		pte_unmap_unlock(pte, ptl);
 	}
 
@@ -3017,7 +3030,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, false, false);
+	do_set_pte(vma, address, fault_page, pte, false, false, false);
 	unlock_page(fault_page);
 unlock_out:
 	pte_unmap_unlock(pte, ptl);
@@ -3069,7 +3082,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		goto uncharge_out;
 	}
-	do_set_pte(vma, address, new_page, pte, true, true);
+	do_set_pte(vma, address, new_page, pte, true, true, false);
 	mem_cgroup_commit_charge(new_page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
@@ -3126,7 +3139,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, true, false);
+	do_set_pte(vma, address, fault_page, pte, true, false, false);
 	pte_unmap_unlock(pte, ptl);
 
 	if (set_page_dirty(fault_page))
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
