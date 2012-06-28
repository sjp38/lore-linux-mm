Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 895E56B008C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:57:06 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 28/40] autonuma: make khugepaged pte_numa aware
Date: Thu, 28 Jun 2012 14:56:08 +0200
Message-Id: <1340888180-15355-29-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

If any of the ptes that khugepaged is collapsing was a pte_numa, the
resulting trans huge pmd will be a pmd_numa too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55fc72d..094f82b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1799,12 +1799,13 @@ out:
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
@@ -1832,11 +1833,15 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
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
@@ -1854,6 +1859,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spinlock_t *ptl;
 	int isolated;
 	unsigned long hstart, hend;
+	bool mknuma = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 #ifndef CONFIG_NUMA
@@ -1972,7 +1978,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	anon_vma_unlock(vma->anon_vma);
 
-	__collapse_huge_page_copy(pte, new_page, vma, address, ptl);
+	mknuma = pmd_numa(_pmd);
+	mknuma |= __collapse_huge_page_copy(pte, new_page, vma, address, ptl);
 	pte_unmap(pte);
 	__SetPageUptodate(new_page);
 	pgtable = pmd_pgtable(_pmd);
@@ -1982,6 +1989,8 @@ static void collapse_huge_page(struct mm_struct *mm,
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
