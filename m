Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA01852
	for <linux-mm@kvack.org>; Thu, 2 Jul 1998 12:38:44 -0400
Received: from mirkwood.dummy.home (root@anx1p3.phys.uu.nl [131.211.33.92])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id SAA11227
	for <linux-mm@kvack.org>; Thu, 2 Jul 1998 18:38:33 +0200 (MET DST)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id SAA08142 for <linux-mm@kvack.org>; Thu, 2 Jul 1998 18:13:58 +0200
Date: Thu, 2 Jul 1998 18:13:55 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: zone allocator design (partly)
Message-ID: <Pine.LNX.3.96.980702174702.8137A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I've come up with a design for the zone allocator.
Basically, we allocate 32-page areas first, and
then we allocate pages inside these area's.

The areas are divided both by usage type and physical
type. Usage is divided in large SLAB, DMA, small SLAB,
pagetable, user pages. Physical type is divided in the
following types: DMAable memory, cached memory and slow
memory.

The distinction between large SLAB and DMA is only made when
total memory goes above the DMA limit. The distinction between
small SLAB and pagetable is only made when we have slow
(uncached / add-on) memory and the user tells us to...

In addition, we also have different lists depending on
how used the areas are, this gives us the following
lists:

large/DMA	small/PTE	user		empty
full		full		full		DMA
3/4		30/32		30/32		normal
1/2		28/32		28/32		slow
1/4		20/32		20/32
		8/32		8/32

Areas are allocated in the following order:
user, slab	-> normal, slow, DMA
pagetable	-> slow, normal, DMA
DMA		-> DMA

On allocation, a page is always taken from the first area
on the 'almost full' list; when we have few free pages,
we give pages inside an almost empty area (page in the lowest
populated queue, or last page in 30/32 queue) an extra
penalty (or we just force-free them) so we can free up an
extra area when needed. We skip DMA areas on our fist
pass over a list, we allocate from them only on our
second pass...

The individual area's are described by the following
struct; next and prev are used for the lists mentioned
above, the flags could maybe be dropped, but they might
be nice for statistics and stuff (and we want alignment
anyway), the page_map is a bitmap of pages and the
num_used is there to move pages from queue to queue
easily. The reason I chose for a bitmap instead of the
currently used linked-list-on-page-itself structure
is that it allows us to keep pages in-core for longer
times so we can do lazy-reclamation...
The structure is aligned to 4 longs, both on x86
and Alpha; don't know about UltraSPARC though.
Heck, I don't even know if it needs alignment :-)

struct memory_area {
	memory_area * next, prev;
	unsigned short flags;
	unsigned long page_map;	/* bitmap of used/free pages */
	unsigned short num_used; /* nr of used pages, used to move us
				around the list of memory_area's */
};

As usual, I want/need comments. This weekend, I might even
be able to create some time for coding up the allocator.
(after I have a working linux-mm archive on our homepage)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
