Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 12C6E8D000A
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:29:37 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 20 of 66] pte alloc trans splitting
Message-Id: <b2a7419c442366762cfb.1288798075@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:27:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
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

diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -133,7 +133,7 @@ static int map_tboot_page(unsigned long 
 	pmd = pmd_alloc(&tboot_mm, pud, vaddr);
 	if (!pmd)
 		return -1;
-	pte = pte_alloc_map(&tboot_mm, pmd, vaddr);
+	pte = pte_alloc_map(&tboot_mm, NULL, pmd, vaddr);
 	if (!pte)
 		return -1;
 	set_pte_at(&tboot_mm, vaddr, pte, pfn_pte(pfn, prot));
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1117,7 +1117,8 @@ static inline int __pmd_alloc(struct mm_
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
 #endif
 
-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
+int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
+		pmd_t *pmd, unsigned long address);
 int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
 
 /*
@@ -1186,16 +1187,18 @@ static inline void pgtable_page_dtor(str
 	pte_unmap(pte);					\
 } while (0)
 
-#define pte_alloc_map(mm, pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
-		NULL: pte_offset_map(pmd, address))
+#define pte_alloc_map(mm, vma, pmd, address)				\
+	((unlikely(pmd_none(*(pmd))) && __pte_alloc(mm, vma,	\
+							pmd, address))?	\
+	 NULL: pte_offset_map(pmd, address))
 
 #define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+	((unlikely(pmd_none(*(pmd))) && __pte_alloc(mm, NULL,	\
+							pmd, address))?	\
 		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
 
 #define pte_alloc_kernel(pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
+	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
 		NULL: pte_offset_kernel(pmd, address))
 
 extern void free_area_init(unsigned long * zones_size);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -394,9 +394,11 @@ void free_pgtables(struct mmu_gather *tl
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
 
@@ -416,14 +418,18 @@ int __pte_alloc(struct mm_struct *mm, pm
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
 
@@ -436,10 +442,11 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
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
@@ -3215,7 +3222,7 @@ int handle_mm_fault(struct mm_struct *mm
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
-	pte = pte_alloc_map(mm, pmd, address);
+	pte = pte_alloc_map(mm, vma, pmd, address);
 	if (!pte)
 		return VM_FAULT_OOM;
 
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -47,7 +47,8 @@ static pmd_t *get_old_pmd(struct mm_stru
 	return pmd;
 }
 
-static pmd_t *alloc_new_pmd(struct mm_struct *mm, unsigned long addr)
+static pmd_t *alloc_new_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+			    unsigned long addr)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -62,7 +63,8 @@ static pmd_t *alloc_new_pmd(struct mm_st
 	if (!pmd)
 		return NULL;
 
-	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, addr))
+	VM_BUG_ON(pmd_trans_huge(*pmd));
+	if (pmd_none(*pmd) && __pte_alloc(mm, vma, pmd, addr))
 		return NULL;
 
 	return pmd;
@@ -147,7 +149,7 @@ unsigned long move_page_tables(struct vm
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
