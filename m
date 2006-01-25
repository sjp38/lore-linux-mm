Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k0PIvm8a008334
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 10:57:49 -0800
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k0PITjtD97937378
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 10:29:45 -0800 (PST)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k0PIQ0OT20139320
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 10:26:00 -0800 (PST)
Date: Wed, 25 Jan 2006 10:18:40 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] zone_reclaim: partial scans instead of full scan.
Message-ID: <Pine.LNX.4.62.0601251016380.9732@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0601251025530.9861@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Instead of scanning all the pages in a zone, imitate real swap and
scan only a portion of the pages and gradually scan more if we do not
free up enough pages. This avoids a zone suddenly loosing all unused
pagecache pages (we may after all access some of these again so they 
deserve another chance) but it still frees up large chunks of memory if a 
zone only contains unused pagecache pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc1-mm3/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc1-mm3.orig/mm/vmscan.c	2006-01-25 10:02:09.000000000 -0800
+++ linux-2.6.16-rc1-mm3/mm/vmscan.c	2006-01-25 10:05:05.000000000 -0800
@@ -1835,6 +1835,14 @@ int zone_reclaim_mode __read_mostly;
  * Mininum time between zone reclaim scans
  */
 #define ZONE_RECLAIM_INTERVAL 30*HZ
+
+/*
+ * Priority for ZONE_RECLAIM. This determines the fraction of pages
+ * of a node considered for each zone_reclaim. 4 scans 1/16th of
+ * a zone.
+ */
+#define ZONE_RECLAIM_PRIORITY 4
+
 /*
  * Try to free up some pages from this zone through reclaim.
  */
@@ -1865,7 +1873,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	sc.may_swap = 0;
 	sc.nr_scanned = 0;
 	sc.nr_reclaimed = 0;
-	sc.priority = 0;
+	sc.priority = ZONE_RECLAIM_PRIORITY + 1;
 	sc.nr_mapped = read_page_state(nr_mapped);
 	sc.gfp_mask = gfp_mask;
 
@@ -1882,7 +1890,15 @@ int zone_reclaim(struct zone *zone, gfp_
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	shrink_zone(zone, &sc);
+	/*
+	 * Free memory by calling shrink zone with increasing priorities
+	 * until we have enough memory freed.
+	 */
+	do {
+		sc.priority--;
+		shrink_zone(zone, &sc);
+
+	} while (sc.nr_reclaimed < nr_pages && sc.priority > 0);
 
 	p->reclaim_state = NULL;
 	current->flags &= ~PF_MEMALLOC;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
