Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id F19D16B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:00:12 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ts6so57188456pac.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:00:12 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id l8si5699857pal.70.2016.06.24.02.00.10
        for <linux-mm@kvack.org>;
        Fri, 24 Jun 2016 02:00:12 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: [PATCH] mm, vmscan: Make kswapd reclaim no more than needed
Date: Fri, 24 Jun 2016 16:59:55 +0800
Message-ID: <082f01d1cdf6$c789a2b0$569ce810$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

We stop reclaiming pages if any eligible zone is balanced.

Signed-off-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---

--- a/mm/vmscan.c	Thu Jun 23 17:56:34 2016
+++ b/mm/vmscan.c	Fri Jun 24 16:45:58 2016
@@ -3185,15 +3185,10 @@ static int balance_pgdat(pg_data_t *pgda
 			if (!populated_zone(zone))
 				continue;
 
-			if (!zone_balanced(zone, sc.order, classzone_idx)) {
-				classzone_idx = i;
-				break;
-			}
+			if (zone_balanced(zone, sc.order, classzone_idx))
+				goto out;
 		}
 
-		if (i < 0)
-			goto out;
-
 		/*
 		 * Do some background aging of the anon list, to give
 		 * pages a chance to be referenced before reclaiming. All
@@ -3236,19 +3231,6 @@ static int balance_pgdat(pg_data_t *pgda
 		/* Check if kswapd should be suspending */
 		if (try_to_freeze() || kthread_should_stop())
 			break;
-
-		/*
-		 * Stop reclaiming if any eligible zone is balanced and clear
-		 * node writeback or congested.
-		 */
-		for (i = 0; i <= classzone_idx; i++) {
-			zone = pgdat->node_zones + i;
-			if (!populated_zone(zone))
-				continue;
-
-			if (zone_balanced(zone, sc.order, classzone_idx))
-				goto out;
-		}
 
 		/*
 		 * Raise priority if scanning rate is too low or there was no
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
