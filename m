Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: [RFC] Accelerate dbench
Date: Sun, 5 Aug 2001 02:04:59 +0200
MIME-Version: 1.0
Message-Id: <01080502045901.00315@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

This simple patch to 2.4.8-pre4 accelerates dbench quite spectacularly
for me.  It also slows down my more realistic make+grep load, so it's
not generally a good thing, but... if we could detect the conditions
where this activation strategy is desirable, it could turn into a good
thing.

This doesn't address any burning issue at the moment, it's just for
comment.  Note that it effectively turns check_used_once into a no-op.

The effect of the patch is to always activate pages when they are
successfully looked up, not when first created.  This allows unused
readahead pages to be quickly reclaimed.  (Buffer pages could easily
be treated the same way but I didn't try it.)  Together with -pre4's
shorter IO queue (also probably not a good thing, as Linus pointed
out) this seems to be very friendly to dbench, for reasons I still
don't understand.

With this patch, I saw very large flucuations in the timings obtained
from dbench 12 on this 64 MB Vaio, but the times ranged from good to
excellent, varying by about 30%.  This is with identical running
conditions, starting from a clean reboot each time, and mkfs'ing the
test partition.  Go figure.  As always, the best dbench times were
associated with very unfair scheduling, with frequent bursts where a
single process makes rapid progress and the others appear to be
pushed aside.

--- ../2.4.7.clean/mm/filemap.c	Sat Aug  4 14:27:16 2001
+++ ./mm/filemap.c	Sat Aug  4 14:32:51 2001
@@ -307,9 +307,9 @@
 		if (page->index == offset)
 			break;
 	}
-	/* Mark the page referenced, kswapd will find it later. */
 	SetPageReferenced(page);
-
+	if (!PageActive(page))
+		activate_page(page);
 not_found:
 	return page;
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
