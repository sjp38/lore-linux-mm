Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA91E8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:54:38 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so34862056edb.22
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:54:38 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id l1si937018edc.252.2019.01.04.04.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:54:37 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 0A7B71C1C22
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:54:37 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 25/25] mm, compaction: Do not direct compact remote memory
Date: Fri,  4 Jan 2019 12:50:11 +0000
Message-Id: <20190104125011.16071-26-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Remote compaction is expensive and possibly counter-productive. Locality
is expected to often have better performance characteristics than remote
high-order pages. For small allocations, it's expected that locality is
generally required or fallbacks are possible. For larger allocations such
as THP, they are forbidden at the time of writing but if __GFP_THISNODE
is ever removed, then it would still be preferable to fallback to small
local base pages over remote THP in the general case. kcompactd is still
woken via kswapd so compaction happens eventually.

While this patch potentially has both positive and negative effects,
it is best to avoid the possibility of remote compaction given the cost
relative to any potential benefit.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index ae70be023b21..cc17f0c01811 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2348,6 +2348,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			continue;
 		}
 
+		/*
+		 * Do not compact remote memory. It's expensive and high-order
+		 * small allocations are expected to prefer or require local
+		 * memory. Similarly, larger requests such as THP can fallback
+		 * to base pages in preference to remote huge pages if
+		 * __GFP_THISNODE is not specified
+		 */
+		if (zone_to_nid(zone) != zone_to_nid(ac->preferred_zoneref->zone))
+			continue;
+
 		status = compact_zone_order(zone, order, gfp_mask, prio,
 				alloc_flags, ac_classzone_idx(ac), capture);
 		rc = max(status, rc);
-- 
2.16.4
