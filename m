Message-ID: <447592A8.1050408@shadowen.org>
Date: Thu, 25 May 2006 12:19:04 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] Zone boundary alignment fixes, default configuration
References: <447173EF.9090000@shadowen.org> <exportbomb.1148291574@pinky>
In-Reply-To: <exportbomb.1148291574@pinky>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[Hmmmm, just received this back from our mailers, thanks a lot!
I thought it was odd to hear total silence.  Anyhow, heres trying
that again.]

There has been much confusion over what is and what is not needed to
ensure we do not merge buddies across zone boundaries.  So I thought
I would try and put down my view of the world and how I think the
fixes out there work together.  I feel that having this all in one
place will help clarify the problem and the proposed solution.

First the assumptions that the buddy allocator is making:

1) that the buddy for any page it is offered can simply be calculated
   from the pfn of that page, and

2) that the page* for the buddy for any page it is offered can
   be examined to see if it is free without referencing the node
   boundaries.

The practical up shot of that is we require the the:

1) mem_map is contigious for any MAX_ORDER span of pages, and

2) mem_map is valid out to MAX_ORDER from any page within a zone.

Let examine a worse case example where we have both nodes which touch
in the middle of a MAX_ORDER range, and have zones with boundaries
the same.  In our hypothetical machine we have MAX_ORDER at 2 so we
have 4 pages in each MAX_ORDER range and we will run two nodes one
from pfn 2->9 and a second from 10->17.  We will have two zones,
the first 4 pages of each node are in a separate zone.  I include
the NODEZONE calculations (the index into the zonetable used to
locate the zone structure from a page) for both FLATMEM/DISCONTIGMEM
and for SPARSEMEM.  I will consider the case where we allocate
independant node_mem_map arrays for each node (maps 1 and 2) and
the ia64 single contigious case (map 3).

      PFN   0     2        5  6        9 10       13 14       17    19
          |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
MAX_ORDER |-----------|-----------|-----------|-----------|-----------|
     NODE |     |-----------0-----------|-----------1-----------|     |
     ZONE |     |-----A-----|-----B-----|-----C-----|-----D-----|     |
          |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
 FLAT/DIS |00|00|00|00|00|00|01|01|01|01|10|10|10|10|11|11|11|11|00|00|
   SPARSE |00|00|00|00|10|10|11|11|21|21|20|20|30|30|31|31|41|41|00|00|
MEM_MAP 1 |ZZZZZ-------------------------ZZZZZ|
MEM_MAP 2                         |ZZZZZ-------------------------ZZZZZ|
MEM_MAP 3 |ZZZZZ-------------------------------------------------ZZZZZ|

Here I am assuming that we have UNALIGNED_ZONE_BOUNDARIES enabled
and therefore have the page_zone_idx(page) != page_zone_idx(buddy)
check.  So lets consider the worst cases freeing a page which wants
to coelesce a buddy which:

1) is below the start of node 0 (page 2),
2) is in another zone (pages 4 and 6),
3) is in another node (pages 8 and 10), and
4) is above the end of node 1 (page 16).

Scenario 1: buddy is below the start of node -- here we are freeing
page 2 we will need to examine buddy page 0 to see if it is free and
whether it is in the same zone.  As the mem_map is zero filled the
page will never be free, PG_buddy is not set.  We cannot coelesce.

Scenario 2: buddy is in another zone -- here we are freeing page
4 (or 6) we will need to examine buddy page 6 (or 4).  If we
assume worst case and the page is free, PG_buddy is set, we then
compare the NODEZONE's.  Here they differ (00 != 01 or 10 != 11).
We cannot coelesce.

Scenario 3a (multiple mem_map case): buddy is in another node -- here
are freeing page 8 (or 10) we will need to examine buddy page 10
(or 8).  As the mem_map is zero filled the page will never appear
free in the node local mem_map.  We cannot coelesce.

Scenario 3b (single mem_map case): buddy is in another node -- here
are freeing page 8 (or 10) we will need to examine buddy page 10
(or 8).  If we assume worst case and the page is free, PG_buddy is
set, we then compare NODEZONES's.  Here they differ (01 != 10 or
21 != 20).  We cannot coelesce.

Scenario 4: buddy is above the end of node -- here we are freeing
page 16 we will need to examine buddy page 18.  As the mem_map
is zero filled the page will never be free, PG_buddy is not set.
We cannot coelesce.

It is important to note that for this to work correctly in the case
where we have missaligned nodes in the single mem_map case we must
compare the page_zone_idx over the page_zone_id to ensure we detect
the node transition in the case where we only have a single zone
in each node.

I hope this clarifies things, please yell if you can see a hole
in this.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
