Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7DA2806D2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 09:55:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p14so27362704wrg.8
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:55:03 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id p88si7832812wmf.209.2017.08.22.06.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 06:55:01 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 1/2] mm: Track actual nr_scanned during shrink_slab()
Date: Tue, 22 Aug 2017 14:53:24 +0100
Message-Id: <20170822135325.9191-1-chris@chris-wilson.co.uk>
In-Reply-To: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
References: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

Some shrinkers may only be able to free a bunch of objects at a time, and
so free more than the requested nr_to_scan in one pass. Whilst other
shrinkers may find themselves even unable to scan as many objects as
they counted, and so underreport. Account for the extra freed/scanned
objects against the total number of objects we intend to scan, otherwise
we may end up penalising the slab far more than intended. Similarly,
we want to add the underperforming scan to the deferred pass so that we
try harder and harder in future passes.

v2: Andrew's shrinkctl->nr_scanned

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org
---
 include/linux/shrinker.h | 7 +++++++
 mm/vmscan.c              | 7 ++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 4fcacd915d45..51d189615bda 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -18,6 +18,13 @@ struct shrink_control {
 	 */
 	unsigned long nr_to_scan;
 
+	/*
+	 * How many objects did scan_objects process?
+	 * This defaults to nr_to_scan before every call, but the callee
+	 * should track its actual progress.
+	 */
+	unsigned long nr_scanned;
+
 	/* current node being shrunk (for NUMA aware shrinkers) */
 	int nid;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1af041930a6..339b8fc95fc9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -393,14 +393,15 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		unsigned long nr_to_scan = min(batch_size, total_scan);
 
 		shrinkctl->nr_to_scan = nr_to_scan;
+		shrinkctl->nr_scanned = nr_to_scan;
 		ret = shrinker->scan_objects(shrinker, shrinkctl);
 		if (ret == SHRINK_STOP)
 			break;
 		freed += ret;
 
-		count_vm_events(SLABS_SCANNED, nr_to_scan);
-		total_scan -= nr_to_scan;
-		scanned += nr_to_scan;
+		count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
+		total_scan -= shrinkctl->nr_scanned;
+		scanned += shrinkctl->nr_scanned;
 
 		cond_resched();
 	}
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
