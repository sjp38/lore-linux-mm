Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5E3D96B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:08:23 -0400 (EDT)
Message-Id: <20121025124832.914777732@chello.nl>
Date: Thu, 25 Oct 2012 14:16:23 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 06/31] mm: Only flush the TLB when clearing an accessible pte
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0006-mm-Only-flush-the-TLB-when-clearing-an-accessible-pt.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

From: Rik van Riel <riel@redhat.com>

If ptep_clear_flush() is called to clear a page table entry that is
accessible anyway by the CPU, eg. a _PAGE_PROTNONE page table entry,
there is no need to flush the TLB on remote CPUs.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/pgtable-generic.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: tip/mm/pgtable-generic.c
===================================================================
--- tip.orig/mm/pgtable-generic.c
+++ tip/mm/pgtable-generic.c
@@ -88,7 +88,8 @@ pte_t ptep_clear_flush(struct vm_area_st
 {
 	pte_t pte;
 	pte = ptep_get_and_clear((vma)->vm_mm, address, ptep);
-	flush_tlb_page(vma, address);
+	if (pte_accessible(pte))
+		flush_tlb_page(vma, address);
 	return pte;
 }
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
