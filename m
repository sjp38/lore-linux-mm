Date: Wed, 20 Jun 2001 23:13:46 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] Avoid !__GFP_IO allocations to eat from memory reservations
Message-ID: <Pine.LNX.4.21.0106202310430.13933-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

I just read pre3<->pre4 diff and it seems you missed this patch... here it
goes again.

In pre3/4, GFP_BUFFER allocations can eat from the "emergency" memory
reservations in case try_to_free_pages() fails for those allocations in
__alloc_pages().


Here goes the (tested) patch to fix that:


--- linux/mm/page_alloc.c.orig	Thu Jun 14 11:00:14 2001
+++ linux/mm/page_alloc.c	Thu Jun 14 11:32:56 2001
@@ -453,6 +453,12 @@
 				int progress = try_to_free_pages(gfp_mask);
 				if (progress || gfp_mask & __GFP_IO)
 					goto try_again;
+				/*
+				 * Fail in case no progress was made and the
+				 * allocation may not be able to block on IO.
+				 */
+				else
+					return NULL;
 			}
 		}
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
