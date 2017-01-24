Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC976B0279
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 10:05:18 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so28430011wmt.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 07:05:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e191si18613669wmf.158.2017.01.24.07.05.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 07:05:17 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/2] mm, page_alloc: don't check cpuset allowed twice in fast-path
Date: Tue, 24 Jan 2017 16:05:11 +0100
Message-Id: <20170124150511.5710-2-vbabka@suse.cz>
In-Reply-To: <20170124150511.5710-1-vbabka@suse.cz>
References: <20170124150511.5710-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

Since commit 682a3385e773 ("mm, page_alloc: inline the fast path of the
zonelist iterator") we replace a NULL nodemask with cpuset_current_mems_allowed
in the fast path, so that get_page_from_freelist() filters nodes allowed by the
cpuset via for_next_zone_zonelist_nodemask(). In that case it's pointless to
additionaly check __cpuset_zone_allowed() in each iteration, which we can avoid
by not adding ALLOC_CPUSET to alloc_flags in that scenario.

This saves some cycles in the allocator fast path on systems with one or more
non-root cpuset configured. In the slow path, ALLOC_CPUSET is reset according
to __alloc_pages_slowpath(). Without configured cpusets, this code is disabled
by a static key.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05068adf9007..407e5d89ad2e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3900,9 +3900,10 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 
 	if (cpusets_enabled()) {
 		*alloc_mask |= __GFP_HARDWALL;
-		*alloc_flags |= ALLOC_CPUSET;
 		if (!ac->nodemask)
 			ac->nodemask = &cpuset_current_mems_allowed;
+		else
+			*alloc_flags |= ALLOC_CPUSET;
 	}
 
 	lockdep_trace_alloc(gfp_mask);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
