Subject: PATCH: Trying to get back IO performance (WIP)
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 03 Jul 2000 02:24:07 +0200
Message-ID: <ytthfa8oyc8.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo@conectiva.com.br, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        This patch is against test3-pre2.
It gives here good performance in the first run, and very bad
in the following ones of dbench 48.  I am hitting here problems with
the locking scheme.  I get a lot of contention in __wait_on_supper.
Almost all the dbench processes are waiting in:

0xc7427dcc 0xc0116fbd schedule+0x389 (0xc4840c20, 0x12901d, 0xc7427ea0, 0x123456
7, 0xc7426000)
                               kernel .text 0xc0100000 0xc0116c34 0xc01173c0
           0xc013639c __wait_on_super+0x184 (0xc13f4c00)
                               kernel .text 0xc0100000 0xc0136218 0xc0136410
           0xc01523e5 ext2_alloc_block+0x21 (0xc4840c20, 0x12901d, 0xc7427ea0)
                               kernel .text 0xc0100000 0xc01523c4 0xc015245c
0xc7427e5c 0xc0152892 block_getblk+0x15e (0xc4840c20, 0xc316b5e0, 0x9, 0x15, 0xc
7427ea0)
                               kernel .text 0xc0100000 0xc0152734 0xc0152a68
0xc7427eac 0xc0152ed0 ext2_get_block+0x468 (0xc4840c20, 0x15, 0xc2d99de0, 0x1)
                               kernel .text 0xc0100000 0xc0152a68 0xc0152fc0
0xc7427ef4 0xc0133ae3 __block_prepare_write+0xe7 (0xc4840c20, 0xc11f7f78, 0x0, 0
x1000, 0xc0152a68)
                               kernel .text 0xc0100000 0xc01339fc 0xc0133bf0
0xc7427f18 0xc0134121 block_prepare_write+0x21 (0xc11f7f78, 0x0, 0x1000, 0xc0152
a68)
                               kernel .text 0xc0100000 0xc0134100 0xc013413c
[0]more> 
0xc7427f30 0xc01531d1 ext2_prepare_write+0x19 (0xc06b4f00, 0xc11f7f78, 0x0, 0x10
00)
                               kernel .text 0xc0100000 0xc01531b8 0xc01531d8
0xc7427f90 0xc0127b8d generic_file_write+0x305 (0xc06b4f00, 0x8050461, 0xafc2, 0
xc06b4f20)
                               kernel .text 0xc0100000 0xc0127888 0xc0127cf0
0xc7427fbc 0xc0130ea8 sys_write+0xe8 (0x9, 0x804b460, 0xffc3, 0x28, 0x1082)
                               kernel .text 0xc0100000 0xc0130dc0 0xc0130ed0
           0xc0109874 system_call+0x34
                               kernel .text 0xc0100000 0xc0109840 0xc0109878


This behavior also happens with vanilla kernel, only that it is not
so easy to reproduce.  Vanilla Kernel also gives normally worse IO
throughput than the first run with this patch.

Comments/suggerences/fixes are welcome.

Later, Juan.

This patch does:
     - Introduces WRITETRY logic that means: write this buffer if that
       is possible, but never block.  If we have to block, skip the
       write. (mainly from Jens axboe)
     - Uses that logic in sync_page_buffers(), i.e. never try to block
       in writes, when writing buffers.
     - Do all the blocking/waiting calling balance_dirty() in
       shrink_mmap.
     - export the sync_page_buffers function.
     - make try_to_free_buffers never generate any IO.
     - Change the caller of that two functions accordingly with the new
       semantics.


diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/drivers/block/ll_rw_blk.c working/drivers/block/ll_rw_blk.c
--- base/drivers/block/ll_rw_blk.c	Fri Jun 30 18:42:30 2000
+++ working/drivers/block/ll_rw_blk.c	Mon Jul  3 00:03:00 2000
@@ -556,7 +556,7 @@
 	unsigned int sector, count;
 	int max_segments = MAX_SEGMENTS;
 	struct request * req = NULL;
-	int rw_ahead, max_sectors, el_ret;
+	int r_ahead, w_ahead, max_sectors, el_ret;
 	struct list_head *head = &q->queue_head;
 	int latency;
 	elevator_t *elevator = &q->elevator;
@@ -584,30 +584,24 @@
 		}
 	}
 
