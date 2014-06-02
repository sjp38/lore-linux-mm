Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5B46B0038
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:36:52 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so822098pab.4
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:36:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xp2si17357178pbc.57.2014.06.02.14.36.50
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:36:51 -0700 (PDT)
Subject: [PATCH 03/10] mm: pagewalk: have generic code keep track of VMA
From: Dave Hansen <dave@sr71.net>
Date: Mon, 02 Jun 2014 14:36:48 -0700
References: <20140602213644.925A26D0@viggo.jf.intel.com>
In-Reply-To: <20140602213644.925A26D0@viggo.jf.intel.com>
Message-Id: <20140602213648.FEA8206D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

7 out of 9 of the page walkers need the VMA and pass it in some
way through mm_walk->private.  Let's add it in the page walker
infrastructure.

This will increase the number of find_vma() calls, but the VMA
cache should help us out pretty nicely here.  This is also quite
easy to optimize if this turns out to be an issue by skipping the
find_vma() call if 'addr' is still within our current
mm_walk->vma.

/proc/$pid/numa_map:
/proc/$pid/smaps:
	lots of stuff including vma (vma is a drop in the bucket)
	in a struct
/proc/$pid/clear_refs:
	passes vma plus an enum in a struct
/proc/$pid/pagemap:
openrisc:
	no VMA
MADV_WILLNEED:
	walk->private is set to vma
cgroup precharge:
	walk->private is set to vma
cgroup move charge:
	walk->private is set to vma
powerpc subpages:
	walk->private is set to vma

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/powerpc/mm/subpage-prot.c |    3 --
 b/fs/proc/task_mmu.c             |   25 ++++++---------------
 b/include/linux/mm.h             |    1 
 b/mm/madvise.c                   |    3 --
 b/mm/memcontrol.c                |    4 +--
 b/mm/pagewalk.c                  |   45 ++++++++++++++++++++++++++++++++++-----
 6 files changed, 52 insertions(+), 29 deletions(-)

diff -puN arch/powerpc/mm/subpage-prot.c~page-walker-pass-vma arch/powerpc/mm/subpage-prot.c
--- a/arch/powerpc/mm/subpage-prot.c~page-walker-pass-vma	2014-06-02 14:20:19.524817706 -0700
+++ b/arch/powerpc/mm/subpage-prot.c	2014-06-02 14:20:19.536818243 -0700
@@ -134,7 +134,7 @@ static void subpage_prot_clear(unsigned
 static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, struct mm_walk *walk)
 {
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	split_huge_page_pmd(vma, addr, pmd);
 	return 0;
 }
