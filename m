Date: Mon, 19 Jun 2000 12:36:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] -ac21 don't set referenced bit
Message-ID: <Pine.LNX.4.21.0006191231300.13200-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, los@lsdb.bwl.uni-mannheim.de
List-ID: <linux-mm.kvack.org>

Hi,

the patch below, against -ac21, does two things:

1) do not set the referenced bit when we add a page to
   one of the caches ... this allows us to distinguish
   between pages which are used again and pages which
   aren't   [keeps performance nice in the presence of
   streaming IO?]

2) in do_try_to_free_pages, if we make progress on a
   priority level, do not decrease priority when we loop
   again ... this should allow us to  a) free more pages
   since we can keep looping back as long as progress is
   being made and  b) maybe keep a better balance between
   shrink_mmap and swap_out since we have a better chance
   to never reach the "gimme memory now or I'll rape your
   wife and kill your children" level
   [and we don't want to get there since arriving at that
   priority level means we'll be doing worse page aging
   and forcing the issue ... potentially making things worse
   for the next time]

With this patch I'm seeing higher application performance and
lower kswapd cpu usage...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- mm/filemap.c.orig	Mon Jun 19 11:32:32 2000
+++ mm/filemap.c	Mon Jun 19 11:33:21 2000
@@ -564,7 +564,7 @@
 
 /*
  * This adds a page to the page cache, starting out as locked,
- * owned by us, referenced, but not uptodate and with no errors.
+ * owned by us, but not uptodate and with no errors.
  */
 static inline void __add_to_page_cache(struct page * page,
 	struct address_space *mapping, unsigned long offset,
@@ -576,8 +576,8 @@
 	if (PageLocked(page))
 		BUG();
 
-	flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty));
-	page->flags = flags | (1 << PG_locked) | (1 << PG_referenced);
+	flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error));
+	page->flags = flags | (1 << PG_locked);
 	page_cache_get(page);
 	page->index = offset;
 	add_page_to_inode_queue(mapping, page);
--- mm/swap_state.c.orig	Mon Jun 19 11:32:32 2000
+++ mm/swap_state.c	Mon Jun 19 11:33:59 2000
@@ -58,8 +58,8 @@
 		BUG();
 	if (page->mapping)
 		BUG();
-	flags = page->flags & ~((1 << PG_error) | (1 << PG_dirty));
-	page->flags = flags | (1 << PG_referenced) | (1 << PG_uptodate);
+	flags = page->flags & ~(1 << PG_error);
+	page->flags = flags | (1 << PG_uptodate);
 	add_to_page_cache_locked(page, &swapper_space, entry.val);
 }
 
--- mm/vmscan.c.orig	Mon Jun 19 11:32:32 2000
+++ mm/vmscan.c	Mon Jun 19 11:47:10 2000
@@ -444,6 +444,7 @@
 	int priority;
 	int count = FREE_COUNT;
 	int swap_count = 0;
+	int made_progress = 0;
 	int ret = 0;
 
 	/* Always trim SLAB caches when memory gets low. */
@@ -452,7 +453,7 @@
 	priority = 64;
 	do {
 		while (shrink_mmap(priority, gfp_mask)) {
-			ret = 1;
+			made_progress = 1;
 			if (!--count)
 				goto done;
 		}
@@ -468,11 +469,11 @@
 			count -= shrink_dcache_memory(priority, gfp_mask);
 			count -= shrink_icache_memory(priority, gfp_mask);
 			if (count <= 0) {
-				ret = 1;
+				made_progress = 1;
 				goto done;
 			}
 			while (shm_swap(priority, gfp_mask)) {
-				ret = 1;
+				made_progress = 1;
 				if (!--count)
 					goto done;
 			}
@@ -493,11 +494,25 @@
 		 */
 		swap_count += count;
 		while (swap_out(priority, gfp_mask)) {
+			made_progress = 1;
 			if (--swap_count < 0)
 				break;
 		}
 
-	} while (--priority >= 0);
+		/*
+		 * If we made progress at the current priority, the next
+		 * loop will also be done at this priority level. There's
+		 * absolutely no reason to drop to a lower priority and
+		 * potentially upset the balance between shrink_mmap and
+		 * swap_out.
+		 */
+		if (made_progress) {
+			made_progress = 0;
+			ret = 1;
+		} else {
+			priority--;
+		}
+	} while (priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
 	while (shrink_mmap(0, gfp_mask)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
