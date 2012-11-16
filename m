Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id EEF406B0089
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:25:51 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2125091eek.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 08:25:51 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 08/19] mm: Only flush the TLB when clearing an accessible pte
Date: Fri, 16 Nov 2012 17:25:10 +0100
Message-Id: <1353083121-4560-9-git-send-email-mingo@kernel.org>
In-Reply-To: <1353083121-4560-1-git-send-email-mingo@kernel.org>
References: <1353083121-4560-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

From: Rik van Riel <riel@redhat.com>

If ptep_clear_flush() is called to clear a page table entry that is
accessible anyway by the CPU, eg. a _PAGE_PROTNONE page table entry,
there is no need to flush the TLB on remote CPUs.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Link: http://lkml.kernel.org/n/tip-vm3rkzevahelwhejx5uwm8ex@git.kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/pgtable-generic.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index d8397da..0c8323f 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -88,7 +88,8 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
