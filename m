Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id D1CCE280250
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:37:50 -0400 (EDT)
Received: by lagx9 with SMTP id x9so8425283lag.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:37:50 -0700 (PDT)
Received: from forward-corp1o.mail.yandex.net (forward-corp1o.mail.yandex.net. [37.140.190.172])
        by mx.google.com with ESMTPS id ew10si1268838lac.11.2015.07.14.08.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 08:37:49 -0700 (PDT)
Subject: [PATCH v4 3/5] pagemap: rework hugetlb and thp report
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 14 Jul 2015 18:37:39 +0300
Message-ID: <20150714153738.29844.39039.stgit@buzz>
In-Reply-To: <20150714152516.29844.69929.stgit@buzz>
References: <20150714152516.29844.69929.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

This patch moves pmd dissection out of reporting loop: huge pages
are reported as bunch of normal pages with contiguous PFNs.

Add missing "FILE" bit in hugetlb vmas.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/proc/task_mmu.c |  100 +++++++++++++++++++++++-----------------------------
 1 file changed, 44 insertions(+), 56 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c05db6acdc35..040721fa405a 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1038,33 +1038,7 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 	return make_pme(frame, flags);
 }
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static pagemap_entry_t thp_pmd_to_pagemap_entry(struct pagemapread *pm,
-		pmd_t pmd, int offset, u64 flags)
-{
-	u64 frame = 0;
-
-	/*
-	 * Currently pmd for thp is always present because thp can not be
-	 * swapped-out, migrated, or HWPOISONed (split in such cases instead.)
-	 * This if-check is just to prepare for future implementation.
-	 */
-	if (pmd_present(pmd)) {
-		frame = pmd_pfn(pmd) + offset;
-		flags |= PM_PRESENT;
-	}
-
-	return make_pme(frame, flags);
-}
-#else
-static pagemap_entry_t thp_pmd_to_pagemap_entry(struct pagemapread *pm,
-		pmd_t pmd, int offset, u64 flags)
-{
-	return make_pme(0, 0);
-}
-#endif
-
-static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
 	struct vm_area_struct *vma = walk->vma;
@@ -1073,35 +1047,48 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte, *orig_pte;
 	int err = 0;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		u64 flags = 0;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (pmd_trans_huge_lock(pmdp, vma, &ptl) == 1) {
+		u64 flags = 0, frame = 0;
+		pmd_t pmd = *pmdp;
 
-		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
+		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
 			flags |= PM_SOFT_DIRTY;
 
+		/*
+		 * Currently pmd for thp is always present because thp
+		 * can not be swapped-out, migrated, or HWPOISONed
+		 * (split in such cases instead.)
+		 * This if-check is just to prepare for future implementation.
+		 */
+		if (pmd_present(pmd)) {
+			flags |= PM_PRESENT;
+			frame = pmd_pfn(pmd) +
+				((addr & ~PMD_MASK) >> PAGE_SHIFT);
+		}
+
 		for (; addr != end; addr += PAGE_SIZE) {
-			unsigned long offset;
-			pagemap_entry_t pme;
+			pagemap_entry_t pme = make_pme(frame, flags);
 
-			offset = (addr & ~PAGEMAP_WALK_MASK) >>
-					PAGE_SHIFT;
-			pme = thp_pmd_to_pagemap_entry(pm, *pmd, offset, flags);
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
 				break;
+			if (flags & PM_PRESENT)
+				frame++;
 		}
 		spin_unlock(ptl);
 		return err;
 	}
 
-	if (pmd_trans_unstable(pmd))
+	if (pmd_trans_unstable(pmdp))
 		return 0;
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 	/*
 	 * We can assume that @vma always points to a valid one and @end never
 	 * goes beyond vma->vm_end.
 	 */
-	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	orig_pte = pte = pte_offset_map_lock(walk->mm, pmdp, addr, &ptl);
 	for (; addr < end; pte++, addr += PAGE_SIZE) {
 		pagemap_entry_t pme;
 
@@ -1118,39 +1105,40 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 }
 
 #ifdef CONFIG_HUGETLB_PAGE
-static pagemap_entry_t huge_pte_to_pagemap_entry(struct pagemapread *pm,
-					pte_t pte, int offset, u64 flags)
-{
-	u64 frame = 0;
-
-	if (pte_present(pte)) {
-		frame = pte_pfn(pte) + offset;
-		flags |= PM_PRESENT;
-	}
-
-	return make_pme(frame, flags);
-}
-
 /* This function walks within one hugetlb entry in the single call */
-static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
+static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
 				 unsigned long addr, unsigned long end,
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
 	struct vm_area_struct *vma = walk->vma;
+	u64 flags = 0, frame = 0;
 	int err = 0;
-	u64 flags = 0;
-	pagemap_entry_t pme;
+	pte_t pte;
 
 	if (vma->vm_flags & VM_SOFTDIRTY)
 		flags |= PM_SOFT_DIRTY;
 
+	pte = huge_ptep_get(ptep);
+	if (pte_present(pte)) {
+		struct page *page = pte_page(pte);
+
+		if (!PageAnon(page))
+			flags |= PM_FILE;
+
+		flags |= PM_PRESENT;
+		frame = pte_pfn(pte) +
+			((addr & ~hmask) >> PAGE_SHIFT);
+	}
+
 	for (; addr != end; addr += PAGE_SIZE) {
-		int offset = (addr & ~hmask) >> PAGE_SHIFT;
-		pme = huge_pte_to_pagemap_entry(pm, *pte, offset, flags);
+		pagemap_entry_t pme = make_pme(frame, flags);
+
 		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			return err;
+		if (flags & PM_PRESENT)
+			frame++;
 	}
 
 	cond_resched();
@@ -1214,7 +1202,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!pm.buffer)
 		goto out_mm;
 
-	pagemap_walk.pmd_entry = pagemap_pte_range;
+	pagemap_walk.pmd_entry = pagemap_pmd_range;
 	pagemap_walk.pte_hole = pagemap_pte_hole;
 #ifdef CONFIG_HUGETLB_PAGE
 	pagemap_walk.hugetlb_entry = pagemap_hugetlb_range;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
