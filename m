Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 369F06B003C
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 13:37:41 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so7673394pdi.13
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 10:37:40 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 06/11] numa_maps: redefine callback functions for page table walker
Date: Mon, 14 Oct 2013 13:37:05 -0400
Message-Id: <1381772230-26878-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1381772230-26878-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1381772230-26878-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org

gather_pte_stats() connected to pmd_entry() does both of pmd loop and
pte loop. So this patch moves pte part into pte_entry().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 53 +++++++++++++++++++++++++----------------------------
 1 file changed, 25 insertions(+), 28 deletions(-)

diff --git v3.12-rc4.orig/fs/proc/task_mmu.c v3.12-rc4/fs/proc/task_mmu.c
index 21e5828..e3e03bc 100644
--- v3.12-rc4.orig/fs/proc/task_mmu.c
+++ v3.12-rc4/fs/proc/task_mmu.c
@@ -1199,7 +1199,6 @@ const struct file_operations proc_pagemap_operations = {
 #ifdef CONFIG_NUMA
 
 struct numa_maps {
-	struct vm_area_struct *vma;
 	unsigned long pages;
 	unsigned long anon;
 	unsigned long active;
@@ -1265,43 +1264,40 @@ static struct page *can_gather_numa_stats(pte_t pte, struct vm_area_struct *vma,
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
 
-	if (pmd_trans_huge_lock(pmd, md->vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma) == 1) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
-		page = can_gather_numa_stats(huge_pte, md->vma, addr);
+		page = can_gather_numa_stats(huge_pte, vma, addr);
 		if (page)
 			gather_stats(page, md, pte_dirty(huge_pte),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
 		spin_unlock(&walk->mm->page_table_lock);
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
@@ -1320,7 +1316,7 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 }
 
 #else
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
 	return 0;
@@ -1350,12 +1346,12 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
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
 	n = mpol_to_str(buffer, sizeof(buffer), pol);
@@ -1388,6 +1384,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	if (is_vm_hugetlb_page(vma))
 		seq_printf(m, " huge");
 
+	/* mmap_sem is held by m_start */
 	walk_page_range(vma->vm_start, vma->vm_end, &walk);
 
 	if (!md->pages)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
