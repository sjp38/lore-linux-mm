Date: Sun, 12 Mar 2000 19:45:53 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: [PATCH] mincore for i386, against 2.3.51
Message-ID: <Pine.BSO.4.10.10003121941460.5358-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi linus-

here's mincore for i386.  this is simpler than madvise, so we should be
able to detect my misunderstandings a little easier before i go on with
madvise.

diff -ruN Linux-2.3.51/arch/i386/kernel/entry.S linux/arch/i386/kernel/entry.S
--- Linux-2.3.51/arch/i386/kernel/entry.S	Sun Mar 12 18:42:20 2000
+++ linux/arch/i386/kernel/entry.S	Sun Mar 12 18:47:04 2000
@@ -638,6 +638,7 @@
 	.long SYMBOL_NAME(sys_setfsuid)		/* 215 */
 	.long SYMBOL_NAME(sys_setfsgid)
 	.long SYMBOL_NAME(sys_pivot_root)
+	.long SYMBOL_NAME(sys_mincore)
 
 
 	/*
@@ -646,6 +647,6 @@
 	 * entries. Don't panic if you notice that this hasn't
 	 * been shrunk every time we add a new system call.
 	 */
-	.rept NR_syscalls-217
+	.rept NR_syscalls-218
 		.long SYMBOL_NAME(sys_ni_syscall)
 	.endr
diff -ruN Linux-2.3.51/include/asm-i386/unistd.h linux/include/asm-i386/unistd.h
--- Linux-2.3.51/include/asm-i386/unistd.h	Wed Jan 26 15:32:02 2000
+++ linux/include/asm-i386/unistd.h	Sun Mar 12 18:50:55 2000
@@ -222,6 +222,7 @@
 #define __NR_setfsuid32		215
 #define __NR_setfsgid32		216
 #define __NR_pivot_root		217
+#define __NR_mincore		218
 
 /* user-visible error numbers are in the range -1 - -124: see <asm-i386/errno.h> */
 
diff -ruN Linux-2.3.51/include/linux/mm.h linux/include/linux/mm.h
--- Linux-2.3.51/include/linux/mm.h	Sun Mar 12 18:42:36 2000
+++ linux/include/linux/mm.h	Sun Mar 12 19:17:15 2000
@@ -105,6 +105,7 @@
 	void (*unmap)(struct vm_area_struct *area, unsigned long, size_t);
 	void (*protect)(struct vm_area_struct *area, unsigned long, size_t, unsigned int newprot);
 	int (*sync)(struct vm_area_struct *area, unsigned long, size_t, unsigned int flags);
+	unsigned char (*incore)(struct vm_area_struct *area, unsigned long);
 	void (*advise)(struct vm_area_struct *area, unsigned long, size_t, unsigned int advise);
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int write_access);
 	struct page * (*wppage)(struct vm_area_struct * area, unsigned long address, struct page * page);
@@ -446,6 +447,8 @@
 			size_t size, unsigned int flags);
 extern struct page *filemap_nopage(struct vm_area_struct * area,
 				    unsigned long address, int no_share);
+extern unsigned char filemap_incore(struct vm_area_struct * vma,
+	unsigned long pgoff);
 
 /*
  * GFP bitmasks..
diff -ruN Linux-2.3.51/ipc/shm.c linux/ipc/shm.c
--- Linux-2.3.51/ipc/shm.c	Sun Mar 12 18:42:48 2000
+++ linux/ipc/shm.c	Sun Mar 12 19:35:23 2000
@@ -115,6 +115,7 @@
 static void killseg_core(struct shmid_kernel *shp, int doacc);
 static void shm_open (struct vm_area_struct *shmd);
 static void shm_close (struct vm_area_struct *shmd);
+static unsigned char shm_incore (struct vm_area_struct *shmd, unsigned long idx);
 static struct page * shm_nopage(struct vm_area_struct *, unsigned long, int);
 static int shm_swapout(struct page *, struct file *);
 #ifdef CONFIG_PROC_FS
@@ -166,6 +167,7 @@
 static struct vm_operations_struct shm_vm_ops = {
 	open:	shm_open,	/* callback for a new vm-area open */
 	close:	shm_close,	/* callback for when the vm-area is released */
