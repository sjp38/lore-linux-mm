Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 3E8506B0074
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:25:39 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2125091eek.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 08:25:37 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 02/19] x86/mm: Only do a local tlb flush in ptep_set_access_flags()
Date: Fri, 16 Nov 2012 17:25:04 +0100
Message-Id: <1353083121-4560-3-git-send-email-mingo@kernel.org>
In-Reply-To: <1353083121-4560-1-git-send-email-mingo@kernel.org>
References: <1353083121-4560-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>

From: Rik van Riel <riel@redhat.com>

Because we only ever upgrade a PTE when calling ptep_set_access_flags(),
it is safe to skip flushing entries on remote TLBs.

The worst that can happen is a spurious page fault on other CPUs, which
would flush that TLB entry.

Lazily letting another CPU incur a spurious page fault occasionally
is (much!) cheaper than aggressively flushing everybody else's TLB.

Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/pgtable.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 8573b83..be3bb46 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -301,6 +301,13 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }
 
+/*
+ * Used to set accessed or dirty bits in the page table entries
+ * on other architectures. On x86, the accessed and dirty bits
+ * are tracked by hardware. However, do_wp_page calls this function
+ * to also make the pte writeable at the same time the dirty bit is
+ * set. In that case we do actually need to write the PTE.
+ */
 int ptep_set_access_flags(struct vm_area_struct *vma,
 			  unsigned long address, pte_t *ptep,
 			  pte_t entry, int dirty)
@@ -310,7 +317,7 @@ int ptep_set_access_flags(struct vm_area_struct *vma,
 	if (changed && dirty) {
 		*ptep = entry;
 		pte_update_defer(vma->vm_mm, address, ptep);
-		flush_tlb_page(vma, address);
+		__flush_tlb_one(address);
 	}
 
 	return changed;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
