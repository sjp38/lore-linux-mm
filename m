Date: Mon, 20 Aug 2001 11:42:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 
Message-ID: <Pine.LNX.4.33L.0108201133550.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alan,

the following patch fixes reclaim_page() and page_launder() to
correctly reactivate a page based one page->count value.

Note that we shouldn't be hitting this code very much with the
current immediate reactivation in __find_page_nolock(), but I
guess it would be useful to have as a safety net against things
like the shmem code and other areas I don't about ;)

regards,

Rik
--
IA64: a worthy successor to i860.


--- linux-2.4.8-ac7/mm/vmscan.c.orig	Mon Aug 20 11:29:24 2001
+++ linux-2.4.8-ac7/mm/vmscan.c	Mon Aug 20 11:30:46 2001
@@ -456,7 +456,7 @@

 		/* Page is or was in use?  Move it to the active list. */
 		if (PageReferenced(page) || page->age > 0 ||
-				(!page->buffers && page_count(page) > 1)) {
+				page_count(page) > (1 + !!page->buffers)) {
 			del_page_from_inactive_clean_list(page);
 			add_page_to_active_list(page);
 			continue;
@@ -594,7 +594,7 @@

 		/* Page is or was in use?  Move it to the active list. */
 		if (PageReferenced(page) || page->age > 0 ||
-				(!page->buffers && page_count(page) > 1) ||
+				page_count(page) > (1 + !!page->buffers) ||
 				page_ramdisk(page)) {
 			del_page_from_inactive_dirty_list(page);
 			add_page_to_active_list(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
