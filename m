Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 58B536B00C4
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:27 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 30/34] thp: extract fallback path from do_huge_pmd_anonymous_page() to a function
Date: Fri,  5 Apr 2013 14:59:54 +0300
Message-Id: <1365163198-29726-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The same fallback path will be reused by non-anonymous pages, so lets'
extract it in separate function.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |  112 ++++++++++++++++++++++++++++--------------------------
 1 file changed, 59 insertions(+), 53 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0cf2e79..c1d5f2b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -779,64 +779,12 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	return true;
 }
 
-int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
+static int do_fallback(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       unsigned int flags)
 {
-	struct page *page;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
 	pte_t *pte;
 
-	if (haddr >= vma->vm_start && haddr + HPAGE_PMD_SIZE <= vma->vm_end) {
-		if (unlikely(anon_vma_prepare(vma)))
-			return VM_FAULT_OOM;
-		if (unlikely(khugepaged_enter(vma)))
-			return VM_FAULT_OOM;
-		if (!(flags & FAULT_FLAG_WRITE) &&
-				transparent_hugepage_use_zero_page()) {
-			pgtable_t pgtable;
-			unsigned long zero_pfn;
-			bool set;
-			pgtable = pte_alloc_one(mm, haddr);
-			if (unlikely(!pgtable))
-				return VM_FAULT_OOM;
-			zero_pfn = get_huge_zero_page();
-			if (unlikely(!zero_pfn)) {
-				pte_free(mm, pgtable);
-				count_vm_event(THP_FAULT_FALLBACK);
-				goto out;
-			}
-			spin_lock(&mm->page_table_lock);
-			set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
-					zero_pfn);
-			spin_unlock(&mm->page_table_lock);
-			if (!set) {
-				pte_free(mm, pgtable);
-				put_huge_zero_page();
-			}
-			return 0;
-		}
-		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					  vma, haddr, numa_node_id(), 0);
-		if (unlikely(!page)) {
-			count_vm_event(THP_FAULT_FALLBACK);
-			goto out;
-		}
-		count_vm_event(THP_FAULT_ALLOC);
-		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
-			put_page(page);
-			goto out;
-		}
-		if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd,
-							  page))) {
-			mem_cgroup_uncharge_page(page);
-			put_page(page);
-			goto out;
-		}
-
-		return 0;
-	}
-out:
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could
@@ -858,6 +806,64 @@ out:
 	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
+int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			       unsigned long address, pmd_t *pmd,
+			       unsigned int flags)
+{
+	struct page *page;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		return do_fallback(mm, vma, address, pmd, flags);
+	if (unlikely(anon_vma_prepare(vma)))
+		return VM_FAULT_OOM;
+	if (unlikely(khugepaged_enter(vma)))
+		return VM_FAULT_OOM;
+	if (!(flags & FAULT_FLAG_WRITE) &&
+			transparent_hugepage_use_zero_page()) {
+		pgtable_t pgtable;
+		unsigned long zero_pfn;
+		bool set;
+		pgtable = pte_alloc_one(mm, haddr);
+		if (unlikely(!pgtable))
+			return VM_FAULT_OOM;
+		zero_pfn = get_huge_zero_page();
+		if (unlikely(!zero_pfn)) {
+			pte_free(mm, pgtable);
+			count_vm_event(THP_FAULT_FALLBACK);
+			return do_fallback(mm, vma, address, pmd, flags);
+		}
+		spin_lock(&mm->page_table_lock);
+		set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
+				zero_pfn);
+		spin_unlock(&mm->page_table_lock);
+		if (!set) {
+			pte_free(mm, pgtable);
+			put_huge_zero_page();
+		}
+		return 0;
+	}
+	page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
+			vma, haddr, numa_node_id(), 0);
+	if (unlikely(!page)) {
+		count_vm_event(THP_FAULT_FALLBACK);
+		return do_fallback(mm, vma, address, pmd, flags);
+	}
+	count_vm_event(THP_FAULT_ALLOC);
+	if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
+		put_page(page);
+		return do_fallback(mm, vma, address, pmd, flags);
+	}
+	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd,
+					page))) {
+		mem_cgroup_uncharge_page(page);
+		put_page(page);
+		return do_fallback(mm, vma, address, pmd, flags);
+	}
+
+	return 0;
+}
+
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
