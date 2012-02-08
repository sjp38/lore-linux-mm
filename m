Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7AC716B13F2
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 19:01:20 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so82007pbc.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 16:01:19 -0800 (PST)
Date: Tue, 7 Feb 2012 16:00:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix UP THP spin_is_locked BUGs
Message-ID: <alpine.LSU.2.00.1202071556460.7549@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

Fix CONFIG_TRANSPARENT_HUGEPAGE=y CONFIG_SMP=n CONFIG_DEBUG_VM=y
CONFIG_DEBUG_SPINLOCK=n kernel: spin_is_locked() is then always false,
and so triggers some BUGs in Transparent HugePage codepaths.

asm-generic/bug.h mentions this problem, and provides a WARN_ON_SMP(x);
but being too lazy to add VM_BUG_ON_SMP, BUG_ON_SMP, WARN_ON_SMP_ONCE,
VM_WARN_ON_SMP_ONCE, just test NR_CPUS != 1 in the existing VM_BUG_ONs.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/huge_memory.c |    4 ++--
 mm/swap.c        |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

--- 3.3-rc2/mm/huge_memory.c	2012-01-20 08:42:35.304020840 -0800
+++ linux/mm/huge_memory.c	2012-02-07 15:37:18.581666053 -0800
@@ -2083,7 +2083,7 @@ static void collect_mm_slot(struct mm_sl
 {
 	struct mm_struct *mm = mm_slot->mm;
 
-	VM_BUG_ON(!spin_is_locked(&khugepaged_mm_lock));
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
 
 	if (khugepaged_test_exit(mm)) {
 		/* free mm_slot */
@@ -2113,7 +2113,7 @@ static unsigned int khugepaged_scan_mm_s
 	int progress = 0;
 
 	VM_BUG_ON(!pages);
-	VM_BUG_ON(!spin_is_locked(&khugepaged_mm_lock));
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
 
 	if (khugepaged_scan.mm_slot)
 		mm_slot = khugepaged_scan.mm_slot;
--- 3.3-rc2/mm/swap.c	2012-01-20 08:42:35.324020840 -0800
+++ linux/mm/swap.c	2012-02-07 15:37:18.581666053 -0800
@@ -659,7 +659,7 @@ void lru_add_page_tail(struct zone* zone
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(!spin_is_locked(&zone->lru_lock));
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&zone->lru_lock));
 
 	SetPageLRU(page_tail);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
