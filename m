Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id AD7DB6B0257
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:10:01 -0400 (EDT)
Received: by wijp15 with SMTP id p15so75695844wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:10:01 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id fs15si21113629wic.53.2015.08.24.05.09.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:09:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 725D9990E6
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:09:53 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/12] mm, page_alloc: Remove unecessary recheck of nodemask
Date: Mon, 24 Aug 2015 13:09:44 +0100
Message-Id: <1440418191-10894-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

An allocation request will either use the given nodemask or the cpuset
current tasks mems_allowed. A cpuset retry will recheck the callers nodemask
and while it's trivial overhead during an extremely rare operation, also
unnecessary. This patch fixes it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c1c3bf54d15..32d1cec124bc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3171,7 +3171,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
-		.nodemask = nodemask,
+		.nodemask = nodemask ? : &cpuset_current_mems_allowed,
 		.migratetype = gfpflags_to_migratetype(gfp_mask),
 	};
 
@@ -3206,8 +3206,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
-				ac.nodemask ? : &cpuset_current_mems_allowed,
-				&ac.preferred_zone);
+				ac.nodemask, &ac.preferred_zone);
 	if (!ac.preferred_zone)
 		goto out;
 	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
