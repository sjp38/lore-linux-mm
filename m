Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7C1826B00A0
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:50:58 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so6043409eek.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:50:58 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 12/33] numa, mm: Support NUMA hinting page faults from gup/gup_fast
Date: Thu, 22 Nov 2012 23:49:33 +0100
Message-Id: <1353624594-1118-13-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Andrea Arcangeli <aarcange@redhat.com>

Introduce FOLL_NUMA to tell follow_page to check
pte/pmd_numa. get_user_pages must use FOLL_NUMA, and it's safe to do
so because it always invokes handle_mm_fault and retries the
follow_page later.

KVM secondary MMU page faults will trigger the NUMA hinting page
faults through gup_fast -> get_user_pages -> follow_page ->
handle_mm_fault.

Other follow_page callers like KSM should not use FOLL_NUMA, or they
would fail to get the pages if they use follow_page instead of
get_user_pages.

[ This patch was picked up from the AutoNUMA tree. ]

Originally-by: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
[ ported to this tree. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 17 +++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 246375c..f39a628 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1585,6 +1585,7 @@ struct page *follow_page(struct vm_area_struct *, unsigned long address,
 #define FOLL_MLOCK	0x40	/* mark page as mlocked */
 #define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
 #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
+#define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/mm/memory.c b/mm/memory.c
index b9bb15c..23ad2eb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1522,6 +1522,8 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
 		goto out;
 	}
+	if ((flags & FOLL_NUMA) && pmd_numa(vma, *pmd))
+		goto no_page_table;
 	if (pmd_trans_huge(*pmd)) {
 		if (flags & FOLL_SPLIT) {
 			split_huge_page_pmd(mm, pmd);
@@ -1551,6 +1553,8 @@ split_fallthrough:
 	pte = *ptep;
 	if (!pte_present(pte))
 		goto no_page;
+	if ((flags & FOLL_NUMA) && pte_numa(vma, pte))
+		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;
 
@@ -1702,6 +1706,19 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			(VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
 	vm_flags &= (gup_flags & FOLL_FORCE) ?
 			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
+
+	/*
+	 * If FOLL_FORCE and FOLL_NUMA are both set, handle_mm_fault
+	 * would be called on PROT_NONE ranges. We must never invoke
+	 * handle_mm_fault on PROT_NONE ranges or the NUMA hinting
+	 * page faults would unprotect the PROT_NONE ranges if
+	 * _PAGE_NUMA and _PAGE_PROTNONE are sharing the same pte/pmd
+	 * bitflag. So to avoid that, don't set FOLL_NUMA if
+	 * FOLL_FORCE is set.
+	 */
+	if (!(gup_flags & FOLL_FORCE))
+		gup_flags |= FOLL_NUMA;
+
 	i = 0;
 
 	do {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
