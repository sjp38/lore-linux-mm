Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 933B86B010A
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:57:50 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH -mm v2 03/11] mm: vma_adjust: only call adjust_free_gap when needed
Date: Thu, 21 Jun 2012 17:57:07 -0400
Message-Id: <1340315835-28571-4-git-send-email-riel@surriel.com>
In-Reply-To: <1340315835-28571-1-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>

When inserting or removing VMAs in adjust_vma, __insert_vm_struct
and __vma_unlink already take care of keeping the free gap information
in the VMA rbtree up to date.

Only if VMA boundaries shift without VMA insertion or removal on that side
of vma, vma_adjust needs to call adjust_free_gap.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/mmap.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index dd6edcd..95f66c5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -562,6 +562,7 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	struct prio_tree_root *root = NULL;
 	struct anon_vma *anon_vma = NULL;
 	struct file *file = vma->vm_file;
+	bool start_changed = false, end_changed = false;
 	long adjust_next = 0;
 	int remove_next = 0;
 
@@ -651,8 +652,14 @@ again:			remove_next = 1 + (end > next->vm_end);
 			vma_prio_tree_remove(next, root);
 	}
 
-	vma->vm_start = start;
-	vma->vm_end = end;
+	if (start != vma->vm_start) {
+		vma->vm_start = start;
+		start_changed = true;
+	}
+	if (end != vma->vm_end) {
+		vma->vm_end = end;
+		end_changed = true;
+	}
 	vma->vm_pgoff = pgoff;
 	if (adjust_next) {
 		next->vm_start += adjust_next << PAGE_SHIFT;
@@ -720,14 +727,18 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (insert && file)
 		uprobe_mmap(insert);
 
-	/* Adjust the rb tree for changes in the free gaps between VMAs. */
-	adjust_free_gap(vma);
-	if (insert)
-		adjust_free_gap(insert);
-	if (vma->vm_next && vma->vm_next != insert)
+	/*
+	 * When inserting or removing VMAs, __insert_vm_struct or __vma_unlink
+	 * have already taken care of updating the free gap information on
+	 * that side of vma.
+	 * Only call adjust_free_gap if VMA boundaries changed without
+	 * insertion or removal on that side of vma.
+	 */
+	if (start_changed && (!vma->vm_prev || vma->vm_prev != insert))
+		adjust_free_gap(vma);
+	if (end_changed && !remove_next && vma->vm_next &&
+						vma->vm_next != insert)
 		adjust_free_gap(vma->vm_next);
-	if (insert && insert->vm_next && insert->vm_next != vma)
-		adjust_free_gap(insert->vm_next);
 
 	validate_mm(mm);
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
