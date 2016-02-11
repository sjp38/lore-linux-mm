Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 384406B0253
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:22:09 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id c10so30663406pfc.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:22:09 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 184si12960089pfa.13.2016.02.11.06.22.04
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 03/28] rmap: extend try_to_unmap() to be usable by split_huge_page()
Date: Thu, 11 Feb 2016 17:21:31 +0300
Message-Id: <1455200516-132137-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch add support for two ttu_flags:

  - TTU_SPLIT_HUGE_PMD would split PMD if it's there, before trying to
    unmap page;

  - TTU_RMAP_LOCKED indicates that caller holds relevant rmap lock;

Apart these flags, patch changes rwc->done to !page_mapcount()
instead of !page_mapped(). try_to_unmap() works on pte level, so we
really interested if this small pages is mapped, not compound page
it's part of.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |  7 +++++++
 include/linux/rmap.h    |  3 +++
 mm/huge_memory.c        |  5 +----
 mm/rmap.c               | 24 ++++++++++++++++--------
 4 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 459fd25b378e..c47067151ffd 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -111,6 +111,9 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			__split_huge_pmd(__vma, __pmd, __address);	\
 	}  while (0)
 
+
+void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address);
+
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
@@ -178,6 +181,10 @@ static inline int split_huge_page(struct page *page)
 static inline void deferred_split_huge_page(struct page *page) {}
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
+
+static inline void split_huge_pmd_address(struct vm_area_struct *vma,
+		unsigned long address) {}
+
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
 {
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index a5875e9b4a27..3d975e2252d4 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -86,6 +86,7 @@ enum ttu_flags {
 	TTU_MIGRATION = 2,		/* migration mode */
 	TTU_MUNLOCK = 4,		/* munlock mode */
 	TTU_LZFREE = 8,			/* lazy free mode */
+	TTU_SPLIT_HUGE_PMD = 16,	/* split huge PMD if any */
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
@@ -93,6 +94,8 @@ enum ttu_flags {
 	TTU_BATCH_FLUSH = (1 << 11),	/* Batch TLB flushes where possible
 					 * and caller guarantees they will
 					 * do a final flush if necessary */
+	TTU_RMAP_LOCKED = (1 << 12)	/* do not grab rmap lock:
+					 * caller holds it */
 };
 
 #ifdef CONFIG_MMU
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2057a3b7cc24..801d4f9aac80 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3049,15 +3049,12 @@ out:
 	}
 }
 
-static void split_huge_pmd_address(struct vm_area_struct *vma,
-				    unsigned long address)
+void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 
-	VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
-
 	pgd = pgd_offset(vma->vm_mm, address);
 	if (!pgd_present(*pgd))
 		return;
diff --git a/mm/rmap.c b/mm/rmap.c
index 30b739ce0ffa..945933a01010 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1431,6 +1431,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		goto out;
 
+	if (flags & TTU_SPLIT_HUGE_PMD)
+		split_huge_pmd_address(vma, address);
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
 		goto out;
@@ -1576,10 +1578,10 @@ static bool invalid_migration_vma(struct vm_area_struct *vma, void *arg)
 	return is_vma_temporary_stack(vma);
 }
 
-static int page_not_mapped(struct page *page)
+static int page_mapcount_is_zero(struct page *page)
 {
-	return !page_mapped(page);
-};
+	return !page_mapcount(page);
+}
 
 /**
  * try_to_unmap - try to remove all page table mappings to a page
@@ -1606,12 +1608,10 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
 		.arg = &rp,
-		.done = page_not_mapped,
+		.done = page_mapcount_is_zero,
 		.anon_lock = page_lock_anon_vma_read,
 	};
 
-	VM_BUG_ON_PAGE(!PageHuge(page) && PageTransHuge(page), page);
-
 	/*
 	 * During exec, a temporary VMA is setup and later moved.
 	 * The VMA is moved under the anon_vma lock but not the
@@ -1623,9 +1623,12 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	if ((flags & TTU_MIGRATION) && !PageKsm(page) && PageAnon(page))
 		rwc.invalid_vma = invalid_migration_vma;
 
-	ret = rmap_walk(page, &rwc);
+	if (flags & TTU_RMAP_LOCKED)
+		ret = rmap_walk_locked(page, &rwc);
+	else
+		ret = rmap_walk(page, &rwc);
 
-	if (ret != SWAP_MLOCK && !page_mapped(page)) {
+	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
 		ret = SWAP_SUCCESS;
 		if (rp.lazyfreed && !PageDirty(page))
 			ret = SWAP_LZFREE;
@@ -1633,6 +1636,11 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	return ret;
 }
 
+static int page_not_mapped(struct page *page)
+{
+	return !page_mapped(page);
+};
+
 /**
  * try_to_munlock - try to munlock a page
  * @page: the page to be munlocked
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
