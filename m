Date: Wed, 26 Apr 2000 04:25:23 -0700
Message-Id: <200004261125.EAA12302@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20000426120130.E3792@redhat.com> (sct@redhat.com)
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com> <20000425120657.B7176@stormix.com> <20000426120130.E3792@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: sim@stormix.com, jgarzik@mandrakesoft.com, riel@nl.linux.org, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

   On Tue, Apr 25, 2000 at 12:06:58PM -0700, Simon Kirby wrote:
   > 
   > Sorry, I made a mistake there while writing..I was going to give an
   > example and wrote 60 seconds, but I didn't actually mean to limit
   > anything to 60 seconds.  I just meant to make a really big global lru
   > that contains everything including page cache and swap. :)

   Doesn't work.  If you do that, a "find / | grep ..." swaps out 
   everything in your entire system.

   Getting the VM to respond properly in a way which doesn't freak out
   in the mass-filescan case is non-trivial.  Simple LRU over all pages
   simply doesn't cut it.

I believe this is not true at all.  Clean pages will be preferred to
toss simply because they are easier to get rid of.  In fact, "find / |
grep" is a perfect example of a case where LRU'ing only clean page
cache pages will keep the free page pools in equilibrium and we won't
need to swap anything.

I can say this with confidence, because I actually implemented a one
day hack which centralized all of page cache, swap cache, and all
anonymous pages into the LRU, deleted the crap we call swap_out and
taught the LRU queue processing how to toss pages from user address
spaces.  Since I gave a mapping to anonymous pages, this became a
doable and almost trivial task.  In these hacks I also created a
multi-list LRU scheme (active, inactive, dirty) so that
try_to_free_pages already had the LRU pool pre-sorted, so it only had
to look at pages which were unreferenced at the onset of memory
pressure.  When we're not paging, kswapd would wake up periodically
to do some LRU aging and populate the inactive/dirty LRU queues.

I have to be quite frank, and say that the FreeBSD people are pretty
much on target when they say that our swapping and paging stinks, it
really does.

I am of the opinion that vmscan.c:swap_out() is one of our biggest
problems, because it kills us in the case where a few processes have
a pagecache page mapped, haven't accessed it in a long time, and
swap_out doesn't unmap those pages in time for the LRU shrink_mmap
code to fully toss it.  This happens even though these pages are
excellant candidates for freeing.  So here is where I came to the
conclusion that LRU needs to have the capability of tossing arbitrary
pages from process address spaces.  This is why in my experiental
hacks I just killed swap_out() completely, and taught LRU how to
do all of the things swap_out did.  I could do this because the
LRU scanner could go from a page to all mappings of that page, even
for anonymous and swap pages.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
