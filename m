Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2B876B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 17:34:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d127so7671496pga.11
        for <linux-mm@kvack.org>; Mon, 01 May 2017 14:34:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b34sor202621plc.6.2017.05.01.14.34.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 May 2017 14:34:23 -0700 (PDT)
Date: Mon, 1 May 2017 14:34:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file is
 low
In-Reply-To: <20170420060904.GA3720@bbox>
Message-ID: <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com> <20170418013659.GD21354@bbox> <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com> <20170419001405.GA13364@bbox> <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
 <20170420060904.GA3720@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The purpose of the code that commit 623762517e23 ("revert 'mm: vmscan: do
not swap anon pages just because free+file is low'") reintroduces is to
prefer swapping anonymous memory rather than trashing the file lru.

If the anonymous inactive lru for the set of eligible zones is considered
low, however, or the length of the list for the given reclaim priority
does not allow for effective anonymous-only reclaiming, then avoid
forcing SCAN_ANON.  Forcing SCAN_ANON will end up thrashing the small
list and leave unreclaimed memory on the file lrus.

If the inactive list is insufficient, fallback to balanced reclaim so the
file lru doesn't remain untouched.

Suggested-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 to akpm: this issue has been possible since at least 3.15, so it's
 probably not high priority for 4.12 but applies cleanly if it can sneak
 in

 mm/vmscan.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2204,8 +2204,17 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		}
 
 		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
-			scan_balance = SCAN_ANON;
-			goto out;
+			/*
+			 * Force SCAN_ANON if there are enough inactive
+			 * anonymous pages on the LRU in eligible zones.
+			 * Otherwise, the small LRU gets thrashed.
+			 */
+			if (!inactive_list_is_low(lruvec, false, sc, false) &&
+			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
+					>> sc->priority) {
+				scan_balance = SCAN_ANON;
+				goto out;
+			}
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
