Received: from willy by www.linux.org.uk with local (Exim 3.13 #1)
	id 15ywz2-0002lZ-00
	for linux-mm@kvack.org; Wed, 31 Oct 2001 15:08:48 +0000
Date: Wed, 31 Oct 2001 15:08:48 +0000
From: Matthew Wilcox <willy@debian.org>
Subject: untested vm patch :-)
Message-ID: <20011031150848.A5120@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch rewrites the new rb-tree find_vma_prev in the style used in
a patch I posted back in January.  Back at that time, I was under the
impression we were trying to stabilise a kernel, so I didn't push for
its inclusion.  But if the VM can get such a huge rewrite, it's probably
worth pushing this patch.

It should speed up page fault handling on ia64 (and is required to make
page fault handling work at all on pa-risc).  It seems more obviously
correct to me.  I haven't tested it because we're not moving the parisc
tree from 2.4.9 until there's something more stable available.

diff -u linux-2413/mm/mmap.c linux-2413-pa/mm/mmap.c
--- linux-2413/mm/mmap.c	Fri Oct 12 10:11:45 2001
+++ linux-2413-pa/mm/mmap.c	Thu Oct 25 07:52:48 2001
@@ -671,49 +671,53 @@
 struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
 				      struct vm_area_struct **pprev)
 {
-	if (mm) {
-		/* Go through the RB tree quickly. */
-		struct vm_area_struct * vma;
-		rb_node_t * rb_node, * rb_last_right, * rb_prev;
-		
-		rb_node = mm->mm_rb.rb_node;
-		rb_last_right = rb_prev = NULL;
-		vma = NULL;
-
-		while (rb_node) {
-			struct vm_area_struct * vma_tmp;
-
-			vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
-
-			if (vma_tmp->vm_end > addr) {
-				vma = vma_tmp;
-				rb_prev = rb_last_right;
-				if (vma_tmp->vm_start <= addr)
-					break;
-				rb_node = rb_node->rb_left;
-			} else {
-				rb_last_right = rb_node;
-				rb_node = rb_node->rb_right;
-			}
-		}
-		if (vma) {
-			if (vma->vm_rb.rb_left) {
-				rb_prev = vma->vm_rb.rb_left;
-				while (rb_prev->rb_right)
-					rb_prev = rb_prev->rb_right;
-			}
-			*pprev = NULL;
-			if (rb_prev)
-				*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
-			if ((rb_prev ? (*pprev)->vm_next : mm->mmap) != vma)
-				BUG();
-			return vma;
+	struct vm_area_struct *vma = NULL, *prev = NULL;
+	rb_node_t * rb_node;
+	if (!mm)
+		goto out;
+
+	/* Guard against addr being lower than the first VMA */
+	vma = mm->mmap;
+
+	/* Go through the RB tree quickly. */
+	rb_node = mm->mm_rb.rb_node;
+
+	while (rb_node) {
+		struct vm_area_struct *vma_tmp;
+		vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
+
+		if (addr < vma_tmp->vm_end) {
+			rb_node = rb_node->rb_left;
+		} else {
+			prev = vma_tmp;
+			if (!prev->vm_next || (addr < prev->vm_next->vm_end))
+				break;
+			rb_node = rb_node->rb_right;
 		}
 	}
-	*pprev = NULL;
-	return NULL;
+
+ out:
+	*pprev = prev;
+	return prev ? prev->vm_next : vma;
 }
 
+#ifdef ARCH_STACK_GROWSUP
+struct vm_area_struct * find_extend_vma(struct mm_struct * mm, unsigned long addr)
+{
+	struct vm_area_struct *vma, *prev;
+
+	addr &= PAGE_MASK;
+	vma = find_vma_prev(mm, addr, &prev);
+	if (vma && (vma->vm_start <= addr))
+		return vma;
+	if (!prev || expand_stack(prev, addr))
+		return NULL;
+	if (prev->vm_flags & VM_LOCKED) {
+		make_pages_present(addr, prev->vm_end);
+	}
+	return prev;
+}
+#else
 struct vm_area_struct * find_extend_vma(struct mm_struct * mm, unsigned long addr)
 {
 	struct vm_area_struct * vma;
@@ -735,6 +739,7 @@
 	}
 	return vma;
 }
+#endif
 
 /* Normal function to fix up a mapping
  * This function is the default for when an area has no specific

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
