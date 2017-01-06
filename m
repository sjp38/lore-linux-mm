Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 809FB6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 03:18:13 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id dh1so61999329wjb.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 00:18:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si1926562wmp.69.2017.01.06.00.18.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 00:18:12 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, page_alloc: don't check cpuset allowed twice in fast-path
Date: Fri,  6 Jan 2017 09:18:05 +0100
Message-Id: <20170106081805.26132-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Since commit 682a3385e773 ("mm, page_alloc: inline the fast path of the
zonelist iterator") we replace a NULL nodemask with cpuset_current_mems_allowed
in the fast path, so that get_page_from_freelist() filters nodes allowed by the
cpuset via for_next_zone_zonelist_nodemask(). In that case it's pointless to
also check __cpuset_zone_allowed(), which we can avoid by not using
ALLOC_CPUSET in that scenario.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c6d5f64feca..3d86fbe2f4f4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3754,9 +3754,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	if (cpusets_enabled()) {
 		alloc_mask |= __GFP_HARDWALL;
-		alloc_flags |= ALLOC_CPUSET;
 		if (!ac.nodemask)
 			ac.nodemask = &cpuset_current_mems_allowed;
+		else
+			alloc_flags |= ALLOC_CPUSET;
 	}
 
 	gfp_mask &= gfp_allowed_mask;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
