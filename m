Subject: [patch 1/3] split mmap
Message-Id: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sat, 24 Mar 2007 23:07:07 +0100
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a straightforward split of do_mmap_pgoff() into two functions:

 - do_mmap_pgoff() checks the parameters, and calculates the vma
   flags.  Then it calls

 - mmap_region(), which does the actual mapping

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2007-03-24 21:00:40.000000000 +0100
+++ linux/mm/mmap.c	2007-03-24 22:28:52.000000000 +0100
@@ -893,14 +893,11 @@ unsigned long do_mmap_pgoff(struct file 
 			unsigned long flags, unsigned long pgoff)
 {
 	struct mm_struct * mm = current->mm;
-	struct vm_area_struct * vma, * prev;
 	struct inode *inode;
 	unsigned int vm_flags;
-	int correct_wcount = 0;
 	int error;
-	struct rb_node ** rb_link, * rb_parent;
 	int accountable = 1;
-	unsigned long charged = 0, reqprot = prot;
+	unsigned long reqprot = prot;
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1025,7 +1022,25 @@ unsigned long do_mmap_pgoff(struct file 
 	error = security_file_mmap(file, reqprot, prot, flags);
 	if (error)
 		return error;
-		
+
+	return mmap_region(file, addr, len, flags, vm_flags, pgoff,
+			   accountable);
+}
+EXPORT_SYMBOL(do_mmap_pgoff);
+
+unsigned long mmap_region(struct file *file, unsigned long addr,
+			  unsigned long len, unsigned long flags,
+			  unsigned int vm_flags, unsigned long pgoff,
+			  int accountable)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma, *prev;
+	int correct_wcount = 0;
+	int error;
+	struct rb_node **rb_link, *rb_parent;
+	unsigned long charged = 0;
+	struct inode *inode =  file ? file->f_path.dentry->d_inode : NULL;
+
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
@@ -1174,8 +1189,6 @@ unacct_error:
 	return error;
 }
 
-EXPORT_SYMBOL(do_mmap_pgoff);
-
 /* Get an address range which is currently unmapped.
  * For shmat() with addr=0.
  *
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2007-03-24 21:00:40.000000000 +0100
+++ linux/include/linux/mm.h	2007-03-24 22:28:52.000000000 +0100
@@ -1035,6 +1035,10 @@ extern unsigned long get_unmapped_area(s
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long pgoff);
+extern unsigned long mmap_region(struct file *file, unsigned long addr,
+	unsigned long len, unsigned long flags,
+	unsigned int vm_flags, unsigned long pgoff,
+	int accountable);
 
 static inline unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
