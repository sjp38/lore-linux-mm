Received: from d1o43.telia.com (d1o43.telia.com [194.22.195.241])
	by maild.telia.com (8.9.3/8.9.3) with ESMTP id BAA22743
	for <linux-mm@kvack.org>; Tue, 6 Jun 2000 01:15:49 +0200 (CEST)
Received: from norran.net (roger@t3o43p4.telia.com [194.22.195.124])
	by d1o43.telia.com (8.8.8/8.8.8) with ESMTP id BAA09649
	for <linux-mm@kvack.org>; Tue, 6 Jun 2000 01:15:47 +0200 (CEST)
Message-ID: <393C3435.8AED5654@norran.net>
Date: Tue, 06 Jun 2000 01:13:57 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] code clean up of kswapd
Content-Type: multipart/mixed;
 boundary="------------C76FA38541B7127214CCA38C"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------C76FA38541B7127214CCA38C
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi all,

This is only a code clean up of kswapd -
It should do almost the same.

I do not claim improved performance :-(
But improved readability :-)

Basically done to be able to add other
stuff more easily later...

[Not tried against ac8, but ac7+riel.3
 should be almost the same]

Comments?

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------C76FA38541B7127214CCA38C
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test1-ac7-riel.3-kswapd.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test1-ac7-riel.3-kswapd.1"

--- vmscan.c.riel	Sat Jun  3 19:09:16 2000
+++ vmscan.c	Sat Jun  3 22:30:22 2000
@@ -551,24 +551,39 @@
 	for (;;) {
 		pg_data_t *pgdat;
 		int something_to_do = 0;
+		int more_to_do = 0;
 
 		pgdat = pgdat_list;
 		do {
 			int i;
+
 			for(i = 0; i < MAX_NR_ZONES; i++) {
 				zone_t *zone = pgdat->node_zones+ i;
-				if (tsk->need_resched)
-					schedule();
 				if (!zone->size || !zone->zone_wake_kswapd)
 					continue;
+				something_to_do = 1;
 				if (zone->free_pages < zone->pages_low)
-					something_to_do = 1;
-				do_try_to_free_pages(GFP_KSWAPD);
+				        more_to_do = 1;
 			}
 			pgdat = pgdat->node_next;
+
 		} while (pgdat);
 
-		if (!something_to_do) {
+		/* Need to free pages?
+		 * Will actually run fewer times than previous version!
+		 * (It did run once per zone with waken kswapd)
+		 */
+		if (something_to_do) { 
+		  do_try_to_free_pages(GFP_KSWAPD);
+		}
+
+		/* In a hurry? */
+		if (more_to_do) {
+		        if (tsk->need_resched) {
+		           schedule();
+			}
+		}
+		else {
 			tsk->state = TASK_INTERRUPTIBLE;
 			interruptible_sleep_on(&kswapd_wait);
 		}

--------------C76FA38541B7127214CCA38C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
