Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3ADAF6B0256
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 10:14:41 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id yy13so14886451pab.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 07:14:41 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id p11si9848291par.72.2016.02.03.07.14.40
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 07:14:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] rmap: extend try_to_unmap() to be usable by split_huge_page()
Date: Wed,  3 Feb 2016 18:14:17 +0300
Message-Id: <1454512459-94334-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 23a03fbeef61..1fdde1ee7042 100644
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
index 581709e837b7..4213c76c8434 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2970,15 +2970,12 @@ out:
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
index a9cffb784502..2cafd48caf85 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1435,6 +1435,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		goto out;
 
+	if (flags & TTU_SPLIT_HUGE_PMD)
+		split_huge_pmd_address(vma, address);
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
 		goto out;
@@ -1580,10 +1582,10 @@ static bool invalid_migration_vma(struct vm_area_struct *vma, void *arg)
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
@@ -1610,12 +1612,10 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
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
@@ -1627,9 +1627,12 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
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
@@ -1637,6 +1640,11 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
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
