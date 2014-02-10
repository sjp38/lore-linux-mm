Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 911136B0044
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:53 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so6716560pbc.40
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:53 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id to9si16561741pbc.185.2014.02.10.12.41.20
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:20 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/8] mm: introduce do_cow_fault()
Date: Mon, 10 Feb 2014 22:41:03 +0200
Message-Id: <1392064866-11840-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch introduces do_cow_fault(). The function does what do_fault()
does for write page faults to private mappings.

Unlike do_fault(), do_read_fault() is relatively clean and
straight-forward.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index cbc17f47df11..9ad0754d11ba 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3354,6 +3354,62 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ret;
 }
 
+static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd,
+		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+{
+	struct page *fault_page, *new_page;
+	spinlock_t *ptl;
+	pte_t entry, *pte;
+	int ret;
+
+	if (unlikely(anon_vma_prepare(vma)))
+		return VM_FAULT_OOM;
+
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	if (!new_page)
+		return VM_FAULT_OOM;
+
+	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)) {
+		page_cache_release(new_page);
+		return VM_FAULT_OOM;
+	}
+
+	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
+		goto uncharge_out;
+
+	copy_user_highpage(new_page, fault_page, address, vma);
+	__SetPageUptodate(new_page);
+
+	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (unlikely(!pte_same(*pte, orig_pte))) {
+		pte_unmap_unlock(pte, ptl);
+		unlock_page(fault_page);
+		page_cache_release(fault_page);
+		goto uncharge_out;
+	}
+
+	flush_icache_page(vma, new_page);
+	entry = mk_pte(new_page, vma->vm_page_prot);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	inc_mm_counter_fast(mm, MM_ANONPAGES);
+	page_add_new_anon_rmap(new_page, vma, address);
+	set_pte_at(mm, address, pte, entry);
+
+	/* no need to invalidate: a not-present page won't be cached */
+	update_mmu_cache(vma, address, pte);
+
+	pte_unmap_unlock(pte, ptl);
+	unlock_page(fault_page);
+	page_cache_release(fault_page);
+	return ret;
+uncharge_out:
+	mem_cgroup_uncharge_page(new_page);
+	page_cache_release(new_page);
+	return ret;
+}
+
 /*
  * do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
@@ -3550,6 +3606,9 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!(flags & FAULT_FLAG_WRITE))
 		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
 				orig_pte);
+	if (!(vma->vm_flags & VM_SHARED))
+		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
+				orig_pte);
 	return do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
@@ -3585,6 +3644,9 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!(flags & FAULT_FLAG_WRITE))
 		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
 				orig_pte);
+	if (!(vma->vm_flags & VM_SHARED))
+		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
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
