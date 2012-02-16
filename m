Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 1AA466B00EC
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:48:51 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [WIP 14/18] Fixes for proc memory
Date: Thu, 16 Feb 2012 15:47:53 +0100
Message-Id: <1329403677-25629-4-git-send-email-mail@smogura.eu>
In-Reply-To: <1329403677-25629-1-git-send-email-mail@smogura.eu>
References: <1329403677-25629-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Fixed smaps to do not split page, and print information about
shared/private huge dirty/clean pages. This changes operates only
on dirty flag from pmd - it may not be enaugh, but checking in addition
PageDirty, like for pte, is too much, because of head of huge page may
be mapped to single pte, not only as huge pmd.

In pagemaps removed splitting and adding huge pmd as one page with shift
of huge page.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 fs/proc/task_mmu.c |   97 ++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 67 insertions(+), 30 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7dcd2a2..111e64c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -333,8 +333,12 @@ struct mem_size_stats {
 	unsigned long resident;
 	unsigned long shared_clean;
 	unsigned long shared_dirty;
+	unsigned long shared_huge_clean;
+	unsigned long shared_huge_dirty;
 	unsigned long private_clean;
 	unsigned long private_dirty;
+	unsigned long private_huge_clean;
+	unsigned long private_huge_dirty;
 	unsigned long referenced;
 	unsigned long anonymous;
 	unsigned long anonymous_thp;
@@ -342,9 +346,8 @@ struct mem_size_stats {
 	u64 pss;
 };
 
-
 static void smaps_pte_entry(pte_t ptent, unsigned long addr,
-		unsigned long ptent_size, struct mm_walk *walk)
+		unsigned long ptent_size, struct mm_walk *walk, int huge_file)
 {
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = mss->vma;
@@ -368,20 +371,33 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 
 	mss->resident += ptent_size;
 	/* Accumulate the size in pages that have been accessed. */
-	if (pte_young(ptent) || PageReferenced(page))
+	if (pte_young(ptent) || (!huge_file && PageReferenced(page)))
 		mss->referenced += ptent_size;
 	mapcount = page_mapcount(page);
+	/* For huge file mapping only account by pte, as page may be made
+	 * dirty, but not pmd (huge page may be mapped in ptes not pde).
+	 */
 	if (mapcount >= 2) {
-		if (pte_dirty(ptent) || PageDirty(page))
+		if (pte_dirty(ptent) || (!huge_file && PageDirty(page))) {
 			mss->shared_dirty += ptent_size;
-		else
+			if (huge_file)
+				mss->shared_huge_dirty += ptent_size;
+		} else {
 			mss->shared_clean += ptent_size;
+			if (huge_file)
+				mss->shared_huge_clean += ptent_size;
+		}
 		mss->pss += (ptent_size << PSS_SHIFT) / mapcount;
 	} else {
-		if (pte_dirty(ptent) || PageDirty(page))
+		if (pte_dirty(ptent) || (!huge_file && PageDirty(page))) {
 			mss->private_dirty += ptent_size;
-		else
+			if (huge_file)
+				mss->private_huge_dirty += ptent_size;
+		} else {
 			mss->private_clean += ptent_size;
+			if (huge_file)
+				mss->private_huge_clean += ptent_size;
+		}
 		mss->pss += (ptent_size << PSS_SHIFT);
 	}
 }
@@ -401,9 +417,10 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			wait_split_huge_page(vma->anon_vma, pmd);
 		} else {
 			smaps_pte_entry(*(pte_t *)pmd, addr,
-					HPAGE_PMD_SIZE, walk);
+					HPAGE_PMD_SIZE, walk,
+					vma->vm_ops != NULL);
 			spin_unlock(&walk->mm->page_table_lock);
