Received: from today.toronto.redhat.com (today.toronto.redhat.com [172.16.14.234])
	by lacrosse.corp.redhat.com (8.9.3/8.9.3) with ESMTP id SAA06147
	for <linux-mm@kvack.org>; Thu, 5 Apr 2001 18:08:56 -0400
Date: Thu, 5 Apr 2001 18:08:56 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] another thinko in memory.c (fwd)
Message-ID: <Pine.LNX.4.33.0104051808390.2151-100000@today.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ooops, forgot to cc...

---------- Forwarded message ----------
Date: Thu, 5 Apr 2001 18:05:13 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
To: torvalds@transmeta.com, alan@redhat.com
Cc: arjanv@redhat.com
Subject: [PATCH] another thinko in memory.c

Hey folks,

Ingo spotted this one, and it's the same kind of smp race.

		-ben

diff -ur v2.4.3/mm/memory.c work-2.4.3/mm/memory.c
--- v2.4.3/mm/memory.c	Thu Apr  5 11:53:46 2001
+++ work-2.4.3/mm/memory.c	Thu Apr  5 16:27:08 2001
@@ -859,9 +859,12 @@
 		 * the swap cache, grab a reference and start using it.
 		 * Can not do lock_page, holding page_table_lock.
 		 */
-		if (!PageSwapCache(old_page) || TryLockPage(old_page))
+		if (!PageSwapCache(old_page))
 			break;
-		if (is_page_shared(old_page)) {
+		if (TryLockPage(old_page))
+			break;
+		/* Recheck swapcachedness: this is a triggerable smp race. */
+		if (!PageSwapCache(old_page) || is_page_shared(old_page)) {
 			UnlockPage(old_page);
 			break;
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
