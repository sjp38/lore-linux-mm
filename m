Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7FF16B0006
	for <linux-mm@kvack.org>; Fri, 25 May 2018 09:09:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id t15-v6so4212148wrm.3
        for <linux-mm@kvack.org>; Fri, 25 May 2018 06:09:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35-v6si2149528edi.14.2018.05.25.06.09.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 May 2018 06:09:18 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, page_alloc: do not break __GFP_THISNODE by zonelist reset
Date: Fri, 25 May 2018 15:08:53 +0200
Message-Id: <20180525130853.13915-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

In __alloc_pages_slowpath() we reset zonelist and preferred_zoneref for
allocations that can ignore memory policies. The zonelist is obtained from
current CPU's node. This is a problem for __GFP_THISNODE allocations that want
to allocate on a different node, e.g. because the allocating thread has been
migrated to a different CPU.

This has been observed to break SLAB in our 4.4-based kernel, because there it
relies on __GFP_THISNODE working as intended. If a slab page is put on wrong
node's list, then further list manipulations may corrupt the list because
page_to_nid() is used to determine which node's list_lock should be locked and
thus we may take a wrong lock and race.

Current SLAB implementation seems to be immune by luck thanks to commit
511e3a058812 ("mm/slab: make cache_grow() handle the page allocated on
arbitrary node") but there may be others assuming that __GFP_THISNODE works as
promised.

We can fix it by simply removing the zonelist reset completely. There is
actually no reason to reset it, because memory policies and cpusets don't
affect the zonelist choice in the first place. This was different when commit
183f6371aac2 ("mm: ignore mempolicies when using ALLOC_NO_WATERMARK")
introduced the code, as mempolicies provided their own restricted zonelists.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Fixes: 183f6371aac2 ("mm: ignore mempolicies when using ALLOC_NO_WATERMARK")
Cc: <stable@vger.kernel.org>
---
Hi,

we might consider this for 4.17 although I don't know if there's anything
currently broken. Stable backports should be more important, but will have to
be reviewed carefully, as the code went through many changes.
BTW I think that also the ac->preferred_zoneref reset is currently useless if
we don't also reset ac->nodemask from a mempolicy to NULL first (which we
probably should for the OOM victims etc?), but I would leave that for a
separate patch.

Vlastimil

 mm/page_alloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d7962f..be0f0b5d3935 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4165,7 +4165,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * orientated.
 	 */
 	if (!(alloc_flags & ALLOC_CPUSET) || reserve_flags) {
-		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
 					ac->high_zoneidx, ac->nodemask);
 	}
-- 
2.17.0
