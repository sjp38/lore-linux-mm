Date: Tue, 21 Aug 2001 21:18:40 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] fix page_launder() reactivation
Message-ID: <Pine.LNX.4.33L.0108212111250.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alan,

here's a quick fix to make page_launder() not move
pages under ->writepage() back to the active list.

regards,

Rik
--
IA64: a worthy successor to i860.


--- linux-2.4.8-ac8/mm/vmscan.c.orig	Tue Aug 21 21:10:03 2001
+++ linux-2.4.8-ac8/mm/vmscan.c	Tue Aug 21 21:11:05 2001
@@ -529,7 +529,7 @@
 		/* Page is or was in use?  Move it to the active list. */
 		if (PageReferenced(page) || page->age > 0 ||
 				page_count(page) > (1 + !!page->buffers) ||
-				page_ramdisk(page)) {
+				page_ramdisk(page) && !PageLocked(page)) {
 			del_page_from_inactive_dirty_list(page);
 			add_page_to_active_list(page);
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
