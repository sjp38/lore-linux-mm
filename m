Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B6D706B025E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:52:52 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 63so17739890pfe.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:52:52 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bs10si5520592pad.73.2016.03.03.08.52.37
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:37 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 09/29] mm: introduce do_set_pmd()
Date: Thu,  3 Mar 2016 19:51:59 +0300
Message-Id: <1457023939-98083-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
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
 include/linux/huge_mm.h |  2 ++
 mm/huge_memory.c        |  8 ------
 mm/memory.c             | 72 ++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/migrate.c            |  3 +--
 4 files changed, 74 insertions(+), 11 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a9ec30594a81..c958e3db0a0e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -150,6 +150,8 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 
 struct page *get_huge_zero_page(void);
 
+#define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e0f8e4d63ffd..2cade3851b7a 100644
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
diff --git a/mm/memory.c b/mm/memory.c
index f8c986df8c63..3bb51a550bbb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2840,6 +2840,66 @@ map_pte:
 	return 0;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
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
+static int do_set_pmd(struct fault_env *fe, struct page *page)
+{
+	struct vm_area_struct *vma = fe->vma;
+	bool write = fe->flags & FAULT_FLAG_WRITE;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	pmd_t entry;
+	int i, ret;
+
+	if (!transhuge_vma_suitable(vma, haddr))
+		return VM_FAULT_FALLBACK;
+
+	ret = VM_FAULT_FALLBACK;
+	page = compound_head(page);
+
+	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
+	if (unlikely(!pmd_none(*fe->pmd)))
+		goto out;
+
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		flush_icache_page(vma, page + i);
+
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
+#else
+static int do_set_pmd(struct fault_env *fe, struct page *page)
+{
+	BUILD_BUG();
+	return 0;
+}
+#endif
+
 /**
  * alloc_set_pte - setup new PTE entry for given page and add reverse page
  * mapping. If needed, the fucntion allocates page table or use pre-allocated.
@@ -2859,9 +2919,19 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
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
diff --git a/mm/migrate.c b/mm/migrate.c
index d20276fffce7..5c9cd90334ea 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1820,8 +1820,7 @@ fail_putback:
 	}
 
 	orig_entry = *pmd;
-	entry = mk_pmd(new_page, vma->vm_page_prot);
-	entry = pmd_mkhuge(entry);
+	entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
 	/*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
