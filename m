Date: Thu, 16 Aug 2001 17:02:24 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <Pine.LNX.4.33.0108161651070.24312-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, alan@redhat.com
Cc: linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

Hello again,

This should be the final variant of the vma merging patch: it does tail
merging for mmap and runs the same code after an mprotect syscall via the
merge_anon_vmas and attempt_merge_next functions.  This also includes a
fix to the mremap merging to avoid merge attempts on non-private mappings.
All told, mozilla now uses ~220 vmas for a few quick page loads that would
previously reach ~1650 vmas or more.  This really boosts the speed of
mozilla -- give it a try!  Patch is against 2.4.9 and applies cleanly to
2.4.8-ac5 too.

		-ben

.... v2.4.9-merge-full.diff
diff -urN /md0/kernels/2.4/v2.4.9/include/linux/mm.h foo/include/linux/mm.h
--- /md0/kernels/2.4/v2.4.9/include/linux/mm.h	Tue Aug  7 17:52:06 2001
+++ foo/include/linux/mm.h	Thu Aug 16 16:59:34 2001
@@ -515,6 +515,7 @@
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);

 extern unsigned long do_brk(unsigned long, unsigned long);
+extern void merge_anon_vmas(struct mm_struct *mm, unsigned long start, unsigned long end);

 struct zone_t;
 /* filemap.c */
diff -urN /md0/kernels/2.4/v2.4.9/mm/mmap.c foo/mm/mmap.c
--- /md0/kernels/2.4/v2.4.9/mm/mmap.c	Fri May 25 22:48:10 2001
+++ foo/mm/mmap.c	Thu Aug 16 16:59:35 2001
@@ -17,6 +17,8 @@
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>

+static inline void attempt_merge_next(struct mm_struct *mm, struct vm_area_struct *vma);
+
 /* description of effects of mapping type and prot in current implementation.
  * this is due to the limited x86 page protection hardware.  The expected
  * behavior is in parens:
@@ -309,7 +311,7 @@

 	/* Can we just expand an old anonymous mapping? */
 	if (addr && !file && !(vm_flags & VM_SHARED)) {
-		struct vm_area_struct * vma = find_vma(mm, addr-1);
+		vma = find_vma(mm, addr-1);
 		if (vma && vma->vm_end == addr && !vma->vm_file &&
 		    vma->vm_flags == vm_flags) {
 			vma->vm_end = addr + len;
@@ -365,12 +367,17 @@
 	if (correct_wcount)
 		atomic_inc(&file->f_dentry->d_inode->i_writecount);

-out:
+out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
 		make_pages_present(addr, addr + len);
 	}
+
+	/* Can we merge this anonymous mapping with the one following it? */
+	if (!file && !(vm_flags & VM_SHARED))
+		attempt_merge_next(mm, vma);
+
 	return addr;

 unmap_and_free_vma:
@@ -1004,4 +1011,34 @@
 	__insert_vm_struct(mm, vmp);
 	spin_unlock(&current->mm->page_table_lock);
 	unlock_vma_mappings(vmp);
+}
+
+static inline void attempt_merge_next(struct mm_struct *mm, struct vm_area_struct *vma)
+{
+	struct vm_area_struct *next = vma->vm_next;
+	if (next && vma->vm_end == next->vm_start && !next->vm_file &&
+	    vma->vm_flags == next->vm_flags) {
+		spin_lock(&mm->page_table_lock);
+		vma->vm_next = next->vm_next;
+		if (mm->mmap_avl)
+			avl_remove(next, &mm->mmap_avl);
+		vma->vm_end = next->vm_end;
+		mm->mmap_cache = vma;	/* Kill the cache. */
+		mm->map_count--;
+		spin_unlock(&mm->page_table_lock);
+
+		kmem_cache_free(vm_area_cachep, next);
+	}
+}
+
+void merge_anon_vmas(struct mm_struct *mm, unsigned long start, unsigned long end)
+{
+	struct vm_area_struct *vma;
+	if (start)
+		start--;
+
+	for (vma = find_vma(mm, start); vma && vma->vm_start <= end;
+	     vma = vma->vm_next)
+		if (!vma->vm_file && !(vma->vm_flags & VM_SHARED))
+			attempt_merge_next(mm, vma);
 }
diff -urN /md0/kernels/2.4/v2.4.9/mm/mprotect.c foo/mm/mprotect.c
--- /md0/kernels/2.4/v2.4.9/mm/mprotect.c	Thu Apr  5 11:53:46 2001
+++ foo/mm/mprotect.c	Thu Aug 16 16:59:35 2001
@@ -278,6 +278,7 @@
 			break;
 		}
 	}
+	merge_anon_vmas(current->mm, start, end);
 out:
 	up_write(&current->mm->mmap_sem);
 	return error;
diff -urN /md0/kernels/2.4/v2.4.9/mm/mremap.c foo/mm/mremap.c
--- /md0/kernels/2.4/v2.4.9/mm/mremap.c	Thu May  3 11:22:20 2001
+++ foo/mm/mremap.c	Thu Aug 16 16:59:35 2001
@@ -128,10 +128,23 @@
 	unsigned long new_addr)
 {
 	struct vm_area_struct * new_vma;
+	int allocated_vma = 0;

-	new_vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (new_vma) {
-		if (!move_page_tables(current->mm, new_addr, addr, old_len)) {
+	/* First, check if we can merge a mapping. -ben */
+	new_vma = find_vma(current->mm, new_addr-1);
+	if (new_vma && !vma->vm_file && !(vma->vm_flags & VM_SHARED) &&
+	    new_vma->vm_end == new_addr && !new_vma->vm_file &&
+		new_vma->vm_flags == vma->vm_flags) {
+		new_vma->vm_end = new_addr + new_len;
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
@@ -142,17 +155,20 @@
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
