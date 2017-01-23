Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 609096B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 07:24:13 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so26027951wjc.3
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 04:24:13 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id m80si14131634wmi.31.2017.01.23.04.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 04:24:12 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: ensure alloc_flags in slow path are initialized
Date: Mon, 23 Jan 2017 13:16:12 +0100
Message-Id: <20170123121649.3180300-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The __alloc_pages_slowpath() has gotten rather complex and gcc
is no longer able to follow the gotos and prove that the
alloc_flags variable is initialized at the time it is used:

mm/page_alloc.c: In function '__alloc_pages_slowpath':
mm/page_alloc.c:3565:15: error: 'alloc_flags' may be used uninitialized in this function [-Werror=maybe-uninitialized]

To be honest, I can't figure that out either, maybe it is or
maybe not, but moving the existing initialization up a little
higher looks safe and makes it obvious to both me and gcc that
the initialization comes before the first use.

Fixes: 74eaa4a97e8e ("mm: consolidate GFP_NOFAIL checks in the allocator slowpath")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/page_alloc.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cf641932c015..d9fa4564524f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3591,6 +3591,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
 		gfp_mask &= ~__GFP_ATOMIC;
 
+	/*
+	 * The fast path uses conservative alloc_flags to succeed only until
+	 * kswapd needs to be woken up, and to avoid the cost of setting up
+	 * alloc_flags precisely. So we do that now.
+	 */
+	alloc_flags = gfp_to_alloc_flags(gfp_mask);
+
 retry_cpuset:
 	compaction_retries = 0;
 	no_progress_loops = 0;
@@ -3607,14 +3614,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (!ac->preferred_zoneref->zone)
 		goto nopage;
 
-
-	/*
-	 * The fast path uses conservative alloc_flags to succeed only until
-	 * kswapd needs to be woken up, and to avoid the cost of setting up
-	 * alloc_flags precisely. So we do that now.
-	 */
-	alloc_flags = gfp_to_alloc_flags(gfp_mask);
-
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
