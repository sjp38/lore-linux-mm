Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 732FD6B003C
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:48:27 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so3011223eek.29
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:48:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si1379448een.83.2013.12.17.08.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 08:48:26 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/6] mm: page_alloc: exclude unreclaimable allocations from zone fairness policy
Date: Tue, 17 Dec 2013 16:48:19 +0000
Message-Id: <1387298904-8824-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1387298904-8824-1-git-send-email-mgorman@suse.de>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Johannes Weiner <hannes@cmpxchg.org>

Dave Hansen noted a regression in a microbenchmark that loops around
open() and close() on an 8-node NUMA machine and bisected it down to
81c0a2bb515f ("mm: page_alloc: fair zone allocator policy").  That
change forces the slab allocations of the file descriptor to spread
out to all 8 nodes, causing remote references in the page allocator
and slab.

The round-robin policy is only there to provide fairness among memory
allocations that are reclaimed involuntarily based on pressure in each
zone.  It does not make sense to apply it to unreclaimable kernel
allocations that are freed manually, in this case instantly after the
allocation, and incur the remote reference costs twice for no reason.

Only round-robin allocations that are usually freed through page
reclaim or slab shrinking.

Cc: <stable@kernel.org>
Bisected-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 580a5f0..f861d02 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1920,7 +1920,8 @@ zonelist_scan:
 		 * back to remote zones that do not partake in the
 		 * fairness round-robin cycle of this zonelist.
 		 */
-		if (alloc_flags & ALLOC_WMARK_LOW) {
+		if ((alloc_flags & ALLOC_WMARK_LOW) &&
+		    (gfp_mask & GFP_MOVABLE_MASK)) {
 			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 				continue;
 			if (zone_reclaim_mode &&
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
