Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 648E2828DF
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:00:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a140so13020089wma.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:00:23 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id z130si10902655wmb.37.2016.04.15.02.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:00:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id DEB781C19CA
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:00:21 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/28] mm, page_alloc: Inline the fast path of the zonelist iterator
Date: Fri, 15 Apr 2016 09:58:57 +0100
Message-Id: <1460710760-32601-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The page allocator iterates through a zonelist for zones that match
the addressing limitations and nodemask of the caller but many allocations
will not be restricted. Despite this, there is always functional call
overhead which builds up.

This patch inlines the optimistic basic case and only calls the
iterator function for the complex case. A hindrance was the fact that
cpuset_current_mems_allowed is used in the fastpath as the allowed nodemask
even though all nodes are allowed on most systems. The patch handles this
by only considering cpuset_current_mems_allowed if a cpuset exists. As well
as being faster in the fast-path, this removes some junk in the slowpath.

The performance difference on a page allocator microbenchmark is;

                                           4.6.0-rc2                  4.6.0-rc2
                                    statinline-v1r20              optiter-v1r20
Min      alloc-odr0-1               412.00 (  0.00%)           382.00 (  7.28%)
Min      alloc-odr0-2               301.00 (  0.00%)           282.00 (  6.31%)
Min      alloc-odr0-4               247.00 (  0.00%)           233.00 (  5.67%)
Min      alloc-odr0-8               215.00 (  0.00%)           203.00 (  5.58%)
Min      alloc-odr0-16              199.00 (  0.00%)           188.00 (  5.53%)
Min      alloc-odr0-32              191.00 (  0.00%)           182.00 (  4.71%)
Min      alloc-odr0-64              187.00 (  0.00%)           177.00 (  5.35%)
Min      alloc-odr0-128             185.00 (  0.00%)           175.00 (  5.41%)
Min      alloc-odr0-256             193.00 (  0.00%)           184.00 (  4.66%)
Min      alloc-odr0-512             207.00 (  0.00%)           197.00 (  4.83%)
Min      alloc-odr0-1024            213.00 (  0.00%)           203.00 (  4.69%)
Min      alloc-odr0-2048            220.00 (  0.00%)           209.00 (  5.00%)
Min      alloc-odr0-4096            226.00 (  0.00%)           214.00 (  5.31%)
Min      alloc-odr0-8192            229.00 (  0.00%)           218.00 (  4.80%)
Min      alloc-odr0-16384           229.00 (  0.00%)           219.00 (  4.37%)

perf indicated that next_zones_zonelist disappeared in the profile and
__next_zones_zonelist did not appear. This is expected as the micro-benchmark
would hit the inlined fast-path every time.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h | 13 +++++++++++--
 mm/mmzone.c            |  2 +-
 mm/page_alloc.c        | 26 +++++++++-----------------
 3 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c60df9257cc7..0c4d5ebb3849 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -922,6 +922,10 @@ static inline int zonelist_node_idx(struct zoneref *zoneref)
 #endif /* CONFIG_NUMA */
 }
 
+struct zoneref *__next_zones_zonelist(struct zoneref *z,
+					enum zone_type highest_zoneidx,
+					nodemask_t *nodes);
+
 /**
  * next_zones_zonelist - Returns the next zone at or below highest_zoneidx within the allowed nodemask using a cursor within a zonelist as a starting point
  * @z - The cursor used as a starting point for the search
@@ -934,9 +938,14 @@ static inline int zonelist_node_idx(struct zoneref *zoneref)
  * being examined. It should be advanced by one before calling
  * next_zones_zonelist again.
  */
-struct zoneref *next_zones_zonelist(struct zoneref *z,
+static __always_inline struct zoneref *next_zones_zonelist(struct zoneref *z,
 					enum zone_type highest_zoneidx,
-					nodemask_t *nodes);
+					nodemask_t *nodes)
+{
+	if (likely(!nodes && zonelist_zone_idx(z) <= highest_zoneidx))
+		return z;
+	return __next_zones_zonelist(z, highest_zoneidx, nodes);
+}
 
 /**
  * first_zones_zonelist - Returns the first zone at or below highest_zoneidx within the allowed nodemask in a zonelist
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 52687fb4de6f..5652be858e5e 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -52,7 +52,7 @@ static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
 }
 
 /* Returns the next zone at or below highest_zoneidx in a zonelist */
-struct zoneref *next_zones_zonelist(struct zoneref *z,
+struct zoneref *__next_zones_zonelist(struct zoneref *z,
 					enum zone_type highest_zoneidx,
 					nodemask_t *nodes)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b56c2b2911a2..e9acc0b0f787 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3193,17 +3193,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
-	/*
-	 * Find the true preferred zone if the allocation is unconstrained by
-	 * cpusets.
-	 */
-	if (!(alloc_flags & ALLOC_CPUSET) && !ac->nodemask) {
-		struct zoneref *preferred_zoneref;
-		preferred_zoneref = first_zones_zonelist(ac->zonelist,
-				ac->high_zoneidx, NULL, &ac->preferred_zone);
-		ac->classzone_idx = zonelist_zone_idx(preferred_zoneref);
-	}
-
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
@@ -3359,14 +3348,21 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
 	unsigned int cpuset_mems_cookie;
-	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
+	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
+		.zonelist = zonelist,
 		.nodemask = nodemask,
 		.migratetype = gfpflags_to_migratetype(gfp_mask),
 	};
 
+	if (cpusets_enabled()) {
+		alloc_flags |= ALLOC_CPUSET;
+		if (!ac.nodemask)
+			ac.nodemask = &cpuset_current_mems_allowed;
+	}
+
 	gfp_mask &= gfp_allowed_mask;
 
 	lockdep_trace_alloc(gfp_mask);
@@ -3390,16 +3386,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
-	/* We set it here, as __alloc_pages_slowpath might have changed it */
-	ac.zonelist = zonelist;
-
 	/* Dirty zone balancing only done in the fast path */
 	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
 
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
-				ac.nodemask ? : &cpuset_current_mems_allowed,
-				&ac.preferred_zone);
+				ac.nodemask, &ac.preferred_zone);
 	if (!ac.preferred_zone)
 		goto out;
 	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
