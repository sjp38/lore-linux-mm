Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 01B346B0037
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:17 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so6709584pad.0
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:17 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yt9si16577925pab.91.2014.02.10.12.41.16
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/8] mm: introduce do_read_fault()
Date: Mon, 10 Feb 2014 22:41:02 +0200
Message-Id: <1392064866-11840-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch introduces do_read_fault(). The function does what do_fault()
does for read page faults.

Unlike do_fault(), do_read_fault() is pretty clean and straight-forward.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index d3317ac02a5b..cbc17f47df11 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3317,6 +3317,43 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	return ret;
 }
 
+static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd,
+		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+{
+	struct page *fault_page;
+	spinlock_t *ptl;
+	pte_t entry, *pte;
+	int ret;
+
+	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
+		return ret;
+
+	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (unlikely(!pte_same(*pte, orig_pte))) {
+		pte_unmap_unlock(pte, ptl);
+		unlock_page(fault_page);
+		page_cache_release(fault_page);
+		return ret;
+	}
+
+	flush_icache_page(vma, fault_page);
+	entry = mk_pte(fault_page, vma->vm_page_prot);
+	if (pte_file(orig_pte) && pte_file_soft_dirty(orig_pte))
+		pte_mksoft_dirty(entry);
+	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	page_add_file_rmap(fault_page);
+	set_pte_at(mm, address, pte, entry);
+
+	/* no need to invalidate: a not-present page won't be cached */
+	update_mmu_cache(vma, address, pte);
+	pte_unmap_unlock(pte, ptl);
+	unlock_page(fault_page);
+
+	return ret;
+}
+
 /*
  * do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
@@ -3510,6 +3547,9 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 	pte_unmap(page_table);
+	if (!(flags & FAULT_FLAG_WRITE))
+		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
+				orig_pte);
 	return do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
@@ -3542,6 +3582,9 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	pgoff = pte_to_pgoff(orig_pte);
+	if (!(flags & FAULT_FLAG_WRITE))
+		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
+				orig_pte);
 	return do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-- 
1.8.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
