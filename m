Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7DCD06B0099
	for <linux-mm@kvack.org>; Sat, 17 Jan 2009 12:12:05 -0500 (EST)
Received: by bwz3 with SMTP id 3so165970bwz.14
        for <linux-mm@kvack.org>; Sat, 17 Jan 2009 09:12:02 -0800 (PST)
Message-ID: <8c5a844a0901170912l48bab3fuc306bd77622bb53f@mail.gmail.com>
Date: Sat, 17 Jan 2009 19:12:02 +0200
From: "Daniel Lowengrub" <lowdanie@gmail.com>
Subject: [PATCH 2.6.28 1/2] memory: improve find_vma
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The goal of this patch is to improve the efficiency of the find_vma
function in mm/mmap.c. The function first checks whether the vma
stored in the cache is the one it's looking for. Currently, it's
possible for the cache to be correct and still get rejected because
the function checks whether the given address is inside the vma in the
cache, not whether the cached vma is the smallest one that's bigger
than the address.  To solve this problem I turned the list of vma's
into a doubly linked list, and using that list made a function that
can check if a given vma is the one that find_vma is looking for.
This gives a greater number of cache hits than the standerd method.
The doubly linked list can be used to optimize other parts of the
memory management as well.  I'll implement some of those possibilities
in the next patch.
Signed-off-by: Daniel Lowengrub <lowdanie@gmail.com>
------------------------------------------------------------------------------------------------------------------------
diff -uNr linux-2.6.28.vanilla/include/linux/mm_types.h
linux-2.6.28.new/include/linux/mm_types.h
--- linux-2.6.28.vanilla/include/linux/mm_types.h	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.new/include/linux/mm_types.h	2009-01-16
15:19:15.000000000 +0200
@@ -108,8 +108,9 @@
 	unsigned long vm_end;		/* The first byte after our end address
 					   within vm_mm. */

-	/* linked list of VM areas per task, sorted by address */
+	/* doubly linked list of VM areas per task, sorted by address */
 	struct vm_area_struct *vm_next;
+	struct vm_area_struct *vm_prev;

 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, see mm.h. */
diff -uNr linux-2.6.28.vanilla/kernel/fork.c linux-2.6.28.new/kernel/fork.c
--- linux-2.6.28.vanilla/kernel/fork.c	2008-12-25 01:26:37.000000000 +0200
+++ linux-2.6.28.new/kernel/fork.c	2009-01-17 18:45:43.000000000 +0200
@@ -257,7 +257,7 @@
 #ifdef CONFIG_MMU
 static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	struct vm_area_struct *mpnt, *tmp, **pprev;
+	struct vm_area_struct *mpnt, *tmp, *tmp_prev, **pprev;
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
@@ -311,6 +311,7 @@
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
 		tmp->vm_next = NULL;
+		tmp->vm_prev = NULL;
 		anon_vma_link(tmp);
 		file = tmp->vm_file;
 		if (file) {
@@ -345,6 +346,9 @@
 		*pprev = tmp;
 		pprev = &tmp->vm_next;

+		tmp->vm_prev = tmp_prev;
+		tmp_prev = tmp;
+
 		__vma_link_rb(mm, tmp, rb_link, rb_parent);
 		rb_link = &tmp->vm_rb.rb_right;
 		rb_parent = &tmp->vm_rb;
diff -uNr linux-2.6.28.vanilla/mm/mmap.c linux-2.6.28.new/mm/mmap.c
--- linux-2.6.28.vanilla/mm/mmap.c	2008-12-25 01:26:37.000000000 +0200
+++ linux-2.6.28.new/mm/mmap.c	2009-01-17 18:41:37.000000000 +0200
@@ -393,14 +393,22 @@
 {
 	if (prev) {
 		vma->vm_next = prev->vm_next;
+		vma->vm_prev = prev;
 		prev->vm_next = vma;
+		if (vma->vm_next)
+			vma->vm_next->vm_prev = vma;
+
 	} else {
 		mm->mmap = vma;
-		if (rb_parent)
+		if (rb_parent) {
 			vma->vm_next = rb_entry(rb_parent,
 					struct vm_area_struct, vm_rb);
-		else
+			vma->vm_next->vm_prev = vma;
+			vma->vm_prev = NULL;
+		} else {
 			vma->vm_next = NULL;
+			vma->vm_prev = NULL;
+		}
 	}
 }

@@ -491,6 +499,8 @@
 		struct vm_area_struct *prev)
 {
 	prev->vm_next = vma->vm_next;
+	if (vma->vm_next)
+		vma->vm_next->vm_prev = prev;
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
@@ -1463,38 +1473,52 @@

 EXPORT_SYMBOL(get_unmapped_area);

+/* Checks if this is the first VMA which satisfies addr < vm_end */
+static inline int after_addr(struct vm_area_struct *vma, unsigned long addr)
+{
+	if (!vma)
+		return 0;
+	if (vma->vm_end > addr) {
+		if (!vma->vm_prev)
+			return 1;
+		if (vma->vm_prev->vm_end <= addr)
+			return 1;
+	}
+	return 0;
+}
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
 struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
 {
 	struct vm_area_struct *vma = NULL;
+	struct rb_node *rb_node;

 	if (mm) {
 		/* Check the cache first. */
-		/* (Cache hit rate is typically around 35%.) */
+		/* (The cache is checked using the after_addr function) */
 		vma = mm->mmap_cache;
-		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
-			struct rb_node * rb_node;

-			rb_node = mm->mm_rb.rb_node;
-			vma = NULL;
+		if (after_addr(vma, addr))
+			return vma;

-			while (rb_node) {
-				struct vm_area_struct * vma_tmp;
+		rb_node = mm->mm_rb.rb_node;
+		vma = NULL;

-				vma_tmp = rb_entry(rb_node,
-						struct vm_area_struct, vm_rb);
-
-				if (vma_tmp->vm_end > addr) {
-					vma = vma_tmp;
-					if (vma_tmp->vm_start <= addr)
-						break;
-					rb_node = rb_node->rb_left;
-				} else
-					rb_node = rb_node->rb_right;
-			}
-			if (vma)
-				mm->mmap_cache = vma;
+		while (rb_node) {
+			struct vm_area_struct *vma_tmp;
+
+			vma_tmp = rb_entry(rb_node,
+					struct vm_area_struct, vm_rb);
+
+			if (vma_tmp->vm_end > addr) {
+				vma = vma_tmp;
+				if (vma_tmp->vm_start <= addr)
+					break;
+				rb_node = rb_node->rb_left;
+			} else
+				rb_node = rb_node->rb_right;
 		}
+		if (vma)
+			mm->mmap_cache = vma;
 	}
 	return vma;
 }
@@ -1806,6 +1830,7 @@
 		vma = vma->vm_next;
 	} while (vma && vma->vm_start < end);
 	*insertion_point = vma;
+	vma->vm_prev = prev ? prev : NULL;
 	tail_vma->vm_next = NULL;
 	if (mm->unmap_area == arch_unmap_area)
 		addr = prev ? prev->vm_end : mm->mmap_base;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
