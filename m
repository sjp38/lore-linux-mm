Message-ID: <3D24D4A0.D39B8F2C@zip.com.au>
Date: Thu, 04 Jul 2002 16:05:04 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: vm lock contention reduction
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

I seem to now have a set of patches which fix the pagemap_lru_lock
contention for some workloads.

They also move the entire page allocation/reclaim/pagecache I/O
functions away from page-at-a-time and make them use chunks of 16 pages
at a time.  The intent of this is to get the effect of large PAGE_CACHE_SIZE
without actually doing that.

Overall lock contention is reduced by 85-90% and pagemap_lru_lock contention
is reduced by maybe 98%.  For workloads where the inactive list is dominated
by pagecache.

If the machine is instead full of anon pages then everything is still crap
because the page reclaim code is scanning zillions of pages and not doing
much useful with them.

In some ways the VM locking is more complex, because we need to cope
with pages which aren't on the LRU.  In some ways the locking is simpler
because pagemap_lru_lock becomes an "innermost" lock.

Relevant patches are:

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/page-flags-atomicity.patch
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/pagevec.patch
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/shrink_cache-pagevec.patch
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/anon-pagevec.patch
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/mpage_writepages-batch.patch
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/batched-lru-add.patch
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/batched-lru-del.patch
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/lru-lock-irq-off.patch
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.24/lru-mopup.patch

My vague plan was to wiggle rmap on top of this work, for two reasons:

1: So it is easy to maintain an rmap backout patch, to aid in comparison
   and debugging and

2: to give a reasonable basis for evaluation of rmap CPU efficiency.

But frankly, I've written and rewritten this code three times so far
and I'm still not really happy with it.  Probably it is more sensible
to get the reverse mapping code into the tree first, and I get to
reimplement the CPU efficiency work a fourth time :(

So I'll flush the rest of my current patchpile at Linus and go take a
look at O_DIRECT for a while.

I'll shelve this lock contention work until we have an rmap patch
for 2.5.   Rik, do you have an estimate on that?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
