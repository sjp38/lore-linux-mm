Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1DEF66B0036
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 17:45:59 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so1552642pdj.39
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 14:45:58 -0700 (PDT)
Received: from psmtp.com ([74.125.245.146])
        by mx.google.com with SMTP id y7si34885pbi.143.2013.10.30.14.45.57
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:45:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 03/11] smaps: redefine callback functions for page table walker
Date: Wed, 30 Oct 2013 17:44:51 -0400
Message-Id: <1383169499-25144-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

smaps_pte_range() connected to pmd_entry() does both of pmd loop and pte loop.
So this patch moves pte part into smaps_pte() on pte_entry() as expected by
the name.

ChangeLog v2:
- rebase onto mmots

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 47 +++++++++++++++++------------------------------
 1 file changed, 17 insertions(+), 30 deletions(-)

diff --git v3.12-rc7-mmots-2013-10-29-16-24.orig/fs/proc/task_mmu.c v3.12-rc7-mmots-2013-10-29-16-24/fs/proc/task_mmu.c
index 9736142..ed79a9c 100644
--- v3.12-rc7-mmots-2013-10-29-16-24.orig/fs/proc/task_mmu.c
+++ v3.12-rc7-mmots-2013-10-29-16-24/fs/proc/task_mmu.c
@@ -444,7 +444,6 @@ const struct file_operations proc_tid_maps_operations = {
 
 #ifdef CONFIG_PROC_PAGE_MONITOR
 struct mem_size_stats {
-	struct vm_area_struct *vma;
 	unsigned long resident;
 	unsigned long shared_clean;
 	unsigned long shared_dirty;
@@ -458,15 +457,16 @@ struct mem_size_stats {
 	u64 pss;
 };
 
-
-static void smaps_pte_entry(pte_t ptent, unsigned long addr,
-		unsigned long ptent_size, struct mm_walk *walk)
+static int smaps_pte(pte_t *pte, unsigned long addr, unsigned long end,
+			struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	struct vm_area_struct *vma = mss->vma;
+	struct vm_area_struct *vma = walk->vma;
 	pgoff_t pgoff = linear_page_index(vma, addr);
 	struct page *page = NULL;
 	int mapcount;
+	pte_t ptent = *pte;
+	unsigned long ptent_size = end - addr;
 
 	if (pte_present(ptent)) {
 		page = vm_normal_page(vma, addr, ptent);
@@ -483,7 +483,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 	}
 
 	if (!page)
-		return;
+		return 0;
 
 	if (PageAnon(page))
 		mss->anonymous += ptent_size;
@@ -509,35 +509,22 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 			mss->private_clean += ptent_size;
 		mss->pss += (ptent_size << PSS_SHIFT);
 	}
+	return 0;
 }
 
-static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
-			   struct mm_walk *walk)
+static int smaps_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
+			struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	struct vm_area_struct *vma = mss->vma;
-	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
+	if (pmd_trans_huge_lock(pmd, walk->vma, &ptl) == 1) {
+		smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
 		spin_unlock(ptl);
 		mss->anonymous_thp += HPAGE_PMD_SIZE;
-		return 0;
+		/* don't call smaps_pte() */
+		walk->skip = 1;
 	}
-
-	if (pmd_trans_unstable(pmd))
-		return 0;
-	/*
-	 * The mmap_sem held all the way back in m_start() is what
-	 * keeps khugepaged out of here and from collapsing things
-	 * in here.
-	 */
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (; addr != end; pte++, addr += PAGE_SIZE)
-		smaps_pte_entry(*pte, addr, PAGE_SIZE, walk);
-	pte_unmap_unlock(pte - 1, ptl);
-	cond_resched();
 	return 0;
 }
 
@@ -602,16 +589,16 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 	struct vm_area_struct *vma = v;
 	struct mem_size_stats mss;
 	struct mm_walk smaps_walk = {
-		.pmd_entry = smaps_pte_range,
+		.pmd_entry = smaps_pmd,
+		.pte_entry = smaps_pte,
 		.mm = vma->vm_mm,
+		.vma = vma,
 		.private = &mss,
 	};
 
 	memset(&mss, 0, sizeof mss);
-	mss.vma = vma;
 	/* mmap_sem is held in m_start */
-	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
-		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
+	walk_page_vma(vma, &smaps_walk);
 
 	show_map_vma(m, vma, is_pid);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
