Date: Tue, 14 Aug 2001 00:19:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] unlazy page movement
Message-ID: <Pine.LNX.4.33L.0108140017530.6118-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alan,

since the VM balancing just about depends on the fact that
the pages it encounters on the inactive_clean list really
are freeable, here is a small patch to unlazy the queue
movement whenever we touch inactive page cache pages.

Please consider applying for the next -ac kernel.

thanks,

Rik
--
IA64: a worthy successor to i860.


--- filemap.c.orig	Mon Aug 13 14:19:58 2001
+++ filemap.c	Tue Aug 14 00:09:14 2001
@@ -353,8 +353,16 @@
 		if (page->index == offset)
 			break;
 	}
-	/* Mark the page referenced, kswapd will find it later. */
-	SetPageReferenced(page);
+	/*
+	 * Mark the page referenced so kswapd knows to up page->age
+	 * the next VM scan. Make sure to move inactive pages to the
+	 * active list so we don't get a nasty surprise when the pages
+	 * we thought were freeable aren't...
+	 */
+	if (PageActive(page))
+		SetPageReferenced(page);
+	else
+		activate_page(page);

 not_found:
 	return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
