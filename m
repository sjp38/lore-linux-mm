Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 315C95F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 14:27:09 -0400 (EDT)
Date: Thu, 21 Oct 2010 13:27:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <20101021181347.GB32737@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1010211326310.24115@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <20101021181347.GB32737@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Potential fixup....



Allocations to ZONE_NORMAL may fall back to ZONE_DMA and ZONE_DMA32
so we must allow calling shrinkers for these zones as well.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/vmscan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2010-10-21 13:23:32.000000000 -0500
+++ linux-2.6/mm/vmscan.c	2010-10-21 13:23:53.000000000 -0500
@@ -2219,7 +2219,7 @@ loop_again:
 					8*high_wmark_pages(zone), end_zone, 0))
 				shrink_zone(priority, zone, &sc);

-			if (zone_idx(zone) == ZONE_NORMAL) {
+			if (zone_idx(zone) <= ZONE_NORMAL) {
 				reclaim_state->reclaimed_slab = 0;
 				nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 							lru_pages);
@@ -2704,7 +2704,7 @@ static int __zone_reclaim(struct zone *z

 	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	if (nr_slab_pages0 > zone->min_slab_pages &&
-					zone_idx(zone) == ZONE_NORMAL) {
+					zone_idx(zone) <= ZONE_NORMAL) {
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
