Date: Thu, 11 Jul 2002 17:08:12 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] small rmap bugfix
Message-ID: <Pine.LNX.4.44L.0207111705480.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I just ran into a bad piece of code in the rmap patch Andrew
has been testing recently. It's possible for pages that were
truncated to still have their bufferheads _and_ be mapped in
the pagetables of processes.

In that case a piece of code in shrink_cache would remove
that page from the LRU ... in effect making it unswappable.

Since the lru_cache_del() is called from page_cache_release()
anyway we can fix the bug by dropping this obsolete piece of
code.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/


===== mm/vmscan.c 1.81 vs edited =====
--- 1.81/mm/vmscan.c	Fri Jul  5 22:31:52 2002
+++ edited/mm/vmscan.c	Thu Jul 11 17:01:00 2002
@@ -235,19 +235,11 @@

 			if (try_to_release_page(page, gfp_mask)) {
 				if (!mapping) {
-					/*
-					 * We must not allow an anon page
-					 * with no buffers to be visible on
-					 * the LRU, so we unlock the page after
-					 * taking the lru lock
-					 */
-					spin_lock(&pagemap_lru_lock);
-					unlock_page(page);
-					__lru_cache_del(page);
-
 					/* effectively free the page here */
+					unlock_page(page);
 					page_cache_release(page);

+					spin_lock(&pagemap_lru_lock);
 					if (--nr_pages)
 						continue;
 					break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
