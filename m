Date: Thu, 5 Apr 2001 11:56:48 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] swap_state.c thinko
Message-ID: <Pine.LNX.4.30.0104051155380.1767-100000@today.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com, alan@redhat.com, torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hey folks,

Here's another one liner that closes an smp race that could corrupt
things.

		-ben

diff -urN v2.4.3/mm/swap_state.c work-2.4.3/mm/swap_state.c
--- v2.4.3/mm/swap_state.c	Fri Dec 29 18:04:27 2000
+++ work-2.4.3/mm/swap_state.c	Thu Apr  5 11:55:00 2001
@@ -140,7 +140,7 @@
 	/*
 	 * If we are the only user, then try to free up the swap cache.
 	 */
-	if (PageSwapCache(page) && !TryLockPage(page)) {
+	if (!TryLockPage(page) && PageSwapCache(page)) {
 		if (!is_page_shared(page)) {
 			delete_from_swap_cache_nolock(page);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
