Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id B89BC6B0075
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:01 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/49] x86: mm: drop TLB flush from ptep_set_access_flags
Date: Fri,  7 Dec 2012 10:23:05 +0000
Message-Id: <1354875832-9700-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

Intel has an architectural guarantee that the TLB entry causing
a page fault gets invalidated automatically. This means
we should be able to drop the local TLB invalidation.

Because of the way other areas of the page fault code work,
chances are good that all x86 CPUs do this.  However, if
someone somewhere has an x86 CPU that does not invalidate
the TLB entry causing a page fault, this one-liner should
be easy to revert.

Signed-off-by: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
---
 arch/x86/mm/pgtable.c |    1 -
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
