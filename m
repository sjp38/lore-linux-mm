Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 8F4446B00AA
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 06/33] autonuma: teach gup_fast about pmd_numa
Date: Thu,  4 Oct 2012 01:50:48 +0200
Message-Id: <1349308275-2174-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

In the special "pmd" mode of knuma_scand
(/sys/kernel/mm/autonuma/knuma_scand/pmd == 1), the pmd may be of numa
type (_PAGE_PRESENT not set), however the pte might be
present. Therefore, gup_pmd_range() must return 0 in this case to
avoid losing a NUMA hinting page fault during gup_fast.

Note: gup_fast will skip over non present ptes (like numa types), so
no explicit check is needed for the pte_numa case. gup_fast will also
skip over THP when the trans huge pmd is non present. So, the pmd_numa
case will also be correctly skipped with no additional code changes
required.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/mm/gup.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 6dc9921..cad7d97 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -169,8 +169,19 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
