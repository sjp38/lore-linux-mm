Date: Mon, 12 Mar 2001 17:50:42 +0000
From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] Shared mmap [Take 3]
Message-ID: <20010312175042.B19848@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, parisc-linux@parisc-linux.org
List-ID: <linux-mm.kvack.org>

This patch changes shared mmaps of files to always be aligned at the
same offset within the processor's d-cache.  This fixes PA-RISC & MIPS.
Sparc & IA-64 need some of their support changing, but I don't want to
do that until everyone's had the chance to disagree with my changes :-)

Index: fs/inode.c
===================================================================
RCS file: /var/cvs/linux/fs/inode.c,v
retrieving revision 1.1.1.3
diff -u -p -r1.1.1.3 inode.c
--- fs/inode.c	2001/01/01 10:32:52	1.1.1.3
+++ fs/inode.c	2001/03/12 13:23:04
@@ -608,6 +608,7 @@ static void clean_inode(struct inode *in
 	inode->i_data.a_ops = &empty_aops;
 	inode->i_data.host = inode;
 	inode->i_mapping = &inode->i_data;
+	inode->i_mmap_offset = -1;
 }
 
 /**
Index: include/linux/fs.h
===================================================================
RCS file: /var/cvs/linux/include/linux/fs.h,v
retrieving revision 1.1.1.4
diff -u -p -r1.1.1.4 fs.h
--- include/linux/fs.h	2001/01/01 10:33:09	1.1.1.4
+++ include/linux/fs.h	2001/03/12 13:56:10
@@ -424,6 +424,7 @@ struct inode {
 
 	unsigned long		i_state;
 
+	unsigned int		i_mmap_offset; /* Handle L1 d-cache aliasing */
 	unsigned int		i_flags;
 	unsigned char		i_sock;
 
Index: include/linux/mm.h
===================================================================
RCS file: /var/cvs/linux/include/linux/mm.h,v
retrieving revision 1.1.1.4
diff -u -p -r1.1.1.4 mm.h
--- include/linux/mm.h	2001/01/01 10:33:09	1.1.1.4
+++ include/linux/mm.h	2001/03/12 13:56:10
@@ -419,6 +419,7 @@ extern void insert_vm_struct(struct mm_s
 extern void __insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void build_mmap_avl(struct mm_struct *);
 extern void exit_mmap(struct mm_struct *);
+extern unsigned long get_shared_area(unsigned long, unsigned long, unsigned int);
 extern unsigned long get_unmapped_area(unsigned long, unsigned long);
 
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
Index: mm/mmap.c
===================================================================
RCS file: /var/cvs/linux/mm/mmap.c,v
retrieving revision 1.1.1.4
diff -u -p -r1.1.1.4 mmap.c
--- mm/mmap.c	2001/01/01 10:33:08	1.1.1.4
+++ mm/mmap.c	2001/03/12 16:47:25
@@ -190,6 +190,7 @@ unsigned long do_mmap_pgoff(struct file 
 {
 	struct mm_struct * mm = current->mm;
 	struct vm_area_struct * vma;
+	struct inode *inode = NULL;
 	int correct_wcount = 0;
 	int error;
 
@@ -223,17 +224,18 @@ unsigned long do_mmap_pgoff(struct file 
 	 * of the memory object, so we don't do any here.
 	 */
 	if (file != NULL) {
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
 
 			/* fall through */
@@ -253,6 +255,15 @@ unsigned long do_mmap_pgoff(struct file 
 	if (flags & MAP_FIXED) {
 		if (addr & ~PAGE_MASK)
 			return -EINVAL;
+	} else if (inode && (flags & MAP_SHARED)) {
+		if (inode->i_mmap_offset != -1) {
+			addr = get_shared_area(addr, len, inode->i_mmap_offset);
+		} else {
+			addr = get_unmapped_area(addr, len);
+		}
+		if (!addr)
+			return -ENOMEM;
+		inode->i_mmap_offset = addr & (SHMLBA - 1);
 	} else {
 		addr = get_unmapped_area(addr, len);
 		if (!addr)
@@ -348,7 +359,7 @@ unsigned long do_mmap_pgoff(struct file 
 
 	insert_vm_struct(mm, vma);
 	if (correct_wcount)
-		atomic_inc(&file->f_dentry->d_inode->i_writecount);
+		atomic_inc(&inode->i_writecount);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -359,7 +370,7 @@ unsigned long do_mmap_pgoff(struct file 
 
 unmap_and_free_vma:
 	if (correct_wcount)
-		atomic_inc(&file->f_dentry->d_inode->i_writecount);
+		atomic_inc(&inode->i_writecount);
 	vma->vm_file = NULL;
 	fput(file);
 	/* Undo any partial mapping done by a device driver. */
@@ -376,6 +387,29 @@ free_vma:
  * Return value 0 means ENOMEM.
  */
 #ifndef HAVE_ARCH_UNMAPPED_AREA
+
+#define DCACHE_ALIGN(addr) ((addr) &~ (SHMLBA - 1))
+
+unsigned long get_shared_area(unsigned long addr, unsigned long len, unsigned int offset)
+{
+	struct vm_area_struct *vmm;
+
+	if (len > TASK_SIZE)
+		return 0;
+	if (!addr)
+		addr = TASK_UNMAPPED_BASE;
+	addr = DCACHE_ALIGN(addr - offset) + offset;
+
+	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+		/* At this point:  (!vmm || addr < vmm->vm_end). */
+		if (TASK_SIZE - len < addr)
+			return 0;
+		if (!vmm || addr + len <= vmm->vm_start)
+			return addr;
+		addr = DCACHE_ALIGN(vmm->vm_end - offset) + offset;
+	}
+}
+
 unsigned long get_unmapped_area(unsigned long addr, unsigned long len)
 {
 	struct vm_area_struct * vmm;
Index: mm/mremap.c
===================================================================
RCS file: /var/cvs/linux/mm/mremap.c,v
retrieving revision 1.1.1.4
diff -u -p -r1.1.1.4 mremap.c
--- mm/mremap.c	2001/01/01 10:33:09	1.1.1.4
+++ mm/mremap.c	2001/03/11 23:48:55
@@ -276,7 +276,11 @@ unsigned long do_mremap(unsigned long ad
 	ret = -ENOMEM;
 	if (flags & MREMAP_MAYMOVE) {
 		if (!(flags & MREMAP_FIXED)) {
-			new_addr = get_unmapped_area(0, new_len);
+			if (vma->vm_file && (vma->vm_flags & VM_SHARED)) {
+				new_addr = get_shared_area(0, new_len, vma->vm_file->f_dentry->d_inode->i_mmap_offset);
+			} else {
+				new_addr = get_unmapped_area(0, new_len);
+			}
 			if (!new_addr)
 				goto out;
 		}

----- End forwarded message -----

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
