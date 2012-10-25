Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 880446B007B
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:03 -0400 (EDT)
Message-Id: <20121025124832.840241082@chello.nl>
Date: Thu, 25 Oct 2012 14:16:22 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 05/31] x86/mm: Reduce tlb flushes from ptep_set_access_flags()
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0005-x86-mm-Reduce-tlb-flushes-from-ptep_set_access_flags.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

From: Rik van Riel <riel@redhat.com>

If ptep_set_access_flags() is invoked to upgrade access permissions
on a PTE, there is no security or data integrity reason to do a
remote TLB flush.

Lazily letting another CPU incur a spurious page fault occasionally
is (much!) cheaper than aggressively flushing everybody else's TLB.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/pgtable.c |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

Index: tip/arch/x86/mm/pgtable.c
===================================================================
--- tip.orig/arch/x86/mm/pgtable.c
+++ tip/arch/x86/mm/pgtable.c
@@ -306,11 +306,26 @@ int ptep_set_access_flags(struct vm_area
 			  pte_t entry, int dirty)
 {
 	int changed = !pte_same(*ptep, entry);
+	/*
+	 * If the page used to be inaccessible (_PAGE_PROTNONE), or
+	 * this call upgrades the access permissions on the same page,
+	 * it is safe to skip the remote TLB flush.
+	 */
+	bool flush_remote = false;
+	if (!pte_accessible(*ptep))
+		flush_remote = false;
+	else if (pte_pfn(*ptep) != pte_pfn(entry) ||
+			(pte_write(*ptep) && !pte_write(entry)) ||
+			(pte_exec(*ptep) && !pte_exec(entry)))
+		flush_remote = true;
 
 	if (changed && dirty) {
 		*ptep = entry;
 		pte_update_defer(vma->vm_mm, address, ptep);
-		flush_tlb_page(vma, address);
+		if (flush_remote)
+			flush_tlb_page(vma, address);
+		else
+			__flush_tlb_one(address);
 	}
 
 	return changed;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
