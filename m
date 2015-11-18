Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 741476B0257
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:25:44 -0500 (EST)
Received: by pacej9 with SMTP id ej9so59396494pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:25:44 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tq4si7233407pab.243.2015.11.18.15.25.42
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 15:25:42 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/9] mm: introduce do_set_pmd()
Date: Thu, 19 Nov 2015 01:25:31 +0200
Message-Id: <1447889136-6928-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With postponed page table allocation we have chance to setup huge pages.
do_set_pte() calls do_set_pmd() if following criteria met:

 - page is compound;
 - pmd entry in pmd_none();
 - vma has suitable size and alignment;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |  8 -------
 mm/internal.h    |  8 +++++++
 mm/memory.c      | 67 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 74 insertions(+), 9 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 353210715fd9..9c1db950341a 100644
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
index 2d1ce8269183..2bc5b41612ae 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -36,6 +36,14 @@
 
 int do_swap_page(struct fault_env *fe, pte_t orig_pte);
 
+static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
+{
+	pmd_t entry;
+	entry = mk_pmd(page, prot);
+	entry = pmd_mkhuge(entry);
+	return entry;
+}
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/memory.c b/mm/memory.c
index 7f742e03c94b..522279922946 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -62,6 +62,7 @@
 #include <linux/dma-debug.h>
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/khugepaged.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -2820,6 +2821,58 @@ map_pte:
 	return 0;
 }
 
+static int do_set_pmd(struct fault_env *fe, struct page *page)
+{
+	struct vm_area_struct *vma = fe->vma;
+	bool write = fe->flags & FAULT_FLAG_WRITE;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	pmd_t entry;
+	int ret;
+
+	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
+		return VM_FAULT_OOM;
+
+	/* fallback to pte mapping */
+	ret = 0;
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
+	ret = VM_FAULT_NOPAGE;
+out:
+	spin_unlock(fe->ptl);
+	return ret;
+}
+
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
 /**
  * do_set_pte - setup new PTE entry for given page and add reverse page mapping.
  *
@@ -2837,10 +2890,22 @@ int do_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 {
 	struct vm_area_struct *vma = fe->vma;
 	bool write = fe->flags & FAULT_FLAG_WRITE;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
 	pte_t entry;
+	int ret;
+
+	if (pmd_none(*fe->pmd) && PageTransCompound(page) &&
+			transhuge_vma_suitable(vma, haddr)) {
+		/* THP on COW? */
+		VM_BUG_ON_PAGE(memcg, page);
+
+		ret = do_set_pmd(fe, page);
+		if (ret)
+			return ret;
+	}
 
 	if (!fe->pte) {
-		int ret = pte_alloc_one_map(fe);
+		ret = pte_alloc_one_map(fe);
 		if (ret)
 			return ret;
 	}
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
