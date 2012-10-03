Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id F27546B00C1
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:54 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 25/33] autonuma: numa hinting page faults entry points
Date: Thu,  4 Oct 2012 01:51:07 +0200
Message-Id: <1349308275-2174-26-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This is where the numa hinting page faults are detected and are passed
over to the AutoNUMA core logic.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h |    2 ++
 mm/memory.c             |   10 ++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ad4e2e0..eca2c5e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -11,6 +11,8 @@ extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       pmd_t orig_pmd);
+extern int huge_pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
+			       pmd_t pmd, pmd_t *pmdp);
 extern pgtable_t get_pmd_huge_pte(struct mm_struct *mm);
 extern struct page *follow_trans_huge_pmd(struct mm_struct *mm,
 					  unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index 1040e87..c89b1d3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/autonuma.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3456,6 +3457,9 @@ int handle_pte_fault(struct mm_struct *mm,
 					pte, pmd, flags, entry);
 	}
 
+	if (pte_numa(entry))
+		return pte_numa_fixup(mm, vma, address, entry, pte, pmd);
+
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
@@ -3530,6 +3534,9 @@ retry:
 		 */
 		orig_pmd = ACCESS_ONCE(*pmd);
 		if (pmd_trans_huge(orig_pmd)) {
+			if (pmd_numa(*pmd))
+				return huge_pmd_numa_fixup(mm, address,
+							   orig_pmd, pmd);
 			if (flags & FAULT_FLAG_WRITE &&
 			    !pmd_write(orig_pmd) &&
 			    !pmd_trans_splitting(orig_pmd)) {
@@ -3548,6 +3555,9 @@ retry:
 		}
 	}
 
+	if (pmd_numa(*pmd))
+		return pmd_numa_fixup(mm, address, pmd);
+
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
