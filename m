Date: Wed, 15 Aug 2001 15:44:16 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] mremap merging.
In-Reply-To: <Pine.LNX.4.33.0108151036350.2407-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33.0108151539240.28240-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This one should actually be correct -- it just looks big as it flattens
the code in do_mremap somewhat.  There's a test program at
http://www.kvack.org/~blah/mremap_test5.c that will trigger the "merged!"
printk and show the results from /proc/<pid>/maps.  Mozilla isn't
triggering it, though, so I'm looking at mprotect now.

Also, mmap/mremap are failing to merge some segments as the BSS of a
program is marked with the executable bit.  At least on x86, X on a page
does nothing, so I'm wondering if we should strip that out from vm_flags
as I was originally suspecting?  At least on my machine it seems to be hit
occasionally.

		-ben

diff -ur /md0/kernels/2.4/v2.4.8-ac5/mm/mremap.c work-v2.4.8-ac5/mm/mremap.c
--- /md0/kernels/2.4/v2.4.8-ac5/mm/mremap.c	Wed Aug 15 12:57:40 2001
+++ work-v2.4.8-ac5/mm/mremap.c	Wed Aug 15 14:59:02 2001
@@ -132,10 +132,23 @@
 	unsigned long new_addr)
 {
 	struct vm_area_struct * new_vma;
+	int allocated_vma = 0;

-	new_vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (new_vma) {
-		if (!move_page_tables(current->mm, new_addr, addr, old_len)) {
+	/* First, check if we can merge a mapping. -ben */
+	new_vma = find_vma(current->mm, new_addr-1);
+	if (new_vma && new_vma->vm_end == new_addr && !new_vma->vm_file &&
+		new_vma->vm_flags == vma->vm_flags) {
+		new_vma->vm_end = new_addr + new_len;
+printk("merged!\n");
+	} else {
+		new_vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+		if (!new_vma)
+			goto no_mem;
+		allocated_vma = 1;
+	}
+
+	if (!move_page_tables(current->mm, new_addr, addr, old_len)) {
+		if (allocated_vma) {
 			*new_vma = *vma;
 			new_vma->vm_start = new_addr;
 			new_vma->vm_end = new_addr+new_len;
@@ -146,17 +159,20 @@
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
 			insert_vm_struct(current->mm, new_vma);
-			do_munmap(current->mm, addr, old_len);
-			current->mm->total_vm += new_len >> PAGE_SHIFT;
-			if (new_vma->vm_flags & VM_LOCKED) {
-				current->mm->locked_vm += new_len >> PAGE_SHIFT;
-				make_pages_present(new_vma->vm_start,
-						   new_vma->vm_end);
-			}
-			return new_addr;
 		}
-		kmem_cache_free(vm_area_cachep, new_vma);
+		do_munmap(current->mm, addr, old_len);
+		current->mm->total_vm += new_len >> PAGE_SHIFT;
+		if (new_vma->vm_flags & VM_LOCKED) {
+			current->mm->locked_vm += new_len >> PAGE_SHIFT;
+			make_pages_present(new_vma->vm_start,
+					   new_vma->vm_end);
+		}
+		return new_addr;
 	}
+	if (allocated_vma)
+		kmem_cache_free(vm_area_cachep, new_vma);
+
+no_mem:
 	return -ENOMEM;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
