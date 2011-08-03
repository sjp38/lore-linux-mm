Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5C63E6B0169
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 20:47:44 -0400 (EDT)
Subject: Re: [PATCH] kswapd: avoid unnecessary rebalance after an
 unsuccessful balancing
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <20110802102231.GC10436@suse.de>
References: <1311952990-3844-1-git-send-email-alex.shi@intel.com>
	 <20110729154031.GV3010@suse.de> <1312159517.27358.2446.camel@debian>
	 <20110802102231.GC10436@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 03 Aug 2011 08:49:42 +0800
Message-ID: <1312332582.27358.2540.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "P@draigBrady.com" <P@draigBrady.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andrea@cpushare.com" <andrea@cpushare.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "luto@mit.edu" <luto@mit.edu>


> You're right. I was thinking only of classzone_idx. I see the point now.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks for your 'Ack', I want to follow your commit comments and correct
a coding style issue, so I rewrite the patch here.

--------------

In commit 215ddd66, Mel Gorman said kswapd is better to sleep after a
unsuccessful balancing if there is tighter reclaim request pending in
the balancing. But in the following scenario, kswapd do something that
is not matched our expectation. The patch fixes this issue.

1, Read pgdat request A (classzone_idx, order = 3)
2, balance_pgdat()
3,    During pgdat, a new pgdat request B (classzone_idx, order = 5) is
placed
4, balance_pgdat() returns but failed since returned order = 0
5, pgdat of request A assigned to balance_pgdat(), and do balancing
again. While the expectation behavior of kswapd should try to sleep.

Signed-off-by: Alex Shi <alex.shi@intel.com>
Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb7bcce..ed8c84c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2792,7 +2792,9 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 static int kswapd(void *p)
 {
 	unsigned long order, new_order;
+	unsigned balanced_order;
 	int classzone_idx, new_classzone_idx;
+	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -2823,7 +2825,9 @@ static int kswapd(void *p)
 	set_freezable();
 
 	order = new_order = 0;
+	balanced_order = 0;
 	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
+	balanced_classzone_idx = classzone_idx;
 	for ( ; ; ) {
 		int ret;
 
@@ -2832,7 +2836,8 @@ static int kswapd(void *p)
 		 * new request of a similar or harder type will succeed soon
 		 * so consider going to sleep on the basis we reclaimed at
 		 */
-		if (classzone_idx >= new_classzone_idx && order == new_order) {
+		if (balanced_classzone_idx >= new_classzone_idx &&
+					balanced_order == new_order) {
 			new_order = pgdat->kswapd_max_order;
 			new_classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order =  0;
@@ -2847,7 +2852,8 @@ static int kswapd(void *p)
 			order = new_order;
 			classzone_idx = new_classzone_idx;
 		} else {
-			kswapd_try_to_sleep(pgdat, order, classzone_idx);
+			kswapd_try_to_sleep(pgdat, balanced_order,
+						balanced_classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
 			new_order = order;
@@ -2866,7 +2872,9 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			order = balance_pgdat(pgdat, order, &classzone_idx);
+			balanced_classzone_idx = classzone_idx;
+			balanced_order = balance_pgdat(pgdat, order,
+						&balanced_classzone_idx);
 		}
 	}
 	return 0;
-- 
1.6.3.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
