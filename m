Message-ID: <485EF481.30409@ah.jp.nec.com>
Date: Mon, 23 Jun 2008 09:55:29 +0900
From: Takenori Nagano <t-nagano@ah.jp.nec.com>
MIME-Version: 1.0
Subject: [patch] memory reclaim more  efficiently
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Keiichi KII <kii@linux.bs1.fc.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi,

Efficiency of memory reclaim is recently one of the hot topics. (LRU splitting,
pageout throttling, etc...) I would like to contribute it and I made this patch.

In shrink_zone(), system can not return to user mode before it finishes to
search LRU list. IMHO, it is very wasteful, since the user processes stay
unnecessarily long time in shrink_zone() loop and application response time
becomes relatively bad. This patch changes shrink_zone() that it finishes memory
reclaim when it reclaims enough memory.

the conditions to end searching:

1. order of request page is 0
2. process is not kswapd.
3. satisfy the condition to return try_to_free_pages()
   # nr_reclaim > SWAP_CLUSTER_MAX


Signed-off-by: Takenori Nagano <t-nagano@ah.jp.nec.com>
Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---
diff -uprN linux-2.6.26-rc6.orig/mm/vmscan.c linux-2.6.26-rc6/mm/vmscan.c
--- linux-2.6.26-rc6.orig/mm/vmscan.c	2008-06-13 06:22:24.000000000 +0900
+++ linux-2.6.26-rc6/mm/vmscan.c	2008-06-20 15:05:03.492700863 +0900
@@ -1224,6 +1224,9 @@ static unsigned long shrink_zone(int pri
 			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
 								sc);
 		}
+		if (nr_reclaimed > sc->swap_cluster_max && !sc->order
+						&& !current_is_kswapd())
+			break;
 	}
 
 	throttle_vm_writeout(sc->gfp_mask);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
