Received: from there (h164n1fls31o925.telia.com [213.65.254.164])
	by maild.telia.com (8.11.2/8.11.0) with SMTP id f7MNoZp17510
	for <linux-mm@kvack.org>; Thu, 23 Aug 2001 01:50:35 +0200 (CEST)
Message-Id: <200108222350.f7MNoZp17510@maild.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: [PATCH NG] alloc_pages_limit & pages_min
Date: Thu, 23 Aug 2001 01:46:12 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[Note: not tested yet... but it might be hard to trigger]

After discussions with Riel and some additions...

* The original code had a little bug in those cases when
- kreclaimd were not allowed to run for a LONG time...
Lots of kernel activity, RT tasks, or code running
around for a long time allocating memory.
- there were lots of inactive clean pages
- pages were allocated without direct_reclaim (higher order)
(networking might be one candidate)
it could result in using up ALL free pages!

This patch tries to prevent this situation in several ways:
1) Do not allow to alloc a free page when they are critically low.
   [last line of patch]

2) If direct reclaims are allowed do some additional work.
 reclaim & free until pages_min,
 alloc one page,
 reclaim and free until pages_low

Q) Nothing is done to force execution of kreclaimd, if no process
    that can direct_reclaim allocs a page - what will happen then?
    [unlikely but...]

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden


*******************************************
Patch prepared by: roger.larsson@norran.net with comments from Riel

--- linux/mm/page_alloc.c.orig	Wed Aug 22 13:36:57 2001
+++ linux/mm/page_alloc.c	Thu Aug 23 01:15:17 2001
@@ -253,11 +253,35 @@
 
 		if (z->free_pages + z->inactive_clean_pages >= water_mark) {
 			struct page *page = NULL;
-			/* If possible, reclaim a page directly. */
-			if (direct_reclaim)
+
+			/*
+			 * Reclaim a page from the inactive_clean list.
+			 * If needed, refill the free list up to the
+			 * low water mark.
+			 */
+			if (direct_reclaim) {
 				page = reclaim_page(z);
-			/* If that fails, fall back to rmqueue. */
-			if (!page)
+
+				while (page && z->free_pages < z->pages_min) {
+					__free_page(page);
+					page = reclaim_page(z);
+				}
+
+				if (page) {
+					while (z->free_pages < z->pages_low) {
+						struct page *extra = reclaim_page(z);
+						if (!extra)
+							break;
+						__free_page(extra);
+					}
+				}
+
+				/* let kreclaimd handle up to pages_high */
+			}
+			/* If that fails, fall back to rmqueue, but never let
+			*  free_pages go below pages_min...
+			*/
+			if (!page && z->free_pages >= z->pages_min)
 				page = rmqueue(z, order);
 			if (page)
 				return page;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
