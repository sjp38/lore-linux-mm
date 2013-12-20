Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4468F6B0089
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 09:54:17 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so1127213eak.30
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 06:54:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si9076541eeh.113.2013.12.20.06.54.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 06:54:16 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] Revert "mm: page_alloc: exclude unreclaimable allocations from zone fairness policy"
Date: Fri, 20 Dec 2013 14:54:11 +0000
Message-Id: <1387551252-23375-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1387551252-23375-1-git-send-email-mgorman@suse.de>
References: <1387551252-23375-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This reverts commit 73f038b863dfe98acabc7c36c17342b84ad52e94. The NUMA behaviour of
this patch is less than ideal. An alternative approch is to interleave allocations
only within local zones which is implemented in the next patch.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f861d02..580a5f0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1920,8 +1920,7 @@ zonelist_scan:
 		 * back to remote zones that do not partake in the
 		 * fairness round-robin cycle of this zonelist.
 		 */
-		if ((alloc_flags & ALLOC_WMARK_LOW) &&
-		    (gfp_mask & GFP_MOVABLE_MASK)) {
+		if (alloc_flags & ALLOC_WMARK_LOW) {
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
