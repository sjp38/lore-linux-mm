Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 4B1226B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 15:54:46 -0400 (EDT)
Date: Fri, 26 Oct 2012 15:33:10 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -v2 3/3] mm,generic: only flush the local TLB in
 ptep_set_access_flags
Message-ID: <20121026153310.51ecdb7f@dull>
In-Reply-To: <CA+55aFxo5jHREHS_ftmM6Vy5+rei2KzzCbrsYJwqSB2TfvA=7w@mail.gmail.com>
References: <20121025121617.617683848@chello.nl>
	<20121025124832.840241082@chello.nl>
	<CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
	<5089F5B5.1050206@redhat.com>
	<CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
	<508A0A0D.4090001@redhat.com>
	<CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
	<CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
	<m2pq45qu0s.fsf@firstfloor.org>
	<508A8D31.9000106@redhat.com>
	<20121026132601.GC9886@gmail.com>
	<20121026144615.2276cd59@dull>
	<CA+55aFyS_iJcKz=-zSDK+bjYiNeEzy4T5FrrGL8HBsxTOSwpJQ@mail.gmail.com>
	<508ADD2F.6030805@redhat.com>
	<CA+55aFxo5jHREHS_ftmM6Vy5+rei2KzzCbrsYJwqSB2TfvA=7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
