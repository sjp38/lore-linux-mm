Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E2CC96B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:08:33 -0500 (EST)
Subject: [patch]vmscan: make kswapd use a correct order
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 11:08:31 +0800
Message-ID: <1291172911.12777.58.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

T0: Task1 wakeup_kswapd(order=3)
T1: kswapd enters balance_pgdat
T2: Task2 wakeup_kswapd(order=2), because pages reclaimed by kswapd are used
quickly
T3: kswapd exits balance_pgdat. kswapd will do check. Now new order=2,
pgdat->kswapd_max_order will become 0, but order=3, if sleeping_prematurely,
then order will become pgdat->kswapd_max_order(0), while at this time the
order should 2
This isn't a big deal, but we do have a small window the order is wrong.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d31d7ce..15cd0d2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2450,7 +2450,7 @@ static int kswapd(void *p)
 				}
 			}
 
-			order = pgdat->kswapd_max_order;
+			order = max_t(unsigned long, new_order, pgdat->kswapd_max_order);
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
