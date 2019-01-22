Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54B438E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 15:10:07 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id b14so14530633itd.1
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 12:10:07 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id p6si9322150itm.58.2019.01.22.12.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 12:10:04 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH] mm: vmscan: do not iterate all mem cgroups for global direct reclaim
Date: Wed, 23 Jan 2019 04:09:42 +0800
Message-Id: <1548187782-108454-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In current implementation, both kswapd and direct reclaim has to iterate
all mem cgroups.  It is not a problem before offline mem cgroups could
be iterated.  But, currently with iterating offline mem cgroups, it
could be very time consuming.  In our workloads, we saw over 400K mem
cgroups accumulated in some cases, only a few hundred are online memcgs.
Although kswapd could help out to reduce the number of memcgs, direct
reclaim still get hit with iterating a number of offline memcgs in some
cases.  We experienced the responsiveness problems due to this
occassionally.

Here just break the iteration once it reclaims enough pages as what
memcg direct reclaim does.  This may hurt the fairness among memcgs
since direct reclaim may awlays do reclaim from same memcgs.  But, it
sounds ok since direct reclaim just tries to reclaim SWAP_CLUSTER_MAX
pages and memcgs can be protected by min/low.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/vmscan.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a714c4f..ced5a16 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2764,16 +2764,15 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 				   sc->nr_reclaimed - reclaimed);
 
 			/*
-			 * Direct reclaim and kswapd have to scan all memory
-			 * cgroups to fulfill the overall scan target for the
-			 * node.
+			 * Kswapd have to scan all memory cgroups to fulfill
+			 * the overall scan target for the node.
 			 *
 			 * Limit reclaim, on the other hand, only cares about
 			 * nr_to_reclaim pages to be reclaimed and it will
 			 * retry with decreasing priority if one round over the
 			 * whole hierarchy is not sufficient.
 			 */
-			if (!global_reclaim(sc) &&
+			if ((!global_reclaim(sc) || !current_is_kswapd()) &&
 					sc->nr_reclaimed >= sc->nr_to_reclaim) {
 				mem_cgroup_iter_break(root, memcg);
 				break;
-- 
1.8.3.1
