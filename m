Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D0780900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 06:12:54 -0400 (EDT)
Date: Fri, 15 Apr 2011 11:12:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Check if PTE is already allocated during page fault
Message-ID: <20110415101248.GB22688@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

With transparent hugepage support, handle_mm_fault() has to be careful
that a normal PMD has been established before handling a PTE fault. To
achieve this, it used __pte_alloc() directly instead of pte_alloc_map
as pte_alloc_map is unsafe to run against a huge PMD. pte_offset_map()
is called once it is known the PMD is safe.

pte_alloc_map() is smart enough to check if a PTE is already present
before calling __pte_alloc but this check was lost. As a consequence,
PTEs may be allocated unnecessarily and the page table lock taken.
Thi useless PTE does get cleaned up but it's a performance hit which
is visible in page_test from aim9.

This patch simply re-adds the check normally done by pte_alloc_map to
check if the PTE needs to be allocated before taking the page table
lock. The effect is noticable in page_test from aim9.

AIM9
                2.6.38-vanilla 2.6.38-checkptenone
creat-clo      446.10 ( 0.00%)   424.47 (-5.10%)
page_test       38.10 ( 0.00%)    42.04 ( 9.37%)
brk_test        52.45 ( 0.00%)    51.57 (-1.71%)
exec_test      382.00 ( 0.00%)   456.90 (16.39%)
fork_test       60.11 ( 0.00%)    67.79 (11.34%)
MMTests Statistics: duration
Total Elapsed Time (seconds)                611.90    612.22

(While this affects 2.6.38, it is a performance rather than a
functional bug and normally outside the rules -stable. While the big
performance differences are to a microbench, the difference in fork
and exec performance may be significant enough that -stable wants to
consider the patch)

Reported-by: Raz Ben Yehuda <raziebe@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
-- 
 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5823698..1659574 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3322,7 +3322,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * run pte_offset_map on the pmd, if an huge pmd could
 	 * materialize from under us from a different thread.
 	 */
-	if (unlikely(__pte_alloc(mm, vma, pmd, address)))
+	if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))
 		return VM_FAULT_OOM;
 	/* if an huge pmd materialized from under us just retry later */
 	if (unlikely(pmd_trans_huge(*pmd)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
