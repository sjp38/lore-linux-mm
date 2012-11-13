Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 020796B006C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:14:39 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3578117eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:14:38 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 01/31] mm/generic: Only flush the local TLB in ptep_set_access_flags()
Date: Tue, 13 Nov 2012 18:13:24 +0100
Message-Id: <1352826834-11774-2-git-send-email-mingo@kernel.org>
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Michel Lespinasse <walken@google.com>

From: Rik van Riel <riel@redhat.com>

The function ptep_set_access_flags() is only ever used to upgrade
access permissions to a page - i.e. they make it less restrictive.

That means the only negative side effect of not flushing remote
TLBs in this function is that other CPUs may incur spurious page
faults, if they happen to access the same address, and still have
a PTE with the old permissions cached in their TLB caches.

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
flush_tlb_fix_spurious_fault() to actually flush the TLB entry.

Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>
[ Changelog massage. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/pgtable-generic.c | 6 +++---
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
