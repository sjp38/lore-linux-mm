Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA20639
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 10:25:13 -0500
Date: Tue, 24 Nov 1998 15:25:03 GMT
Message-Id: <199811241525.PAA00862@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Linux-2.1.129..
In-Reply-To: <Pine.LNX.3.95.981123120028.5712B-100000@penguin.transmeta.com>
References: <m1r9uudxth.fsf@flinx.ccr.net>
	<Pine.LNX.3.95.981123120028.5712B-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 23 Nov 1998 12:02:41 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> On 23 Nov 1998, Eric W. Biederman wrote:
>> 
ST> That would be true if we didn't do the free_page_and_swap_cache trick.
ST> However, doing that would require two passes: once by the swapper, and
ST> once by shrink_mmap(): before actually freeing a page. 

> This is something I considered doing. It has various advantages, and it's
> almost done already in a sense: the swap cache thing is what would act as
> the buffer between the two passes. 

Yes.  

> Then the page table scanning would never really page anything out: it
> would just move things into the swap cache. That makes the table scanner
> simpler, actually. The real page-out would be when the swap-cache is
> flushed to disk and then freed.

Indeed.  However, I think it misses the real advantage, which is that
the mechanism would be inherently self-tuning (much more so than the
existing code).   The swapper would batch up pageouts from the page
tables, leaving a number of recyclable pages in the swap cache, and
those cached pages would be subject to fair removal from the cache:
we would not start to ignore cache completely once we start swapping
(which is important if we don't age the swap pages: the lack of aging
makes it far to easy to keep finding free swap pages so we never go
back to shrink_mmap() mode).

> I'd like to see this, although I think it's way too late for 2.2

The mechanism is all there, and we're just tuning policy.  Frankly,
the changes we've seen in vm policy since 2.1.125 are pretty major
already, and I think it's important to get it right before 2.2.0.

The patch below is a very simple implementation of this concept.
I have been running it on 2.1.130-pre2 on 8MB and on 64MB.  On 8, it
gives the expected performance, roughly similar to previous
incarnations of the page-cache-ageless kernels.  

On 64MB, however, it feels rather different: subjectively I think it
feels like the fastest kernel I've ever run on this box.  It happily
swaps out unused code while refusing to touch used ptes, and seems to
balance cache much better than before.  With a very large emacs
(a couple of thousand-message mailboxes loaded in VM), netscape and xv
running, switching between desktops is still zero-wait, and compiles
still go fast.

Unfortunately, 2.1.129 keeps hanging on me, so the testing on 64MB was
cut short after a couple of hours (I think it's either audio CDs or
Ingo's latest alpha-raid which causes the trouble).  No problems on
the 8MB box though.

Linus, is it really too late to look at adding this?

--Stephen


----------------------------------------------------------------
--- mm/vmscan.c~	Tue Nov 17 15:43:55 1998
+++ mm/vmscan.c	Mon Nov 23 17:05:33 1998
@@ -170,7 +170,7 @@
 			 * copy in memory, so we add it to the swap
 			 * cache. */
 			if (PageSwapCache(page_map)) {
-				free_page_and_swap_cache(page);
+				free_page(page);
 				return (atomic_read(&page_map->count) == 0);
 			}
 			add_to_swap_cache(page_map, entry);
@@ -188,7 +188,7 @@
 		 * asynchronously.  That's no problem, shrink_mmap() can
 		 * correctly clean up the occassional unshared page
 		 * which gets left behind in the swap cache. */
-		free_page_and_swap_cache(page);
+		free_page(page);
 		return 1;	/* we slept: the process may not exist any more */
 	}
 
@@ -202,7 +202,7 @@
 		set_pte(page_table, __pte(entry));
 		flush_tlb_page(vma, address);
 		swap_duplicate(entry);
-		free_page_and_swap_cache(page);
+		free_page(page);
 		return (atomic_read(&page_map->count) == 0);
 	} 
 	/* 
@@ -218,7 +218,11 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
+#if 0
 	entry = page_unuse(page_map);
+#else
+	entry = (atomic_read(&page_map->count) == 1);
+#endif
 	__free_page(page_map);
 	return entry;
 }
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