+	incore:	shm_incore,
 	nopage:	shm_nopage,
 	swapout:shm_swapout,
 };
@@ -1197,6 +1199,38 @@
 static int shm_swapout(struct page * page, struct file *file)
 {
 	return 0;
+}
+
+/*
+ * is page in memory?
+ *
+ * shm has a special incore method because we need to synchronize
+ * with the shm swapper (shm_swap) while finding the page.
+ */
+static unsigned char shm_incore(struct vm_area_struct * shmd,
+	unsigned long idx)
+{
+	unsigned char present = 0;
+	pte_t pte;
+	struct shmid_kernel * shp;
+	struct inode * inode = shmd->vm_file->f_dentry->d_inode;
+
+	down(&inode->i_sem);
+	if(!(shp = shm_lock(inode->i_ino)))
+		BUG();
+
+	/*
+	 * the pte isn't present if the page is swapped, or if it hasn't
+	 * been touched yet.  Otherwise, we say the page is available.
+	 */
+	pte = SHM_ENTRY(shp, (unsigned int)idx);
+	if (pte_present(pte))
+		present = 1;
+
+	shm_unlock(inode->i_ino);
+	up(&inode->i_sem);
+
+	return present;
 }
 
 /*
diff -ruN Linux-2.3.51/mm/filemap.c linux/mm/filemap.c
--- Linux-2.3.51/mm/filemap.c	Sun Mar 12 18:42:48 2000
+++ linux/mm/filemap.c	Sun Mar 12 19:00:48 2000
@@ -1294,6 +1294,28 @@
 }
 
 /*
+ * Later we can get more picky about what "in core" means precisely
+ * for a filemapped page.  For now, simply check to see if the page
+ * is in the page cache, and is up to date; i.e. that no page-in
+ * operation would be required at this time if an application were
+ * to map and access this page.
+ */
+unsigned char filemap_incore(struct vm_area_struct * vma, unsigned long pgoff)
+{
+	unsigned char present = 0;
+	struct address_space * as = &vma->vm_file->f_dentry->d_inode->i_data;
+	struct page * page, ** hash = page_hash(as, pgoff);
+
+	spin_lock(&pagecache_lock);
+	page = __find_page_nolock(as, pgoff, *hash);
+	if ((page) && (Page_Uptodate(page)))
+		present = 1;
+	spin_unlock(&pagecache_lock);
+
+	return present;
+}
+
+/*
  * filemap_nopage() is invoked via the vma operations vector for a
  * mapped memory region to read in file data during a page fault.
  *
@@ -1610,6 +1632,7 @@
 static struct vm_operations_struct file_shared_mmap = {
 	unmap:		filemap_unmap,		/* unmap - we need to sync the pages */
 	sync:		filemap_sync,
+	incore:		filemap_incore,
 	nopage:		filemap_nopage,
 	swapout:	filemap_swapout,
 };
@@ -1621,6 +1644,7 @@
  * know they can't ever get write permissions..)
  */
 static struct vm_operations_struct file_private_mmap = {
+	incore:		filemap_incore,
 	nopage:		filemap_nopage,
 };
 
diff -ruN Linux-2.3.51/mm/mmap.c linux/mm/mmap.c
--- Linux-2.3.51/mm/mmap.c	Sun Mar 12 18:42:48 2000
+++ linux/mm/mmap.c	Sun Mar 12 19:06:22 2000
@@ -731,6 +731,140 @@
 	return ret;
 }
 
