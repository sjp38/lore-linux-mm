Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 23F9B6B00A0
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:15:22 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3578117eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:15:21 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 19/31] x86/mm: Completely drop the TLB flush from ptep_set_access_flags()
Date: Tue, 13 Nov 2012 18:13:42 +0100
Message-Id: <1352826834-11774-20-git-send-email-mingo@kernel.org>
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Michel Lespinasse <walken@google.com>

From: Rik van Riel <riel@redhat.com>

Intel has an architectural guarantee that the TLB entry causing
a page fault gets invalidated automatically. This means
we should be able to drop the local TLB invalidation.

Because of the way other areas of the page fault code work,
chances are good that all x86 CPUs do this.  However, if
someone somewhere has an x86 CPU that does not invalidate
the TLB entry causing a page fault, this one-liner should
be easy to revert - or a CPU model specific quirk could
be added to retain this optimization on most CPUs.

Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Linus Torvalds <torvalds@kernel.org>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>
[ Applied changelog massage and moved this last in the series,
  to create bisection distance. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/pgtable.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index be3bb46..7353de3 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -317,7 +317,6 @@ int ptep_set_access_flags(struct vm_area_struct *vma,
 	if (changed && dirty) {
 		*ptep = entry;
 		pte_update_defer(vma->vm_mm, address, ptep);
-		__flush_tlb_one(address);
 	}
 
 	return changed;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
