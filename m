Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 5121438DD6
	for <linux-mm@kvack.org>; Fri, 15 Jun 2001 12:17:51 -0300 (EST)
Date: Fri, 15 Jun 2001 12:17:51 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [RFT][PATCH] even out background aging
Message-ID: <Pine.LNX.4.33.0106151211360.2262-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[Request For Testers:  please test this on your system...]

Hi,

the following patch makes use of the fact that refill_inactive()
now calls swap_out() before calling refill_inactive_scan() and
the fact that the inactive_dirty list is now reclaimed in a fair
LRU order.

Background scanning can now be replaced by a simple call to
refill_inactive(), instead of the refill_inactive_scan(), which
gave mapped pages an unfair advantage over unmapped ones.

The special-casing of the amount to scan in refill_inactive_scan()
is removed as well, there's absolutely no reason we'd need it with
the current VM balance.

regards,

Rik
--


--- linux-2.4.6-pre3/mm/vmscan.c.orig	Thu Jun 14 12:28:03 2001
+++ linux-2.4.6-pre3/mm/vmscan.c	Fri Jun 15 11:55:09 2001
@@ -695,13 +695,6 @@
 	int page_active = 0;
 	int nr_deactivated = 0;

-	/*
-	 * When we are background aging, we try to increase the page aging
-	 * information in the system.
-	 */
-	if (!target)
-		maxscan = nr_active_pages >> 4;
-
 	/* Take the lock while messing with the list... */
 	spin_lock(&pagemap_lru_lock);
 	while (maxscan-- > 0 && (page_lru = active_list.prev) != &active_list) {
@@ -978,7 +971,7 @@
 			recalculate_vm_stats();

 			/* Do background page aging. */
-			refill_inactive_scan(DEF_PRIORITY, 0);
+			refill_inactive(GFP_KSWAPD, 0);
 		}

 		run_task_queue(&tq_disk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
