Message-Id: <200108231933.f7NJX8j21551@mailc.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Upd: [PATCH NG] alloc_pages_limit & pages_min
Date: Thu, 23 Aug 2001 21:28:44 +0200
References: <Pine.LNX.4.33L.0108231600020.31410-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108231600020.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, alan.cox@redhat.com
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Riel convinced be to back off a part of the patch.
Here comes an updated one.

-- 
Roger Larsson
Skelleftea
Sweden

*******************************************
Patch prepared by: roger.larsson@norran.net
Name of file: linux-2.4.8-pre3-pages_min-R3

--- linux/mm/page_alloc.c.orig  Thu Aug 23 19:58:55 2001
+++ linux/mm/page_alloc.c       Thu Aug 23 21:19:20 2001
@@ -253,11 +253,26 @@

                if (z->free_pages + z->inactive_clean_pages >= water_mark) {
                        struct page *page = NULL;
-                       /* If possible, reclaim a page directly. */
-                       if (direct_reclaim)
+
+                       /*
+                        * Reclaim a page from the inactive_clean list.
+                        * If needed, refill the free list up to the
+                        * low water mark.
+                        */
+                       if (direct_reclaim) {
                                page = reclaim_page(z);
-                       /* If that fails, fall back to rmqueue. */
-                       if (!page)
+
+                               while (page && z->free_pages < z->pages_min) {
+                                       __free_page(page);
+                                       page = reclaim_page(z);
+                               }
+
+                               /* let kreclaimd handle up to pages_high */
+                       }
+                       /* If that fails, fall back to rmqueue, but never let
+                       *  free_pages go below pages_min...
+                       */
+                       if (!page && z->free_pages >= z->pages_min)
                                page = rmqueue(z, order);
                        if (page)
                                return page;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
