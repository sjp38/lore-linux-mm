Date: Tue, 5 Jun 2001 16:48:46 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] reapswap for 2.4.5-ac10
Message-ID: <Pine.LNX.4.21.0106051646570.2997-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: =?ISO-8859-1?Q?Andr=E9_Dahlqvist?= <anedah-9@sm.luth.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alan, 

I'm resending the reapswap patch for inclusion into -ac series. 

--- linux.orig/mm/vmscan.c	Wed May 30 14:51:21 2001
+++ linux/mm/vmscan.c	Wed May 30 16:18:41 2001
@@ -461,6 +461,28 @@
 			continue;
 		}
 
+		/*
+		 * FIXME: this is a hack.
+		 *
+		 * Check for dead swap cache pages and clean
+		 * them as fast as possible, before doing any other checks.
+		 *
+		 * Note: We are guaranteeing that this page will never 
+		 * be touched in the future because a dirty page with no
+		 * other users than the swapcache will never be referenced
+		 * again.
+		 * 
+		 */
+
+		if (PageSwapCache(page) && PageDirty(page) &&
+				(page_count(page) - !!page->buffers) == 1 &&
+				swap_count(page) == 1) { 
+			ClearPageDirty(page);
+			ClearPageReferenced(page);
+			page->age = 0;
+		}
+
+			
 		/* Page is or was in use?  Move it to the active list. */
 		if (PageReferenced(page) || page->age > 0 ||
 				(!page->buffers && page_count(page) > 1) ||
@@ -686,6 +708,21 @@
 			nr_active_pages--;
 			continue;
 		}
+		
+		/*
+		 * FIXME: hack
+		 *
+		 * Special case for dead swap cache pages.
+		 * See comment on page_launder() for more info.
+		 */
+		if (PageSwapCache(page) && PageDirty(page) &&
+				(page_count(page) - !!page->buffers) == 1 &&
+				swap_count(page) == 1) {
+			deactivate_page_nolock(page);
+			nr_deactivated++;
+			continue;
+		}
+
 
 		/* Do aging on the pages. */
 		if (PageTestandClearReferenced(page)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
