Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 5E83F6B004D
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 17:49:01 -0500 (EST)
Received: by qao25 with SMTP id 25so3025714qao.14
        for <linux-mm@kvack.org>; Fri, 09 Dec 2011 14:49:00 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH v3] mm: simplify find_vma_prev
Date: Fri,  9 Dec 2011 17:48:40 -0500
Message-Id: <1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1323466526.27746.29.camel@joe2Laptop>
References: <1323466526.27746.29.camel@joe2Laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Shaohua Li <shaohua.li@intel.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

commit 297c5eee37 (mm: make the vma list be doubly linked) added
vm_prev member into vm_area_struct. Therefore we can simplify
find_vma_prev() by using it. Also, this change help to improve
page fault performance because it has strong locality of reference.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mmap.c |   36 ++++++++----------------------------
 1 files changed, 8 insertions(+), 28 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index eae90af..b9c0241 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1603,39 +1603,19 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 
 EXPORT_SYMBOL(find_vma);
 
-/* Same as find_vma, but also return a pointer to the previous VMA in *pprev. */
+/*
+ * Same as find_vma, but also return a pointer to the previous VMA in *pprev.
+ * Note: pprev is set to NULL when return value is NULL.
+ */
 struct vm_area_struct *
 find_vma_prev(struct mm_struct *mm, unsigned long addr,
 			struct vm_area_struct **pprev)
 {
-	struct vm_area_struct *vma = NULL, *prev = NULL;
-	struct rb_node *rb_node;
-	if (!mm)
-		goto out;
-
-	/* Guard against addr being lower than the first VMA */
-	vma = mm->mmap;
-
-	/* Go through the RB tree quickly. */
-	rb_node = mm->mm_rb.rb_node;
-
-	while (rb_node) {
-		struct vm_area_struct *vma_tmp;
-		vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
-
-		if (addr < vma_tmp->vm_end) {
-			rb_node = rb_node->rb_left;
-		} else {
-			prev = vma_tmp;
-			if (!prev->vm_next || (addr < prev->vm_next->vm_end))
-				break;
-			rb_node = rb_node->rb_right;
-		}
-	}
+	struct vm_area_struct *vma;
 
-out:
-	*pprev = prev;
-	return prev ? prev->vm_next : vma;
+	vma = find_vma(mm, addr);
+	*pprev = vma ? vma->vm_prev : NULL;
+	return vma;
 }
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
