Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 9EF7D6B0071
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 19:36:51 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/3] mm, thp: implement virtual huge zero page
Date: Sat, 29 Sep 2012 02:37:20 +0300
Message-Id: <1348875441-19561-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Virtual huge zero page is a PMD table with all entries set to zero page.
When we get write-protect page fault to zero page in such PMD we drop
the whole page table and allow THP (if enabled) to allocate a real
memory instead.

The implementation requires HAVE_PMD_SPECAIL from an arch if it wants to
support virtual zero page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |    8 ++++++++
 mm/huge_memory.c   |   38 ++++++++++++++++++++++++++++++++++++++
 mm/memory.c        |   15 ++++++++-------
 3 files changed, 54 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 311be90..179a41c 100644
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
index 57c4b93..8189fb6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -696,6 +696,33 @@ static inline struct page *alloc_hugepage(int defrag)
 }
 #endif
 
+static void set_huge_zero_page(pgtable_t pgtable, struct vm_area_struct *vma,
+		unsigned long haddr, pmd_t *pmd)
+{
+	pmd_t _pmd;
+	int i;
+
+	pmdp_clear_flush_notify(vma, haddr, pmd);
+	/* leave pmd empty until pte is filled */
+
+	pmd_populate(vma->vm_mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		pte_t *pte, entry;
+		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
+		entry = pte_mkspecial(entry);
+		pte = pte_offset_map(&_pmd, haddr);
+		VM_BUG_ON(!pte_none(*pte));
+		set_pte_at(vma->vm_mm, haddr, pte, entry);
+		pte_unmap(pte);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(vma->vm_mm, pmd, pgtable);
+	_pmd = pmd_mkspecial(*pmd);
+	set_pmd_at(vma->vm_mm, haddr, pmd, _pmd);
+	vma->vm_mm->nr_ptes++;
+}
+
 int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       unsigned int flags)
@@ -709,6 +736,17 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_OOM;
 		if (unlikely(khugepaged_enter(vma)))
 			return VM_FAULT_OOM;
+		if (IS_ENABLED(CONFIG_HAVE_PMD_SPECIAL) &&
+				!(flags & FAULT_FLAG_WRITE)) {
+			pgtable_t pgtable;
+			pgtable = pte_alloc_one(mm, haddr);
+			if (unlikely(!pgtable))
+				goto out;
+			spin_lock(&mm->page_table_lock);
+			set_huge_zero_page(pgtable, vma, haddr, pmd);
+			spin_unlock(&mm->page_table_lock);
+			return 0;
+		}
 		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
 					  vma, haddr, numa_node_id(), 0);
 		if (unlikely(!page)) {
diff --git a/mm/memory.c b/mm/memory.c
index 5736170..38dfd5e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -724,13 +724,6 @@ static inline int is_zero_pfn(unsigned long pfn)
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
@@ -3514,6 +3507,14 @@ retry:
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
+
+	if (pmd_special(*pmd) && flags & FAULT_FLAG_WRITE) {
+		pgtable_t pgtable = pmd_pgtable(*pmd);
+		pmd_clear(pmd);
+		pte_free(mm, pgtable);
+		mm->nr_ptes--;
+	}
+
 	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
 		if (!vma->vm_ops)
 			return do_huge_pmd_anonymous_page(mm, vma, address,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
