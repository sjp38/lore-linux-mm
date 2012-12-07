Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 8438E6B0078
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:03 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/49] mm,generic: only flush the local TLB in ptep_set_access_flags
Date: Fri,  7 Dec 2012 10:23:06 +0000
Message-Id: <1354875832-9700-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

The function ptep_set_access_flags is only ever used to upgrade
access permissions to a page. That means the only negative side
effect of not flushing remote TLBs is that other CPUs may incur
spurious page faults, if they happen to access the same address,
and still have a PTE with the old permissions cached in their
TLB.

Having another CPU maybe incur a spurious page fault is faster
than always incurring the cost of a remote TLB flush, so replace
the remote TLB flush with a purely local one.

This should be safe on every architecture that correctly
implements flush_tlb_fix_spurious_fault() to actually invalidate
the local TLB entry that caused a page fault, as well as on
architectures where the hardware invalidates TLB entries that
cause page faults.

In the unlikely event that you are hitting what appears to be
an infinite loop of page faults, and 'git bisect' took you to
this changeset, your architecture needs to implement
flush_tlb_fix_spurious_fault to actually flush the TLB entry.

Signed-off-by: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Michel Lespinasse <walken@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
---
 mm/pgtable-generic.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index e642627..d8397da 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -12,8 +12,8 @@
 
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
- * Only sets the access flags (dirty, accessed, and
- * writable). Furthermore, we know it always gets set to a "more
+ * Only sets the access flags (dirty, accessed), as well as write 
+ * permission. Furthermore, we know it always gets set to a "more
  * permissive" setting, which allows most architectures to optimize
  * this. We return whether the PTE actually changed, which in turn
  * instructs the caller to do things like update__mmu_cache.  This
@@ -27,7 +27,7 @@ int ptep_set_access_flags(struct vm_area_struct *vma,
 	int changed = !pte_same(*ptep, entry);
 	if (changed) {
 		set_pte_at(vma->vm_mm, address, ptep, entry);
-		flush_tlb_page(vma, address);
+		flush_tlb_fix_spurious_fault(vma, address);
 	}
 	return changed;
 }
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
