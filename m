Date: Thu, 2 Nov 2000 13:49:22 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: PATCH [2.4.0test10]: Kiobuf#03, add unmap/dirty-page map-specific kiobuf functions
Message-ID: <20001102134922.C1876@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="L2Brqb15TUChFOBK"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--L2Brqb15TUChFOBK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

OK, this is the bit which addresses the dirtying of pages mapped into
a kiobuf.

It adds mapping-specific info to the kiobuf, so that just as
map_user_kiobuf can add the file struct vector to allow any necessary
writepage after the IO completes, so can other mapping functions
specify their own operations on the mapped pages to deal with IO
completion.

The patch adds a "map_private" field in the kiobuf to be used by the
mapping function's callbacks, and a vector of callbacks currently
containing:

mark_dirty:
	marks all pages mapped in the kiobuf as dirty.  Used by the
	raw device code after read IOs complete to propagate the 
	dirty state into any mmaped files.

unmap:
	allows for cleanup of the map_private field when the kiobuf 
	is destroyed.

map_user_kiobuf does nothing special for kiobufs marked for write
(meaning IO writes, ie. reads from memory), but sets up map_private as
a vector of struct file *s for read IOs.  The mark_dirty callback
propagates that info into the page if page->mapping->a_ops->writepage
exists.

If the writepage does not exist, then it should simply do a
SetPageDirty on the page, but the VM cannot cope with this at present:
the swapout code does not yet handle flushing of dirty pages during
page eviction, and if a process with such a page mapped exits,
__free_pages_ok() will bugcheck on seeing the dirty bit.

Rik, you said you were going to look at deferred swapout using the
page dirty flag for anonymous pages --- do you want to take this up?

One other thing: at some point in the future I'd like to add a
"mark_dirty" a_ops callback to be used in preference of the writepage.
This would allow filesystems such as ext2, which don't require the
struct file * for page writes, to defer the write of these mmaped
pages until later rather than to force a flush to disk every time we
dirty a kiobuf-mapped mmaped page.

Cheers,
 Stephen

--L2Brqb15TUChFOBK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03-mapfunc.diff"

diff -ru linux-2.4.0-test10.kio.02/drivers/char/raw.c linux-2.4.0-test10.kio.03/drivers/char/raw.c
--- linux-2.4.0-test10.kio.02/drivers/char/raw.c	Thu Nov  2 12:00:35 2000
+++ linux-2.4.0-test10.kio.03/drivers/char/raw.c	Thu Nov  2 12:08:54 2000
@@ -326,6 +326,9 @@
 			size -= iobuf->retval;
 			buf += iobuf->retval;
 		}
+		
+		if (rw == READ) 
+			mark_dirty_kiovec(&iobuf, 1, iobuf->retval);
 
 		unmap_kiobuf(iobuf); /* The unlock_kiobuf is implicit here */
 
diff -ru linux-2.4.0-test10.kio.02/fs/iobuf.c linux-2.4.0-test10.kio.03/fs/iobuf.c
--- linux-2.4.0-test10.kio.02/fs/iobuf.c	Thu Nov  2 12:06:59 2000
+++ linux-2.4.0-test10.kio.03/fs/iobuf.c	Thu Nov  2 12:08:54 2000
@@ -128,6 +128,7 @@
 }
 
 