-	rw_ahead = 0;	/* normal case; gets changed below for READA */
+	r_ahead = w_ahead = 0;
 	switch (rw) {
 		case READA:
-			rw_ahead = 1;
+			r_ahead = 1;
 			rw = READ;	/* drop into READ */
 		case READ:
 			if (buffer_uptodate(bh)) /* Hmmph! Already have it */
 				goto end_io;
 			kstat.pgpgin++;
 			break;
-		case WRITERAW:
-			rw = WRITE;
-			goto do_write;	/* Skip the buffer refile */
+		case WRITETRY:
+			w_ahead = 1;
 		case WRITE:
 			if (!test_and_clear_bit(BH_Dirty, &bh->b_state))
 				goto end_io;	/* Hmmph! Nothing to write */
 			refile_buffer(bh);
-		do_write:
-			/*
-			 * We don't allow the write-requests to fill up the
-			 * queue completely:  we want some room for reads,
-			 * as they take precedence. The last third of the
-			 * requests are only for reads.
-			 */
+		case WRITERAW:  	/* Skip the buffer refile */
+			rw = WRITE;
 			kstat.pgpgout++;
 			break;
 		default:
@@ -705,8 +699,13 @@
 get_rq:
 	if ((req = get_request(q, rw)) == NULL) {
 		spin_unlock_irq(&io_request_lock);
-		if (rw_ahead)
+		if (r_ahead)
 			goto end_io;
+		if (w_ahead) {
+			set_bit(BH_Dirty, &bh->b_state);
+			refile_buffer(bh);
+			goto end_io;
+		}
 
 		req = __get_request_wait(q, rw);
 		spin_lock_irq(&io_request_lock);
@@ -837,6 +836,15 @@
 		bh->b_rsector = bh->b_blocknr * (bh->b_size>>9);
 
 		generic_make_request(q, rw, bh);
+
+		/*
+		 * hack
+		 */
+		if (rw == WRITETRY && buffer_dirty(bh)) {
+			clear_bit(BH_Req, &bh->b_state);
+			clear_bit(BH_Lock, &bh->b_state);
+		}
+		
 	}
 	return;
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/fs/buffer.c working/fs/buffer.c
--- base/fs/buffer.c	Fri Jun 30 18:42:31 2000
+++ working/fs/buffer.c	Mon Jul  3 01:54:19 2000
@@ -1313,7 +1313,7 @@
 	 * instead.
 	 */
 	if (!offset) {
-		if (!try_to_free_buffers(page, 0)) {
+		if (!try_to_free_buffers(page)) {
 			atomic_inc(&buffermem_pages);
 			return 0;
 		}
@@ -2101,28 +2101,29 @@
 	return 0;
 }
 
-/*
- * Sync all the buffers on one page..
+/**
+ * sync_page_buffers - Sync all the buffers on one page..
+ * @page: page to sync buffers from.
+ * @wait: indicate if we have to wait.
  *
- * If we have old buffers that are locked, we'll
- * wait on them, but we won't wait on the new ones
- * we're writing out now.
+ * If we have old buffers that are locked, we'll wait on them, but we
+ * won't wait on the new ones we're writing out now.  We will wait
+ * only in the last locked buffer.  That means that we will wait once
+ * as maximum.
  *
  * This all is required so that we can free up memory
- * later.
+ * later.  
  */
-static void sync_page_buffers(struct buffer_head *bh, int wait)
+void sync_page_buffers(struct page *page)
 {
-	struct buffer_head * tmp = bh;
+	struct buffer_head *bh = page->buffers;
+	struct buffer_head *tmp = bh;
 
 	do {
 		struct buffer_head *p = tmp;
 		tmp = tmp->b_this_page;
-		if (buffer_locked(p)) {
-			if (wait)
-				__wait_on_buffer(p);
-		} else if (buffer_dirty(p))
-			ll_rw_block(WRITE, 1, &p);
+		if (!buffer_locked(p) && buffer_dirty(p))
+			ll_rw_block(WRITETRY, 1, &p);
 	} while (tmp != bh);
 }
 
@@ -2132,21 +2133,19 @@
 #define BUFFER_BUSY_BITS	((1<<BH_Dirty) | (1<<BH_Lock) | (1<<BH_Protected))
 #define buffer_busy(bh)		(atomic_read(&(bh)->b_count) | ((bh)->b_state & BUFFER_BUSY_BITS))
 
-/*
- * try_to_free_buffers() checks if all the buffers on this particular page
- * are unused, and free's the page if so.
- *
- * Wake up bdflush() if this fails - if we're running low on memory due
- * to dirty buffers, we need to flush them out as quickly as possible.
+/**
+ * try_to_free_buffers - checks if all the buffers on this particular
+ * page are unused, and free's the page if so.
+ * @page: page to free buffers from
  *
- * NOTE: There are quite a number of ways that threads of control can
- *       obtain a reference to a buffer head within a page.  So we must
- *	 lock out all of these paths to cleanly toss the page.
+ * We will test if we can free all the buffers in that page, if that
+ * is true, we free the page, otherwise we return an error code.
  */
-int try_to_free_buffers(struct page * page, int wait)
+int try_to_free_buffers(struct page * page)
 {
 	struct buffer_head * tmp, * bh = page->buffers;
 	int index = BUFSIZE_INDEX(bh->b_size);
+	int ret = 0;
 
 	spin_lock(&lru_list_lock);
 	write_lock(&hash_table_lock);
@@ -2183,18 +2182,13 @@
 	/* And free the page */
 	page->buffers = NULL;
 	page_cache_release(page);
+	ret = 1;
+busy_buffer_page:
 	spin_unlock(&free_list[index].lock);
 	write_unlock(&hash_table_lock);
 	spin_unlock(&lru_list_lock);
-	return 1;
+	return ret;
 
-busy_buffer_page:
-	/* Uhhuh, start writeback so that we don't end up with all dirty pages */
-	spin_unlock(&free_list[index].lock);
-	write_unlock(&hash_table_lock);
-	spin_unlock(&lru_list_lock);	
-	sync_page_buffers(bh, wait);
-	return 0;
 }
 
 /* ================== Debugging =================== */
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/linux/fs.h working/include/linux/fs.h
--- base/include/linux/fs.h	Sat Jul  1 22:13:56 2000
+++ working/include/linux/fs.h	Sun Jul  2 22:41:51 2000
@@ -72,6 +72,7 @@
 #define SPECIAL 4	/* For non-blockdevice requests in request queue */
 
 #define WRITERAW 5	/* raw write - don't play with buffer lists */
+#define WRITETRY 6	/* try to write - don't block if no requests free */
 
 #define NIL_FILP	((struct file *)0)
 #define SEL_IN		1
@@ -920,7 +921,8 @@
 
 extern int fs_may_remount_ro(struct super_block *);
 
-extern int try_to_free_buffers(struct page *, int);
+extern int try_to_free_buffers(struct page *);
+extern void sync_page_buffers(struct page *);
 extern void refile_buffer(struct buffer_head * buf);
 
 #define BUF_CLEAN	0
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/filemap.c working/mm/filemap.c
--- base/mm/filemap.c	Fri Jun 30 18:42:32 2000
+++ working/mm/filemap.c	Mon Jul  3 01:52:55 2000
@@ -245,19 +245,16 @@
 	spin_unlock(&pagecache_lock);
 }
 
-/*
- * nr_dirty represents the number of dirty pages that we will write async
- * before doing sync writes.  We can only do sync writes if we can
- * wait for IO (__GFP_IO set).
- */
+#define MAX_LAUNDER	100
+
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count, nr_dirty;
+	int ret = 0, count;
+	int nr_writes = 0;
 	struct list_head * page_lru;
 	struct page * page = NULL;
-	
+
 	count = nr_lru_pages / (priority + 1);
-	nr_dirty = priority;
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
@@ -294,9 +291,12 @@
 		 * of zone - it's old.
 		 */
 		if (page->buffers) {
-			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
-			if (!try_to_free_buffers(page, wait))
+			if (!try_to_free_buffers(page)) {
+				if ((gfp_mask & __GFP_IO) &&
+				    (nr_writes++ < MAX_LAUNDER))
+					sync_page_buffers(page);
 				goto unlock_continue;
+			}
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
 				atomic_dec(&buffermem_pages);
@@ -370,6 +370,9 @@
 
 out:
 	spin_unlock(&pagemap_lru_lock);
+
+	if (gfp_mask & __GFP_IO)
+		balance_dirty(NODEV);
 
 	return ret;
 }


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
