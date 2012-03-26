Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 53A7C6B007E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:57:13 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 28/39] autonuma: follow_page check for pte_numa/pmd_numa
Date: Mon, 26 Mar 2012 19:46:15 +0200
Message-Id: <1332783986-24195-29-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Without this, follow_page wouldn't trigger the NUMA hinting faults.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/memory.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index eac888a..a0f35cd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1486,7 +1486,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 		goto no_page_table;
 
 	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd))
+	if (pmd_none(*pmd) || pmd_numa(*pmd))
 		goto no_page_table;
 	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
 		BUG_ON(flags & FOLL_GET);
@@ -1520,7 +1520,7 @@ split_fallthrough:
 	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	pte = *ptep;
-	if (!pte_present(pte))
+	if (!pte_present(pte) || pte_numa(pte))
 		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
