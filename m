Received: from localhost (riel@localhost)
	by duckman.conectiva (8.9.3/8.8.7) with ESMTP id QAA04880
	for <linux-mm@kvack.org>; Sun, 26 Mar 2000 16:25:41 -0300
Date: Sun, 26 Mar 2000 16:25:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: 2.3.99-pre3 VM strangeness
Message-ID: <Pine.LNX.4.21.0003251806570.4844-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've been playing around with 2.3.99-pre3 somewhat and I've
found that the VM subsystem seems to be working fine and
has pretty good performance. However, I've found one strange
anomaly, which results in high CPU usage by kswapd.

The problem seems to be in the current implementation of the
LRU cache, which also keeps (and needlessly ages) unfreeable
(mapped in processes) pages.

Suppose a heavily swapping program, which has 60% of physical
memory in the swap cache (not uncommon). Now we have 60% of
physical memory in the LRU queue, but only a tiny fraction of
it is freeable at any time (because we're swapping _heavily_).

In shrink_mmap(), however, we'll be scanning _all_ the pages
and immediately freeing those pages that are freeable. This
means that most of the time will be spent reshuffling a lot
of non-freeable pages. I've seen kswapd use as much as 60%
CPU, with just 800 pagefaults per second (of which just
180 hit the disk).

The correct solution will be to have only freeable pages and
buffer pages in the LRU queue. When we unmap the page in
try_to_swap_out() (and are the last PTE user) we add the page
to the back of the LRU queue.

Pages are removed from the LRU queue in two ways:
- freed when they reach the front of the queue
- reclaimed by the application from which we stole them

Buffer pages which go to the front of the queue should
have their buffers stolen and be moved to the back of the
queue when we fail in stealing all its buffers.

The size of the LRU queue can be dynamically adjusted.
If there are too many reclaims by applications, we
reduce the size of the queue, if there aren't enough of
them we probably aren't doing enough page aging and we
should increase the size of the queue.

In __get_free_pages() we can remove a page from the free
list (like we do now) or from the LRU queue when we're
low on memory. Kswapd has the task of making sure the LRU
queue is big enough (and recalculating the target size of
the LRU queue).

I'll start implementing this strategy now.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
