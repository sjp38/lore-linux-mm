Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA16995
	for <linux-mm@kvack.org>; Fri, 5 Feb 1999 11:54:18 -0500
Date: Fri, 5 Feb 1999 16:53:38 GMT
Message-Id: <199902051653.QAA01763@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: [PATCH] Fix for VM deadlock in 2.2.1
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <number6@the-village.bc.nu>
Cc: linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

The VM deadlock problems we still have in 2.2 are triggered on both
inode and superblock locks, but the underlying cause is not the
filesystem locking but the VM reentrancy involved.  Any file IO
operation (write, msync or whatever) which holds a critical vfs lock
while allocating memory can recurse if the file is mmap()ed writably
anywhere, as we go down the path get_free_pages() -> try_to_free_pages()
-> try_to_swap_out() -> filemap_write_page().

Even with the recursive inode semaphore, it is trivial to reproduce this
using two or more processes each doing mmap + write to their own files.

One the way to hack this problem out bit by bit is to redo the locking
on all filesystems, and the recursive semaphore code is a start down
this path.

The way to completely eliminate the problem is for the VM to avoid this
recursion in the first place.  The patch below adds a new kpiod (page IO
daemon) thread to augment kswapd.  All filemap page writes get queued to
this thread for IO rather than being executed in the context of the
caller, and the caller never blocks waiting for that IO to complete.  In
other words, the caller can never fail eventually to release any vfs
locks currently held, so the page write is guaranteed to succeed
eventually.  Even recursive allocations within the kpiod thread are
safe, since that just results in a queuing of the recursive page write:
the actual IO is deferred until the kpiod thread loops to its next
request.

The downside of the change is that we are limited to a single thread of
execution when doing memory mapped writeback, although starting multiple
kpiod threads will avoid this if it proves to be a problem.  On ext2fs,
only the copying of the page to the buffer cache is serialised in this
way; the actual disk IO will proceed asynchronously via bdflush as
usual.

msync() does not use the new kpiod thread for its page writes, nor does
it need to.

A reproducer which stresses writeable mmap and write()s in parallel
would reliably lock up within a couple of iterations on 2.2.1, but I got
bored after listening to it successfully thrash the disk for a couple of
hours with the fix in place.

The second patch below is a tiny one I had queued for post-2.2.1, and
just moves the swap_cnt and swap_address task_struct fields to the
mm_struct, preventing the VM from making multiple swap passes over a
single mm if there are multiple threads using that mm.

--Stephen

----------------------------------------------------------------
--- init/main.c.~1~	Wed Jan 20 18:18:53 1999
+++ init/main.c	Wed Feb  3 17:47:08 1999
@@ -64,6 +64,7 @@
 static int init(void *);
 extern int bdflush(void *);
 extern int kswapd(void *);
+extern int kpiod(void *);
 extern void kswapd_setup(void);
 
 extern void init_IRQ(void);
