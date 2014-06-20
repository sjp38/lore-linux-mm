Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id DE28D6B0068
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:12:12 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so4381290wes.0
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:12:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id eu5si3937093wic.47.2014.06.20.13.12.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jun 2014 13:12:11 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 12/13] mm: /proc/pid/clear_refs: avoid split_huge_page()
Date: Fri, 20 Jun 2014 16:11:38 -0400
Message-Id: <1403295099-6407-13-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Andrea Arcangeli <aarcange@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently pagewalker splits all THP pages on any clear_refs request.  It's
not necessary.  We can handle this on PMD level.

One side effect is that soft dirty will potentially see more dirty memory,
since we will mark whole THP page dirty at once.

Sanity checked with CRIU test suite. More testing is required.

ChangeLog:
- move code for thp to clear_refs_pte_range()

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 fs/proc/task_mmu.c | 47 ++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 44 insertions(+), 3 deletions(-)

diff --git v3.16-rc1.orig/fs/proc/task_mmu.c v3.16-rc1/fs/proc/task_mmu.c
index ac50a829320a..2acbe144152c 100644
--- v3.16-rc1.orig/fs/proc/task_mmu.c
+++ v3.16-rc1/fs/proc/task_mmu.c
@@ -719,10 +719,10 @@ struct clear_refs_private {
 	enum clear_refs_types type;
 };
 
+#ifdef CONFIG_MEM_SOFT_DIRTY
 static inline void clear_soft_dirty(struct vm_area_struct *vma,
 		unsigned long addr, pte_t *pte)
 {
-#ifdef CONFIG_MEM_SOFT_DIRTY
 	/*
 	 * The soft-dirty tracker uses #PF-s to catch writes
 	 * to pages, so write-protect the pte as well. See the
@@ -741,9 +741,35 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 	}
 
 	set_pte_at(vma->vm_mm, addr, pte, ptent);
-#endif
 }
 
+static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
+		unsigned long addr, pmd_t *pmdp)
+{
+	pmd_t pmd = *pmdp;
+
+	pmd = pmd_wrprotect(pmd);
+	pmd = pmd_clear_flags(pmd, _PAGE_SOFT_DIRTY);
+
+	if (vma->vm_flags & VM_SOFTDIRTY)
+		vma->vm_flags &= ~VM_SOFTDIRTY;
+
+	set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
+}
+
+#else
+
+static inline void clear_soft_dirty(struct vm_area_struct *vma,
+		unsigned long addr, pte_t *pte)
+{
+}
+
+static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
+		unsigned long addr, pmd_t *pmdp)
+{
+}
+#endif
+
 static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
@@ -753,7 +779,22 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	struct page *page;
 
-	split_huge_page_pmd(vma, addr, pmd);
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
+			clear_soft_dirty_pmd(vma, addr, pmd);
+			goto out;
+		}
+
+		page = pmd_page(*pmd);
+
+		/* Clear accessed and referenced bits. */
+		pmdp_test_and_clear_young(vma, addr, pmd);
+		ClearPageReferenced(page);
+out:
+		spin_unlock(ptl);
+		return 0;
+	}
+
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
