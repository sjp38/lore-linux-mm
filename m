Date: Fri, 28 Apr 2000 20:21:04 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [PATCH] 2.3.99-pre6 vm fix
Message-ID: <Pine.LNX.4.21.0004281938300.3919-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Linus,

here's a patch against 2.3.99-pre6 that fixes the stability problem
(apparently it was possible for a process to "slip through" the
tests in swap_out() and end up with a swap_cnt of 0 which would mean
an infinite loop in the leftshifting loop).

It also fixes a correctness issue in kswapd. Kswapd would exit
after one call to do_try_to_free_pages(), even if there was still
a lot of work to do. Now kswapd will play again if there are still
a lot of pages to free.

The performance problem isn't 100% fixed yet, but the other two
things are important enough that I thought I'd send the patch
now instead of after the (extra long) weekend.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.3.99-pre6/mm/filemap.c.orig	Thu Apr 27 12:49:05 2000
+++ linux-2.3.99-pre6/mm/filemap.c	Fri Apr 28 19:49:01 2000
@@ -238,14 +238,13 @@
 
 int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
 {
-	int ret = 0, loop = 0, count;
+	int ret = 0, count;
 	LIST_HEAD(young);
 	LIST_HEAD(old);
 	LIST_HEAD(forget);
 	struct list_head * page_lru, * dispose;
 	struct page * page = NULL;
 	struct zone_struct * p_zone;
-	int maxloop = 256 >> priority;
 	
 	if (!zone)
 		BUG();
@@ -262,30 +261,26 @@
 		list_del(page_lru);
 		p_zone = page->zone;
 
-		/*
-		 * These two tests are there to make sure we don't free too
-		 * many pages from the "wrong" zone. We free some anyway,
-		 * they are the least recently used pages in the system.
-		 * When we don't free them, leave them in &old.
-		 */
-		dispose = &old;
-		if (p_zone != zone && (loop > (maxloop / 4) ||
-				p_zone->free_pages > p_zone->pages_high))
-			goto dispose_continue;
+		/* This LRU list only contains a few pages from the system,
+		 * so we must fail and let swap_out() refill the list if
+		 * there aren't enough freeable pages on the list */
 
 		/* The page is in use, or was used very recently, put it in
 		 * &young to make sure that we won't try to free it the next
 		 * time */
 		dispose = &young;
-
 		if (test_and_clear_bit(PG_referenced, &page->flags))
 			goto dispose_continue;
 
-		count--;
+		if (p_zone->free_pages > p_zone->pages_high)
+			goto dispose_continue;
+
 		if (!page->buffers && page_count(page) > 1)
 			goto dispose_continue;
 
-		/* Page not used -> free it; if that fails -> &old */
+		count--;
+		/* Page not used -> free it or put it on the old list
+		 * so it gets freed first the next time */
 		dispose = &old;
 		if (TryLockPage(page))
 			goto dispose_continue;
@@ -375,9 +370,8 @@
 	/* nr_lru_pages needs the spinlock */
 	nr_lru_pages--;
 
-	loop++;
 	/* wrong zone?  not looped too often?    roll again... */
-	if (page->zone != zone && loop < maxloop)
+	if (page->zone != zone && count)
 		goto again;
 
 out:
--- linux-2.3.99-pre6/mm/page_alloc.c.orig	Thu Apr 27 12:57:20 2000
+++ linux-2.3.99-pre6/mm/page_alloc.c	Fri Apr 28 12:29:08 2000
@@ -285,9 +285,11 @@
 		goto allocate_ok;
 
 	/* If we're a memory hog, unmap some pages */
-	if (current->hog && low_on_memory &&
-			(gfp_mask & __GFP_WAIT))
-		swap_out(4, gfp_mask);
+	if (current->hog && low_on_memory && (gfp_mask & __GFP_WAIT)) {
+	//	swap_out(6, gfp_mask);
+	//	shm_swap(6, gfp_mask, (zone_t *)(zone));
+		try_to_free_pages(gfp_mask, (zone_t *)(zone));
+	}
 
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
--- linux-2.3.99-pre6/mm/vmscan.c.orig	Thu Apr 27 12:57:58 2000
+++ linux-2.3.99-pre6/mm/vmscan.c	Fri Apr 28 19:43:37 2000
@@ -387,8 +387,8 @@
 				if (!p->swappable || !mm || mm->rss <= 0)
 					continue;
 				/* small processes are swapped out less */
-				while ((mm->swap_cnt << 2 * (i + 1) < max_cnt))
-					i++;
+				while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
+						&& i++ < 10)
 				mm->swap_cnt >>= i;
 				mm->swap_cnt += i; /* if swap_cnt reaches 0 */
 				/* we're big -> hog treatment */
@@ -437,14 +437,13 @@
 {
 	int priority;
 	int count = SWAP_CLUSTER_MAX;
-	int ret;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
 	priority = 6;
 	do {
-		while ((ret = shrink_mmap(priority, gfp_mask, zone))) {
+		while (shrink_mmap(priority, gfp_mask, zone)) {
 			if (!--count)
 				goto done;
 		}
@@ -467,9 +466,7 @@
 			}
 		}
 
-		/* Then, try to page stuff out..
-		 * We use swapcount here because this doesn't actually
-		 * free pages */
+		/* Then, try to page stuff out.. */
 		while (swap_out(priority, gfp_mask)) {
 			if (!--count)
 				goto done;
@@ -530,12 +527,16 @@
 		pgdat = pgdat_list;
 		while (pgdat) {
 			for (i = 0; i < MAX_NR_ZONES; i++) {
-				zone = pgdat->node_zones + i;
+			    int count = SWAP_CLUSTER_MAX;
+			    zone = pgdat->node_zones + i;
+			    do {
 				if (tsk->need_resched)
 					schedule();
 				if ((!zone->size) || (!zone->zone_wake_kswapd))
 					continue;
 				do_try_to_free_pages(GFP_KSWAPD, zone);
+			   } while (zone->free_pages < zone->pages_low &&
+					   --count);
 			}
 			pgdat = pgdat->node_next;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