@@ -1271,6 +1272,7 @@
 	kernel_thread(bdflush, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
 	/* Start the background pageout daemon. */
 	kswapd_setup();
+	kernel_thread(kpiod, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
 	kernel_thread(kswapd, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
 
 #if CONFIG_AP1000
--- mm/filemap.c.~1~	Mon Jan 25 18:47:11 1999
+++ mm/filemap.c	Wed Feb  3 20:34:54 1999
@@ -19,6 +19,7 @@
 #include <linux/blkdev.h>
 #include <linux/file.h>
 #include <linux/swapctl.h>
+#include <linux/slab.h>
 
 #include <asm/pgtable.h>
 #include <asm/uaccess.h>
@@ -39,6 +40,26 @@
 
 #define release_page(page) __free_page((page))
 
+/* 
+ * Define a request structure for outstanding page write requests
+ * to the background page io daemon
+ */
+
+struct pio_request 
+{
+	struct pio_request *	next;
+	struct file *		file;
+	unsigned long		offset;
+	unsigned long		page;
+};
+static struct pio_request *pio_first = NULL, **pio_last = &pio_first;
+static kmem_cache_t *pio_request_cache;
+static struct wait_queue *pio_wait = NULL;
+
+static inline void 
+make_pio_request(struct file *, unsigned long, unsigned long);
+
+
 /*
  * Invalidate the pages of an inode, removing all pages that aren't
  * locked down (those are sure to be up-to-date anyway, so we shouldn't
@@ -1079,8 +1100,9 @@
 }
 
 static int filemap_write_page(struct vm_area_struct * vma,
-	unsigned long offset,
-	unsigned long page)
+			      unsigned long offset,
+			      unsigned long page,
+			      int wait)
 {
 	int result;
 	struct file * file;
@@ -1098,6 +1120,17 @@
 	 * and file could be released ... increment the count to be safe.
 	 */
 	file->f_count++;
+
+	/* 
+	 * If this is a swapping operation rather than msync(), then
+	 * leave the actual IO, and the restoration of the file count,
+	 * to the kpiod thread.  Just queue the request for now.
+	 */
+	if (!wait) {
+		make_pio_request(file, offset, page);
+		return 0;
+	}
+	
 	down(&inode->i_sem);
 	result = do_write_page(inode, file, (const char *) page, offset);
 	up(&inode->i_sem);
@@ -1113,7 +1146,7 @@
  */
 int filemap_swapout(struct vm_area_struct * vma, struct page * page)
 {
-	return filemap_write_page(vma, page->offset, page_address(page));
+	return filemap_write_page(vma, page->offset, page_address(page), 0);
 }
 
 static inline int filemap_sync_pte(pte_t * ptep, struct vm_area_struct *vma,
@@ -1150,7 +1183,7 @@
 			return 0;
 		}
 	}
-	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, page);
+	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, page, 1);
 	free_page(page);
 	return error;
 }
@@ -1568,4 +1601,121 @@
 	clear_bit(PG_locked, &page->flags);
 	wake_up(&page->wait);
 	__free_page(page);
+}
+
+
+/* Add request for page IO to the queue */
+
+static inline void put_pio_request(struct pio_request *p)
+{
+	*pio_last = p;
+	p->next = NULL;
+	pio_last = &p->next;
+}
+
+/* Take the first page IO request off the queue */
+
+static inline struct pio_request * get_pio_request(void)
+{
+	struct pio_request * p = pio_first;
+	pio_first = p->next;
+	if (!pio_first)
+		pio_last = &pio_first;
+	return p;
+}
+
+/* Make a new page IO request and queue it to the kpiod thread */
+
+static inline void make_pio_request(struct file *file,
+				    unsigned long offset,
+				    unsigned long page)
+{
+	struct pio_request *p;
+
+	atomic_inc(&mem_map[MAP_NR(page)].count);
+
+	/* 
+	 * We need to allocate without causing any recursive IO in the
+	 * current thread's context.  We might currently be swapping out
+	 * as a result of an allocation made while holding a critical
+	 * filesystem lock.  To avoid deadlock, we *MUST* not reenter
+	 * the filesystem in this thread.
+	 *
+	 * We can wait for kswapd to free memory, or we can try to free
+	 * pages without actually performing further IO, without fear of
+	 * deadlock.  --sct
+	 */
+
+	while ((p = kmem_cache_alloc(pio_request_cache, GFP_BUFFER)) == NULL) {
+		if (try_to_free_pages(__GFP_WAIT))
+			continue;
+		current->state = TASK_INTERRUPTIBLE;
+		schedule_timeout(HZ/10);
+	}
+	
+	p->file   = file;
+	p->offset = offset;
+	p->page   = page;
+
+	put_pio_request(p);
+	wake_up(&pio_wait);
+}
+
+
+/*
+ * This is the only thread which is allowed to write out filemap pages
+ * while swapping.
+ * 
+ * To avoid deadlock, it is important that we never reenter this thread.
+ * Although recursive memory allocations within this thread may result
+ * in more page swapping, that swapping will always be done by queuing
+ * another IO request to the same thread: we will never actually start
+ * that IO request until we have finished with the current one, and so
+ * we will not deadlock.  
+ */
+
+int kpiod(void * unused)
+{
+	struct wait_queue wait = {current};
+	struct inode * inode;
+	struct dentry * dentry;
+	struct pio_request * p;
+	
+	current->session = 1;
+	current->pgrp = 1;
+	strcpy(current->comm, "kpiod");
+	sigfillset(&current->blocked);
+	init_waitqueue(&pio_wait);
+
+	lock_kernel();
+	
+	pio_request_cache = kmem_cache_create("pio_request", 
+					      sizeof(struct pio_request),
+					      0, SLAB_HWCACHE_ALIGN, 
+					      NULL, NULL);
+	if (!pio_request_cache)
+		panic ("Could not create pio_request slab cache");
+	
+	while (1) {
+		current->state = TASK_INTERRUPTIBLE;
+		add_wait_queue(&pio_wait, &wait);
+		while (!pio_first)
+			schedule();
+		remove_wait_queue(&pio_wait, &wait);
+		current->state = TASK_RUNNING;
+
+		while (pio_first) {
+			p = get_pio_request();
+			dentry = p->file->f_dentry;
+			inode = dentry->d_inode;
+			
+			down(&inode->i_sem);
+			do_write_page(inode, p->file,
+				      (const char *) p->page, p->offset);
+			up(&inode->i_sem);
+			fput(p->file);
+			free_page(p->page);
+			kmem_cache_free(pio_request_cache, p);
+		}
+	}
 }
