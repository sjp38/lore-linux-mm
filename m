Received: from mail.ccr.net (ccr@alogconduit1ah.ccr.net [208.130.159.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA16213
	for <linux-mm@kvack.org>; Fri, 25 Dec 1998 15:02:56 -0500
Subject: Swap File improvement.
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 25 Dec 1998 14:18:50 -0600
Message-ID: <m1n24crn4l.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


The following patch allows asynchronous swapping to swap files,
improving their performance immensely.

Additionally since now all swapping goes there brw_page, the semantics are much
cleaner, and we don't need to maintain ll_rw_swap_file.

My final function rw_swap_page_nolock is not strictly needed currenly,
but this all came out of work and a swapfs type filesystem, where it was very
useful.

Note.  We could (except for sysv shm) remove the swap lock map entirely.

diff -uNr linux-2.1.132.eb0/drivers/block/ll_rw_blk.c linux-2.1.132.eb1/drivers/block/ll_rw_blk.c
--- linux-2.1.132.eb0/drivers/block/ll_rw_blk.c	Fri Dec 25 12:09:33 1998
+++ linux-2.1.132.eb1/drivers/block/ll_rw_blk.c	Fri Dec 25 12:19:23 1998
@@ -649,86 +649,6 @@
 	return;
 }
 
-void ll_rw_swap_file(int rw, kdev_t dev, unsigned int *b, int nb, char *buf)
-{
-	int i, j;
-	int buffersize;
-	int max_req;
-	unsigned long rsector;
-	kdev_t rdev;
-	struct request * req[8];
-	unsigned int major = MAJOR(dev);
-	struct semaphore sem = MUTEX_LOCKED;
-
-	if (major >= MAX_BLKDEV || !(blk_dev[major].request_fn)) {
-		printk(KERN_NOTICE "ll_rw_swap_file: trying to swap to"
-                                   " nonexistent block-device\n");
-		return;
-	}
-	max_req = NR_REQUEST;
-	switch (rw) {
-		case READ:
-			break;
-		case WRITE:
-			max_req = (NR_REQUEST * 2) / 3;
-			if (is_read_only(dev)) {
-				printk(KERN_NOTICE
-                                       "Can't swap to read-only device %s\n",
-					kdevname(dev));
-				return;
-			}
-			break;
-		default:
-			panic("ll_rw_swap: bad block dev cmd, must be R/W");
-	}
-	buffersize = PAGE_SIZE / nb;
-
-	if ((major == LOOP_MAJOR) || (major == NBD_MAJOR))
-	     max_req >>= 1;
-	for (j=0, i=0; i<nb;)
-	{
-		for (; j < 8 && i < nb; j++, i++, buf += buffersize)
-		{
-		        rdev = dev;
-			rsector = b[i] * (buffersize >> 9);
-#ifdef CONFIG_BLK_DEV_MD
-			if (major==MD_MAJOR &&
-			    md_map (MINOR(dev), &rdev,
-				    &rsector, buffersize >> 9)) {
-			        printk (KERN_ERR
-                                        "Bad md_map in ll_rw_swap_file\n");
-				return;
-			}
-#endif
-			
-			if (j == 0) {
-				req[j] = get_request_wait(max_req, rdev);
-			} else {
-				unsigned long flags;
-				spin_lock_irqsave(&io_request_lock,flags);
-				req[j] = get_request(max_req, rdev);
-				spin_unlock_irqrestore(&io_request_lock,flags);
-				if (req[j] == NULL)
-					break;
-			}
-			req[j]->cmd = rw;
-			req[j]->errors = 0;
-			req[j]->sector = rsector;
-			req[j]->nr_sectors = buffersize >> 9;
-			req[j]->current_nr_sectors = buffersize >> 9;
-			req[j]->buffer = buf;
-			req[j]->sem = &sem;
-			req[j]->bh = NULL;
-			req[j]->next = NULL;
-			add_request(MAJOR(rdev)+blk_dev,req[j]);
-		}
-		run_task_queue(&tq_disk);
-		while (j > 0) {
-			j--;
-			down(&sem);
-		}
-	}
-}
 #ifdef CONFIG_STRAM_SWAP
 extern int stram_device_init( void );
 #endif
diff -uNr linux-2.1.132.eb0/include/linux/fs.h linux-2.1.132.eb1/include/linux/fs.h
--- linux-2.1.132.eb0/include/linux/fs.h	Fri Dec 25 12:11:32 1998
+++ linux-2.1.132.eb1/include/linux/fs.h	Fri Dec 25 12:19:23 1998
@@ -815,8 +815,6 @@
 extern struct buffer_head * getblk(kdev_t, int, int);
 extern struct buffer_head * find_buffer(kdev_t dev, int block, int size);
 extern void ll_rw_block(int, int, struct buffer_head * bh[]);
-extern void ll_rw_page(int, kdev_t, unsigned long, char *);
-extern void ll_rw_swap_file(int, kdev_t, unsigned int *, int, char *);
 extern int is_read_only(kdev_t);
 extern void __brelse(struct buffer_head *);
 extern inline void brelse(struct buffer_head *buf)
diff -uNr linux-2.1.132.eb0/include/linux/swap.h linux-2.1.132.eb1/include/linux/swap.h
--- linux-2.1.132.eb0/include/linux/swap.h	Fri Dec 25 12:11:33 1998
+++ linux-2.1.132.eb1/include/linux/swap.h	Fri Dec 25 12:19:23 1998
@@ -87,6 +87,7 @@
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, unsigned long, char *, int);
 extern void rw_swap_page_nocache(int, unsigned long, char *);
