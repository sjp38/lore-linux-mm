Date: Sun, 26 Mar 2000 21:59:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [PATCH] Re: kswapd
In-Reply-To: <200003261008.LAA16031@raistlin.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.21.0003262143500.1104-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Sun, 26 Mar 2000, Russell King wrote:

> I think I've solved (very dirtily) my kswapd problem

Your patch is the correct one. I've added an extra reschedule
point and cleaned up the code a little bit. I wonder who sent
the brown-paper-bag patch with the superfluous while loop to
Linus ...        (please raise your hand and/or buy rmk a beer)

Linus, could you please apply this patch ASAP? :)

regards,

Rik  (PS. I'm still planning to implement the VM changes I posted
to linux-mm earlier today, kswapd could be better and more efficient)
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.3.99-pre3/mm/vmscan.c.orig	Sat Mar 25 12:57:20 2000
+++ linux-2.3.99-pre3/mm/vmscan.c	Sun Mar 26 21:37:19 2000
@@ -499,19 +499,19 @@
 		 * the processes needing more memory will wake us
 		 * up on a more timely basis.
 		 */
-		do {
-			pgdat = pgdat_list;
-			while (pgdat) {
-				for (i = 0; i < MAX_NR_ZONES; i++) {
-					zone = pgdat->node_zones + i;
-					if ((!zone->size) || (!zone->zone_wake_kswapd))
-						continue;
-					do_try_to_free_pages(GFP_KSWAPD, zone);
-				}
-				pgdat = pgdat->node_next;
+		pgdat = pgdat_list;
+		while (pgdat) {
+			for (i = 0; i < MAX_NR_ZONES; i++) {
+				zone = pgdat->node_zones + i;
+				if (tsk->need_resched)
+					schedule();
+				if ((!zone->size) || (!zone->zone_wake_kswapd))
+					continue;
+				do_try_to_free_pages(GFP_KSWAPD, zone);
 			}
-			run_task_queue(&tq_disk);
-		} while (!tsk->need_resched);
+			pgdat = pgdat->node_next;
+		}
+		run_task_queue(&tq_disk);
 		tsk->state = TASK_INTERRUPTIBLE;
 		interruptible_sleep_on(&kswapd_wait);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
