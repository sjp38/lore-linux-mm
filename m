Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 0850E6B006E
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 05:08:40 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 7/9] thp: implement splitting pmd for huge zero page
Date: Thu,  9 Aug 2012 12:08:18 +0300
Message-Id: <1344503300-9507-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We can't split huge zero page itself, but we can split the pmd which
points to it.

On splitting the pmd we create a table with all ptes set to normal zero
page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c8948d6..4df5841 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1599,6 +1599,7 @@ int split_huge_page(struct page *page)
 	struct anon_vma *anon_vma;
 	int ret = 1;
 
+	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
 	BUG_ON(!PageAnon(page));
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
@@ -2503,6 +2504,36 @@ static int khugepaged(void *none)
 	return 0;
 }
 
+static void __split_huge_zero_page_pmd(struct mm_struct *mm, pmd_t *pmd,
+		unsigned long address)
+{
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct vm_area_struct *vma;
+	int i;
+
+	vma = find_vma(mm, address);
+	VM_BUG_ON(vma == NULL);
+	pmdp_clear_flush_notify(vma, haddr, pmd);
+	/* leave pmd empty until pte is filled */
+
+	pgtable = get_pmd_huge_pte(mm);
+	pmd_populate(mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		pte_t *pte, entry;
+		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
+		entry = pte_mkspecial(entry);
+		pte = pte_offset_map(&_pmd, haddr);
+		VM_BUG_ON(!pte_none(*pte));
+		set_pte_at(mm, haddr, pte, entry);
+		pte_unmap(pte);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(mm, pmd, pgtable);
+}
+
 void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd,
 		unsigned long address)
 {
@@ -2513,6 +2544,11 @@ void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd,
 		spin_unlock(&mm->page_table_lock);
 		return;
 	}
+	if (is_huge_zero_pmd(*pmd)) {
+		__split_huge_zero_page_pmd(mm, pmd, address);
+		spin_unlock(&mm->page_table_lock);
+		return;
+	}
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
