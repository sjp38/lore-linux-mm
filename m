Subject: PATCH: Balancing patch against pre9-3
References: <Pine.LNX.4.10.10005211005430.1320-100000@penguin.transmeta.com>
From: "Quintela Carreira Juan J." <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Sun, 21 May 2000 10:15:42 -0700 (PDT)"
Date: 22 May 2000 13:27:54 +0200
Message-ID: <ytthfbqakp1.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

        I have finished the port of the patch to pre9-3.  My stability
problems yesterday was related to a bad patch applied by hand :(
(Yes I am porting a brown paper bag in my head).

Linus, you had applied almost all the patch, the remaining parts are:
       
- the use of the nr_dirty counter.  It counts the number of dirty
  pages that we are allowed to write asynchronously before we wait for
  completion.  Notice also that we are waiting only if __GFP_IO is
  set.  We initialize that variable to the priority.  This means that
  with high priorities, we will almost never wait, but with lower
  priorities (high VM pressure) we will wait almost for all pages.
  This looks to me as the correct behavior.
  
- We start do_try_to_free_pages with a *high* priority.  In my tests
  here (I have posted the numbers in previous posts), shown that with
  a priority of 64, we allocate almost always at that priority, then
  we need to wait for less pages, which means lower latency.  The other
  advantage of having a high priority is that we will push less hard
  shrink_mmap, and we will call swap_out sooner.  The last thing is no
  bad as we call swap_out sooner, but with a high_priority, which means
  that it will try to free few pages.

- Rik suggested (and I agree) that in swap_out we must *try* harder to
  swap_out pages if we are in low priorities.  That is the effect of
  the change in the counter calculation in swap_out.

- In do_try_to_free_pages, we return success if we have freed some
  page, not only if we have freed FREE_COUNT pages.  That solved the
  last problems with mmap002 been killed in pre9-2.  I have changed
  SWAP_COUNT to 16. In some of my experiments showed that only
  increasing the value of SWAP_COUNT improved the behavior of the
  system.  I think that the problem here is that under high VM
  pressure, we try to swap the same number of pages that we will try
  to free, and people reference that pages while we are waiting, or
  other processes steal our pages.  Other thougths on that?

- I have been studying which processes are swapped, and with this
  patch all the processes except the used ones are swapped.  Here xfs
  (font manager) is swapped out (it gets only one page 4k in memory).
  Ben, could you test that it also swaps xfs-tt pages?

- The problem of the stalls continue, we have stalls from time to
  time, basically when we have all the memory used by the page
  cache with dirty pages (i.e. mmap002 running alone in the machine).
  I know that this is a pathological case, but the stalls are
  sometimes as big as 5 seconds.  This case appears not to be as
  pathological as thought, people from multimedia are reporting
  similar problems, and people with big writes (dd a cdrom and
  similar are noting similar problems).  I am studying that problem.

Comments?

Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-3/mm/filemap.c testing/mm/filemap.c
--- pre9-3/mm/filemap.c	Sun May 21 17:38:02 2000
+++ testing/mm/filemap.c	Mon May 22 13:05:36 2000
@@ -244,13 +244,19 @@
 	spin_unlock(&pagecache_lock);
 }
 
+/*
+ * nr_dirty represents the number of dirty pages that we will write async
+ * before doing sync writes.  We can only do sync writes if we can
+ * wait for IO (__GFP_IO set).
+ */
 int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0, count;
+	int ret = 0, count, nr_dirty;
 	struct list_head * page_lru;
 	struct page * page = NULL;
 	
 	count = nr_lru_pages / (priority + 1);
+	nr_dirty = priority;
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
@@ -287,7 +293,8 @@
 		 * of zone - it's old.
 		 */
 		if (page->buffers) {
-			if (!try_to_free_buffers(page, 1))
+			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
+			if (!try_to_free_buffers(page, wait))
 				goto unlock_continue;
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-3/mm/vmscan.c testing/mm/vmscan.c
--- pre9-3/mm/vmscan.c	Sun May 21 17:38:03 2000
+++ testing/mm/vmscan.c	Mon May 22 13:10:38 2000
@@ -363,7 +363,7 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = (nr_threads << 1) >> (priority >> 1);
+	counter = (nr_threads << 2) >> (priority >> 2);
 	if (counter < 1)
 		counter = 1;
 
@@ -430,16 +430,17 @@
  * latency.
  */
 #define FREE_COUNT	8
-#define SWAP_COUNT	8
+#define SWAP_COUNT	16
 static int do_try_to_free_pages(unsigned int gfp_mask)
 {
 	int priority;
 	int count = FREE_COUNT;
+	int swap_count;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	priority = 32;
+	priority = 64;
 	do {
 		while (shrink_mmap(priority, gfp_mask)) {
 			if (!--count)
@@ -471,12 +472,11 @@
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
+
 	} while (--priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
@@ -484,8 +484,8 @@
 		if (!--count)
 			goto done;
 	}
-
-	return 0;
+	/* We return 1 if we are freed some page */
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
