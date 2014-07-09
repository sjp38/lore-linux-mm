Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id AC9B582965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 04:13:14 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so7074932wes.4
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:13:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg2si57320285wjb.78.2014.07.09.01.13.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 01:13:14 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/6] mm: vmscan: Only update per-cpu thresholds for online CPU
Date: Wed,  9 Jul 2014 09:13:06 +0100
Message-Id: <1404893588-21371-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1404893588-21371-1-git-send-email-mgorman@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

When kswapd is awake reclaiming, the per-cpu stat thresholds are
lowered to get more accurate counts to avoid breaching watermarks.  This
threshold update iterates over all possible CPUs which is unnecessary.
Only online CPUs need to be updated. If a new CPU is onlined,
refresh_zone_stat_thresholds() will set the thresholds correctly.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index e574e883..e9ab104 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -200,7 +200,7 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 			continue;
 
 		threshold = (*calculate_pressure)(zone);
-		for_each_possible_cpu(cpu)
+		for_each_online_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
 	}
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
