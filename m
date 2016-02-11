Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 349106B0272
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:23:46 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id yy13so29584017pab.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:23:46 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id g74si12899389pfd.215.2016.02.11.06.23.12
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:23:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 10/28] mm: introduce do_set_pmd()
Date: Thu, 11 Feb 2016 17:21:38 +0300
Message-Id: <1455200516-132137-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With postponed page table allocation we have chance to setup huge pages.
do_set_pte() calls do_set_pmd() if following criteria met:

 - page is compound;
 - pmd entry in pmd_none();
 - vma has suitable size and alignment;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |  8 -------
 mm/internal.h    | 16 ++++++++++++++
 mm/memory.c      | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 78 insertions(+), 9 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0dc081fea9f1..9d614cee994f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -771,14 +771,6 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
-{
-	pmd_t entry;
-	entry = mk_pmd(page, prot);
-	entry = pmd_mkhuge(entry);
-	return entry;
-}
-
 static inline struct list_head *page_deferred_list(struct page *page)
 {
 	/*
diff --git a/mm/internal.h b/mm/internal.h
index 4ff5f2588430..4c5e13138c46 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -37,6 +37,22 @@
 
 int do_swap_page(struct fault_env *fe, pte_t orig_pte);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
+{
+	pmd_t entry;
+	entry = mk_pmd(page, prot);
+	entry = pmd_mkhuge(entry);
+	return entry;
+}
+#else
+static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
+{
+	BUILD_BUG();
+	return __pmd(0);
+}
+#endif
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/memory.c b/mm/memory.c
index 0d204ef02855..fb61e82bbb9a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2828,6 +2828,57 @@ map_pte:
 	return 0;
 }
 
+#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
+static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
+		unsigned long haddr)
+{
+	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
+			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
+		return false;
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		return false;
+	return true;
+}
+
+static int do_set_pmd(struct fault_env *fe, struct page *page)
+{
+	struct vm_area_struct *vma = fe->vma;
+	bool write = fe->flags & FAULT_FLAG_WRITE;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	pmd_t entry;
+	int ret;
+
+	if (!transhuge_vma_suitable(vma, haddr))
+		return VM_FAULT_FALLBACK;
+
+	ret = VM_FAULT_FALLBACK;
+
+	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
+	if (unlikely(!pmd_none(*fe->pmd)))
+		goto out;
+
+	// XXX: make flush_icache_page() aware about compound pages?
+	flush_icache_page(vma, page);
+
+	page = compound_head(page);
+	entry = mk_huge_pmd(page, vma->vm_page_prot);
+	if (write)
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+
+	add_mm_counter(vma->vm_mm, MM_FILEPAGES, HPAGE_PMD_NR);
+	page_add_file_rmap(page, true);
+
+	set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
+
+	update_mmu_cache_pmd(vma, haddr, fe->pmd);
+
+	/* fault is handled */
+	ret = 0;
+out:
+	spin_unlock(fe->ptl);
+	return ret;
+}
+
 /**
  * do_set_pte - setup new PTE entry for given page and add reverse page mapping.
  *
@@ -2846,9 +2897,19 @@ int do_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 	struct vm_area_struct *vma = fe->vma;
 	bool write = fe->flags & FAULT_FLAG_WRITE;
 	pte_t entry;
+	int ret;
+
+	if (pmd_none(*fe->pmd) && PageTransCompound(page)) {
+		/* THP on COW? */
+		VM_BUG_ON_PAGE(memcg, page);
+
+		ret = do_set_pmd(fe, page);
+		if (ret != VM_FAULT_FALLBACK)
+			return ret;
+	}
 
 	if (!fe->pte) {
-		int ret = pte_alloc_one_map(fe);
+		ret = pte_alloc_one_map(fe);
 		if (ret)
 			return ret;
 	}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
