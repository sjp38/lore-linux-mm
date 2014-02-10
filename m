Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id A938D6B0044
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 16:45:21 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id c13so3209799eek.19
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:45:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k3si28496247eep.57.2014.02.10.13.45.18
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 13:45:19 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 06/11] numa_maps: redefine callback functions for page table walker
Date: Mon, 10 Feb 2014 16:44:31 -0500
Message-Id: <1392068676-30627-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

gather_pte_stats() connected to pmd_entry() does both of pmd loop and
pte loop. So this patch moves pte part into pte_entry().

ChangeLog v2:
- rebase onto mmots

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 54 ++++++++++++++++++++++++++----------------------------
 1 file changed, 26 insertions(+), 28 deletions(-)

diff --git v3.14-rc2.orig/fs/proc/task_mmu.c v3.14-rc2/fs/proc/task_mmu.c
index 7ed7c88f0687..8b23bbcc5e04 100644
--- v3.14-rc2.orig/fs/proc/task_mmu.c
+++ v3.14-rc2/fs/proc/task_mmu.c
@@ -1193,7 +1193,6 @@ const struct file_operations proc_pagemap_operations = {
 #ifdef CONFIG_NUMA
 
 struct numa_maps {
-	struct vm_area_struct *vma;
 	unsigned long pages;
 	unsigned long anon;
 	unsigned long active;
@@ -1259,43 +1258,41 @@ static struct page *can_gather_numa_stats(pte_t pte, struct vm_area_struct *vma,
 	return page;
 }
 
-static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
+static int gather_pte_stats(pte_t *pte, unsigned long addr,
 		unsigned long end, struct mm_walk *walk)
 {
-	struct numa_maps *md;
-	spinlock_t *ptl;
-	pte_t *orig_pte;
-	pte_t *pte;
+	struct numa_maps *md = walk->private;
 
-	md = walk->private;
+	struct page *page = can_gather_numa_stats(*pte, walk->vma, addr);
+	if (!page)
+		return 0;
+	gather_stats(page, md, pte_dirty(*pte), 1);
+	return 0;
+}
+
+static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
+		unsigned long end, struct mm_walk *walk)
+{
+	struct numa_maps *md = walk->private;
+	struct vm_area_struct *vma = walk->vma;
+	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, md->vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
-		page = can_gather_numa_stats(huge_pte, md->vma, addr);
+		page = can_gather_numa_stats(huge_pte, vma, addr);
 		if (page)
 			gather_stats(page, md, pte_dirty(huge_pte),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
 		spin_unlock(ptl);
-		return 0;
+		/* don't call gather_pte_stats() */
+		walk->skip = 1;
 	}
-
-	if (pmd_trans_unstable(pmd))
-		return 0;
-	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
-	do {
-		struct page *page = can_gather_numa_stats(*pte, md->vma, addr);
-		if (!page)
-			continue;
-		gather_stats(page, md, pte_dirty(*pte), 1);
-
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(orig_pte, ptl);
 	return 0;
 }
 #ifdef CONFIG_HUGETLB_PAGE
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
 	struct numa_maps *md;
@@ -1314,7 +1311,7 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 }
 
 #else
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
 	return 0;
@@ -1344,12 +1341,12 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	/* Ensure we start with an empty set of numa_maps statistics. */
 	memset(md, 0, sizeof(*md));
 
-	md->vma = vma;
-
-	walk.hugetlb_entry = gather_hugetbl_stats;
-	walk.pmd_entry = gather_pte_stats;
+	walk.hugetlb_entry = gather_hugetlb_stats;
+	walk.pmd_entry = gather_pmd_stats;
+	walk.pte_entry = gather_pte_stats;
 	walk.private = md;
 	walk.mm = mm;
+	walk.vma = vma;
 
 	pol = get_vma_policy(task, vma, vma->vm_start);
 	mpol_to_str(buffer, sizeof(buffer), pol);
@@ -1380,6 +1377,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	if (is_vm_hugetlb_page(vma))
 		seq_printf(m, " huge");
 
+	/* mmap_sem is held by m_start */
 	walk_page_range(vma->vm_start, vma->vm_end, &walk);
 
 	if (!md->pages)
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
