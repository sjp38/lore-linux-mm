Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2D6B38D003E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 19:43:47 -0500 (EST)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 1/6] mm: use mm_struct to resolve gate vma's in __get_user_pages
Date: Tue,  8 Mar 2011 19:42:18 -0500
Message-Id: <1299631343-4499-2-git-send-email-wilsons@start.ca>
In-Reply-To: <1299631343-4499-1-git-send-email-wilsons@start.ca>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

We now check if a requested user page overlaps a gate vma using the supplied mm
instead of the supplied task.  The given task is now used solely for accounting
purposes and may be NULL.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 mm/memory.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 3863e86..36445e3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1437,9 +1437,9 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		struct vm_area_struct *vma;
 
 		vma = find_extend_vma(mm, start);
-		if (!vma && in_gate_area(tsk->mm, start)) {
+		if (!vma && in_gate_area(mm, start)) {
 			unsigned long pg = start & PAGE_MASK;
-			struct vm_area_struct *gate_vma = get_gate_vma(tsk->mm);
+			struct vm_area_struct *gate_vma = get_gate_vma(mm);
 			pgd_t *pgd;
 			pud_t *pud;
 			pmd_t *pmd;
@@ -1533,10 +1533,13 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 						return i ? i : -EFAULT;
 					BUG();
 				}
-				if (ret & VM_FAULT_MAJOR)
-					tsk->maj_flt++;
-				else
-					tsk->min_flt++;
+
+				if (tsk) {
+					if (ret & VM_FAULT_MAJOR)
+						tsk->maj_flt++;
+					else
+						tsk->min_flt++;
+				}
 
 				if (ret & VM_FAULT_RETRY) {
 					*nonblocking = 0;
@@ -1581,7 +1584,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 
 /**
  * get_user_pages() - pin user pages in memory
- * @tsk:	task_struct of target task
+ * @tsk:	the task_struct to use for page fault accounting, or
+ *		NULL if faults are not to be recorded.
  * @mm:		mm_struct of target mm
  * @start:	starting user address
  * @nr_pages:	number of pages from start to pin
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
