Date: Thu, 5 Apr 2001 13:11:30 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.21.0104051304450.27736-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.30.0104051310470.1767-100000@today.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: arjanv@redhat.com, alan@redhat.com, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2001, Rik van Riel wrote:

> I sure hope the page is unlocked afterwards, regardless of
> whether it's (still) in the swap cache or not ...

You're right.  Here's the hopefully correct version.

		-ben

diff -ur v2.4.3/mm/swap_state.c work-2.4.3/mm/swap_state.c
--- v2.4.3/mm/swap_state.c	Fri Dec 29 18:04:27 2000
+++ work-2.4.3/mm/swap_state.c	Thu Apr  5 13:10:27 2001
@@ -140,10 +140,9 @@
 	/*
 	 * If we are the only user, then try to free up the swap cache.
 	 */
-	if (PageSwapCache(page) && !TryLockPage(page)) {
-		if (!is_page_shared(page)) {
+	if (!TryLockPage(page)) {
+		if (PageSwapCache(page) && !is_page_shared(page))
 			delete_from_swap_cache_nolock(page);
-		}
 		UnlockPage(page);
 	}
 	page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
