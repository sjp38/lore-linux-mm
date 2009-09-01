Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 986AF6B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 07:00:07 -0400 (EDT)
Date: Tue, 1 Sep 2009 12:00:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] page-allocator: Always change pageblock ownership when
	anti-fragmentation is disabled
Message-ID: <20090901110005.GB27393@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On low-memory systems, anti-fragmentation gets disabled as fragmentation
cannot be avoided on a sufficiently large boundary to be worthwhile.
Once disabled, there is a period of time when all the pageblocks are marked
MOVABLE and the expectation is that they get marked UNMOVABLE at each call
to __rmqueue_fallback().

However, when MAX_ORDER is large the pageblocks do not change ownership
because the normal criteria are not met. This has the effect of prematurely
breaking up too many large contiguous blocks. This is most serious on NOMMU
systems which depend on high-order allocations to boot. This patch causes
pageblocks to change ownership on every fallback when anti-fragmentation is
disabled. This prevents the large blocks being prematurely broken up.

This is a fix to commit 49255c619fbd482d704289b5eb2795f8e3b7ff2e [page
allocator: move check for disabled anti-fragmentation out of fastpath]
and the problem affects 2.6.31-rc8.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Tested-by: Paul Mundt <lethal@linux-sh.org>
--- 
 mm/page_alloc.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d052abb..41eb651 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -817,13 +817,15 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			 * agressive about taking ownership of free pages
 			 */
 			if (unlikely(current_order >= (pageblock_order >> 1)) ||
-					start_migratetype == MIGRATE_RECLAIMABLE) {
+					start_migratetype == MIGRATE_RECLAIMABLE ||
+					page_group_by_mobility_disabled) {
 				unsigned long pages;
 				pages = move_freepages_block(zone, page,
 								start_migratetype);
 
 				/* Claim the whole block if over half of it is free */
-				if (pages >= (1 << (pageblock_order-1)))
+				if (pages >= (1 << (pageblock_order-1)) ||
+						page_group_by_mobility_disabled)
 					set_pageblock_migratetype(page,
 								start_migratetype);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
