Date: Mon, 30 Jan 2006 12:33:16 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Reclaim slab during zone reclaim
Message-ID: <Pine.LNX.4.62.0601301232380.4929@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If large amounts of zone memory are used by empty slabs then zone_reclaim
becomes uneffective. This patch shakes the slab a bit.

The problem with this patch is that the slab reclaim is not containable
to a zone. Thus slab reclaim may affect the whole system and be extremely
slow. This also means that we cannot determine how many pages were freed
in this zone. Thus we need to go off node for at least one allocation.

The functionality is disabled by default.

We could modify the shrinkers to take a zone parameter but that would be
quite invasive. Better ideas are welcome.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc1-mm4/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc1-mm4.orig/mm/vmscan.c	2006-01-30 11:38:05.000000000 -0800
+++ linux-2.6.16-rc1-mm4/mm/vmscan.c	2006-01-30 11:43:19.000000000 -0800
@@ -1835,6 +1835,7 @@ int zone_reclaim_mode __read_mostly;
 #define RECLAIM_ZONE (1<<0)	/* Run shrink_cache on the zone */
 #define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
 #define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
+#define RECLAIM_SLAB (1<<3)	/* Do a global slab shrink if the zone is out of memory */
 
 /*
  * Mininum time between zone reclaim scans
@@ -1905,6 +1906,19 @@ int zone_reclaim(struct zone *zone, gfp_
 
 	} while (sc.nr_reclaimed < nr_pages && sc.priority > 0);
 
+	if (sc.nr_reclaimed < nr_pages && (zone_reclaim_mode & RECLAIM_SLAB)) {
+		/*
+		 * shrink_slab does not currently allow us to determine
+		 * how many pages were freed in the zone. So we just
+		 * shake the slab and then go offnode for a single allocation.
+		 *
+		 * shrink_slab will free memory on all zones and may take
+		 * a long time.
+		 */
+		shrink_slab(sc.nr_scanned, gfp_mask, order);
+		sc.nr_reclaimed = 1;    /* Avoid getting the off node timeout */
+	}
+
 	p->reclaim_state = NULL;
 	current->flags &= ~PF_MEMALLOC;
 
Index: linux-2.6.16-rc1-mm4/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.16-rc1-mm4.orig/Documentation/sysctl/vm.txt	2006-01-30 11:42:59.000000000 -0800
+++ linux-2.6.16-rc1-mm4/Documentation/sysctl/vm.txt	2006-01-30 11:43:19.000000000 -0800
@@ -137,6 +137,7 @@ This is value ORed together of
 1	= Zone reclaim on
 2	= Zone reclaim writes dirty pages out
 4	= Zone reclaim swaps pages
+8	= Also do a global slab reclaim pass
 
 zone_reclaim_mode is set during bootup to 1 if it is determined that pages
 from remote zones will cause a measurable performance reduction. The
@@ -160,6 +161,11 @@ Allowing regular swap effectively restri
 node unless explicitly overridden by memory policies or cpuset
 configurations.
 
+It may be advisable to allow slab reclaim if the system makes heavy
+use of files and builds up large slab caches. However, the slab
+shrink operation is global, may take a long time and free slabs
+in all nodes of the system.
+
 ================================================================
 
 zone_reclaim_interval:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
