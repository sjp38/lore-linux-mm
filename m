Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3FD36B026A
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:07:30 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g13so48951223ioj.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:07:30 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id iu4si5510808pac.93.2016.06.15.13.07.01
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:07:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 11/37] mm: introduce do_set_pmd()
Date: Wed, 15 Jun 2016 23:06:16 +0300
Message-Id: <1466021202-61880-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With postponed page table allocation we have chance to setup huge pages.
do_set_pte() calls do_set_pmd() if following criteria met:

 - page is compound;
 - pmd entry in pmd_none();
 - vma has suitable size and alignment;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |  2 ++
 mm/huge_memory.c        |  5 ----
 mm/memory.c             | 72 ++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/migrate.c            |  3 +--
 4 files changed, 74 insertions(+), 8 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 670ea0e3d138..3ef07cd7730c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -143,6 +143,8 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 struct page *get_huge_zero_page(void);
 void put_huge_zero_page(void);
 
+#define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 05088abe7576..b24b7993c369 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -795,11 +795,6 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
-{
-	return pmd_mkhuge(mk_pmd(page, prot));
-}
-
 static inline struct list_head *page_deferred_list(struct page *page)
 {
 	/*
diff --git a/mm/memory.c b/mm/memory.c
index 02a5491f0f17..6c0ebbc680d4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2921,6 +2921,66 @@ map_pte:
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
@@ -2940,9 +3000,19 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
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
index 7e6e9375d654..c7531ccf65f4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1984,8 +1984,7 @@ fail_putback:
 	}
 
 	orig_entry = *pmd;
-	entry = mk_pmd(new_page, vma->vm_page_prot);
-	entry = pmd_mkhuge(entry);
+	entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
 	/*
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
