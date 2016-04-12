Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7AE6B0261
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:13:56 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id a140so47145374wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:13:56 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id cf3si29966999wjc.1.2016.04.12.03.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:13:55 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 11A641C256D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:13:55 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 16/24] mm, page_alloc: Move __GFP_HARDWALL modifications out of the fastpath
Date: Tue, 12 Apr 2016 11:12:17 +0100
Message-Id: <1460455945-29644-17-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

__GFP_HARDWALL only has meaning in the context of cpusets but the fast path
always applies the flag on the first attempt. Move the manipulations into
the cpuset paths where they will be masked by a static branch in the common
case.

With the other micro-optimisations in this series combined, the impact on
a page allocator microbenchmark is

                                           4.6.0-rc2                  4.6.0-rc2
                                       decstat-v1r20                micro-v1r20
Min      alloc-odr0-1               381.00 (  0.00%)           377.00 (  1.05%)
Min      alloc-odr0-2               275.00 (  0.00%)           273.00 (  0.73%)
Min      alloc-odr0-4               229.00 (  0.00%)           226.00 (  1.31%)
Min      alloc-odr0-8               199.00 (  0.00%)           196.00 (  1.51%)
Min      alloc-odr0-16              186.00 (  0.00%)           183.00 (  1.61%)
Min      alloc-odr0-32              179.00 (  0.00%)           175.00 (  2.23%)
Min      alloc-odr0-64              174.00 (  0.00%)           172.00 (  1.15%)
Min      alloc-odr0-128             172.00 (  0.00%)           170.00 (  1.16%)
Min      alloc-odr0-256             181.00 (  0.00%)           183.00 ( -1.10%)
Min      alloc-odr0-512             193.00 (  0.00%)           191.00 (  1.04%)
Min      alloc-odr0-1024            201.00 (  0.00%)           199.00 (  1.00%)
Min      alloc-odr0-2048            206.00 (  0.00%)           204.00 (  0.97%)
Min      alloc-odr0-4096            212.00 (  0.00%)           210.00 (  0.94%)
Min      alloc-odr0-8192            215.00 (  0.00%)           213.00 (  0.93%)
Min      alloc-odr0-16384           216.00 (  0.00%)           214.00 (  0.93%)

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 73dc0413e997..219e0d05ed88 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3353,7 +3353,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
-	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
+	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
 		.zonelist = zonelist,
@@ -3362,6 +3362,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	};
 
 	if (cpusets_enabled()) {
+		alloc_mask |= __GFP_HARDWALL;
 		alloc_flags |= ALLOC_CPUSET;
 		if (!ac.nodemask)
 			ac.nodemask = &cpuset_current_mems_allowed;
@@ -3391,7 +3392,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 	/* First allocation attempt */
-	alloc_mask = gfp_mask|__GFP_HARDWALL;
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
 	if (unlikely(!page)) {
 		/*
@@ -3417,8 +3417,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 * the mask is being updated. If a page allocation is about to fail,
 	 * check if the cpuset changed during allocation and if so, retry.
 	 */
-	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie))) {
+		alloc_mask = gfp_mask;
 		goto retry_cpuset;
+	}
 
 	return page;
 }
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
