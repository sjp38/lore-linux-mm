Subject: PATCH: Possible solution to VM problems
References: <Pine.LNX.4.21.0005161631320.32026-100000@duckman.distro.conectiva>
	<yttvh0evx43.fsf@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "17 May 2000 02:28:12 +0200"
Date: 17 May 2000 22:45:25 +0200
Message-ID: <yttn1lox5wa.fsf_-_@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        I have done the following modifications to yesterday patch:

- I didn't remove the free_before_allocate patch form Rik, it appears
  to work well here.
- I *fix* the nr_dirty test in yesterday patch, the sense of
  the test was reversed.
- I have change in the calculation of counter in do_try_to_free_pages,
  the suggestion came from Rik.
- I have changed the priority to 64.
 
The change of the priority means that we call shrink_mmap with
smaller count and that we also try to swap_out thinks sooner, this
gives the system smoother behaviour.  I have measured the priority
with witch we obtained one page.  The values are for a UP K6-300 with
98MB of ram running mmap002 in a loop.  The data was collected for all
the calls to do_try_to_free_page during 2 and a half hours.
     - do_try_to_free_pages failed to free pages 5 times
     - It killed 2 processes (mmap002)
     - number of calls to do_try_to_free_pages: 137k
     - calls succeed with priority = 64:         58k
     - calls succeed with priority = 63:         40k
     - calls succeed with priority = 6x:        125k
     - calls succeed with priority = 5x:          9k
     - calls succeed with priority = 4x:          1.5k
     - calls succeed with priority = 3x:          0.8k
     - calls succeed with priority = 2x:          0.4k
     - calls succeed with priority = 1x:             16
     - calls succeed with priority < 10:              6
     - calls failed:                                  5

This shows us that we have almost alway pages "freeable" indeed with a
memory *hog* like mmap002.  With this patch the killed processes
problem is _almost_ solved.

It remains the problem of the slowdown, the vmstat 1 stops from time
to time over 8 seconds, typical output is that:

   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  1  1   4096   1628     92  89744   0   4  2968  2233  332   176   3  12  86
 1  0  0   4184   1520    316  83652 596 112  1160 84735 6963  4814   0  14  85
 1  0  0   4196   1696    332  80852  12  36  2949     9  185   153  15  17  68


the stall is between 1st and 2nd line, notice that we have liberated
3MB of page cache, but we are also read a bit (1160) and me have wrote
a lot (84k).  I have notice that almost all the stalls are of size
~80k or ~40k.  This thing is easy to reproduce, when you run the first
time mmap002 it will stop vmstat output just in the moment that it
begins to swap (no more free memory).  After that it happens from time
to time, not too many times, i.e. each 4/5 runs of mmap002.

Other thing that appears to be solved is the kswapd using too much
CPU.  Here it uses 1m55second in a 45minutes mmap002 testing.

Could the people having problems with memory in 2.3.99-prex, test this
patch and report his experiences?  Thanks.

Comments?

Later, Juan.

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
+++ testing/include/linux/fs.h	Wed May 17 19:20:05 2000
@@ -900,7 +900,7 @@
 
 extern int fs_may_remount_ro(struct super_block *);
 
-extern int try_to_free_buffers(struct page *);
+extern int try_to_free_buffers(struct page *, int);
 extern void refile_buffer(struct buffer_head * buf);
 
 #define BUF_CLEAN	0
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-2/mm/filemap.c testing/mm/filemap.c
--- pre9-2/mm/filemap.c	Fri May 12 23:46:46 2000
+++ testing/mm/filemap.c	Wed May 17 20:03:02 2000
@@ -246,12 +246,13 @@
 
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count;
+	int ret = 0, count, nr_dirty;
 	LIST_HEAD(old);
 	struct list_head * page_lru, * dispose;
 	struct page * page = NULL;
 	
 	count = nr_lru_pages / (priority + 1);
+	nr_dirty = 10; /* magic number */
 
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
+++ testing/mm/vmscan.c	Wed May 17 21:03:30 2000
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
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	priority = 6;
+	priority = 64;
 	do {
 		while (shrink_mmap(priority, gfp_mask)) {
 			if (!--count)

 



-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