+extern void rw_swap_page_nolock(int, unsigned long, char *, int);
 extern void swap_after_unlock_page (unsigned long entry);
 
 /* linux/mm/page_alloc.c */
diff -uNr linux-2.1.132.eb0/mm/page_io.c linux-2.1.132.eb1/mm/page_io.c
--- linux-2.1.132.eb0/mm/page_io.c	Fri Dec 25 12:11:36 1998
+++ linux-2.1.132.eb1/mm/page_io.c	Fri Dec 25 12:22:52 1998
@@ -7,6 +7,7 @@
  *  Asynchronous swapping added 30.12.95. Stephen Tweedie
  *  Removed race in async swapping. 14.4.1996. Bruno Haible
  *  Add swap of shared pages through the page cache. 20.2.1998. Stephen Tweedie
+ *  Always use brw_page, life becomes simpler. 12 May 1998 Eric Biederman
  */
 
 #include <linux/mm.h>
@@ -15,8 +16,6 @@
 #include <linux/locks.h>
 #include <linux/swapctl.h>
 
-#include <asm/dma.h>
-#include <asm/uaccess.h> /* for copy_to/from_user */
 #include <asm/pgtable.h>
 
 static struct wait_queue * lock_queue = NULL;
@@ -24,8 +23,6 @@
 /*
  * Reads or writes a swap page.
  * wait=1: start I/O and wait for completion. wait=0: start asynchronous I/O.
- * All IO to swap files (as opposed to swap partitions) is done
- * synchronously.
  *
  * Important prevention of race condition: the caller *must* atomically 
  * create a unique swap cache entry for this swap page before calling
@@ -38,21 +35,22 @@
  * that shared pages stay shared while being swapped.
  */
 
