Date: Thu, 28 Dec 2000 12:57:08 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] better drop-behind in generic_file_write
Message-ID: <Pine.LNX.4.21.0012281238480.14052-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Phillips <phillips@innominate.de>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi Linus, Daniel,

the (trivial) patch below fixes the drop-behind call in
generic_file_write to *only* do drop-behind if we've
written "past the end" of the page.

This way we have a better chance of still having partially
written pages in memory when we write to them again (eg. for
TUX logfiles). Not only will this speed up non page-aligned
writes on loaded systems, it'll also give slower writes a
small advantage over fast writes (which will skip page boundaries
more often).

Linus, Alan, could you please apply this patch in your next
2.4.0-test kernel ?

regards,

Rik
--
Hollywood goes for world dumbination,
	Trailer at 11.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/


--- linux-2.4.0-test12-pre3/mm/filemap.c.orig	2000/12/21 18:20:17
+++ linux/mm/filemap.c	2000/12/21 21:31:39
@@ -2436,7 +2436,7 @@
 	}
 
 	while (count) {
-		unsigned long bytes, index, offset;
+		unsigned long bytes, index, offset, partial = 0;
 		char *kaddr;
 
 		/*
@@ -2446,8 +2446,10 @@
 		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
 		index = pos >> PAGE_CACHE_SHIFT;
 		bytes = PAGE_CACHE_SIZE - offset;
-		if (bytes > count)
+		if (bytes > count) {
 			bytes = count;
+			partial = 1;
+		}
 
 		status = -ENOMEM;	/* we'll assign it later anyway */
 		page = __grab_cache_page(mapping, index, &cached_page);
@@ -2478,9 +2480,17 @@
 			buf += status;
 		}
 unlock:
-		/* Mark it unlocked again and drop the page.. */
+		/*
+		 * Mark it unlocked again and release the page.
+		 * In order to prevent large (fast) file writes
+		 * from causing too much memory pressure we move
+		 * completely written pages to the inactive list.
+		 * We do, however, try to keep the pages that may
+		 * still be written to (ie. partially written pages).
+		 */
 		UnlockPage(page);
-		deactivate_page(page);
+		if (!partial)
+			deactivate_page(page);
 		page_cache_release(page);
 
 		if (status < 0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
