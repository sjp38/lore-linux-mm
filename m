Date: Thu, 8 Jun 2000 03:16:36 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: [PATCH] page aging for 2.2.16
Message-ID: <20000608031635.A353@acs.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

This patch seems to significantly improve the interactive
performance of 2.2.16.  Without the patch XMMS and the mouse
pointer will stop responding for seconds at a time while running
Bonnie.  With the patch everything is smooth.

I timed a kernel compile with -j 20 to test the cost of the
aging.  It does not seem to make a significant difference (3
seconds slower).  Bonnie reports slightly higher IO figures
with the patch.  I don't think the change is significant.

Comments appreciated.

    Neil

-- 
"If you're a great programmer, you make all the routines depend on each
other, so little mistakes can really hurt you." -- Bill Gates, ca. 1985.


diff -ru linux-2.2/include/linux/mm.h linux-age/include/linux/mm.h
--- linux-2.2/include/linux/mm.h	Thu Jun  8 00:30:02 2000
+++ linux-age/include/linux/mm.h	Thu Jun  8 01:49:42 2000
@@ -129,7 +129,11 @@
 	struct wait_queue *wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
+	int age;
 } mem_map_t;
+
+#define PAGE_AGE_INITIAL 1	/* age for pages just mapped */
+#define PAGE_AGE_YOUNG 2	/* age for pages recently referenced */
 
 /* Page flag bit values */
 #define PG_locked		 0
diff -ru linux-2.2/mm/filemap.c linux-age/mm/filemap.c
--- linux-2.2/mm/filemap.c	Thu Jun  8 00:30:26 2000
+++ linux-age/mm/filemap.c	Thu Jun  8 01:44:16 2000
@@ -147,8 +147,6 @@
 
 	page = mem_map + clock;
 	do {
-		int referenced;
-
 		/* This works even in the presence of PageSkip because
 		 * the first two entries at the beginning of a hole will
 		 * be marked, not just the first.
@@ -165,12 +163,20 @@
 			clock = page - mem_map;
 		}
 		
+		if (test_and_clear_bit(PG_referenced, &page->flags)) {
+			page->age = PAGE_AGE_YOUNG;
+			continue;
+		}
+
+		if (page->age > 0) {
+			page->age--;
+			continue;
+		}
+
 		/* We can't free pages unless there's just one user */
 		if (atomic_read(&page->count) != 1)
 			continue;
 
-		referenced = test_and_clear_bit(PG_referenced, &page->flags);
-
 		if (PageLocked(page))
 			continue;
 
@@ -179,20 +185,11 @@
 
 		count--;
 
-		/*
-		 * Is it a page swap page? If so, we want to
-		 * drop it if it is no longer used, even if it
-		 * were to be marked referenced..
-		 */
+		/* Is it a page swap page? Drop it, its old. */
 		if (PageSwapCache(page)) {
-			if (referenced && swap_count(page->offset) != 1)
-				continue;
 			delete_from_swap_cache(page);
 			return 1;
 		}	
-
-		if (referenced)
-			continue;
 
 		/* Is it a buffer page? */
 		if (page->buffers) {
diff -ru linux-2.2/mm/page_alloc.c linux-age/mm/page_alloc.c
--- linux-2.2/mm/page_alloc.c	Thu Jun  8 00:30:26 2000
+++ linux-age/mm/page_alloc.c	Thu Jun  8 01:49:50 2000
@@ -129,6 +129,7 @@
 		if (PageSwapCache(page))
 			panic ("Freeing swap cache page");
 		page->flags &= ~(1 << PG_referenced);
+		page->age = PAGE_AGE_INITIAL;
 		free_pages_ok(page - mem_map, order, PageDMA(page) ? 1 : 0);
 		return;
 	}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