-void rw_swap_page(int rw, unsigned long entry, char * buf, int wait)
+static void rw_swap_page_base(int rw, unsigned long entry, struct page *page, int wait)
 {
 	unsigned long type, offset;
 	struct swap_info_struct * p;
-	struct page *page = mem_map + MAP_NR(buf);
+	int zones[PAGE_SIZE/512];
+	int zones_used;
+	kdev_t dev;
+	int block_size;
 
 #ifdef DEBUG_SWAP
 	printk ("DebugVM: %s_swap_page entry %08lx, page %p (count %d), %s\n",
 		(rw == READ) ? "read" : "write", 
-		entry, buf, atomic_read(&page->count),
+		entry, (char *) page_address(page), atomic_read(&page->count),
 		wait ? "wait" : "nowait");
 #endif
 
-	if (page->inode && page->inode != &swapper_inode)
-		panic ("Tried to swap a non-swapper page");
 	type = SWP_TYPE(entry);
 	if (type >= nr_swapfiles) {
 		printk("Internal error: bad swap-device\n");
@@ -85,13 +83,27 @@
 		printk(KERN_ERR "VM: swap page is unlocked\n");
 		return;
 	}
-	
-	/* Make sure we are the only process doing I/O with this swap page. */
-	while (test_and_set_bit(offset,p->swap_lockmap)) {
-		run_task_queue(&tq_disk);
-		sleep_on(&lock_queue);
+
+	if (PageSwapCache(page)) {
+		/* Make sure we are the only process doing I/O with this swap page. */
+		while (test_and_set_bit(offset,p->swap_lockmap)) {
+			run_task_queue(&tq_disk);
+			sleep_on(&lock_queue);
+		}
+
+		/* 
+		 * Make sure that we have a swap cache association for this
+		 * page.  We need this to find which swap page to unlock once
+		 * the swap IO has completed to the physical page.  If the page
+		 * is not already in the cache, just overload the offset entry
+		 * as if it were: we are not allowed to manipulate the inode
+		 * hashing for locked pages.
+		 */
+		if (page->offset != entry) {
+			printk ("swap entry mismatch");
+			return;
+		}
 	}
-	
 	if (rw == READ) {
 		clear_bit(PG_uptodate, &page->flags);
 		kstat.pswpin++;
@@ -99,54 +111,25 @@
 		kstat.pswpout++;
 
 	atomic_inc(&page->count);
-	/* 
-	 * Make sure that we have a swap cache association for this
-	 * page.  We need this to find which swap page to unlock once
-	 * the swap IO has completed to the physical page.  If the page
-	 * is not already in the cache, just overload the offset entry
-	 * as if it were: we are not allowed to manipulate the inode
-	 * hashing for locked pages.
-	 */
-	if (!PageSwapCache(page)) {
-		printk(KERN_ERR "VM: swap page is not in swap cache\n");
-		return;
-	}
-	if (page->offset != entry) {
-		printk (KERN_ERR "VM: swap entry mismatch\n");
-		return;
-	}
-
 	if (p->swap_device) {
-		if (!wait) {
-			set_bit(PG_free_after, &page->flags);
-			set_bit(PG_decr_after, &page->flags);
-			set_bit(PG_swap_unlock_after, &page->flags);
-			atomic_inc(&nr_async_pages);
-		}
-		ll_rw_page(rw,p->swap_device,offset,buf);
-		/*
-		 * NOTE! We don't decrement the page count if we
-		 * don't wait - that will happen asynchronously
-		 * when the IO completes.
-		 */
-		if (!wait)
-			return;
-		wait_on_page(page);
+		zones[0] = offset;
+		zones_used = 1;
+		dev = p->swap_device;
+		block_size = PAGE_SIZE;
 	} else if (p->swap_file) {
 		struct inode *swapf = p->swap_file->d_inode;
-		unsigned int zones[PAGE_SIZE/512];
 		int i;
 		if (swapf->i_op->bmap == NULL
 			&& swapf->i_op->smap != NULL){
 			/*
-				With MS-DOS, we use msdos_smap which return
+				With MS-DOS, we use msdos_smap which returns
 				a sector number (not a cluster or block number).
 				It is a patch to enable the UMSDOS project.
 				Other people are working on better solution.
 
 				It sounds like ll_rw_swap_file defined
-				it operation size (sector size) based on
-				PAGE_SIZE and the number of block to read.
+				its operation size (sector size) based on
+				PAGE_SIZE and the number of blocks to read.
 				So using bmap or smap should work even if
 				smap will require more blocks.
 			*/
@@ -159,39 +142,72 @@
 					return;
 				}
 			}
+			block_size = 512;
 		}else{
 			int j;
 			unsigned int block = offset
 				<< (PAGE_SHIFT - swapf->i_sb->s_blocksize_bits);
 
-			for (i=0, j=0; j< PAGE_SIZE ; i++, j +=swapf->i_sb->s_blocksize)
+			block_size = swapf->i_sb->s_blocksize;
+			for (i=0, j=0; j< PAGE_SIZE ; i++, j += block_size)
 				if (!(zones[i] = bmap(swapf,block++))) {
 					printk("rw_swap_page: bad swap file\n");
 					return;
 				}
+			zones_used = i;
+			dev = swapf->i_dev;
 		}
-		ll_rw_swap_file(rw,swapf->i_dev, zones, i,buf);
-		/* Unlike ll_rw_page, ll_rw_swap_file won't unlock the
-		   page for us. */
-		clear_bit(PG_locked, &page->flags);
-		wake_up(&page->wait);
-	} else
+	} else {
 		printk(KERN_ERR "rw_swap_page: no swap file or device\n");
-
+		/* Do some cleaning up so if this ever happens we can hopefully
+		 * trigger controlled shutdown.
+		 */
+		if (PageSwapCache(page)) {
+			if (!test_and_clear_bit(offset,p->swap_lockmap))
+				printk("swap_after_unlock_page: lock already cleared\n");
+			wake_up(&lock_queue);
+		}
+		atomic_dec(&page->count);
+		return;
+	}
+ 	if (!wait) {
+ 		set_bit(PG_decr_after, &page->flags);
+ 		atomic_inc(&nr_async_pages);
+ 	}
+ 	if (PageSwapCache(page)) {
+ 		/* only lock/unlock swap cache pages! */
+ 		set_bit(PG_swap_unlock_after, &page->flags);
+ 	}
+ 	set_bit(PG_free_after, &page->flags);
+
+ 	/* block_size == PAGE_SIZE/zones_used */
+ 	brw_page(rw, page, dev, zones, block_size, 0);
+ 
+ 	/* Note! For consistency we do all of the logic,
+ 	 * decrementing the page count, and unlocking the page in the
+ 	 * swap lock map - in the IO completion handler.
+ 	 */
+ 	if (!wait) 
+ 		return;
+ 	wait_on_page(page);
 	/* This shouldn't happen, but check to be sure. */
