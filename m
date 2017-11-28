Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0C06B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 20:53:12 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t77so15514129pfe.10
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:53:12 -0800 (PST)
Received: from mxhk.zte.com.cn (mxhk.zte.com.cn. [63.217.80.70])
        by mx.google.com with ESMTPS id bg3si4099576plb.420.2017.11.27.17.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 17:53:11 -0800 (PST)
From: Jiang Biao <jiang.biao2@zte.com.cn>
Subject: [PATCH] mm/vmscan: try to optimize branch procedures.
Date: Tue, 28 Nov 2017 09:49:45 +0800
Message-Id: <1511833785-55392-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jiang.biao2@zte.com.cn, zhong.weidong@zte.com.cn

1. Use unlikely to try to improve branch prediction. The
*total_scan < 0* branch is unlikely to reach, so use unlikely.

2. Optimize *next_deferred >= scanned* condition.
*next_deferred >= scanned* condition could be optimized into
*next_deferred > scanned*, because when *next_deferred == scanned*,
next_deferred shoud be 0, which is covered by the else branch.

3. Merge two branch blocks into one. The *next_deferred > 0* branch
could be merged into *next_deferred > scanned* to simplify the code.

Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>
---
 mm/vmscan.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb2f031..5f5d4ab 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -338,7 +338,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	delta *= freeable;
 	do_div(delta, nr_eligible + 1);
 	total_scan += delta;
-	if (total_scan < 0) {
+	if (unlikely(total_scan < 0)) {
 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
 		       shrinker->scan_objects, total_scan);
 		total_scan = freeable;
@@ -407,18 +407,16 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		cond_resched();
 	}
 
-	if (next_deferred >= scanned)
-		next_deferred -= scanned;
-	else
-		next_deferred = 0;
 	/*
 	 * move the unused scan count back into the shrinker in a
 	 * manner that handles concurrent updates. If we exhausted the
 	 * scan, there is no need to do an update.
 	 */
-	if (next_deferred > 0)
+	if (next_deferred > scanned) {
+		next_deferred -= scanned;
 		new_nr = atomic_long_add_return(next_deferred,
 						&shrinker->nr_deferred[nid]);
+	}
 	else
 		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
