Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k59KlRYm019256
	for <linux-mm@kvack.org>; Fri, 9 Jun 2006 13:47:27 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k59IQS8s11366643
	for <linux-mm@kvack.org>; Fri, 9 Jun 2006 11:26:28 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k59IQRnB40513831
	for <linux-mm@kvack.org>; Fri, 9 Jun 2006 11:26:27 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Folgh-0000A2-00
	for <linux-mm@kvack.org>; Fri, 09 Jun 2006 11:26:27 -0700
Date: Fri, 9 Jun 2006 11:22:52 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: zoned VM stats: Remove nr_mapped from zone reclaim
Message-ID: <Pine.LNX.4.64.0606091121580.520@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606091126190.520@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

We can now access the number of mapped state in an inexpensive
way in shrink_active_list. So drop the nr_mapped field from
scan_control.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.17-rc6-mm1.orig/mm/vmscan.c	2006-06-09 10:30:52.044367475 -0700
+++ linux-2.6.17-rc6-mm1/mm/vmscan.c	2006-06-09 11:14:02.891680453 -0700
@@ -48,8 +48,6 @@ struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
-	unsigned long nr_mapped;	/* From page_state */
-
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 
@@ -749,7 +747,7 @@ static void shrink_active_list(unsigned 
 		 * how much memory
 		 * is mapped.
 		 */
-		mapped_ratio = (sc->nr_mapped * 100) / vm_total_pages;
+		mapped_ratio = global_page_state(NR_MAPPED) / vm_total_pages;
 
 		/*
 		 * Now decide how much we really want to unmap some pages.  The
@@ -997,7 +995,6 @@ unsigned long try_to_free_pages(struct z
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		sc.nr_mapped = global_page_state(NR_MAPPED);
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
@@ -1082,7 +1079,6 @@ loop_again:
 	total_scanned = 0;
 	nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode,
-	sc.nr_mapped = global_page_state(NR_MAPPED);
 
 	inc_page_state(pageoutrun);
 
@@ -1417,7 +1413,6 @@ unsigned long shrink_all_memory(unsigned
 		for (prio = DEF_PRIORITY; prio >= 0; prio--) {
 			unsigned long nr_to_scan = nr_pages - ret;
 
-			sc.nr_mapped = global_page_state(NR_MAPPED);
 			sc.nr_scanned = 0;
 
 			ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
@@ -1554,7 +1549,6 @@ static int __zone_reclaim(struct zone *z
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
-		.nr_mapped = global_page_state(NR_MAPPED),
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