+
 /*
  * Unmap all of the pages referenced by a kiobuf.  We release the pages,
  * and unlock them if they were locked. 
@@ -137,6 +138,10 @@
 {
 	int i;
 	struct page *map;
+
+	if (iobuf->map_ops && iobuf->map_ops->unmap)
+		iobuf->map_ops->unmap(iobuf);
+	iobuf->map_ops = NULL;
 	
 	for (i = 0; i < iobuf->nr_pages; i++) {
 		map = iobuf->maplist[i];
@@ -151,6 +156,38 @@
 	iobuf->locked = 0;
 }
 
+void unmap_kiovec (struct kiobuf **iovec, int nr) 
+{
+	for (; nr > 0; --nr)
+		unmap_kiobuf(*iovec++);
+}
+
+/* Mark all kiobufs in a vector as dirty, propagating dirty bits to all
+   pages in the vector.  "bytes" indicates how much of the data has been
+   modified.  A value less than zero means "everything".  */
+
+int mark_dirty_kiovec(struct kiobuf **iovec, int nr, int bytes)
+{
+	struct kiobuf *iobuf;
+	int buf_bytes;
+	int rc, err = 0;
+	
+	for (; nr > 0; --nr) {
+		iobuf = *iovec++;
+		buf_bytes = bytes;
+		if (buf_bytes < 0 || buf_bytes > iobuf->length)
+			buf_bytes = iobuf->length;
+		rc = iobuf->map_ops->mark_dirty(iobuf, bytes);
+		if (rc && !err)
+			err = rc;
+		if (bytes >= 0)
+			bytes -= buf_bytes;
+		if (!bytes)
+			break;
+	}
+	return err;
+}
+
 
 /*
  * Lock down all of the pages of a kiovec for IO.
@@ -253,5 +290,4 @@
 	}
 	return 0;
 }
-
 
diff -ru linux-2.4.0-test10.kio.02/include/linux/iobuf.h linux-2.4.0-test10.kio.03/include/linux/iobuf.h
--- linux-2.4.0-test10.kio.02/include/linux/iobuf.h	Thu Nov  2 12:07:27 2000
+++ linux-2.4.0-test10.kio.03/include/linux/iobuf.h	Thu Nov  2 12:08:54 2000
@@ -29,6 +29,15 @@
 #define KIO_STATIC_PAGES	(KIO_MAX_ATOMIC_IO / (PAGE_SIZE >> 10) + 1)
 #define KIO_MAX_SECTORS		(KIO_MAX_ATOMIC_IO * 2)
 
+struct kiobuf;
+
+/* Operations on an established mapping of a kiobuf */
+struct kiobuf_map_operations 
+{
+	int		(*unmap) (struct kiobuf *);
+	int		(*mark_dirty) (struct kiobuf *, int);
+};
+
 /* The main kiobuf struct used for all our IO! */
 
 struct kiobuf 
@@ -60,6 +69,11 @@
 
 	void		(*end_io) (struct kiobuf *); /* Completion callback */
 	wait_queue_head_t wait_queue;
+
+	/* Private state for the mapping function: allows arbitrary IO
+           routines to perform completion appropriately. */
+	void *		map_private;
+	struct kiobuf_map_operations * map_ops;
 };
 
 
@@ -80,6 +94,7 @@
 void	unmap_kiobuf(struct kiobuf *iobuf);
 int	lock_kiovec(int nr, struct kiobuf *iovec[], int wait);
 int	unlock_kiovec(int nr, struct kiobuf *iovec[]);
+int	mark_dirty_kiovec(struct kiobuf **iovec, int nr, int bytes);
 
 /* fs/buffer.c */
 
diff -ru linux-2.4.0-test10.kio.02/mm/memory.c linux-2.4.0-test10.kio.03/mm/memory.c
--- linux-2.4.0-test10.kio.02/mm/memory.c	Thu Nov  2 12:39:16 2000
+++ linux-2.4.0-test10.kio.03/mm/memory.c	Thu Nov  2 12:39:54 2000
@@ -42,6 +42,8 @@
 #include <linux/smp_lock.h>
 #include <linux/swapctl.h>
 #include <linux/iobuf.h>
+#include <linux/file.h>
+#include <linux/slab.h>
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 #include <linux/highmem.h>
@@ -414,6 +416,84 @@
 	return page;
 }
 
