Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1F38E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:06:04 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c18so3352390edt.23
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:06:04 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id l22si1221132edj.93.2018.12.14.15.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:06:03 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id D19B71C1DFE
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:06:02 +0000 (GMT)
Date: Fri, 14 Dec 2018 23:06:01 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 14/14] mm, compaction: Do not direct compact remote memory
Message-ID: <20181214230601.GE29005@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

Remote compaction is expensive and possibly counter-productive. Locality
is expected to often have better performance characteristics than remote
high-order pages. For small allocations, it's expected that locality is
generally required or fallbacks are possible. For larger allocations such
as THP, they are forbidden at the time of writing but if __GFP_THISNODE
is ever removed, then it would still be preferable to fallback to small
local base pages over remote THP in the general case. kcompactd is still
woken via kswapd so compaction happens eventually.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 39d33b6d1172..05fecd7227e4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2208,6 +2208,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
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


-- 
Mel Gorman
SUSE Labs
