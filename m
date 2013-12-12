Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id AD19B6B0036
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:06:23 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id q10so254110ead.3
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 07:06:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si24037044eeh.176.2013.12.12.07.06.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 07:06:22 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] mm: page_alloc: exclude unreclaimable allocations from zone fairness policy
Date: Thu, 12 Dec 2013 15:06:16 +0000
Message-Id: <1386860779-2301-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1386860779-2301-1-git-send-email-mgorman@suse.de>
References: <1386860779-2301-1-git-send-email-mgorman@suse.de>
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
