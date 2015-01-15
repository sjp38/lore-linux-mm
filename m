Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id E17FF6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:38:13 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id j5so14015165qga.7
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 14:38:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64si3703532qgt.111.2015.01.15.14.38.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 14:38:13 -0800 (PST)
Date: Fri, 16 Jan 2015 00:18:12 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] mm/vmscan: fix highidx argument type
Message-ID: <1421360175-18899-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

for_each_zone_zonelist_nodemask wants an enum zone_type
argument, but is passed gfp_t:

mm/vmscan.c:2658:9:    expected int enum zone_type [signed] highest_zoneidx
mm/vmscan.c:2658:9:    got restricted gfp_t [usertype] gfp_mask
mm/vmscan.c:2658:9: warning: incorrect type in argument 2 (different base types)
mm/vmscan.c:2658:9:    expected int enum zone_type [signed] highest_zoneidx
mm/vmscan.c:2658:9:    got restricted gfp_t [usertype] gfp_mask

convert argument to the correct type.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

In case this was already fixed, pls ignore - seems to still be
there in latest master.

 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ab2505c..dcd90c8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2656,7 +2656,7 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 	 * should make reasonable progress.
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-					gfp_mask, nodemask) {
+					gfp_zone(gfp_mask), nodemask) {
 		if (zone_idx(zone) > ZONE_NORMAL)
 			continue;
 
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
