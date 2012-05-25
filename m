Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 425AA6B00F8
	for <linux-mm@kvack.org>; Fri, 25 May 2012 13:03:16 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 27/35] autonuma: make khugepaged pte_numa aware
Date: Fri, 25 May 2012 19:02:31 +0200
Message-Id: <1337965359-29725-28-git-send-email-aarcange@redhat.com>
In-Reply-To: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

If any of the ptes that khugepaged is collapsing was a pte_numa, the
resulting trans huge pmd will be a pmd_numa too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b1c047b..d388517 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1790,12 +1790,13 @@ out:
 	return isolated;
 }
 
-static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
+static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
 				      struct vm_area_struct *vma,
 				      unsigned long address,
 				      spinlock_t *ptl)
 {
 	pte_t *_pte;
+	bool mknuma = false;
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
 		pte_t pteval = *_pte;
 		struct page *src_page;
@@ -1823,11 +1824,15 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			page_remove_rmap(src_page);
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
+
+			mknuma |= pte_numa(pteval);
 		}
 
 		address += PAGE_SIZE;
 		page++;
 	}
+
+	return mknuma;
 }
 
 static void collapse_huge_page(struct mm_struct *mm,
@@ -1845,6 +1850,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spinlock_t *ptl;
 	int isolated;
 	unsigned long hstart, hend;
+	bool mknuma = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 #ifndef CONFIG_NUMA
@@ -1963,7 +1969,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	anon_vma_unlock(vma->anon_vma);
 
-	__collapse_huge_page_copy(pte, new_page, vma, address, ptl);
+	mknuma = pmd_numa(_pmd);
+	mknuma |= __collapse_huge_page_copy(pte, new_page, vma, address, ptl);
 	pte_unmap(pte);
 	__SetPageUptodate(new_page);
 	pgtable = pmd_pgtable(_pmd);
@@ -1973,6 +1980,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	_pmd = mk_pmd(new_page, vma->vm_page_prot);
 	_pmd = maybe_pmd_mkwrite(pmd_mkdirty(_pmd), vma);
 	_pmd = pmd_mkhuge(_pmd);
+	if (mknuma)
+		_pmd = pmd_mknuma(_pmd);
 
 	/*
 	 * spin_lock() below is not the equivalent of smp_wmb(), so

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
