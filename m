Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C8BBB6B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 21:43:47 -0400 (EDT)
From: Alex Shi <alex.shi@intel.com>
Subject: [PATCH] kswapd: assign new_order and new_classzone_idx after wakeup in sleeping
Date: Fri, 29 Jul 2011 09:45:08 +0800
Message-Id: <1311903908-18263-1-git-send-email-alex.shi@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, P@draigBrady.com
Cc: mgorman@suse.de, minchan.kim@gmail.com, linux-kernel@vger.kernel.org, andrea@cpushare.com, tim.c.chen@intel.com, shaohua.li@intel.com, akpm@linux-foundation.org, riel@redhat.com, luto@mit.edu

There 2 place to read pgdat in kswapd. One is return from a successful
balance, another is waked up from sleeping. But the new_order and
new_classzone_idx are not assigned after kswapd_try_to_sleep(), that
will cause a bug in the following scenario.

After the last time successful balance, kswapd goes to sleep. So the
new_order and new_classzone_idx were assigned to 0 and MAX-1 since there
is no new wakeup during last time balancing. Now, a new wakeup came and
finish balancing successful with order > 0. But since new_order is still
0, this time successful balancing were judged as a failed balance. so,
if there is another new wakeup coming during balancing, kswapd cann't
read this and still want to try to sleep. And if the new wakeup is a
tighter request, kswapd may goes to sleep, not to do balancing. That is
incorrect.

So, to avoid above problem, the new_order and new_classzone_idx need to
be assigned for later successful comparison.

Paidrag Brady, Could like do a retry for your problem on this patch?

Signed-off-by: Alex Shi <alex.shi@intel.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7ef6912..eb7bcce 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2850,6 +2850,8 @@ static int kswapd(void *p)
 			kswapd_try_to_sleep(pgdat, order, classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
+			new_order = order;
+			new_classzone_idx = classzone_idx;
 			pgdat->kswapd_max_order = 0;
 			pgdat->classzone_idx = pgdat->nr_zones - 1;
 		}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
