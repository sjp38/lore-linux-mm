Date: Thu, 30 Mar 2000 23:55:25 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: shrink_mmap SMP race fix
In-Reply-To: <Pine.LNX.4.21.0003301757450.1104-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0003302323220.10302-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Mar 2000, Rik van Riel wrote:

>That this works has been demonstrated by the second chance
>replacement patchlet that went into 2.2.15pre...

The trick is only to not clear the referenced bit for mapped pages from
within shrink_mmap (not to change swap_out). That's good since it gives to
mapped pages a longer life since they are more critical (exectutables sits
on mapped pages). I agree in changing shrink_mmap to not clear the
reference bit for mapped pages in 2.3.x too, that is going to make the
swapout stage smoother I think, agreed.

>Point is, we should give the process a good amount of time
>to fault their page back in. Otherwise page aging is just

The process just had the time to fault back in before the page got
unmapped from the pte. The swap cache that gets generated is less
interesting information than the page cache (there was not accessed bit or
pte in the page cache).

Also consider if there's a swap loop the swap_out continue to generate
swap_cache. If we threat swap_cache and page cache equally we'll end
finishing the page cache completly and having only the pollution in the
cache. If you instead shrink from the right place you may end preserving
the interesting cache. Consider there are lots of swap hog cases where you
never fault in the swap cache again (but you only touch always different
memory) and they are usually the harmful ones where we should react
smoothly.

>the single NRU bit; in 2.2 we've already seen that that is
>just not enough.

IMHO it's enough. We also have the implicit information of inserction
point in the LRU (that's better than 2.2.x). Also if you really want to do
better you don't need more than one bit but you want zero bit and to keep
the LRU in perfect order rolling entries at each cache hit ;).

The aging of mapped pages is right now quite special case (and the change
you did there to make sure unmapped pages have reference bit set is very
good idea for 2.3.x too! :). The reason we need such trick is that such
pages are going to be always with the reference bit clear when they gets
unmapped by swap_out just because shrink_mmap has to fail (so potentially
clearing the age bits) in order to trigger the swap_out in first place.
With the new design instead we'll be able to know when we have to swap_out
without the need of entering shrink_mmap and the reference bit won't be
cleared in order to trigger swap_out. And in general though is good idea
to give longer lifetime to the .text sections so the mouse keeps moving
the arrow more probably ;).

This below untested patch incremental with all the previous patches should
do the trick:

--- 2.3.99-pre3aa1-alpha/mm/filemap.c.~1~	Thu Mar 30 18:24:29 2000
+++ 2.3.99-pre3aa1-alpha/mm/filemap.c	Thu Mar 30 23:50:26 2000
@@ -233,6 +233,16 @@
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
+		/*
+		 * HACK: don't clear the reference bit on mapped page cache
+		 * to give them longer life.
+		 */
+		if (page->mapping && page_count(page) > 1) {
+			dispose = &young;
+			count--;
+			goto dispose_continue;
+		}
+
 		dispose = &zone->lru_cache;
 		if (test_and_clear_bit(PG_referenced, &page->flags))
 			/* Roll the page at the top of the lru list,

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
