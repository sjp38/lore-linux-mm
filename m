Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 450FE8D003C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:01 -0500 (EST)
Message-Id: <20110307172206.831489809@chello.nl>
Date: Mon, 07 Mar 2011 18:13:55 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 05/15] mm, tile: Change flush_tlb_range() VM_HUGETLB semantics
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=tile-flush_tlb_range-hugetlb.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Since we're going to provide a fake VMA covering a large range, we
need to change the VM_HUGETLB semantic to mean _also_ wipe HPAGE TLBs.

Cc: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/tile/kernel/tlb.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6/arch/tile/kernel/tlb.c
===================================================================
--- linux-2.6.orig/arch/tile/kernel/tlb.c
+++ linux-2.6/arch/tile/kernel/tlb.c
@@ -67,11 +67,14 @@ EXPORT_SYMBOL(flush_tlb_page);
 void flush_tlb_range(const struct vm_area_struct *vma,
 		     unsigned long start, unsigned long end)
 {
-	unsigned long size = hv_page_size(vma);
 	struct mm_struct *mm = vma->vm_mm;
 	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
-	flush_remote(0, cache, &mm->cpu_vm_mask, start, end - start, size,
-		     &mm->cpu_vm_mask, NULL, 0);
+	flush_remote(0, cache, &mm->cpu_vm_mask, start, end - start,
+			PAGE_SIZE, &mm->cpu_vm_mask, NULL, 0);
+	if (vma->vm_flags & VM_HUGETLB) {
+		flush_remote(0, 0, &mm->cpu_vm_mask, start, end - start,
+				HPAGE_SIZE, &mm->cpu_vm_mask, NULL, 0);
+	}
 }
 
 void flush_tlb_all(void)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
