Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BA56D6B00CA
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:48:32 -0500 (EST)
Message-Id: <20100309194314.292117654@redhat.com>
Date: Tue, 09 Mar 2010 20:39:18 +0100
From: aarcange@redhat.com
Subject: [patch 17/35] pte alloc trans splitting
References: <20100309193901.207868642@redhat.com>
Content-Disposition: inline; filename=pte_alloc_trans_splitting
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

pte alloc routines must wait for split_huge_page if the pmd is not
present and not null (i.e. pmd_trans_splitting). The additional
branches are optimized away at compile time by pmd_trans_splitting if
the config option is off. However we must pass the vma down in order
to know the anon_vma lock to wait for.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mm.h |   13 ++++++++-----
 mm/memory.c        |   19 +++++++++++++------
 mm/mremap.c        |    7 ++++---
 3 files changed, 25 insertions(+), 14 deletions(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1060,7 +1060,8 @@ static inline int __pmd_alloc(struct mm_
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
 #endif
 
-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
+int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
+		pmd_t *pmd, unsigned long address);
 int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
 
 /*
@@ -1129,12 +1130,14 @@ static inline void pgtable_page_dtor(str
 	pte_unmap(pte);					\
 } while (0)
 
-#define pte_alloc_map(mm, pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
-		NULL: pte_offset_map(pmd, address))
+#define pte_alloc_map(mm, vma, pmd, address)				\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, vma,	\
+							pmd, address))?	\
+	 NULL: pte_offset_map(pmd, address))
 
 #define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, NULL,	\
+							pmd, address))?	\
 		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
 
 #define pte_alloc_kernel(pmd, address)			\
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -398,9 +398,11 @@ void free_pgtables(struct mmu_gather *tl
 	}
 }
 
-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
+int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
+		pmd_t *pmd, unsigned long address)
 {
 	pgtable_t new = pte_alloc_one(mm, address);
+	int wait_split_huge_page;
 	if (!new)
 		return -ENOMEM;
 
@@ -420,14 +422,18 @@ int __pte_alloc(struct mm_struct *mm, pm
 	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
 
 	spin_lock(&mm->page_table_lock);
-	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
+	wait_split_huge_page = 0;
+	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		mm->nr_ptes++;
 		pmd_populate(mm, pmd, new);
 		new = NULL;
-	}
+	} else if (unlikely(pmd_trans_splitting(*pmd)))
+		wait_split_huge_page = 1;
 	spin_unlock(&mm->page_table_lock);
 	if (new)
 		pte_free(mm, new);
+	if (wait_split_huge_page)
+		wait_split_huge_page(vma->anon_vma, pmd);
 	return 0;
 }
 
@@ -440,10 +446,11 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	smp_wmb(); /* See comment in __pte_alloc */
 
 	spin_lock(&init_mm.page_table_lock);
-	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
+	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
 		new = NULL;
-	}
+	} else
+		VM_BUG_ON(pmd_trans_splitting(*pmd));
 	spin_unlock(&init_mm.page_table_lock);
 	if (new)
 		pte_free_kernel(&init_mm, new);
@@ -3125,7 +3132,7 @@ int handle_mm_fault(struct mm_struct *mm
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
-	pte = pte_alloc_map(mm, pmd, address);
+	pte = pte_alloc_map(mm, vma, pmd, address);
 	if (!pte)
 		return VM_FAULT_OOM;
 
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -48,7 +48,8 @@ static pmd_t *get_old_pmd(struct mm_stru
 	return pmd;
 }
 
-static pmd_t *alloc_new_pmd(struct mm_struct *mm, unsigned long addr)
+static pmd_t *alloc_new_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+			    unsigned long addr)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -63,7 +64,7 @@ static pmd_t *alloc_new_pmd(struct mm_st
 	if (!pmd)
 		return NULL;
 
-	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, addr))
+	if (!pmd_present(*pmd) && __pte_alloc(mm, vma, pmd, addr))
 		return NULL;
 
 	return pmd;
@@ -148,7 +149,7 @@ unsigned long move_page_tables(struct vm
 		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
 		if (!old_pmd)
 			continue;
-		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
+		new_pmd = alloc_new_pmd(vma->vm_mm, vma, new_addr);
 		if (!new_pmd)
 			break;
 		next = (new_addr + PMD_SIZE) & PMD_MASK;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
