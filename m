Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11B696B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 05:37:13 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so16101201wjb.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:37:13 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id w72si10915133wrc.19.2017.01.17.02.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 02:37:11 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id c85so4908465wmi.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:37:11 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, vmscan: consider eligible zones in get_scan_count
Date: Tue, 17 Jan 2017 11:37:01 +0100
Message-Id: <20170117103702.28542-3-mhocko@kernel.org>
In-Reply-To: <20170117103702.28542-1-mhocko@kernel.org>
References: <20170117103702.28542-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

get_scan_count considers the whole node LRU size when
- doing SCAN_FILE due to many page cache inactive pages
- calculating the number of pages to scan

in both cases this might lead to unexpected behavior especially on 32b
systems where we can expect lowmem memory pressure very often.

A large highmem zone can easily distort SCAN_FILE heuristic because
there might be only few file pages from the eligible zones on the node
lru and we would still enforce file lru scanning which can lead to
trashing while we could still scan anonymous pages.

The later use of lruvec_lru_size can be problematic as well. Especially
when there are not many pages from the eligible zones. We would have to
skip over many pages to find anything to reclaim but shrink_node_memcg
would only reduce the remaining number to scan by SWAP_CLUSTER_MAX
at maximum. Therefore we can end up going over a large LRU many times
without actually having chance to reclaim much if anything at all. The
closer we are out of memory on lowmem zone the worse the problem will
be.

Fix this by filtering out all the ineligible zones when calculating the
lru size for both paths and consider only sc->reclaim_idx zones.

Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index aed39dc272c0..ffac8fa7bdd8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2235,7 +2235,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_list_is_low(lruvec, true, sc, false) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES) >> sc->priority) {
+	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2302,7 +2302,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			unsigned long size;
 			unsigned long scan;
 
-			size = lruvec_lru_size(lruvec, lru, MAX_NR_ZONES);
+			size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
 			scan = size >> sc->priority;
 
 			if (!scan && pass && force_scan)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