-	if (atomic_read(&page->count) == 1)
+	if (atomic_read(&page->count) == 0)
 		printk(KERN_ERR "rw_swap_page: page unused while waiting!\n");
-	atomic_dec(&page->count);
-	if (offset && !test_and_clear_bit(offset,p->swap_lockmap))
-		printk(KERN_ERR "rw_swap_page: lock already cleared\n");
-	wake_up(&lock_queue);
+
 #ifdef DEBUG_SWAP
 	printk ("DebugVM: %s_swap_page finished on page %p (count %d)\n",
 		(rw == READ) ? "read" : "write", 
-		buf, atomic_read(&page->count));
+		(char *) page_adddress(page), 
+		atomic_read(&page->count));
 #endif
 }
 
+/* Note: We could remove this totally asynchronous function,
+ * and improve swap performance, and remove the need for the swap lock map,
+ * by not removing pages from the swap cache until after I/O has been
+ * processed and letting remove_from_page_cache decrement the swap count
+ * just before it removes the page from the page cache.
+ */
 /* This is run when asynchronous page I/O has completed. */
 void swap_after_unlock_page (unsigned long entry)
 {
@@ -214,6 +230,35 @@
 	wake_up(&lock_queue);
 }
 
+/* A simple wrapper so the base function doesn't need to enforce
+ * that all swap pages go through the swap cache!
+ */
+void rw_swap_page(int rw, unsigned long entry, char *buf, int wait)
+{
+	struct page *page = mem_map + MAP_NR(buf);
+
+	if (page->inode && page->inode != &swapper_inode)
+		panic ("Tried to swap a non-swapper page");
+
+	/*
+	 * Make sure that we have a swap cache association for this
+	 * page.  We need this to find which swap page to unlock once
+	 * the swap IO has completed to the physical page.  If the page
+	 * is not already in the cache, just overload the offset entry
+	 * as if it were: we are not allowed to manipulate the inode
+	 * hashing for locked pages.
+	 */
+	if (!PageSwapCache(page)) {
+		printk("VM: swap page is not in swap cache\n");
+		return;
+	}
+	if (page->offset != entry) {
+		printk ("swap entry mismatch");
+		return;
+	}
+	rw_swap_page_base(rw, entry, page, wait);
+}
+
 /*
  * Setting up a new swap file needs a simple wrapper just to read the 
  * swap signature.  SysV shared memory also needs a simple wrapper.
@@ -242,33 +287,23 @@
 	clear_bit(PG_swap_cache, &page->flags);
 }
 
-
-
 /*
- * Swap partitions are now read via brw_page.  ll_rw_page is an
- * asynchronous function now --- we must call wait_on_page afterwards
- * if synchronous IO is required.  
+ * shmfs needs a version that doesn't put the page in the page cache!
+ * The swap lock map insists that pages be in the page cache!
+ * Therefore we can't use it.  Later when we can remove the need for the
+ * lock map and we can reduce the number of functions exported.
  */
-void ll_rw_page(int rw, kdev_t dev, unsigned long offset, char * buffer)
+void rw_swap_page_nolock(int rw, unsigned long entry, char *buffer, int wait)
 {
-	int block = offset;
-	struct page *page;
-
-	switch (rw) {
-		case READ:
-			break;
-		case WRITE:
-			if (is_read_only(dev)) {
-				printk("Can't page to read-only device %s\n",
-					kdevname(dev));
-				return;
-			}
-			break;
-		default:
-			panic("ll_rw_page: bad block dev cmd, must be R/W");
-	}
-	page = mem_map + MAP_NR(buffer);
-	if (!PageLocked(page))
-		panic ("ll_rw_page: page not already locked");
-	brw_page(rw, page, dev, &block, PAGE_SIZE, 0);
+	struct page *page = mem_map + MAP_NR((unsigned long) buffer);
+	
+	if (!PageLocked(page)) {
+		printk("VM: rw_swap_page_nolock: page not locked!\n");
+		return;
+	}
+	if (PageSwapCache(page)) {
+		printk ("VM: rw_swap_page_nolock: page in swap cache!\n");
+		return;
+	}
+	rw_swap_page_base(rw, entry, page, wait);
 }

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
