Date: Tue, 19 Oct 1999 16:16:55 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: [PATCH]: oom and cleaner error handling in *_nopage
Message-ID: <Pine.BSO.4.10.9910191607470.6236-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi linus-

this patch, against 2.3.21, includes all the minor oom/error-handling
corrections that andrea and i discussed with you in august.  i submit this
for inclusion in 2.3.

also, would you like me to finish up and submit my madvise() patch for
2.3/2.4?  i set it aside when you announced the feature freeze, but there
seems to be a lot of discussion about madvise() lately.  i could also take
a crack at vivek pai's suggestion for mincore().

diff -ruN linux-2.3.21-ref/drivers/sgi/char/graphics.c linux/drivers/sgi/char/graphics.c
--- linux-2.3.21-ref/drivers/sgi/char/graphics.c	Mon Oct 11 23:02:37 1999
+++ linux/drivers/sgi/char/graphics.c	Tue Oct 19 15:23:00 1999
@@ -238,7 +238,9 @@
 
 	virt_add = address & PAGE_MASK;
 	phys_add = cards[board].g_regs + virt_add - vma->vm_start;
-	remap_page_range(virt_add, phys_add, PAGE_SIZE, vma->vm_page_prot);
+	if (remap_page_range(virt_add, phys_add, PAGE_SIZE,
+						vma->vm_page_prot) < 0)
+		return -1;
 
 	pgd = pgd_offset(current->mm, address);
 	pmd = pmd_offset(pgd, address);
