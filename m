Date: 11 Oct 2004 16:40:34 -0000
Message-ID: <20041011164034.17383.qmail@science.horizon.com>
From: linux@horizon.com
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I just thought I'd mention something that Doug Lea found Very
Important when designing dlmalloc to reduce fragmentation:

- Maintain the free lists in FIFO order.  LIFO has severe problems.
- When a free block is merged into a larger block, it goes back on
  the end of the appropriate list.

If you maintain free blocks as a LIFO stack (something that occurs to
people thinking about cache effects), then you end up with a steady
state where the top few blocks are allocated very rapidly and never get
a chance to merge, while the bottom is made up of blocks whose neighbours
are permanently allocated and never get merged.

What you *want* to do is make small (low-order) allocations from blocks
which will never grow any larger (the ones on the bottom of the stack),
and keep other blocks on the free list until they've been combined with
their neighbours.

FIFO ordering works best for this, giving everything an equal chance to
be merged, and allocating the blocks that have had their chance and not
been merged.

I haven't grovelled through the Linux code to figure out what it does
do exactly, but if you're trying to reduce external fragmentation,
that's a proven technique.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
