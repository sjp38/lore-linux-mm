Subject: Re: PATCH: Possible solution to VM problems (take 2)
References: <Pine.LNX.4.21.0005161631320.32026-100000@duckman.distro.conectiva>
	<yttvh0evx43.fsf@vexeta.dc.fi.udc.es>
	<yttn1lox5wa.fsf_-_@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "17 May 2000 22:45:25 +0200"
Date: 18 May 2000 01:31:32 +0200
Message-ID: <ytt8zx8wy7f.fsf_-_@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        after discussions with Rik, we have arrived to the conclusions
vs. previous patch that:

1- nr_dirty should be made initialised with priority value, that means
   that for big priorities, we start *quite a lot* of async writes
   before waiting for one page.  And in low priorities, we wait for
   any page, we need memory at any cost.

2- We changed do_try_to_free_pages to return success it it has freed
   some page, not only when we have liberated count pages, that makes
   the system not to kill mmap002 never get killed, 30 minutes test.

The interactive response from the system looks better, but I need to
do more testing on that.  The system time has been reduced also.

Please, can somebody with highmem test this patch, I am very
interested in know if the default values here work there also well.
They should work well, but, who nows.

As always, comments are welcome.

Later, Juan.

PD. You can get my kernel patches from: 
    http://carpanta.dc.fi.udc.es/~quintela/kernel/

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/fs/buffer.c testing/fs/buffer.c
--- pre9-2/fs/buffer.c	Fri May 12 23:46:45 2000
+++ testing/fs/buffer.c	Wed May 17 19:17:27 2000
@@ -1324,7 +1324,7 @@
 	 * instead.
 	 */
 	if (!offset) {
-		if (!try_to_free_buffers(page)) {
+		if (!try_to_free_buffers(page, 0)) {
 			atomic_inc(&buffermem_pages);
 			return 0;
 		}
@@ -2121,14 +2121,14 @@
  * This all is required so that we can free up memory
  * later.
  */
-static void sync_page_buffers(struct buffer_head *bh)
+static void sync_page_buffers(struct buffer_head *bh, int wait)
 {
-	struct buffer_head * tmp;
-
-	tmp = bh;
+	struct buffer_head * tmp = bh;
 	do {
 		struct buffer_head *p = tmp;
 		tmp = tmp->b_this_page;
+		if (buffer_locked(p) && wait)
+			__wait_on_buffer(p);
 		if (buffer_dirty(p) && !buffer_locked(p))
 			ll_rw_block(WRITE, 1, &p);
 	} while (tmp != bh);
@@ -2151,7 +2151,7 @@
  *       obtain a reference to a buffer head within a page.  So we must
  *	 lock out all of these paths to cleanly toss the page.
  */
-int try_to_free_buffers(struct page * page)
+int try_to_free_buffers(struct page * page, int wait)
 {
 	struct buffer_head * tmp, * bh = page->buffers;
 	int index = BUFSIZE_INDEX(bh->b_size);
@@ -2201,7 +2201,7 @@
 	spin_unlock(&free_list[index].lock);
 	write_unlock(&hash_table_lock);
 	spin_unlock(&lru_list_lock);	
-	sync_page_buffers(bh);
+	sync_page_buffers(bh, wait);
 	return 0;
 }
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/include/linux/fs.h testing/include/linux/fs.h
--- pre9-2/include/linux/fs.h	Wed May 17 19:11:51 2000
+++ testing/include/linux/fs.h	Thu May 18 00:44:24 2000
@@ -900,7 +900,7 @@
 
 extern int fs_may_remount_ro(struct super_block *);
 
-extern int try_to_free_buffers(struct page *);
+extern int try_to_free_buffers(struct page *, int);
 extern void refile_buffer(struct buffer_head * buf);
 
 #define BUF_CLEAN	0
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/mm/filemap.c testing/mm/filemap.c
--- pre9-2/mm/filemap.c	Fri May 12 23:46:46 2000
+++ testing/mm/filemap.c	Thu May 18 01:00:39 2000
@@ -246,12 +246,13 @@
 
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count;
+	int ret = 0, count, nr_dirty;
 	LIST_HEAD(old);
 	struct list_head * page_lru, * dispose;
 	struct page * page = NULL;
 	
 	count = nr_lru_pages / (priority + 1);
+	nr_dirty = priority;
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
@@ -303,8 +304,10 @@
 		 * of zone - it's old.
 		 */
 		if (page->buffers) {
-			if (!try_to_free_buffers(page))
-				goto unlock_continue;
+			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty < 0));
+			nr_dirty--;
+			if (!try_to_free_buffers(page, wait))
+					goto unlock_continue;
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
 				atomic_dec(&buffermem_pages);
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/mm/vmscan.c testing/mm/vmscan.c
--- pre9-2/mm/vmscan.c	Tue May 16 00:36:11 2000
+++ testing/mm/vmscan.c	Thu May 18 01:20:20 2000
@@ -363,7 +363,7 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = (nr_threads << 1) >> (priority >> 1);
+	counter = (nr_threads << 2) >> (priority >> 2);
 	if (counter < 1)
 		counter = 1;
 
@@ -435,11 +435,12 @@
 {
 	int priority;
 	int count = FREE_COUNT;
+	int swap_count;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	priority = 6;
+	priority = 64;
 	do {
 		while (shrink_mmap(priority, gfp_mask)) {
 			if (!--count)
@@ -471,12 +472,10 @@
 		 * put in the swap cache), so we must not count this
 		 * as a "count" success.
 		 */
-		{
-			int swap_count = SWAP_COUNT;
-			while (swap_out(priority, gfp_mask))
-				if (--swap_count < 0)
-					break;
-		}
+		swap_count = SWAP_COUNT;
+		while (swap_out(priority, gfp_mask))
+			if (--swap_count < 0)
+				break;
 	} while (--priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
@@ -485,7 +484,7 @@
 			goto done;
 	}
 
-	return 0;
+	return (count != FREE_COUNT);
 
 done:
 	return 1;


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
