Received: from there (h164n1fls31o925.telia.com [213.65.254.164])
	by maila.telia.com (8.11.2/8.11.0) with SMTP id f7MFJOR19243
	for <linux-mm@kvack.org>; Wed, 22 Aug 2001 17:19:24 +0200 (CEST)
Message-Id: <200108221519.f7MFJOR19243@maila.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: [PATCH] __alloc_pages_limit pages_min
Date: Wed, 22 Aug 2001 17:12:40 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

If __alloc_pages_limit is called with PAGES_HIGH and direct_reclaim.
It might alloc the last free page of a zone....

How:
* inactive_clean_pages >= pages_high

first if gives

if (free_pages + inactive_clean >= pages_high) => true

No direct_reclaim gives no attempt to call reclaim_page.
Instead rmqueue will be called...
now we have one page less - run it again...
free_pages will be decremented until zero...

Last page gone in a at PAGES_HIGH alloc!!!

Note: reclaim_page will fix this situation direct it is allowed to
run since it is kicked in __alloc_pages. But since we cannot
guarantee that this will never happen...

/RogerL

this patch is against 2.4.8-pre3 as it was my current kernel.
(searching for a USB storage bug...)
*******************************************
Patch prepared by: roger.larsson@norran.net

--- linux/mm/page_alloc.c.orig	Wed Aug 22 13:36:57 2001
+++ linux/mm/page_alloc.c	Wed Aug 22 13:50:31 2001
@@ -256,8 +256,9 @@
 			/* If possible, reclaim a page directly. */
 			if (direct_reclaim)
 				page = reclaim_page(z);
-			/* If that fails, fall back to rmqueue. */
-			if (!page)
+			/* If that fails, fall back to rmqueue, but do never
+			*  go below free_pages for any zone*/
+			if (!page && z->free_pages >= z->pages_min)
 				page = rmqueue(z, order);
 			if (page)
 				return page;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