+
+int discard_iobuf_filp_map(struct kiobuf *iobuf)
+{
+	int i;
+	struct file **files = (struct file **) iobuf->map_private;
+	struct file *filp;
+
+	if (!files)
+		return 0;
+	
+	for (i = 0; i < iobuf->nr_pages; i++) {
+		filp = *files++;
+		if (filp != NULL)
+			fput(filp);
+	}
+	
+	kfree(iobuf->map_private);
+	iobuf->map_private = NULL;
+	return 0;
+}
+
+/* On completion of a successful read() into the user buffer for any
+ * number of bytes, we need to propagate the dirty state into the
+ * underlying pages. 
+ *
+ * "bytes == -1" means mark all pages in the iobuf data region dirty. */
+
+int mark_user_iobuf_dirty(struct kiobuf *iobuf, int bytes)
+{
+	int first, last, i;
+	int err = 0, tmp;
+	struct file **files = (struct file **) iobuf->map_private;
+	
+	if (bytes < 0 || bytes > iobuf->length)
+		bytes = iobuf->length;
+	if (!bytes)
+		return 0;
+	
+	first = iobuf->offset >> PAGE_SHIFT;
+	last = (iobuf->offset + bytes - 1) >> PAGE_SHIFT;
+	
+	for (i=first; i<=last; i++) {
+		struct page *page = iobuf->maplist[i];
+		struct file *filp = files[i];
+		
+		if (page->mapping && page->mapping->a_ops->writepage) {
+			if (!iobuf->locked)
+				lock_page(page);
+			tmp = page->mapping->a_ops->writepage(filp, page);
+			if (!iobuf->locked)
+				UnlockPage(page);
+			if (tmp && !err)
+				err = tmp;
+		} else {
+#if 0  /* Need to educate the VM elsewhere about this!  At the very least:
+	  __free_pages_ok:	need to recognise dirty pages as valid 
+				(or clean them in zap_page_range)
+	  vmscan.c:		flush dirty swap-cache pages to swap on
+				eviction */
+			SetPageDirty(page);
+#endif
+		}
+	}
+	return err;
+}
+
+/* For kiobufs, "read" means "read into memory" and hence involves
+ * dirtying the pages concerned. */
+
+struct kiobuf_map_operations usermap_read_ops = {
+	unmap:		discard_iobuf_filp_map,
+	mark_dirty:	mark_user_iobuf_dirty
+};
+
+struct kiobuf_map_operations usermap_write_ops = {};
+
+
+
 /*
  * Force in an entire range of pages from the current process's user VA,
  * and pin them in physical memory.  
@@ -423,7 +503,7 @@
 int map_user_kiobuf(int rw, struct kiobuf *iobuf, unsigned long va, size_t len)
 {
 	unsigned long		ptr, end;
-	int			err;
+	int			err, nrpages;
 	struct mm_struct *	mm;
 	struct vm_area_struct *	vma = 0;
 	struct page *		map;
@@ -434,15 +514,34 @@
 	if (iobuf->nr_pages)
 		return -EINVAL;
 
+	/* If it is already mapped, we have a big problem! */
+	if (iobuf->map_ops != NULL)
+		BUG();
+	
 	mm = current->mm;
 	dprintk ("map_user_kiobuf: begin\n");
 	
 	ptr = va & PAGE_MASK;
 	end = (va + len + PAGE_SIZE - 1) & PAGE_MASK;
-	err = expand_kiobuf(iobuf, (end - ptr) >> PAGE_SHIFT);
+	nrpages = (end - ptr) >> PAGE_SHIFT;
+	err = expand_kiobuf(iobuf, nrpages);
 	if (err)
 		return err;
 
+	/* For writable mappings, we need to support marking the pages
+           dirty later on, and that in turn requires storing the filps
+           associated with the vma being scanned. */
+	if (datain) {
+		iobuf->map_private = kmalloc(sizeof(void *) * nrpages, GFP_KERNEL);
+		if (!iobuf->map_private)
+			return -ENOMEM;
+		memset(iobuf->map_private, 0, sizeof(void *) * nrpages);
+
+		iobuf->map_ops = &usermap_read_ops;
+	}
+	else
+		iobuf->map_ops = &usermap_write_ops;
+	
 	down(&mm->mmap_sem);
 
 	err = -EFAULT;
@@ -491,9 +590,20 @@
 			printk (KERN_INFO "Mapped page missing [%d]\n", i);
 		spin_unlock(&mm->page_table_lock);
 		iobuf->maplist[i] = map;
-		iobuf->nr_pages = ++i;
 		
 		ptr += PAGE_SIZE;
+
+		/* The page is pinned and the mm is locked, so we can
+                   safely lookup the filp for this page's writeback now
+                   if we need to. */
+		if (datain) {
+			struct file *filp = vma->vm_file;
+			if (filp) 
+				get_file(filp);
+			((struct file **)iobuf->map_private)[i] = filp;
+		}
+
+		iobuf->nr_pages = ++i;
 	}
 
 	up(&mm->mmap_sem);
@@ -503,6 +613,10 @@
  out_unlock:
 	up(&mm->mmap_sem);
 	unmap_kiobuf(iobuf);
+	if (datain) 
+		discard_iobuf_filp_map(iobuf);
+	iobuf->map_ops = NULL;
+	
 	dprintk ("map_user_kiobuf: end %d\n", err);
 	return err;
 }

--L2Brqb15TUChFOBK--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
