Date: Tue, 6 Aug 2002 18:27:10 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH][PATCH] expand_stack upward growing stack & comments
In-Reply-To: <Pine.LNX.4.44L.0208061818350.23404-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.44L.0208061825560.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <willy@debian.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Aug 2002, Rik van Riel wrote:

> the following patch implements:
>
> - expand_stack for upward growing stacks, thanks to Matthew Wilcox
> - trivial: cache file->f_dentry->d_inode; saves a few bytes of compiled
>   size. (also by Matthew Wilcox)
> - fix the comment in expand_stack that left Matthew puzzled (me)

Ohhh crap, of course I forgot to attach the patch ;)

> Please apply for the next kernel,

Here it is, against today's 2.5-bk ;)

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".



===== mm/mmap.c 1.43 vs edited =====
--- 1.43/mm/mmap.c	Mon Jul 29 16:23:46 2002
+++ edited/mm/mmap.c	Tue Aug  6 18:17:50 2002
@@ -422,6 +422,7 @@
 {
 	struct mm_struct * mm = current->mm;
 	struct vm_area_struct * vma, * prev;
+	struct inode *inode = NULL;
 	unsigned int vm_flags;
 	int correct_wcount = 0;
 	int error;
@@ -469,17 +470,18 @@
 	}

 	if (file) {
+		inode = file->f_dentry->d_inode;
 		switch (flags & MAP_TYPE) {
 		case MAP_SHARED:
 			if ((prot & PROT_WRITE) && !(file->f_mode & FMODE_WRITE))
 				return -EACCES;

 			/* Make sure we don't allow writing to an append-only file.. */
-			if (IS_APPEND(file->f_dentry->d_inode) && (file->f_mode & FMODE_WRITE))
+			if (IS_APPEND(inode) && (file->f_mode & FMODE_WRITE))
 				return -EACCES;

 			/* make sure there are no mandatory locks on the file. */
-			if (locks_verify_locked(file->f_dentry->d_inode))
+			if (locks_verify_locked(inode))
 				return -EAGAIN;

 			vm_flags |= VM_SHARED | VM_MAYSHARE;
@@ -603,7 +605,7 @@

 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	if (correct_wcount)
-		atomic_inc(&file->f_dentry->d_inode->i_writecount);
+		atomic_inc(&inode->i_writecount);

 out:
 	mm->total_vm += len >> PAGE_SHIFT;
@@ -615,7 +617,7 @@

 unmap_and_free_vma:
 	if (correct_wcount)
-		atomic_inc(&file->f_dentry->d_inode->i_writecount);
+		atomic_inc(&inode->i_writecount);
 	vma->vm_file = NULL;
 	fput(file);

@@ -755,38 +757,43 @@
 	return prev ? prev->vm_next : vma;
 }

+#ifdef ARCH_STACK_GROWSUP
 /*
- * vma is the first one with  address < vma->vm_end,
- * and even address < vma->vm_start. Have to extend vma.
+ * vma is the first one with address > vma->vm_end.  Have to extend vma.
  */
 int expand_stack(struct vm_area_struct * vma, unsigned long address)
 {
 	unsigned long grow;

+	if (!(vma->vm_flags & VM_GROWSUP))
+		return -EFAULT;
+
 	/*
-	 * vma->vm_start/vm_end cannot change under us because the caller
-	 * is required to hold the mmap_sem in write mode. We need to get
-	 * the spinlock only before relocating the vma range ourself.
+	 * Subtle: in order to modify the vma list we would need to hold
+	 * the mmap_sem in write mode, however the page fault path holds
+	 * the mmap_sem only in read mode.  This works out ok because:
+	 * - we only change the size of this VMA and don't modify the VMA list
+	 * - we hold the page_table_lock over the critical section
 	 */
+	address += 4 + PAGE_SIZE - 1;
 	address &= PAGE_MASK;
  	spin_lock(&vma->vm_mm->page_table_lock);
-	grow = (vma->vm_start - address) >> PAGE_SHIFT;
+	grow = (address - vma->vm_end) >> PAGE_SHIFT;

 	/* Overcommit.. */
-	if(!vm_enough_memory(grow)) {
+	if (!vm_enough_memory(grow)) {
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		return -ENOMEM;
 	}

-	if (vma->vm_end - address > current->rlim[RLIMIT_STACK].rlim_cur ||
+	if (address - vma->vm_start > current->rlim[RLIMIT_STACK].rlim_cur ||
 			((vma->vm_mm->total_vm + grow) << PAGE_SHIFT) >
 			current->rlim[RLIMIT_AS].rlim_cur) {
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		vm_unacct_memory(grow);
 		return -ENOMEM;
 	}
-	vma->vm_start = address;
-	vma->vm_pgoff -= grow;
+	vma->vm_end = address;
 	vma->vm_mm->total_vm += grow;
 	if (vma->vm_flags & VM_LOCKED)
 		vma->vm_mm->locked_vm += grow;
@@ -794,7 +801,6 @@
 	return 0;
 }

-#ifdef ARCH_STACK_GROWSUP
 struct vm_area_struct * find_extend_vma(struct mm_struct * mm, unsigned long addr)
 {
 	struct vm_area_struct *vma, *prev;
@@ -811,6 +817,46 @@
 	return prev;
 }
 #else
+/*
+ * vma is the first one with address < vma->vm_start.  Have to extend vma.
+ */
+int expand_stack(struct vm_area_struct * vma, unsigned long address)
+{
+	unsigned long grow;
+
+	/*
+	 * Subtle: in order to modify the vma list we would need to hold
+	 * the mmap_sem in write mode, however the page fault path holds
+	 * the mmap_sem only in read mode.  This works out ok because:
+	 * - we only change the size of this VMA and don't modify the VMA list
+	 * - we hold the page_table_lock over the critical section
+	 */
+	address &= PAGE_MASK;
+ 	spin_lock(&vma->vm_mm->page_table_lock);
+	grow = (vma->vm_start - address) >> PAGE_SHIFT;
+
+	/* Overcommit.. */
+	if (!vm_enough_memory(grow)) {
+		spin_unlock(&vma->vm_mm->page_table_lock);
+		return -ENOMEM;
+	}
+
+	if (vma->vm_end - address > current->rlim[RLIMIT_STACK].rlim_cur ||
+			((vma->vm_mm->total_vm + grow) << PAGE_SHIFT) >
+			current->rlim[RLIMIT_AS].rlim_cur) {
+		spin_unlock(&vma->vm_mm->page_table_lock);
+		vm_unacct_memory(grow);
+		return -ENOMEM;
+	}
+	vma->vm_start = address;
+	vma->vm_pgoff -= grow;
+	vma->vm_mm->total_vm += grow;
+	if (vma->vm_flags & VM_LOCKED)
+		vma->vm_mm->locked_vm += grow;
+	spin_unlock(&vma->vm_mm->page_table_lock);
+	return 0;
+}
+
 struct vm_area_struct * find_extend_vma(struct mm_struct * mm, unsigned long addr)
 {
 	struct vm_area_struct * vma;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
