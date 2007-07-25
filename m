Date: Tue, 24 Jul 2007 21:20:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: NUMA policy issues with ZONE_MOVABLE
Message-ID: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

The outcome of the 2.6.23 merge was surprising. No antifrag but only 
ZONE_MOVABLE. ZONE_MOVABLE is the highest zone.

For the NUMA layer this has some weird consequences if ZONE_MOVABLE is populated

1. It is the highest zone.

2. Thus policy_zone == ZONE_MOVABLE

ZONE_MOVABLE contains only movable allocs by default. That is anonymous 
pages and page cache pages?

The NUMA layer only supports NUMA policies for the highest zone. 
Thus NUMA policies can control anonymous pages and the page cache pages 
allocated from ZONE_MOVABLE. 

However, NUMA policies will no longer affect non pagecache and non 
anonymous allocations. So policies can no longer redirect slab allocations 
and huge page allocations (unless huge page allocations are moved to 
ZONE_MOVABLE). And there are likely other allocations that are not 
movable.

If ZONE_MOVABLE is off then things should be working as normal.

Doesnt this mean that ZONE_MOVABLE is incompatible with CONFIG_NUMA?


The mobility approach used subcategories of a zone which would have 
allowed the application of memory policies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
