Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 958B06B005D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 05:08:38 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 4/9] thp: do_huge_pmd_wp_page(): handle huge zero page
Date: Thu,  9 Aug 2012 12:08:15 +0300
Message-Id: <1344503300-9507-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On right access to huge zero page we alloc a new page and clear it.

In fallback path we create a new table and set pte around fault address
to the newly allocated page. All other ptes set to normal zero page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |    8 ++++
 mm/huge_memory.c   |  102 ++++++++++++++++++++++++++++++++++++++++++++--------
 mm/memory.c        |    7 ----
 3 files changed, 95 insertions(+), 22 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b36d08c..c6eef63 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -514,6 +514,14 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 }
 #endif
 
+#ifndef my_zero_pfn
+static inline unsigned long my_zero_pfn(unsigned long addr)
+{
+	extern unsigned long zero_pfn;
+	return zero_pfn;
+}
+#endif
+
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a534f84..f5029d4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -867,6 +867,61 @@ pgtable_t get_pmd_huge_pte(struct mm_struct *mm)
 	return pgtable;
 }
 
+static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, unsigned long haddr)
+{
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	struct page *page;
+	int i, ret = 0;
+
+	page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	if (!page) {
+		ret |= VM_FAULT_OOM;
+		goto out;
+	}
+
+	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
+		put_page(page);
+		ret |= VM_FAULT_OOM;
+		goto out;
+	}
+
+	clear_user_highpage(page, address);
+	__SetPageUptodate(page);
+
+	spin_lock(&mm->page_table_lock);
+	pmdp_clear_flush_notify(vma, haddr, pmd);
+	/* leave pmd empty until pte is filled */
+
+	pgtable = get_pmd_huge_pte(mm);
+	pmd_populate(mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		pte_t *pte, entry;
+		if (haddr == (address & PAGE_MASK)) {
+			entry = mk_pte(page, vma->vm_page_prot);
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			page_add_new_anon_rmap(page, vma, haddr);
+		} else {
+			entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
+			entry = pte_mkspecial(entry);
+		}
+		pte = pte_offset_map(&_pmd, haddr);
+		VM_BUG_ON(!pte_none(*pte));
+		set_pte_at(mm, haddr, pte, entry);
+		pte_unmap(pte);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(mm, pmd, pgtable);
+	spin_unlock(&mm->page_table_lock);
+
+	ret |= VM_FAULT_WRITE;
+out:
+	return ret;
+}
+
 static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address,
@@ -964,17 +1019,19 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
 {
 	int ret = 0;
-	struct page *page, *new_page;
+	struct page *page = NULL, *new_page;
 	unsigned long haddr;
 
 	VM_BUG_ON(!vma->anon_vma);
+	haddr = address & HPAGE_PMD_MASK;
+	if (is_huge_zero_pmd(orig_pmd))
+		goto alloc;
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_unlock;
 
 	page = pmd_page(orig_pmd);
 	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
-	haddr = address & HPAGE_PMD_MASK;
 	if (page_mapcount(page) == 1) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
@@ -986,7 +1043,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
-
+alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
 		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
@@ -996,28 +1053,39 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (unlikely(!new_page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
-		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
-						   pmd, orig_pmd, page, haddr);
-		if (ret & VM_FAULT_OOM)
-			split_huge_page(page);
-		put_page(page);
+		if (is_huge_zero_pmd(orig_pmd)) {
+			ret = do_huge_pmd_wp_zero_page_fallback(mm, vma,
+					address, pmd, haddr);
+		} else {
+			ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
+					pmd, orig_pmd, page, haddr);
+			if (ret & VM_FAULT_OOM)
+				split_huge_page(page);
+			put_page(page);
+		}
 		goto out;
 	}
 	count_vm_event(THP_FAULT_ALLOC);
 
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		put_page(new_page);
-		split_huge_page(page);
-		put_page(page);
+		if (page) {
+			split_huge_page(page);
+			put_page(page);
+		}
 		ret |= VM_FAULT_OOM;
 		goto out;
 	}
 
-	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
+	if (is_huge_zero_pmd(orig_pmd))
+		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
+	else
+		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
 	spin_lock(&mm->page_table_lock);
-	put_page(page);
+	if (page)
+		put_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
 		spin_unlock(&mm->page_table_lock);
 		mem_cgroup_uncharge_page(new_page);
@@ -1025,7 +1093,6 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out;
 	} else {
 		pmd_t entry;
-		VM_BUG_ON(!PageHead(page));
 		entry = mk_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		entry = pmd_mkhuge(entry);
@@ -1033,8 +1100,13 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		update_mmu_cache(vma, address, entry);
-		page_remove_rmap(page);
-		put_page(page);
+		if (is_huge_zero_pmd(orig_pmd))
+			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		if (page) {
+			VM_BUG_ON(!PageHead(page));
+			page_remove_rmap(page);
+			put_page(page);
+		}
 		ret |= VM_FAULT_WRITE;
 	}
 out_unlock:
diff --git a/mm/memory.c b/mm/memory.c
index 2466d12..c281847 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -720,13 +720,6 @@ static inline int is_zero_pfn(unsigned long pfn)
 }
 #endif
 
-#ifndef my_zero_pfn
-static inline unsigned long my_zero_pfn(unsigned long addr)
-{
-	return zero_pfn;
-}
-#endif
-
 /*
  * vm_normal_page -- This function gets the "struct page" associated with a pte.
  *
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
