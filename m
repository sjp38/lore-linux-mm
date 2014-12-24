Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA836B006C
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:03 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so10013382pab.2
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:03 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id cj3si34174043pbc.134.2014.12.24.04.22.59
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 04/38] proc: drop handling non-linear mappings
Date: Wed, 24 Dec 2014 14:22:12 +0200
Message-Id: <1419423766-114457-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We have to handle non-linear mappings for /proc/PID/{smaps,clear_refs}
which is unused now. Let's drop it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 246eae84b13b..6396f88c6687 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -443,7 +443,6 @@ struct mem_size_stats {
 	unsigned long anonymous;
 	unsigned long anonymous_thp;
 	unsigned long swap;
-	unsigned long nonlinear;
 	u64 pss;
 };
 
@@ -484,7 +483,6 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 {
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = mss->vma;
-	pgoff_t pgoff = linear_page_index(vma, addr);
 	struct page *page = NULL;
 
 	if (pte_present(*pte)) {
@@ -496,17 +494,10 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 			mss->swap += PAGE_SIZE;
 		else if (is_migration_entry(swpent))
 			page = migration_entry_to_page(swpent);
-	} else if (pte_file(*pte)) {
-		if (pte_to_pgoff(*pte) != pgoff)
-			mss->nonlinear += PAGE_SIZE;
 	}
 
 	if (!page)
 		return;
-
-	if (page->index != pgoff)
-		mss->nonlinear += PAGE_SIZE;
-
 	smaps_account(mss, page, PAGE_SIZE, pte_young(*pte), pte_dirty(*pte));
 }
 
@@ -596,7 +587,6 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_ACCOUNT)]	= "ac",
 		[ilog2(VM_NORESERVE)]	= "nr",
 		[ilog2(VM_HUGETLB)]	= "ht",
-		[ilog2(VM_NONLINEAR)]	= "nl",
 		[ilog2(VM_ARCH_1)]	= "ar",
 		[ilog2(VM_DONTDUMP)]	= "dd",
 #ifdef CONFIG_MEM_SOFT_DIRTY
@@ -668,10 +658,6 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   (vma->vm_flags & VM_LOCKED) ?
 			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
 
-	if (vma->vm_flags & VM_NONLINEAR)
-		seq_printf(m, "Nonlinear:      %8lu kB\n",
-				mss.nonlinear >> 10);
-
 	show_smap_vma_flags(m, vma);
 	m_cache_vma(m, vma);
 	return 0;
@@ -772,8 +758,6 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
 	} else if (is_swap_pte(ptent)) {
 		ptent = pte_swp_clear_soft_dirty(ptent);
-	} else if (pte_file(ptent)) {
-		ptent = pte_file_clear_soft_dirty(ptent);
 	}
 
 	set_pte_at(vma->vm_mm, addr, pte, ptent);
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
