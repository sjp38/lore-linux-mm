Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 7E1656B007E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:18:43 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 06/39] autonuma: teach gup_fast about pte_numa
Date: Mon, 26 Mar 2012 19:45:53 +0200
Message-Id: <1332783986-24195-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

gup_fast will skip over non present ptes (pte_numa requires the pte to
be non present). So no explicit check is needed for pte_numa in the
pte case.

gup_fast will also automatically skip over THP when the trans huge pmd
is non present (pmd_numa requires the pmd to be non present).

But for the special pmd mode scan of knuma_scand
(/sys/kernel/mm/autonuma/knuma_scand/pmd == 1), the pmd may be of numa
type (so non present too), the pte may be present. gup_pte_range
wouldn't notice the pmd is of numa type. So to avoid losing a NUMA
hinting page fault with gup_fast we need an explicit check for
pmd_numa() here to be sure it will fault through gup ->
handle_mm_fault.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/mm/gup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index dd74e46..bf36575 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -164,7 +164,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		 * wait_split_huge_page() would never return as the
 		 * tlb flush IPI wouldn't run.
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
