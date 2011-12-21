Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id D15CB6B0062
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 17:20:39 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/4] thp: optimize away unnecessary page table locking
Date: Wed, 21 Dec 2011 17:23:46 -0500
Message-Id: <1324506228-18327-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently when we check if we can handle thp as it is or we need to
split it into regular sized pages, we hold page table lock prior to
check whether a given pmd is mapping thp or not. Because of this,
when it's not "huge pmd" we suffer from unnecessary lock/unlock overhead.
To remove it, this patch introduces a optimized check function and
replace several similar logics with it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: David Rientjes <rientjes@google.com>
---
 fs/proc/task_mmu.c      |   74 ++++++++++------------------
 include/linux/huge_mm.h |    7 +++
 mm/huge_memory.c        |  124 ++++++++++++++++++++++------------------------
 mm/mremap.c             |    3 +-
 4 files changed, 93 insertions(+), 115 deletions(-)

diff --git 3.2-rc5.orig/fs/proc/task_mmu.c 3.2-rc5/fs/proc/task_mmu.c
index 0df61ab..3b79dd4 100644
--- 3.2-rc5.orig/fs/proc/task_mmu.c
+++ 3.2-rc5/fs/proc/task_mmu.c
@@ -394,20 +394,12 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	spin_lock(&walk->mm->page_table_lock);
-	if (pmd_trans_huge(*pmd)) {
-		if (pmd_trans_splitting(*pmd)) {
-			spin_unlock(&walk->mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma, pmd);
-		} else {
-			smaps_pte_entry(*(pte_t *)pmd, addr,
-					HPAGE_PMD_SIZE, walk);
-			spin_unlock(&walk->mm->page_table_lock);
-			mss->anonymous_thp += HPAGE_PMD_SIZE;
-			return 0;
-		}
-	} else {
+	if (check_and_wait_split_huge_pmd(pmd, vma)) {
+		smaps_pte_entry(*(pte_t *)pmd, addr,
+				HPAGE_PMD_SIZE, walk);
 		spin_unlock(&walk->mm->page_table_lock);
+		mss->anonymous_thp += HPAGE_PMD_SIZE;
+		return 0;
 	}
 	/*
 	 * The mmap_sem held all the way back in m_start() is what
@@ -689,26 +681,19 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
 
-	spin_lock(&walk->mm->page_table_lock);
-	if (pmd_trans_huge(*pmd)) {
-		if (pmd_trans_splitting(*pmd)) {
-			spin_unlock(&walk->mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma, pmd);
-		} else {
-			for (; addr != end; addr += PAGE_SIZE) {
-				int offset = (addr & ~PAGEMAP_WALK_MASK)
-					>> PAGE_SHIFT;
-				pfn = thp_pte_to_pagemap_entry(*(pte_t *)pmd,
-							       offset);
-				err = add_to_pagemap(addr, pfn, pm);
-				if (err)
-					break;
-			}
-			spin_unlock(&walk->mm->page_table_lock);
-			return err;
+	/* David comment */
+	if (check_and_wait_split_huge_pmd(pmd, vma)) {
+		for (; addr != end; addr += PAGE_SIZE) {
+			int offset = (addr & ~PAGEMAP_WALK_MASK)
+				>> PAGE_SHIFT;
+			pfn = thp_pte_to_pagemap_entry(*(pte_t *)pmd,
+						       offset);
+			err = add_to_pagemap(addr, pfn, pm);
+			if (err)
+				break;
 		}
-	} else {
 		spin_unlock(&walk->mm->page_table_lock);
+		return err;
 	}
 
 	for (; addr != end; addr += PAGE_SIZE) {
@@ -975,24 +960,17 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	pte_t *pte;
 
 	md = walk->private;
-	spin_lock(&walk->mm->page_table_lock);
-	if (pmd_trans_huge(*pmd)) {
-		if (pmd_trans_splitting(*pmd)) {
-			spin_unlock(&walk->mm->page_table_lock);
-			wait_split_huge_page(md->vma->anon_vma, pmd);
-		} else {
-			pte_t huge_pte = *(pte_t *)pmd;
-			struct page *page;
-
-			page = can_gather_numa_stats(huge_pte, md->vma, addr);
-			if (page)
-				gather_stats(page, md, pte_dirty(huge_pte),
-						HPAGE_PMD_SIZE/PAGE_SIZE);
-			spin_unlock(&walk->mm->page_table_lock);
-			return 0;
-		}
-	} else {
+
+	if (check_and_wait_split_huge_pmd(pmd, md->vma)) {
+		pte_t huge_pte = *(pte_t *)pmd;
+		struct page *page;
+
+		page = can_gather_numa_stats(huge_pte, md->vma, addr);
+		if (page)
+			gather_stats(page, md, pte_dirty(huge_pte),
+				     HPAGE_PMD_SIZE/PAGE_SIZE);
 		spin_unlock(&walk->mm->page_table_lock);
+		return 0;
 	}
 
 	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
diff --git 3.2-rc5.orig/include/linux/huge_mm.h 3.2-rc5/include/linux/huge_mm.h
index a9ace9c..477c8e3 100644
--- 3.2-rc5.orig/include/linux/huge_mm.h
+++ 3.2-rc5/include/linux/huge_mm.h
@@ -113,6 +113,8 @@ extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    long adjust_next);
+extern int check_and_wait_split_huge_pmd(pmd_t *pmd,
+				struct vm_area_struct *vma);
 static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 unsigned long start,
 					 unsigned long end,
@@ -176,6 +178,11 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 long adjust_next)
 {
 }
+static inline int check_and_wait_split_huge_pmd(pmd_t *pmd,
+					struct vm_area_struct *vma)
+{
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git 3.2-rc5.orig/mm/huge_memory.c 3.2-rc5/mm/huge_memory.c
index 36b3d98..b73c744 100644
--- 3.2-rc5.orig/mm/huge_memory.c
+++ 3.2-rc5/mm/huge_memory.c
@@ -1001,29 +1001,21 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 {
 	int ret = 0;
 
-	spin_lock(&tlb->mm->page_table_lock);
-	if (likely(pmd_trans_huge(*pmd))) {
-		if (unlikely(pmd_trans_splitting(*pmd))) {
-			spin_unlock(&tlb->mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma,
-					     pmd);
-		} else {
-			struct page *page;
-			pgtable_t pgtable;
-			pgtable = get_pmd_huge_pte(tlb->mm);
-			page = pmd_page(*pmd);
-			pmd_clear(pmd);
-			page_remove_rmap(page);
-			VM_BUG_ON(page_mapcount(page) < 0);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-			VM_BUG_ON(!PageHead(page));
-			spin_unlock(&tlb->mm->page_table_lock);
-			tlb_remove_page(tlb, page);
-			pte_free(tlb->mm, pgtable);
-			ret = 1;
-		}
-	} else
+	if (likely(check_and_wait_split_huge_pmd(pmd, vma))) {
+		struct page *page;
+		pgtable_t pgtable;
+		pgtable = get_pmd_huge_pte(tlb->mm);
+		page = pmd_page(*pmd);
+		pmd_clear(pmd);
+		page_remove_rmap(page);
+		VM_BUG_ON(page_mapcount(page) < 0);
+		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+		VM_BUG_ON(!PageHead(page));
 		spin_unlock(&tlb->mm->page_table_lock);
+		tlb_remove_page(tlb, page);
+		pte_free(tlb->mm, pgtable);
+		ret = 1;
+	}
 
 	return ret;
 }
@@ -1034,21 +1026,14 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 {
 	int ret = 0;
 
-	spin_lock(&vma->vm_mm->page_table_lock);
-	if (likely(pmd_trans_huge(*pmd))) {
-		ret = !pmd_trans_splitting(*pmd);
-		spin_unlock(&vma->vm_mm->page_table_lock);
-		if (unlikely(!ret))
-			wait_split_huge_page(vma->anon_vma, pmd);
-		else {
-			/*
-			 * All logical pages in the range are present
-			 * if backed by a huge page.
-			 */
-			memset(vec, 1, (end - addr) >> PAGE_SHIFT);
-		}
-	} else
+	if (likely(check_and_wait_split_huge_pmd(pmd, vma))) {
+		/*
+		 * All logical pages in the range are present
+		 * if backed by a huge page.
+		 */
 		spin_unlock(&vma->vm_mm->page_table_lock);
+		memset(vec, 1, (end - addr) >> PAGE_SHIFT);
+	}
 
 	return ret;
 }
@@ -1078,21 +1063,12 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		goto out;
 	}
 
-	spin_lock(&mm->page_table_lock);
-	if (likely(pmd_trans_huge(*old_pmd))) {
-		if (pmd_trans_splitting(*old_pmd)) {
-			spin_unlock(&mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma, old_pmd);
-			ret = -1;
-		} else {
-			pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
-			VM_BUG_ON(!pmd_none(*new_pmd));
-			set_pmd_at(mm, new_addr, new_pmd, pmd);
-			spin_unlock(&mm->page_table_lock);
-			ret = 1;
-		}
-	} else {
+	if (likely(check_and_wait_split_huge_pmd(old_pmd, vma))) {
+		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
+		VM_BUG_ON(!pmd_none(*new_pmd));
+		set_pmd_at(mm, new_addr, new_pmd, pmd);
 		spin_unlock(&mm->page_table_lock);
+		ret = 1;
 	}
 out:
 	return ret;
@@ -1104,27 +1080,45 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	struct mm_struct *mm = vma->vm_mm;
 	int ret = 0;
 
-	spin_lock(&mm->page_table_lock);
-	if (likely(pmd_trans_huge(*pmd))) {
-		if (unlikely(pmd_trans_splitting(*pmd))) {
-			spin_unlock(&mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma, pmd);
-		} else {
-			pmd_t entry;
+	if (likely(check_and_wait_split_huge_pmd(pmd, vma))) {
+		pmd_t entry;
 
-			entry = pmdp_get_and_clear(mm, addr, pmd);
-			entry = pmd_modify(entry, newprot);
-			set_pmd_at(mm, addr, pmd, entry);
-			spin_unlock(&vma->vm_mm->page_table_lock);
-			flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
-			ret = 1;
-		}
-	} else
+		entry = pmdp_get_and_clear(mm, addr, pmd);
+		entry = pmd_modify(entry, newprot);
+		set_pmd_at(mm, addr, pmd, entry);
 		spin_unlock(&vma->vm_mm->page_table_lock);
+		flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
+		ret = 1;
+	}
 
 	return ret;
 }
 
+/*
+ * Returns 1 if a given pmd is mapping a thp and stable (not under splitting.)
+ * Returns 0 otherwise. Note that if it returns 1, this routine returns without
+ * unlocking page table locks. So callers must unlock them.
+ */
+int check_and_wait_split_huge_pmd(pmd_t *pmd, struct vm_area_struct *vma)
+{
+	if (!pmd_trans_huge(*pmd))
+		return 0;
+
+	spin_lock(&vma->vm_mm->page_table_lock);
+	if (likely(pmd_trans_huge(*pmd))) {
+		if (pmd_trans_splitting(*pmd)) {
+			spin_unlock(&vma->vm_mm->page_table_lock);
+			wait_split_huge_page(vma->anon_vma, pmd);
+		} else {
+			/* Thp mapped by 'pmd' is stable, so we can
+			 * handle it as it is. */
+			return 1;
+		}
+	}
+	spin_unlock(&vma->vm_mm->page_table_lock);
+	return 0;
+}
+
 pmd_t *page_check_address_pmd(struct page *page,
 			      struct mm_struct *mm,
 			      unsigned long address,
diff --git 3.2-rc5.orig/mm/mremap.c 3.2-rc5/mm/mremap.c
index d6959cb..d534668 100644
--- 3.2-rc5.orig/mm/mremap.c
+++ 3.2-rc5/mm/mremap.c
@@ -155,9 +155,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 			if (err > 0) {
 				need_flush = true;
 				continue;
-			} else if (!err) {
-				split_huge_page_pmd(vma->vm_mm, old_pmd);
 			}
+			split_huge_page_pmd(vma->vm_mm, old_pmd);
 			VM_BUG_ON(pmd_trans_huge(*old_pmd));
 		}
 		if (pmd_none(*new_pmd) && __pte_alloc(new_vma->vm_mm, new_vma,
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
