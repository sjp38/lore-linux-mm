Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id B767B6B006E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 06:33:41 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so971403pbb.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:33:41 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 2/6] mm: check rb_subtree_gap correctness
Date: Wed, 31 Oct 2012 03:33:21 -0700
Message-Id: <1351679605-4816-3-git-send-email-walken@google.com>
In-Reply-To: <1351679605-4816-1-git-send-email-walken@google.com>
References: <1351679605-4816-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org

When CONFIG_DEBUG_VM_RB is enabled, check that rb_subtree_gap is
correctly set for every vma and that mm->highest_vm_end is also correct.

Also add an explicit 'bug' variable to track if browse_rb() detected any
invalid condition.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/mmap.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 4b14c4070305..548fed471398 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -365,7 +365,7 @@ static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
 #ifdef CONFIG_DEBUG_VM_RB
 static int browse_rb(struct rb_root *root)
 {
-	int i = 0, j;
+	int i = 0, j, bug = 0;
 	struct rb_node *nd, *pn = NULL;
 	unsigned long prev = 0, pend = 0;
 
@@ -373,39 +373,47 @@ static int browse_rb(struct rb_root *root)
 		struct vm_area_struct *vma;
 		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
 		if (vma->vm_start < prev)
-			printk("vm_start %lx prev %lx\n", vma->vm_start, prev), i = -1;
+			printk("vm_start %lx prev %lx\n", vma->vm_start, prev), bug = 1;
 		if (vma->vm_start < pend)
-			printk("vm_start %lx pend %lx\n", vma->vm_start, pend);
+			printk("vm_start %lx pend %lx\n", vma->vm_start, pend), bug = 1;
 		if (vma->vm_start > vma->vm_end)
-			printk("vm_end %lx < vm_start %lx\n", vma->vm_end, vma->vm_start);
+			printk("vm_end %lx < vm_start %lx\n", vma->vm_end, vma->vm_start), bug = 1;
+		if (vma->rb_subtree_gap != vma_compute_subtree_gap(vma))
+			printk("free gap %lx, correct %lx\n",
+			       vma->rb_subtree_gap,
+			       vma_compute_subtree_gap(vma)), bug = 1;
 		i++;
 		pn = nd;
 		prev = vma->vm_start;
 		pend = vma->vm_end;
 	}
 	j = 0;
-	for (nd = pn; nd; nd = rb_prev(nd)) {
+	for (nd = pn; nd; nd = rb_prev(nd))
 		j++;
-	}
 	if (i != j)
-		printk("backwards %d, forwards %d\n", j, i), i = 0;
-	return i;
+		printk("backwards %d, forwards %d\n", j, i), bug = 1;
+	return bug ? -1 : i;
 }
 
 void validate_mm(struct mm_struct *mm)
 {
 	int bug = 0;
 	int i = 0;
+	unsigned long highest_address = 0;
 	struct vm_area_struct *vma = mm->mmap;
 	while (vma) {
 		struct anon_vma_chain *avc;
 		list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
 			anon_vma_interval_tree_verify(avc);
+		highest_address = vma->vm_end;
 		vma = vma->vm_next;
 		i++;
 	}
 	if (i != mm->map_count)
 		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
+	if (highest_address != mm->highest_vm_end)
+		printk("mm->highest_vm_end %lx, found %lx\n",
+		       mm->highest_vm_end, highest_address), bug = 1;
 	i = browse_rb(&mm->mm_rb);
 	if (i != mm->map_count)
 		printk("map_count %d rb %d\n", mm->map_count, i), bug = 1;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