----------------------------------------------------------------
--- include/linux/sched.h.~1~	Tue Jan 26 00:06:22 1999
+++ include/linux/sched.h	Wed Feb  3 17:49:31 1999
@@ -174,6 +174,8 @@
 	unsigned long rss, total_vm, locked_vm;
 	unsigned long def_flags;
 	unsigned long cpu_vm_mask;
+	unsigned long swap_cnt;	/* number of pages to swap on next pass */
+	unsigned long swap_address;
 	/*
 	 * This is an architecture-specific pointer: the portable
 	 * part of Linux does not know about any segments.
@@ -191,7 +193,7 @@
 		0, 0, 0, 				\
 		0, 0, 0, 0,				\
 		0, 0, 0,				\
-		0, 0, NULL }
+		0, 0, 0, 0, NULL }
 
 struct signal_struct {
 	atomic_t		count;
@@ -276,8 +278,6 @@
 /* mm fault and swap info: this can arguably be seen as either mm-specific or thread-specific */
 	unsigned long min_flt, maj_flt, nswap, cmin_flt, cmaj_flt, cnswap;
 	int swappable:1;
-	unsigned long swap_address;
-	unsigned long swap_cnt;		/* number of pages to swap on next pass */
 /* process credentials */
 	uid_t uid,euid,suid,fsuid;
 	gid_t gid,egid,sgid,fsgid;
@@ -361,7 +361,7 @@
 /* utime */	{0,0,0,0},0, \
 /* per CPU times */ {0, }, {0, }, \
 /* flt */	0,0,0,0,0,0, \
-/* swp */	0,0,0, \
+/* swp */	0, \
 /* process credentials */					\
 /* uid etc */	0,0,0,0,0,0,0,0,				\
 /* suppl grps*/ 0, {0,},					\
--- mm/vmscan.c.~1~	Mon Jan 25 19:08:56 1999
+++ mm/vmscan.c	Wed Feb  3 17:47:09 1999
@@ -202,7 +202,7 @@
 
 	do {
 		int result;
-		tsk->swap_address = address + PAGE_SIZE;
+		tsk->mm->swap_address = address + PAGE_SIZE;
 		result = try_to_swap_out(tsk, vma, address, pte, gfp_mask);
 		if (result)
 			return result;
@@ -274,7 +274,7 @@
 	/*
 	 * Go through process' page directory.
 	 */
-	address = p->swap_address;
+	address = p->mm->swap_address;
 
 	/*
 	 * Find the proper vm-area
@@ -296,8 +296,8 @@
 	}
 
 	/* We didn't find anything for the process */
-	p->swap_cnt = 0;
-	p->swap_address = 0;
+	p->mm->swap_cnt = 0;
+	p->mm->swap_address = 0;
 	return 0;
 }
 
@@ -345,9 +345,9 @@
 				continue;
 			/* Refresh swap_cnt? */
 			if (assign)
-				p->swap_cnt = p->mm->rss;
-			if (p->swap_cnt > max_cnt) {
-				max_cnt = p->swap_cnt;
+				p->mm->swap_cnt = p->mm->rss;
+			if (p->mm->swap_cnt > max_cnt) {
+				max_cnt = p->mm->swap_cnt;
 				pbest = p;
 			}
 		}
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
