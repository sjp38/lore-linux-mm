Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id BE5CD6B0275
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:15:49 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id n3so93430263wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:15:49 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id d203si17074928wmf.56.2016.04.11.01.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:15:48 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 73C2A1C149D
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:15:48 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 16/22] mm, page_alloc: Move __GFP_HARDWALL modifications out of the fastpath
Date: Mon, 11 Apr 2016 09:13:39 +0100
Message-Id: <1460362424-26369-17-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

__GFP_HARDWALL only has meaning in the context of cpusets but the fast path
always applies the flag on the first attempt. Move the manipulations into
the cpuset paths where they will be masked by a static branch in the common
case.

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
