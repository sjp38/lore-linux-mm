Message-ID: <3D4CE74A.A827C9BC@zip.com.au>
Date: Sun, 04 Aug 2002 01:35:22 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: how not to write a search algorithm
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Worked out why my box is going into a 3-5 minute coma with one test.
Think what the LRUs look like when the test first hits page reclaim
on this 2.5G ia32 box:

               head                           tail
active_list:   <800M of ZONE_NORMAL> <200M of ZONE_HIGHMEM>
inactive_list:          <1.5G of ZONE_HIGHMEM>

now, somebody does a GFP_KERNEL allocation.

uh-oh.

VM calls refill_inactive.  That moves 25 ZONE_HIGHMEM pages onto
the inactive list.  It then scans 5000 pages, achieving nothing.

VM calls refill_inactive.  That moves 25 ZONE_HIGHMEM pages onto
the inactive list.  It then scans about 10000 pages, achieving nothing.

VM calls refill_inactive.  That moves 25 ZONE_HIGHMEM pages onto
the inactive list.  It then scans about 20000 pages, achieving nothing.

VM calls refill_inactive.  That moves 25 ZONE_HIGHMEM pages onto
the inactive list.  It then scans about 40000 pages, achieving nothing.

VM calls refill_inactive.  That moves 25 ZONE_HIGHMEM pages onto
the inactive list.  It then scans about 80000 pages, achieving nothing.

VM calls refill_inactive.  That moves 25 ZONE_HIGHMEM pages onto
the inactive list.  It then scans about 160000 pages, achieving nothing.

VM calls refill_inactive.  That moves 25 ZONE_HIGHMEM pages onto
the inactive list.  It then scans about 320000 pages, achieving nothing.

The page allocation fails.  So __alloc_pages tries it all again.


This all gets rather boring.


Per-zone LRUs will fix it up.  We need that anyway, because a ZONE_NORMAL
request will bogusly refile, on average, memory_size/800M pages to the
head of the inactive list, thus wrecking page aging.

Alan's kernel has a nice-looking implementation.  I'll lift that out
next week unless someone beats me to it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
