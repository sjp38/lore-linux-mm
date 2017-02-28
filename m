Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA6F6B03C2
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:11:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u199so6339750wmd.4
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:11:35 -0800 (PST)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id 31si2815159wrs.143.2017.02.28.07.11.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 07:11:34 -0800 (PST)
Received: by mail-wr0-f193.google.com with SMTP id q39so2005450wrb.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:11:34 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-4.9 2/2] mm, vmscan: consider eligible zones in get_scan_count
Date: Tue, 28 Feb 2017 16:11:08 +0100
Message-Id: <20170228151108.20853-3-mhocko@kernel.org>
In-Reply-To: <20170228151108.20853-1-mhocko@kernel.org>
References: <20170228151108.20853-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Trevor Cordes <trevor@tecnopolis.ca>

From: Michal Hocko <mhocko@suse.com>

commit 71ab6cfe88dcf9f6e6a65eb85cf2bda20a257682 upstream.

get_scan_count() considers the whole node LRU size when

 - doing SCAN_FILE due to many page cache inactive pages
 - calculating the number of pages to scan

In both cases this might lead to unexpected behavior especially on 32b
systems where we can expect lowmem memory pressure very often.

A large highmem zone can easily distort SCAN_FILE heuristic because
there might be only few file pages from the eligible zones on the node
lru and we would still enforce file lru scanning which can lead to
trashing while we could still scan anonymous pages.

The later use of lruvec_lru_size can be problematic as well.  Especially
when there are not many pages from the eligible zones.  We would have to
skip over many pages to find anything to reclaim but shrink_node_memcg
would only reduce the remaining number to scan by SWAP_CLUSTER_MAX at
maximum.  Therefore we can end up going over a large LRU many times
without actually having chance to reclaim much if anything at all.  The
closer we are out of memory on lowmem zone the worse the problem will
be.

Fix this by filtering out all the ineligible zones when calculating the
lru size for both paths and consider only sc->reclaim_idx zones.

The patch would need to be tweaked a bit to apply to 4.10 and older but
I will do that as soon as it hits the Linus tree in the next merge
window.

Link: http://lkml.kernel.org/r/20170117103702.28542-3-mhocko@kernel.org
Fixes: b2e18757f2c9 ("mm, vmscan: begin reclaiming pages on a per-node basis")
Signed-off-by: Michal Hocko <mhocko@suse.com>
Tested-by: Trevor Cordes <trevor@tecnopolis.ca>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org>	[4.8+]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/vmscan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index cd516c632e8f..30a88b945a44 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2205,7 +2205,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_list_is_low(lruvec, true, sc) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES) >> sc->priority) {
+	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2272,7 +2272,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
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
