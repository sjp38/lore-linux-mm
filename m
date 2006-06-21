Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LI9aSf027658
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 11:09:36 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LFkr8s14892768
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LFkrnB8936092
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft4ur-0004wa-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700
Date: Wed, 21 Jun 2006 08:44:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060621154445.18741.58979.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 05/14] Remove NR_FILE_MAPPED from scan control structure
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606210846470.18960@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Subject: zoned VM stats: Remove nr_mapped from scan control
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Martin Bligh <mbligh@google.com>, linux-mm@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

We can now access the number of pages in a mapped state in an inexpensive
way in shrink_active_list.  So drop the nr_mapped field from scan_control.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmscan.c	2006-06-21 07:35:39.744211663 -0700
+++ linux-2.6.17-mm1/mm/vmscan.c	2006-06-21 07:37:24.659577925 -0700
@@ -46,8 +46,6 @@ struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
-	unsigned long nr_mapped;	/* From page_state */
-
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 
@@ -727,7 +725,8 @@ static void shrink_active_list(unsigned 
 		 * how much memory
 		 * is mapped.
 		 */
-		mapped_ratio = (sc->nr_mapped * 100) / total_memory;
+		mapped_ratio = (global_page_state(NR_FILE_MAPPED) * 100) /
+					total_memory;
 
 		/*
 		 * Now decide how much we really want to unmap some pages.  The
@@ -972,7 +971,6 @@ unsigned long try_to_free_pages(struct z
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		sc.nr_mapped = global_page_state(NR_FILE_MAPPED);
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
@@ -1062,8 +1060,6 @@ loop_again:
 	total_scanned = 0;
 	nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
-	sc.nr_mapped = global_page_state(NR_FILE_MAPPED);
-
 	inc_page_state(pageoutrun);
 
 	for (i = 0; i < pgdat->nr_zones; i++) {
@@ -1412,7 +1408,6 @@ static int __zone_reclaim(struct zone *z
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
-		.nr_mapped = global_page_state(NR_FILE_MAPPED),
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
