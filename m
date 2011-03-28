Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 017968D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:57:03 -0400 (EDT)
Received: by pvg4 with SMTP id 4so777017pvg.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:57:01 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 1/6] nommu: sort mm->mmap list properly
Date: Mon, 28 Mar 2011 22:56:42 +0900
Message-Id: <1301320607-7259-2-git-send-email-namhyung@gmail.com>
In-Reply-To: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
References: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Greg Ungerer <gerg@snapgear.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

@vma added into @mm should be sorted by start addr, end addr and VMA struct
addr in that order because we may get identical VMAs in the @mm. However
this was true only for the rbtree, not for the list.

This patch fixes this by remembering 'rb_prev' during the tree traversal
like find_vma_prepare() does and linking the @vma via __vma_link_list().
After this patch, we can iterate the whole VMAs in correct order simply
by using @mm->mmap list.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/nommu.c |   62 ++++++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 40 insertions(+), 22 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index e7dbd3fae187..20d9c330eb0e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -672,6 +672,30 @@ static void protect_vma(struct vm_area_struct *vma, unsigned long flags)
 #endif
 }
 
+/* borrowed from mm/mmap.c */
+static inline void
+__vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
+		struct vm_area_struct *prev, struct rb_node *rb_parent)
+{
+	struct vm_area_struct *next;
+
+	vma->vm_prev = prev;
+	if (prev) {
+		next = prev->vm_next;
+		prev->vm_next = vma;
+	} else {
+		mm->mmap = vma;
+		if (rb_parent)
+			next = rb_entry(rb_parent,
+					struct vm_area_struct, vm_rb);
+		else
+			next = NULL;
+	}
+	vma->vm_next = next;
+	if (next)
+		next->vm_prev = vma;
+}
+
 /*
  * add a VMA into a process's mm_struct in the appropriate place in the list
  * and tree and add to the address space's page tree also if not an anonymous
@@ -680,9 +704,9 @@ static void protect_vma(struct vm_area_struct *vma, unsigned long flags)
  */
 static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	struct vm_area_struct *pvma, **pp, *next;
+	struct vm_area_struct *pvma, *prev;
 	struct address_space *mapping;
-	struct rb_node **p, *parent;
+	struct rb_node **p, *parent, *rb_prev;
 
 	kenter(",%p", vma);
 
@@ -703,7 +727,7 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 	}
 
 	/* add the VMA to the tree */
-	parent = NULL;
+	parent = rb_prev = NULL;
 	p = &mm->mm_rb.rb_node;
 	while (*p) {
 		parent = *p;
@@ -713,17 +737,20 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 		 * (the latter is necessary as we may get identical VMAs) */
 		if (vma->vm_start < pvma->vm_start)
 			p = &(*p)->rb_left;
-		else if (vma->vm_start > pvma->vm_start)
+		else if (vma->vm_start > pvma->vm_start) {
+			rb_prev = parent;
 			p = &(*p)->rb_right;
-		else if (vma->vm_end < pvma->vm_end)
+		} else if (vma->vm_end < pvma->vm_end)
 			p = &(*p)->rb_left;
-		else if (vma->vm_end > pvma->vm_end)
+		else if (vma->vm_end > pvma->vm_end) {
+			rb_prev = parent;
 			p = &(*p)->rb_right;
-		else if (vma < pvma)
+		} else if (vma < pvma)
 			p = &(*p)->rb_left;
-		else if (vma > pvma)
+		else if (vma > pvma) {
+			rb_prev = parent;
 			p = &(*p)->rb_right;
-		else
+		} else
 			BUG();
 	}
 
@@ -731,20 +758,11 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
 
 	/* add VMA to the VMA list also */
-	for (pp = &mm->mmap; (pvma = *pp); pp = &(*pp)->vm_next) {
-		if (pvma->vm_start > vma->vm_start)
-			break;
-		if (pvma->vm_start < vma->vm_start)
-			continue;
-		if (pvma->vm_end < vma->vm_end)
-			break;
-	}
+	prev = NULL;
+	if (rb_prev)
+		prev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
 
-	next = *pp;
-	*pp = vma;
-	vma->vm_next = next;
-	if (next)
-		next->vm_prev = vma;
+	__vma_link_list(mm, vma, prev, parent);
 }
 
 /*
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
