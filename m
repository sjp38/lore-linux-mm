Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3826B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 22:42:48 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ao6so64069692pac.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:42:48 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id gk6si6644195pac.121.2016.06.15.19.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 19:42:47 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id hf6so2631475pac.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:42:47 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v3] mm/compaction: remove unnecessary order check in direct compact path
Date: Thu, 16 Jun 2016 10:42:36 +0800
Message-Id: <1466044956-3690-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mhocko@suse.com, mina86@mina86.com, minchan@kernel.org, mgorman@techsingularity.net, rientjes@google.com, kirill.shutemov@linux.intel.com, izumi.taku@jp.fujitsu.com, hannes@cmpxchg.org, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

In direct compact path, both __alloc_pages_direct_compact and
try_to_compact_pages check (order == 0).

This patch removes the check in __alloc_pages_direct_compact() and
move the modifying of current->flags to the entry point of direct
page compaction where we really do the compaction.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
v2:
  remove the check in __alloc_pages_direct_compact - Anshuman Khandual
v3:
  remove check in __alloc_pages_direct_compact and move current->flags
  modifying to try_to_compact_pages
---
 mm/compaction.c | 7 ++++++-
 mm/page_alloc.c | 5 -----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index fbb7b38..dcfaf57 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1686,12 +1686,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 
 	*contended = COMPACT_CONTENDED_NONE;
 
-	/* Check if the GFP flags allow compaction */
+	/*
+	 * Check if this is an order-0 request and
+	 * if the GFP flags allow compaction.
+	 */
 	if (!order || !may_enter_fs || !may_perform_io)
 		return COMPACT_SKIPPED;
 
 	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode);
 
+	current->flags |= PF_MEMALLOC;
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
@@ -1768,6 +1772,7 @@ break_loop:
 		all_zones_contended = 0;
 		break;
 	}
+	current->flags &= ~PF_MEMALLOC;
 
 	/*
 	 * If at least one zone wasn't deferred or skipped, we report if all
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b9ea618..dd3a2b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3173,13 +3173,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct page *page;
 	int contended_compaction;
 
-	if (!order)
-		return NULL;
-
-	current->flags |= PF_MEMALLOC;
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
 						mode, &contended_compaction);
-	current->flags &= ~PF_MEMALLOC;
 
 	if (*compact_result <= COMPACT_INACTIVE)
 		return NULL;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
