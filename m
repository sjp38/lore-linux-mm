Date: Fri, 6 Apr 2001 20:47:13 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] swap_state.c thinko
Message-ID: <20010406204713.P28118@athlon.random>
References: <Pine.LNX.4.21.0104061638200.1098-100000@localhost.localdomain> <Pine.LNX.4.31.0104061011120.12081-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.31.0104061011120.12081-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Fri, Apr 06, 2001 at 10:21:38AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 06, 2001 at 10:21:38AM -0700, Linus Torvalds wrote:
> I don't agree with your vm_enough_memory() worry - it should be correct
> already, because it shows up as page cache pages (and that, in turn, is
> already taken care of). In fact, the swap cache pages shouldn't even
> create any new special cases: they are exactly equivalent to already-
> existing page cache pages.

swap cache also decrease the amount free-swap-space, that will be reclaimed as
soon as we collect the swap cache. so we must add the swap cache size to the
amount of virtual memory available (in addition to the in-core pagecachesize)
to take care of the swap side. I suggested that as the fix for the failed
malloc issue to the missioncritical guys when they asked me about that.
However I think I seen some overkill patch floating around, the fix is just a
one liner:

--- 2.4.3aa/mm/mmap.c.~1~	Fri Apr  6 05:10:16 2001
+++ 2.4.3aa/mm/mmap.c	Fri Apr  6 20:44:18 2001
@@ -64,6 +64,7 @@
 	free += atomic_read(&page_cache_size);
 	free += nr_free_pages();
 	free += nr_swap_pages;
+	free += swapper_space.nrpages;
 	/*
 	 * The code below doesn't account for free space in the inode
 	 * and dentry slab cache, slab cache fragmentation, inodes and

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
