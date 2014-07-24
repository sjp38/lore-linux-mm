Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 209946B0087
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 18:41:09 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id rd18so2959793iec.28
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:41:08 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id f13si253712igt.24.2014.07.24.15.41.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 15:41:08 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so2933123ier.27
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:41:08 -0700 (PDT)
Date: Thu, 24 Jul 2014 15:41:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: restructure thp avoidance of light synchronous
 migration
Message-ID: <alpine.DEB.2.02.1407241540190.22557@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

__GFP_NO_KSWAPD, once the way to determine if an allocation was for thp or not, 
has gained more users.  Their use is not necessarily wrong, they are trying to 
do a memory allocation that can easily fail without disturbing kswapd, so the 
bit has gained additional usecases.

This restructures the check to determine whether MIGRATE_SYNC_LIGHT should be 
used for memory compaction in the page allocator.  Rather than testing solely 
for __GFP_NO_KSWAPD, test for all bits that must be set for thp allocations.

This also moves the check to be done only after the page allocator is aborted 
for deferred or contended memory compaction since setting migration_mode for 
this case is pointless.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2616,14 +2616,6 @@ rebalance:
 		goto got_pg;
 
 	/*
-	 * It can become very expensive to allocate transparent hugepages at
-	 * fault, so use asynchronous memory compaction for THP unless it is
-	 * khugepaged trying to collapse.
-	 */
-	if (!(gfp_mask & __GFP_NO_KSWAPD) || (current->flags & PF_KTHREAD))
-		migration_mode = MIGRATE_SYNC_LIGHT;
-
-	/*
 	 * If compaction is deferred for high-order allocations, it is because
 	 * sync compaction recently failed. In this is the case and the caller
 	 * requested a movable allocation that does not heavily disrupt the
@@ -2633,6 +2625,15 @@ rebalance:
 						(gfp_mask & __GFP_NO_KSWAPD))
 		goto nopage;
 
+	/*
+	 * It can become very expensive to allocate transparent hugepages at
+	 * fault, so use asynchronous memory compaction for THP unless it is
+	 * khugepaged trying to collapse.
+	 */
+	if ((gfp_mask & GFP_TRANSHUGE) != GFP_TRANSHUGE ||
+						(current->flags & PF_KTHREAD))
+		migration_mode = MIGRATE_SYNC_LIGHT;
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
