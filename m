Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id AD29D6B003A
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 17:46:00 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so1555241pad.23
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 14:46:00 -0700 (PDT)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id jp3si28121pbc.186.2013.10.30.14.45.59
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:45:59 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 04/11] clear_refs: redefine callback functions for page table walker
Date: Wed, 30 Oct 2013 17:44:52 -0400
Message-Id: <1383169499-25144-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Currently clear_refs_pte_range() is connected to pmd_entry() to split thps
if found. But now this work can be done in core page table walker code.
So we have no reason to keep this callback on pmd_entry(). This patch moves
pte handling code on pte_entry() callback.

clear_refs_write() has some prechecks about if we really walk over a given
vma. It's fine to let them done by test_walk() callback, so let's define it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 82 ++++++++++++++++++++++--------------------------------
 1 file changed, 33 insertions(+), 49 deletions(-)

diff --git v3.12-rc7-mmots-2013-10-29-16-24.orig/fs/proc/task_mmu.c v3.12-rc7-mmots-2013-10-29-16-24/fs/proc/task_mmu.c
index ed79a9c..3e1b739 100644
--- v3.12-rc7-mmots-2013-10-29-16-24.orig/fs/proc/task_mmu.c
+++ v3.12-rc7-mmots-2013-10-29-16-24/fs/proc/task_mmu.c
@@ -719,7 +719,6 @@ enum clear_refs_types {
 };
 
 struct clear_refs_private {
-	struct vm_area_struct *vma;
 	enum clear_refs_types type;
 };
 
@@ -751,41 +750,43 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 #endif
 }
 
-static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
+static int clear_refs_pte(pte_t *pte, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
 	struct clear_refs_private *cp = walk->private;
-	struct vm_area_struct *vma = cp->vma;
-	pte_t *pte, ptent;
-	spinlock_t *ptl;
+	struct vm_area_struct *vma = walk->vma;
 	struct page *page;
 
-	split_huge_page_pmd(vma, addr, pmd);
-	if (pmd_trans_unstable(pmd))
+	if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
+		clear_soft_dirty(vma, addr, pte);
 		return 0;
+	}
+	if (!pte_present(*pte))
+		return 0;
+	page = vm_normal_page(vma, addr, *pte);
+	if (!page)
+		return 0;
+	/* Clear accessed and referenced bits. */
+	ptep_test_and_clear_young(vma, addr, pte);
+	ClearPageReferenced(page);
+	return 0;
+}
 
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (; addr != end; pte++, addr += PAGE_SIZE) {
-		ptent = *pte;
-
-		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
-			clear_soft_dirty(vma, addr, pte);
-			continue;
-		}
-
-		if (!pte_present(ptent))
-			continue;
-
-		page = vm_normal_page(vma, addr, ptent);
-		if (!page)
-			continue;
+static int clear_refs_test_walk(unsigned long start, unsigned long end,
+				struct mm_walk *walk)
+{
+	struct clear_refs_private *cp = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 
-		/* Clear accessed and referenced bits. */
-		ptep_test_and_clear_young(vma, addr, pte);
-		ClearPageReferenced(page);
-	}
-	pte_unmap_unlock(pte - 1, ptl);
-	cond_resched();
+	/*
+	 * Writing 1 to /proc/pid/clear_refs affects all pages.
+	 * Writing 2 to /proc/pid/clear_refs only affects anonymous pages.
+	 * Writing 3 to /proc/pid/clear_refs only affects file mapped pages.
+	 */
+	if (cp->type == CLEAR_REFS_ANON && vma->vm_file)
+		walk->skip = 1;
+	if (cp->type == CLEAR_REFS_MAPPED && !vma->vm_file)
+		walk->skip = 1;
 	return 0;
 }
 
@@ -827,33 +828,16 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			.type = type,
 		};
 		struct mm_walk clear_refs_walk = {
-			.pmd_entry = clear_refs_pte_range,
+			.pte_entry = clear_refs_pte,
+			.test_walk = clear_refs_test_walk,
 			.mm = mm,
 			.private = &cp,
 		};
 		down_read(&mm->mmap_sem);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
-			cp.vma = vma;
-			if (is_vm_hugetlb_page(vma))
-				continue;
-			/*
-			 * Writing 1 to /proc/pid/clear_refs affects all pages.
-			 *
-			 * Writing 2 to /proc/pid/clear_refs only affects
-			 * Anonymous pages.
-			 *
-			 * Writing 3 to /proc/pid/clear_refs only affects file
-			 * mapped pages.
-			 */
-			if (type == CLEAR_REFS_ANON && vma->vm_file)
-				continue;
-			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
-				continue;
-			walk_page_range(vma->vm_start, vma->vm_end,
-					&clear_refs_walk);
-		}
+		for (vma = mm->mmap; vma; vma = vma->vm_next)
+			walk_page_vma(vma, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		flush_tlb_mm(mm);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