+static long mincore_area(struct vm_area_struct * vma,
+	unsigned long start, unsigned long end, unsigned char * vec)
+{
+	long error, i, remaining;
+	unsigned char * tmp;
+	unsigned char (*incore)(struct vm_area_struct * , unsigned long);
+
+	error = -ENOMEM;
+	if (!vma->vm_ops || !vma->vm_ops->incore)
+		return error;
+	incore = vma->vm_ops->incore;
+
+	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	if (end > vma->vm_end)
+		end = vma->vm_end;
+	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
+	error = -EAGAIN;
+	tmp = (unsigned char *) __get_free_page(GFP_KERNEL);
+	if (!tmp)
+		return error;
+
+	/* (end - start) is # of pages, and also # of bytes in "vec */
+	remaining = (end - start),
+
+	error = 0;
+	for (i = 0; remaining > 0; remaining -= PAGE_SIZE, i++) {
+		int j = 0;
+		long thispiece = (remaining < PAGE_SIZE) ?
+						remaining : PAGE_SIZE;
+
+		while (j < thispiece)
+			tmp[j++] = incore(vma, start++);
+
+		if (copy_to_user(vec + PAGE_SIZE * i, tmp, thispiece)) {
+			error = -EFAULT;
+			break;
+		}
+	}
+
+	free_page((unsigned long) tmp);
+	return error;
+}
+
+/*
+ * The mincore(2) system call.
+ *
+ * mincore() returns the memory residency status of the pages in the
+ * current process's address space specified by [addr, addr + len).
+ * The status is returned in a vector of bytes.  The least significant
+ * bit of each byte is 1 if the referenced page is in memory, otherwise
+ * it is zero.
+ *
+ * Because the status of a page can change after mincore() checks it
+ * but before it returns to the application, the returned vector may
+ * contain stale information.  Only locked pages are guaranteed to
+ * remain in memory.
+ *
+ * return values:
+ *  zero    - success
+ *  -EFAULT - vec points to an illegal address
+ *  -EINVAL - addr is not a multiple of PAGE_CACHE_SIZE,
+ *		or len has a nonpositive value
+ *  -ENOMEM - Addresses in the range [addr, addr + len] are
+ *		invalid for the address space of this process, or
+ *		specify one or more pages which are not currently
+ *		mapped
+ *  -EAGAIN - A kernel resource was temporarily unavailable.
+ */
+asmlinkage long sys_mincore(unsigned long start, size_t len,
+	unsigned char * vec)
+{
+	int index = 0;
+	unsigned long end;
+	struct vm_area_struct * vma;
+	int unmapped_error = 0;
+	long error = -EINVAL;
+
+	down(&current->mm->mmap_sem);
+
+	if (start & ~PAGE_MASK)
+		goto out;
+	len = (len + ~PAGE_MASK) & PAGE_MASK;
+	end = start + len;
+	if (end < start)
+		goto out;
+
+	error = 0;
+	if (end == start)
+		goto out;
+
+	/*
+	 * If the interval [start,end) covers some unmapped address
+	 * ranges, just ignore them, but return -ENOMEM at the end.
+	 */
+	vma = find_vma(current->mm, start);
+	for (;;) {
+		/* Still start < end. */
+		error = -ENOMEM;
+		if (!vma)
+			goto out;
+
+		/* Here start < vma->vm_end. */
+		if (start < vma->vm_start) {
+			unmapped_error = -ENOMEM;
+			start = vma->vm_start;
+		}
+
+		/* Here vma->vm_start <= start < vma->vm_end. */
+		if (end <= vma->vm_end) {
+			if (start < end) {
+				error = mincore_area(vma, start, end,
+							&vec[index]);
+				if (error)
+					goto out;
+			}
+			error = unmapped_error;
+			goto out;
+		}
+
+		/* Here vma->vm_start <= start < vma->vm_end < end. */
+		error = mincore_area(vma, start, vma->vm_end, &vec[index]);
+		if (error)
+			goto out;
+		index += (vma->vm_end - start) >> PAGE_CACHE_SHIFT;
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	}
+
+out:
+	up(&current->mm->mmap_sem);
+	return error;
+}
+
 /*
  *  this is really a simplified "do_mmap".  it only handles
  *  anonymous maps.  eventually we may be able to do some

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
