Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7D394828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:09:55 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id yy13so66113533pab.3
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:09:55 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id we2si16537922pac.127.2016.01.31.04.09.50
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:09:50 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v4 5/8] procfs: Add support for PUDs to smaps, clear_refs and pagemap
Date: Sun, 31 Jan 2016 23:09:32 +1100
Message-Id: <1454242175-16870-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

Because there's no 'struct page' for DAX THPs, a lot of this code is
simpler than the PMD code it mimics.  Extra code would need to be added
to support PUDs of anonymous or page-cache THPs.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/proc/task_mmu.c | 109 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 109 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3ba3c64..ea20ce4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -586,6 +586,33 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 }
 #endif
 
+static int smaps_pud_range(pud_t *pud, unsigned long addr, unsigned long end,
+		struct mm_walk *walk)
+{
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	struct vm_area_struct *vma = walk->vma;
+	struct mem_size_stats *mss = walk->private;
+
+	if (is_huge_zero_pud(*pud))
+		return 0;
+
+	mss->resident += HPAGE_PUD_SIZE;
+	if (vma->vm_flags & VM_SHARED) {
+		if (pud_dirty(*pud))
+			mss->shared_dirty += HPAGE_PUD_SIZE;
+		else
+			mss->shared_clean += HPAGE_PUD_SIZE;
+	} else {
+		if (pud_dirty(*pud))
+			mss->private_dirty += HPAGE_PUD_SIZE;
+		else
+			mss->private_clean += HPAGE_PUD_SIZE;
+	}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
+	return 0;
+}
+
 static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			   struct mm_walk *walk)
 {
@@ -707,6 +734,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 	struct vm_area_struct *vma = v;
 	struct mem_size_stats mss;
 	struct mm_walk smaps_walk = {
+		.pud_entry = smaps_pud_range,
 		.pmd_entry = smaps_pte_range,
 #ifdef CONFIG_HUGETLB_PAGE
 		.hugetlb_entry = smaps_hugetlb_range,
@@ -889,13 +917,50 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 
 	set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
 }
+static inline void clear_soft_dirty_pud(struct vm_area_struct *vma,
+		unsigned long addr, pud_t *pudp)
+{
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	pud_t pud = pudp_huge_get_and_clear(vma->vm_mm, addr, pudp);
+
+	pud = pud_wrprotect(pud);
+	pud = pud_clear_soft_dirty(pud);
+
+	if (vma->vm_flags & VM_SOFTDIRTY)
+		vma->vm_flags &= ~VM_SOFTDIRTY;
+
+	set_pud_at(vma->vm_mm, addr, pudp, pud);
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+}
 #else
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmdp)
 {
 }
+static inline void clear_soft_dirty_pud(struct vm_area_struct *vma,
+		unsigned long addr, pud_t *pudp)
+{
+}
 #endif
 
+static int clear_refs_pud_range(pud_t *pud, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	struct clear_refs_private *cp = walk->private;
+	struct vm_area_struct *vma = walk->vma;
+
+	if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
+		clear_soft_dirty_pud(vma, addr, pud);
+	} else {
+		/* Clear accessed and referenced bits. */
+		pudp_test_and_clear_young(vma, addr, pud);
+	}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
+	return 0;
+}
+
 static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
@@ -1006,6 +1071,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			.type = type,
 		};
 		struct mm_walk clear_refs_walk = {
+			.pud_entry = clear_refs_pud_range,
 			.pmd_entry = clear_refs_pte_range,
 			.test_walk = clear_refs_test_walk,
 			.mm = mm,
@@ -1170,6 +1236,48 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 	return make_pme(frame, flags);
 }
 
+static int pagemap_pud_range(pud_t *pudp, unsigned long addr, unsigned long end,
+			     struct mm_walk *walk)
+{
+	int err = 0;
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	struct vm_area_struct *vma = walk->vma;
+	struct pagemapread *pm = walk->private;
+	u64 flags = 0, frame = 0;
+	pud_t pud = *pudp;
+
+	if ((vma->vm_flags & VM_SOFTDIRTY) || pud_soft_dirty(pud))
+		flags |= PM_SOFT_DIRTY;
+
+	/*
+	 * Currently pud for thp is always present because thp
+	 * can not be swapped-out, migrated, or HWPOISONed
+	 * (split in such cases instead.)
+	 * This if-check is just to prepare for future implementation.
+	 */
+	if (pud_present(pud)) {
+		flags |= PM_PRESENT;
+		if (!(vma->vm_flags & VM_SHARED))
+			flags |= PM_MMAP_EXCLUSIVE;
+
+		if (pm->show_pfn)
+			frame = pud_pfn(pud) +
+					((addr & ~PUD_MASK) >> PAGE_SHIFT);
+
+		for (; addr != end; addr += PAGE_SIZE) {
+			pagemap_entry_t pme = make_pme(frame, flags);
+
+			err = add_to_pagemap(addr, &pme, pm);
+			if (err)
+				break;
+			if (pm->show_pfn && (flags & PM_PRESENT))
+				frame++;
+		}
+	}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+	return err;
+}
+
 static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
@@ -1349,6 +1457,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!pm.buffer)
 		goto out_mm;
 
+	pagemap_walk.pud_entry = pagemap_pud_range;
 	pagemap_walk.pmd_entry = pagemap_pmd_range;
 	pagemap_walk.pte_hole = pagemap_pte_hole;
 #ifdef CONFIG_HUGETLB_PAGE
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
