Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 65B366B0085
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:10 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/49] mm: Optimize the TLB flush of sys_mprotect() and change_protection() users
Date: Fri,  7 Dec 2012 10:23:10 +0000
Message-Id: <1354875832-9700-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Ingo Molnar <mingo@kernel.org>

Reuse the NUMA code's 'modified page protections' count that
change_protection() computes and skip the TLB flush if there's
no changes to a range that sys_mprotect() modifies.

Given that mprotect() already optimizes the same-flags case
I expected this optimization to dominantly trigger on
CONFIG_NUMA_BALANCING=y kernels - but even with that feature
disabled it triggers rather often.

There's two reasons for that:

1)

While sys_mprotect() already optimizes the same-flag case:

        if (newflags == oldflags) {
                *pprev = vma;
                return 0;
        }

and this test works in many cases, but it is too sharp in some
others, where it differentiates between protection values that the
underlying PTE format makes no distinction about, such as
PROT_EXEC == PROT_READ on x86.

2)

Even where the pte format over vma flag changes necessiates a
modification of the pagetables, there might be no pagetables
yet to modify: they might not be instantiated yet.

During a regular desktop bootup this optimization hits a couple
of hundred times. During a Java test I measured thousands of
hits.

So this optimization improves sys_mprotect() in general, not just
CONFIG_NUMA_BALANCING=y kernels.

[ We could further increase the efficiency of this optimization if
  change_pte_range() and change_huge_pmd() was a bit smarter about
  recognizing exact-same-value protection masks - when the hardware
  can do that safely. This would probably further speed up mprotect(). ]

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/mprotect.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 1e265be..7c3628a 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -153,7 +153,9 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 				 dirty_accountable);
 	} while (pgd++, addr = next, addr != end);
 
-	flush_tlb_range(vma, start, end);
+	/* Only flush the TLB if we actually modified any entries: */
+	if (pages)
+		flush_tlb_range(vma, start, end);
 
 	return pages;
 }
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
