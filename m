Date: Sun, 8 Aug 1999 20:38:57 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: [patch] care about the age of the pte even if we are low on memory
Message-ID: <Pine.LNX.4.10.9908082020250.29734-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, MOLNAR Ingo <mingo@redhat.com>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I don't know why in the 2.3.x we are swapping out even the young pages.
This is not going to help oom handling at all and it's only reducing of an
order of magnitude the interactive feeling under heavy swapout. I can
notice an huge difference with eyes from clean 2.2.10 to 2.3.13-pre8.

The low_on_memory flag is there only for GFP internals and IMO it
shouldn't be ever looked from other places.

This patch against 2.3.13-pre8 will fix the problem and it will avoid
further mistakes.

diff -urN 2.3.13-pre8/include/linux/mm.h 2.3.13-pre8-low_on_memory/include/linux/mm.h
--- 2.3.13-pre8/include/linux/mm.h	Wed Aug  4 12:28:17 1999
+++ 2.3.13-pre8-low_on_memory/include/linux/mm.h	Sun Aug  8 20:25:58 1999
@@ -292,8 +292,6 @@
 	return page;
 }
 
-extern int low_on_memory;
-
 /* memory.c & swap.c*/
 
 #define free_page(addr) free_pages((addr),0)
diff -urN 2.3.13-pre8/mm/page_alloc.c 2.3.13-pre8-low_on_memory/mm/page_alloc.c
--- 2.3.13-pre8/mm/page_alloc.c	Tue Jul 13 02:02:40 1999
+++ 2.3.13-pre8-low_on_memory/mm/page_alloc.c	Sun Aug  8 20:24:03 1999
@@ -194,8 +194,6 @@
 	set_page_count(map, 1); \
 } while (0)
 
-int low_on_memory = 0;
-
 unsigned long __get_free_pages(int gfp_mask, unsigned long order)
 {
 	unsigned long flags;
@@ -221,6 +219,7 @@
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
 		int freed;
+		static int low_on_memory = 0;
 
 		if (nr_free_pages > freepages.min) {
 			if (!low_on_memory)
diff -urN 2.3.13-pre8/mm/vmscan.c 2.3.13-pre8-low_on_memory/mm/vmscan.c
--- 2.3.13-pre8/mm/vmscan.c	Sun Aug  8 17:21:41 1999
+++ 2.3.13-pre8-low_on_memory/mm/vmscan.c	Sun Aug  8 20:23:19 1999
@@ -54,7 +54,7 @@
 	 * Dont be too eager to get aging right if
 	 * memory is dangerously low.
 	 */
-	if (!low_on_memory && pte_young(pte)) {
+	if (pte_young(pte)) {
 		/*
 		 * Transfer the "accessed" bit from the page
 		 * tables to the global page map.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
