Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 9FAAD6B006C
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 04:15:06 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/19] mm: numa: teach gup_fast about pmd_numa
Date: Tue,  6 Nov 2012 09:14:42 +0000
Message-Id: <1352193295-26815-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-1-git-send-email-mgorman@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Andrea Arcangeli <aarcange@redhat.com>

When scanning pmds, the pmd may be of numa type (_PAGE_PRESENT not set),
however the pte might be present. Therefore, gup_pmd_range() must return
0 in this case to avoid losing a NUMA hinting page fault during gup_fast.

Note: gup_fast will skip over non present ptes (like numa types), so
no explicit check is needed for the pte_numa case. gup_fast will also
skip over THP when the trans huge pmd is non present. So, the pmd_numa
case will also be correctly skipped with no additional code changes
required.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/mm/gup.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index dd74e46..02c5ec5 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -163,8 +163,19 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		 * can't because it has irq disabled and
 		 * wait_split_huge_page() would never return as the
 		 * tlb flush IPI wouldn't run.
+		 *
+		 * The pmd_numa() check is needed because the code
+		 * doesn't check the _PAGE_PRESENT bit of the pmd if
+		 * the gup_pte_range() path is taken. NOTE: not all
+		 * gup_fast users will will access the page contents
+		 * using the CPU through the NUMA memory channels like
+		 * KVM does. So we're forced to trigger NUMA hinting
+		 * page faults unconditionally for all gup_fast users
+		 * even though NUMA hinting page faults aren't useful
+		 * to I/O drivers that will access the page with DMA
+		 * and not with the CPU.
 		 */
-		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+		if (pmd_none(pmd) || pmd_trans_splitting(pmd) || pmd_numa(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd))) {
 			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
