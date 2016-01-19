Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD366B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 08:24:12 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id e65so175968565pfe.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 05:24:12 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id f2si7875873pas.32.2016.01.19.05.24.10
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 05:24:11 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: change pmd_trans_huge_lock() interface to return ptl
Date: Tue, 19 Jan 2016 16:24:01 +0300
Message-Id: <1453209841-56158-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

After THP refcounting rework we have only two possible return values
from pmd_trans_huge_lock(): success and failure. Return-by-pointer for
ptl doesn't make much sense in this case.

Let's convert pmd_trans_huge_lock() to return ptl on success and NULL on
failure.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c      | 12 ++++++++----
 include/linux/huge_mm.h | 16 ++++++++--------
 mm/huge_memory.c        | 24 ++++++++++++++----------
 mm/memcontrol.c         |  6 ++++--
 mm/mincore.c            |  3 ++-
 5 files changed, 36 insertions(+), 25 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 71ffc91060f6..85d16c67c33e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -602,7 +602,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
 		smaps_pmd_entry(pmd, addr, walk);
 		spin_unlock(ptl);
 		return 0;
@@ -913,7 +914,8 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	struct page *page;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
 		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
 			clear_soft_dirty_pmd(vma, addr, pmd);
 			goto out;
@@ -1187,7 +1189,8 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 	int err = 0;
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	if (pmd_trans_huge_lock(pmdp, vma, &ptl)) {
+	ptl = pmd_trans_huge_lock(pmdp, vma);
+	if (ptl) {
 		u64 flags = 0, frame = 0;
 		pmd_t pmd = *pmdp;
 
@@ -1519,7 +1522,8 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	pte_t *orig_pte;
 	pte_t *pte;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index cfe81e10bd54..459fd25b378e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -120,15 +120,15 @@ extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    long adjust_next);
-extern bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
-		spinlock_t **ptl);
+extern spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd,
+		struct vm_area_struct *vma);
 /* mmap_sem must be held on entry */
-static inline bool pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
-		spinlock_t **ptl)
+static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
+		struct vm_area_struct *vma)
 {
 	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
 	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
-		return __pmd_trans_huge_lock(pmd, vma, ptl);
+		return __pmd_trans_huge_lock(pmd, vma);
 	else
 		return false;
 }
@@ -190,10 +190,10 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 long adjust_next)
 {
 }
-static inline bool pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
-		spinlock_t **ptl)
+static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
+		struct vm_area_struct *vma)
 {
-	return false;
+	return NULL;
 }
 
 static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 21fda6a10e89..ba655d4d6864 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1560,7 +1560,8 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	struct mm_struct *mm = tlb->mm;
 	int ret = 0;
 
-	if (!pmd_trans_huge_lock(pmd, vma, &ptl))
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (!ptl)
 		goto out_unlocked;
 
 	orig_pmd = *pmd;
@@ -1627,7 +1628,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	pmd_t orig_pmd;
 	spinlock_t *ptl;
 
-	if (!__pmd_trans_huge_lock(pmd, vma, &ptl))
+	ptl = __pmd_trans_huge_lock(pmd, vma);
+	if (!ptl)
 		return 0;
 	/*
 	 * For architectures like ppc64 we look at deposited pgtable
@@ -1690,7 +1692,8 @@ bool move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 	 * We don't have to worry about the ordering of src and dst
 	 * ptlocks because exclusive mmap_sem prevents deadlock.
 	 */
-	if (__pmd_trans_huge_lock(old_pmd, vma, &old_ptl)) {
+	old_ptl = __pmd_trans_huge_lock(old_pmd, vma);
+	if (old_ptl) {
 		new_ptl = pmd_lockptr(mm, new_pmd);
 		if (new_ptl != old_ptl)
 			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
@@ -1724,7 +1727,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl)) {
+	ptl = __pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
 		pmd_t entry;
 		bool preserve_write = prot_numa && pmd_write(*pmd);
 		ret = 1;
@@ -1760,14 +1764,14 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
  * Note that if it returns true, this routine returns without unlocking page
  * table lock. So callers must unlock it.
  */
-bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
-		spinlock_t **ptl)
+spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 {
-	*ptl = pmd_lock(vma->vm_mm, pmd);
+	spinlock_t *ptl;
+	ptl = pmd_lock(vma->vm_mm, pmd);
 	if (likely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
-		return true;
-	spin_unlock(*ptl);
-	return false;
+		return ptl;
+	spin_unlock(ptl);
+	return NULL;
 }
 
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0eda67376df4..2d91438cf14a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4673,7 +4673,8 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
 		spin_unlock(ptl);
@@ -4861,7 +4862,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	union mc_target target;
 	struct page *page;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
 		if (mc.precharge < HPAGE_PMD_NR) {
 			spin_unlock(ptl);
 			return 0;
diff --git a/mm/mincore.c b/mm/mincore.c
index 2a565ed8bb49..563f32045490 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -117,7 +117,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	unsigned char *vec = walk->private;
 	int nr = (end - addr) >> PAGE_SHIFT;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
 		memset(vec, 1, nr);
 		spin_unlock(ptl);
 		goto out;
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
