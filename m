Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id CD5CA6B0096
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:17 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 22/36] autonuma: make khugepaged pte_numa aware
Date: Wed, 22 Aug 2012 16:59:06 +0200
Message-Id: <1345647560-30387-23-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

If any of the ptes that khugepaged is collapsing was a pte_numa, the
resulting trans huge pmd will be a pmd_numa too.

See the comment inline for why we require just one pte_numa pte to
make a pmd_numa pmd. If needed later we could change the number of
pte_numa ptes required to create a pmd_numa and make it tunable with
sysfs too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |   33 +++++++++++++++++++++++++++++++--
 1 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 08fd33c..a65590f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1816,12 +1816,19 @@ out:
 	return isolated;
 }
 
-static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
+/*
+ * Do the actual data copy for mapped ptes and release the mapped
+ * pages, or alternatively zero out the transparent hugepage in the
+ * mapping holes. Transfer the page_autonuma information in the
+ * process. Return true if any of the mapped ptes was of numa type.
+ */
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
@@ -1849,11 +1856,29 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			page_remove_rmap(src_page);
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
+
+			/*
+			 * Only require one pte_numa mapped by a pmd
+			 * to make it a pmd_numa, too. To avoid the
+			 * risk of losing NUMA hinting page faults, it
+			 * is better to overestimate the NUMA node
+			 * affinity with a node where we just
+			 * collapsed a hugepage, rather than
+			 * underestimate it.
+			 *
+			 * Note: if AUTONUMA_SCAN_PMD_FLAG is set, we
+			 * won't find any pte_numa ptes since we're
+			 * only setting NUMA hinting at the pmd
+			 * level.
+			 */
+			mknuma |= pte_numa(pteval);
 		}
 
 		address += PAGE_SIZE;
 		page++;
 	}
+
+	return mknuma;
 }
 
 static void collapse_huge_page(struct mm_struct *mm,
@@ -1871,6 +1896,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spinlock_t *ptl;
 	int isolated;
 	unsigned long hstart, hend;
+	bool mknuma = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 #ifndef CONFIG_NUMA
@@ -1989,7 +2015,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	anon_vma_unlock(vma->anon_vma);
 
-	__collapse_huge_page_copy(pte, new_page, vma, address, ptl);
+	mknuma = pmd_numa(_pmd);
+	mknuma |= __collapse_huge_page_copy(pte, new_page, vma, address, ptl);
 	pte_unmap(pte);
 	__SetPageUptodate(new_page);
 	pgtable = pmd_pgtable(_pmd);
@@ -1999,6 +2026,8 @@ static void collapse_huge_page(struct mm_struct *mm,
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
