Date: Wed, 18 Aug 1999 19:23:16 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: [patch] rw_swap_page_nocache dead
Message-ID: <Pine.LNX.4.10.9908181921520.16546-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

rw_swap_page_nocache seems dead code to me. I can compile shm/swapfile.o
fine even without it.

diff -ur 2.3.14-pre1/include/linux/swap.h 2.3.14-pre1-page_io/include/linux/swap.h
--- 2.3.14-pre1/include/linux/swap.h	Wed Aug 18 17:44:42 1999
+++ 2.3.14-pre1-page_io/include/linux/swap.h	Wed Aug 18 19:13:07 1999
@@ -85,7 +85,6 @@
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);
-extern void rw_swap_page_nocache(int, unsigned long, char *);
 extern void rw_swap_page_nolock(int, unsigned long, char *, int);
 extern void swap_after_unlock_page (unsigned long entry);
 
diff -ur 2.3.14-pre1/mm/page_io.c 2.3.14-pre1-page_io/mm/page_io.c
--- 2.3.14-pre1/mm/page_io.c	Thu Aug 12 02:53:25 1999
+++ 2.3.14-pre1-page_io/mm/page_io.c	Wed Aug 18 19:12:52 1999
@@ -170,24 +170,6 @@
 }
 
 /*
- * Setting up a new swap file needs a simple wrapper just to read the 
- * swap signature.  SysV shared memory also needs a simple wrapper.
- */
-void rw_swap_page_nocache(int rw, unsigned long entry, char *buf)
-{
-	struct page *page = mem_map + MAP_NR(buf);
-	
-	if (TryLockPage(page))
-		PAGE_BUG(page);
-	if (PageSwapCache(page))
-		PAGE_BUG(page);
-	if (page->inode)
-		PAGE_BUG(page);
-	page->offset = entry;
-	rw_swap_page_base(rw, entry, page, 1, 1);
-}
-
-/*
  * shmfs needs a version that doesn't put the page in the page cache!
  * The swap lock map insists that pages be in the page cache!
  * Therefore we can't use it.  Later when we can remove the need for the

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
