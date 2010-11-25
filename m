Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 09B656B0089
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 05:51:52 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAPApnHK001016
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Nov 2010 19:51:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F00E45DE4C
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:51:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4462E45DE51
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:51:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EB39E78003
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:51:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 23B711DB8014
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:51:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101125090328.GB14180@hostway.ca>
References: <1290647274.12777.3.camel@sli10-conroe> <20101125090328.GB14180@hostway.ca>
Message-Id: <20101125180959.F462.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Nov 2010 19:51:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> kswapd is throwing out many times what is needed for the order 3
> watermark to be met.  It seems to be not as bad now, but look at these
> pages being reclaimed (200ms intervals, whitespace-packed buddyinfo
> followed by nr_pages_free calculation and final order-3 watermark test,
> kswapd woken after the second sample):
> 
> Normal zone at the same time (shown separately for clarity):
>
>   Zone order:0      1     2     3    4   5  6 7 8 9 A nr_free or3-low-chk
> 
> Normal     452      1     0     0    0   0  0 0 0 0 0     454 -5 <= 238
> Normal     452      1     0     0    0   0  0 0 0 0 0     454 -5 <= 238
> (kswapd wakes)
> Normal    7618     76     0     0    0   0  0 0 0 0 0    7770 145 <= 238
> Normal    8860     73     1     0    0   0  0 0 0 0 0    9010 143 <= 238
> Normal    8929     25     0     0    0   0  0 0 0 0 0    8979 43 <= 238
> Normal    8917      0     0     0    0   0  0 0 0 0 0    8917 -7 <= 238
> Normal    8978     16     0     0    0   0  0 0 0 0 0    9010 25 <= 238
> Normal    9064      4     0     0    0   0  0 0 0 0 0    9072 1 <= 238
> Normal    9068      2     0     0    0   0  0 0 0 0 0    9072 -3 <= 238
> Normal    8992      9     0     0    0   0  0 0 0 0 0    9010 11 <= 238
> Normal    9060      6     0     0    0   0  0 0 0 0 0    9072 5 <= 238
> Normal    9010      0     0     0    0   0  0 0 0 0 0    9010 -7 <= 238
> Normal    8907      5     0     0    0   0  0 0 0 0 0    8917 3 <= 238
> Normal    8576      0     0     0    0   0  0 0 0 0 0    8576 -7 <= 238
> Normal    8018      0     0     0    0   0  0 0 0 0 0    8018 -7 <= 238
> Normal    6778      0     0     0    0   0  0 0 0 0 0    6778 -7 <= 238
> Normal    6189      0     0     0    0   0  0 0 0 0 0    6189 -7 <= 238
> Normal    6220      0     0     0    0   0  0 0 0 0 0    6220 -7 <= 238
> Normal    6096      0     0     0    0   0  0 0 0 0 0    6096 -7 <= 238
> Normal    6251      0     0     0    0   0  0 0 0 0 0    6251 -7 <= 238
> Normal    6127      0     0     0    0   0  0 0 0 0 0    6127 -7 <= 238
> Normal    6218      1     0     0    0   0  0 0 0 0 0    6220 -5 <= 238
> Normal    6034      0     0     0    0   0  0 0 0 0 0    6034 -7 <= 238
> Normal    6065      0     0     0    0   0  0 0 0 0 0    6065 -7 <= 238
> Normal    6189      0     0     0    0   0  0 0 0 0 0    6189 -7 <= 238
> Normal    6189      0     0     0    0   0  0 0 0 0 0    6189 -7 <= 238
> Normal    6096      0     0     0    0   0  0 0 0 0 0    6096 -7 <= 238
> Normal    6127      0     0     0    0   0  0 0 0 0 0    6127 -7 <= 238
> Normal    6158      0     0     0    0   0  0 0 0 0 0    6158 -7 <= 238
> Normal    6127      0     0     0    0   0  0 0 0 0 0    6127 -7 <= 238
> (kswapd sleeps -- maybe too much turkey)
> 
> DMA32 get so much reclaimed that the watermark test succeeded long ago.
> Meanwhile, Normal is being reclaimed as well, but because it's fighting
> with allocations, it tries for a while and eventually succeeds (I think),
> but the 200ms samples didn't catch it.
> 
> KOSAKI Motohiro, I'm interested in your commit 73ce02e9.  This seems
> to be similar to this problem, but your change is not working here. 
> We're seeing kswapd run without sleeping, KSWAPD_SKIP_CONGESTION_WAIT
> is increasing (so has_under_min_watermark_zone is true), and pageoutrun
> increasing all the time.  This means that balance_pgdat() keeps being
> called, but sleeping_prematurely() is returning true, so kswapd() just
> keeps re-calling balance_pgdat().  If your approach is correct to stop
> kswapd here, the problem seems to be that balance_pgdat's copy of order
> and sc.order is being set to 0, but not pgdat->kswapd_max_order, so
> kswapd never really sleeps.  How is this supposed to work?

Um. this seems regression since commit f50de2d381 (vmscan: have kswapd sleep 
for a short interval and double check it should be asleep)

Can you please try this?



Subject: [PATCH] vmscan: don't rewakeup kswapd if zone memory was exhaust

---
 mm/vmscan.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1fcadaf..2945c74 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2148,7 +2148,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at high_wmark_pages(zone).
  *
- * Returns the number of pages which were actually freed.
+ * Return 1 if balancing was suceeded, otherwise 0.
  *
  * There is special handling here for zones which are full of pinned pages.
  * This can happen if the pages are all mlocked, or if they are all used by
@@ -2165,7 +2165,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
  * interoperates with the page allocator fallback scheme to ensure that aging
  * of pages is balanced across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
+static int balance_pgdat(pg_data_t *pgdat, int order)
 {
 	int all_zones_ok;
 	int priority;
@@ -2361,10 +2361,10 @@ out:
 		goto loop_again;
 	}
 
-	return sc.nr_reclaimed;
+	return (sc.nr_reclaimed >= SWAP_CLUSTER_MAX);
 }
 
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
+static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int force)
 {
 	long remaining = 0;
 	DEFINE_WAIT(wait);
@@ -2374,6 +2374,9 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
+	if (force)
+		goto sleep:
+
 	/* Try to sleep for a short interval */
 	if (!sleeping_prematurely(pgdat, order, remaining)) {
 		remaining = schedule_timeout(HZ/10);
@@ -2386,6 +2389,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 	 * go fully to sleep until explicitly woken up.
 	 */
 	if (!sleeping_prematurely(pgdat, order, remaining)) {
+ sleep:
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
@@ -2426,11 +2430,11 @@ static int kswapd(void *p)
 	unsigned long order;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
-
 	struct reclaim_state reclaim_state = {
 		.reclaimed_slab = 0,
 	};
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+	int balanced = 0;
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
@@ -2467,7 +2471,7 @@ static int kswapd(void *p)
 			 */
 			order = new_order;
 		} else {
-			kswapd_try_to_sleep(pgdat, order);
+			kswapd_try_to_sleep(pgdat, order, !balanced);
 			order = pgdat->kswapd_max_order;
 		}
 
@@ -2481,7 +2485,7 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			balance_pgdat(pgdat, order);
+			balanced = balance_pgdat(pgdat, order);
 		}
 	}
 	return 0;
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
