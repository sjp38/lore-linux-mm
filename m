Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 757CA6B008C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:37:00 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 20/34] kswapd: avoid unnecessary rebalance after an unsuccessful balancing
Date: Thu, 19 Jul 2012 15:36:30 +0100
Message-Id: <1342708604-26540-21-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: "Alex,Shi" <alex.shi@intel.com>

commit d2ebd0f6b89567eb93ead4e2ca0cbe03021f344b upstream.

Stable note: Fixes https://bugzilla.redhat.com/show_bug.cgi?id=712019. This
	patch reduces kswapd CPU usage.

In commit 215ddd66 ("mm: vmscan: only read new_classzone_idx from pgdat
when reclaiming successfully") , Mel Gorman said kswapd is better to sleep
after a unsuccessful balancing if there is tighter reclaim request pending
in the balancing.  But in the following scenario, kswapd do something that
is not matched our expectation.  The patch fixes this issue.

1, Read pgdat request A (classzone_idx, order = 3)
2, balance_pgdat()
3, During pgdat, a new pgdat request B (classzone_idx, order = 5) is placed
4, balance_pgdat() returns but failed since returned order = 0
5, pgdat of request A assigned to balance_pgdat(), and do balancing again.
   While the expectation behavior of kswapd should try to sleep.

Signed-off-by: Alex Shi <alex.shi@intel.com>
Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Tested-by: PA!draig Brady <P@draigBrady.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index aa75861..bf85e4d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2841,7 +2841,9 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 static int kswapd(void *p)
 {
 	unsigned long order, new_order;
+	unsigned balanced_order;
 	int classzone_idx, new_classzone_idx;
+	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -2872,7 +2874,9 @@ static int kswapd(void *p)
 	set_freezable();
 
 	order = new_order = 0;
+	balanced_order = 0;
 	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
+	balanced_classzone_idx = classzone_idx;
 	for ( ; ; ) {
 		int ret;
 
@@ -2881,7 +2885,8 @@ static int kswapd(void *p)
 		 * new request of a similar or harder type will succeed soon
 		 * so consider going to sleep on the basis we reclaimed at
 		 */
-		if (classzone_idx >= new_classzone_idx && order == new_order) {
+		if (balanced_classzone_idx >= new_classzone_idx &&
+					balanced_order == new_order) {
 			new_order = pgdat->kswapd_max_order;
 			new_classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order =  0;
@@ -2896,7 +2901,8 @@ static int kswapd(void *p)
 			order = new_order;
 			classzone_idx = new_classzone_idx;
 		} else {
-			kswapd_try_to_sleep(pgdat, order, classzone_idx);
+			kswapd_try_to_sleep(pgdat, balanced_order,
+						balanced_classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order = 0;
@@ -2913,7 +2919,9 @@ static int kswapd(void *p)
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