@@ -163,7 +163,6 @@ static void subpage_mark_vma_nohuge(stru
 		if (vma->vm_start >= (addr + len))
 			break;
 		vma->vm_flags |= VM_NOHUGEPAGE;
-		subpage_proto_walk.private = vma;
 		walk_page_range(vma->vm_start, vma->vm_end,
 				&subpage_proto_walk);
 		vma = vma->vm_next;
diff -puN fs/proc/task_mmu.c~page-walker-pass-vma fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~page-walker-pass-vma	2014-06-02 14:20:19.526817794 -0700
+++ b/fs/proc/task_mmu.c	2014-06-02 14:20:19.537818287 -0700
@@ -424,7 +424,6 @@ const struct file_operations proc_tid_ma
 
 #ifdef CONFIG_PROC_PAGE_MONITOR
 struct mem_size_stats {
-	struct vm_area_struct *vma;
 	unsigned long resident;
 	unsigned long shared_clean;
 	unsigned long shared_dirty;
@@ -443,7 +442,7 @@ static void smaps_pte_entry(pte_t ptent,
 		unsigned long ptent_size, struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	struct vm_area_struct *vma = mss->vma;
+	struct vm_area_struct *vma = walk->vma;
 	pgoff_t pgoff = linear_page_index(vma, addr);
 	struct page *page = NULL;
 	int mapcount;
@@ -495,7 +494,7 @@ static int smaps_pte_range(pmd_t *pmd, u
 			   struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	struct vm_area_struct *vma = mss->vma;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
 
@@ -588,7 +587,6 @@ static int show_smap(struct seq_file *m,
 	};
 
 	memset(&mss, 0, sizeof mss);
-	mss.vma = vma;
 	/* mmap_sem is held in m_start */
 	if (vma->vm_mm)
 		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
@@ -712,7 +710,6 @@ enum clear_refs_types {
 };
 
 struct clear_refs_private {
-	struct vm_area_struct *vma;
 	enum clear_refs_types type;
 };
 
@@ -748,7 +745,7 @@ static int clear_refs_pte_range(pmd_t *p
 				unsigned long end, struct mm_walk *walk)
 {
 	struct clear_refs_private *cp = walk->private;
-	struct vm_area_struct *vma = cp->vma;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte, ptent;
 	spinlock_t *ptl;
 	struct page *page;
@@ -828,7 +825,6 @@ static ssize_t clear_refs_write(struct f
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
-			cp.vma = vma;
 			/*
 			 * Writing 1 to /proc/pid/clear_refs affects all pages.
 			 *
@@ -1073,15 +1069,11 @@ static int pagemap_hugetlb_range(pte_t *
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
-	struct vm_area_struct *vma;
 	int err = 0;
 	int flags2;
 	pagemap_entry_t pme;
 
-	vma = find_vma(walk->mm, addr);
-	WARN_ON_ONCE(!vma);
-
-	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
+	if (walk->vma && (walk->vma->vm_flags & VM_SOFTDIRTY))
 		flags2 = __PM_SOFT_DIRTY;
 	else
 		flags2 = 0;
@@ -1241,7 +1233,6 @@ const struct file_operations proc_pagema
 #ifdef CONFIG_NUMA
 
 struct numa_maps {
-	struct vm_area_struct *vma;
 	unsigned long pages;
 	unsigned long anon;
 	unsigned long active;
@@ -1317,11 +1308,11 @@ static int gather_pte_stats(pmd_t *pmd,
 
 	md = walk->private;
 
-	if (pmd_trans_huge_lock(pmd, md->vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, walk->vma, &ptl) == 1) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
-		page = can_gather_numa_stats(huge_pte, md->vma, addr);
+		page = can_gather_numa_stats(huge_pte, walk->vma, addr);
 		if (page)
 			gather_stats(page, md, pte_dirty(huge_pte),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
@@ -1333,7 +1324,7 @@ static int gather_pte_stats(pmd_t *pmd,
 		return 0;
 	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	do {
-		struct page *page = can_gather_numa_stats(*pte, md->vma, addr);
+		struct page *page = can_gather_numa_stats(*pte, walk->vma, addr);
 		if (!page)
 			continue;
 		gather_stats(page, md, pte_dirty(*pte), 1);
@@ -1392,8 +1383,6 @@ static int show_numa_map(struct seq_file
 	/* Ensure we start with an empty set of numa_maps statistics. */
 	memset(md, 0, sizeof(*md));
 
-	md->vma = vma;
-
 	walk.hugetlb_entry = gather_hugetbl_stats;
 	walk.pmd_entry = gather_pte_stats;
 	walk.private = md;
diff -puN include/linux/mm.h~page-walker-pass-vma include/linux/mm.h
--- a/include/linux/mm.h~page-walker-pass-vma	2014-06-02 14:20:19.528817884 -0700
+++ b/include/linux/mm.h	2014-06-02 14:20:19.538818332 -0700
@@ -1118,6 +1118,7 @@ struct mm_walk {
 			     unsigned long addr, unsigned long next,
 			     struct mm_walk *walk);
 	struct mm_struct *mm;
+	struct vm_area_struct *vma;
 	void *private;
 };
 
diff -puN mm/madvise.c~page-walker-pass-vma mm/madvise.c
--- a/mm/madvise.c~page-walker-pass-vma	2014-06-02 14:20:19.529817929 -0700
+++ b/mm/madvise.c	2014-06-02 14:20:19.539818378 -0700
@@ -139,7 +139,7 @@ static int swapin_walk_pmd_entry(pmd_t *
 	unsigned long end, struct mm_walk *walk)
 {
 	pte_t *orig_pte;
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	unsigned long index;
 
 	if (pmd_none_or_trans_huge_or_clear_bad(pmd))
@@ -176,7 +176,6 @@ static void force_swapin_readahead(struc
 	struct mm_walk walk = {
 		.mm = vma->vm_mm,
 		.pmd_entry = swapin_walk_pmd_entry,
-		.private = vma,
 	};
 
 	walk_page_range(start, end, &walk);
diff -puN mm/memcontrol.c~page-walker-pass-vma mm/memcontrol.c
--- a/mm/memcontrol.c~page-walker-pass-vma	2014-06-02 14:20:19.532818064 -0700
+++ b/mm/memcontrol.c	2014-06-02 14:20:19.541818468 -0700
@@ -6786,7 +6786,7 @@ static int mem_cgroup_count_precharge_pt
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
 {
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
 
@@ -6962,7 +6962,7 @@ static int mem_cgroup_move_charge_pte_ra
 				struct mm_walk *walk)
 {
 	int ret = 0;
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
 	enum mc_target_type target_type;
diff -puN mm/pagewalk.c~page-walker-pass-vma mm/pagewalk.c
--- a/mm/pagewalk.c~page-walker-pass-vma	2014-06-02 14:20:19.533818109 -0700
+++ b/mm/pagewalk.c	2014-06-02 14:20:19.542818513 -0700
@@ -3,6 +3,38 @@
 #include <linux/sched.h>
 #include <linux/hugetlb.h>
 
+
+/*
+ * The VMA which applies to the current place in the
+ * page walk is tracked in walk->vma.  If there is
+ * no VMA covering the current area (when in a pte_hole)
+ * walk->vma will be NULL.
+ *
+ * If the area bing walked is covered by more than one
+ * VMA, then the first one will be set in walk->vma.
+ * Additional VMAs can be found by walking the VMA sibling
+ * list, or by calling this function or find_vma() directly.
+ *
+ * In a situation where the area being walked is not
+ * entirely covered by a VMA, the _first_ VMA which covers
+ * part of the area will be set in walk->vma.
+ */
+static void walk_update_vma(unsigned long addr, unsigned long end,
+		     struct mm_walk *walk)
+{
+	struct vm_area_struct *new_vma = find_vma(walk->mm, addr);
+
+	/*
+	 * find_vma() is not exact and returns the next VMA
+	 * ending after addr.  The vma we found may be outside
+	 * the range which we are walking, so clear it if so.
+	 */
+	if (new_vma && new_vma->vm_start >= end)
+		new_vma = NULL;
+
+	walk->vma = new_vma;
+}
+
 static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			  struct mm_walk *walk)
 {
@@ -15,6 +47,7 @@ static int walk_pte_range(pmd_t *pmd, un
 		if (err)
 		       break;
 		addr += PAGE_SIZE;
+		walk_update_vma(addr, addr + PAGE_SIZE, walk);
 		if (addr == end)
 			break;
 		pte++;
@@ -35,6 +68,7 @@ static int walk_pmd_range(pud_t *pud, un
 	do {
 again:
 		next = pmd_addr_end(addr, end);
+		walk_update_vma(addr, next, walk);
 		if (pmd_none(*pmd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
@@ -79,6 +113,7 @@ static int walk_pud_range(pgd_t *pgd, un
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
+		walk_update_vma(addr, next, walk);
 		if (pud_none_or_clear_bad(pud)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
@@ -105,10 +140,10 @@ static unsigned long hugetlb_entry_end(s
 	return boundary < end ? boundary : end;
 }
 
-static int walk_hugetlb_range(struct vm_area_struct *vma,
-			      unsigned long addr, unsigned long end,
+static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 			      struct mm_walk *walk)
 {
+	struct vm_area_struct *vma = walk->vma;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long next;
 	unsigned long hmask = huge_page_mask(h);
@@ -187,14 +222,14 @@ int walk_page_range(unsigned long addr,
 		struct vm_area_struct *vma = NULL;
 
 		next = pgd_addr_end(addr, end);
-
+		walk_update_vma(addr, next, walk);
 		/*
 		 * This function was not intended to be vma based.
 		 * But there are vma special cases to be handled:
 		 * - hugetlb vma's
 		 * - VM_PFNMAP vma's
 		 */
-		vma = find_vma(walk->mm, addr);
+		vma = walk->vma;
 		if (vma && (vma->vm_start <= addr)) {
 			/*
 			 * There are no page structures backing a VM_PFNMAP
@@ -219,7 +254,7 @@ int walk_page_range(unsigned long addr,
 				 * so walk through hugetlb entries within a
 				 * given vma.
 				 */
-				err = walk_hugetlb_range(vma, addr, next, walk);
+				err = walk_hugetlb_range(addr, next, walk);
 				if (err)
 					break;
 				pgd = pgd_offset(walk->mm, next);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
