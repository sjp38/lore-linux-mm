Message-ID: <413AA7B2.4000907@yahoo.com.au>
Date: Sun, 05 Sep 2004 15:44:18 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Kswapd is dumb as bricks when it comes to higher order allocations.
Actually that's not quite fair: it is bad at lots of things... but
higher order allocations are one of its more spectacular failures.

The major problem that I can see is with !wait allocations, where
you aren't allowed to free anything yourself - you're relying on
kswapd (aside from that, it's always nice to avoid synchronous reclaim).

Apparently these (higher-order && !wait) come up mainly in networking
which is the thing I had in mind. *However* as I only have half of a
gigabit network (ie. 1 card), I haven't done any testing where it
really counts. I'm also seeing surprisingly few reports on lkml, so
perhaps it is me that needs the beating?

Anyway, the big failure case is when memory is fragmented to the
point that pages_free > pages_low, but you still have no higher order
pages left. In that case, your !wait allocations can keep calling
wakeup_kswapd but he'll just keep sleeping. min_free_kbytes is not
really a solution because it just raises pages_low. In a nutshell,
that whole area doesn't really have any idea about higher order
allocations.

So my solution? Just teach kswapd and the watermark code about higher
order allocations in a fairly simple way. If pages_low is (say), 1024KB,
we now also require 512KB of order-1 and above pages, 256K of order-2
and up, 128K of order 3, etc. (perhaps we should stop at about order-3?)

*Also*, if we have requested an order 5 allocation, but one isn't
available, we'll get kswapd to try to free at least 1, even if its
order-5 "free-until" watermark is 0KB.

The main cost is keeping track of the number of free pages of each order.
There is also a penalty in the allocator for order > 0 allocations, but
I have tried to do it so lower order allocations need to do less work.

Flames? Comments?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