diff -ruN linux-2.3.21-ref/fs/fat/mmap.c linux/fs/fat/mmap.c
--- linux-2.3.21-ref/fs/fat/mmap.c	Fri Jul  2 18:15:51 1999
+++ linux/fs/fat/mmap.c	Tue Oct 19 15:19:51 1999
@@ -30,7 +30,7 @@
 static unsigned long fat_file_mmap_nopage(
 	struct vm_area_struct * area,
 	unsigned long address,
-	int error_code)
+	int no_share)
 {
 	struct inode * inode = area->vm_file->f_dentry->d_inode;
 	unsigned long page;
@@ -40,7 +40,7 @@
 
 	page = __get_free_page(GFP_KERNEL);
 	if (!page)
-		return page;
+		return -1;
 	address &= PAGE_MASK;
 	pos = address - area->vm_start + area->vm_offset;
 
diff -ruN linux-2.3.21-ref/fs/ncpfs/mmap.c linux/fs/ncpfs/mmap.c
--- linux-2.3.21-ref/fs/ncpfs/mmap.c	Fri Jul  2 18:15:51 1999
+++ linux/fs/ncpfs/mmap.c	Tue Oct 19 15:20:26 1999
@@ -44,7 +44,7 @@
 
 	page = __get_free_page(GFP_KERNEL);
 	if (!page)
-		return page;
+		return -1;
 	address &= PAGE_MASK;
 	pos = address - area->vm_start + area->vm_offset;
 
diff -ruN linux-2.3.21-ref/mm/filemap.c linux/mm/filemap.c
--- linux-2.3.21-ref/mm/filemap.c	Mon Oct 11 23:03:44 1999
+++ linux/mm/filemap.c	Tue Oct 19 15:15:11 1999
@@ -530,7 +530,7 @@
  * This adds the requested page to the page cache if it isn't already there,
  * and schedules an I/O to read in its contents from disk.
  */
-static inline void page_cache_read(struct file * file, unsigned long offset) 
+static inline int page_cache_read(struct file * file, unsigned long offset) 
 {
 	unsigned long new_page;
 	struct inode *inode = file->f_dentry->d_inode;
@@ -541,17 +541,17 @@
 	page = __find_page_nolock(inode, offset, *hash); 
 	spin_unlock(&pagecache_lock);
 	if (page)
-		return;
+		return 0;
 
 	new_page = page_cache_alloc();
 	if (!new_page)
-		return;
+		return -ENOMEM;
 	page = page_cache_entry(new_page);
 
 	if (!add_to_page_cache_unique(page, inode, offset, hash)) {
-		inode->i_op->readpage(file, page);
+		int error = inode->i_op->readpage(file, page);
 		page_cache_release(page);
-		return;
+		return error;
 	}
 
 	/*
@@ -559,26 +559,30 @@
 	 * raced with us and added our page to the cache first.
 	 */
 	page_cache_free(new_page);
-	return;
+	return 0;
 }
 
 /*
  * Read in an entire cluster at once.  A cluster is usually a 64k-
  * aligned block that includes the address requested in "offset."
  */
-static void read_cluster_nonblocking(struct file * file,
+static int read_cluster_nonblocking(struct file * file,
 	unsigned long offset)
 {
+	int error = 0;
 	off_t filesize = file->f_dentry->d_inode->i_size;
 	unsigned long pages = CLUSTER_PAGES;
 
 	offset = CLUSTER_OFFSET(offset);
 	while ((pages-- > 0) && (offset < filesize)) {
-		page_cache_read(file, offset);
-		offset += PAGE_CACHE_SIZE;
+		error = page_cache_read(file, offset);
+		if (!error)
+			offset += PAGE_CACHE_SIZE;
+		else
+			break;
 	}
 
-	return;
+	return error;
 }
 
 /* 
@@ -914,7 +918,8 @@
 		ahead += PAGE_CACHE_SIZE;
 		if ((raend + ahead) >= inode->i_size)
 			break;
-		page_cache_read(filp, raend + ahead);
+		if (page_cache_read(filp, raend + ahead))
+			break;
 	}
 /*
  * If we tried to read ahead some pages,
@@ -1294,13 +1299,11 @@
  * The goto's are kind of ugly, but this streamlines the normal case of having
  * it in the page cache, and handles the special cases reasonably without
  * having a lot of duplicated code.
- *
- * XXX - at some point, this should return unique values to indicate to
- *       the caller whether this is EIO, OOM, or SIGBUS.
  */
 static unsigned long filemap_nopage(struct vm_area_struct * area,
 	unsigned long address, int no_share)
 {
+	int error;
 	struct file * file = area->vm_file;
 	struct dentry * dentry = file->f_dentry;
 	struct inode * inode = dentry->d_inode;
@@ -1347,7 +1350,8 @@
 		if (new_page) {
 			copy_page(new_page, old_page);
 			flush_page_to_ram(new_page);
-		}
+		} else
+			new_page = -1;	/* signal OOM */
 		page_cache_release(page);
 		return new_page;
 	}
@@ -1364,16 +1368,26 @@
 	 * so we need to map a zero page.
 	 */
 	if (offset < inode->i_size)
-		read_cluster_nonblocking(file, offset);
+		error = read_cluster_nonblocking(file, offset);
 	else
-		page_cache_read(file, offset);
+		error = page_cache_read(file, offset);
 
 	/*
 	 * The page we want has now been added to the page cache.
 	 * In the unlikely event that someone removed it in the
 	 * meantime, we'll just come back here and read it again.
 	 */
-	goto retry_find;
+	if (!error)
+		goto retry_find;
+
+	/*
+	 * An error return from page_cache_read can result if the
+	 * system is low on memory, or a problem occurs while trying
+	 * to schedule I/O.
+	 */
+	if (error == -ENOMEM)
+		return -1;
+	return 0;
 
 page_not_uptodate:
 	lock_page(page);
diff -ruN linux-2.3.21-ref/mm/memory.c linux/mm/memory.c
--- linux-2.3.21-ref/mm/memory.c	Mon Oct 11 23:02:44 1999
+++ linux/mm/memory.c	Tue Oct 19 15:05:17 1999
@@ -1060,7 +1060,7 @@
 	 */
 	page = vma->vm_ops->nopage(vma, address & PAGE_MASK, (vma->vm_flags & VM_SHARED)?0:write_access);
 	if (!page)
-		return 0;	/* SIGBUS - but we _really_ should know whether it is OOM or SIGBUS */
+		return 0;	/* SIGBUS */
 	if (page == -1)
 		return -1;	/* OOM */
 
	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
