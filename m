Date: Sat, 15 Jul 2000 14:56:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 2.4.0-test4 kswapd rebalancing fix
Message-ID: <Pine.LNX.4.21.0007151453200.17208-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@fenrus.demon.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, ttb@tentacle.dhis.org
List-ID: <linux-mm.kvack.org>

Hi,

the attached patch should fix the following things in
2.4.0-test4:
- kswapd keeping too much memory free
- bad performance in some cases because kswapd doesn't
  have the ability to properly balance between zones

(this patch was created in 1 minute in response to a complaint
from some people on #kernelnewbies, I'm working on the new VM
myself and won't take any time to defend or talk about this patch
if it turns out people for some reason don't like it)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.4.0-test4/mm/vmscan.c.orig	Sat Jul 15 14:48:38 2000
+++ linux-2.4.0-test4/mm/vmscan.c	Sat Jul 15 14:49:49 2000
@@ -440,27 +440,6 @@
 }
 
 /*
- * Check if there recently has been memory pressure (zone_wake_kswapd)
- */
-static inline int keep_kswapd_awake(void)
-{
-	pg_data_t *pgdat = pgdat_list;
-
-	do {
-		int i;
-		for(i = 0; i < MAX_NR_ZONES; i++) {
-			zone_t *zone = pgdat->node_zones+ i;
-			if (zone->size &&
-			    zone->zone_wake_kswapd)
-				return 1;
-		}
-		pgdat = pgdat->node_next;
-	} while (pgdat);
-
-	return 0;
-}
-
-/*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
  * without holding the kernel lock etc.
@@ -595,7 +574,7 @@
 	tsk->flags |= PF_MEMALLOC;
 
 	for (;;) {
-		if (!keep_kswapd_awake()) {
+		if (!memory_pressure()) {
 			/* wake up regulary to do an early attempt too free
 			 * pages - pages will not actually be freed.
 			 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
