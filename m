From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910191759.KAA93685@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm18-2.3.22 incremental swapout() interface cleanup
Date: Tue, 19 Oct 1999 10:59:41 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

Here is an incremental patch against the previous kanoj-mm17-2.3.21
kswapd vma scanning protection patch. This one cleans up the swapout()
interface per our discussions. Let me know if this looks okay, or you
want me rework the patch.

Thanks.

Kanoj

--- Documentation/vm/locking	Mon Oct 18 16:16:50 1999
+++ Documentation/vm/locking	Tue Oct 19 09:43:50 1999
@@ -14,13 +14,12 @@
 The vma list of the victim mm is also scanned by the stealer, 
 and the vmlist_lock is used to preserve list sanity against the
 process adding/deleting to the list. This also gurantees existance
-of the vma. Vma existance gurantee while invoking the driver
-swapout() method in try_to_swap_out() also relies on the fact
-that do_munmap() temporarily gets lock_kernel before decimating
-the vma, thus the swapout() method must snapshot all the vma 
-fields it needs before going to sleep (which will release the
-lock_kernel held by the page stealer). Currently, filemap_swapout
-is the only method that depends on this shaky interlocking.
+of the vma. Vma existance is not guranteed once try_to_swap_out() 
+drops the vmlist lock. To gurantee the existance of the underlying 
+file structure, a get_file is done before the swapout() method is 
+invoked. The page passed into swapout() is guaranteed not to be reused
+for a different purpose because the page reference count due to being
+present in the user's pte is not released till after swapout() returns.
 
 Any code that modifies the vmlist, or the vm_start/vm_end/
 vm_flags:VM_LOCKED/vm_next of any vma *in the list* must prevent 
--- include/linux/mm.h	Mon Oct 18 14:36:57 1999
+++ include/linux/mm.h	Mon Oct 18 16:03:32 1999
@@ -106,7 +106,7 @@
 	unsigned long (*nopage)(struct vm_area_struct * area, unsigned long address, int write_access);
 	unsigned long (*wppage)(struct vm_area_struct * area, unsigned long address,
 		unsigned long page);
-	int (*swapout)(struct vm_area_struct *, struct page *);
+	int (*swapout)(struct page *, struct file *);
 };
 
 /*
--- ipc/shm.c	Mon Oct 18 14:37:59 1999
+++ ipc/shm.c	Mon Oct 18 16:03:57 1999
@@ -33,7 +33,7 @@
 static void shm_open (struct vm_area_struct *shmd);
 static void shm_close (struct vm_area_struct *shmd);
 static unsigned long shm_nopage(struct vm_area_struct *, unsigned long, int);
-static int shm_swapout(struct vm_area_struct *, struct page *);
+static int shm_swapout(struct page *, struct file *);
 #ifdef CONFIG_PROC_FS
 static int sysvipc_shm_read_proc(char *buffer, char **start, off_t offset, int length, int *eof, void *data);
 #endif
@@ -660,7 +660,7 @@
  * data structures already, and shm_swap_out() will just
  * work off them..
  */
-static int shm_swapout(struct vm_area_struct * vma, struct page * page)
+static int shm_swapout(struct page * page, struct file *file)
 {
 	return 0;
 }
--- /usr/tmp/p_rdiff_a0057a/filemap.c	Mon Oct 18 17:39:10 1999
+++ mm/filemap.c	Mon Oct 18 16:24:15 1999
@@ -1447,27 +1447,25 @@
 	return retval;
 }
 
-static int filemap_write_page(struct vm_area_struct * vma,
+static int filemap_write_page(struct file *file,
 			      unsigned long offset,
 			      unsigned long page,
 			      int wait)
 {
 	int result;
-	struct file * file;
 	struct dentry * dentry;
 	struct inode * inode;
 
-	file = vma->vm_file;
 	dentry = file->f_dentry;
 	inode = dentry->d_inode;
 
 	/*
 	 * If a task terminates while we're swapping the page, the vma and
-	 * and file could be released ... increment the count to be safe.
+	 * and file could be released ... try_to_swap_out has done a get_file.
+	 * vma/file is guaranteed to exist in the unmap/sync cases because 
+	 * mmap_sem is held.
 	 */
-	get_file(file);
 	result = do_write_page(inode, file, (const char *) page, offset);
-	fput(file);
 	return result;
 }
 
@@ -1478,9 +1476,9 @@
  * at the same time..
  */
 extern void wakeup_bdflush(int);
-int filemap_swapout(struct vm_area_struct * vma, struct page * page)
+int filemap_swapout(struct page * page, struct file *file)
 {
-	int retval = filemap_write_page(vma, page->offset, page_address(page), 0);
+	int retval = filemap_write_page(file, page->offset, page_address(page), 0);
 	wakeup_bdflush(0);
 	return retval;
 }
@@ -1521,7 +1519,7 @@
 			return 0;
 		}
 	}
-	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, pageaddr, 1);
+	error = filemap_write_page(vma->vm_file, address - vma->vm_start + vma->vm_offset, pageaddr, 1);
 	page_cache_free(pageaddr);
 	return error;
 }
--- mm/vmscan.c	Mon Oct 18 12:43:48 1999
+++ mm/vmscan.c	Mon Oct 18 16:28:15 1999
@@ -18,6 +18,7 @@
 #include <linux/pagemap.h>
 #include <linux/init.h>
 #include <linux/bigmem.h>
+#include <linux/file.h>
 
 #include <asm/pgtable.h>
 
@@ -38,6 +39,7 @@
 	unsigned long entry;
 	unsigned long page_addr;
 	struct page * page;
+	int (*swapout)(struct page *, struct file *);
 
 	pte = *page_table;
 	if (!pte_present(pte))
@@ -130,13 +132,16 @@
 	 * That would get rid of a lot of problems.
 	 */
 	flush_cache_page(vma, address);
-	if (vma->vm_ops && vma->vm_ops->swapout) {
+	if (vma->vm_ops && (swapout = vma->vm_ops->swapout)) {
 		int error;
+		struct file *file = vma->vm_file;
+		if (file) get_file(file);
 		pte_clear(page_table);
 		vma->vm_mm->rss--;
 		flush_tlb_page(vma, address);
 		vmlist_access_unlock(vma->vm_mm);
-		error = vma->vm_ops->swapout(vma, page);
+		error = swapout(page, file);
+		if (file) fput(file);
 		if (!error)
 			goto out_free_success;
 		__free_page(page);
--- mm/mmap.c	Mon Oct 18 17:09:51 1999
+++ mm/mmap.c	Mon Oct 18 17:10:05 1999
@@ -687,11 +687,6 @@
 		end = end > mpnt->vm_end ? mpnt->vm_end : end;
 		size = end - st;
 
-		/*
-		 * The lock_kernel interlocks with kswapd try_to_swap_out
-		 * invoking a driver swapout() method, and being able to
-		 * guarantee vma existance.
-		 */
 		lock_kernel();
 		if (mpnt->vm_ops && mpnt->vm_ops->unmap)
 			mpnt->vm_ops->unmap(mpnt, st, size);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