-			mss->anonymous_thp += HPAGE_PMD_SIZE;
+				mss->anonymous_thp += HPAGE_PMD_SIZE;
 			return 0;
 		}
 	} else {
@@ -416,7 +433,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	 */
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
-		smaps_pte_entry(*pte, addr, PAGE_SIZE, walk);
+		smaps_pte_entry(*pte, addr, PAGE_SIZE, walk, 0);
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
 	return 0;
@@ -443,20 +460,24 @@ static int show_smap(struct seq_file *m, void *v)
 	show_map_vma(m, vma);
 
 	seq_printf(m,
-		   "Size:           %8lu kB\n"
-		   "Rss:            %8lu kB\n"
-		   "Pss:            %8lu kB\n"
-		   "Shared_Clean:   %8lu kB\n"
-		   "Shared_Dirty:   %8lu kB\n"
-		   "Private_Clean:  %8lu kB\n"
-		   "Private_Dirty:  %8lu kB\n"
-		   "Referenced:     %8lu kB\n"
-		   "Anonymous:      %8lu kB\n"
-		   "AnonHugePages:  %8lu kB\n"
-		   "Swap:           %8lu kB\n"
-		   "KernelPageSize: %8lu kB\n"
-		   "MMUPageSize:    %8lu kB\n"
-		   "Locked:         %8lu kB\n",
+		   "Size:                %8lu kB\n"
+		   "Rss:                 %8lu kB\n"
+		   "Pss:                 %8lu kB\n"
+		   "Shared_Clean:        %8lu kB\n"
+		   "Shared_Dirty:        %8lu kB\n"
+		   "Private_Clean:       %8lu kB\n"
+		   "Private_Dirty:       %8lu kB\n"
+		   "Shared_Huge_Clean:   %8lu kB\n"
+		   "Shared_Huge_Dirty:   %8lu kB\n"
+		   "Private_Huge_Clean:  %8lu kB\n"
+		   "Private_Huge_Dirty:  %8lu kB\n"
+		   "Referenced:          %8lu kB\n"
+		   "Anonymous:           %8lu kB\n"
+		   "AnonHugePages:       %8lu kB\n"
+		   "Swap:                %8lu kB\n"
+		   "KernelPageSize:      %8lu kB\n"
+		   "MMUPageSize:         %8lu kB\n"
+		   "Locked:              %8lu kB\n",
 		   (vma->vm_end - vma->vm_start) >> 10,
 		   mss.resident >> 10,
 		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
@@ -464,6 +485,10 @@ static int show_smap(struct seq_file *m, void *v)
 		   mss.shared_dirty  >> 10,
 		   mss.private_clean >> 10,
 		   mss.private_dirty >> 10,
+		   mss.shared_huge_clean  >> 10,
+		   mss.shared_huge_dirty  >> 10,
+		   mss.private_huge_clean >> 10,
+		   mss.private_huge_dirty >> 10,
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
 		   mss.anonymous_thp >> 10,
@@ -661,6 +686,15 @@ static u64 pte_to_pagemap_entry(pte_t pte)
 	return pme;
 }
 
+static u64 pmd_to_pagemap_entry(pmd_t pmd)
+{
+	u64 pme = 0;
+	if (pmd_present(pmd))
+		pme = PM_PFRAME(pmd_pfn(pmd))
+			| PM_PSHIFT(HPAGE_SHIFT) | PM_PRESENT;
+	return pme | PM_PSHIFT(HPAGE_SHIFT);
+}
+
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
@@ -669,8 +703,6 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte;
 	int err = 0;
 
-	split_huge_page_pmd(walk->mm, pmd);
-
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
 	for (; addr != end; addr += PAGE_SIZE) {
@@ -685,10 +717,15 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		 * and that it isn't a huge page vma */
 		if (vma && (vma->vm_start <= addr) &&
 		    !is_vm_hugetlb_page(vma)) {
-			pte = pte_offset_map(pmd, addr);
-			pfn = pte_to_pagemap_entry(*pte);
-			/* unmap before userspace copy */
-			pte_unmap(pte);
+			pmd_t pmd_val = *pmd;
+			if (pmd_trans_huge(pmd_val)) {
+				pfn = pmd_to_pagemap_entry(pmd_val);
+			} else {
+				pte = pte_offset_map(pmd, addr);
+				pfn = pte_to_pagemap_entry(*pte);
+				/* unmap before userspace copy */
+				pte_unmap(pte);
+			}
 		}
 		err = add_to_pagemap(addr, pfn, pm);
 		if (err)
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
