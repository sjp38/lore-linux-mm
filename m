Date: Wed, 3 May 2000 14:11:46 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [PATCHlet] Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <200005020023.RAA31259@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0005031408250.10610-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: roger.larsson@norran.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2000, David S. Miller wrote:
> BTW, what loop are you trying to "continue;" out of here?
> 
> +			    do {
>  				if (tsk->need_resched)
>  					schedule();
>  				if ((!zone->size) || (!zone->zone_wake_kswapd))
>  					continue;
>  				do_try_to_free_pages(GFP_KSWAPD, zone);
> +			   } while (zone->free_pages < zone->pages_low &&
> +					   --count);

Ughhhhh. And the worst part is that it took me a few _days_ to
figure out ;)

Anyway, the fix for this small buglet is attached. I'll continue
working on the active/inactive lists (per pgdat!), if I haven't
sent in the active/inactive list thing for the next prepatch, it
would be nice to have this small fix applied.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/


--- vmscan.c.orig	Wed May  3 10:51:36 2000
+++ vmscan.c	Wed May  3 13:00:00 2000
@@ -528,15 +528,15 @@
 		pgdat = pgdat_list;
 		while (pgdat) {
 			for (i = 0; i < MAX_NR_ZONES; i++) {
-			    int count = SWAP_CLUSTER_MAX;
-			    zone = pgdat->node_zones + i;
-			    do {
-				if (tsk->need_resched)
-					schedule();
+				int count = SWAP_CLUSTER_MAX;
+				zone = pgdat->node_zones + i;
 				if ((!zone->size) || (!zone->zone_wake_kswapd))
 					continue;
-				do_try_to_free_pages(GFP_KSWAPD, zone);
-			   } while (zone->free_pages < zone->pages_low &&
+				do {
+					if (tsk->need_resched)
+						schedule();
+					do_try_to_free_pages(GFP_KSWAPD, zone);
+		 		} while (zone->free_pages < zone->pages_low &&
 					   --count);
 			}
 			pgdat = pgdat->node_next;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
