Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: [PATCH] Unlazy activate (was: re "ongoing vm suckage")
Date: Sun, 5 Aug 2001 01:28:35 +0200
References: <Pine.LNX.4.33L.0108040411220.2526-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108040411220.2526-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <01080501283500.00315@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 04 August 2001 09:13, Rik van Riel wrote:
> Oh, and we definately need to un-lazy the queue movement
> from the inactive_clean list. Having all of the pages you
> counted on as being reclaimable referenced is a very bad
> surprise ...

This patch does immediate activate for used-twice pages, so that
pages already known to be referenced don't stay sitting on the
inactive queue until page_launder finds them.

This improves dbench a little, as well as my make+grep load, so
it seems like a good thing.  I can't think of any reason why it
makes sense to leave those pages sitting on the inactive queue
when we already know they're going to be activated eventually.
Well, *maybe* there would be less CPU spent acquiring the
pagemap_lru_lock, but that's it.

--- ../2.4.8-pre4/mm/filemap.c	Sat Aug  4 14:27:16 2001
+++ ./mm/filemap.c	Sat Aug  4 23:41:00 2001
@@ -979,9 +979,13 @@
 
 static inline void check_used_once (struct page *page)
 {
-	if (!page->age) {
-		page->age = PAGE_AGE_START;
-		ClearPageReferenced(page);
+	if (!PageActive(page)) {
+		if (page->age)
+			activate_page(page);
+		else {
+			page->age = PAGE_AGE_START;
+			ClearPageReferenced(page);
+		}
 	}
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
